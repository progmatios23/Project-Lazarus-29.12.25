
-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Variables
local player = Players.LocalPlayer
local scriptUrl = "https://api.junkie-development.de/api/v1/luascripts/public/3e73ebff1af450511d7cf0bda858517be15f5f269ac343792ac557701ce4a4f1/download"
local maxRetries = 7
local delayBetweenRetries = 0.07
local retryCount = 0
local scriptLoaded = false
local guiVisible = false

-- Create main screen GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoRetryGUI"
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- ============================================
-- GUI 1: Loading Status GUI (Main GUI)
-- ============================================
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Name = "LoadingFrame"
LoadingFrame.Size = UDim2.new(0, 300, 0, 150)
LoadingFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
LoadingFrame.BackgroundTransparency = 0.1
LoadingFrame.BorderSizePixel = 0
LoadingFrame.Visible = true
LoadingFrame.Parent = ScreenGui

local UICorner1 = Instance.new("UICorner")
UICorner1.CornerRadius = UDim.new(0, 8)
UICorner1.Parent = LoadingFrame

local LoadingTitle = Instance.new("TextLabel")
LoadingTitle.Name = "LoadingTitle"
LoadingTitle.Size = UDim2.new(1, 0, 0, 40)
LoadingTitle.Position = UDim2.new(0, 0, 0, 0)
LoadingTitle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
LoadingTitle.BackgroundTransparency = 0
LoadingTitle.Text = "🔄 Script Loader"
LoadingTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadingTitle.TextSize = 18
LoadingTitle.Font = Enum.Font.GothamBold
LoadingTitle.Parent = LoadingFrame

local UICorner2 = Instance.new("UICorner")
UICorner2.CornerRadius = UDim.new(0, 8)
UICorner2.Parent = LoadingTitle

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(1, -20, 0, 60)
StatusLabel.Position = UDim2.new(0, 10, 0, 50)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Checking script status...\nRetry: 0/" .. maxRetries
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.TextSize = 14
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextWrapped = true
StatusLabel.Parent = LoadingFrame

local RetryButton = Instance.new("TextButton")
RetryButton.Name = "RetryButton"
RetryButton.Size = UDim2.new(0.8, 0, 0, 35)
RetryButton.Position = UDim2.new(0.1, 0, 0, 110)
RetryButton.BackgroundColor3 = Color3.fromRGB(50, 120, 220)
RetryButton.Text = "🔄 Force Retry"
RetryButton.TextColor3 = Color3.fromRGB(255, 255, 255)
RetryButton.TextSize = 14
RetryButton.Font = Enum.Font.GothamBold
RetryButton.Parent = LoadingFrame

local UICorner3 = Instance.new("UICorner")
UICorner3.CornerRadius = UDim.new(0, 6)
UICorner3.Parent = RetryButton

-- ============================================
-- GUI 2: Script Failed GUI (No Key Entry)
-- ============================================
local FailedFrame = Instance.new("Frame")
FailedFrame.Name = "FailedFrame"
FailedFrame.Size = UDim2.new(0, 350, 0, 200)
FailedFrame.Position = UDim2.new(0.5, -175, 0.5, -100)
FailedFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
FailedFrame.BackgroundTransparency = 0.1
FailedFrame.BorderSizePixel = 0
FailedFrame.Visible = false
FailedFrame.Parent = ScreenGui

local UICorner4 = Instance.new("UICorner")
UICorner4.CornerRadius = UDim.new(0, 8)
UICorner4.Parent = FailedFrame

local FailedTitle = Instance.new("TextLabel")
FailedTitle.Name = "FailedTitle"
FailedTitle.Size = UDim2.new(1, 0, 0, 40)
FailedTitle.Position = UDim2.new(0, 0, 0, 0)
FailedTitle.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
FailedTitle.BackgroundTransparency = 0
FailedTitle.Text = "⚠️ SCRIPT FAILED"
FailedTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
FailedTitle.TextSize = 18
FailedTitle.Font = Enum.Font.GothamBold
FailedTitle.Parent = FailedFrame

local UICorner5 = Instance.new("UICorner")
UICorner5.CornerRadius = UDim.new(0, 8)
UICorner5.Parent = FailedTitle

local FailedMessage = Instance.new("TextLabel")
FailedMessage.Name = "FailedMessage"
FailedMessage.Size = UDim2.new(1, -20, 0, 80)
FailedMessage.Position = UDim2.new(0, 10, 0, 50)
FailedMessage.BackgroundTransparency = 1
FailedMessage.Text = "Script executed but GUI not showing.\nAuto-retry system activated!"
FailedMessage.TextColor3 = Color3.fromRGB(255, 255, 255)
FailedMessage.TextSize = 14
FailedMessage.Font = Enum.Font.Gotham
FailedMessage.TextWrapped = true
FailedMessage.Parent = FailedFrame

