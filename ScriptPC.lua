game:GetService("Players").LocalPlayer.PlayerGui.DraconicHubGui:Destroy()
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "🔥Draconic Hub X🔥",
    Text = "Welcome Draconic Hub Remake",
    Duration = 7
})
local Fluent = https://raw.githubusercontent.com/xilodasss/xilodas/refs/heads/main/Esp.lua(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = https://raw.githubusercontent.com/xilodasss/xilodas/refs/heads/main/Esp.lua(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = https://raw.githubusercontent.com/xilodasss/xilodas/refs/heads/main/Esp.lua(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
local Window = Fluent:CreateWindow({
    Title = "🔥| Draconic-X-Remake",
    SubTitle = "Overhaul (2.0 PC Version) Made by Unknownproooolucky",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local FloatingButton = https://raw.githubusercontent.com/xilodasss/xilodas/refs/heads/main/Esp.lua(game:HttpGet("https://raw.githubusercontent.com/xilodasss/xilodas/refs/heads/main/FlyBytton.lua",true))()
FloatingButton.init(Window)

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" })
}

local Options = Fluent.Options

Fluent:Notify({
    Title = "🔥Draconic X Evade🔥",
    Content = "System Loaded",
    Duration = 3
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- Billboard ESP Variables
local NextbotBillboards = {}
local nextbotLoop = nil
-- local PlayerBillboards = {} <-- УДАЛЕНО
local TicketBillboards = {}

-- ДОБАВИТЬ ЭТИ СТРОКИ ГДЕ-ТО ПОСЛЕ ТАКИХ ПЕРЕМЕННЫХ:
local ExternalESP = nil
local ExternalESPLoaded = false
local ExternalNextbotESP = nil
local ExternalNextbotESPLoaded = false

-- Tracer ESP Variables
local playerTracerElements = {}
local botTracerElements = {}
local playerTracerConnection = nil
local botTracerConnection = nil

-- Auto Respawn Variables
local lastSavedPosition = nil
local respawnConnection = nil
local AutoSelfReviveConnection = nil
local hasRevived = false
local SelfReviveMethod = "Spawnpoint"

-- New Feature Variables
local AntiAFKConnection = nil
local autoWhistleHandle = nil
local stableCameraInstance = nil

-- Get nextbot names from ReplicatedStorage
local nextBotNames = {}
if ReplicatedStorage:FindFirstChild("NPCs") then
    for _, npc in ipairs(ReplicatedStorage.NPCs:GetChildren()) do
        table.insert(nextBotNames, npc.Name)
    end
end

function isNextbotModel(model)
    if not model or not model.Name then return false end
    for _, name in ipairs(nextBotNames) do
        if model.Name == name then return true end
    end
    return model.Name:lower():find("nextbot") or 
           model.Name:lower():find("scp") or 
           model.Name:lower():find("monster") or
           model.Name:lower():find("creep") or
           model.Name:lower():find("enemy") or
           model.Name:lower():find("zombie") or
           model.Name:lower():find("ghost") or
           model.Name:lower():find("demon")
end

function getDistanceFromPlayer(targetPosition)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then 
        return 0 
    end
    local distance = (targetPosition - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
    return math.floor(distance)
end



local function scanForTickets()
    -- Если включен внешний Ticket ESP, используем его
    if ExternalTicketESPLoaded and _G.UpdateTicketESP then
        pcall(_G.UpdateTicketESP)
    else
        -- Стандартная логика (резервная)
        local ticketsFound = {}
        
        local gameFolder = workspace:FindFirstChild("Game")
        if gameFolder then
            local effects = gameFolder:FindFirstChild("Effects")
            if effects then
                local tickets = effects:FindFirstChild("Tickets")
                if tickets then
                    for _, ticket in pairs(tickets:GetChildren()) do
                        if ticket:IsA("BasePart") or ticket:IsA("Model") then
                            local part = ticket:IsA("Model") and 
                                       (ticket:FindFirstChild("HumanoidRootPart") or 
                                        ticket:FindFirstChild("Head") or 
                                        ticket.PrimaryPart or 
                                        ticket:FindFirstChildWhichIsA("BasePart")) or 
                                       ticket:IsA("BasePart") and ticket
                            if part then
                                ticketsFound[ticket] = part
                            end
                        end
                    end
                end
            end
        end
        
        -- Очистка старых ESP
        for ticket, data in pairs(TicketBillboards) do
            if not ticketsFound[ticket] or not ticket.Parent then
                if data.esp then
                    data.esp:Destroy()
                end
                TicketBillboards[ticket] = nil
            end
        end
    end
end

-- ==================== TRACER ESP FUNCTIONS ====================

function createTracerObject()
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Thickness = 1
    tracer.ZIndex = 1
    return tracer
end

function updatePlayerTracers()
    local camera = workspace.CurrentCamera
    if not camera then return end
    
    local screenBottomCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
    local currentTargets = {}

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                currentTargets[player] = true
                
                if not playerTracerElements[player] then
                    playerTracerElements[player] = createTracerObject()
                end

                local tracer = playerTracerElements[player]
                local vector, onScreen = camera:WorldToViewportPoint(hrp.Position)

                if onScreen then
                    tracer.Visible = true
                    tracer.From = screenBottomCenter
                    tracer.To = Vector2.new(vector.X, vector.Y)
                    tracer.Color = Color3.fromRGB(255, 255, 255)
                else
                    tracer.Visible = false
                end
            end
        end
    end

    for player, tracer in pairs(playerTracerElements) do
        if not currentTargets[player] then
            if tracer and tracer.Remove then
                tracer:Remove()
            end
            playerTracerElements[player] = nil
        end
    end
end

function updateBotTracers()
    local camera = workspace.CurrentCamera
    if not camera then return end
    
    local screenBottomCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
    local currentTargets = {}

    local playersFolder = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
    if playersFolder then
        for _, model in pairs(playersFolder:GetChildren()) do
            if model:IsA("Model") and isNextbotModel(model) then
                local hrp = model:FindFirstChild("HumanoidRootPart")
                if hrp then
                    currentTargets[model] = true
                    
                    if not botTracerElements[model] then
                        botTracerElements[model] = createTracerObject()
                    end

                    local tracer = botTracerElements[model]
                    local vector, onScreen = camera:WorldToViewportPoint(hrp.Position)

                    if onScreen then
                        tracer.Visible = true
                        tracer.From = screenBottomCenter
                        tracer.To = Vector2.new(vector.X, vector.Y)
                        tracer.Color = Color3.fromRGB(255, 0, 0)
                    else
                        tracer.Visible = false
                    end
                end
            end
        end
    end

    local npcsFolder = workspace:FindFirstChild("NPCs")
    if npcsFolder then
        for _, model in pairs(npcsFolder:GetChildren()) do
            if model:IsA("Model") and isNextbotModel(model) then
                local hrp = model:FindFirstChild("HumanoidRootPart")
                if hrp then
                    currentTargets[model] = true
                    
                    if not botTracerElements[model] then
                        botTracerElements[model] = createTracerObject()
                    end

                    local tracer = botTracerElements[model]
                    local vector, onScreen = camera:WorldToViewportPoint(hrp.Position)

                    if onScreen then
                        tracer.Visible = true
                        tracer.From = screenBottomCenter
                        tracer.To = Vector2.new(vector.X, vector.Y)
                        tracer.Color = Color3.fromRGB(255, 0, 0)
                    else
                        tracer.Visible = false
                    end
                end
            end
        end
    end

    for model, tracer in pairs(botTracerElements) do
        if not currentTargets[model] then
            if tracer and tracer.Remove then
                tracer:Remove()
            end
            botTracerElements[model] = nil
        end
    end
end

function startPlayerTracers()
    if playerTracerConnection then return end
    playerTracerConnection = RunService.RenderStepped:Connect(updatePlayerTracers)
end

function stopPlayerTracers()
    if playerTracerConnection then
        playerTracerConnection:Disconnect()
        playerTracerConnection = nil
    end
    for player, tracer in pairs(playerTracerElements) do
        if tracer and tracer.Remove then
            tracer:Remove()
        end
    end
    playerTracerElements = {}
end

function startBotTracers()
    if botTracerConnection then return end
    botTracerConnection = RunService.RenderStepped:Connect(updateBotTracers)
end

function stopBotTracers()
    if botTracerConnection then
        botTracerConnection:Disconnect()
        botTracerConnection = nil
    end
    for model, tracer in pairs(botTracerElements) do
        if tracer and tracer.Remove then
            tracer:Remove()
        end
    end
    botTracerElements = {}
end

-- ==================== AUTO RESPAWN FUNCTIONS ====================

local function startAutoRespawn()
    if AutoSelfReviveConnection then
        AutoSelfReviveConnection:Disconnect()
    end
    if respawnConnection then
        respawnConnection:Disconnect()
    end
    
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:WaitForChild("Humanoid")
        local hrp = character:WaitForChild("HumanoidRootPart")
        
        AutoSelfReviveConnection = character:GetAttributeChangedSignal("Downed"):Connect(function()
            local isDowned = character:GetAttribute("Downed")
            if isDowned then
                if SelfReviveMethod == "Spawnpoint" then
                    if not hasRevived then
                        hasRevived = true
                        pcall(function()
                            ReplicatedStorage.Events.Player.ChangePlayerMode:FireServer(true)
                        end)
                        task.delay(10, function()
                            hasRevived = false
                        end)
                    end
                elseif SelfReviveMethod == "Fake Revive" then
                    if hrp then
                        lastSavedPosition = hrp.Position
                    end
                    task.wait(3)
                    local startTime = tick()
                    repeat
                        pcall(function()
                            ReplicatedStorage:WaitForChild("Events"):WaitForChild("Player"):WaitForChild("ChangePlayerMode"):FireServer(true)
                        end)
                    until not character:GetAttribute("Downed") or (tick() - startTime > 1)
                    local newCharacter
                    repeat
                        newCharacter = LocalPlayer.Character
                        task.wait()
                    until newCharacter and newCharacter:FindFirstChild("HumanoidRootPart")
                    local newHRP = newCharacter:FindFirstChild("HumanoidRootPart")
                    if lastSavedPosition and newHRP then
                        newHRP.CFrame = CFrame.new(lastSavedPosition)
                        task.wait(0.5)
                        local movedDistance = (newHRP.Position - lastSavedPosition).Magnitude
                        if movedDistance > 1 then
                            lastSavedPosition = nil
                        end
                    end
                end
            end
        end)
    end
    
    respawnConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
        task.wait(1)
        local newHumanoid = newChar:WaitForChild("Humanoid")
        local newHRP = newChar:WaitForChild("HumanoidRootPart")
        
        AutoSelfReviveConnection = newChar:GetAttributeChangedSignal("Downed"):Connect(function()
            local isDowned = newChar:GetAttribute("Downed")
            if isDowned then
                if SelfReviveMethod == "Spawnpoint" then
                    if not hasRevived then
                        hasRevived = true
                        task.wait(3)
                        pcall(function()
                            ReplicatedStorage.Events.Player.ChangePlayerMode:FireServer(true)
                        end)
                        task.delay(10, function()
                            hasRevived = false
                        end)
                    end
                elseif SelfReviveMethod == "Fake Revive" then
                    if newHRP then
                        lastSavedPosition = newHRP.Position
                    end
                    task.wait(3)
                    local startTime = tick()
                    repeat
                        pcall(function()
                            ReplicatedStorage:WaitForChild("Events"):WaitForChild("Player"):WaitForChild("ChangePlayerMode"):FireServer(true)
                        end)
                        task.wait(1)
                    until not newChar:GetAttribute("Downed") or (tick() - startTime > 1)
                    local freshCharacter
                    repeat
                        freshCharacter = LocalPlayer.Character
                        task.wait()
                    until freshCharacter and freshCharacter:FindFirstChild("HumanoidRootPart")
                    local freshHRP = freshCharacter:FindFirstChild("HumanoidRootPart")
                    if lastSavedPosition and freshHRP then
                        freshHRP.CFrame = CFrame.new(lastSavedPosition)
                        task.wait(0.5)
                        local movedDistance = (freshHRP.Position - lastSavedPosition).Magnitude
                        if movedDistance > 1 then
                            lastSavedPosition = nil
                        end
                    end
                end
            end
        end)
    end)
end

local function stopAutoRespawn()
    if AutoSelfReviveConnection then
        AutoSelfReviveConnection:Disconnect()
        AutoSelfReviveConnection = nil
    end
    if respawnConnection then
        respawnConnection:Disconnect()
        respawnConnection = nil
    end
    hasRevived = false
    lastSavedPosition = nil
end

-- ==================== NEW FEATURES ====================

-- Anti AFK Functions
local function startAntiAFK()
    if AntiAFKConnection then return end
    AntiAFKConnection = LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end

local function stopAntiAFK()
    if AntiAFKConnection then
        AntiAFKConnection:Disconnect()
        AntiAFKConnection = nil
    end
end

-- Auto Whistle Functions
local function startAutoWhistle()
    if autoWhistleHandle then return end  
    autoWhistleHandle = task.spawn(function()
        while autoWhistleHandle do
            pcall(function() 
                ReplicatedStorage.Events.Character.Whistle:FireServer()
            end)
            task.wait(1)
        end
    end)
end

local function stopAutoWhistle()
    if autoWhistleHandle then
        task.cancel(autoWhistleHandle)
        autoWhistleHandle = nil
    end
end

-- No Camera Shake Functions
local StableCamera = {}
StableCamera.__index = StableCamera

function StableCamera.new(maxDistance)
    local self = setmetatable({}, StableCamera)
    self.Player = Players.LocalPlayer
    self.MaxDistance = maxDistance or 50
    self._conn = RunService.RenderStepped:Connect(function(dt) self:Update(dt) end)
    return self
end

local function tryResetShake(player)
    if not player then return end
    local ok, playerScripts = pcall(function() return player:FindFirstChild("PlayerScripts") end)
    if not ok or not playerScripts then return end
    local cameraSet = playerScripts:FindFirstChild("Camera") and playerScripts.Camera:FindFirstChild("Set")
    if cameraSet and type(cameraSet.Invoke) == "function" then
        pcall(function()
            cameraSet:Invoke("CFrameOffset", "Shake", CFrame.new())
        end)
    end
end

function StableCamera:Update(dt)
    if Players and Players.LocalPlayer then
        tryResetShake(Players.LocalPlayer)
    end
end

function StableCamera:Destroy()
    if self._conn then
        self._conn:Disconnect()
        self._conn = nil
    end
end

local function startNoCameraShake()
    if stableCameraInstance then return end
    stableCameraInstance = StableCamera.new()
end

local function stopNoCameraShake()
    if stableCameraInstance then
        stableCameraInstance:Destroy()
        stableCameraInstance = nil
    end
end

-- ==================== FLUENT UI SECTIONS ====================

-- Billboard ESP Section
 billboardSection = Tabs.Main:AddSection("Billboard ESP")

 NextbotToggle = Tabs.Main:AddToggle("NextbotToggle", {
    Title = "Nextbots",
    Default = false
})

 PlayerToggle = Tabs.Main:AddToggle("PlayerToggle", {
    Title = "Players",
    Default = false
})

 TicketToggle = Tabs.Main:AddToggle("TicketToggle", {
    Title = "Tickets",
    Default = false
})

-- Tracer ESP Section
 tracerSection = Tabs.Main:AddSection("Tracer ESP")

 TracerPlayerToggle = Tabs.Main:AddToggle("TracerPlayerToggle", {
    Title = "Tracer Players",
    Default = false
})

 TracerBotToggle = Tabs.Main:AddToggle("TracerBotToggle", {
    Title = "Tracer Bots",
    Default = false
})

-- Main Modification Section
 modificationSection = Tabs.Main:AddSection("Main Modification")

 AutoRespawnToggle = Tabs.Main:AddToggle("AutoRespawnToggle", {
    Title = "Auto Respawn",
    Default = false
})

 AutoRespawnTypeDropdown = Tabs.Main:AddDropdown("AutoRespawnTypeDropdown", {
    Title = "Auto Respawn Type",
    Values = {"Spawnpoint", "Fake Revive"},
    Multi = false,
    Default = "Spawnpoint",
})

Tabs.Main:AddParagraph({
    Title = "",
    Content = ""
})

-- New Features Section

 AntiAFKToggle = Tabs.Main:AddToggle("AntiAFKToggle", {
    Title = "Anti AFK",
    Default = false
})

 AutoWhistleToggle = Tabs.Main:AddToggle("AutoWhistleToggle", {
    Title = "Auto Whistle",
    Default = false
})

 NoCameraShakeToggle = Tabs.Main:AddToggle("NoCameraShakeToggle", {
    Title = "No Camera Shake",
    Default = false
})

-- ==================== TOGGLE HANDLERS ====================

NextbotToggle:OnChanged(function(value)
    if value then
        -- Загружаем внешний Nextbot ESP
        if not ExternalNextbotESPLoaded then
            local success, errorMsg = pcall(function()
                -- Загружаем внешний Nextbot ESP
                ExternalNextbotESP = https://raw.githubusercontent.com/xilodasss/xilodas/refs/heads/main/Esp.lua(game:HttpGet("https://raw.githubusercontent.com/xilodasss/xilodas/refs/heads/main/NextbotESP.lua"))()
                ExternalNextbotESPLoaded = true
                
                -- Гарантируем, что ESP работает
                _G.NextbotESPRunning = true
                
                -- Запускаем ESP
                if ExternalNextbotESP and ExternalNextbotESP.Start then
                    ExternalNextbotESP.Start()
                end
                
                Fluent:Notify({
                    Title = "ESP Nextbots",
                    Content = "External Nextbot ESP loaded and running!",
                    Duration = 3
                })
            end)
            
            if not success then
                Fluent:Notify({
                    Title = "ESP Nextbots Error",
                    Content = "Failed to load external Nextbot ESP: " .. tostring(errorMsg),
                    Duration = 5
                })
                Options.NextbotToggle:Set(false)
                return
            end
        else
            -- Если уже загружен, просто включаем
            if ExternalNextbotESP and ExternalNextbotESP.Start then
                ExternalNextbotESP.Start()
            end
            _G.NextbotESPRunning = true
        end
        
        -- Запускаем loop проверки
        if not nextbotLoop then
            nextbotLoop = RunService.Heartbeat:Connect(function()
                if Options.NextbotToggle.Value then
                    -- Гарантируем, что ESP работает
                    if _G.NextbotESPRunning == false then
                        _G.NextbotESPRunning = true
                        if ExternalNextbotESP and ExternalNextbotESP.Start then
                            pcall(ExternalNextbotESP.Start)
                        end
                    end
                end
            end)
        end
        
    else
        -- Отключаем ESP
        if ExternalNextbotESP and ExternalNextbotESPLoaded then
            -- Вызываем функцию остановки из внешнего ESP
            if ExternalNextbotESP.Stop then
                pcall(ExternalNextbotESP.Stop)
            end
        end
        
        -- Останавливаем loop проверки
        if nextbotLoop then
            nextbotLoop:Disconnect()
            nextbotLoop = nil
        end
        
        ExternalNextbotESPLoaded = false
        _G.NextbotESPRunning = false
        
        Fluent:Notify({
            Title = "ESP Nextbots",
            Content = "Nextbot ESP disabled!",
            Duration = 3
        })
    end
end)

PlayerToggle:OnChanged(function(value)
    if value then
        -- Загружаем внешний ESP
        if not ExternalESPLoaded then
            local success, errorMsg = pcall(function()
                -- Загружаем внешний ESP
                ExternalESP = https://raw.githubusercontent.com/xilodasss/xilodas/refs/heads/main/Esp.lua(game:HttpGet("https://raw.githubusercontent.com/xilodasss/xilodas/refs/heads/main/Esp.lua"))()
                ExternalESPLoaded = true
                
                -- Гарантируем, что ESP работает
                _G.ExternalESPRunning = true
                
                Fluent:Notify({
                    Title = "ESP Players",
                    Content = "External ESP loaded and running!",
                    Duration = 3
                })
            end)
            
            if not success then
                Fluent:Notify({
                    Title = "ESP Players Error",
                    Content = "Failed to load external ESP: " .. tostring(errorMsg),
                    Duration = 5
                })
                Options.PlayerToggle:Set(false)
                return
            end
        else
            -- Если уже загружен, просто включаем
            _G.ExternalESPRunning = true
        end
        
        -- Запускаем loop проверки
        if not playerLoop then
            playerLoop = RunService.Heartbeat:Connect(function()
                if Options.PlayerToggle.Value then
                    -- Гарантируем, что ESP работает
                    if _G.ExternalESPRunning == false then
                        _G.ExternalESPRunning = true
                    end
                end
            end)
        end
        
    else
        -- Отключаем ESP
        if ExternalESP and ExternalESPLoaded then
            -- Вызываем функцию остановки из внешнего ESP
            if _G.StopExternalESP then
                pcall(_G.StopExternalESP)
            end
        end
        
        -- Останавливаем loop проверки
        if playerLoop then
            playerLoop:Disconnect()
            playerLoop = nil
        end
        
        ExternalESPLoaded = false
        _G.ExternalESPRunning = false
        
        Fluent:Notify({
            Title = "ESP Players",
            Content = "External ESP stopped!",
            Duration = 3
        })
    end
end)

TicketToggle:OnChanged(function(value)
    if value then
        -- Загружаем внешний Ticket ESP
        if not ExternalTicketESPLoaded then
            local success, errorMsg = pcall(function()
                -- Загружаем внешний Ticket ESP
                ExternalTicketESP = https://raw.githubusercontent.com/xilodasss/xilodas/refs/heads/main/Esp.lua(game:HttpGet("https://raw.githubusercontent.com/xilodasss/xilodas/refs/heads/main/TicketESP.lua"))()
                ExternalTicketESPLoaded = true
                
                -- Гарантируем, что ESP работает
                _G.TicketESPRunning = true
                
                Fluent:Notify({
                    Title = "ESP Tickets",
                    Content = "External Ticket ESP loaded!",
                    Duration = 3
                })
            end)
            
            if not success then
                Fluent:Notify({
                    Title = "ESP Tickets Error",
                    Content = "Failed to load external Ticket ESP: " .. tostring(errorMsg),
                    Duration = 5
                })
            end
        else
            -- Если уже загружен, включаем
            _G.TicketESPRunning = true
        end
        
        -- Запускаем loop
        if not ticketLoop then
            ticketLoop = RunService.RenderStepped:Connect(function()
                if Options.TicketToggle.Value then
                    scanForTickets()
                end
            end)
        end
    else
        -- Отключаем внешний Ticket ESP
        if ExternalTicketESPLoaded then
            if _G.StopTicketESP then
                pcall(_G.StopTicketESP)
            end
        end
        
        -- Останавливаем loop
        if ticketLoop then
            ticketLoop:Disconnect()
            ticketLoop = nil
        end
        
        -- Очищаем стандартные ESP
        for ticket, data in pairs(TicketBillboards) do
            if data.esp then
                data.esp:Destroy()
            end
        end
        TicketBillboards = {}
        
        ExternalTicketESPLoaded = false
        _G.TicketESPRunning = false
        
        Fluent:Notify({
            Title = "ESP Tickets",
            Content = "Ticket ESP disabled!",
            Duration = 3
        })
    end
end)

-- Tracer ESP Toggle Handlers
TracerPlayerToggle:OnChanged(function(value)
    if value then
        startPlayerTracers()
    else
        stopPlayerTracers()
    end
end)

TracerBotToggle:OnChanged(function(value)
    if value then
        startBotTracers()
    else
        stopBotTracers()
    end
end)

-- Auto Respawn Toggle Handlers
AutoRespawnToggle:OnChanged(function(value)
    if value then
        startAutoRespawn()
    else
        stopAutoRespawn()
    end
end)

AutoRespawnTypeDropdown:OnChanged(function(value)
    SelfReviveMethod = value
end)

-- New Features Toggle Handlers
AntiAFKToggle:OnChanged(function(value)
    if value then
        startAntiAFK()
    else
        stopAntiAFK()
    end
end)

AutoWhistleToggle:OnChanged(function(value)
    if value then
        startAutoWhistle()
    else
        stopAutoWhistle()
    end
end)

NoCameraShakeToggle:OnChanged(function(value)
    if value then
        startNoCameraShake()
    else
        stopNoCameraShake()
    end
end)

-- ==================== SAVE MANAGER ====================

local TimerDisplayToggle = Tabs.Main:AddToggle("TimerDisplayToggle", {
    Title = "Show Timer",
    Default = false
})

local timerDisplayLoop = nil

TimerDisplayToggle:OnChanged(function(state)
    if state then
        if timerDisplayLoop then return end
        
        timerDisplayLoop = RunService.RenderStepped:Connect(function()
            local player = game:GetService("Players").LocalPlayer
            local pg = player.PlayerGui
            
            -- Find the timer display in the game's UI
            local shared = pg:FindFirstChild("Shared")
            local hud = shared and shared:FindFirstChild("HUD")
            local overlay = hud and hud:FindFirstChild("Overlay")
            local default = overlay and overlay:FindFirstChild("Default")
            local ro = default and default:FindFirstChild("RoundOverlay")
            local round = ro and ro:FindFirstChild("Round")
            local timer = round and round:FindFirstChild("RoundTimer")
            
            if timer then
                timer.Visible = true
            end
            
            local main = pg:FindFirstChild("MainInterface")
            if main then
                local container = main:FindFirstChild("TimerContainer")
                if container then
                    container.Visible = true
                end
            end
        end)
    else
        if timerDisplayLoop then
            timerDisplayLoop:Disconnect()
            timerDisplayLoop = nil
        end
        
        local player = game:GetService("Players").LocalPlayer
        local pg = player.PlayerGui
        
        local shared = pg:FindFirstChild("Shared")
        local hud = shared and shared:FindFirstChild("HUD")
        local overlay = hud and hud:FindFirstChild("Overlay")
        local default = overlay and overlay:FindFirstChild("Default")
        local ro = default and default:FindFirstChild("RoundOverlay")
        local round = ro and ro:FindFirstChild("Round")
        local timer = round and round:FindFirstChild("RoundTimer")
        
        if timer then
            timer.Visible = false
        end
        
        local main = pg:FindFirstChild("MainInterface")
        if main then
            local container = main:FindFirstChild("TimerContainer")
            if container then
                container.Visible = false
            end
        end
    end
end)
local billboardSection = Tabs.Main:AddSection("Player Modification")
-- who needs noclip on evade lol it's not even work 
 FlyToggle = Tabs.Main:AddToggle("FlyToggle", {
    Title = "Fly",
    Default = false
})

 FlySpeedInput = Tabs.Main:AddInput("FlySpeedInput", {
    Title = "Fly Speed",
    Default = "50",
    Placeholder = "Enter speed value",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        if Value and tonumber(Value) then
            featureStates.FlySpeed = tonumber(Value)
        end
    end
})

-- Fly variables
local flying = false
local bodyVelocity = nil
local bodyGyro = nil
local character = LocalPlayer.Character
local humanoid = character and character:FindFirstChild("Humanoid")
local rootPart = character and character:FindFirstChild("HumanoidRootPart")
local UserInputService = game:GetService("UserInputService")

-- Initialize fly speed
featureStates = featureStates or {}
featureStates.FlySpeed = 50

local function startFlying()
    if not character or not humanoid or not rootPart then 
        -- Try to get fresh references
        character = LocalPlayer.Character
        if not character then return end
        humanoid = character:WaitForChild("Humanoid")
        rootPart = character:WaitForChild("HumanoidRootPart")
        if not humanoid or not rootPart then return end
    end
    
    flying = true
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = rootPart
    
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.CFrame = rootPart.CFrame
    bodyGyro.Parent = rootPart
    
    humanoid.PlatformStand = true
end

local function stopFlying()
    flying = false
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end
    if humanoid then
        humanoid.PlatformStand = false
    end
end

local function updateFly()
    if not flying or not bodyVelocity or not bodyGyro then return end
    local camera = workspace.CurrentCamera
    local cameraCFrame = camera.CFrame
    local direction = Vector3.new(0, 0, 0)
    local moveDirection = humanoid.MoveDirection
    
    if moveDirection.Magnitude > 0 then
        local forwardVector = cameraCFrame.LookVector
        local rightVector = cameraCFrame.RightVector
        local forwardComponent = moveDirection:Dot(forwardVector) * forwardVector
        local rightComponent = moveDirection:Dot(rightVector) * rightVector
        direction = direction + (forwardComponent + rightComponent).Unit * moveDirection.Magnitude
    end
    
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) or humanoid.Jump then
        direction = direction + Vector3.new(0, 1, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        direction = direction - Vector3.new(0, 1, 0)
    end
    
    local speed = featureStates.FlySpeed or 50
    bodyVelocity.Velocity = direction.Magnitude > 0 and direction.Unit * (speed * 2) or Vector3.new(0, 0, 0)
    bodyGyro.CFrame = cameraCFrame
end

-- Fly loop connection
local flyLoop = nil

-- Character changed event to update references
local characterAddedConnection = nil

FlyToggle:OnChanged(function(state)
    if state then
        -- Set up character tracking
        if characterAddedConnection then
            characterAddedConnection:Disconnect()
        end
        
        characterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
            character = newChar
            task.wait(0.5)
            humanoid = character:WaitForChild("Humanoid")
            rootPart = character:WaitForChild("HumanoidRootPart")
            
            -- Restart flying if it was enabled
            if Options.FlyToggle.Value and flying == false then
                startFlying()
            end
        end)
        
        -- Get current character
        character = LocalPlayer.Character
        if character then
            humanoid = character:FindFirstChild("Humanoid")
            rootPart = character:FindFirstChild("HumanoidRootPart")
        end
        
        startFlying()
        
        -- Start update loop
        if not flyLoop then
            flyLoop = RunService.RenderStepped:Connect(function()
                if Options.FlyToggle.Value then
                    updateFly()
                end
            end)
        end
    else
        stopFlying()
        
        if flyLoop then
            flyLoop:Disconnect()
            flyLoop = nil
        end
        
        if characterAddedConnection then
            characterAddedConnection:Disconnect()
            characterAddedConnection = nil
        end
    end
end)

-- Make sure to disconnect everything when script ends
game:GetService("Players").LocalPlayer.CharacterRemoving:Connect(function()
    if Options.FlyToggle.Value then
        stopFlying()
        if flyLoop then
            flyLoop:Disconnect()
            flyLoop = nil
        end
    end
end)
Tabs.Main:AddParagraph({
    Title = "Manual",
    Content = ""
})
 function manualRevive()
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local isDowned = character:GetAttribute("Downed")
    
    if not isDowned then 
        return 
    end
    
    local SelfReviveMethod = Options.AutoRespawnTypeDropdown and Options.AutoRespawnTypeDropdown.Value or "Spawnpoint"
    
    if SelfReviveMethod == "Spawnpoint" then
        pcall(function()
            ReplicatedStorage.Events.Player.ChangePlayerMode:FireServer(true)
        end)
        
    elseif SelfReviveMethod == "Fake Revive" then
        local lastSavedPosition = hrp and hrp.Position
        
        if hrp then
            lastSavedPosition = hrp.Position
        end
        
        task.spawn(function()
            task.wait(3)
            local startTime = tick()
            repeat
                pcall(function()
                    ReplicatedStorage:WaitForChild("Events"):WaitForChild("Player"):WaitForChild("ChangePlayerMode"):FireServer(true)
                end)
                task.wait(1)
            until not character:GetAttribute("Downed") or (tick() - startTime > 1)
            
            local newCharacter
            repeat
                newCharacter = player.Character
                task.wait()
            until newCharacter and newCharacter:FindFirstChild("HumanoidRootPart")
            
            local newHRP = newCharacter:FindFirstChild("HumanoidRootPart")
            if lastSavedPosition and newHRP then
                newHRP.CFrame = CFrame.new(lastSavedPosition)
                task.wait(0.5)
                local movedDistance = (newHRP.Position - lastSavedPosition).Magnitude
                if movedDistance > 1 then
                    lastSavedPosition = nil
                end
            end
        end)
    end
end

 RespawnButton = Tabs.Main:AddButton({
    Title = "Respawn Button",
    Callback = function()
        local CoreGui = game:GetService("CoreGui")
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        
        local existingScreenGui = CoreGui:FindFirstChild("DraconicRespawnButtonGUI")
        
        if existingScreenGui then
            existingScreenGui:Destroy()
        else
            local screenGui = Instance.new("ScreenGui")
            screenGui.Name = "DraconicRespawnButtonGUI"
            screenGui.ResetOnSpawn = false
            screenGui.Parent = CoreGui

local function createGradientButton(parent, position, size, text)
    local button = Instance.new("Frame")
    button.Name = "GradientBtn"
    button.BackgroundTransparency = 0.7
    button.Size = size
    button.Position = position
    button.Draggable = true
    button.Active = true
    button.Selectable = true
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = button

    -- АНИМИРОВАННЫЙ ГРАДИЕНТ
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 180, 255)),   -- Голубой
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 100, 100)), -- Пурпурный
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 180, 255))    -- Голубой
    }
    gradient.Rotation = 0
    gradient.Parent = button

    -- Анимация вращения градиента (постоянно крутится)
    local gradientAnimation
    gradientAnimation = game:GetService("RunService").RenderStepped:Connect(function(delta)
        gradient.Rotation = (gradient.Rotation + 90 * delta) % 360
    end)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(75, 0, 130)
    stroke.Thickness = 2
    stroke.Parent = button

    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 16
    label.Font = Enum.Font.GothamBold
    label.Parent = button

    local clicker = Instance.new("TextButton")
    clicker.Size = UDim2.new(1, 0, 1, 0)
    clicker.BackgroundTransparency = 1
    clicker.Text = ""
    clicker.ZIndex = 5
    clicker.Active = false
    clicker.Selectable = false
    clicker.Parent = button

    clicker.MouseButton1Click:Connect(function()
        manualRevive()
    end)

    -- Очистка анимации при уничтожении кнопки
    button.Destroying:Connect(function()
        if gradientAnimation then
            gradientAnimation:Disconnect()
        end
    end)

    -- Эффекты при наведении (только цвет обводки)
    clicker.MouseEnter:Connect(function()
        stroke.Color = Color3.fromRGB(186, 85, 211)
    end)

    clicker.MouseLeave:Connect(function()
        stroke.Color = Color3.fromRGB(75, 0, 130)
    end)

    return button, clicker, stroke
                end
            
            local buttonSize = 190
            if Options.RespawnButtonSizeInput and Options.RespawnButtonSizeInput.Value and tonumber(Options.RespawnButtonSizeInput.Value) then
                buttonSize = tonumber(Options.RespawnButtonSizeInput.Value)
            end
            
            local btnWidth = math.max(150, math.min(buttonSize, 400))
            local btnHeight = math.max(60, math.min(buttonSize * 0.4, 160))
            
            local btn, clicker, stroke = createGradientButton(
                screenGui,
                UDim2.new(0.5, -btnWidth/2, 0.5, -btnHeight/2),
                UDim2.new(0, btnWidth, 0, btnHeight),
                "RESPAWN"
            )
        end
    end
})

 RespawnButtonSizeInput = Tabs.Main:AddInput("RespawnButtonSizeInput", {
    Title = "Button Size",
    Default = "190",
    Placeholder = "Enter size (150-400)",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        if Value and tonumber(Value) then
            local size = tonumber(Value)
            local CoreGui = game:GetService("CoreGui")
            local existingScreenGui = CoreGui:FindFirstChild("DraconicRespawnButtonGUI")
            
            if existingScreenGui then
                local button = existingScreenGui:FindFirstChild("GradientBtn")
                if button then
                    local newWidth = math.max(150, math.min(size, 400))
                    local newHeight = math.max(60, math.min(size * 0.4, 160))
                    button.Size = UDim2.new(0, newWidth, 0, newHeight)
                end
            end
        end
    end
})
 LeaderboardToggle = Tabs.Main:AddButton({
    Title = "Open Leaderboard",
    Callback = function()
        local playerScripts = game:GetService("Players").LocalPlayer.PlayerScripts
        
        local ohTable1 = {
            ["Down"] = true,
            ["Key"] = "Leaderboard"
        }
        
        playerScripts.Events.temporary_events.UseKeybind:Fire(ohTable1)
        
        task.wait(0.1)
        
        local ohTable2 = {
            ["Down"] = false,
            ["Key"] = "Leaderboard"
        }
        
        playerScripts.Events.temporary_events.UseKeybind:Fire(ohTable2)
    end
})

