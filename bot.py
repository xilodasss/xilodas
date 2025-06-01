import json
import os
import random
import re
from datetime import datetime, timedelta
import logging
import tempfile
import inspect
import pyfiglet
import asyncio
import hashlib
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

from telegram import (
    InlineKeyboardButton, InlineKeyboardMarkup, Update, BotCommand, InputFile,
    BotCommandScopeAllPrivateChats, BotCommandScopeChat
)
from telegram.ext import (
    Application,
    CommandHandler,
    ContextTypes,
    CallbackQueryHandler,
    MessageHandler,
    filters,
    ConversationHandler
)
from telegram.constants import ParseMode
from telegram.error import BadRequest

# Files
config_file_path = 'config.json'
keys_data_file_path = 'keys_data.json'
referral_data_file_path = 'referral_data.json'

# Directories
base_dir_path = "bot_data"
logs_dir_path = os.path.join(base_dir_path, "source_combo_lists")
generated_files_dir_path = os.path.join(base_dir_path, "generated_files")
junk_files_dir_path = os.path.join(base_dir_path, "junk_processed_lines")
user_info_dir_path = os.path.join(base_dir_path, "user_info")

# Globals
app_config = {}
app_keys_data = {"keys": {}, "user_access": {}}
app_referral_data = {"user_points": {}, "referred_users": {}}
bot_start_timestamp = datetime.now()

# Patterns
email_pattern_regex = re.compile(r"([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})[:|]([^\s]+)")
username_pattern_regex = re.compile(r"([a-zA-Z0-9_.-]{3,})[:|]([^\s]+)")
key_pattern_regex = re.compile(r"^[A-Z0-9]{16}$")

# Executor
file_op_executor = ThreadPoolExecutor(max_workers=2)

# Banner
raw_banner_text = "xilodas"
compact_font = pyfiglet.Figlet(font='small')
ascii_art_banner_raw = compact_font.renderText(raw_banner_text)

# Colors
LOG_COLORS = {
    "bot": "\033[96m",
    "user": "\033[92m",
    "owner": "\033[95m",
    "error": "\033[91m",
    "warning": "\033[93m",
    "default": "\033[0m",
    "info_default": "\033[97m"
}
CONSOLE_COLORS_FOR_BANNER = ["\033[91m", "\033[92m", "\033[93m", "\033[94m", "\033[95m", "\033[96m"]
CONSOLE_RESET_COLOR = "\033[0m"

def colorize_banner_for_console(banner_text): # Colorize
    lines = banner_text.split('\n'); colorized_lines = []
    char_idx = 0
    for i, line in enumerate(lines):
        if line.strip():
            char_colored_line = ""
            for char_val in line:
                if char_val != ' ':
                    char_colored_line += CONSOLE_COLORS_FOR_BANNER[char_idx % len(CONSOLE_COLORS_FOR_BANNER)] + char_val
                    char_idx +=1
                else: char_colored_line += char_val
            colorized_lines.append(char_colored_line + CONSOLE_RESET_COLOR)
        else: colorized_lines.append(line)
    return "\n".join(colorized_lines)
colored_ascii_art_banner_console = colorize_banner_for_console(ascii_art_banner_raw)

# Logging
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
logging.getLogger("httpx").setLevel(logging.WARNING)
logging.getLogger("telegram.ext").setLevel(logging.WARNING)

class CustomLogFormatter(logging.Formatter): # Formatter
    def format(self, record):
        log_prefix = ""; log_message = record.getMessage()
        if hasattr(record, 'log_type'):
            log_type = record.log_type; color = LOG_COLORS.get(log_type, LOG_COLORS["default"])
            log_prefix = f"{color}[{log_type}]{CONSOLE_RESET_COLOR} "
        elif record.levelno == logging.ERROR:
            color = LOG_COLORS["error"]; log_prefix = f"{color}[error]{CONSOLE_RESET_COLOR} "
            log_message = f"{log_message} ({record.filename}:{record.lineno})"
        elif record.levelno == logging.WARNING:
            color = LOG_COLORS["warning"]; log_prefix = f"{color}[warning]{CONSOLE_RESET_COLOR} "
        elif record.levelno == logging.INFO :
            color = LOG_COLORS["info_default"]; log_prefix = f"{color}[info]{CONSOLE_RESET_COLOR} "
        else: log_prefix = f"[{record.levelname.lower()}]{CONSOLE_RESET_COLOR} "
        return f"{log_prefix}{log_message}"

console_handler = logging.StreamHandler()
console_handler.setFormatter(CustomLogFormatter())
if not logger.hasHandlers(): logger.addHandler(console_handler)
logger.propagate = False

def log_bot_update(message): logger.info(message, extra={'log_type': 'bot'}) # Bot
def log_user_activity(message): logger.info(message, extra={'log_type': 'user'}) # User
def log_owner_activity(message): logger.info(message, extra={'log_type': 'owner'}) # Owner
def log_error_simplified(message, exc_info=False): logger.error(message, exc_info=exc_info) # Error
def log_warning_simplified(message): logger.warning(message) # Warning

# States
STATE_AWAITING_GENKEY_DURATION = 1
STATE_AWAITING_GENKEY_AMOUNT = 2