local AutoRetryButton = Instance.new("TextButton")
AutoRetryButton.Name = "AutoRetryButton"
AutoRetryButton.Size = UDim2.new(0.8, 0, 0, 35)
AutoRetryButton.Position = UDim2.new(0.1, 0, 0, 140)
AutoRetryButton.BackgroundColor3 = Color3.fromRGB(50, 180, 80)
AutoRetryButton.Text = "🔄 Auto-Retry 7 Times"
AutoRetryButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoRetryButton.TextSize = 14
AutoRetryButton.Font = Enum.Font.GothamBold
AutoRetryButton.Parent = FailedFrame

local UICorner6 = Instance.new("UICorner")
UICorner6.CornerRadius = UDim.new(0, 6)
UICorner6.Parent = AutoRetryButton

-- ============================================
-- GUI 3: "If script doesn't show up" (Retry Only)
-- ============================================
local ExtendedRetryFrame = Instance.new("Frame")
ExtendedRetryFrame.Name = "ExtendedRetryFrame"
ExtendedRetryFrame.Size = UDim2.new(0, 400, 0, 180)
ExtendedRetryFrame.Position = UDim2.new(0.5, -200, 0.5, -90)
ExtendedRetryFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
ExtendedRetryFrame.BackgroundTransparency = 0.1
ExtendedRetryFrame.BorderSizePixel = 0
ExtendedRetryFrame.Visible = false
ExtendedRetryFrame.Parent = ScreenGui

local UICorner7 = Instance.new("UICorner")
UICorner7.CornerRadius = UDim.new(0, 10)
UICorner7.Parent = ExtendedRetryFrame

local ExtendedRetryTitle = Instance.new("TextLabel")
ExtendedRetryTitle.Name = "ExtendedRetryTitle"
ExtendedRetryTitle.Size = UDim2.new(1, 0, 0, 45)
ExtendedRetryTitle.Position = UDim2.new(0, 0, 0, 0)
ExtendedRetryTitle.BackgroundColor3 = Color3.fromRGB(180, 80, 80)
ExtendedRetryTitle.BackgroundTransparency = 0
ExtendedRetryTitle.Text = "⚠️ EXTENDED RETRY"
ExtendedRetryTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
ExtendedRetryTitle.TextSize = 18
ExtendedRetryTitle.Font = Enum.Font.GothamBold
ExtendedRetryTitle.Parent = ExtendedRetryFrame

local UICorner8 = Instance.new("UICorner")
UICorner8.CornerRadius = UDim.new(0, 10)
UICorner8.Parent = ExtendedRetryTitle

local ExtendedRetryMessage = Instance.new("TextLabel")
ExtendedRetryMessage.Name = "ExtendedRetryMessage"
ExtendedRetryMessage.Size = UDim2.new(1, -20, 0, 70)
ExtendedRetryMessage.Position = UDim2.new(0, 10, 0, 55)
ExtendedRetryMessage.BackgroundTransparency = 1
ExtendedRetryMessage.Text = "Script still not showing.\nWill execute " .. maxRetries .. " times with 0.07s delay."
ExtendedRetryMessage.TextColor3 = Color3.fromRGB(255, 255, 255)
ExtendedRetryMessage.TextSize = 14
ExtendedRetryMessage.Font = Enum.Font.Gotham
ExtendedRetryMessage.TextWrapped = true
ExtendedRetryMessage.Parent = ExtendedRetryFrame

local ExtendedRetryButton = Instance.new("TextButton")
ExtendedRetryButton.Name = "ExtendedRetryButton"
ExtendedRetryButton.Size = UDim2.new(0.8, 0, 0, 35)
ExtendedRetryButton.Position = UDim2.new(0.1, 0, 0, 130)
ExtendedRetryButton.BackgroundColor3 = Color3.fromRGB(220, 120, 50)
ExtendedRetryButton.Text = "🔄 Execute " .. maxRetries .. " Times"
ExtendedRetryButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ExtendedRetryButton.TextSize = 14
ExtendedRetryButton.Font = Enum.Font.GothamBold
ExtendedRetryButton.Parent = ExtendedRetryFrame

local UICorner9 = Instance.new("UICorner")
UICorner9.CornerRadius = UDim.new(0, 6)
UICorner9.Parent = ExtendedRetryButton

