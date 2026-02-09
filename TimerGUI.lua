local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local function CreateTimerGUI()
    local MainInterface = Instance.new("ScreenGui")
    local TimerContainer = Instance.new("Frame")
    local AspectRatio = Instance.new("UIAspectRatioConstraint")
    local SizeLimit = Instance.new("UISizeConstraint")
    local TimerDisplay = Instance.new("Frame")
    local RoundedCorners = Instance.new("UICorner")
    local BorderOutline = Instance.new("UIStroke")
    local PanelBackground = Instance.new("ImageLabel")
    local BackgroundCorners = Instance.new("UICorner")
    local OverlayImage = Instance.new("ImageLabel")
    local StatusText = Instance.new("TextLabel")
    local TextGradient = Instance.new("UIGradient")
    local StatusBorder = Instance.new("UIStroke")
    local CountdownText = Instance.new("TextLabel")
    local TimerGradient = Instance.new("UIGradient")
    local CountdownBorder = Instance.new("UIStroke")

    MainInterface.Name = "MainInterface"
    MainInterface.Parent = PlayerGui
    MainInterface.ResetOnSpawn = false
    MainInterface.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    MainInterface.Enabled = true
    MainInterface.DisplayOrder = 2
    TimerContainer.Name = "TimerContainer"
    TimerContainer.Parent = MainInterface
    TimerContainer.AnchorPoint = Vector2.new(0.5, 0)
    TimerContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TimerContainer.BackgroundTransparency = 1.000
    TimerContainer.BorderColor3 = Color3.fromRGB(27, 42, 53)
    TimerContainer.Position = UDim2.new(0.5, 0, 0, 0)
    TimerContainer.Size = UDim2.new(1, 0, 1, 0)
    TimerContainer.Visible = false

    AspectRatio.Parent = TimerContainer

    SizeLimit.Parent = TimerContainer
    SizeLimit.MaxSize = Vector2.new(900, 900)

    TimerDisplay.Name = "TimerDisplay"
    TimerDisplay.Parent = TimerContainer
    TimerDisplay.AnchorPoint = Vector2.new(0.5, 0.5)
    -- ИЗМЕНЕНО: Убираем черный цвет фона и делаем фон прозрачным для градиента
    TimerDisplay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TimerDisplay.BackgroundTransparency = 1.000  -- Полностью прозрачный
    TimerDisplay.BorderColor3 = Color3.fromRGB(27, 42, 53)
    TimerDisplay.BorderSizePixel = 0
    TimerDisplay.Position = UDim2.new(0.5, 0, 0.1, 0)
    TimerDisplay.Size = UDim2.new(0.300000012, 0,0.100000001, 0)
    TimerDisplay.ZIndex = 10000

    RoundedCorners.CornerRadius = UDim.new(0, 12)
    RoundedCorners.Parent = TimerDisplay

    -- Обновленный контур: темно-красный как у Draconic Hub
    BorderOutline.Parent = TimerDisplay
    BorderOutline.Thickness = 2
    BorderOutline.Color = Color3.fromRGB(139, 0, 0)  -- Темно-красный
    BorderOutline.Transparency = 0.1

    -- СОЗДАЕМ градиентный фон вместо черного
    local BackgroundFrame = Instance.new("Frame")
    BackgroundFrame.Name = "BackgroundFrame"
    BackgroundFrame.Parent = TimerDisplay
    BackgroundFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    BackgroundFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    BackgroundFrame.BackgroundTransparency = 0  -- Полупрозрачный как у кнопок
    BackgroundFrame.BorderSizePixel = 0
    BackgroundFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    BackgroundFrame.Size = UDim2.new(1, 0, 1, 0)
    BackgroundFrame.ZIndex = 9998  -- Ниже, чем основной контейнер
    
    local BackgroundCorner = Instance.new("UICorner")
    BackgroundCorner.CornerRadius = UDim.new(0, 12)
    BackgroundCorner.Parent = BackgroundFrame
    
    -- Градиент для фона (красный-черный-красный)
    local BackgroundGradient = Instance.new("UIGradient")
    BackgroundGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(139, 0, 0)),      -- Красный
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 0, 0)),     -- Черный
        ColorSequenceKeypoint.new(1, Color3.fromRGB(139, 0, 0))      -- Красный
    }
    BackgroundGradient.Rotation = 0
    BackgroundGradient.Parent = BackgroundFrame
    
    -- Анимация вращения градиента
    local backgroundAnimation
    backgroundAnimation = RunService.RenderStepped:Connect(function(delta)
        BackgroundGradient.Rotation = (BackgroundGradient.Rotation + 90 * delta) % 360
    end)

    PanelBackground.Name = "PanelBackground"
    PanelBackground.Parent = TimerDisplay
    PanelBackground.AnchorPoint = Vector2.new(0.5, 0.5)
    PanelBackground.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    PanelBackground.BackgroundTransparency = 1.000
    PanelBackground.BorderColor3 = Color3.fromRGB(27, 42, 53)
    PanelBackground.Position = UDim2.new(0.5, 0, 0.5, 0)
    PanelBackground.Size = UDim2.new(1, 0, 1, 0)
    PanelBackground.ZIndex = 9999
    PanelBackground.Image = ""
    PanelBackground.ImageColor3 = Color3.fromRGB(255, 255, 255)
    PanelBackground.ImageTransparency = 1.000

    BackgroundCorners.CornerRadius = UDim.new(0, 12)
    BackgroundCorners.Parent = PanelBackground

    OverlayImage.Parent = TimerDisplay
    OverlayImage.AnchorPoint = Vector2.new(0.5, 0.5)
    OverlayImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    OverlayImage.BackgroundTransparency = 1.000
    OverlayImage.BorderColor3 = Color3.fromRGB(27, 42, 53)
    OverlayImage.Position = UDim2.new(0.5, 0, 0.5, 0)
    OverlayImage.Size = UDim2.new(1, 0, 1, 0)
    OverlayImage.ZIndex = 10001
    OverlayImage.Image = ""
    OverlayImage.ImageColor3 = Color3.fromRGB(255, 255, 255)
    OverlayImage.ImageTransparency = 1.000
    OverlayImage.ScaleType = Enum.ScaleType.Crop

    StatusText.Name = "StatusText"
    StatusText.Parent = TimerDisplay
    StatusText.AnchorPoint = Vector2.new(0.5, 0.5)
    StatusText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    StatusText.BackgroundTransparency = 1.000
    StatusText.BorderColor3 = Color3.fromRGB(27, 42, 53)
    StatusText.Position = UDim2.new(0.5, 0, 0.3, 0)
    StatusText.Size = UDim2.new(0.9, 0, 0.3, 0)
    StatusText.ZIndex = 10002
    StatusText.Font = Enum.Font.GothamBold
    StatusText.Text = "ROUND ACTIVE"
    StatusText.TextColor3 = Color3.fromRGB(255, 255, 255)
    StatusText.TextScaled = true
    StatusText.TextSize = 14.000
    StatusText.TextStrokeTransparency = 0.850
    StatusText.TextWrapped = true

    TextGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(220, 220, 220))}
    TextGradient.Rotation = 90
    TextGradient.Parent = StatusText

    StatusBorder.Parent = StatusText
    StatusBorder.Thickness = 1
    StatusBorder.Color = Color3.fromRGB(255, 255, 255)
    StatusBorder.Transparency = 0.7

    CountdownText.Name = "CountdownText"
    CountdownText.Parent = TimerDisplay
    CountdownText.AnchorPoint = Vector2.new(0.5, 0.5)
    CountdownText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    CountdownText.BackgroundTransparency = 1.000
    CountdownText.BorderColor3 = Color3.fromRGB(27, 42, 53)
    CountdownText.Position = UDim2.new(0.5, 0, 0.7, 0)
    CountdownText.Size = UDim2.new(0.9, 0, 0.5, 0)
    CountdownText.ZIndex = 10002
    CountdownText.Font = Enum.Font.GothamBold
    CountdownText.Text = "0:00"
    CountdownText.TextColor3 = Color3.fromRGB(255, 255, 255)
    CountdownText.TextScaled = true
    CountdownText.TextSize = 14.000
    CountdownText.TextStrokeTransparency = 0.850
    CountdownText.TextWrapped = true

    TimerGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(220, 220, 220))}
    TimerGradient.Rotation = 90
    TimerGradient.Parent = CountdownText

    CountdownBorder.Parent = CountdownText
    CountdownBorder.Thickness = 1
    CountdownBorder.Color = Color3.fromRGB(255, 255, 255)
    CountdownBorder.Transparency = 0.7

    return CountdownText, StatusText, MainInterface, TimerContainer, backgroundAnimation