def load_app_config(): # Configuration
    global app_config
    default_settings = {
        "bot_token": "YOUR_BOT_TOKEN_HERE",
        "owner_id": 0,
        "points_per_redeem": 5,
        "accounts_per_redeem": 50,
        "max_referral_points": 50,
        "default_generate_count": 50
    }
    numeric_keys = ["owner_id", "points_per_redeem", "accounts_per_redeem", "max_referral_points", "default_generate_count"]
    
    current_config = default_settings.copy()
    config_changed_or_created = False
    loaded_config_values = {}

    try:
        with open(config_file_path, 'r') as f:
            loaded_config_values = json.load(f)
        for key in default_settings:
            if key in loaded_config_values:
                current_config[key] = loaded_config_values[key]
            else:
                log_warning_simplified(f"Config: '{key}' missing in '{config_file_path}'. Using default: {default_settings[key]}.")
                config_changed_or_created = True
    
    except FileNotFoundError:
        log_error_simplified(f"'{config_file_path}' not found. Creating with default values.")
        config_changed_or_created = True
    except json.JSONDecodeError:
        log_error_simplified(f"'{config_file_path}' contains invalid JSON. Using defaults and will overwrite the file.")
        config_changed_or_created = True

    for key in numeric_keys:
        if not isinstance(current_config[key], int):
            original_value = current_config[key]
            current_config[key] = default_settings[key]
            log_warning_simplified(f"Config: '{key}' ('{original_value}') is not an integer. Corrected to default: {default_settings[key]}.")
            config_changed_or_created = True

    app_config = current_config

    if app_config.get("owner_id") == 0 or app_config.get("bot_token") == "YOUR_BOT_TOKEN_HERE" or not app_config.get("bot_token"):
        log_error_simplified("CRITICAL: 'owner_id' or 'bot_token' is not correctly set in config.json.")
        # Ensure a config file is written out, especially if it was just created or had errors
        if not os.path.exists(config_file_path) or loaded_config_values.get("owner_id") == 0 or loaded_config_values.get("bot_token") == "YOUR_BOT_TOKEN_HERE" or config_changed_or_created:
            with open(config_file_path, 'w') as f:
                json.dump(app_config, f, indent=4) # Save current state (likely defaults or partially filled)
            print(f"'{config_file_path}' has been created/updated. Please ensure 'bot_token' (not 'YOUR_BOT_TOKEN_HERE') and 'owner_id' (not 0) are correctly set.")
        exit(1)
    
    if config_changed_or_created:
        with open(config_file_path, 'w') as f:
            json.dump(app_config, f, indent=4)
        log_bot_update(f"'{config_file_path}' has been updated/created with current settings.")

def load_data_from_file(file_path, default_content): # Load
    try:
        with open(file_path, 'r') as f: return json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        save_data_to_file(file_path, default_content); return default_content

def save_data_to_file(file_path, data_content): # Save
    try:
        with open(file_path, 'w') as f: json.dump(data_content, f, indent=4)
    except Exception as e: log_error_simplified(f"Save error {file_path}: {e}")

def initialize_all_data(): # Initialize
    global app_keys_data, app_referral_data
    app_keys_data = load_data_from_file(keys_data_file_path, {"keys": {}, "user_access": {}})
    app_referral_data = load_data_from_file(referral_data_file_path, {"user_points": {}, "referred_users": {}})

def save_app_keys_data(): save_data_to_file(keys_data_file_path, app_keys_data) # Keys
def save_app_referral_data(): save_data_to_file(referral_data_file_path, app_referral_data) # Referrals

def ensure_data_folders_exist(): # Folders
    for p in [base_dir_path, logs_dir_path, generated_files_dir_path, junk_files_dir_path, user_info_dir_path]:
        os.makedirs(p, exist_ok=True)
    if not os.path.exists(keys_data_file_path): save_app_keys_data()
    if not os.path.exists(referral_data_file_path): save_app_referral_data()

async def perform_initial_integrity_check(): # Integrity
    magic_signature = "anti skid: modified by @xilodas"
    try:
        src_lines, _ = inspect.getsourcelines(perform_initial_integrity_check)
        if magic_signature not in "".join(src_lines): log_error_simplified("Integrity check FAIL.")
    except Exception as e: log_error_simplified(f"Integrity check error: {e}")

def check_if_owner(user_id_val: int) -> bool: # Owner
    owner_id_val = app_config.get('owner_id')
    return owner_id_val is not None and user_id_val == owner_id_val

def list_available_domains(): # Domains
    domains_set = set()
    if os.path.exists(logs_dir_path) and os.path.isdir(logs_dir_path):
        for file_name in os.listdir(logs_dir_path):
            if file_name.lower().endswith(".txt"): domains_set.add(os.path.splitext(file_name)[0])
    return sorted(list(domains_set))

def get_domain_file_path(domain_name_str: str): # Path
    path = os.path.join(logs_dir_path, f"{domain_name_str.lower()}.txt")
    if os.path.exists(path): return path
    for name_in_folder in os.listdir(logs_dir_path):
        if name_in_folder.lower() == f"{domain_name_str.lower()}.txt":
            return os.path.join(logs_dir_path, name_in_folder)
    return None

def clean_urls_from_text(text_line: str) -> str: # Clean
    return re.sub(r'http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\\(\\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+', '', text_line).strip()

