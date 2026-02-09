-- TicketESP.lua
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Глобальные переменные
_G.TicketESPRunning = true
local TicketESPInstances = {}

-- Функция остановки
_G.StopTicketESP = function()
    _G.TicketESPRunning = false
    
    -- Удаляем все ESP
    for _, esp in pairs(TicketESPInstances) do
        if esp and esp.Parent then
            esp:Destroy()
        end
    end
    TicketESPInstances = {}
    
    print("[Ticket ESP] Stopped")
end

-- Функция обновления
_G.UpdateTicketESP = function()
    if not _G.TicketESPRunning then return end
    
    local ticketsFound = {}
    
    -- Поиск тикетов
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
    
    -- Удаляем старые ESP
    for ticket, esp in pairs(TicketESPInstances) do
        if not ticketsFound[ticket] or not ticket.Parent then
            if esp then
                esp:Destroy()
            end
            TicketESPInstances[ticket] = nil
        end
    end
    
    -- Создаем новые ESP
    for ticket, part in pairs(ticketsFound) do
        if not TicketESPInstances[ticket] then
            -- Создаем BillboardGui
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "ExternalTicketESP"
            billboard.Adornee = part
            billboard.Size = UDim2.new(0, 100, 0, 30)
            billboard.StudsOffset = Vector3.new(0, 2, 0)
            billboard.AlwaysOnTop = true
            billboard.MaxDistance = 1000
            billboard.Parent = part
            
            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
            textLabel.TextSize = 12
            textLabel.Font = Enum.Font.RobotoMono
            textLabel.Parent = billboard
            
            local stroke = Instance.new("UIStroke")
            stroke.Color = Color3.new(0, 0, 0)
            stroke.Thickness = 2
            stroke.Parent = textLabel
            
            TicketESPInstances[ticket] = billboard
        end
        
        -- Обновляем текст
        local esp = TicketESPInstances[ticket]
        if esp and esp.Parent and esp:FindFirstChildOfClass("TextLabel") then
            local textLabel = esp:FindFirstChildOfClass("TextLabel")
            local distance = 0
            
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                distance = (part.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            end
            
            textLabel.Text = string.format("Ticket [%d m]", math.floor(distance))
        end
    end
end

-- Автоматическое обновление
local connection = RunService.Heartbeat:Connect(function()
    if _G.TicketESPRunning then
        _G.UpdateTicketESP()
    end
end)

-- Очистка при выходе
LocalPlayer.CharacterRemoving:Connect(function()
    if connection then
        connection:Disconnect()
    end
end)

print("[Ticket ESP] Loaded")
return _G.StopTicketESP