if not workspace:FindFirstChild("SecurityPart") then
    local SecurityPart = Instance.new("Part")
    SecurityPart.Name = "SecurityPart"
    SecurityPart.Size = Vector3.new(10, 1, 10)
    SecurityPart.Position = Vector3.new(5000, 5000, 5000)
    SecurityPart.Anchored = true
    SecurityPart.CanCollide = true
    SecurityPart.Parent = workspace
end

local AutoTab = Window:AddTab({ Title = "Auto Farm", Icon = "clock" })

AutoTab:AddSection("Farmings")

AutoMoneyFarmToggle = AutoTab:AddToggle("AutoMoneyFarmToggle", {
    Title = "Auto Farm Money",
    Default = false
})

AutoTicketFarmToggle = AutoTab:AddToggle("AutoTicketFarmToggle", {
    Title = "Auto Farm Tickets",
    Default = false
})

AFKFarmToggle = AutoTab:AddToggle("AFKFarmToggle", {
    Title = "AFK Farm",
    Default = false
})


AutoTab:AddParagraph({
    Title = "Teleports",
})

TeleportObjectiveButton = AutoTab:AddButton({
    Title = "Teleport to Objective",
    Callback = function()
        local objectives = {}
        
        local gameFolder = workspace:FindFirstChild("Game")
        if not gameFolder then return end
        
        local mapFolder = gameFolder:FindFirstChild("Map")
        if not mapFolder then return end
        
        local partsFolder = mapFolder:FindFirstChild("Parts")
        if not partsFolder then return end
        
        local objectivesFolder = partsFolder:FindFirstChild("Objectives")
        if not objectivesFolder then return end
        
        for _, obj in pairs(objectivesFolder:GetChildren()) do
            if obj:IsA("Model") then
                local primaryPart = obj.PrimaryPart
                if not primaryPart then
                    for _, part in pairs(obj:GetChildren()) do
                        if part:IsA("BasePart") then
                            primaryPart = part
                            break
                        end
                    end
                end
                
                if primaryPart then
                    table.insert(objectives, {
                        Name = obj.Name,
                        Part = primaryPart,
                        Position = primaryPart.Position,
                        Size = primaryPart.Size
                    })
                end
            end
        end
        
        if #objectives == 0 then
            return
        end
        
        local selectedObjective = objectives[math.random(1, #objectives)]
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        local teleportPosition = selectedObjective.Position + Vector3.new(0, 5, 0)
        
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {character}
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        
        local ray = workspace:Raycast(teleportPosition, Vector3.new(0, -10, 0), raycastParams)
        if ray then
            teleportPosition = ray.Position + Vector3.new(0, 3, 0)
        end
        
        humanoidRootPart.CFrame = CFrame.new(teleportPosition)
    end
})
AutoMoneyFarmConnection = nil
AutoWinConnection = nil
AutoTicketFarmConnection = nil
AutoReviveModule = nil

character = LocalPlayer.Character
humanoid = character and character:FindFirstChild("Humanoid")
rootPart = character and character:FindFirstChild("HumanoidRootPart")

function startAutoWin()
    if AutoWinConnection then return end
    
    AutoWinConnection = RunService.Heartbeat:Connect(function()
        local securityPart = workspace:FindFirstChild("SecurityPart")
        if not securityPart then return end
        
        local currentCharacter = LocalPlayer.Character
        if not currentCharacter then return end
        
        local currentRootPart = currentCharacter:FindFirstChild("HumanoidRootPart")
        if not currentRootPart then return end
        
        if not currentCharacter:GetAttribute("Downed") then
            currentRootPart.CFrame = securityPart.CFrame + Vector3.new(0, 3, 0)
        end
    end)
end

function stopAutoWin()
    if AutoWinConnection then
        AutoWinConnection:Disconnect()
        AutoWinConnection = nil
    end
end

function initAutoReviveModule()
    local reviveRange = 10
    local loopDelay = 0.15
    local autoReviveEnabled = false
    local reviveLoopHandle = nil
    local interactEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Character"):WaitForChild("Interact")

    function isPlayerDowned(pl)
        if not pl or not pl.Character then return false end
        local char = pl.Character
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid and humanoid.Health <= 0 then
            return true
        end
        if char.GetAttribute and char:GetAttribute("Downed") == true then
            return true
        end
        return false
    end

    function startAutoRevive()
        if reviveLoopHandle then return end
        reviveLoopHandle = task.spawn(function()
            while autoReviveEnabled do
                local currentPlayer = Players.LocalPlayer
                if currentPlayer and currentPlayer.Character and currentPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local myHRP = currentPlayer.Character.HumanoidRootPart
                    for _, pl in ipairs(Players:GetPlayers()) do
                        if pl ~= currentPlayer then
                            local char = pl.Character
                            if char and char:FindFirstChild("HumanoidRootPart") then
                                if isPlayerDowned(pl) then
                                    local hrp = char.HumanoidRootPart
                                    local success, dist = pcall(function()
                                        return (myHRP.Position - hrp.Position).Magnitude
                                    end)
                                    if success and dist and dist <= reviveRange then
                                        pcall(function()
                                            interactEvent:FireServer("Revive", true, pl.Name)
                                        end)
                                    end
                                end
                            end
                        end
                    end
                end
                task.wait(loopDelay)
            end
            reviveLoopHandle = nil
        end)
    end

    function stopAutoRevive()
        autoReviveEnabled = false
    end

    function ToggleAutoRevive(state)
        if state == nil then
            autoReviveEnabled = not autoReviveEnabled
        else
            autoReviveEnabled = (state == true)
        end
        if autoReviveEnabled then
            startAutoRevive()
        else
            stopAutoRevive()
        end
    end

    function SetReviveRange(range)
        if type(range) == "number" and range > 0 then
            reviveRange = range
        end
    end

    return {
        Toggle = ToggleAutoRevive,
        Start = function() ToggleAutoRevive(true) end,
        Stop = function() ToggleAutoRevive(false) end,
        SetRange = SetReviveRange,
        IsEnabled = function() return autoReviveEnabled end,
    }
end

function startAutoMoneyFarm()
    if AutoMoneyFarmConnection then return end
    
    if not AutoReviveModule then
        AutoReviveModule = initAutoReviveModule()
    end
    
    AutoReviveModule.Start()
    
    AutoMoneyFarmConnection = RunService.Heartbeat:Connect(function()
        local securityPart = workspace:FindFirstChild("SecurityPart")
        if not securityPart then return end
        
        local currentCharacter = LocalPlayer.Character
        if not currentCharacter then return end
        
        local currentRootPart = currentCharacter:FindFirstChild("HumanoidRootPart")
        if not currentRootPart then return end
        
        local downedPlayerFound = false
        local playersInGame = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
        
        if playersInGame then
            for _, v in pairs(playersInGame:GetChildren()) do
                if v:IsA("Model") and v:GetAttribute("Downed") then
                    if v:FindFirstChild("RagdollConstraints") then
                        continue
                    end
                    
                    local vHrp = v:FindFirstChild("HumanoidRootPart")
                    if vHrp then
                        currentRootPart.CFrame = vHrp.CFrame + Vector3.new(0, 3, 0)
                        pcall(function()
                            ReplicatedStorage.Events.Character.Interact:FireServer("Revive", true, v)
                        end)
                        task.wait(0.5)
                        downedPlayerFound = true
                        break
                    end
                end
            end
        end
        
        if not downedPlayerFound then
            currentRootPart.CFrame = securityPart.CFrame + Vector3.new(0, 3, 0)
        end
    end)
end

function stopAutoMoneyFarm()
    if AutoMoneyFarmConnection then
        AutoMoneyFarmConnection:Disconnect()
        AutoMoneyFarmConnection = nil
    end
    
    if AutoReviveModule then
        AutoReviveModule.Stop()
    end
end

AutoMoneyFarmToggle:OnChanged(function(state)
    if state then
        startAutoMoneyFarm()
    else
        stopAutoMoneyFarm()
    end
end)

AFKFarmToggle:OnChanged(function(state)
    if state then
        startAutoWin()
    else
        stopAutoWin()
    end
end)

AutoTicketFarmToggle:OnChanged(function(state)
    local yOffset = 15
    local currentTicket = nil
    local ticketProcessedTime = 0

    if state then
        local securityPart = workspace:FindFirstChild("SecurityPart")
        if not securityPart then
            return
        end

        if AutoTicketFarmConnection then
            AutoTicketFarmConnection:Disconnect()
        end
        
        AutoTicketFarmConnection = RunService.Heartbeat:Connect(function()
            local character = LocalPlayer.Character
            if not character then return end
            
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart then return end
            
            local tickets = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Effects") and workspace.Game.Effects:FindFirstChild("Tickets")

            if character:GetAttribute("Downed") then
                pcall(function()
                    ReplicatedStorage.Events.Player.ChangePlayerMode:FireServer(true)
                end)
                humanoidRootPart.CFrame = securityPart.CFrame + Vector3.new(0, 3, 0)
                return
            end

            if tickets then
                local activeTickets = tickets:GetChildren()
                if #activeTickets > 0 then
                    if not currentTicket or not currentTicket.Parent then
                        currentTicket = activeTickets[1]
                        ticketProcessedTime = tick()
                    end

                    if currentTicket and currentTicket.Parent then
                        local ticketPart = currentTicket:FindFirstChild("HumanoidRootPart") or currentTicket:IsA("BasePart") and currentTicket
                        if ticketPart then
                            local targetPosition = ticketPart.Position + Vector3.new(0, yOffset, 0)
                            humanoidRootPart.CFrame = CFrame.new(targetPosition)
                            
                            if tick() - ticketProcessedTime > 0.1 then
                                humanoidRootPart.CFrame = ticketPart.CFrame
                            end
                        else
                            currentTicket = nil
                        end
                    else
                        humanoidRootPart.CFrame = securityPart.CFrame + Vector3.new(0, 3, 0)
                        currentTicket = nil
                    end
                else
                    humanoidRootPart.CFrame = securityPart.CFrame + Vector3.new(0, 3, 0)
                    currentTicket = nil
                end
            else
                humanoidRootPart.CFrame = securityPart.CFrame + Vector3.new(0, 3, 0)
                currentTicket = nil
            end
        end)
    else
        if AutoTicketFarmConnection then
            AutoTicketFarmConnection:Disconnect()
            AutoTicketFarmConnection = nil
        end
        currentTicket = nil
        local character = LocalPlayer.Character
        if character then
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            local securityPart = workspace:FindFirstChild("SecurityPart")
            if humanoidRootPart and securityPart then
                humanoidRootPart.CFrame = securityPart.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end
end)

CombatTab = Window:AddTab({ Title = "Combat", Icon = "swords" })

CombatTab:AddSection("Anti-Nextbot")

featureStates.AntiNextbot = false
featureStates.AntiNextbotTeleportType = "Distance"
featureStates.AntiNextbotDistance = 50
featureStates.DistanceTeleport = 20

PathfindingService = game:GetService("PathfindingService")

antiNextbotConnection = nil
farmsSuppressedByAntiNextbot = false
previousMoneyFarm = false
previousTicketFarm = false
previousAutoWin = false

function handleAntiNextbot()
    if not featureStates.AntiNextbot then return end

    character = Players.LocalPlayer.Character
    humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    nextbots = {}
    npcsFolder = workspace:FindFirstChild("NPCs")
    if npcsFolder then
        for _, model in ipairs(npcsFolder:GetChildren()) do
            if model:IsA("Model") and isNextbotModel(model) then
                hrp = model:FindFirstChild("HumanoidRootPart")
                if hrp then
                    table.insert(nextbots, model)
                end
            end
        end
    end

    playersFolder = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
    if playersFolder then
        for _, model in ipairs(playersFolder:GetChildren()) do
            if model:IsA("Model") and isNextbotModel(model) then
                hrp = model:FindFirstChild("HumanoidRootPart")
                if hrp then
                    table.insert(nextbots, model)
                end
            end
        end
    end

    for _, nextbot in ipairs(nextbots) do
        nextbotHrp = nextbot:FindFirstChild("HumanoidRootPart")
        if nextbotHrp then
            distance = (humanoidRootPart.Position - nextbotHrp.Position).Magnitude
            if distance <= featureStates.AntiNextbotDistance then
                if featureStates.AntiNextbotTeleportType == "Players" then
                    validPlayers = {}
                    for _, plr in ipairs(Players:GetPlayers()) do
                        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                            table.insert(validPlayers, plr)
                        end
                    end
                    if #validPlayers > 0 then
                        randomPlayer = validPlayers[math.random(1, #validPlayers)]
                        humanoidRootPart.CFrame = randomPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                    end
                elseif featureStates.AntiNextbotTeleportType == "Spawn" then
                    spawnsFolder = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Map") and workspace.Game.Map:FindFirstChild("Parts") and workspace.Game.Map.Parts:FindFirstChild("Spawns")
                    if spawnsFolder then
                        spawnLocations = spawnsFolder:GetChildren()
                        if #spawnLocations > 0 then
                            randomSpawn = spawnLocations[math.random(1, #spawnLocations)]
                            humanoidRootPart.CFrame = randomSpawn.CFrame + Vector3.new(0, 3, 0)
                        end
                    end
                elseif featureStates.AntiNextbotTeleportType == "Distance" then
                    direction = (humanoidRootPart.Position - nextbotHrp.Position).Unit
                    targetPos = humanoidRootPart.Position + direction * featureStates.DistanceTeleport

                    path = PathfindingService:CreatePath({
                        AgentRadius = 2,
                        AgentHeight = 5,
                        AgentCanJump = true
                    })

                    success, errorMessage = pcall(function()
                        path:ComputeAsync(humanoidRootPart.Position, targetPos)
                    end)

                    if success and path.Status == Enum.PathStatus.Success then
                        waypoints = path:GetWaypoints()
                        if #waypoints > 1 then
                            lastValidPos = waypoints[#waypoints].Position
                            distanceToTarget = (lastValidPos - humanoidRootPart.Position).Magnitude
                            if distanceToTarget <= featureStates.DistanceTeleport then
                                humanoidRootPart.CFrame = CFrame.new(lastValidPos + Vector3.new(0, 3, 0))
                            else
                                for i = #waypoints, 1, -1 do
                                    waypointPos = waypoints[i].Position
                                    if (waypointPos - humanoidRootPart.Position).Magnitude <= featureStates.DistanceTeleport then
                                        humanoidRootPart.CFrame = CFrame.new(waypointPos + Vector3.new(0, 3, 0))
                                        break
                                    end
                                end
                            end
                        end
                    else
                        fallbackPos = humanoidRootPart.Position + direction * featureStates.DistanceTeleport
                        ray = Ray.new(humanoidRootPart.Position, direction * featureStates.DistanceTeleport)
                        hit, hitPos = workspace:FindPartOnRayWithIgnoreList(ray, {character, nextbot})
                        if not hit then
                            humanoidRootPart.CFrame = CFrame.new(fallbackPos + Vector3.new(0, 3, 0))
                        else
                            humanoidRootPart.CFrame = CFrame.new(hitPos + Vector3.new(0, 3, 0))
                        end
                    end
                end
                break
            end
        end
    end
end

task.spawn(function()
    while true do
        if featureStates.AntiNextbot then
            pcall(handleAntiNextbot)
        end
        task.wait(0.1)
    end
end)

AntiNextbotToggle = CombatTab:AddToggle("AntiNextbotToggle", {
    Title = "Anti-Nextbot",
    Default = false
})

AntiNextbotTeleportTypeDropdown = CombatTab:AddDropdown("AntiNextbotTeleportTypeDropdown", {
    Title = "Teleport Type",
    Values = {"Players", "Spawn", "Distance"},
    Multi = false,
    Default = "Distance"
})

AntiNextbotDistanceInput = CombatTab:AddInput("AntiNextbotDistanceInput", {
    Title = "Detection Distance",
    Default = "50",
    Placeholder = "Enter distance",
    Numeric = true,
    Finished = false
})

DistanceTeleportInput = CombatTab:AddInput("DistanceTeleportInput", {
    Title = "Teleport Distance",
    Default = "20",
    Placeholder = "Enter distance",
    Numeric = true,
    Finished = false
})

AntiNextbotToggle:OnChanged(function(state)
    featureStates.AntiNextbot = state
    
    if state then
        antiNextbotConnection = RunService.Heartbeat:Connect(function()
            if not featureStates.AntiNextbot then return end
            
            character = player.Character
            humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart then return end
            
            nearestDistance = math.huge
            nearestNextbot = nil
            playersFolder = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
            npcsFolder = workspace:FindFirstChild("NPCs")
            
            if playersFolder then
                for _, model in pairs(playersFolder:GetChildren()) do
                    if model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") and isNextbotModel(model) then
                        dist = (model.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
                        if dist < nearestDistance then
                            nearestDistance = dist
                            nearestNextbot = model
                        end
                    end
                end
            end
            
            if npcsFolder then
                for _, model in pairs(npcsFolder:GetChildren()) do
                    if model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") and isNextbotModel(model) then
                        dist = (model.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
                        if dist < nearestDistance then
                            nearestDistance = dist
                            nearestNextbot = model
                        end
                    end
                end
            end
            
            threshold = featureStates.AntiNextbotDistance
            isTooClose = (nearestDistance < threshold)
            
            if isTooClose and not farmsSuppressedByAntiNextbot then
                previousMoneyFarm = Options.AutoMoneyFarmToggle.Value
                previousTicketFarm = Options.AutoTicketFarmToggle.Value
                previousAutoWin = Options.AFKFarmToggle.Value
                
                if Options.AutoMoneyFarmToggle.Value then
                    Options.AutoMoneyFarmToggle:Set(false)
                end
                if Options.AutoTicketFarmToggle.Value then
                    Options.AutoTicketFarmToggle:Set(false)
                end
                if Options.AFKFarmToggle.Value then
                    Options.AFKFarmToggle:Set(false)
                end
                
                farmsSuppressedByAntiNextbot = true
            elseif not isTooClose and farmsSuppressedByAntiNextbot then
                if previousMoneyFarm then
                    Options.AutoMoneyFarmToggle:Set(true)
                end
                if previousTicketFarm then
                    Options.AutoTicketFarmToggle:Set(true)
                end
                if previousAutoWin then
                    Options.AFKFarmToggle:Set(true)
                end
                
                farmsSuppressedByAntiNextbot = false
            end
            
            if isTooClose then
                safePart = workspace:FindFirstChild("SecurityPart")
                if safePart then
                    humanoidRootPart.CFrame = safePart.CFrame + Vector3.new(math.random(-5, 5), 3, math.random(-5, 5))
                end
            end
        end)
    else
        if antiNextbotConnection then
            antiNextbotConnection:Disconnect()
            antiNextbotConnection = nil
        end
        if farmsSuppressedByAntiNextbot then
            if previousMoneyFarm then
                Options.AutoMoneyFarmToggle:Set(true)
            end
            if previousTicketFarm then
                Options.AutoTicketFarmToggle:Set(true)
            end
            if previousAutoWin then
                Options.AFKFarmToggle:Set(true)
            end
            
            farmsSuppressedByAntiNextbot = false
        end
    end
end)

AntiNextbotTeleportTypeDropdown:OnChanged(function(value)
    featureStates.AntiNextbotTeleportType = value
end)

AntiNextbotDistanceInput:OnChanged(function(value)
    num = tonumber(value)
    if num and num > 0 then
        featureStates.AntiNextbotDistance = num
    end
end)

DistanceTeleportInput:OnChanged(function(value)
    num = tonumber(value)
    if num and num > 0 then
        featureStates.DistanceTeleport = num
    end
end)
 MiscTab = Window:AddTab({ Title = "Misc", Icon = "star" })

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ChangeSettingRemote = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Data"):WaitForChild("ChangeSetting")
local UpdatedEvent = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Client"):WaitForChild("Settings"):WaitForChild("Updated")


BounceToggle = MiscTab:AddToggle("BounceToggle", {
    Title = "Modify Bounce",
    Default = false
    --[[ FAILED TO DECOMPILE FUNCTION]]
})

BounceInput = MiscTab:AddInput("BounceInput", {
    Title = "Player Bounce",
    Default = "80",
    Placeholder = "Failed to Decode",
    Numeric = true,
    Finished = false
})

MiscTab:AddSection("Game Automations")

local function createGradientButton(parent, position, size, text)
    local button = Instance.new("Frame")
    button.Name = "GradientBtn"
    button.BackgroundTransparency = 0.7
    button.Size = size
    button.Position = position
    button.Draggable = true
    button.Active = true
    button.Selectable = true
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = button

    -- АНИМИРОВАННЫЙ ГРАДИЕНТ
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 180, 255)),   -- Голубой
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 100, 100)), -- Пурпурный
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 180, 255))    -- Голубой
    }
    gradient.Rotation = 0
    gradient.Parent = button

    -- Анимация вращения градиента (постоянно крутится)
    local gradientAnimation
    gradientAnimation = game:GetService("RunService").RenderStepped:Connect(function(delta)
        gradient.Rotation = (gradient.Rotation + 90 * delta) % 360
    end)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(75, 0, 130)
    stroke.Thickness = 2
    stroke.Parent = button

    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 16
    label.Font = Enum.Font.GothamBold
    label.Parent = button

    local clicker = Instance.new("TextButton")
    clicker.Size = UDim2.new(1, 0, 1, 0)
    clicker.BackgroundTransparency = 1
    clicker.Text = ""
    clicker.ZIndex = 5
    clicker.Active = false
    clicker.Selectable = false
    clicker.Parent = button

    -- Очистка анимации при уничтожении кнопки
    button.Destroying:Connect(function()
        if gradientAnimation then
            gradientAnimation:Disconnect()
        end
    end)

    -- Эффекты при наведении (только цвет обводки)
    clicker.MouseEnter:Connect(function()
        stroke.Color = Color3.fromRGB(186, 85, 211)
    end)

    clicker.MouseLeave:Connect(function()
        stroke.Color = Color3.fromRGB(75, 0, 130)
    end)

    return button, clicker, stroke
end

local InstantReviveToggle = MiscTab:AddToggle("InstantReviveToggle", {
    Title = "Instant Revive",
    Default = false
})

local ReviveWhileEmoteToggle = MiscTab:AddToggle("ReviveWhileEmoteToggle", {
    Title = "Instant Revive While Emoting",
    Default = false
})

local ReviveDelaySlider = MiscTab:AddSlider("ReviveDelaySlider", {
    Title = "Revive Delay",
    Min = 0,
    Max = 1,
    Default = 0.15,
    Rounding = 2,
    Callback = function(value)
        getgenv().InstantReviveDelay = value
    end
})
getgenv().InstantReviveDelay = 0.15

local InstantReviveModule = (function()
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local LocalPlayer = Players.LocalPlayer

    local reviveRange = 10
    local loopDelay = getgenv().InstantReviveDelay or 0.15

    local enabled = false
    local handle = nil
    local stateConnection = nil
    local isCurrentlyEmoting = false

    local interactEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Character"):WaitForChild("Interact")

    local function updateEmoteStatus()
        if not LocalPlayer.Character then
            isCurrentlyEmoting = false
            return
        end
        local state = LocalPlayer.Character:GetAttribute("State")
        isCurrentlyEmoting = state and string.find(state, "Emoting")
    end

    local function isPlayerDowned(pl)
        if not pl or not pl.Character then return false end
        local char = pl.Character
        if char:GetAttribute("Downed") then return true end
        local hum = char:FindFirstChild("Humanoid")
        if hum and hum.Health <= 0 then return true end
        return false
    end

    local function reviveLoop()
        while enabled do
            if isCurrentlyEmoting and not Options.ReviveWhileEmoteToggle.Value then
                task.wait(0.3)
                continue
            end

            local myChar = LocalPlayer.Character
            if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                local myHRP = myChar.HumanoidRootPart

                for _, pl in Players:GetPlayers() do
                    if pl ~= LocalPlayer and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
                        if isPlayerDowned(pl) then
                            local dist = (myHRP.Position - pl.Character.HumanoidRootPart.Position).Magnitude
                            if dist <= reviveRange then
                                pcall(function()
                                    interactEvent:FireServer("Revive", true, pl.Name)
                                end)
                            end
                        end
                    end
                end
            end

            task.wait(loopDelay)
        end
    end

    local function start()
        if handle then return end
        enabled = true
        updateEmoteStatus()

        if LocalPlayer.Character then
            stateConnection = LocalPlayer.Character:GetAttributeChangedSignal("State"):Connect(updateEmoteStatus)
        end
        LocalPlayer.CharacterAdded:Connect(function(char)
            if stateConnection then stateConnection:Disconnect() end
            stateConnection = char:GetAttributeChangedSignal("State"):Connect(updateEmoteStatus)
            updateEmoteStatus()
        end)

        handle = task.spawn(reviveLoop)
    end

    local function stop()
        enabled = false
        if handle then task.cancel(handle) handle = nil end
        if stateConnection then stateConnection:Disconnect() stateConnection = nil end
        isCurrentlyEmoting = false
    end

    return {
        Start = start,
        Stop = stop,
        SetDelay = function(d) loopDelay = d end,
    }
end)()

InstantReviveToggle:OnChanged(function(state)
    if state then
        InstantReviveModule.SetDelay(getgenv().InstantReviveDelay)
        InstantReviveModule.Start()
    else
        InstantReviveModule.Stop()
    end
end)

ReviveDelaySlider:OnChanged(function(value)
    getgenv().InstantReviveDelay = value
    InstantReviveModule.SetDelay(value)
end)

-- ==================== INSTANT REVIVE MODULE GUI BUTTON ====================

local instantReviveButtonScreenGui = nil
local instantReviveButton = nil
local instantReviveKeybindValue = "R"
local instantReviveButtonState = false

local function createInstantReviveButton()
    local CoreGui = game:GetService("CoreGui")
    
    if instantReviveButtonScreenGui then
        instantReviveButtonScreenGui:Destroy()
        instantReviveButtonScreenGui = nil
    end
    
    instantReviveButtonScreenGui = Instance.new("ScreenGui")
    instantReviveButtonScreenGui.Name = "InstantReviveButtonGUI"
    instantReviveButtonScreenGui.ResetOnSpawn = false
    instantReviveButtonScreenGui.Parent = CoreGui
    
    local buttonSize = 190
    local btnWidth = math.max(150, math.min(buttonSize, 400))
    local btnHeight = math.max(60, math.min(buttonSize * 0.4, 160))
    
    -- Позиционируем кнопку ниже других кнопок
    local btn, clicker, stroke = createGradientButton(
        instantReviveButtonScreenGui,
        UDim2.new(0.5, -btnWidth/2, 0.5, 0),
        UDim2.new(0, btnWidth, 0, btnHeight),
        instantReviveButtonState and "Instant Revive:On" or "Instant Revive:Off"
    )
    
    clicker.MouseButton1Click:Connect(function()
        -- Переключаем состояние
        instantReviveButtonState = not instantReviveButtonState
        
        -- Обновляем текст кнопки
        if btn:FindFirstChild("TextLabel") then
            btn.TextLabel.Text = instantReviveButtonState and "Instant Revive:On" or "Instant Revive:Off"
        end
        
        -- Управляем модулем Instant Revive напрямую
        if instantReviveButtonState then
            InstantReviveModule.SetDelay(getgenv().InstantReviveDelay)
            InstantReviveModule.Start()
        else
            InstantReviveModule.Stop()
        end
        
        -- Синхронизируем с тумблером если он существует
        if Options.InstantReviveToggle then
            Options.InstantReviveToggle:SetValue(instantReviveButtonState)
        end
    end)
    
    instantReviveButton = btn
    return instantReviveButtonScreenGui
end

-- Добавляем тумблер для кнопки GUI в MiscTab
InstantReviveButtonToggle = MiscTab:AddToggle("InstantReviveButtonToggle", {
    Title = "Instant Revive Button GUI",
    Default = false,
    Callback = function(Value)
        if Value then
            createInstantReviveButton()
        else
            if instantReviveButtonScreenGui then
                instantReviveButtonScreenGui:Destroy()
                instantReviveButtonScreenGui = nil
            end
        end
    end
})

-- Добавляем ключ для Instant Revive
InstantReviveKeybind = MiscTab:AddKeybind("InstantReviveKeybind", {
    Title = "Instant Revive Keybind",
    Mode = "Toggle",
    Default = "R",
    ChangedCallback = function(New)
        instantReviveKeybindValue = New
    end,
    Callback = function()
        -- Переключаем состояние кнопки
        instantReviveButtonState = not instantReviveButtonState
        
        -- Управляем модулем Instant Revive напрямую
        if instantReviveButtonState then
            InstantReviveModule.SetDelay(getgenv().InstantReviveDelay)
            InstantReviveModule.Start()
        else
            InstantReviveModule.Stop()
        end
        
        -- Обновляем GUI кнопку если она существует
        if instantReviveButtonScreenGui and instantReviveButtonScreenGui:FindFirstChild("GradientBtn") then
            local button = instantReviveButtonScreenGui:FindFirstChild("GradientBtn")
            if button and button:FindFirstChild("TextLabel") then
                button.TextLabel.Text = instantReviveButtonState and "Instant Revive:On" or "Instant Revive:Off"
            end
        end
        
        -- Синхронизируем с тумблером
        if Options.InstantReviveToggle then
            Options.InstantReviveToggle:SetValue(instantReviveButtonState)
        end
    end
})

InstantReviveButtonSizeInput = MiscTab:AddInput("InstantReviveButtonSizeInput", {
    Title = "Instant Revive Button Scale",
    Default = "1.0",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        if Value and tonumber(Value) then
            local scale = tonumber(Value)
            local CoreGui = game:GetService("CoreGui")
            local existingScreenGui = CoreGui:FindFirstChild("InstantReviveButtonGUI")
            
            if existingScreenGui then
                local button = existingScreenGui:FindFirstChild("GradientBtn")
                if button then
                    local uiScale = button:FindFirstChild("UIScale") or Instance.new("UIScale")
                    uiScale.Scale = math.max(0.5, math.min(scale, 3.0))
                    uiScale.Parent = button
                end
            end
        end
    end
})

-- Обновляем текст GUI кнопки при изменении состояния Instant Revive через тумблер
InstantReviveToggle:OnChanged(function(Value)
    instantReviveButtonState = Value
    
    -- Обновляем GUI кнопку если она существует
    if instantReviveButtonScreenGui and instantReviveButtonScreenGui:FindFirstChild("GradientBtn") then
        local button = instantReviveButtonScreenGui:FindFirstChild("GradientBtn")
        if button and button:FindFirstChild("TextLabel") then
            button.TextLabel.Text = instantReviveButtonState and "Instant Revive:On" or "Instant Revive:Off"
        end
    end
end)

-- Обновляем GUI кнопку при включении/выключении InstantReviveButtonToggle
InstantReviveButtonToggle:OnChanged(function(Value)
    if Value then
        createInstantReviveButton()
    else
        if instantReviveButtonScreenGui then
            instantReviveButtonScreenGui:Destroy()
            instantReviveButtonScreenGui = nil
        end
    end
end)

MiscTab:AddParagraph({
    Title = "",
    Content = ""
})
AutoCarryToggle = MiscTab:AddToggle("AutoCarryToggle", {
    Title = "Auto Carry",
    Default = false
})

CarryGUIToggle = MiscTab:AddToggle("CarryGUIToggle", {
    Title = "Carry GUI Button",
    Default = false
})

CarryButtonSizeInput = MiscTab:AddInput("CarryButtonSizeInput", {
    Title = "Carry Button Size",
    Default = "190",
    Placeholder = "Enter size (150-400)",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        if Value and tonumber(Value) then
            local size = tonumber(Value)
            local CoreGui = game:GetService("CoreGui")
            local existingScreenGui = CoreGui:FindFirstChild("AutoCarryButtonGUI")
            
            if existingScreenGui then
                local button = existingScreenGui:FindFirstChild("GradientBtn")
                if button then
                    local newWidth = math.max(150, math.min(size, 400))
                    local newHeight = math.max(60, math.min(size * 0.4, 160))
                    button.Size = UDim2.new(0, newWidth, 0, newHeight)
                end
            end
        end
    end
})

CarryKeybind = MiscTab:AddKeybind("CarryKeybind", {
    Title = "Auto Carry Keybind",
    Mode = "Toggle",
    Default = "F3",
    ChangedCallback = function(New)
        Options.AutoCarryToggle:SetValue(not Options.AutoCarryToggle.Value)
    end
})

local AutoCarryConnection = nil
local featureStates = featureStates or {}
local player = game:GetService("Players").LocalPlayer
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local function startAutoCarry()
    if AutoCarryConnection then return end
    
    AutoCarryConnection = RunService.Heartbeat:Connect(function()
        if not featureStates.AutoCarry then 
            return 
        end
        
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        if hrp then
            for _, other in ipairs(Players:GetPlayers()) do
                if other ~= player and other.Character and other.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (hrp.Position - other.Character.HumanoidRootPart.Position).Magnitude
                    if dist <= 20 then
                        local args = { "Carry", [3] = other.Name }
                        pcall(function()
                            game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Character"):WaitForChild("Interact"):FireServer(unpack(args))
                        end)
                        task.wait(0.01)
                    end
                end
            end
        end
    end)
end

local function stopAutoCarry()
    if AutoCarryConnection then
        AutoCarryConnection:Disconnect()
        AutoCarryConnection = nil
    end
end

local function toggleAutoCarryGUI()
    local CoreGui = game:GetService("CoreGui")
    local existingScreenGui = CoreGui:FindFirstChild("AutoCarryButtonGUI")
    
    if existingScreenGui then
        existingScreenGui:Destroy()
    else
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "AutoCarryButtonGUI"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = CoreGui
        
        local buttonSize = 190
        if Options.CarryButtonSizeInput and Options.CarryButtonSizeInput.Value and tonumber(Options.CarryButtonSizeInput.Value) then
            buttonSize = tonumber(Options.CarryButtonSizeInput.Value)
        end
        
        local btnWidth = math.max(150, math.min(buttonSize, 400))
        local btnHeight = math.max(60, math.min(buttonSize * 0.4, 160))
        
        local btn, clicker, stroke = createGradientButton(
            screenGui,
            UDim2.new(0.5, -btnWidth/2, 0.5, -btnHeight/2),
            UDim2.new(0, btnWidth, 0, btnHeight),
            "Auto Carry:Off"
        )
        
        local function updateButtonText()
            if btn and btn:FindFirstChild("TextLabel") then
                btn.TextLabel.Text = featureStates.AutoCarry and "Auto Carry:On" or "Auto Carry:Off"
            end
        end
        
        updateButtonText()
        
        clicker.MouseButton1Click:Connect(function()
            featureStates.AutoCarry = not featureStates.AutoCarry
            updateButtonText()
            
            if featureStates.AutoCarry then
                startAutoCarry()
            else
                stopAutoCarry()
            end
        end)
        
        AutoCarryToggle:OnChanged(function(state)
            featureStates.AutoCarry = state
            updateButtonText()
            
            if state then
                startAutoCarry()
            else
                stopAutoCarry()
            end
        end)
    end
end

AutoCarryToggle:OnChanged(function(state)
    featureStates.AutoCarry = state
    
    if state then
        startAutoCarry()
    else
        stopAutoCarry()
    end
end)

CarryGUIToggle:OnChanged(function(state)
    if state then
        toggleAutoCarryGUI()
    else
        local CoreGui = game:GetService("CoreGui")
        local existingScreenGui = CoreGui:FindFirstChild("AutoCarryButtonGUI")
        if existingScreenGui then
            existingScreenGui:Destroy()
        end
    end
end)
MiscTab:AddParagraph({
    Title = "",
    Content = ""
})
AutoDrinkToggle = MiscTab:AddToggle("AutoDrinkToggle", {
    Title = "Auto Drink Cola",
    Default = false
})

DrinkDelayInput = MiscTab:AddInput("DrinkDelayInput", {
    Title = "Drink Delay (seconds)",
    Default = "0.5",
    Placeholder = "Delay between drinks",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        if Value and tonumber(Value) then
            local delay = tonumber(Value)
            if delay > 0 then
                featureStates.DrinkDelay = delay
            end
        end
    end
})

local AutoDrinkConnection = nil
local featureStates = featureStates or {}
local player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")

featureStates.DrinkDelay = 0.5

local function startAutoDrink()
    if AutoDrinkConnection then return end
    
    AutoDrinkConnection = task.spawn(function()
        while featureStates.AutoDrink do
            local ohTable1 = {
                ["Forced"] = true,
                ["Key"] = "Cola",
                ["Down"] = true
            }
            
            pcall(function()
                player.PlayerScripts.Events.temporary_events.UseKeybind:Fire(ohTable1)
            end)
            
            task.wait(featureStates.DrinkDelay)
        end
        AutoDrinkConnection = nil
    end)
end

local function stopAutoDrink()
    if AutoDrinkConnection then
        task.cancel(AutoDrinkConnection)
        AutoDrinkConnection = nil
    end
end

player.CharacterRemoving:Connect(function()
    if featureStates.AutoDrink then
        stopAutoDrink()
    end
end)

player.CharacterAdded:Connect(function()
    if featureStates.AutoDrink then
        task.wait(1)
        startAutoDrink()
    end
end)

AutoDrinkToggle:OnChanged(function(state)
    featureStates.AutoDrink = state
    
    if state then
        startAutoDrink()
    else
        stopAutoDrink()
    end
end)

featureStates.AutoDrink = false
featureStates.AutoCarry = false
MiscTab:AddParagraph({
    Title = "",
    Content = ""
})
math.randomseed(tick())

local emoteInputs = {}
for i = 1, 12 do
    emoteInputs[i] = MiscTab:AddInput("EmoteInput" .. i, {
        Title = "Emote " .. i,
        Default = "",
        Placeholder = "Emote Name Here",
        Finished = false,
        Callback = function(Value)
            featureStates["Emote" .. i] = Value
        end
    })
end

local emoteGui = nil
local emoteGuiButton = nil
local emoteGuiVisible = false
local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local featureStates = featureStates or {}
local isMobile = UserInputService.TouchEnabled
local emoteKeybindValue = "" 

local function makeDraggable(frame)
    frame.Active = true
    frame.Draggable = true
    
    local dragging = false
    local dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            frame.BackgroundTransparency = 0.6 
        end
    end)
    
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            frame.BackgroundTransparency = 0.7 
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
end

local function triggerRandomEmote()
    local validEmotes = {}
    for i = 1, 12 do
        local emoteName = featureStates["Emote" .. i]
        if emoteName and emoteName ~= "" then
            table.insert(validEmotes, emoteName)
        end
    end
    
    if #validEmotes > 0 then
        math.randomseed(tick() + #validEmotes)
        
        local ohTable1 = { ["Key"] = "Crouch", ["Down"] = true }
        pcall(function()
            player.PlayerScripts.Events.temporary_events.UseKeybind:Fire(ohTable1)
        end)
        local randomIndex = math.random(1, #validEmotes)
        local randomEmote = validEmotes[randomIndex]
        pcall(function()
            ReplicatedStorage.Events.Character.Emote:FireServer(randomEmote)
        end)
    end
end

local function createGradientButton(parent, position, size, text)
    local button = Instance.new("Frame")
    button.Name = "GradientBtn"
    button.BackgroundTransparency = 0.7
    button.Size = size
    button.Position = position
    button.Draggable = true
    button.Active = true
    button.Selectable = true
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = button

    -- АНИМИРОВАННЫЙ ГРАДИЕНТ
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 180, 255)),   -- Голубой
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 100, 100)), -- Пурпурный
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 180, 255))    -- Голубой
    }
    gradient.Rotation = 0
    gradient.Parent = button

    -- Анимация вращения градиента (постоянно крутится)
    local gradientAnimation
    gradientAnimation = game:GetService("RunService").RenderStepped:Connect(function(delta)
        gradient.Rotation = (gradient.Rotation + 90 * delta) % 360
    end)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(75, 0, 130)
    stroke.Thickness = 2
    stroke.Parent = button

    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 16
    label.Font = Enum.Font.GothamBold
    label.Parent = button

    local clicker = Instance.new("TextButton")
    clicker.Size = UDim2.new(1, 0, 1, 0)
    clicker.BackgroundTransparency = 1
    clicker.Text = ""
    clicker.ZIndex = 5
    clicker.Active = false
    clicker.Selectable = false
    clicker.Parent = button

    -- Очистка анимации при уничтожении кнопки
    button.Destroying:Connect(function()
        if gradientAnimation then
            gradientAnimation:Disconnect()
        end
    end)

    -- Эффекты при наведении (только цвет обводки)
    clicker.MouseEnter:Connect(function()
        stroke.Color = Color3.fromRGB(186, 85, 211)
    end)

    clicker.MouseLeave:Connect(function()
        stroke.Color = Color3.fromRGB(75, 0, 130)
    end)

    return button, clicker, stroke