def extract_valid_combo(line_text: str) -> str | None: # Extract
    match = email_pattern_regex.search(line_text) or username_pattern_regex.search(line_text)
    if match:
        user, pwd = match.group(1).strip(), match.group(2).strip()
        if user and pwd: return f"{user}:{pwd}"
    return None

def _load_existing_generated_hashes() -> set[str]: # Hashes
    hashes = set()
    for fp_obj in Path(generated_files_dir_path).rglob("*.txt"):
        try:
            with fp_obj.open("r", encoding='utf-8', errors="ignore") as f:
                for line in f:
                    combo = extract_valid_combo(clean_urls_from_text(line))
                    if combo: hashes.add(hashlib.md5(combo.encode()).hexdigest())
        except OSError as e: log_error_simplified(f"Read error {fp_obj}: {e}")
    return hashes

def _extract_accounts_from_domain_file(domain_fp_str: str, count: int, existing_hashes: set[str]) -> list[tuple[str, str]]: # Accounts
    combos = set(); results = []; processed_hashes = set()
    try:
        with open(domain_fp_str, 'r', encoding='utf-8', errors='ignore') as f: lines = f.readlines()
        random.shuffle(lines)
        for orig_line in lines:
            if len(results) >= count: break
            cleaned = clean_urls_from_text(orig_line); combo = extract_valid_combo(cleaned)
            if combo:
                combo_hash = hashlib.md5(combo.encode()).hexdigest()
                if combo_hash not in existing_hashes and combo_hash not in processed_hashes and combo not in combos:
                    results.append((combo, orig_line.strip())); combos.add(combo); processed_hashes.add(combo_hash)
    except Exception as e: log_error_simplified(f"Processing error {domain_fp_str}: {e}")
    return results

def _move_used_lines_to_junk_file(domain_fp_str: str, lines_to_move: list[str]): # Junk
    if not lines_to_move or not domain_fp_str or not os.path.exists(domain_fp_str): return
    junk_path = os.path.join(junk_files_dir_path, f"processed_{os.path.basename(domain_fp_str)}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt")
    move_set = set(lines_to_move); remaining = []; moved_content = []
    try:
        with open(domain_fp_str, 'r', encoding='utf-8', errors='ignore') as src_f:
            for line in src_f:
                stripped = line.strip()
                if stripped in move_set: moved_content.append(line); move_set.remove(stripped)
                else: remaining.append(line)
        if moved_content:
            with open(domain_fp_str, 'w', encoding='utf-8') as src_w_f: src_w_f.writelines(remaining)
            os.makedirs(os.path.dirname(junk_path), exist_ok=True)
            with open(junk_path, 'a', encoding='utf-8') as junk_f:
                junk_f.write(f"# Moved from {os.path.basename(domain_fp_str)} at {datetime.now().isoformat()}\n")
                junk_f.writelines(moved_content); junk_f.write("\n")
    except Exception as e: log_error_simplified(f"Junking error {domain_fp_str}: {e}")

async def _background_move_to_junk_wrapper(domain_fp, orig_lines): # Background
    try:
        loop = asyncio.get_running_loop()
        await loop.run_in_executor(file_op_executor, _move_used_lines_to_junk_file, domain_fp, orig_lines)
    except Exception as e: log_error_simplified(f"Background junk error {os.path.basename(domain_fp)}: {e}", exc_info=True)

async def retrieve_accounts_from_domain_async(domain_name: str, count: int = 1): # Retrieve
    domain_fp = get_domain_file_path(domain_name)
    if not domain_fp: log_user_activity(f"File not found for '{domain_name}'."); return None, []
    loop = asyncio.get_running_loop()
    existing_hashes = await loop.run_in_executor(file_op_executor, _load_existing_generated_hashes)
    extracted_pairs = await loop.run_in_executor(file_op_executor, _extract_accounts_from_domain_file, domain_fp, count, existing_hashes)
    valid_combos = [p[0] for p in extracted_pairs]; orig_lines = [p[1] for p in extracted_pairs]
    if orig_lines: asyncio.create_task(_background_move_to_junk_wrapper(domain_fp, orig_lines))
    return valid_combos, orig_lines

def verify_user_access(user_id: int) -> bool: # Access
    if check_if_owner(user_id): return True
    uid_str = str(user_id); access = app_keys_data["user_access"].get(uid_str)
    if not access: return False
    try:
        expiry = datetime.fromisoformat(access['expiry'])
        if expiry < datetime.now(): del app_keys_data["user_access"][uid_str]; save_app_keys_data(); return False
        return True
    except ValueError: del app_keys_data["user_access"][uid_str]; save_app_keys_data(); return False

def format_uptime_duration() -> str: # Uptime
    delta = datetime.now() - bot_start_timestamp; secs = delta.total_seconds()
    d, r = divmod(secs, 86400); h, r = divmod(r, 3600); m, s = divmod(r, 60)
    parts = [f"{int(x)}{u}" for x, u in zip([d,h,m,s], "dhms") if int(x)]
    return " ".join(parts) or "0s"

