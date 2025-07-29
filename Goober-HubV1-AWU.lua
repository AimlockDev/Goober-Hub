local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()

-- Vars for ESP
local espEnabled = false
local espObjects = {}
local highlightConnections = {}

-- Spinbot variables and functions
local spinbotEnabled = false
local spinConnection
local spinSpeed = math.rad(10) -- adjust for spin speed

local function startSpin()
    if spinConnection then spinConnection:Disconnect() end
    spinConnection = RunService.Heartbeat:Connect(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, spinSpeed, 0)
        end
    end)
end

local function stopSpin()
    if spinConnection then
        spinConnection:Disconnect()
        spinConnection = nil
    end
end

local function rainbowColor()
    local t = tick() * 3
    local r = math.sin(t) * 0.5 + 0.5
    local g = math.sin(t + 2) * 0.5 + 0.5
    local b = math.sin(t + 4) * 0.5 + 0.5
    return Color3.new(r, g, b)
end

local function createESP(player)
    if espObjects[player] then return end
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.new(1, 1, 1)
    highlight.OutlineColor = rainbowColor()
    highlight.OutlineTransparency = 0
    highlight.Parent = player.Character or workspace
    espObjects[player] = highlight

    player.CharacterAdded:Connect(function(character)
        highlight.Parent = character
    end)

    local conn = RunService.RenderStepped:Connect(function()
        if espEnabled and highlight.Parent then
            highlight.OutlineColor = rainbowColor()
        end
    end)
    highlightConnections[highlight] = conn
end

local function removeESP(player)
    if espObjects[player] then
        local highlight = espObjects[player]
        local conn = highlightConnections[highlight]
        if conn then conn:Disconnect() end
        highlight:Destroy()
        espObjects[player] = nil
    end
end

local function addESPForCurrentPlayers()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            createESP(player)
        end
    end
end

local function removeAllESP()
    for highlight, conn in pairs(highlightConnections) do
        conn:Disconnect()
        highlight:Destroy()
    end
    highlightConnections = {}
    espObjects = {}
end

-- Player events
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if espEnabled then
            createESP(player)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

-- Create main window
local Window = Rayfield:CreateWindow({
    Name = "Goober Hub",
    LoadingTitle = "Goober Hub",
    LoadingSubtitle = "by -AimlockDev",
    ConfigurationSaving = { Enabled = false }
})

local Tab = Window:CreateTab('Main')

-- ESP toggle
local espToggle = Tab:CreateToggle({
    Name = "Enable Rainbow ESP",
    CurrentValue = false,
    Flag = "RainbowESP",
    Callback = function(val)
        espEnabled = val
        if not val then
            removeAllESP()
        else
            addESPForCurrentPlayers()
        end
    end,
})

-- Movement sliders
local walkSpeedSlider = Tab:CreateSlider({
    Name = "WalkSpeed",
    Range = {1, 150},
    Increment = 1,
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(val)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = val
        end
    end,
})

local jumpPowerSlider = Tab:CreateSlider({
    Name = "JumpPower",
    Range = {1, 150},
    Increment = 1,
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(val)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower = val
        end
    end,
})

-- Infinite Jump toggle
local infiniteJumpEnabled = false
local infiniteJumpToggle = Tab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfiniteJump",
    Callback = function(val)
        infiniteJumpEnabled = val
    end,
})

-- Connect UserInputService to enable infinite jump
UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Spinbot toggle
local spinbotToggle = Tab:CreateToggle({
    Name = "Spinbot",
    CurrentValue = false,
    Flag = "Spinbot",
    Callback = function(val)
        if val then
            startSpin()
        else
            stopSpin()
        end
    end,
})

-- Buttons for scripts
local loadInfiniteYieldButton = Tab:CreateButton({
    Name = "Load Infinite Yield",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/edgeiy/infiniteyield/master/source"))()
    end,
})

local loadHatHubButton = Tab:CreateButton({
    Name = "Load Hat Hub (FE's & Animations)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/inkdupe/hat-scripts/refs/heads/main/updatedhathub.lua"))()
    end,
})

local loadAirhubButton = Tab:CreateButton({
    Name = "Airhub (Aimbots & Stuff)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Exunys/AirHub/main/AirHub.lua"))()
    end,
})

-- Load default values
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
    LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
    LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower = 50
end

-- Initial notification
Rayfield:Notify({
    Title = "Goober Hub",
    Content = "Welcome to Goober Hub!",
    Duration = 6.5,
})