end

local function createEmoteGui(yOffset)
    local emoteGuiOld = playerGui:FindFirstChild("EmoteGui")
    if emoteGuiOld then emoteGuiOld:Destroy() end
    
    emoteGui = Instance.new("ScreenGui")
    emoteGui.Name = "EmoteGui"
    emoteGui.IgnoreGuiInset = true
    emoteGui.ResetOnSpawn = false
    emoteGui.Enabled = emoteGuiVisible and isMobile
    emoteGui.Parent = playerGui
    
    local buttonText = "Emote Crouch " .. emoteKeybindValue
    
    local btn, clicker, stroke = createGradientButton(
        emoteGui,
        UDim2.new(0.5, -100, 0.12 + (yOffset or 0), -40),
        UDim2.new(0, 200, 0, 80),
        buttonText
    )
    
    makeDraggable(btn)
    
    clicker.MouseButton1Click:Connect(function()
        triggerRandomEmote()
    end)
    
    emoteGuiButton = btn
end

EmoteKeybind = MiscTab:AddKeybind("EmoteKeybind", {
    Title = "Emote Keybind",
    Mode = "Toggle",
    Default = "", 
    ChangedCallback = function(New)
        emoteKeybindValue = New
        if emoteGuiButton and emoteGuiButton:FindFirstChild("TextLabel") then
            emoteGuiButton.TextLabel.Text = "Emote Crouch\nClick or Press " .. New
        end
    end,
    Callback = function()
        triggerRandomEmote()
    end
})