-- ============================================
-- Announcement GUI (Shows every 10 seconds for 6 seconds)
-- ============================================
local AnnouncementFrame = Instance.new("Frame")
AnnouncementFrame.Name = "AnnouncementFrame"
AnnouncementFrame.Size = UDim2.new(0, 350, 0, 100)
AnnouncementFrame.Position = UDim2.new(0.5, -175, 0.1, 0)
AnnouncementFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
AnnouncementFrame.BackgroundTransparency = 0.2
AnnouncementFrame.BorderSizePixel = 0
AnnouncementFrame.Visible = false
AnnouncementFrame.Parent = ScreenGui

local UICorner10 = Instance.new("UICorner")
UICorner10.CornerRadius = UDim.new(0, 8)
UICorner10.Parent = AnnouncementFrame

local AnnouncementTitle = Instance.new("TextLabel")
AnnouncementTitle.Name = "AnnouncementTitle"
AnnouncementTitle.Size = UDim2.new(1, 0, 0, 30)
AnnouncementTitle.Position = UDim2.new(0, 0, 0, 0)
AnnouncementTitle.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
AnnouncementTitle.BackgroundTransparency = 0
AnnouncementTitle.Text = "📢 ANNOUNCEMENT"
AnnouncementTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
AnnouncementTitle.TextSize = 14
AnnouncementTitle.Font = Enum.Font.GothamBold
AnnouncementTitle.Parent = AnnouncementFrame

local UICorner11 = Instance.new("UICorner")
UICorner11.CornerRadius = UDim.new(0, 8)
UICorner11.Parent = AnnouncementTitle

local AnnouncementText = Instance.new("TextLabel")
AnnouncementText.Name = "AnnouncementText"
AnnouncementText.Size = UDim2.new(1, -20, 0, 60)
AnnouncementText.Position = UDim2.new(0, 10, 0, 35)
AnnouncementText.BackgroundTransparency = 1
AnnouncementText.Text = "After putting Key if the script doesnt show up, re-execute it!."
AnnouncementText.TextColor3 = Color3.fromRGB(255, 255, 255)
AnnouncementText.TextSize = 12
AnnouncementText.Font = Enum.Font.Gotham
AnnouncementText.TextWrapped = true
AnnouncementText.Parent = AnnouncementFrame

-- Close buttons for all GUIs
local function createCloseButton(parentFrame)
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0, 8)
    CloseButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    CloseButton.Text = "✕"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 16
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Parent = parentFrame
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 15)
    UICorner.Parent = CloseButton
    
    return CloseButton
end

local LoadingCloseButton = createCloseButton(LoadingFrame)
local FailedCloseButton = createCloseButton(FailedFrame)
local ExtendedRetryCloseButton = createCloseButton(ExtendedRetryFrame)

-- Function to check if script GUI is visible
local function isScriptGUIVisible()
    local playerGui = player:FindFirstChild("PlayerGui")
    
    if not playerGui then return false end
    
    -- Check for common GUI names
    local guiNames = {"MainGui", "Hub", "Menu", "GUI", "ScriptGUI", "Loader"}
    for _, name in ipairs(guiNames) do
        local gui = playerGui:FindFirstChild(name)
        if gui and gui:IsA("ScreenGui") and gui.Enabled then
            return true
        end
    end
    
    -- Check for any visible GUI that's not ours
    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AutoRetryGUI" then
            if gui:FindFirstChildOfClass("Frame") or gui:FindFirstChildOfClass("TextLabel") then
                return true
            end
        end
    end
    
    return false
end

-- Function to execute the script
local function executeTargetScript()
    local success, result = pcall(function()
        return loadstring(game:HttpGet(scriptUrl))()
    end)
    
    return success, result
end

-- Function to update loading status
local function updateLoadingStatus(message, retryNum)
    StatusLabel.Text = message .. "\nRetry: " .. retryNum .. "/" .. maxRetries
end

-- Function to show/hide GUIs
local function showLoadingGUI()
    LoadingFrame.Visible = true
    FailedFrame.Visible = false
    ExtendedRetryFrame.Visible = false
    guiVisible = true
end

local function showFailedGUI()
    LoadingFrame.Visible = false
    FailedFrame.Visible = true
    ExtendedRetryFrame.Visible = false
    guiVisible = true
end

local function showExtendedRetryGUI()
    LoadingFrame.Visible = false
    FailedFrame.Visible = false
    ExtendedRetryFrame.Visible = true
    guiVisible = true
end

local function hideAllGUIs()
    LoadingFrame.Visible = false
    FailedFrame.Visible = false
    ExtendedRetryFrame.Visible = false
    guiVisible = false
