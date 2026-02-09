-- Создаем основной интерфейс
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DraconicHubGui"
screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

-- Главный контейнер (Красное окно) с ЧЕРНОЙ ЖИРНОЙ ОБВОДКОЙ
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 700, 0, 350)
mainFrame.Position = UDim2.new(0.5, -350, 0.5, -170)
mainFrame.BackgroundColor3 = Color3.fromRGB(220, 20, 20)
mainFrame.BackgroundTransparency = 0.3
mainFrame.BorderSizePixel = 5
mainFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.Active = true
mainFrame.Selectable = true
mainFrame.Parent = screenGui

-- Скругление углов для главного окна
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 15)
uiCorner.Parent = mainFrame

-- Контейнер для анимированного лого
local logoContainer = Instance.new("Frame")
logoContainer.Name = "LogoContainer"
logoContainer.Size = UDim2.new(0, 180, 0, 180)
logoContainer.Position = UDim2.new(0.5, -90, 0, -100)
logoContainer.BackgroundTransparency = 1
logoContainer.Parent = mainFrame

-- Вращающийся фон
local spinningBackground = Instance.new("ImageLabel")
spinningBackground.Name = "SpinningBackground"
spinningBackground.Size = UDim2.new(1.5, 0, 1.5, 0)
spinningBackground.AnchorPoint = Vector2.new(0.5, 0.5)
spinningBackground.Position = UDim2.new(0.5, 0, 0.5, 0)
spinningBackground.BackgroundTransparency = 1
spinningBackground.Image = "rbxassetid://72879616626375"
spinningBackground.ImageTransparency = 0.3
spinningBackground.ZIndex = 1
spinningBackground.Parent = logoContainer

-- Основное лого
local mainLogo = Instance.new("ImageLabel")
mainLogo.Name = "MainLogo"
mainLogo.Size = UDim2.new(0.8, 0, 0.8, 0)
mainLogo.AnchorPoint = Vector2.new(0.5, 0.5)
mainLogo.Position = UDim2.new(0.5, 0, 0.5, 0)
mainLogo.BackgroundTransparency = 1
mainLogo.Image = "rbxassetid://102225156206159"
mainLogo.ZIndex = 2
mainLogo.Parent = logoContainer

-- Скругление для основного лого
local logoCorner = Instance.new("UICorner")
logoCorner.CornerRadius = UDim.new(0.2, 0)
logoCorner.Parent = mainLogo

-- Заголовок
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 660, 0, 50)
titleLabel.Position = UDim2.new(0.5, -325, 0, 90)
titleLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Text = "Draconic Hub X Key System"
titleLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 40
titleLabel.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 20)
titleCorner.Parent = titleLabel

-- Поле ввода ключа
local keyInput = Instance.new("TextBox")
keyInput.Size = UDim2.new(0, 660, 0, 50)
keyInput.Position = UDim2.new(0.5, -325, 0, 155)
keyInput.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
keyInput.PlaceholderText = "Enter Key Here"
keyInput.Text = ""
keyInput.TextColor3 = Color3.fromRGB(0, 0, 0)
keyInput.Font = Enum.Font.SourceSans
keyInput.TextSize = 35
keyInput.Parent = mainFrame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 20)
inputCorner.Parent = keyInput

-- Контейнер выбора платформы (после поля ввода ключа, перед кнопками)
local platformContainer = Instance.new("Frame")
platformContainer.Name = "PlatformContainer"
platformContainer.Size = UDim2.new(0, 660, 0, 50)
platformContainer.Position = UDim2.new(0.5, -325, 0, 215)
platformContainer.BackgroundTransparency = 1
platformContainer.Parent = mainFrame

-- Текст выбора платформы
local platformLabel = Instance.new("TextLabel")
platformLabel.Name = "PlatformLabel"
platformLabel.Size = UDim2.new(0, 150, 1, 0)
platformLabel.Position = UDim2.new(0, 0, 0, 0)
platformLabel.BackgroundTransparency = 1
platformLabel.Text = "Platform:"
platformLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
platformLabel.Font = Enum.Font.SourceSansBold
platformLabel.TextSize = 28
platformLabel.TextXAlignment = Enum.TextXAlignment.Left
platformLabel.Parent = platformContainer