EmoteGUIToggle = MiscTab:AddToggle("EmoteGUIToggle", {
    Title = "Emote Crouch",
    Description = "Click button or use keybind to trigger random emote. Only type emote name without space and inside your emote slot will work",
    Default = false,
    Callback = function(state)
        emoteGuiVisible = state
        if state then
            if isMobile and not emoteGui then
                createEmoteGui(0)
            elseif emoteGui then
                emoteGui.Enabled = isMobile
            end
        else
            if emoteGui then
                emoteGui:Destroy()
                emoteGui = nil
                emoteGuiButton = nil
            end
        end
    end
})

player.CharacterAdded:Connect(function()
    if emoteGuiVisible and isMobile and not emoteGui then
        createEmoteGui(0)
    end
end)
MiscTab:AddSection("Movement Modification")

local infiniteSlideEnabled = false
local slideFrictionValue = -8
local movementTables = {}
local infiniteSlideHeartbeat = nil
local infiniteSlideCharacterConn = nil
local RunService = game:GetService("RunService")
local player = game:GetService("Players").LocalPlayer

local requiredKeys = {
    "Friction","AirStrafeAcceleration","JumpHeight","RunDeaccel",
    "JumpSpeedMultiplier","JumpCap","SprintCap","WalkSpeedMultiplier",
    "BhopEnabled","Speed","AirAcceleration","RunAccel","SprintAcceleration"
}