end

local TimerLabel, StatusLabel, MainInterface, TimerContainer, backgroundAnimation = CreateTimerGUI()

local statsFolder = workspace:WaitForChild("Game"):WaitForChild("Stats")

local timerConnection

local function formatTime(seconds)
    if not seconds then return "0:00" end

    seconds = math.floor(tonumber(seconds) or 0)
    local minutes = math.floor(seconds / 60)
    local remainingSeconds = seconds % 60

    return string.format("%d:%02d", minutes, remainingSeconds)
end

local function setupTimerConnection()
    if timerConnection then
        timerConnection:Disconnect()
    end

    if statsFolder then
        timerConnection = statsFolder:GetAttributeChangedSignal("Timer"):Connect(function()
            local timerValue = statsFolder:GetAttribute("Timer")
            local roundStarted = statsFolder:GetAttribute("RoundStarted")

            TimerLabel.Text = formatTime(timerValue)

            TimerLabel.TextColor3 = timerValue and timerValue <= 5 and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(255, 255, 255)

            StatusLabel.Text = roundStarted and "ROUND ACTIVE" or "INTERMISSION"
        end)

        local initialTimer = statsFolder:GetAttribute("Timer")
        local initialRoundStarted = statsFolder:GetAttribute("RoundStarted")

        TimerLabel.Text = formatTime(initialTimer)
        TimerLabel.TextColor3 = initialTimer and initialTimer <= 5 and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(255, 255, 255)
        StatusLabel.Text = initialRoundStarted and "ROUND ACTIVE" or "INTERMISSION"
    end
end

setupTimerConnection()

local folderAddedConnection
folderAddedConnection = workspace.ChildAdded:Connect(function(child)
    if child.Name == "Game" then
        local gameFolder = child:WaitForChild("Stats")
        statsFolder = gameFolder
        setupTimerConnection()
    end
end)

local function cleanupTimer()
    if timerConnection then
        timerConnection:Disconnect()
        timerConnection = nil
    end
    if folderAddedConnection then
        folderAddedConnection:Disconnect()
        folderAddedConnection = nil
    end
    if backgroundAnimation then
        backgroundAnimation:Disconnect()
        backgroundAnimation = nil
    end
end

-- Автоматическая очистка анимации при удалении
TimerContainer.Destroying:Connect(function()
    if backgroundAnimation then
        backgroundAnimation:Disconnect()
        backgroundAnimation = nil
    end
end)