async def send_or_edit_message(upd: Update, ctx: ContextTypes.DEFAULT_TYPE, txt: str, reply_markup=None, parse_mode=None): # Message
    chat_id = upd.effective_chat.id if upd.effective_chat else 0
    key = f"last_bot_message_id_{chat_id}"
    try:
        if ctx.chat_data and ctx.chat_data.get(key) and chat_id:
            await ctx.bot.edit_message_text(chat_id=chat_id, message_id=ctx.chat_data[key],
                                            text=txt, reply_markup=reply_markup, parse_mode=parse_mode)
        elif upd.message:
            msg = await upd.message.reply_text(txt, reply_markup=reply_markup, parse_mode=parse_mode)
            if ctx.chat_data is not None: ctx.chat_data[key] = msg.message_id
    except Exception as e:
        log_error_simplified(f"Edit/Send fail: {e}")
        if upd.message:
            try:
                msg = await upd.message.reply_text(txt, reply_markup=reply_markup, parse_mode=parse_mode)
                if ctx.chat_data is not None: ctx.chat_data[key] = msg.message_id
            except Exception as e2: log_error_simplified(f"Fallback send also failed: {e2}")

async def handle_start_command(upd: Update, ctx: ContextTypes.DEFAULT_TYPE): # Start
    user = upd.effective_user; uid_str = str(user.id); referred = False
    chat_id = upd.effective_chat.id if upd.effective_chat else 0
    if ctx.chat_data: ctx.chat_data.pop(f"last_bot_message_id_{chat_id}", None)
    log_user_activity(f"{uid_str} ({user.username or 'NoUser'}) /start.")

    if ctx.args and ctx.args[0].startswith("ref_"):
        referrer_id_str_val = ctx.args[0][4:]
        if referrer_id_str_val.isdigit() and uid_str != referrer_id_str_val and not app_referral_data["referred_users"].get(uid_str):
            app_referral_data["referred_users"][uid_str] = referrer_id_str_val
            user_current_points = app_referral_data["user_points"].get(referrer_id_str_val, 0)

            if user_current_points < app_config['max_referral_points']:
                user_new_points = user_current_points + 1
                app_referral_data["user_points"][referrer_id_str_val] = user_new_points
                save_app_referral_data(); referred = True
                log_user_activity(f"{uid_str} referred by {referrer_id_str_val}. Referrer points: {user_new_points}")
                try: await ctx.bot.send_message(chat_id=int(referrer_id_str_val), text=f"🎉 New referral! You earned a point. Total points: {user_new_points}")
                except Exception as e: log_error_simplified(f"Notify referrer {referrer_id_str_val} err: {e}")
            else:
                save_app_referral_data(); referred = True
                log_user_activity(f"{uid_str} referred by {referrer_id_str_val}. Referrer at max points.")
                try: await ctx.bot.send_message(chat_id=int(referrer_id_str_val), text=f"🎉 New referral! You're already at the maximum of {app_config['max_referral_points']} points.")
                except Exception as e: log_error_simplified(f"Notify referrer {referrer_id_str_val} (max pts) err: {e}")

        elif uid_str == referrer_id_str_val: await send_or_edit_message(upd, ctx, "🤦 No self-refer.")
        elif app_referral_data["referred_users"].get(uid_str): await send_or_edit_message(upd, ctx, "😊 You've already been processed by a referral link.")

    banner = f"<pre>originated by @xilodas </pre>\n"; body = f"Hello {user.mention_html()}!\n\n"
    if referred: body += "Thanks for joining via a referral link! Your referrer has been credited.\n\n"
    uptime = format_uptime_duration()
    body += (f"BOT FILES GENERATOR.\n/generate\n/redeem <code>KEY</code>\n/myreferral\n/usepoints\n\nStatus: Active ({uptime})")
    await send_or_edit_message(upd, ctx, banner + body, parse_mode=ParseMode.HTML)

async def prompt_genkey_duration(upd: Update, ctx: ContextTypes.DEFAULT_TYPE) -> int: # Genkey
    if not check_if_owner(upd.effective_user.id): await send_or_edit_message(upd, ctx, "🚫 Owner only."); return ConversationHandler.END
    log_owner_activity(f"{upd.effective_user.id} initiated /generatekey.")
    await send_or_edit_message(upd, ctx, "🔑 Enter duration for key(s) (e.g., 7d, 1m, custom:30):")
    return STATE_AWAITING_GENKEY_DURATION

async def received_genkey_duration(upd: Update, ctx: ContextTypes.DEFAULT_TYPE) -> int: # Duration
    duration_input = upd.message.text.strip()
    key_duration_val = duration_input
    if duration_input.lower().startswith("custom:"):
        try: days_val = int(duration_input.split(":")[1]); assert days_val > 0; key_duration_val = f"{days_val}d"
        except: await upd.message.reply_text("Invalid custom duration. Try custom:X (X=days). Start over /generatekey"); return ConversationHandler.END
    elif duration_input not in ['1m','1h','1d','7d','30d','lifetime']:
        await upd.message.reply_text("Invalid duration. Use 1m,1h,1d,7d,30d,lifetime or custom:X. Start over /generatekey"); return ConversationHandler.END

    ctx.user_data['genkey_duration'] = key_duration_val
    ctx.user_data['genkey_duration_display'] = duration_input
    await upd.message.reply_text(f"Duration set to: {duration_input}. Now, how many keys?")
    return STATE_AWAITING_GENKEY_AMOUNT

