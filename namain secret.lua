local HttpService = game:GetService("HttpService")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local wind = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local REDisplaySystemMessage = RS.Packages._Index["sleitnick_net@0.2.0"].net["RE/DisplaySystemMessage"]
local coinLabel = player.PlayerGui.Events.Frame.CurrencyCounter.Counter
local rodValues = {}
local rodMap = {}
local SelectedRod = nil
local autoBuyRodEnabled = false
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

local function buyRod(int)
    pcall(function()
        RS.Packages._Index['sleitnick_net@0.2.0'].net['RF/PurchaseFishingRod']:InvokeServer(int)
    end)
end

local function getRods()
    local rods = {}
    for _, item in pairs(require(RS.Items)) do 
        if item.Data and item.Data.Type == 'Fishing Rods' and item.Price then
            table.insert(rods, {
                id = item.Data.Id,
                name = item.Data.Name,
                price = item.Price,
                tier = item.Data.Tier or 0,
                icon = item.Data.Icon
            })
        end 
    end 
    table.sort(rods, function(a, b) return a.price < b.price end)
    return rods
end

local function frmt(num)
    local f, uck = tostring(num)
    while true do 
        f, uck = string.gsub(f, "^(-?%d+)(%d%d%d)", '%1.%2')
        if uck == 0 then break end
    end 
    return f 
end

local function parseCoin(text)
    text = text:gsub(",", "")
    if text:find("K") or text:find("k") then
        local num = tonumber(text:match("[%d%.]+"))
        return num * 1000
    elseif text:find("M") or text:find("m") then
        local num = tonumber(text:match("[%d%.]+"))
        return num * 1000000
    elseif text:find("B") or text:find("b") then
        local num = tonumber(text:match("[%d%.]+"))
        return num * 1000000000
    else
        return tonumber(text) or 0
    end
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
    Icon = "terminal",
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
local shopTab = window:Tab({ Title = 'Shop', Icon = 'shopping-cart', Locked = false })
window:SelectTab(1)
Window:DisableTopbarButtons({
    "Close"
})
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

local rodSection = shopTab:Section({
    Title = 'Rods Shop',
    Icon = 'package',
    Opened = true 
})

for _, rod in ipairs(getRods()) do
    local displayText = rod.name .. " | " .. frmt(rod.price)
    table.insert(rodValues, displayText)
    rodMap[displayText] = rod
end

rodSection:Dropdown({
    Title = 'Select Rod',
    Values = rodValues,
    Value = "",
    Multi = false,
    AllowNone = true,
    Callback = function(choice)
        if choice and choice ~= "" then
            SelectedRod = rodMap[choice]
            log(true, 'SatanScript', 'Rod Selected : ' .. SelectedRod.name)
        end
    end
})

rodSection:Toggle({
    Title = 'Auto Buy Selected Rod',
    Icon = 'check',
    type = 'Checkbox',
    Callback = function(state)
        autoBuyRodEnabled = state
        log(state, 'Auto Buy', state and 'Auto Buy Rod Enabled!' or 'Auto Buy Rod Disabled!')
    end
})

rodSection:Button({
    Title = 'Buy Selected Rod',
    Locked = false,
    Callback = function()
        if not SelectedRod then
            log(false, 'SatanScript', 'Please Select A Rod First!')
            return
        end
        local currentCoin = parseCoin(coinLabel.Text)
        if currentCoin < SelectedRod.price then
            log(false, 'SatanScript', 'You Coins Are Not Enough To Buy '.. SelectedRod.name)
            return
        end
        buyRod(SelectedRod.id)
        log(true, 'SatanScript', 'Buying ' .. SelectedRod.name)
    end
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

coinLabel:GetPropertyChangedSignal("Text"):Connect(function()
    local currentCoin = parseCoin(coinLabel.Text)
    if autoBuyBaitEnabled and SelectedBait and currentCoin >= SelectedBait.price then
        buyBait(SelectedBait.id)
        log(true, 'SatanScript', 'Bought Bait : ' .. SelectedBait.name)
        task.wait(1)
    end
    if autoBuyRodEnabled and SelectedRod and currentCoin >= SelectedRod.price then
        buyRod(SelectedRod.id)
        log(true, 'SatanScript', 'Bought Rod : ' .. SelectedRod.name)
        task.wait(1)
    end
end)