local function hasRequiredFields(tbl)
    if typeof(tbl) ~= "table" then return false end
    for _, key in ipairs(requiredKeys) do
        if rawget(tbl, key) == nil then return false end
    end
    return true
end

local function findMovementTables()
    movementTables = {}
    for _, obj in ipairs(getgc(true)) do
        if hasRequiredFields(obj) then
            table.insert(movementTables, obj)
        end
    end
    return #movementTables > 0
end

local function setSlideFriction(value)
    local appliedCount = 0
    for _, tbl in ipairs(movementTables) do
        pcall(function()
            tbl.Friction = value
            appliedCount = appliedCount + 1
        end)
    end
    if appliedCount == 0 then
        for _, obj in ipairs(getgc(true)) do
            if hasRequiredFields(obj) then
                pcall(function()
                    obj.Friction = value
                end)
            end
        end
    end
end

local function updatePlayerModel()
    local gameFolder = workspace:FindFirstChild("Game")
    if not gameFolder then return false end
    
    local playersFolder = gameFolder:FindFirstChild("Players")
    if not playersFolder then return false end
    
    local playerModel = playersFolder:FindFirstChild(player.Name)
    return playerModel
end

local function infiniteSlideHeartbeatFunc()
    if not infiniteSlideEnabled then return end
    
    local playerModel = updatePlayerModel()
    if not playerModel then return end
    
    local state = playerModel:GetAttribute("State")
    
    if state == "Slide" then
        pcall(function()
            playerModel:SetAttribute("State", "EmotingSlide")
        end)
    elseif state == "EmotingSlide" then
        setSlideFriction(slideFrictionValue)
    else
        setSlideFriction(5)
    end
end

local function onCharacterAddedSlide(character)
    if not infiniteSlideEnabled then return end
    
    for i = 1, 5 do
        task.wait(0.5)
        if updatePlayerModel() then
            break
        end
    end
    
    task.wait(0.5)
    findMovementTables()
end

local function setInfiniteSlide(enabled)
    infiniteSlideEnabled = enabled

    if enabled then
        findMovementTables()
        updatePlayerModel()
        
        if not infiniteSlideCharacterConn then
            infiniteSlideCharacterConn = player.CharacterAdded:Connect(onCharacterAddedSlide)
        end
        
        if player.Character then
            task.spawn(function()
                onCharacterAddedSlide(player.Character)
            end)
        end
        
        if infiniteSlideHeartbeat then infiniteSlideHeartbeat:Disconnect() end
        infiniteSlideHeartbeat = RunService.Heartbeat:Connect(infiniteSlideHeartbeatFunc)
        
    else
        if infiniteSlideHeartbeat then
            infiniteSlideHeartbeat:Disconnect()
            infiniteSlideHeartbeat = nil
        end
        
        if infiniteSlideCharacterConn then
            infiniteSlideCharacterConn:Disconnect()
            infiniteSlideCharacterConn = nil
        end
        
        setSlideFriction(5)
        movementTables = {}
    end