async def received_genkey_amount(upd: Update, ctx: ContextTypes.DEFAULT_TYPE) -> int: # Amount
    try: amount_val = int(upd.message.text.strip()); assert amount_val > 0
    except: await upd.message.reply_text("Invalid amount. Must be a positive number. Start over /generatekey"); return ConversationHandler.END

    duration_val = ctx.user_data.get('genkey_duration')
    duration_display = ctx.user_data.get('genkey_duration_display', duration_val)
    user_id_val = upd.effective_user.id

    keys_list = [''.join(random.choices('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', k=16)) for _ in range(amount_val)]
    for k_str in keys_list:
        app_keys_data["keys"][k_str] = {'duration': duration_val, 'used': False, 'generated_by': user_id_val,
                                    'generated_at': datetime.now().isoformat(), 'used_by': None, 'used_at': None}
    save_app_keys_data(); log_owner_activity(f"{user_id_val} generated {amount_val} keys duration {duration_display}.")
    keys_text = '\n'.join(keys_list)
    resp_msg = f"✅ Generated {amount_val} keys (duration: {duration_display}):\n\n<pre>{keys_text}</pre>"
    if len(resp_msg) > 4096: resp_msg = f"✅ Generated {amount_val} keys (duration: {duration_display}). List too long."
    await upd.message.reply_text(resp_msg, parse_mode=ParseMode.HTML)

    ctx.user_data.pop('genkey_duration', None); ctx.user_data.pop('genkey_duration_display', None)
    return ConversationHandler.END

async def cancel_genkey_conversation(upd: Update, ctx: ContextTypes.DEFAULT_TYPE) -> int: # Cancel
    await send_or_edit_message(upd, ctx, "Key generation cancelled.")
    ctx.user_data.pop('genkey_duration', None); ctx.user_data.pop('genkey_duration_display', None)
    return ConversationHandler.END

async def process_potential_key_message(upd: Update, ctx: ContextTypes.DEFAULT_TYPE): # AutoRedeem
    if upd.message is None or upd.message.text is None: return
    text_key = upd.message.text.strip().upper()
    if not key_pattern_regex.fullmatch(text_key): return

    user_id_val = upd.effective_user.id
    if check_if_owner(user_id_val) or verify_user_access(user_id_val): return

    key_details = app_keys_data["keys"].get(text_key)
    if not key_details or key_details['used']:
        if key_details and key_details['used']: log_user_activity(f"{user_id_val} sent used key: {text_key}")
        return

    dur_map = {'1m': 1, '1h': 60, '1d': 1440, '7d': 10080, '30d': 43200, 'lifetime': 52560000}
    key_dur_str = key_details['duration']; delta = None
    if key_dur_str.endswith('d') and key_dur_str[:-1].isdigit(): delta = timedelta(days=int(key_dur_str[:-1]))
    elif key_dur_str in dur_map: delta = timedelta(minutes=dur_map[key_dur_str])
    if not delta: log_error_simplified(f"Invalid key duration {key_dur_str} for {text_key}"); return

    expiry = datetime.now() + delta
    app_keys_data["user_access"][str(user_id_val)] = {'expiry': expiry.isoformat(), 'key': text_key, 'redeemed_at': datetime.now().isoformat()}
    app_keys_data["keys"][text_key].update({'used': True, 'used_by': user_id_val, 'used_at': datetime.now().isoformat()})
    save_app_keys_data(); log_user_activity(f"{user_id_val} auto-redeemed key: {text_key}")
    await upd.message.reply_text(f"🔑 Key <code>{text_key}</code> auto-redeemed!\nAccess until {expiry.strftime('%Y-%m-%d %H:%M UTC')}", parse_mode=ParseMode.HTML)
    await handle_start_command(upd, ctx)

async def handle_redeem_key_command(upd: Update, ctx: ContextTypes.DEFAULT_TYPE): # Redeem
    user_id_val = upd.effective_user.id
    chat_id_val = upd.effective_chat.id if upd.effective_chat else 0
    if ctx.chat_data: ctx.chat_data.pop(f"last_bot_message_id_{chat_id_val}", None)
    if check_if_owner(user_id_val): await send_or_edit_message(upd, ctx, "🔑 Owner has permanent access."); return
    if len(ctx.args or []) != 1: await send_or_edit_message(upd, ctx, "Usage: /redeem <KEY>"); return

    key_string_to_redeem = ctx.args[0].strip().upper()
    if verify_user_access(user_id_val): await send_or_edit_message(upd, ctx, "🔑 You already have active access."); return

    key_details = app_keys_data["keys"].get(key_string_to_redeem)
    if not key_details: await send_or_edit_message(upd, ctx, "❌ Invalid key."); return
    if key_details['used']:
        used_at_time_str = "Unknown"
        if key_details.get('used_at'):
            try: used_at_time_str = datetime.fromisoformat(key_details['used_at']).strftime('%Y-%m-%d %H:%M UTC')
            except (ValueError, TypeError): log_error_simplified(f"Parse used_at err for key {key_string_to_redeem}")
        msg_text = f"⚠️ You already redeemed this on {used_at_time_str}." if str(key_details.get('used_by')) == str(user_id_val) else f"❌ Key used by someone else on {used_at_time_str}."
        await send_or_edit_message(upd, ctx, msg_text); return

    dur_map = {'1m': 1, '1h': 60, '1d': 1440, '7d': 10080, '30d': 43200, 'lifetime': 52560000}
    key_dur_str = key_details['duration']; delta = None
    if key_dur_str.endswith('d') and key_dur_str[:-1].isdigit(): delta = timedelta(days=int(key_dur_str[:-1]))
    elif key_dur_str in dur_map: delta = timedelta(minutes=dur_map[key_dur_str])
    if not delta: await send_or_edit_message(upd, ctx, "❌ Invalid key duration. Contact admin."); return

    expiry = datetime.now() + delta
    app_keys_data["user_access"][str(user_id_val)] = {'expiry': expiry.isoformat(), 'key': key_string_to_redeem, 'redeemed_at': datetime.now().isoformat()}
    app_keys_data["keys"][key_string_to_redeem].update({'used': True, 'used_by': user_id_val, 'used_at': datetime.now().isoformat()})
    save_app_keys_data(); log_user_activity(f"{user_id_val} redeemed key {key_string_to_redeem}")
    await send_or_edit_message(upd, ctx, f"✅ Key redeemed! Access until {expiry.strftime('%Y-%m-%d %H:%M UTC')}")

