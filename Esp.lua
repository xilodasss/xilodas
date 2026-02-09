-- Esp.lua (постоянно работающий ESP)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Глобальные переменные
_G.ExternalESPRunning = true
local ESPInstances = {}
local ESPConnection = nil

-- Функция для полного удаления ESP (только при выключении из основного скрипта)
_G.StopExternalESP = function()
    _G.ExternalESPRunning = false
    
    -- Останавливаем соединение
    if ESPConnection then
        ESPConnection:Disconnect()
        ESPConnection = nil
    end
    
    -- Удаляем все ESP объекты
    for player, esp in pairs(ESPInstances) do
        if esp and esp.Parent then
            esp:Destroy()
        end
    end
    ESPInstances = {}
    
    print("[External ESP] Stopped")
end

-- Создание ESP для игрока
local function createESP(player)
    if not _G.ExternalESPRunning or player == LocalPlayer then return end
    
    local character = player.Character
    if not character then return end
    
    local head = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
    if not head then return end
    
    -- Проверяем, нет ли уже ESP для этого игрока
    if ESPInstances[player] and ESPInstances[player].Parent then
        ESPInstances[player]:Destroy()
    end
    
    -- Создаем BillboardGui
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ExternalPlayerESP"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 120, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 1500
    billboard.Active = true
    billboard.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    billboard.Parent = head
    
    -- Текст
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = player.Name
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- Зеленый
    textLabel.TextSize = 14
    textLabel.Font = Enum.Font.RobotoMono
    textLabel.TextStrokeTransparency = 0.5
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    textLabel.Parent = billboard
    
    ESPInstances[player] = billboard
    
    return billboard
end

-- Обновление всех ESP
local function updateAllESP()
    if not _G.ExternalESPRunning then return end
    
    -- Обновляем существующие ESP
    for player, esp in pairs(ESPInstances) do
        if player and player.Character and esp and esp.Parent then
            local character = player.Character
            local head = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
            local textLabel = esp:FindFirstChildOfClass("TextLabel")
            
            if head and textLabel and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                -- Расстояние
                local distance = (head.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                
                -- Цвет в зависимости от состояния
                local textColor = Color3.fromRGB(255, 255, 255) -- Зеленый по умолчанию
                local extraText = ""
                
                if character:FindFirstChild("Revives") then
                    textColor = Color3.fromRGB(255, 255, 0) -- Желтый
                    extraText = "] [Revives"
                elseif character:GetAttribute("Downed") then
                    textColor = Color3.fromRGB(255, 0, 0) -- Красный
                    extraText = "] [Downed"
                end
                
                textLabel.Text = string.format("%s [%dm%s]", player.Name, math.floor(distance), extraText)
                textLabel.TextColor3 = textColor
            end
        else
            -- Удаляем невалидные ESP
            if esp then
                esp:Destroy()
            end
            ESPInstances[player] = nil
        end
    end
    
    -- Проверяем новых игроков
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not ESPInstances[player] and player.Character then
            createESP(player)
        end
    end
end

-- Инициализация ESP для всех игроков
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        if player.Character then
            createESP(player)
        end
        -- Ожидание появления персонажа
        player.CharacterAdded:Connect(function(character)
            task.wait(0.5)
            if _G.ExternalESPRunning then
                createESP(player)
            end
        end)
    end
end

-- Подключение для новых игроков
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function(character)
            task.wait(0.5)
            if _G.ExternalESPRunning then
                createESP(player)
            end
        end)
    end
end)

-- Очистка при выходе игрока
Players.PlayerRemoving:Connect(function(player)
    if ESPInstances[player] then
        ESPInstances[player]:Destroy()
        ESPInstances[player] = nil
    end
end)

-- Главный loop для обновления ESP
ESPConnection = RunService.Heartbeat:Connect(updateAllESP)

-- Автоматическое восстановление при респавне локального игрока
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if _G.ExternalESPRunning then
        -- Пересоздаем ESP для всех игроков
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                createESP(player)
            end
        end
    end
end)

print("[External ESP] Loaded and running")
return _G.StopExternalESP