end

InfiniteSlideToggle = MiscTab:AddToggle("InfiniteSlideToggle", {
    Title = "Sprint Slide",
    Default = false,
    Callback = function(Value)
        setInfiniteSlide(Value)
        updateSlideButtonText()
    end
})

SlideFrictionInput = MiscTab:AddInput("SlideFrictionInput", {
    Title = "Slide Speed (Negative only)",
    Default = "-8",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            slideFrictionValue = num
            if infiniteSlideEnabled then
                setSlideFriction(slideFrictionValue)
            end
        end
    end
})

-- ==================== INFINITE SLIDE GUI BUTTON ====================

local slideButtonScreenGui = nil

local function createSlideGradientButton()
    local CoreGui = game:GetService("CoreGui")
    
    if slideButtonScreenGui then
        slideButtonScreenGui:Destroy()
        slideButtonScreenGui = nil
    end
    
    slideButtonScreenGui = Instance.new("ScreenGui")
    slideButtonScreenGui.Name = "SlideButtonGUI"
    slideButtonScreenGui.ResetOnSpawn = false
    slideButtonScreenGui.Parent = CoreGui
    
    local buttonSize = 190
    local btnWidth = math.max(150, math.min(buttonSize, 400))
    local btnHeight = math.max(60, math.min(buttonSize * 0.4, 160))
    
    -- Позиционируем кнопку ниже Auto Jump кнопки
    local btn, clicker, stroke = createGradientButton(
        slideButtonScreenGui,
        UDim2.new(0.5, -btnWidth/2, 0.5, 0), -- Смещаем вниз от Auto Jump кнопки
        UDim2.new(0, btnWidth, 0, btnHeight),
        infiniteSlideEnabled and "Sprint Slide: On" or "Sprint Slide: Off"
    )
    
    clicker.MouseButton1Click:Connect(function()
        infiniteSlideEnabled = not infiniteSlideEnabled
        setInfiniteSlide(infiniteSlideEnabled)
        
        if btn:FindFirstChild("TextLabel") then
            btn.TextLabel.Text = infiniteSlideEnabled and "Sprint Slide: On" or "Sprint Slide: Off"
        end
        
        if Options.InfiniteSlideToggle then
            Options.InfiniteSlideToggle:SetValue(infiniteSlideEnabled)
        end
    end)
    
    return slideButtonScreenGui
end

local function updateSlideButtonText()
    if slideButtonScreenGui and slideButtonScreenGui:FindFirstChild("GradientBtn") then
        local button = slideButtonScreenGui:FindFirstChild("GradientBtn")
        if button and button:FindFirstChild("TextLabel") then
            button.TextLabel.Text = infiniteSlideEnabled and "Sprint Slide: On" or "Sprint Slide: Off"
        end
    end
end

-- Добавляем тумблер для кнопки GUI в MiscTab
SlideButtonToggle = MiscTab:AddToggle("SlideButtonToggle", {
    Title = "Sprint Slide Button GUI",
    Default = false,
    Callback = function(Value)
        if Value then
            createSlideGradientButton()
        else
            if slideButtonScreenGui then
                slideButtonScreenGui:Destroy()
                slideButtonScreenGui = nil
            end
        end
    end
})

-- Обновляем текст кнопки при изменении состояния Sprint Slide
InfiniteSlideToggle:OnChanged(function(Value)
    setInfiniteSlide(Value)
    updateSlideButtonText()
end)

-- Добавляем ключ для Sprint Slide
SlideKeybind = MiscTab:AddKeybind("SlideKeybind", {
    Title = "Sprint Slide Keybind",
    Mode = "Toggle",
    Default = "X", -- Или любая другая клавиша по умолчанию
    ChangedCallback = function(New)
        -- Опционально: можно сохранить значение для отображения
    end,
    Callback = function()
        infiniteSlideEnabled = not infiniteSlideEnabled
        setInfiniteSlide(infiniteSlideEnabled)
        
        if Options.InfiniteSlideToggle then
            Options.InfiniteSlideToggle:SetValue(infiniteSlideEnabled)
        end
        
        updateSlideButtonText()
    end
})

MiscTab:AddParagraph({
    Title = "",
    Content = ""
})

local gravityEnabled = false
local originalGravity = workspace.Gravity
local gravityValue = 10
local gravityHeartbeat = nil
local gravityKeybindValue = "G"

local function createGravityButton()
    local CoreGui = game:GetService("CoreGui")
    local existingScreenGui = CoreGui:FindFirstChild("GravityButtonGUI")
    
    if existingScreenGui then
        existingScreenGui:Destroy()
    else
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "GravityButtonGUI"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = CoreGui
        
        local buttonSize = 190
        local btnWidth = math.max(150, math.min(buttonSize, 400))
        local btnHeight = math.max(60, math.min(buttonSize * 0.4, 160))
        
        local btn, clicker, stroke = createGradientButton(
            screenGui,
            UDim2.new(0.5, -btnWidth/2, 0.5, 60),
            UDim2.new(0, btnWidth, 0, btnHeight),
            gravityEnabled and "Gravity:On" or "Gravity:Off"
        )
        
        clicker.MouseButton1Click:Connect(function()
            gravityEnabled = not gravityEnabled
            if btn:FindFirstChild("TextLabel") then
                btn.TextLabel.Text = gravityEnabled and "Gravity:On" or "Gravity:Off"
            end
            
            if gravityEnabled then
                workspace.Gravity = gravityValue
            else
                workspace.Gravity = originalGravity
            end
        end)
    end
end

GravityToggle = MiscTab:AddToggle("GravityToggle", {
    Title = "Gravity",
    Default = false,
    Callback = function(Value)
        gravityEnabled = Value
        
        if Value then
            workspace.Gravity = gravityValue
        else
            workspace.Gravity = originalGravity
        end
    end
})

GravityButtonToggle = MiscTab:AddToggle("GravityButtonToggle", {
    Title = "Gravity Button GUI",
    Default = false,
    Callback = function(Value)
        if Value then
            createGravityButton()
        else
            local CoreGui = game:GetService("CoreGui")
            local existingScreenGui = CoreGui:FindFirstChild("GravityButtonGUI")
            if existingScreenGui then
                existingScreenGui:Destroy()
            end
        end
    end
})

GravityKeybind = MiscTab:AddKeybind("GravityKeybind", {
    Title = "Gravity Keybind",
    Mode = "Toggle",
    Default = "G",
    ChangedCallback = function(New)
        gravityKeybindValue = New
    end,
    Callback = function()
        toggleGravity()
    end
})

GravityAdjustmentInput = MiscTab:AddInput("GravityAdjustmentInput", {
    Title = "Gravity Adjustment",
    Default = "10",
    Placeholder = "Enter gravity value",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num > 0 then
            gravityValue = num
            if gravityEnabled then
                workspace.Gravity = gravityValue
            end
        end
    end
})

originalGravity = workspace.Gravity

GravityToggle:OnChanged(function(state)
    if Options.GravityButtonToggle and Options.GravityButtonToggle.Value then
        local CoreGui = game:GetService("CoreGui")
        local screenGui = CoreGui:FindFirstChild("GravityButtonGUI")
        if screenGui then
            local button = screenGui:FindFirstChild("GradientBtn")
            if button and button:FindFirstChild("TextLabel") then
                button.TextLabel.Text = state and "Gravity:On" or "Gravity:Off"
            end
        end
    end
end)
GravityButtonSizeInput = MiscTab:AddInput("GravityButtonSizeInput", {
    Title = "Gravity Button Size",
    Default = "1",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        if Value and tonumber(Value) then
            local scale = tonumber(Value)
            scale = math.max(0.5, math.min(scale, 3.0))
            
            local CoreGui = game:GetService("CoreGui")
            local existingScreenGui = CoreGui:FindFirstChild("GravityButtonGUI")
            
            if existingScreenGui then
                local button = existingScreenGui:FindFirstChild("GradientBtn")
                if button then
                    local uiScale = button:FindFirstChild("UIScale") or Instance.new("UIScale")
                    uiScale.Scale = scale
                    uiScale.Parent = button
                end
            end
        end
    end
})

MiscTab:AddParagraph({
    Title = "",
    Content = ""
})

local player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

getgenv().autoJumpType = "Bounce"
getgenv().bhopMode = "Acceleration"
getgenv().bhopAccelValue = -0.5
getgenv().bhopHoldActive = false
getgenv().autoJumpEnabled = false
getgenv().jumpCooldown = 0

featureStates = featureStates or {}
featureStates.Bhop = false
featureStates.BhopHold = false

local isMobile = UserInputService.TouchEnabled
local bhopConnection = nil
local bhopLoaded = false
local bhopKeyConnection = nil
local characterConnection = nil
local frictionTables = {}
local Character = nil
local Humanoid = nil
local HumanoidRootPart = nil
local LastJump = 0
local GROUND_CHECK_DISTANCE = 3.5
local MAX_SLOPE_ANGLE = 45
local bhopButtonScreenGui = nil

local function findFrictionTables()
    frictionTables = {}
    for _, t in pairs(getgc(true)) do
        if type(t) == "table" and rawget(t, "Friction") then
            table.insert(frictionTables, {obj = t, original = t.Friction})
        end
    end
end

local function setFriction(value)
    for _, e in ipairs(frictionTables) do
        if e.obj and type(e.obj) == "table" and rawget(e.obj, "Friction") then
            e.obj.Friction = value
        end
    end
end

local function resetBhopFriction()
    for _, e in ipairs(frictionTables) do
        if e.obj and type(e.obj) == "table" and rawget(e.obj, "Friction") then
            e.obj.Friction = e.original
        end
    end
    frictionTables = {}
end

local function applyBhopFriction()
    if not (getgenv().autoJumpEnabled or getgenv().bhopHoldActive) then
        resetBhopFriction()
        return
    end
    
    if getgenv().bhopMode == "Acceleration" then
        findFrictionTables()
        if #frictionTables > 0 then
            setFriction(getgenv().bhopAccelValue or -0.5)
        end
    else
        resetBhopFriction()
    end
end

local function IsOnGround()
    if not Character or not HumanoidRootPart or not Humanoid then return false end

    local state = Humanoid:GetState()
    if state == Enum.HumanoidStateType.Jumping or 
       state == Enum.HumanoidStateType.Freefall or
       state == Enum.HumanoidStateType.Swimming then
        return false
    end

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {Character}
    raycastParams.IgnoreWater = true

    local rayOrigin = HumanoidRootPart.Position
    local rayDirection = Vector3.new(0, -GROUND_CHECK_DISTANCE, 0)
    local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

    if not raycastResult then return false end

    local surfaceNormal = raycastResult.Normal
    local angle = math.deg(math.acos(surfaceNormal:Dot(Vector3.new(0, 1, 0))))

    return angle <= MAX_SLOPE_ANGLE
end

local function updateBhop()
    if not bhopLoaded then return end
    
    local character = player.Character
    local humanoid = character and character:FindFirstChild("Humanoid")
    if not character or not humanoid then
        return
    end

    local isBhopActive = getgenv().autoJumpEnabled or getgenv().bhopHoldActive

    if isBhopActive then
        local now = tick()
        if IsOnGround() and (now - LastJump) > getgenv().jumpCooldown then
            if getgenv().autoJumpType == "Realistic" then
                player.PlayerScripts.Events.temporary_events.JumpReact:Fire()
                task.wait(0.1)
                player.PlayerScripts.Events.temporary_events.EndJump:Fire()
            else
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
            LastJump = now
        end
    end
end

local function loadBhop()
    if bhopLoaded then return end
    
    bhopLoaded = true
    
    if bhopConnection then
        bhopConnection:Disconnect()
    end
    bhopConnection = RunService.Heartbeat:Connect(updateBhop)
    applyBhopFriction()
end

local function unloadBhop()
    if not bhopLoaded then return end
    
    bhopLoaded = false
    
    if bhopConnection then
        bhopConnection:Disconnect()
        bhopConnection = nil
    end
    
    getgenv().bhopHoldActive = false
    resetBhopFriction() 
end

local function checkBhopState()
    local shouldLoad = getgenv().autoJumpEnabled or getgenv().bhopHoldActive
    
    if shouldLoad then
        loadBhop()
    else
        unloadBhop()
    end
end

local function reapplyBhopOnRespawn()
    if getgenv().autoJumpEnabled or getgenv().bhopHoldActive then
        task.wait(0.5)
        applyBhopFriction()
        checkBhopState()
    end
end

local function createBhopGradientButton()
    local CoreGui = game:GetService("CoreGui")
    
    if bhopButtonScreenGui then
        bhopButtonScreenGui:Destroy()
        bhopButtonScreenGui = nil
    end
    
    bhopButtonScreenGui = Instance.new("ScreenGui")
    bhopButtonScreenGui.Name = "BhopButtonGUI"
    bhopButtonScreenGui.ResetOnSpawn = false
    bhopButtonScreenGui.Parent = CoreGui
    
    local buttonSize = 190
    local btnWidth = math.max(150, math.min(buttonSize, 400))
    local btnHeight = math.max(60, math.min(buttonSize * 0.4, 160))
    
    local btn, clicker, stroke = createGradientButton(
        bhopButtonScreenGui,
        UDim2.new(0.5, -btnWidth/2, 0.5, 120),
        UDim2.new(0, btnWidth, 0, btnHeight),
        getgenv().autoJumpEnabled and "Auto Jump: On" or "Auto Jump: Off"
    )
    
    clicker.MouseButton1Click:Connect(function()
        getgenv().autoJumpEnabled = not getgenv().autoJumpEnabled
        featureStates.Bhop = getgenv().autoJumpEnabled
        
        if btn:FindFirstChild("TextLabel") then
            btn.TextLabel.Text = getgenv().autoJumpEnabled and "Auto Jump: On" or "Auto Jump: Off"
        end
        
        if Options.BhopToggle then
            Options.BhopToggle:SetValue(getgenv().autoJumpEnabled)
        end
        
        checkBhopState() 
    end)
    
    return bhopButtonScreenGui
end

local function updateBhopButtonText()
    if bhopButtonScreenGui and bhopButtonScreenGui:FindFirstChild("GradientBtn") then
        local button = bhopButtonScreenGui:FindFirstChild("GradientBtn")
        if button and button:FindFirstChild("TextLabel") then
            button.TextLabel.Text = getgenv().autoJumpEnabled and "Auto Jump: On" or "Auto Jump: Off"
        end
    end
end

local function setupJumpButton()
    local success, err = pcall(function()
        local touchGui = player:WaitForChild("PlayerGui", 5):WaitForChild("TouchGui", 5)
        if not touchGui then return end
        local touchControlFrame = touchGui:WaitForChild("TouchControlFrame", 5)
        if not touchControlFrame then return end
        local jumpButton = touchControlFrame:WaitForChild("JumpButton", 5)
        if not jumpButton then return end
        
        jumpButton.MouseButton1Down:Connect(function()
            if featureStates.BhopHold then
                getgenv().bhopHoldActive = true
                checkBhopState()
            end
        end)
        
        jumpButton.MouseButton1Up:Connect(function()
            getgenv().bhopHoldActive = false
            checkBhopState()
        end)
    end)
end

AutoJumpTypeDropdown = MiscTab:AddDropdown("AutoJumpTypeDropdown", {
    Title = "Auto Jump Type",
    Values = {"Bounce", "Realistic"},
    Multi = false,
    Default = "Bounce",
    Callback = function(Value)
        getgenv().autoJumpType = Value
    end
})

BhopToggle = MiscTab:AddToggle("BhopToggle", {
    Title = "Bunny Hop",
    Default = false,
    Callback = function(Value)
        featureStates.Bhop = Value
        getgenv().autoJumpEnabled = Value
        
        updateBhopButtonText()
        checkBhopState() 
    end
})

BhopHoldToggle = MiscTab:AddToggle("BhopHoldToggle", {
    Title = "Bhop Hold (Hold Space/Jump)",
    Default = false,
    Callback = function(Value)
        featureStates.BhopHold = Value
        if not Value then
            getgenv().bhopHoldActive = false
            checkBhopState() 
        end
    end
})

