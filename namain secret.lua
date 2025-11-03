local HttpService = game:GetService("HttpService")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local wind = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local REDisplaySystemMessage = RS.Packages._Index["sleitnick_net@0.2.0"].net["RE/DisplaySystemMessage"]

local autoEventEnabled = false
local savedPosition = nil
local savedCFrame = nil
local autoBackPosEnabled = false
local backPosDelay = 4
local eventStartTime = 0
local isAtEvent = false
local EventPos = Vector3.new(-1956.77, -440.03, 7388.30) 
local EventFacing = Vector3.new(-0.996, -0.000, -0.089)

local function log(state, str_t, str_c)
    wind:Notify({ Title = str_t, Content = str_c, Icon = state and 'check' or 'x', Duration = 3 })
end

local function saveCurrentPosition()
    local char = player.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    savedPosition = hrp.Position
    savedCFrame = hrp.CFrame
    return true
end

local function teleportToEvent()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.CFrame = CFrame.new(EventPos, EventPos + EventFacing)
    isAtEvent = true
    eventStartTime = tick()
end

local function backToSavedPos()
    if not savedCFrame then 
        log(false, 'SatanScript', 'No Saved Position!')
        return 
    end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.CFrame = savedCFrame
    isAtEvent = false
end

REDisplaySystemMessage.OnClientEvent:Connect(function(message)
    if autoEventEnabled then
        local lowerMsg = string.lower(message)
        if string.find(lowerMsg, "[server]") and string.find(lowerMsg, "group fishing event") then
            task.spawn(function()
                task.wait(1)
                teleportToEvent()
                log(true, 'SatanScript', 'Teleported To Event!')
            end)
        end
    end
end)

local window = wind:CreateWindow({
    Title = "Auto Event",
    Icon = "sparkles",
    Author = "SatanScript",
    Size = UDim2.fromOffset(320, 280),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 180,
    BackgroundImageTransparency = 0.42,
    HideSearchBar = true,
    ScrollBarEnabled = false
})

local eventTab = window:Tab({ Title = 'Auto Event', Icon = 'sparkles', Locked = false })

local eventSection1 = eventTab:Section({
    Title = 'Event Settings',
    Icon = 'zap',
    Opened = true
})

eventSection1:Toggle({
    Title = 'Auto Secret Event',
    Icon = 'check',
    type = 'Checkbox',
    Default = false,
    Callback = function(state)
        autoEventEnabled = state
        if state then
            log(true, 'SatanScript', 'Auto Event Enabled!')
        else
            log(false, 'SatanScript', 'Auto Event Disabled!')
        end
    end
})

local eventSection2 = eventTab:Section({
    Title = 'Position Manager',
    Icon = 'map-pin',
    Opened = true
})

eventSection2:Button({
    Title = 'Save Current Position',
    Locked = false,
    Callback = function()
        if saveCurrentPosition() then
            log(true, 'SatanScript', 'Position Saved Successfully!')
        else
            log(false, 'SatanScript', 'Failed To Save Position!')
        end
    end
})

eventSection2:Toggle({
    Title = 'Auto Back Current Position',
    Desc = 'Auto Back After Event Time',
    Icon = 'check',
    type = 'Checkbox',
    Default = false,
    Callback = function(state)
        autoBackPosEnabled = state
        if state then
            log(true, 'SatanScript', 'Auto Back Position Enabled!')
        else
            log(false, 'SatanScript', 'Auto Back Position Disabled!')
        end
    end
})

eventSection2:Input({
    Title = "Back Position Delay",
    Value = "4",
    InputIcon = "clock",
    Type = "Input",
    Placeholder = "Minutes...",
    Callback = function(input)
        local num = tonumber(input)
        if num and num > 0 then
            backPosDelay = num
            log(true, 'SatanScript', 'Delay Set To: ' .. num .. ' Minutes')
        else
            log(false, 'SatanScript', 'Invalid Number!')
        end
    end
})

local settings = eventTab:Section({
    Title = 'Window Setting',
    Icon = 'settings',
    Opened = true
})

settings:Keybind({
    Title = "Enum Key Code To Open UI",
    Desc = "Click This Shit & Punch Your Keyboard",
    Value = "S",
    Callback = function(v)
        window:SetToggleKey(Enum.KeyCode[v])
        log(true, 'SatanScript', 'Key Setted To : '.. v)
    end
})

window:SelectTab(1)
Window:DisableTopbarButtons({
    "Close"
})

task.spawn(function()
    while task.wait(1) do
        if autoBackPosEnabled and isAtEvent and eventStartTime > 0 then
            local elapsedTime = (tick() - eventStartTime) / 60
            if elapsedTime >= backPosDelay then
                backToSavedPos()
                log(true, 'SatanScript', 'Returned To Saved Position!')
                eventStartTime = 0
            end
        end
    end
end)
