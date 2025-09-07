-- Universal Safety Functions
local function safeCall(func, ...)
    if type(func) == "function" then
        return func(...)
    else
        warn("Attempted to call a non-function value: " .. tostring(func))
        return nil
    end
end

local function safeFireTouch(part1, part2, state)
    if part1 and part2 and part1.Parent and part2.Parent and firetouchinterest then
        firetouchinterest(part1, part2, state)
        return true
    else
        warn("firetouchinterest failed: Missing parts or function doesn't exist")
        return false
    end
end

-- Safe Axe Getter
local function GetAxe()
    local player = game.Players.LocalPlayer
    if not player then return nil end
    
    local Inventory = player:FindFirstChild("Inventory")
    if not Inventory then
        warn("Inventory not found!")
        return nil
    end

    local axeNames = {"Strong Axe", "Good Axe", "Old Axe"}
    for _, axeName in ipairs(axeNames) do
        local axe = Inventory:FindFirstChild(axeName)
        if axe then
            return axe
        end
    end
   
    warn("No axe found in inventory!")
    return nil
end

-- Safe Killer
local function Kill(name)
    if not name or type(name) ~= "string" then
        warn("Invalid target name provided to Kill function")
        return
    end

    print("Killing ".. name)
    
    local axe = GetAxe()
    if not axe then return end

    local remote = game.ReplicatedStorage:FindFirstChild("RemoteEvents")
    local toolRemote = remote and remote:FindFirstChild("ToolDamageObject")
    if not toolRemote then
        warn("ToolDamageObject remote event not found!")
        return
    end

    local locations = {
        workspace.Map.Foliage:GetChildren(),
        workspace.Map.Landmarks:GetChildren(),
        workspace.Characters:GetChildren()
    }

    local hitArgs = {
        nil, -- will be replaced with target
        axe,
        "1_7133264797",
        CFrame.new(38.33494186401367, 4.007955074310303, 22.121450424194336, -0.8037834167480469, 5.754389675871607e-08, -0.5949220657348633, -1.82064507914248e-09, 1, 9.918493049099197e-08, 0.5949220657348633, 8.080634472662496e-08, -0.8037834167480469)
    }

    for _, location in ipairs(locations) do
        for _, v in ipairs(location) do
            if v and v.Parent and v.Name == name and v:GetAttribute("Health") and v:GetAttribute("Health") > 0 then
                hitArgs[1] = v
                task.spawn(function()
                    local hit = 0
                    repeat
                        hit += 1
                        task.wait(0.05)
                        safeCall(toolRemote.InvokeServer, toolRemote, unpack(hitArgs))
                    until not v or not v.Parent or v:GetAttribute("Health") == 0 or hit >= 150
                end)
            end
        end
    end
end

-- Safe Grabber
local function Grab(Name)
    if not Name or type(Name) ~= "string" then
        warn("Invalid item name provided to Grab function")
        return
    end

    print("Grabbing ".. Name)
    
    local player = game.Players.LocalPlayer
    if not player then return end
    
    local character = player.Character
    if not character or not character.PrimaryPart then
        warn("No character or PrimaryPart found!")
        return
    end

    local mainFire = workspace.Map.Campground.MainFire
    local fireCenter = mainFire and mainFire:FindFirstChild("Center")
    local CachedPos = fireCenter and fireCenter.CFrame or character.PrimaryPart.CFrame

    local itemsFolder = workspace:FindFirstChild("Items")
    if not itemsFolder then
        warn("Items folder not found!")
        return
    end

    for _, v in ipairs(itemsFolder:GetChildren()) do
        if v and v.Parent and v.Name == Name and v.Name ~= "Item Chest" and v:FindFirstChild("PrimaryPart") then
            -- Safe teleport and touch
            safeCall(character.SetPrimaryPartCFrame, character, v.PrimaryPart.CFrame)
            task.wait(0.1)
            
            safeFireTouch(character.PrimaryPart, v.PrimaryPart, 0)
            task.wait(0.005)
            
            safeCall(character.SetPrimaryPartCFrame, character, CachedPos)
            safeCall(v.SetPrimaryPartCFrame, v, CachedPos)
            task.wait(0.005)
        end
    end
end

-- Safe Walkspeed setter
local function setWalkSpeed(value)
    local player = game.Players.LocalPlayer
    if not player then return end
    
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    
    if humanoid then
        humanoid.WalkSpeed = value
    else
        warn("Cannot set WalkSpeed: Humanoid not found")
    end
end

-- Rayfield GUI Setup
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield", true))()
local Window = Rayfield:CreateWindow({
    Name = "Code Menu",
    LoadingTitle = "99 Nights in the Forest",
    LoadingSubtitle = "by Mr. Coder",
    ConfigurationSaving = false,
    Discord = {
        Enabled = false
    },
    KeySystem = false
})

local MainTab = Window:CreateTab("Main", 4483362458)

local AttackSection = MainTab:CreateSection("Attack (Hold Axe Out)")

MainTab:CreateButton({
    Name = "Cut Down Small Trees",
    Callback = function()
        Kill("Small Tree")
    end
})