async def handle_generate_accounts_command(upd: Update, ctx: ContextTypes.DEFAULT_TYPE): # Generate
    uid = upd.effective_user.id; chat_id = upd.effective_chat.id if upd.effective_chat else 0
    if ctx.chat_data: ctx.chat_data.pop(f"last_bot_message_id_{chat_id}", None)
    if not verify_user_access(uid): await send_or_edit_message(upd, ctx, "🚫 No access. /redeem"); return
    domains = list_available_domains()
    if not domains: await send_or_edit_message(upd, ctx, "⚠️ No domains."); return
    kb = []; row = []
    for d in domains:
        row.append(InlineKeyboardButton(d[:30], callback_data=f"gen_{d[:30]}"))
        if len(row) == 2: kb.append(row); row = []
    if row: kb.append(row)
    if not kb: await send_or_edit_message(upd, ctx, "⚠️ No domain list."); return
    await send_or_edit_message(upd, ctx, "📁 Select domain:", reply_markup=InlineKeyboardMarkup(kb))

async def handle_my_access_command(upd: Update, ctx: ContextTypes.DEFAULT_TYPE): # MyAccess
    uid = upd.effective_user.id; chat_id = upd.effective_chat.id if upd.effective_chat else 0
    if ctx.chat_data: ctx.chat_data.pop(f"last_bot_message_id_{chat_id}", None)
    if check_if_owner(uid): await send_or_edit_message(upd, ctx, "🔑 Owner: Permanent access."); return
    access = app_keys_data["user_access"].get(str(uid))
    if access and verify_user_access(uid):
        expiry = "Invalid";
        try: expiry = datetime.fromisoformat(access['expiry']).strftime('%Y-%m-%d %H:%M UTC')
        except (ValueError, TypeError): log_error_simplified(f"Parse expiry error for user {uid}")
        await send_or_edit_message(upd, ctx, f"🔑 Active.\nExpires: {expiry}\nKey: <code>{access.get('key','N/A')}</code>", parse_mode=ParseMode.HTML)
    else: await send_or_edit_message(upd, ctx, "🚫 No access. /redeem")

async def handle_my_referral_command(upd: Update, ctx: ContextTypes.DEFAULT_TYPE): # MyReferral
    uid_str = str(upd.effective_user.id); pts = app_referral_data["user_points"].get(uid_str, 0)
    bot_uname = (await ctx.bot.get_me()).username; link = f"https://t.me/{bot_uname}?start=ref_{uid_str}"
    chat_id = upd.effective_chat.id if upd.effective_chat else 0
    if ctx.chat_data: ctx.chat_data.pop(f"last_bot_message_id_{chat_id}", None)
    await send_or_edit_message(upd, ctx, f"🏆 Points: {pts}\n🔗 Link: {link}\n\nShare (max {app_config['max_referral_points']}).\n/usepoints: {app_config['points_per_redeem']}pts for {app_config['accounts_per_redeem']} accs.")

async def handle_use_points_command(upd: Update, ctx: ContextTypes.DEFAULT_TYPE): # UsePoints
    uid_str = str(upd.effective_user.id); pts = app_referral_data["user_points"].get(uid_str, 0)
    chat_id = upd.effective_chat.id if upd.effective_chat else 0
    if ctx.chat_data: ctx.chat_data.pop(f"last_bot_message_id_{chat_id}", None)
    if pts < app_config['points_per_redeem']: await send_or_edit_message(upd, ctx, f"☹️ Need {app_config['points_per_redeem']} pts, have {pts}."); return
    domains = list_available_domains()
    if not domains: await send_or_edit_message(upd, ctx, "⚠️ No domains for redeem."); return
    kb = []; row = []
    for d in domains:
        row.append(InlineKeyboardButton(d[:20], callback_data=f"usepoints_{d[:20]}"))
        if len(row) == 2: kb.append(row); row = []
    if row: kb.append(row)
    await send_or_edit_message(upd, ctx, f"Have {pts} pts. Select domain for {app_config['accounts_per_redeem']} accs ({app_config['points_per_redeem']} pts):", reply_markup=InlineKeyboardMarkup(kb))