-- Кнопка Mobile (выбрана по умолчанию)
local mobileBtn = Instance.new("TextButton")
mobileBtn.Name = "MobileButton"
mobileBtn.Size = UDim2.new(0, 120, 0, 40)
mobileBtn.Position = UDim2.new(0, 160, 0.5, -20)
mobileBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255) -- Синий для выбранного
mobileBtn.Text = "📱Mobile/PC"
mobileBtn.Font = Enum.Font.SourceSansBold
mobileBtn.TextSize = 24
mobileBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
mobileBtn.Parent = platformContainer

local mobileCorner = Instance.new("UICorner")
mobileCorner.CornerRadius = UDim.new(0, 10)
mobileCorner.Parent = mobileBtn

-- Кнопка PC
local pcBtn = Instance.new("TextButton")
pcBtn.Name = "PCButton"
pcBtn.Size = UDim2.new(0, 120, 0, 40)
pcBtn.Position = UDim2.new(0, 300, 0.5, -20)
pcBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100) -- Серый для невыбранного
pcBtn.Text = "🖥️ PC (Xeno)"
pcBtn.Font = Enum.Font.SourceSansBold
pcBtn.TextSize = 24
pcBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
pcBtn.Parent = platformContainer

local pcCorner = Instance.new("UICorner")
pcCorner.CornerRadius = UDim.new(0, 10)
pcCorner.Parent = pcBtn

-- Переменная для хранения выбранной платформы (по умолчанию Mobile)
local selectedPlatform = "Mobile"

-- Функция обновления выбора платформы
local function updatePlatformSelection(platform)
    selectedPlatform = platform
    
    if platform == "Mobile" then
        mobileBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        mobileBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        pcBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        pcBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    else
        mobileBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        mobileBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        pcBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        pcBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
    
    showMessage("Selected: " .. platform, Color3.fromRGB(0, 200, 255))
end

-- Обработчики кликов для кнопок платформы
mobileBtn.MouseButton1Click:Connect(function()
    updatePlatformSelection("Mobile")
end)

pcBtn.MouseButton1Click:Connect(function()
    updatePlatformSelection("PC")
end)

-- Анимация наведения для кнопок платформы
local function setupPlatformButtonHover(button)
    button.MouseEnter:Connect(function()
        if not (button == mobileBtn and selectedPlatform == "Mobile") and 
           not (button == pcBtn and selectedPlatform == "PC") then
            button.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end)
    
    button.MouseLeave:Connect(function()
        if button == mobileBtn then
            if selectedPlatform == "Mobile" then
                button.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
                button.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                button.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
                button.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
        else -- pcBtn
            if selectedPlatform == "PC" then
                button.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
                button.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                button.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
                button.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
        end
    end)
end

setupPlatformButtonHover(mobileBtn)
setupPlatformButtonHover(pcBtn)

-- Кнопка Submit
local submitBtn = Instance.new("TextButton")
submitBtn.Name = "SubmitButton"
submitBtn.Size = UDim2.new(0, 260, 0, 60)
submitBtn.Position = UDim2.new(0, 25, 0, 280)
submitBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
submitBtn.Text = "Submit"
submitBtn.Font = Enum.Font.SourceSansBold
submitBtn.TextSize = 35
submitBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
submitBtn.Parent = mainFrame

local submitCorner = Instance.new("UICorner")
submitCorner.CornerRadius = UDim.new(0, 20)
submitCorner.Parent = submitBtn

-- Кнопка Get Key
local getKeyBtn = Instance.new("TextButton")
getKeyBtn.Name = "GetKeyButton"
getKeyBtn.Size = UDim2.new(0, 260, 0, 60)
getKeyBtn.Position = UDim2.new(0, 420, 0, 280)
getKeyBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
getKeyBtn.Text = "Get Key"
getKeyBtn.Font = Enum.Font.SourceSansBold
getKeyBtn.TextSize = 35
getKeyBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
getKeyBtn.Parent = mainFrame

local getKeyCorner = Instance.new("UICorner")
getKeyCorner.CornerRadius = UDim.new(0, 20)
getKeyCorner.Parent = getKeyBtn

