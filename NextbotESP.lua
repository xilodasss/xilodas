-- NextbotESP.lua
-- Внешний файл для Nextbot ESP из Draconic Hub

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Billboard ESP Variables
local NextbotBillboards = {}
local nextbotLoop = nil

-- Глобальные функции для управления
_G.NextbotESPRunning = false
_G.StopNextbotESP = function()
    _G.NextbotESPRunning = false
    if nextbotLoop then
        nextbotLoop:Disconnect()
        nextbotLoop = nil
    end
    clearAllNextbotESP()
end

-- Get nextbot names from ReplicatedStorage
local nextBotNames = {}
if ReplicatedStorage:FindFirstChild("NPCs") then
    for _, npc in ipairs(ReplicatedStorage.NPCs:GetChildren()) do
        table.insert(nextBotNames, npc.Name)
    end
end

function isNextbotModel(model)
    if not model or not model.Name then 
        return false 
    end
    
    -- Проверяем по списку известных Nextbot имен из ReplicatedStorage
    for _, name in ipairs(nextBotNames) do
        if model.Name == name then 
            return true 
        end
    end
    
    -- Более строгая проверка по ключевым словам
    local lowerName = model.Name:lower()
    
    -- Проверяем явные признаки Nextbot
    if lowerName:find("nextbot") or 
       lowerName:find("scp%-") or  -- Только SCP- префикс
       lowerName:find("^monster") or  -- Начинается с monster
       lowerName:find("^creep") or     -- Начинается с creep
       lowerName:find("^enemy") then   -- Начинается с enemy
        return true
    end
    
    -- Исключаем игроков (они не должны иметь такие имена)
    if Players:FindFirstChild(model.Name) then
        return false
    end
    
    -- Проверяем наличие специфичных атрибутов или тегов
    if model:GetAttribute("IsNPC") or model:GetAttribute("Nextbot") then
        return true
    end
    
    return false
end