async def handle_user_info_command(upd: Update, ctx: ContextTypes.DEFAULT_TYPE): # UserInfo
    target_user_id = None; requesting_user_id = upd.effective_user.id
    chat_id = upd.effective_chat.id if upd.effective_chat else 0
    if ctx.chat_data: ctx.chat_data.pop(f"last_bot_message_id_{chat_id}", None)

    if ctx.args and ctx.args[0].isdigit():
        if not check_if_owner(requesting_user_id): await send_or_edit_message(upd, ctx, "🚫 Owner only for others."); return
        target_user_id = int(ctx.args[0]); log_owner_activity(f"{requesting_user_id} requests info for {target_user_id}")
    else: target_user_id = requesting_user_id; log_user_activity(f"{target_user_id} requests own info.")

    parts = [f"👤 <b>ID:</b> <code>{target_user_id}</code>"]
    if check_if_owner(target_user_id): parts.append("👑 Role: Owner")
    else:
        access = app_keys_data["user_access"].get(str(target_user_id))
        if access and verify_user_access(target_user_id):
            expiry = "Invalid date"
            try: expiry = datetime.fromisoformat(access['expiry']).strftime('%Y-%m-%d %H:%M UTC')
            except (ValueError, TypeError): log_error_simplified(f"Parse expiry error for user {target_user_id} in userinfo: {access.get('expiry')}")
            parts.extend([f"🔑 Access: Active until {expiry}", f"🏷️ Key: <code>{access.get('key','N/A')}</code>"])
        else: parts.append("🚫 Access: None/Expired")
    parts.append(f"🏆 Points: {app_referral_data['user_points'].get(str(target_user_id), 0)}")
    if ref_by := app_referral_data["referred_users"].get(str(target_user_id)): parts.append(f"🤝 Referred By: <code>{ref_by}</code>")
    try:
        user_chat = await ctx.bot.get_chat(target_user_id)
        if user_chat.username: parts.append(f"📛 Username: @{user_chat.username}")
        if user_chat.first_name: parts.append(f"📋 Name: {user_chat.first_name}{(' ' + user_chat.last_name) if user_chat.last_name else ''}")
    except Exception as e: log_error_simplified(f"Chat details err {target_user_id}: {e}"); parts.append("📛 Name: N/A")
    await send_or_edit_message(upd, ctx, "\n".join(parts), parse_mode=ParseMode.HTML)

async def handle_button_callback(upd: Update, ctx: ContextTypes.DEFAULT_TYPE): # Buttons
    query = upd.callback_query; await query.answer()
    uid = query.from_user.id; uid_str = str(uid); data = query.data
    msg_to_edit = query.message

    try:
        if data.startswith("gen_"):
            if not verify_user_access(uid): await query.edit_message_text("🚫 Access expired. /redeem"); return
            domain = data[4:]; log_user_activity(f"{uid} generating for domain: {domain}")
            try: await msg_to_edit.edit_text(f"⏳ Processing '<code>{domain}</code>'...", parse_mode=ParseMode.HTML)
            except BadRequest: msg_to_edit = await ctx.bot.send_message(query.message.chat_id, f"⏳ Processing '<code>{domain}</code>'...", parse_mode=ParseMode.HTML)

            accs, _ = await retrieve_accounts_from_domain_async(domain, count=app_config['default_generate_count'])
            if not accs: await msg_to_edit.edit_text(f"⚠️ No new accounts for <b>{domain}</b>.", parse_mode=ParseMode.HTML); return

            num_sent = len(accs); content = "\n".join(accs)
            fname = f"{domain}_{num_sent}accs_gen_{query.from_user.username or uid_str}_{datetime.now().strftime('%Y%m%d%H%M%S')}.txt"
            fpath = os.path.join(generated_files_dir_path, fname)
            try:
                with open(fpath, "w", encoding="utf-8") as f: f.write(content + "\n"); logger.debug(f"Saved gen file: {fpath}")
                await ctx.bot.send_document(query.message.chat_id, InputFile(open(fpath, 'rb'), filename=fname), caption=f"✅ {num_sent} accs from {domain}.\n\n✨ Originated by @xilodas ")
                await msg_to_edit.edit_text(f"✅ File for <b>{domain}</b> sent!", parse_mode=ParseMode.HTML)
            except Exception as e: log_error_simplified(f"Err sending gen file: {e}"); await msg_to_edit.edit_text(f"❌ Error for {domain}.", parse_mode=ParseMode.HTML)

        elif data.startswith("usepoints_"):
            domain = data[len("usepoints_"):]; pts = app_referral_data["user_points"].get(uid_str, 0)
            if pts < app_config['points_per_redeem']: await query.edit_message_text(f"☹️ Need {app_config['points_per_redeem']} pts, have {pts}."); return
            log_user_activity(f"{uid} using points for domain: {domain}")
            try: await msg_to_edit.edit_text(f"⏳ Processing '<code>{domain}</code>' for points...", parse_mode=ParseMode.HTML)
            except BadRequest: msg_to_edit = await ctx.bot.send_message(query.message.chat_id, f"⏳ Processing '<code>{domain}</code>' for points...", parse_mode=ParseMode.HTML)

            accs, _ = await retrieve_accounts_from_domain_async(domain, count=app_config['accounts_per_redeem'])
            if not accs: await msg_to_edit.edit_text(f"⚠️ No new accounts for <b>{domain}</b>.", parse_mode=ParseMode.HTML); return

            num_sent = len(accs); content = "\n".join(accs)
            fname = f"{domain}_{num_sent}accs_pts_{query.from_user.username or uid_str}_{datetime.now().strftime('%Y%m%d%H%M%S')}.txt"
            fpath = os.path.join(generated_files_dir_path, fname)
            try:
                with open(fpath, "w", encoding="utf-8") as f: f.write(content + "\n"); logger.debug(f"Saved pts file: {fpath}")
                await ctx.bot.send_document(query.message.chat_id, InputFile(open(fpath, 'rb'), filename=fname), caption=f"{num_sent} accs from {domain}.")
                app_referral_data["user_points"][uid_str] = pts - app_config['points_per_redeem']; save_app_referral_data()
                await msg_to_edit.edit_text(f"✅ File sent! Points left: {pts - app_config['points_per_redeem']}.", parse_mode=ParseMode.HTML)
            except Exception as e: log_error_simplified(f"Err sending pts file: {e}"); await msg_to_edit.edit_text(f"❌ Error for {domain}.", parse_mode=ParseMode.HTML)
    except Exception as e:
        log_error_simplified(f"Err in button_callback: {e}", exc_info=True)
        try:
            err_txt = "Unexpected error. Try again."
            target = msg_to_edit or query.message
            if target: await target.edit_text(err_txt)
        except: pass