-- Создаем сообщение об ошибке
local errorLabel = Instance.new("TextLabel")
errorLabel.Size = UDim2.new(0, 660, 0, 40)
errorLabel.Position = UDim2.new(0.5, -325, 0, 360)
errorLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
errorLabel.BackgroundTransparency = 0.5
errorLabel.Text = ""
errorLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
errorLabel.Font = Enum.Font.SourceSansBold
errorLabel.TextSize = 25
errorLabel.Visible = false
errorLabel.Parent = mainFrame

local errorCorner = Instance.new("UICorner")
errorCorner.CornerRadius = UDim.new(0, 10)
errorCorner.Parent = errorLabel

--- АНИМАЦИЯ ВРАЩЕНИЯ ЛОГО ---
local rotationSpeed = 0.5
local currentRotation = 0

local function animateLogo()
    while true do
        task.wait()
        currentRotation = (currentRotation + rotationSpeed) % 360
        spinningBackground.Rotation = currentRotation
    end
end

task.spawn(animateLogo)

--- Platoboost Key System Configuration ---
local service = 16094
local secret = "9bfce86e-a6fc-4baf-93d8-4d77a2254e41"
local useNonce = false

-- Режим тестирования (для быстрой проверки FREE ключей)
local TEST_MODE = true
local TEST_KEYS = {
    ["FREE_NEWYEAR"] = true,
    ["FREE_TEST"] = true,
    ["FREE_ACCESS"] = true
}

-- Утилиты
local HttpService = game:GetService("HttpService")

--! Вспомогательные функции Platoboost
local fSetClipboard = setclipboard or toclipboard or writeclipboard or (syn and syn.write_clipboard)
local fRequest = request or http_request or (syn and syn.request) or (http and http.request)
local fStringChar = string.char
local fToString = tostring
local fStringSub = string.sub
local fOsTime = os.time
local fMathRandom = math.random
local fMathFloor = math.floor
local fGetHwid = gethwid or function() 
    return tostring(game:GetService("Players").LocalPlayer.UserId)
end

-- JSON функции для Platoboost
local function lEncode(data)
    return HttpService:JSONEncode(data)
end

local function lDecode(data)
    local success, result = pcall(function()
        return HttpService:JSONDecode(data)
    end)
    return success and result or nil
end

local function lDigest(input)
    local hash = 0
    for i = 1, #input do
        hash = (hash * 31 + string.byte(input, i)) % 2^32
    end
    return tostring(hash)
end

--! Конфигурация хоста Platoboost
local host = "https://api.platoboost.com"

-- Проверяем подключение к хосту
if fRequest then
    local success, hostResponse = pcall(function()
        return fRequest({
            Url = host .. "/public/connectivity",
            Method = "GET",
            Headers = {
                ["Content-Type"] = "application/json"
            }
        })
    end)
    
    if not success or (hostResponse and (hostResponse.StatusCode ~= 200 and hostResponse.StatusCode ~= 429)) then
        host = "https://api.platoboost.net"
        print("[Platoboost] Switched to backup host:", host)
    end
end

--! Кэширование ссылки для Platoboost
local cachedLink, cachedTime = "", 0
local requestSending = false

local function cacheLink()
    if requestSending then
        return false, "A request is already being sent"
    end
    
    if cachedTime + (10 * 60) > fOsTime() and cachedLink ~= "" then
        return true, cachedLink
    end
    
    requestSending = true
    
    local hwid = fGetHwid()
    local data = {
        service = service,
        identifier = lDigest(hwid)
    }
    
    print("[Platoboost] Requesting link for HWID:", hwid)
    
    local success, response = pcall(function()
        return fRequest({
            Url = host .. "/public/start",
            Method = "POST",
            Body = lEncode(data),
            Headers = {
                ["Content-Type"] = "application/json"
            }
        })
    end)
    
    requestSending = false
    
    if not success or not response then
        print("[Platoboost] Failed to connect")
        return false, "Failed to connect to Platoboost"
    end
    
    print("[Platoboost] Response status:", response.StatusCode)
    
    if response.StatusCode == 200 then
        local decoded = lDecode(response.Body)
        
        if decoded and decoded.success == true then
            cachedLink = decoded.data.url
            cachedTime = fOsTime()
            print("[Platoboost] Link received:", cachedLink)
            return true, cachedLink
        else
            print("[Platoboost] Failed to get link:", decoded and decoded.message or "Unknown error")
            return false, decoded and decoded.message or "Failed to get link"
        end
    elseif response.StatusCode == 429 then
        print("[Platoboost] Rate limited")
        return false, "Rate limited. Please wait 20 seconds"
    else
        print("[Platoboost] Server error:", response.StatusCode)
        return false, "Server error: " .. tostring(response.StatusCode)
    end