BhopButtonToggle = MiscTab:AddToggle("BhopButtonToggle", {
    Title = "Bhop Button GUI",
    Default = false,
    Callback = function(Value)
        if Value then
            createBhopGradientButton()
        else
            if bhopButtonScreenGui then
                bhopButtonScreenGui:Destroy()
                bhopButtonScreenGui = nil
            end
        end
    end
})

BhopKeybind = MiscTab:AddKeybind("BhopKeybind", {
    Title = "Bhop Keybind",
    Mode = "Toggle",
    Default = "B",
    ChangedCallback = function(New)
    end,
    Callback = function()
        getgenv().autoJumpEnabled = not getgenv().autoJumpEnabled
        featureStates.Bhop = getgenv().autoJumpEnabled
        
        if Options.BhopToggle then
            Options.BhopToggle:SetValue(getgenv().autoJumpEnabled)
        end
        
        updateBhopButtonText()
        checkBhopState()
    end
})

BhopModeDropdown = MiscTab:AddDropdown("BhopModeDropdown", {
    Title = "Bhop Mode",
    Values = {"Acceleration", "No Acceleration"},
    Multi = false,
    Default = "Acceleration",
    Callback = function(Value)
        getgenv().bhopMode = Value
        checkBhopState()
    end
})

BhopAccelInput = MiscTab:AddInput("BhopAccelInput", {
    Title = "Bhop Acceleration",
    Default = "-0.5",
    Placeholder = "Enter negative value (e.g., -0.5)",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and string.sub(Value, 1, 1) == "-" then
            getgenv().bhopAccelValue = num
            if getgenv().autoJumpEnabled or getgenv().bhopHoldActive then
                applyBhopFriction()
            end
        end
    end
})

JumpCooldownInput = MiscTab:AddInput("JumpCooldownInput", {
    Title = "Jump Cooldown (Seconds)",
    Default = "0.7",
    Placeholder = "Enter cooldown in seconds",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num > 0 then
            getgenv().jumpCooldown = num
        end
    end
})

RunService.Heartbeat:Connect(function()
    if not Character or not Character:IsDescendantOf(workspace) then
        Character = player.Character or player.CharacterAdded:Wait()
        if Character then
            Humanoid = Character:FindFirstChildOfClass("Humanoid")
            HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        else
            Humanoid = nil
            HumanoidRootPart = nil
        end
    end
end)

if characterConnection then
    characterConnection:Disconnect()
end
characterConnection = player.CharacterAdded:Connect(function(character)
    Character = character
    Humanoid = character:WaitForChild("Humanoid")
    HumanoidRootPart = character:WaitForChild("HumanoidRootPart")
    setupJumpButton()
    reapplyBhopOnRespawn()
end)

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.KeyCode == Enum.KeyCode.Space and featureStates.BhopHold then
        getgenv().bhopHoldActive = true
        checkBhopState() 
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then
        getgenv().bhopHoldActive = false
    end
end)

Players.PlayerRemoving:Connect(function(leavingPlayer)
    if leavingPlayer == player then
        unloadBhop()
        if bhopKeyConnection then
            bhopKeyConnection:Disconnect()
        end
        if characterConnection then
            characterConnection:Disconnect()
        end
    end
end)

task.spawn(function()
    task.wait(1)
    if Options.BhopButtonToggle and Options.BhopButtonToggle.Value then
        createBhopGradientButton()
    end
end)
MiscTab:AddSection("Utilities")

local lagSwitchEnabled = false
local lagSwitchKeybindValue = "F12"
local lagDelayValue = 0.1
local lagIntensity = 1000000
local lagSwitchMode = "Normal" -- "Normal" или "Demon"
local isLagActive = false

-- Обычный режим лаг свича (математические операции)
local function performMathLag()
    local startTime = tick()
    local duration = lagDelayValue
    
    while tick() - startTime < duration do
        for i = 1, lagIntensity do
            local a = math.random(1, 1000000) * math.random(1, 1000000)
            a = a / math.random(1, 10000)
            local b = math.sqrt(math.random(1, 1000000))
            b = b * math.pi * math.exp(1)
            local c = math.sin(math.rad(math.random(1, 360))) * math.cos(math.rad(math.random(1, 360)))
        end
    end
end

-- Демон режим: лаг + подъем игрока
local function performDemonLag()
    local startTime = tick()
    local duration = lagDelayValue
    
    -- Получаем текущее значение из поля ввода или глобальной переменной
    local currentHeightInput = Options.DemonRiseHeightInput and Options.DemonRiseHeightInput.Value or "100"
    local currentSpeedInput = Options.DemonRiseSpeedInput and Options.DemonRiseSpeedInput.Value or "80"
    
    local RISE_HEIGHT = tonumber(currentHeightInput) or 10
    local BOOST_SPEED = tonumber(currentSpeedInput) or 80
    
    print(string.format("Демон режим: высота = %dм, скорость = %d", RISE_HEIGHT, BOOST_SPEED))
    
    -- Часть 1: Выполняем математический лаг
    task.spawn(function()
        local startLagTime = tick()
        while tick() - startLagTime < duration do
            for i = 1, math.floor(lagIntensity / 2) do
                local a = math.random(1, 1000000) * math.random(1, 1000000)
                a = a / math.random(1, 10000)
                local b = math.sqrt(math.random(1, 1000000))
                b = b * math.pi * math.exp(1)
            end
        end
    end)
    
    -- Часть 2: Подъем игрока
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character
    
    if character then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")
        
        if humanoidRootPart and humanoid then
            -- Сохраняем начальную высоту
            local startHeight = humanoidRootPart.Position.Y
            
            -- Используем BodyThrust для подъема
            local bodyThrust = Instance.new("BodyThrust")
            bodyThrust.Name = "DemonRiseThrust"
            bodyThrust.Force = Vector3.new(0, BOOST_SPEED * 500, 0)  -- Нормальная сила
            bodyThrust.Location = Vector3.new(0, 0, 0)
            bodyThrust.Parent = humanoidRootPart
            
            -- Добавляем BodyVelocity для контроля
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.Name = "DemonRiseVelocity"
            bodyVelocity.MaxForce = Vector3.new(0, 500000, 0)  -- Нормальная сила
            bodyVelocity.Velocity = Vector3.new(0, BOOST_SPEED, 0)
            bodyVelocity.Parent = humanoidRootPart
            
            -- Ждем пока поднимется на нужную высоту
            local waitTime = 0
            local maxWaitTime = 5  -- Максимальное время ожидания в секундах
            
            while waitTime < maxWaitTime do
                local currentHeight = humanoidRootPart.Position.Y
                local heightGained = currentHeight - startHeight
                
                if heightGained >= RISE_HEIGHT then
                    break
                end
                
                task.wait(0.1)
                waitTime = waitTime + 0.1
            end
            
            -- Убираем силы
            if bodyThrust then
                bodyThrust:Destroy()
            end
            if bodyVelocity then
                bodyVelocity:Destroy()
            end
            
            -- Проверяем результат
            local finalHeight = humanoidRootPart.Position.Y
            local heightGained = finalHeight - startHeight
            print(string.format("Демон режим: поднято на %.1f метров (цель: %.1f м)", heightGained, RISE_HEIGHT))
            
            Fluent:Notify({
                Title = "Demon Mode",
                Content = string.format("Lifted %.1f meters", heightGained),
                Duration = 3
            })
        end
    end
    
    isLagActive = false
end

local function toggleLagSwitch()
    if not isLagActive then
        isLagActive = true
        
        if lagSwitchMode == "Normal" then
            task.spawn(function()
                performMathLag()
                isLagActive = false
            end)
        elseif lagSwitchMode == "Demon" then
            task.spawn(function()
                performDemonLag()
                isLagActive = false
            end)
        end
    end
end

-- Инициализируем значения по умолчанию для демон режима
getgenv().DemonRiseHeight = 10  -- 100 метров по умолчанию
getgenv().DemonRiseSpeed = 80
getgenv().DemonSoftLanding = true

-- ==================== UI ELEMENTS FOR LAG SWITCH ====================

-- Функция для создания кнопки GUI
local function createLagSwitchButton()
    local CoreGui = game:GetService("CoreGui")
    local existingScreenGui = CoreGui:FindFirstChild("LagSwitchButtonGUI")
    
    if existingScreenGui then
        existingScreenGui:Destroy()
    else
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "LagSwitchButtonGUI"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = CoreGui
        
        local buttonSize = 190
        local btnWidth = math.max(150, math.min(buttonSize, 400))
        local btnHeight = math.max(60, math.min(buttonSize * 0.4, 160))
        
        local btn, clicker, stroke = createGradientButton(
            screenGui,
            UDim2.new(0.5, -btnWidth/2, 0.5, 1),
            UDim2.new(0, btnWidth, 0, btnHeight),
            "Lag Switch"
        )
        
        clicker.MouseButton1Click:Connect(function()
            if lagSwitchEnabled then
                toggleLagSwitch()
            end
        end)
    end
end

-- Добавь эту функцию сразу после объявления переменных и перед созданием UI элементов

-- Основной тумблер для включения Lag Switch
LagSwitchToggle = MiscTab:AddToggle("LagSwitchToggle", {
    Title = "Lag Switch",
    Default = false,
    Callback = function(Value)
        lagSwitchEnabled = Value
    end
})

-- Выбор режима
LagSwitchModeDropdown = MiscTab:AddDropdown("LagSwitchModeDropdown", {
    Title = "Lag Switch Mode",
    Values = {"Normal", "Demon"},
    Multi = false,
    Default = "Normal",
    Callback = function(Value)
        lagSwitchMode = Value
    end
})

-- Настройки задержки
LagDelayInput = MiscTab:AddInput("LagDelayInput", {
    Title = "Lag Delay (Seconds)",
    Default = "0.1",
    Placeholder = "Enter delay in seconds (0.1-5)",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num > 0 and num <= 5 then
            lagDelayValue = num
        end
    end
})

-- Настройки интенсивности
LagIntensityInput = MiscTab:AddInput("LagIntensityInput", {
    Title = "Lag Intensity",
    Default = "1000000",
    Placeholder = "Enter intensity (1000-10000000)",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num >= 1000 and num <= 10000000 then
            lagIntensity = num
        end
    end
})

-- Настройки для демон режима
DemonRiseHeightInput = MiscTab:AddInput("DemonRiseHeightInput", {
    Title = "Demon Rise Height (meters)",
    Default = "10",
    Placeholder = "Enter rise height in meters (10-500)",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num >= 10 and num <= 500 then
            getgenv().DemonRiseHeight = num
            Fluent:Notify({
                Title = "Demon Mode",
                Content = string.format("Rise height set to %d meters", num),
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Demon Mode",
                Content = "Height must be between 10 and 500 meters",
                Duration = 3
            })
        end
    end
})

DemonRiseSpeedInput = MiscTab:AddInput("DemonRiseSpeedInput", {
    Title = "Demon Rise Speed",
    Default = "80",
    Placeholder = "Enter rise speed (20-200)",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num >= 20 and num <= 200 then
            getgenv().DemonRiseSpeed = num
            Fluent:Notify({
                Title = "Demon Mode",
                Content = string.format("Rise speed set to %d", num),
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Demon Mode",
                Content = "Speed must be between 20 and 200",
                Duration = 3
            })
        end
    end
})


LagSwitchButtonToggle = MiscTab:AddToggle("LagSwitchButtonToggle", {
    Title = "Lag Switch Button",
    Default = false,
    Callback = function(Value)
        if Value then
            createLagSwitchButton()
        else
            local CoreGui = game:GetService("CoreGui")
            local existingScreenGui = CoreGui:FindFirstChild("LagSwitchButtonGUI")
            if existingScreenGui then
                existingScreenGui:Destroy()
            end
        end
    end
})

LagSwitchKeybind = MiscTab:AddKeybind("LagSwitchKeybind", {
    Title = "Lag Switch Keybind",
    Mode = "Toggle",
    Default = "F12",
    ChangedCallback = function(New)
        lagSwitchKeybindValue = New
        
        local CoreGui = game:GetService("CoreGui")
        local screenGui = CoreGui:FindFirstChild("LagSwitchButtonGUI")
        if screenGui then
            local button = screenGui:FindFirstChild("GradientBtn")
            if button and button:FindFirstChild("TextLabel") then
                button.TextLabel.Text = "Lag Switch"
            end
        end
    end,
    Callback = function()
        if lagSwitchEnabled then
            toggleLagSwitch()
        end
    end
})

LagSwitchKeybind:OnChanged(function()
    if Options.LagSwitchButtonToggle and Options.LagSwitchButtonToggle.Value then
        local CoreGui = game:GetService("CoreGui")
        local screenGui = CoreGui:FindFirstChild("LagSwitchButtonGUI")
        if screenGui then
            local button = screenGui:FindFirstChild("GradientBtn")
            if button and button:FindFirstChild("TextLabel") then
                button.TextLabel.Text = "Lag Switch"
            end
        end
    end
end)

LagSwitchScaleInput = MiscTab:AddInput("LagSwitchScaleInput", {
    Title = "Lag Switch Button Scale",
    Default = "1.0",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        if Value and tonumber(Value) then
            local scale = tonumber(Value)
            local CoreGui = game:GetService("CoreGui")
            local existingScreenGui = CoreGui:FindFirstChild("LagSwitchButtonGUI")
            
            if existingScreenGui then
                local button = existingScreenGui:FindFirstChild("GradientBtn")
                if button then
                    local uiScale = button:FindFirstChild("UIScale") or Instance.new("UIScale")
                    uiScale.Scale = math.max(0.5, math.min(scale, 3.0))
                    uiScale.Parent = button
                end
            end
        end
    end
})

-- Автоматически устанавливаем значение в поле ввода при загрузке
task.spawn(function()
    task.wait(1)
    if DemonRiseHeightInput then
        DemonRiseHeightInput:SetValue("100")
    end
    if DemonRiseSpeedInput then
        DemonRiseSpeedInput:SetValue("80")
    end
    if DemonSoftLandingToggle then
        DemonSoftLandingToggle:SetValue(true)
    end
end)

-- Обновляем описание для демон режима
MiscTab:AddParagraph({
    Title = "Demon Mode Features",
    Content = "Demon mode combines lag switch with character elevation. Default height: 100 meters. You can adjust height and speed settings."
})

MiscTab:AddSection("Camera Adjustments")

local cameraStretchConnection = nil
local stretchHorizontal = 0.80
local stretchVertical = 0.80

local function setupCameraStretch()
    if cameraStretchConnection then 
        cameraStretchConnection:Disconnect() 
        cameraStretchConnection = nil
    end
    
    cameraStretchConnection = game:GetService("RunService").RenderStepped:Connect(function()
        local Camera = workspace.CurrentCamera
        if Camera then
            Camera.CFrame = Camera.CFrame * CFrame.new(0, 0, 0, stretchHorizontal, 0, 0, 0, stretchVertical, 0, 0, 0, 1)
        end
    end)
end

CameraStretchToggle = MiscTab:AddToggle("CameraStretchToggle", {
    Title = "Camera Stretch",
    Default = false,
    Callback = function(Value)
        if Value then
            setupCameraStretch()
        else
            if cameraStretchConnection then
                cameraStretchConnection:Disconnect()
                cameraStretchConnection = nil
            end
        end
    end
})

CameraStretchHorizontalInput = MiscTab:AddInput("CameraStretchHorizontalInput", {
    Title = "Camera Stretch Horizontal",
    Default = "0.80",
    Placeholder = "Enter horizontal stretch value",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            stretchHorizontal = num
            if Options.CameraStretchToggle and Options.CameraStretchToggle.Value then
                setupCameraStretch()
            end
        end
    end
})

CameraStretchVerticalInput = MiscTab:AddInput("CameraStretchVerticalInput", {
    Title = "Camera Stretch Vertical",
    Default = "0.80",
    Placeholder = "Enter vertical stretch value",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            stretchVertical = num
            if Options.CameraStretchToggle and Options.CameraStretchToggle.Value then
                setupCameraStretch()
            end
        end
    end
})
MiscTab:AddSection("Client Modification")

