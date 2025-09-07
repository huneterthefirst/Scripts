-- Functions
local function GetAxe()
    local Inventory = game.Players.LocalPlayer:WaitForChild("Inventory")
    local axeNames = {"Strong Axe", "Good Axe", "Old Axe"} -- Check in order from BEST to WORST
   
    for _, axeName in ipairs(axeNames) do
        local axe = Inventory:FindFirstChild(axeName)
        if axe then
            return axe
        end
    end
   
    warn("No axe found in inventory! You need at least an Old Axe.")
    return nil
end

local function Kill(name)
	print("Killing ".. name)
    for _, v in ipairs(workspace.Map.Foliage:GetChildren()) do
        if v.Name == name then
            local args = {
                v,
                GetAxe(),
                "1_7133264797",
                CFrame.new(38.33494186401367, 4.007955074310303, 22.121450424194336, -0.8037834167480469, 5.754389675871607e-08, -0.5949220657348633, -1.82064507914248e-09, 1, 9.918493049099197e-08, 0.5949220657348633, 8.080634472662496e-08, -0.8037834167480469)
            }
            task.spawn(function()
                local hit = 0
                repeat
                    hit += 1
                    task.wait(0.05)
                    game.ReplicatedStorage.RemoteEvents.ToolDamageObject:InvokeServer(unpack(args))
                until v:GetAttribute("Health") == 0 or hit >= 150
            end)
        end
    end

    for _, v in ipairs(workspace.Map.Landmarks:GetChildren()) do
        if v.Name == name then
            local args = {
                v,
                GetAxe(),
                "1_7133264797",
                CFrame.new(38.33494186401367, 4.007955074310303, 22.121450424194336, -0.8037834167480469, 5.754389675871607e-08, -0.5949220657348633, -1.82064507914248e-09, 1, 9.918493049099197e-08, 0.5949220657348633, 8.080634472662496e-08, -0.8037834167480469)
            }
            task.spawn(function()
                local hit = 0
                repeat
                    hit += 1
                    task.wait(0.05)
                    game.ReplicatedStorage.RemoteEvents.ToolDamageObject:InvokeServer(unpack(args))
                until v:GetAttribute("Health") == 0 or hit >= 150
            end)
        end
    end

	for _, v in ipairs(workspace.Characters:GetChildren()) do
        if v.Name == name then
            local args = {
                v,
                GetAxe(),
                "1_7133264797",
                CFrame.new(38.33494186401367, 4.007955074310303, 22.121450424194336, -0.8037834167480469, 5.754389675871607e-08, -0.5949220657348633, -1.82064507914248e-09, 1, 9.918493049099197e-08, 0.5949220657348633, 8.080634472662496e-08, -0.8037834167480469)
            }
            task.spawn(function()
                local hit = 0
                repeat
                    hit += 1
                    task.wait(0.05)
                    game.ReplicatedStorage.RemoteEvents.ToolDamageObject:InvokeServer(unpack(args))
                until v:GetAttribute("Health") == 0 or hit >= 150
            end)
        end
    end
end

local function Grab(Name)
    print("Grabbing ".. Name)
    local CachedPos = workspace.Map.Campground.MainFire.Center.CFrame
    CachedPos = game.Players.LocalPlayer.Character.PrimaryPart.CFrame

    for _, v in ipairs(workspace.Items:GetChildren()) do
        if v.Name == Name and v.Name ~= "Item Chest" then
            task.spawn(function()
				for i = 1, 15, 1 do
					-- TELEPORT TO ITEM
					game.Players.LocalPlayer.Character:SetPrimaryPartCFrame(v.PrimaryPart.CFrame)

					-- FORCE TOUCH IT (THE SECRET SAUCE)
					firetouchinterest(game.Players.LocalPlayer.Character.PrimaryPart, v.PrimaryPart, 0) -- Touch

					-- TELEPORT BACK
					game.Players.LocalPlayer.Character:SetPrimaryPartCFrame(CachedPos)
					-- YANK THE ITEM WITH US
					v:SetPrimaryPartCFrame(CachedPos)
					task.wait(0.005)
				end
			end)
        end
    end
    task.wait(5) -- let that shit replicate
    game.Players.LocalPlayer.Character:SetPrimaryPartCFrame(CachedPos)
end

-- Rayfield GUI Setup
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
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

local MainTab = Window:CreateTab("Main", 4483362458) -- optional icon ID

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
	Name = "Grab Steaks",
	Callback = function()
		Grab("Steak")
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

PlayerTab:CreateButton({
	Name = "Save Position",
	Callback = function()
		CSP = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
	end
})

PlayerTab:CreateButton({
	Name = "Goto Saved Position",
	Callback = function()
		if CSP then
			game.Players.LocalPlayer.Character:SetPrimaryPartCFrame(CSP)
		else
			Rayfield:Notify({
				Title = "Code Menu",
				Content = "Save A Position First",
				Duration = 6.5,
				Image = "rewind",
			})
		end
	end
})

Rayfield:Notify({
	Title = "Code Menu",
	Content = "Make Sure You Wait At Least 5 Minutes Before Teleporting Items To Yourself Or It Won't Replicate",
	Duration = 6.5,
	Image = "rewind",
})