end

--! Генерация nonce для Platoboost
local function generateNonce()
    local str = ""
    for _ = 1, 16 do
        str = str .. fStringChar(fMathFloor(fMathRandom() * (122 - 97 + 1)) + 97)
    end
    return str
end

--! Функция активации ключа (для FREE ключей)
local function redeemKey(key)
    print("[Platoboost] Redeeming key:", key)
    
    local nonce = generateNonce()
    local endpoint = host .. "/public/redeem/" .. fToString(service)
    
    local body = {
        identifier = lDigest(fGetHwid()),
        key = key
    }
    
    if useNonce then
        body.nonce = nonce
    end
    
    local response = fRequest({
        Url = endpoint,
        Method = "POST",
        Body = lEncode(body),
        Headers = {
            ["Content-Type"] = "application/json"
        }
    })
    
    if response and response.StatusCode == 200 then
        local decoded = lDecode(response.Body)
        
        if decoded and decoded.success == true then
            if decoded.data.valid == true then
                if useNonce then
                    if decoded.data.hash == lDigest("true" .. "-" .. nonce .. "-" .. secret) then
                        return true, "Key activated successfully!"
                    else
                        return false, "Failed to verify integrity"
                    end
                else
                    return true, "Key activated successfully!"
                end
            else
                return false, "Key is invalid"
            end
        else
            if decoded and string.sub(decoded.message, 1, 27) == "unique constraint violation" then
                return false, "You already have an active key, please wait for it to expire"
            else
                return false, decoded and decoded.message or "Activation failed"
            end
        end
    elseif response and response.StatusCode == 429 then
        return false, "You are being rate limited, please wait 20 seconds"
    else
        return false, "Server returned an invalid status code: " .. tostring(response and response.StatusCode or "No response")
    end
end

--! Проверка ключа через Platoboost API (с поддержкой FREE ключей)
local function verifyKey(key)
    if requestSending then
        return false, "A request is already being sent, please slow down"
    end
    
    if key == "" or key == nil then
        return false, "Please enter a key"
    end
    
    -- Очищаем ключ от пробелов
    key = string.gsub(key, "%s+", "")
    
    print("[Platoboost] Verifying key:", key)
    print("[Platoboost] Key starts with:", string.sub(key, 1, 5))
    
    -- ВРЕМЕННЫЙ РЕЖИМ ТЕСТИРОВАНИЯ (принимает FREE ключи без проверки API)
    if TEST_MODE then
        print("[TEST MODE] Checking test key")
        
        -- Проверяем в списке тестовых ключей
        if TEST_KEYS[key] then
            return true, "Test key accepted! Loading..."
        end
        
        -- Принимаем любой ключ начинающийся с FREE_ в тестовом режиме
        if string.sub(key, 1, 5):upper() == "FREE_" and string.len(key) > 10 then
            return true, "Free key accepted! Loading..."
        end
    end
    
    requestSending = true
    
    local hwid = fGetHwid()
    local nonce = useNonce and generateNonce() or ""
    
    -- Создаем endpoint для проверки ключа
    local endpoint = host .. "/public/whitelist/" .. fToString(service) .. "?identifier=" .. lDigest(hwid) .. "&key=" .. key
    
    if useNonce then
        endpoint = endpoint .. "&nonce=" .. nonce
    end
    
    print("[Platoboost] Request URL:", endpoint)
    
    local success, response = pcall(function()
        return fRequest({
            Url = endpoint,
            Method = "GET",
            Headers = {
                ["Content-Type"] = "application/json"
            }
        })
    end)
    
    requestSending = false
    
    if not success or not response then
        print("[Platoboost] Connection failed")
        return false, "Failed to connect to verification server"
    end
    
    print("[Platoboost] Response status:", response.StatusCode)
    
    if response.StatusCode == 200 then
        local decoded = lDecode(response.Body)
        
        if decoded then
            print("[Platoboost] Response success:", decoded.success)
            
            if decoded.success == true then
                if decoded.data.valid == true then
                    if useNonce then
                        if decoded.data.hash == lDigest("true" .. "-" .. nonce .. "-" .. secret) then
                            return true, "Key verified successfully!"
                        else
                            return false, "Security verification failed"
                        end
                    else
                        return true, "Key verified successfully!"
                    end
                else
                    -- Ключ не валиден в whitelist
                    print("[Platoboost] Key not in whitelist")
                    
                    -- Пробуем активировать ключ через redeem (особенно для FREE ключей)
                    local redeemSuccess, redeemMessage = redeemKey(key)
                    
                    if redeemSuccess then
                        return true, redeemMessage
                    else
                        return false, redeemMessage or "Key is invalid or expired"
                    end
                end
            else
                return false, decoded.message or "Verification failed"
            end
        else
            return false, "Invalid server response"
        end
    elseif response.StatusCode == 429 then
        return false, "Rate limited. Please wait 20 seconds"
    else
        print("[Platoboost] Server error:", response.StatusCode)
        return false, "Server error: " .. tostring(response.StatusCode)
    end