FullBrightToggle = MiscTab:AddToggle("FullBrightToggle", {
    Title = "Full Bright",
    Default = false,
    Callback = function(state)
        featureStates.FullBright = state
        if state then
            local Lighting = game:GetService("Lighting")
            
            featureStates.originalBrightness = Lighting.Brightness
            featureStates.originalAmbient = Lighting.Ambient
            featureStates.originalOutdoorAmbient = Lighting.OutdoorAmbient
            featureStates.originalColorShiftBottom = Lighting.ColorShift_Bottom
            featureStates.originalColorShiftTop = Lighting.ColorShift_Top
            
            local function applyFullBright()
                if Lighting.Brightness ~= 1 then
                    Lighting.Brightness = 1
                end
                if Lighting.Ambient ~= Color3.new(1, 1, 1) then
                    Lighting.Ambient = Color3.new(1, 1, 1)
                end
                if Lighting.OutdoorAmbient ~= Color3.new(1, 1, 1) then
                    Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
                end
                if Lighting.ColorShift_Bottom ~= Color3.new(1, 1, 1) then
                    Lighting.ColorShift_Bottom = Color3.new(1, 1, 1)
                end
                if Lighting.ColorShift_Top ~= Color3.new(1, 1, 1) then
                    Lighting.ColorShift_Top = Color3.new(1, 1, 1)
                end
            end
            
            applyFullBright()
            
            if featureStates.fullBrightConnection then
                featureStates.fullBrightConnection:Disconnect()
            end
            
            featureStates.fullBrightConnection = RunService.Heartbeat:Connect(function()
                if featureStates.FullBright then
                    applyFullBright()
                end
            end)
            
            featureStates.fullBrightCharConnection = game.Players.LocalPlayer.CharacterAdded:Connect(function()
                task.wait(1)
                if featureStates.FullBright then
                    applyFullBright()
                end
            end)
            
        else
            if featureStates.fullBrightConnection then
                featureStates.fullBrightConnection:Disconnect()
                featureStates.fullBrightConnection = nil
            end
            
            if featureStates.fullBrightCharConnection then
                featureStates.fullBrightCharConnection:Disconnect()
                featureStates.fullBrightCharConnection = nil
            end
            
            if featureStates.originalBrightness then
                local Lighting = game:GetService("Lighting")
                Lighting.Brightness = featureStates.originalBrightness
                Lighting.Ambient = featureStates.originalAmbient
                Lighting.OutdoorAmbient = featureStates.originalOutdoorAmbient
                Lighting.ColorShift_Bottom = featureStates.originalColorShiftBottom
                Lighting.ColorShift_Top = featureStates.originalColorShiftTop
            end
        end
    end
})

AntiLag1 = MiscTab:AddButton({
    Title = "Anti lag 1",
    Callback = function()
        local Lighting = game:GetService("Lighting")
        local Terrain = workspace:FindFirstChildOfClass("Terrain")
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer

        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1e10
        Lighting.Brightness = 1

        if Terrain then
            Terrain.WaterWaveSize = 0
            Terrain.WaterWaveSpeed = 0
            Terrain.WaterReflectance = 0
            Terrain.WaterTransparency = 1
        end

        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.Material = Enum.Material.Plastic
                obj.Reflectance = 0
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj:Destroy()
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                obj:Destroy()
            elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
                obj:Destroy()
            end
        end

        for _, player in ipairs(Players:GetPlayers()) do
            local char = player.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("Accessory") or part:IsA("Clothing") then
                        part:Destroy()
                    end
                end
            end
        end
    end
})

AntiLag2 = MiscTab:AddButton({
    Title = "Anti lag 2",
    Callback = function()
        local ToDisable = {
            Textures = true,
            VisualEffects = true,
            Parts = true,
            Particles = true,
            Sky = true
        }

        local ToEnable = {
            FullBright = false
        }

        local Stuff = {}

        for _, v in next, game:GetDescendants() do
            if ToDisable.Parts then
                if v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("BasePart") then
                    v.Material = Enum.Material.SmoothPlastic
                    table.insert(Stuff, 1, v)
                end
            end
            
            if ToDisable.Particles then
                if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Explosion") or v:IsA("Sparkles") or v:IsA("Fire") then
                    v.Enabled = false
                    table.insert(Stuff, 1, v)
                end
            end
            
            if ToDisable.VisualEffects then
                if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("SunRaysEffect") then
                    v.Enabled = false
                    table.insert(Stuff, 1, v)
                end
            end
            
            if ToDisable.Textures then
                if v:IsA("Decal") or v:IsA("Texture") then
                    v.Texture = ""
                    table.insert(Stuff, 1, v)
                end
            end
            
            if ToDisable.Sky then
                if v:IsA("Sky") then
                    v.Parent = nil
                    table.insert(Stuff, 1, v)
                end
            end
        end

        if ToEnable.FullBright then
            local Lighting = game:GetService("Lighting")
            
            Lighting.FogColor = Color3.fromRGB(255, 255, 255)
            Lighting.FogEnd = math.huge
            Lighting.FogStart = math.huge
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = 5
            Lighting.ColorShift_Bottom = Color3.fromRGB(255, 255, 255)
            Lighting.ColorShift_Top = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            Lighting.Outlines = true
        end
    end 
})

AntiLag3 = MiscTab:AddButton({
    Title = "Remove Texture",
    Callback = function()
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("Part") or part:IsA("MeshPart") or part:IsA("UnionOperation") or part:IsA("WedgePart") or part:IsA("CornerWedgePart") then
                if part:IsA("Part") then
                    part.Material = Enum.Material.SmoothPlastic
                end
                if part:FindFirstChildWhichIsA("Texture") then
                    local texture = part:FindFirstChildWhichIsA("Texture")
                    texture.Texture = "rbxassetid://0"
                end
                if part:FindFirstChildWhichIsA("Decal") then
                    local decal = part:FindFirstChildWhichIsA("Decal")
                    decal.Texture = "rbxassetid://0"
                end
            end
        end
    end
})

NoFogToggle = MiscTab:AddToggle("NoFogToggle", {
    Title = "Remove fog",
    Default = false,
    Callback = function(state)
        local Lighting = game:GetService("Lighting")
        if state then
            featureStates.originalFogEnd = Lighting.FogEnd
            featureStates.originalAtmospheres = {}
            
            for _, atmosphere in ipairs(Lighting:GetChildren()) do
                if atmosphere:IsA("Atmosphere") then
                    table.insert(featureStates.originalAtmospheres, atmosphere:Clone())
                end
            end
            
            Lighting.FogEnd = 1000000
            for _, v in pairs(Lighting:GetDescendants()) do
                if v:IsA("Atmosphere") then
                    v:Destroy()
                end
            end
        else
            if featureStates.originalFogEnd then
                Lighting.FogEnd = featureStates.originalFogEnd
            end
            
            if featureStates.originalAtmospheres then
                for _, atmosphere in ipairs(featureStates.originalAtmospheres) do
                    if not atmosphere.Parent then
                        local newAtmosphere = Instance.new("Atmosphere")
                        for _, prop in pairs({"Density", "Offset", "Color", "Decay", "Glare", "Haze"}) do
                            if atmosphere[prop] then
                                newAtmosphere[prop] = atmosphere[prop]
                            end
                        end
                        newAtmosphere.Parent = Lighting
                    end
                end
            end
        end
    end
})

local SettingsTab = Window:AddTab({ Title = "Settings", Icon = "settings" })

SettingsTab:AddSection("Configuration")

-- ==================== FPS TIMER SETTINGS ====================

SettingsTab:AddSection("FPS Timer Settings")

local FPSTimerToggle = SettingsTab:AddToggle("FPSTimerToggle", {
    Title = "Show FPS Timer",
    Description = "Display FPS and session timer",
    Default = true,
    Callback = function(state)
        local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
        local timerGUI = PlayerGui:FindFirstChild("DraconicFPS")
        
        if state then
            -- Включаем
            if not timerGUI then
                createSimpleTimer()
            else
                timerGUI.Enabled = true
            end
        else
            -- Выключаем
            if timerGUI then
                timerGUI.Enabled = false
            end
        end
    end
})

SettingsTab:AddButton({
    Title = "Save Configuration",
    Description = "Save current settings to config file",
    Callback = function()
        SaveManager:Save()
        Fluent:Notify({
            Title = "Settings",
            Content = "Configuration saved successfully!",
            Duration = 3
        })
    end
})

SettingsTab:AddButton({
    Title = "Load Configuration",
    Description = "Load settings from config file",
    Callback = function()
        SaveManager:Load()
        Fluent:Notify({
            Title = "Settings",
            Content = "Configuration loaded successfully!",
            Duration = 3
        })
    end
})

SettingsTab:AddButton({
    Title = "Reset Configuration",
    Description = "Reset all settings to default",
    Callback = function()
        Window:Dialog({
            Title = "Reset Configuration",
            Content = "Are you sure you want to reset all settings to default?",
            Buttons = {
                {
                    Title = "Confirm",
                    Callback = function()
                        SaveManager:Reset()
                        Fluent:Notify({
                            Title = "Settings",
                            Content = "Configuration reset to default!",
                            Duration = 3
                        })
                    end
                },
                {
                    Title = "Cancel",
                    Callback = function()
                        print("Reset cancelled.")
                    end
                }
            }
        })
    end
})

SettingsTab:AddParagraph({
    Title = "Auto Load",
    Content = "The configuration will automatically load when the script starts."
})

SettingsTab:AddSection("Interface Manager")
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:SetFolder("DraconicXEvade")
InterfaceManager:BuildInterfaceSection(SettingsTab)

SettingsTab:AddSection("Save Manager")
SaveManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
SaveManager:SetFolder("DraconicXEvade/Config")
SaveManager:BuildConfigSection(SettingsTab)

task.spawn(function()
    task.wait(1)
    SaveManager:LoadAutoloadConfig()
end)

-- Добавляем новую вкладку Event, если её ещё нет

local InfoTab = Window:AddTab({ Title = "Info", Icon = "help-circle" })

InfoTab:AddSection("Information")

InfoTab:AddParagraph({
    Title = "Telegram Support",
    Content = "Join our Telegram channel for updates and support"
})

InfoTab:AddButton({
    Title = "Copy Telegram Link",
    Description = "Click to copy Telegram link to clipboard",
    Callback = function()
        local telegramLink = "https://t.me/DraconicHub"
        
        -- Копирование в буфер обмена
        setclipboard(telegramLink)
        
        Fluent:Notify({
            Title = "Telegram",
            Content = "Link copied to clipboard!",
            Duration = 3
        })
    end
})

Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()
https://raw.githubusercontent.com/xilodasss/xilodas/refs/heads/main/Esp.lua(game:HttpGet('https://raw.githubusercontent.com/xilodasss/xilodas/refs/heads/main/TimerGUI.lua'))()

local function createSimpleTimer()
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local UserInputService = game:GetService("UserInputService")
    local StatsService = game:GetService("Stats")
    
    -- Создаём GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DraconicFPS"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 147, 0, 40) -- Увеличили ширину для пинга
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundTransparency = 0.7
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    -- Добавляем возможность перетаскивания
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    -- Функция для начала перетаскивания
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, 
                                   startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    -- Обработчики событий для перетаскивания
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            -- Подсветка при перетаскивании
            frame.BackgroundTransparency = 0.5
            
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    frame.BackgroundTransparency = 0.7
                    connection:Disconnect()
                end
            end)
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    -- Обработка перемещения мыши/тача
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input == dragInput or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    
    -- Тексты FPS, Ping и таймера
    local statsText = Instance.new("TextLabel")
    statsText.Size = UDim2.new(1, -10, 0.5, 0)
    statsText.Position = UDim2.new(0, 5, 0, 0)
    statsText.BackgroundTransparency = 1
    statsText.TextColor3 = Color3.new(1, 1, 1) -- Белый цвет для всего текста
    statsText.Font = Enum.Font.GothamBold
    statsText.TextSize = 14
    statsText.TextXAlignment = Enum.TextXAlignment.Center
    statsText.Text = "FPS: 60 | Ping: 0ms"
    statsText.Parent = frame
    
    local timerText = Instance.new("TextLabel")
    timerText.Size = UDim2.new(1, -10, 0.5, 0)
    timerText.Position = UDim2.new(0, 5, 0.5, 0)
    timerText.BackgroundTransparency = 1
    timerText.TextColor3 = Color3.new(1, 1, 1)
    timerText.Font = Enum.Font.GothamBold
    timerText.TextSize = 14
    timerText.TextXAlignment = Enum.TextXAlignment.Center
    timerText.Text = "Client Time: 0h 0m 0s"
    timerText.Parent = frame
    
    -- Таймер для обновления
    local startTime = tick()
    local frameCount = 0
    local lastUpdate = tick()
    local currentFPS = 0
    
    -- Функция для получения пинга
    local function getPing()
        local ping = 0
        
        -- Метод 1: Через Stats (стандартный метод Roblox)
        pcall(function()
            local stats = StatsService
            local networkStats = stats:FindFirstChild("Network")
            if networkStats then
                local serverStats = networkStats:FindFirstChild("ServerStatsItem")
                if serverStats then
                    ping = math.floor(serverStats:GetValue())
                end
            end
        end)
        
        -- Метод 2: Если первый не сработал, используем альтернативный
        if ping == 0 then
            pcall(function()
                -- Иногда пинг хранится в другом месте
                local performanceStats = StatsService:FindFirstChild("PerformanceStats")
                if performanceStats then
                    local pingStat = performanceStats:FindFirstChild("Ping")
                    if pingStat then
                        ping = math.floor(pingStat:GetValue())
                    end
                end
            end)
        end
        
        -- Метод 3: Запасной вариант (если оба метода не работают)
        if ping == 0 then
            ping = 50 -- Примерное значение
        end
        
        return ping
    end
    
    -- Обновление
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        
        local currentTime = tick()
        
        -- Обновляем FPS и Ping каждые 0.5 секунды
        if currentTime - lastUpdate >= 0.5 then
            -- Обновляем FPS
            currentFPS = math.floor(frameCount / (currentTime - lastUpdate))
            frameCount = 0
            lastUpdate = currentTime
            
            -- Получаем пинг
            local ping = getPing()
            
            -- Обновляем текст
            statsText.Text = string.format("FPS: %d | Ping: %dms", currentFPS, ping)
        end
        
        -- Обновляем таймер
        local elapsed = currentTime - startTime
        local hours = math.floor(elapsed / 3600)
        local minutes = math.floor((elapsed % 3600) / 60)
        local seconds = math.floor(elapsed % 60)
        
        timerText.Text = string.format("Client Time: %dh %dm %ds", hours, minutes, seconds)
    end)
    
    -- Функция для изменения позиции
    function screenGui:SetPosition(x, y)
        frame.Position = UDim2.new(0, x, 0, y)
    end
    
    -- Функция для скрытия/показа
    function screenGui:SetVisible(visible)
        screenGui.Enabled = visible
    end
    
    -- Сохраняем позицию при перезапуске персонажа
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        if not screenGui or not screenGui.Parent then
            screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end
    end)
    
    print("Draconic Timer: Created with FPS, Ping and Time display!")
    return screenGui
end

-- Автоматически создаём таймер
createSimpleTimer()
-- Автоматическое восстановление ESP при респавне
LocalPlayer.CharacterAdded:Connect(function()
    if Options.PlayerToggle and Options.PlayerToggle.Value then
        task.wait(2) -- Даем время на загрузку
        
        -- Перезагружаем ESP если оно пропало
        if ExternalESPLoaded and (not _G.ExternalESPRunning or _G.ExternalESPRunning == false) then
            Fluent:Notify({
                Title = "ESP Players",
                Content = "Restoring ESP after respawn...",
                Duration = 3
            })
            
            -- Останавливаем старый ESP если есть
            if _G.StopExternalESP then
                pcall(_G.StopExternalESP)
            end
            
            -- Загружаем заново
            local success = pcall(function()
                ExternalESP = https://raw.githubusercontent.com/xilodasss/xilodas/refs/heads/main/Esp.lua(game:HttpGet("https://raw.githubusercontent.com/xilodasss/xilodas/refs/heads/main/Esp.lua"))()
                _G.ExternalESPRunning = true
            end)
            
            if success then
                Fluent:Notify({
                    Title = "ESP Players",
                    Content = "ESP restored successfully!",
                    Duration = 3
                })
            end
        end
    end
end)

-- Автоматическое восстановление Nextbot ESP при респавне
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(2)
    
    -- Восстановление Nextbot ESP
    if Options.NextbotToggle and Options.NextbotToggle.Value then
        if ExternalNextbotESPLoaded and ExternalNextbotESP then
            if not ExternalNextbotESP.IsRunning() then
                Fluent:Notify({
                    Title = "ESP Nextbots",
                    Content = "Restoring Nextbot ESP after respawn...",
                    Duration = 3
                })
                pcall(ExternalNextbotESP.Start)
            end
        end
    end
end)

-- Очистка Nextbot ESP при выходе из игры
game:GetService("Players").LocalPlayer.CharacterRemoving:Connect(function()
    if Options.NextbotToggle and Options.NextbotToggle.Value then
        if ExternalNextbotESPLoaded and ExternalNextbotESP then
            pcall(ExternalNextbotESP.Stop)
        end
    end
end)