MainTab:CreateButton({
    Name = "Cut Down Snowy Small Trees",
    Callback = function()
        Kill("Snowy Small Tree")
    end
})

MainTab:CreateButton({
    Name = "Kill Bunnys",
    Callback = function()
        Kill("Bunny")
    end
})

MainTab:CreateButton({
    Name = "Kill Wolfs",
    Callback = function()
        Kill("Wolf")
    end
})

MainTab:CreateButton({
    Name = "Kill Artic Foxs",
    Callback = function()
        Kill("Arctic Fox")
    end
})

MainTab:CreateButton({
    Name = "Kill Alpha Wolfs",
    Callback = function()
        Kill("Alpha Wolf")
    end
})

MainTab:CreateButton({
    Name = "Kill CrossBow Cultists",
    Callback = function()
        Kill("Crossbow Cultist")
    end
})

MainTab:CreateButton({
    Name = "Kill Cultists",
    Callback = function()
        Kill("Cultist")
    end
})

local GrabSection = MainTab:CreateSection("Grab")

MainTab:CreateButton({
    Name = "Grab Logs",
    Callback = function()
        Grab("Log")
    end
})

MainTab:CreateButton({
    Name = "Grab Carrots",
    Callback = function()
        Grab("Carrot")
    end
})

MainTab:CreateButton({
    Name = "Grab Morsels",
    Callback = function()
        Grab("Morsel")
    end
})

MainTab:CreateButton({
    Name = "Grab Cooked Morsels",
    Callback = function()
        Grab("Cooked Morsel")
    end
})

MainTab:CreateButton({
    Name = "Grab Steaks",
    Callback = function()
        Grab("Steak")
    end
})

MainTab:CreateButton({
    Name = "Grab Cooked Steaks",
    Callback = function()
        Grab("Cooked Steak")
    end
})

MainTab:CreateButton({
    Name = "Grab Bunny Foots",
    Callback = function()
        Grab("Bunny Foot")
    end
})

MainTab:CreateButton({
    Name = "Grab Broken Microwaves",
    Callback = function()
        Grab("Broken Microwave")
    end
})

MainTab:CreateButton({
    Name = "Grab Coin Stacks",
    Callback = function()
        Grab("Coin Stack")
    end
})

MainTab:CreateButton({
    Name = "Grab Alpha Wolf Corpses",
    Callback = function()
        Grab("Alpha Wolf Corpse")
    end
})

MainTab:CreateButton({
    Name = "Grab Berrys",
    Callback = function()
        Grab("Berry")
    end
})

MainTab:CreateButton({
    Name = "Grab Bolts",
    Callback = function()
        Grab("Bolt")
    end
})

MainTab:CreateButton({
    Name = "Grab Broken Fans",
    Callback = function()
        Grab("Broken Fan")
    end
})

MainTab:CreateButton({
    Name = "Grab Coals",
    Callback = function()
        Grab("Coal")
    end
})

MainTab:CreateButton({
    Name = "Grab Saplings",
    Callback = function()
        Grab("Sapling")
    end
})

MainTab:CreateButton({
    Name = "Grab Wolf Pelts",
    Callback = function()
        Grab("Wolf Pelt")
    end
})

MainTab:CreateButton({
    Name = "Grab Old Radios",
    Callback = function()
        Grab("Old Radio")
    end
})

MainTab:CreateButton({
    Name = "Grab Washing Machines",
    Callback = function()
        Grab("Washing Machine")
    end
})

MainTab:CreateButton({
    Name = "Grab Tyres",
    Callback = function()
        Grab("Tyre")
    end
})

local CSP
local PlayerTab = Window:CreateTab("Player", 4483362458)

PlayerTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {0, 100},
   Increment = 1,
   CurrentValue = 16,
   Flag = "Slider1",
   Callback = function(Value)
        setWalkSpeed(Value)
   end,
})

PlayerTab:CreateButton({
    Name = "Save Position",
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player and player.Character
        local humanoidRootPart = character and character.PrimaryPart
        
        if humanoidRootPart then
            CSP = humanoidRootPart.CFrame
            Rayfield:Notify({
                Title = "Position Saved",
                Content = "Current position has been saved!",
                Duration = 3,
                Image = "check"
            })
        else
            warn("Cannot save position: No character found")
        end
    end
})

PlayerTab:CreateButton({
    Name = "Goto Saved Position",
    Callback = function()
        if CSP then
            local player = game.Players.LocalPlayer
            local character = player and player.Character
            
            if character and character.PrimaryPart then
                character:SetPrimaryPartCFrame(CSP)
            else
                warn("Cannot teleport: No character found")
            end
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Save A Position First",
                Duration = 6.5,
                Image = "error"
            })
        end
    end
})

Rayfield:Notify({
    Title = "CODE MENU",
    Content = "MAKE SURE YOU WAIT AT LEAST 5 MINUTES BEFORE TELEPORTING ITEMS TO YOURSELF OR IT WON'T REPLICATE",
    Duration = 6.7,
    Image = "rewind",
})

print("99 Nights Menu Loaded Successfully!")