async def configure_bot_commands(app_obj: Application): # Commands
    gen_cmds = [BotCommand(c, d) for c,d in [("start","Menu"),("generate","Generate"),("redeem","Redeem Key"),("myaccess","Access Info"),("myreferral","Referral"),("usepoints","Use Points"), ("userinfo", "View your user info")]]
    owner_cmd_list = [BotCommand("generatekey","Generate Keys (Owner/Conversational)"), BotCommand("userinfo", "View user info (Owner: /userinfo <id>)")]
    try: await app_obj.bot.set_my_commands(gen_cmds, scope=BotCommandScopeAllPrivateChats()); log_bot_update("General cmds set.")
    except Exception as e: log_error_simplified(f"Set general cmds err: {e}")
    owner_id = app_config.get("owner_id")
    if owner_id:
        try: await app_obj.bot.set_my_commands(gen_cmds + owner_cmd_list, scope=BotCommandScopeChat(chat_id=owner_id)); log_bot_update(f"Owner cmds set for {owner_id}")
        except Exception as e: log_error_simplified(f"Set owner cmds err {owner_id}: {e}")
    else: log_bot_update("Owner ID not set, owner cmds not scoped.")

def main_program_loop(): # Main
    global bot_start_timestamp; bot_start_timestamp = datetime.now()
    print("Initializing...")
    load_app_config(); ensure_data_folders_exist(); initialize_all_data()

    if 'bot_token' not in app_config or 'owner_id' not in app_config or app_config['bot_token'] == "YOUR_BOT_TOKEN_HERE" or app_config['owner_id'] == 0:
        log_error_simplified(f"Config critical error: 'bot_token' or 'owner_id' not properly set. Exiting."); exit(1)

    app = Application.builder().token(app_config['bot_token']).connect_timeout(30).read_timeout(30).build()
    app.job_queue.run_once(lambda ctx: perform_initial_integrity_check(), when=1)
    app.job_queue.run_once(lambda ctx: configure_bot_commands(app), when=2)

    genkey_conv_handler = ConversationHandler(
        entry_points=[CommandHandler("generatekey", prompt_genkey_duration, filters=filters.User(user_id=app_config['owner_id']))],
        states={
            STATE_AWAITING_GENKEY_DURATION: [MessageHandler(filters.TEXT & ~filters.COMMAND, received_genkey_duration)],
            STATE_AWAITING_GENKEY_AMOUNT: [MessageHandler(filters.TEXT & ~filters.COMMAND, received_genkey_amount)],
        },
        fallbacks=[CommandHandler("cancel", cancel_genkey_conversation)],
        block=False
    )
    app.add_handler(genkey_conv_handler)

    cmd_handlers = {"start":handle_start_command, "redeem":handle_redeem_key_command, "generate":handle_generate_accounts_command,
                    "myaccess":handle_my_access_command, "myreferral":handle_my_referral_command, "usepoints":handle_use_points_command,
                    "userinfo": handle_user_info_command}
    for cmd, hdlr in cmd_handlers.items(): app.add_handler(CommandHandler(cmd, hdlr, block=False))

    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, process_potential_key_message, block=False))
    app.add_handler(CallbackQueryHandler(handle_button_callback, block=False))

    print(colored_ascii_art_banner_console)
    log_bot_update(f"--- Bot RUNNING (Owner: {app_config.get('owner_id')}) ---\nOriginated by @xilodas ")
    try: app.run_polling(allowed_updates=Update.ALL_TYPES, stop_signals=None)
    except Exception as e: log_error_simplified(f"Polling error: {e}", exc_info=True)
    finally:
        log_bot_update("--- BOT STOPPING ---"); file_op_executor.shutdown(wait=True); log_bot_update("Executor down."); log_bot_update("--- BOT STOPPED ---")

if __name__ == '__main__':
    try: main_program_loop()
    except KeyboardInterrupt: log_bot_update("Shutdown via KeyboardInterrupt.")
    except Exception as e: log_error_simplified(f"Main execution error: {e}", exc_info=True)
    finally:
        if 'file_op_executor' in globals() and hasattr(file_op_executor, '_shutdown') and not file_op_executor._shutdown:
            try: log_bot_update("Final executor shutdown attempt..."); file_op_executor.shutdown(wait=False)
            except: pass
        log_bot_update("Exit.")