end

-- Функция для показа сообщения
local function showMessage(text, color)
    errorLabel.Text = text
    errorLabel.TextColor3 = color
    errorLabel.Visible = true
    
    task.spawn(function()
        task.wait(3)
        errorLabel.Visible = false
    end)
end

-- Функция для запуска скрипта
local function executeScript()
    rotationSpeed = 0
    screenGui.Enabled = false
    
    -- Показываем сообщение о загрузке
    showMessage("Loading Draconic Hub (" .. selectedPlatform .. ")...", Color3.fromRGB(0, 255, 0))
    
    local success, errorMsg = pcall(function()
        -- Загружаем скрипт хаба в зависимости от выбранной платформы
        if selectedPlatform == "Mobile" then
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Lapwpkddm/Hacks/refs/heads/main/Online%20Script/ScriptMobile.lua"))()
        else -- PC
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Lapwpkddm/Hacks/refs/heads/main/Online%20Script/ScriptPC.lua"))()
        end
    end)
    
    if not success then
        screenGui.Enabled = true
        rotationSpeed = 0.5
        showMessage("Script error: " .. tostring(errorMsg), Color3.fromRGB(255, 50, 50))
        
        -- Сбрасываем кнопку Submit
        submitBtn.Text = "Submit"
        submitBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        submitBtn.TextSize = 35
        submitBtn.AutoButtonColor = true
    end
end

--- НАСТРОЙКА КНОПОК ---

-- Кнопка Submit (Проверка ключа)
submitBtn.MouseButton1Click:Connect(function()
    print("[Submit] Button clicked")
    
    local enteredKey = keyInput.Text
    
    if enteredKey == "" then
        showMessage("Please enter a key!", Color3.fromRGB(255, 255, 0))
        return
    end
    
    -- Блокируем кнопку на время проверки
    submitBtn.Text = "Checking..."
    submitBtn.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    submitBtn.TextSize = 30
    submitBtn.AutoButtonColor = false
    
    task.spawn(function()
        task.wait(0.5) -- Имитация задержки сети
        
        local success, message = verifyKey(enteredKey)
        
        if success then
            showMessage(message, Color3.fromRGB(50, 255, 50))
            rotationSpeed = 3
            
            -- Анимация успеха
            for i = 1, 10 do
                submitBtn.BackgroundColor3 = Color3.fromRGB(50, 255 - i*10, 50)
                task.wait(0.05)
            end
            
            task.wait(1)
            executeScript()
        else
            showMessage("Error: " .. message, Color3.fromRGB(255, 50, 50))
            
            -- Сбрасываем кнопку
            submitBtn.Text = "Submit"
            submitBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            submitBtn.TextSize = 35
            submitBtn.AutoButtonColor = true
            rotationSpeed = 0.5
            
            -- Эффект тряски при ошибке
            local originalPos = keyInput.Position
            for i = 1, 5 do
                keyInput.Position = UDim2.new(0.5, -325 + math.random(-5, 5), 0, 155 + math.random(-2, 2))
                task.wait(0.05)
            end
            keyInput.Position = originalPos
            
            -- Подсвечиваем поле красным
            keyInput.BackgroundColor3 = Color3.fromRGB(255, 150, 150)
            task.wait(0.5)
            keyInput.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        end
    end)
end)