function getDistanceFromPlayer(targetPosition)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then 
        return 0 
    end
    local distance = (targetPosition - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
    return math.floor(distance)
end

-- ==================== BILLBOARD ESP FUNCTIONS ====================

function CreateBillboardESP(Name, Part, Color, TextSize)
    if not Part then return nil end
    
    -- Если уже есть ESP, возвращаем его
    local existingESP = Part:FindFirstChild(Name)
    if existingESP then
        return existingESP
    end

    local BillboardGui = Instance.new("BillboardGui")
    local TextLabel = Instance.new("TextLabel")

    BillboardGui.Parent = Part
    BillboardGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    BillboardGui.Name = Name
    BillboardGui.AlwaysOnTop = true
    BillboardGui.LightInfluence = 1
    BillboardGui.Size = UDim2.new(0, 200, 0, 50)
    BillboardGui.StudsOffset = Vector3.new(0, 3, 0)
    BillboardGui.MaxDistance = 1000

    TextLabel.Parent = BillboardGui
    TextLabel.BackgroundTransparency = 1
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.TextScaled = false
    TextLabel.Font = Enum.Font.RobotoMono
    TextLabel.TextStrokeTransparency = 0.5
    TextLabel.TextSize = TextSize or 14
    TextLabel.TextColor3 = Color or Color3.fromRGB(255, 255, 255)
    TextLabel.Text = "Loading..."

    return BillboardGui
end

function UpdateBillboardESP(Name, Part, NameText, Color, TextSize, extraText)
    if not Part then return false end

    local esp = Part:FindFirstChild(Name)
    if esp and esp:FindFirstChildOfClass("TextLabel") then
        local label = esp:FindFirstChildOfClass("TextLabel")
        
        if Color then
            label.TextColor3 = Color
        end
        
        if TextSize then
            label.TextSize = TextSize
        end
        
        local distance = getDistanceFromPlayer(Part.Position)
        local name = NameText or Part.Parent and Part.Parent.Name or Part.Name
        label.Text = string.format("%s [%d m%s]", name, distance, extraText or "")
        
        return true
    end
    return false
end

function DestroyBillboardESP(Name, Part)
    if not Part then return false end
    
    local esp = Part:FindFirstChild(Name)
    if esp then
        esp:Destroy()
        return true
    end
    
    return false
end

-- Функция для создания fake part для модели
local function createFakePartForModel(model)
    if not model or not model:IsA("Model") then return nil end
    
    local fakePart = Instance.new("Part")
    fakePart.Name = "ESP_Anchor"
    fakePart.Size = Vector3.new(0.1, 0.1, 0.1)
    fakePart.Transparency = 1
    fakePart.CanCollide = false
    fakePart.Anchored = true
    fakePart.Parent = model
    
    -- Пытаемся позиционировать в центре модели
    if model.PrimaryPart then
        fakePart.CFrame = model.PrimaryPart.CFrame
    else
        local success, center = pcall(function()
            return model:GetBoundingBox()
        end)
        if success and center then
            fakePart.CFrame = center
        else
            -- Если не получилось, используем первую найденную часть
            local firstPart = model:FindFirstChildWhichIsA("BasePart")
            if firstPart then
                fakePart.CFrame = firstPart.CFrame
            end
        end
    end
    
    return fakePart
end

-- Основная функция сканирования некстботов
local function scanForNextbots()
    local nextbots = {}
    
    -- Ищем в Game.Players
    local playersFolder = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
    if playersFolder then
        for _, model in ipairs(playersFolder:GetChildren()) do
            if model:IsA("Model") and isNextbotModel(model) then
                nextbots[model] = model
            end
        end
    end
    
    -- Ищем в NPCs
    local npcsFolder = workspace:FindFirstChild("NPCs")
    if npcsFolder then
        for _, model in ipairs(npcsFolder:GetChildren()) do
            if model:IsA("Model") and isNextbotModel(model) then
                nextbots[model] = model
            end
        end
    end
    
    -- Обрабатываем найденных некстботов
    for model, _ in pairs(nextbots) do
        if not NextbotBillboards[model] then
            -- Создаем fake part если нужно
            local fakePart = model:FindFirstChild("ESP_Anchor")
            if not fakePart then
                fakePart = createFakePartForModel(model)
            end
            
            if fakePart then
                -- Создаем ESP
                local esp = CreateBillboardESP("NextbotESP", fakePart, Color3.fromRGB(255, 0, 0), 16)
                if esp then
                    UpdateBillboardESP("NextbotESP", fakePart, model.Name, Color3.fromRGB(255, 0, 0), 16)
                    NextbotBillboards[model] = {
                        esp = esp, 
                        part = fakePart, 
                        fakePart = true,
                        lastUpdate = tick()
                    }
                end
            end
        else
            -- Обновляем существующий ESP
            local data = NextbotBillboards[model]
            if data.part and data.part.Parent == model then
                -- Обновляем позицию fake part
                if model:IsA("Model") then
                    if model.PrimaryPart then
                        data.part.CFrame = model.PrimaryPart.CFrame
                    else
                        local success, center = pcall(function()
                            return model:GetBoundingBox()
                        end)
                        if success and center then
                            data.part.CFrame = center
                        end
                    end
                end
                
                -- Обновляем текст ESP
                UpdateBillboardESP("NextbotESP", data.part, model.Name, Color3.fromRGB(255, 0, 0), 16)
                data.lastUpdate = tick()
            else
                -- Если fake part удален, создаем новый
                local fakePart = createFakePartForModel(model)
                if fakePart then
                    data.part = fakePart
                    local esp = CreateBillboardESP("NextbotESP", fakePart, Color3.fromRGB(255, 0, 0), 16)
                    if esp then
                        UpdateBillboardESP("NextbotESP", fakePart, model.Name, Color3.fromRGB(255, 0, 0), 16)
                        data.esp = esp
                        data.lastUpdate = tick()
                    end
                end
            end
        end
    end
    
    -- Очищаем удаленных некстботов
    for model, data in pairs(NextbotBillboards) do
        if not nextbots[model] or not model.Parent then
            if data.part then
                DestroyBillboardESP("NextbotESP", data.part)
                if data.fakePart then
                    data.part:Destroy()
                end
            end
            NextbotBillboards[model] = nil
        elseif tick() - data.lastUpdate > 10 then
            -- Удаляем старые ESP (на всякий случай)
            if data.part then
                DestroyBillboardESP("NextbotESP", data.part)
                if data.fakePart then
                    data.part:Destroy()
                end
            end
            NextbotBillboards[model] = nil
        end
    end
end

-- ==================== CLEAR ESP FUNCTIONS ====================
local function clearAllNextbotESP()
    for model, data in pairs(NextbotBillboards) do
        if data.part then
            DestroyBillboardESP("NextbotESP", data.part)
            if data.fakePart then
                data.part:Destroy()
            end
        end
    end
    NextbotBillboards = {}
end

-- Функция для запуска ESP
local function startNextbotESP()
    if nextbotLoop then return end
    
    _G.NextbotESPRunning = true
    
    nextbotLoop = RunService.Heartbeat:Connect(function()
        if _G.NextbotESPRunning then
            scanForNextbots()
        end
    end)
    
    -- Немедленно запускаем сканирование
    task.spawn(function()
        for i = 1, 3 do
            scanForNextbots()
            task.wait(0.1)
        end
    end)
    
    return true
end

-- Функция для остановки ESP
local function stopNextbotESP()
    _G.NextbotESPRunning = false
    
    if nextbotLoop then
        nextbotLoop:Disconnect()
        nextbotLoop = nil
    end
    
    -- Очищаем все ESP при отключении
    clearAllNextbotESP()
    
    return true
end

-- Экспортируемые функции
return {
    Start = startNextbotESP,
    Stop = stopNextbotESP,
    ClearAll = clearAllNextbotESP,
    IsRunning = function()
        return _G.NextbotESPRunning == true
    end
}
