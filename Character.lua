local module = {}

function module:CreateCharacter(FaceId: string)
	--============ Model ============--
	local Character = Instance.new("Model")

	--============ Humanoid ============--
	local Humanoid = Instance.new("Humanoid")
	Humanoid.Parent = Character
	Humanoid.Name = "Humanoid"
	Humanoid.MaxHealth = 100
	Humanoid.Health = 100
	Humanoid.WalkSpeed = 16
	Humanoid.JumpPower = 50
	Humanoid.RigType = Enum.HumanoidRigType.R6
	Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

	--============ HumanoidRootPart (Essential for movement) ============--
	local HumanoidRootPart = Instance.new("Part")
	HumanoidRootPart.Name = "HumanoidRootPart"
	HumanoidRootPart.Size = Vector3.new(2, 2, 1)
	HumanoidRootPart.CanCollide = true
	HumanoidRootPart.Transparency = 1
	HumanoidRootPart.TopSurface = Enum.SurfaceType.Smooth
	HumanoidRootPart.BottomSurface = Enum.SurfaceType.Smooth
	HumanoidRootPart.Material = Enum.Material.Plastic
	HumanoidRootPart.Parent = Character
	Character.PrimaryPart = HumanoidRootPart

	--============ Torso (Required for R6) ============--
	local Torso = Instance.new("Part")
	Torso.Name = "Torso"
	Torso.Size = Vector3.new(2, 2, 1)
	Torso.CanCollide = false
	Torso.Transparency = 0
	Torso.TopSurface = Enum.SurfaceType.Smooth
	Torso.BottomSurface = Enum.SurfaceType.Smooth
	Torso.Material = Enum.Material.Plastic
	Torso.Color = Color3.fromRGB(17, 17, 17)
	Torso.Parent = Character

	--============ RootJoint (Connects HumanoidRootPart to Torso) ============--
	local RootJoint = Instance.new("Motor6D")
	RootJoint.Name = "RootJoint"
	RootJoint.Part0 = HumanoidRootPart
	RootJoint.Part1 = Torso
	RootJoint.C0 = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0)
	RootJoint.C1 = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0)
	RootJoint.Parent = HumanoidRootPart

	--============ Limbs ============--
	local Head = Instance.new("Part")
	local LArm = Instance.new("Part")
	local RArm = Instance.new("Part")
	local LLeg = Instance.new("Part")
	local RLeg = Instance.new("Part")

	--============ Names ============--
	Head.Name = "Head"
	LArm.Name = "Left Arm"
	RArm.Name = "Right Arm"
	LLeg.Name = "Left Leg"
	RLeg.Name = "Right Leg"

	--============ Limb Properties ============--
	local limbProperties = {
		Size = Vector3.new(1, 2, 1),
		CanCollide = false,
		Transparency = 0,
		TopSurface = Enum.SurfaceType.Smooth,
		BottomSurface = Enum.SurfaceType.Smooth,
		Material = Enum.Material.Plastic,
		Color = Color3.fromRGB(255, 255, 255)
	}

	Head.Size = Vector3.new(2, 1, 1) -- Head is different size
	Head.CanCollide = false
	Head.Transparency = 0
	Head.TopSurface = Enum.SurfaceType.Smooth
	Head.BottomSurface = Enum.SurfaceType.Smooth
	Head.Material = Enum.Material.Plastic
	Head.Color = Color3.fromRGB(255, 255, 255)
	Head.Parent = Character
	local HeadMesh = Instance.new("SpecialMesh", Head)
	HeadMesh.MeshType = Enum.MeshType.Head
	HeadMesh.Scale = Vector3.new(1.25, 1.25, 1.25)
	local Decal = Instance.new("Decal")
	Decal.Texture = FaceId or "rbxassetid://94482736799147"
	Decal.Face = Enum.NormalId.Front
	Decal.Parent = Head

	-- Apply properties to arms and legs
	for _, limb in pairs({LArm, RArm, LLeg, RLeg}) do
		for property, value in pairs(limbProperties) do
			limb[property] = value
		end
		limb.Parent = Character
	end

	--============ Motor6Ds ============--
	local Neck = Instance.new("Motor6D")
	Neck.Name = "Neck"
	Neck.Part0 = Torso
	Neck.Part1 = Head
	Neck.C0 = CFrame.new(0, 1, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0)
	Neck.C1 = CFrame.new(0, -0.5, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0)
	Neck.Parent = Torso

	local LWeld = Instance.new("Motor6D")
	LWeld.Name = "Left Shoulder"
	LWeld.Part0 = Torso
	LWeld.Part1 = LArm
	LWeld.C0 = CFrame.new(-1, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
	LWeld.C1 = CFrame.new(0.5, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
	LWeld.Parent = Torso

	local RWeld = Instance.new("Motor6D")
	RWeld.Name = "Right Shoulder"
	RWeld.Part0 = Torso
	RWeld.Part1 = RArm
	RWeld.C0 = CFrame.new(1, 0.5, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0)
	RWeld.C1 = CFrame.new(-0.5, 0.5, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0)
	RWeld.Parent = Torso

	local LLegWeld = Instance.new("Motor6D")
	LLegWeld.Name = "Left Hip"
	LLegWeld.Part0 = Torso
	LLegWeld.Part1 = LLeg
	LLegWeld.C0 = CFrame.new(-0.5, -1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
	LLegWeld.C1 = CFrame.new(0, 1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
	LLegWeld.Parent = Torso

	local RLegWeld = Instance.new("Motor6D")
	RLegWeld.Name = "Right Hip"
	RLegWeld.Part0 = Torso
	RLegWeld.Part1 = RLeg
	RLegWeld.C0 = CFrame.new(0.5, -1, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0)
	RLegWeld.C1 = CFrame.new(0, 1, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0)
	RLegWeld.Parent = Torso

	return Character
end
return module