end

-- Function to show announcement
local function showAnnouncement()
    AnnouncementFrame.Visible = true
    task.wait(6) -- Show for 6 seconds
    AnnouncementFrame.Visible = false
end

-- Function to perform auto-retry with multiple executions
local function performMultiExecute()
    ExtendedRetryMessage.Text = "Executing script " .. maxRetries .. " times...\nPlease wait..."
    
    local successfulExecutions = 0
    
    for i = 1, maxRetries do
        ExtendedRetryMessage.Text = "Executing...\nAttempt " .. i .. "/" .. maxRetries
        
        local success, result = executeTargetScript()
        
        if success then
            successfulExecutions = successfulExecutions + 1
            ExtendedRetryMessage.Text = "✅ Execution " .. i .. " successful!\nWaiting 0.07s..."
        else
            ExtendedRetryMessage.Text = "❌ Execution " .. i .. " failed\nTrying again..."
        end
        
        if i < maxRetries then
            task.wait(delayBetweenRetries)
        end
    end
    
    -- Check if GUI appears after all executions
    task.wait(1)
    
    if isScriptGUIVisible() then
        ExtendedRetryMessage.Text = "✅ SUCCESS!\nScript GUI is now visible after " .. successfulExecutions .. " executions.\nClosing in 3 seconds..."
        task.wait(3)
        hideAllGUIs()
    else
        ExtendedRetryMessage.Text = "❌ Still not showing...\n" .. successfulExecutions .. "/" .. maxRetries .. " executions succeeded.\nTry restarting the game."
    end
end

-- Main auto-retry function
local function performAutoRetry()
    scriptLoaded = false
    retryCount = 0
    showLoadingGUI()
    
    local function attemptExecution()
        retryCount = retryCount + 1
        updateLoadingStatus("Executing script...", retryCount)
        
        local success, result = executeTargetScript()
        
        if success then
            scriptLoaded = true
            updateLoadingStatus("✅ Script executed successfully!\nChecking for GUI...", retryCount)
            
            task.wait(0.5)
            
            if isScriptGUIVisible() then
                updateLoadingStatus("✅ Script GUI detected!\nScript is working properly.", retryCount)
                task.wait(2)
                hideAllGUIs()
            else
                updateLoadingStatus("⚠️ Script executed but GUI not visible.", retryCount)
                task.wait(1)
                showFailedGUI()
            end
        else
            updateLoadingStatus("❌ Execution failed:\n" .. tostring(result):sub(1, 100), retryCount)
            
            if retryCount < maxRetries then
                task.wait(delayBetweenRetries)
                attemptExecution()
            else
                updateLoadingStatus("❌ Max retries reached.", retryCount)
                task.wait(1)
                showExtendedRetryGUI()
            end
        end
    end
    
    attemptExecution()
end

-- Button click events
RetryButton.MouseButton1Click:Connect(function()
    performAutoRetry()
end)

AutoRetryButton.MouseButton1Click:Connect(function()
    performMultiExecute()
end)

ExtendedRetryButton.MouseButton1Click:Connect(function()
    performMultiExecute()
end)

-- Close button events
LoadingCloseButton.MouseButton1Click:Connect(function()
    hideAllGUIs()
end)

FailedCloseButton.MouseButton1Click:Connect(function()
    hideAllGUIs()
end)

ExtendedRetryCloseButton.MouseButton1Click:Connect(function()
    hideAllGUIs()
end)

-- Make GUIs draggable
local function makeDraggableSimple(frame, dragButton)
    local dragging = false
    local offset
    
    dragButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            offset = frame.Position - UDim2.new(0, input.Position.X, 0, input.Position.Y)
        end
    end)
    
    dragButton.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            frame.Position = UDim2.new(0, input.Position.X, 0, input.Position.Y) + offset
        end
    end)
    
    dragButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

makeDraggableSimple(LoadingFrame, LoadingTitle)
makeDraggableSimple(FailedFrame, FailedTitle)
makeDraggableSimple(ExtendedRetryFrame, ExtendedRetryTitle)
makeDraggableSimple(AnnouncementFrame, AnnouncementTitle)

-- Announcement scheduler (shows every 10 seconds for 6 seconds)
task.spawn(function()
    while true do
        task.wait(10) -- Wait 10 seconds
        showAnnouncement()
    end
end)

-- Auto-start the process
task.wait(1)
performAutoRetry()

print("Auto-Retry System Loaded!")
print("Announcement will show every 10 seconds for 6 seconds")
