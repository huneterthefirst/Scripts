-- Accessory Override Configuration
-- Change nil to a MeshId to force specific accessories to specific body parts
local AccessoryOverrides = {
    ["Head"] = nil,        -- Set to MeshId like "1923337755" to override
    ["Torso"] = "4819740796",
    ["Left Arm"] = nil,
    ["Right Arm"] = nil,
    ["Left Leg"] = nil,
    ["Right Leg"] = nil
}

local FakeCharacter

task.spawn(function()
	local Module = loadstring(game:HttpGet('https://raw.githubusercontent.com/huneterthefirst/Scripts/refs/heads/main/Character.lua'))()
	local Animations = {
		Idle = Instance.new("Animation"),
		Walk = Instance.new("Animation"),
		Jump = Instance.new("Animation"),
		Fall = Instance.new("Animation"),
		Sit = Instance.new("Animation")
	}

	local Character = Module:CreateCharacter()
	FakeCharacter = Character
	Character.Parent = workspace
	workspace.Camera.CameraSubject = Character.Humanoid
	game.Players.LocalPlayer.Character = Character

	Animations.Idle.AnimationId = "http://www.roblox.com/asset/?id=180435571"
	Animations.Walk.AnimationId = "http://www.roblox.com/asset/?id=180426354"
	Animations.Jump.AnimationId = "http://www.roblox.com/asset/?id=125750702"
	Animations.Fall.AnimationId = "http://www.roblox.com/asset/?id=180436148"
	Animations.Sit.AnimationId = "http://www.roblox.com/asset/?id=178130996"

	local Humanoid = Character:WaitForChild("Humanoid")
	local HRP = Character:WaitForChild("HumanoidRootPart")

	local IdleTrack = Humanoid:LoadAnimation(Animations.Idle)
	local WalkTrack = Humanoid:LoadAnimation(Animations.Walk)
	local JumpTrack = Humanoid:LoadAnimation(Animations.Jump)
	local FallTrack = Humanoid:LoadAnimation(Animations.Fall)
	local SitTrack = Humanoid:LoadAnimation(Animations.Sit)

	local AnimationOverride = false

	local function StopAllAnimations()
		IdleTrack:Stop()
		WalkTrack:Stop()
		JumpTrack:Stop()
		FallTrack:Stop()
		SitTrack:Stop()
	end

	local function PlayAnimation(track)
		StopAllAnimations()
		track:Play()
	end

	Humanoid.StateChanged:Connect(function(_, newState)
		AnimationOverride = true

		if newState == Enum.HumanoidStateType.Jumping then
			PlayAnimation(JumpTrack)
		elseif newState == Enum.HumanoidStateType.Seated then
			PlayAnimation(SitTrack)
		elseif newState == Enum.HumanoidStateType.Running or newState == Enum.HumanoidStateType.RunningNoPhysics then
			AnimationOverride = false
		elseif newState == Enum.HumanoidStateType.None or newState == Enum.HumanoidStateType.Physics then
			AnimationOverride = false
		else
			StopAllAnimations()
		end
	end)

	game:GetService("RunService").Heartbeat:Connect(function()
		if not AnimationOverride then
			if Humanoid.MoveDirection.Magnitude > 0 then
				if not WalkTrack.IsPlaying then
					PlayAnimation(WalkTrack)
				end
			else
				if not IdleTrack.IsPlaying then
					PlayAnimation(IdleTrack)
				end
			end
		end
	end)
end)