-- Кнопка Get Key (Получение ссылки)
getKeyBtn.MouseButton1Click:Connect(function()
    print("[Get Key] Button clicked")
    
    -- Блокируем кнопку на время запроса
    getKeyBtn.Text = "Getting Link..."
    getKeyBtn.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    getKeyBtn.TextSize = 30
    getKeyBtn.AutoButtonColor = false
    rotationSpeed = 2
    
    task.spawn(function()
        task.wait(0.5) -- Имитация задержки сети
        
        local success, link = cacheLink()
        
        if success then
            -- Копируем ссылку в буфер обмена
            if fSetClipboard then
                local copySuccess = pcall(function()
                    fSetClipboard(link)
                end)
                
                if copySuccess then
                    showMessage("Link copied to clipboard!", Color3.fromRGB(50, 150, 255))
                    
                    -- Показываем уведомление
                    pcall(function()
                        game:GetService("StarterGui"):SetCore("SendNotification", {
                            Title = "Draconic Hub",
                            Text = "Link copied! Open in browser",
                            Duration = 5
                        })
                    end)
                else
                    showMessage("Link: " .. link, Color3.fromRGB(50, 150, 255))
                end
            else
                showMessage("Link: " .. link, Color3.fromRGB(50, 150, 255))
            end
        else
            showMessage("Error: " .. link, Color3.fromRGB(255, 50, 50))
        end
        
        -- Сбрасываем кнопку
        getKeyBtn.Text = "Get Key"
        getKeyBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        getKeyBtn.TextSize = 35
        getKeyBtn.AutoButtonColor = true
        rotationSpeed = 0.5
    end)
end)

-- Анимация наведения на кнопки
local function setupButtonHover(button)
    local originalColor = button.BackgroundColor3
    
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(200, 200, 255)
        rotationSpeed = 1.5
    end)
    
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = originalColor
        rotationSpeed = 0.5
    end)
end

setupButtonHover(submitBtn)
setupButtonHover(getKeyBtn)

-- Эффект при наведении на лого
logoContainer.MouseEnter:Connect(function()
    rotationSpeed = 2
    mainLogo.ImageTransparency = 0.2
end)

logoContainer.MouseLeave:Connect(function()
    rotationSpeed = 0.5
    mainLogo.ImageTransparency = 0
end)

-- Код перетаскивания окна
local dragging, dragInput, dragStart, startPos

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Закрытие на ESC
local userInputService = game:GetService("UserInputService")
local guiVisible = true

userInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Escape then
        guiVisible = not guiVisible
        screenGui.Enabled = guiVisible
    end
end)

-- Информационное сообщение
task.spawn(function()
    task.wait(1)
    if TEST_MODE then
        showMessage("TEST MODE: FREE keys accepted", Color3.fromRGB(255, 255, 0))
    else
        showMessage("Click 'Get Key' to get access link", Color3.fromRGB(255, 255, 255))
    end
end)

-- Обработка нажатия Enter в поле ввода
keyInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        submitBtn.MouseButton1Click:Fire()
    end
end)

-- Автоматическая вставка тестового ключа в режиме тестирования
if TEST_MODE then
    task.spawn(function()
        task.wait(1)
        keyInput.Text = "FREE_NEWYEAR"
        showMessage("Test key inserted automatically", Color3.fromRGB(0, 255, 0))
    end)
end

-- Предзагрузка ссылки при запуске
task.spawn(function()
    task.wait(2)
    print("[Platoboost] Preloading link...")
    local success, link = cacheLink()
    if success then
        print("[Platoboost] Link preloaded:", link)
    else
        print("[Platoboost] Preload failed:", link)
    end
end)

-- Вывод информации о системе
print("=======================================")
print("DRACONIC HUB X - KEY SYSTEM")
print("=======================================")
print("Service ID:", service)
print("Host:", host)
print("Test Mode:", TEST_MODE)
print("=======================================")
print("Key 'FREE_ce9cee7b67c4b257da6907af2924dcd2' is accepted")
print("=======================================")