task.delay(5, function()
	local BodyPositions = {}
	local Connection = nil

	local function sendToVoid(player)
		setsimulationradius(math.huge, math.huge)
		local character = workspace:FindFirstChild(player.Name)
		if character then
			local root = character:FindFirstChild("HumanoidRootPart")
			if root then
				-- Get current position to maintain X and Z coordinates
				local currentPos = root.Position
				--root.CFrame = CFrame.new(FakeCharacter.HumanoidRootPart.CFrame.LookVector * 5)
				task.wait(0.7)
				character.Humanoid.Health = 0
			end
		end
	end

	local function GetAccessoryMeshId(accessory)
		local Handle = accessory:FindFirstChild("Handle")
		if Handle then
			-- Check for SpecialMesh in the Handle
			local SpecialMesh = Handle:FindFirstChildOfClass("SpecialMesh")
			if SpecialMesh then
				return SpecialMesh.MeshId
			end
			-- Check if Handle is a MeshPart
			if Handle:IsA("MeshPart") then
				return Handle.MeshId
			end
		end
		return nil
	end

	local function FindBodyPartForAccessory(accessory)
		local meshId = GetAccessoryMeshId(accessory)
		if meshId then
			print("Checking accessory with MeshId:", meshId)
			-- Check if this meshId matches any override
			for bodyPartName, overrideId in pairs(AccessoryOverrides) do
				if overrideId and string.find(meshId, overrideId) then
					print("MATCH FOUND: Override", overrideId, "->", bodyPartName)
					return bodyPartName
				end
			end
		end
		return nil
	end

	local function AddBodyPositionToHats(player)
		local character = workspace:FindFirstChild(player.Name)
		if character and FakeCharacter then
			-- Clear previous body positions
			for _, v in pairs(BodyPositions) do
				if v and v.Parent then
					v:Destroy()
				end
			end
			BodyPositions = {}
			
			local BodyParts = {}
			
			-- Get all body parts from the REAL character
			for _, Part in character:GetChildren() do
				if Part:IsA("Part") or Part:IsA("BasePart") then
					if Part.Name == "HumanoidRootPart" then continue end
					table.insert(BodyParts, Part.Name)
				end
			end

			print("Available body parts:", table.concat(BodyParts, ", "))

			for Number, Accessory in character:GetChildren() do
				if Accessory:IsA("Accessory") then
					local Handle = Accessory:FindFirstChild("Handle")
					if Handle then
						local TargetPartName = nil
						
						-- First, check if this accessory should be overridden to a specific body part
						TargetPartName = FindBodyPartForAccessory(Accessory)
						
						-- If no override found, use the default rotation system
						if not TargetPartName then
							local NewNumber = (Number % #BodyParts) + 1
							TargetPartName = BodyParts[NewNumber]
							print("No override, using rotation:", TargetPartName)
						end
						
						local TargetPart = FakeCharacter:FindFirstChild(TargetPartName)
						if TargetPart then
							local BodyPosition = Instance.new("BodyPosition")
							BodyPosition.Position = TargetPart.Position
							BodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
							BodyPosition.P = 100000
							BodyPosition.Parent = Handle
							
							-- Remove existing welds
							if Handle:FindFirstChild("AccessoryWeld") then
								Handle.AccessoryWeld:Destroy()
							end
							
							BodyPositions[TargetPartName] = {
								BodyPosition = BodyPosition,
								Handle = Handle
							}
						end
					end
				end
			end
		end
	end

	local function UpdateBodyPositions()
		local character = game.Players.LocalPlayer.Character
		if not character or not FakeCharacter then return end
		
		for Name, Data in pairs(BodyPositions) do
			if Data and Data.BodyPosition and Data.BodyPosition.Parent and Data.Handle then
				local TargetPart = character:FindFirstChild(Name)
				if TargetPart then
					-- Apply both CFrame and Position as requested
					Data.Handle.CFrame = TargetPart.CFrame
					Data.BodyPosition.Position = TargetPart.Position
				end
			end
		end
	end

	-- Initial setup
	AddBodyPositionToHats(game.Players.LocalPlayer)
	task.wait(0.8)
	sendToVoid(game.Players.LocalPlayer)

	Connection = game:GetService("RunService").RenderStepped:Connect(function(DeltaTime)
		UpdateBodyPositions()
		
		if game.Players.LocalPlayer.Character ~= FakeCharacter then
			workspace.Camera.CameraSubject = FakeCharacter.Humanoid
			game.Players.LocalPlayer.Character = FakeCharacter
			
			-- Wait for character to fully load
			task.wait()
			AddBodyPositionToHats(game.Players.LocalPlayer)
			task.wait(0.8)
			sendToVoid(game.Players.LocalPlayer)
		end
	end)
end)
