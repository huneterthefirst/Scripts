-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local function Notification(...)
    local text = table.concat({...}, " ")
    local player = game.Players.LocalPlayer
    local userId = 975659609

    local thumbnailUrl = string.format("https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=150&height=150&format=png", userId)

    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Mr. Coder",
        Text = text,
        Duration = 5,
        Icon = thumbnailUrl
    })
end

-- Global environment cleanup
if getgenv().SigmaMover then
    getgenv().SigmaMover:Destroy()
    getgenv().SigmaMover = nil
end

-- Player References
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = Workspace.CurrentCamera

-- State Variables
local ghostPart = nil
local selectedReal = nil
local controlledParts = {} -- [Part] = {CanCollide = originalValue, CollisionGroup = originalGroup}
local formationActive = false
local formationDistance = 5
local rotationAngle = 0
local rotationSpeed = 2
local wobbleAmount = 0
local gridSize = 2
local moveSpeed = 0.2
local nudgeStep = 1
local orbitTarget = nil

-- Store in global env for cleanup
getgenv().SigmaMover = {
    Destroy = function()
        -- Clean up UI
        if player.PlayerGui:FindFirstChild("SigmaMoverGUI") then
            player.PlayerGui.SigmaMoverGUI:Destroy()
        end
        
        -- Clean up ghost part
        if ghostPart then
            ghostPart:Destroy()
        end
        
        -- Restore collision
        for part, properties in pairs(controlledParts) do
            if part and part.Parent and type(properties) == "table" then
                part.CanCollide = properties.CanCollide
                part.CollisionGroup = properties.CollisionGroup
            end
        end
        
        -- Remove all BodyPositions and BodyGyros we created
        for part, _ in pairs(controlledParts) do
            if part and part.Parent then
                for _, child in ipairs(part:GetChildren()) do
                    if child:IsA("BodyPosition") or child:IsA("BodyGyro") then
                        child:Destroy()
                    end
                end
            end
        end
        
        Notification("SigmaMover cleaned up! Ready for re-injection! 💀🔥")
    end
}

-- Get character safely (only when needed)
local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

-- Get humanoid safely
local function getHumanoid()
    local char = getCharacter()
    return char:WaitForChild("Humanoid")
end

-- Get root part safely
local function getRootPart()
    local char = getCharacter()
    return char:WaitForChild("HumanoidRootPart")
end

-- Store original collision properties
local function storeCollisionProperties(part)
    if not controlledParts[part] or type(controlledParts[part]) == "boolean" then
        controlledParts[part] = {
            CanCollide = part.CanCollide,
            CollisionGroup = part.CollisionGroup
        }
    end
end

-- Enable ghost mode (no collision during spin)
local function enableGhostMode()
    for part, properties in pairs(controlledParts) do
        if part and part.Parent then
            part.CanCollide = false
            part.CollisionGroup = "Ghost"
        end
    end
end

-- Restore original collision properties
local function restoreCollision()
    for part, properties in pairs(controlledParts) do
        if part and part.Parent and type(properties) == "table" then
            part.CanCollide = properties.CanCollide
            part.CollisionGroup = properties.CollisionGroup
        end
    end
end

-- UI Setup
local function initUI()
    -- Clean up old UI first
    if player.PlayerGui:FindFirstChild("SigmaMoverGUI") then
        player.PlayerGui.SigmaMoverGUI:Destroy()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "SigmaMoverGUI"
    gui.Parent = player.PlayerGui
    gui.ResetOnSpawn = false

    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(0.4, 0, 0.35, 0)
    info.Position = UDim2.new(0.02, 0, 0.02, 0)
    info.BackgroundTransparency = 0.7
    info.TextColor3 = Color3.new(1, 1, 1)
    info.TextScaled = true
    info.Text = "B: Pick\nN: Place & FORCE OWNERSHIP\nG/H: Grid +/-\nV: ROTATE AROUND TARGET\nX: AUTO-ADD ALL PARTS\nNumpad +/-: Adjust Distance\nNumpad */1: Adjust Spin Speed\nNumpad 2/3: Adjust Wobble\nNumpad 4: ORBIT MOUSE TARGET!"
    info.Parent = gui
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(0.25, 0, 0.18, 0)
    status.Position = UDim2.new(0.02, 0, 0.38, 0)
    status.BackgroundTransparency = 0.7
    status.TextColor3 = Color3.new(1, 1, 1)
    status.TextScaled = true
    status.Text = "Rotation: OFF\nDistance: " .. formationDistance .. "\nSpin: " .. rotationSpeed .. "\nWobble: " .. wobbleAmount .. "\nTarget: " .. (orbitTarget and orbitTarget.Name or "NONE")
    status.Name = "StatusLabel"
    status.Parent = gui
end

local function updateStatus()
    local status = player.PlayerGui.SigmaMoverGUI:FindFirstChild("StatusLabel")
    if status then
        status.Text = "Rotation: " .. (formationActive and "ON" or "OFF") .. 
                     "\nDistance: " .. formationDistance .. 
                     "\nSpin: " .. string.format("%.1f", rotationSpeed) ..
                     "\nWobble: " .. string.format("%.1f", wobbleAmount) ..
                     "\nTarget: " .. (orbitTarget and orbitTarget.Name or "NONE")
    end
end

-- Snap to Grid
local function snap(pos)
    local half = gridSize / 2
    return Vector3.new(
        math.floor(pos.X / gridSize) * gridSize + half,
        math.floor(pos.Y / gridSize) * gridSize + half,
        math.floor(pos.Z / gridSize) * gridSize + half
    )
end

-- Raycast from mouse (with character safety check)
local function raycastMouse()
    local character = getCharacter()
    if not character or not character.Parent then return Vector3.new(0, 0, 0) end
    
    local origin = camera.CFrame.Position
    local direction = mouse.UnitRay.Direction * 1000
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = ghostPart and {ghostPart, character} or {character}
    local result = Workspace:Raycast(origin, direction, params)
    return result
end

-- Update ghost position
local function updateGhost()
    if not ghostPart then return end
    local rayResult = raycastMouse()
    local targetPos = rayResult and rayResult.Position or mouse.Hit.Position
    local targetCFrame = CFrame.new(targetPos)
    TweenService:Create(ghostPart, TweenInfo.new(moveSpeed), {CFrame = targetCFrame}):Play()
end

-- THE ULTIMATE OWNERSHIP RIZZLER
local function rizzUpNetworkOwnership(part, targetPosition)
    local character = getCharacter()
    if not character or not character.Parent then return end
    
    part.Anchored = false
    task.wait()
    part.Anchored = true
    task.wait()
    part.Anchored = false
    
    local bodyPos = part:FindFirstChildOfClass("BodyPosition") or Instance.new("BodyPosition")
    bodyPos.Parent = part
    bodyPos.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyPos.P = 500000
    bodyPos.D = 5000
    bodyPos.Position = targetPosition
    
    local bodyGyro = part:FindFirstChildOfClass("BodyGyro") or Instance.new("BodyGyro")
    bodyGyro.Parent = part
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.P = 500000
    bodyGyro.D = 5000
    bodyGyro.CFrame = CFrame.new(targetPosition)
    
    part.Velocity = Vector3.new(0, 0, 0)
    part.RotVelocity = Vector3.new(0, 0, 0)
    
    -- Store original collision properties
    storeCollisionProperties(part)
    
    task.spawn(function()
        for i = 1, 10 do
            if bodyPos and bodyPos.Parent and character and character.Parent then
                bodyPos.Position = targetPosition
            end
            if bodyGyro and bodyGyro.Parent and character and character.Parent then
                bodyGyro.CFrame = CFrame.new(targetPosition)
            end
            task.wait(0.05)
        end
    end)
    
    Notification("ULTIMATE RIZZ APPLIED TO: " .. part.Name)
end

-- X KEY: AUTO-ADD ALL UNANCHORED PARTS (TASK.SPAWNED SO ORBIT DOESN'T STOP)
local function autoAddAllParts()
    task.spawn(function()
        local character = getCharacter()
        if not character or not character.Parent then return 0 end
        
        local partsAdded = 0
        
        for _, descendant in ipairs(Workspace:GetDescendants()) do
            if descendant:IsA("BasePart") then
                local isPlayerPart = false
                local current = descendant
                while current and current ~= Workspace do
                    if current == character then
                        isPlayerPart = true
                        break
                    end
                    current = current.Parent
                end
                
                if not isPlayerPart then
                    local hasBodyPosition = descendant:FindFirstChildOfClass("BodyPosition")
                    
                    if (not descendant.Anchored) or hasBodyPosition then
                        if not controlledParts[descendant] then
                            storeCollisionProperties(descendant)
                            partsAdded += 1
                            
                            if not hasBodyPosition and not descendant.Anchored then
                                local bodyPos = Instance.new("BodyPosition")
                                bodyPos.Parent = descendant
                                bodyPos.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                bodyPos.P = 100000
                                bodyPos.D = 2000
                                bodyPos.Position = descendant.Position
                                
                                local bodyGyro = Instance.new("BodyGyro")
                                bodyGyro.Parent = descendant
                                bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                                bodyGyro.P = 100000
                                bodyGyro.D = 2000
                                bodyGyro.CFrame = descendant.CFrame
								descendant.CanCollide = false
                            end
                        end
                    end
                end
            end
        end
        
        Notification("AUTO-ADDED " .. partsAdded .. " PARTS TO YOUR ARMY! 💀🔥")
        return partsAdded
    end)
end

-- NUMPAD 4: SET ORBIT TARGET TO WHATEVER MOUSE IS HOVERING OVER
local function setOrbitTargetToMouseTarget()
    local rayResult = raycastMouse()
    if rayResult and rayResult.Instance and rayResult.Instance:IsA("BasePart") then
        orbitTarget = rayResult.Instance
        Notification("ORBIT TARGET SET TO: " .. orbitTarget.Name .. " 💀🔥")
        updateStatus()
    else
        Notification("No valid target under mouse! Aim at a part!")
    end
end

-- V KEY: MAKE EVERYTHING ROTATE AROUND TARGET
local function activateRotation()
    if not orbitTarget then
        Notification("No orbit target set! Use Numpad 4 while hovering over a part!")
        return
    end
    
    formationActive = true
    rotationAngle = 0
    enableGhostMode()
    updateStatus()
    Notification("ROTATION ACTIVATED! Parts now orbiting around " .. orbitTarget.Name .. "! (Ghost Mode ON)")
end

-- STOP ROTATION AND RESTORE COLLISION
local function deactivateRotation()
    formationActive = false
    restoreCollision()
    updateStatus()
    Notification("ROTATION STOPPED! Collision restored.")
end

-- UPDATE ROTATION AROUND TARGET WITH WOBBLE
local function updateRotation(deltaTime)
    if not formationActive or not orbitTarget or not orbitTarget.Parent then 
        if formationActive and (not orbitTarget or not orbitTarget.Parent) then
            deactivateRotation()
        end
        return 
    end
    
    rotationAngle += rotationSpeed * deltaTime
    if rotationAngle > (2 * math.pi) then
        rotationAngle -= (2 * math.pi)
    end
    
    local parts = {}
    for part, _ in pairs(controlledParts) do
        if part and part.Parent then
            table.insert(parts, part)
        end
    end
    
    if #parts == 0 then return end
    
    local angleIncrement = (2 * math.pi) / #parts
    local time = tick()
    
    for i, part in ipairs(parts) do
        local bodyPos = part:FindFirstChildOfClass("BodyPosition") or Instance.new("BodyPosition")
        bodyPos.Parent = part
        bodyPos.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyPos.P = 100000
        bodyPos.D = 2000
        
        local partAngle = rotationAngle + (i * angleIncrement)
        
        local wobble = Vector3.new(
            math.sin(time * 3 + i) * wobbleAmount,
            math.cos(time * 2 + i) * wobbleAmount,
            math.sin(time * 4 + i) * wobbleAmount
        )
        
        local offset = Vector3.new(
            math.cos(partAngle) * formationDistance,
            0,
            math.sin(partAngle) * formationDistance
        ) + wobble
        
        local targetPosition = orbitTarget.Position + offset
        bodyPos.Position = targetPosition
        
        local bodyGyro = part:FindFirstChildOfClass("BodyGyro") or Instance.new("BodyGyro")
        bodyGyro.Parent = part
        bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bodyGyro.P = 100000
        bodyGyro.D = 2000
        
        local outwardDirection = (targetPosition - orbitTarget.Position).Unit
        bodyGyro.CFrame = CFrame.new(targetPosition, targetPosition + outwardDirection)
    end
end

-- Input Handler
local function onInput(input, processed)
    if processed then return end
    local key = input.KeyCode

    -- PICK PART
    if key == Enum.KeyCode.B then
        local target = mouse.Target
        if target and target:IsA("BasePart") then
            if ghostPart then ghostPart:Destroy() end
            selectedReal = target
            
            ghostPart = target:Clone()
            ghostPart.Name = "GhostPart"
            ghostPart.Parent = Workspace
            ghostPart.Transparency = 0.5
            ghostPart.CanCollide = false
            ghostPart.Anchored = true
            
            for _, child in ipairs(ghostPart:GetChildren()) do
                if not child:IsA("BasePart") then
                    child:Destroy()
                end
            end
            
            ghostPart.CFrame = CFrame.new(ghostPart.Position)
        end

    -- PLACE & APPLY ULTIMATE RIZZ
    elseif key == Enum.KeyCode.N then
        if ghostPart and selectedReal then
            local targetPos = ghostPart.Position
            rizzUpNetworkOwnership(selectedReal, targetPos)
            ghostPart:Destroy()
            ghostPart, selectedReal = nil, nil
        end

    -- V: TOGGLE ROTATION AROUND TARGET
    elseif key == Enum.KeyCode.V then
        if formationActive then
            deactivateRotation()
        else
            activateRotation()
        end

    -- X: AUTO-ADD ALL PARTS (TASK.SPAWNED)
    elseif key == Enum.KeyCode.X then
        autoAddAllParts()

    -- NUMPAD 4: SET ORBIT TARGET TO MOUSE TARGET
    elseif key == Enum.KeyCode.KeypadFour then
        setOrbitTargetToMouseTarget()

    -- ADJUST ROTATION DISTANCE
    elseif key == Enum.KeyCode.KeypadPlus then
        formationDistance = formationDistance + 1
        updateStatus()

    elseif key == Enum.KeyCode.KeypadMinus then
        formationDistance = math.max(formationDistance - 1, 1)
        updateStatus()

    -- ADJUST SPIN SPEED
    elseif key == Enum.KeyCode.KeypadMultiply then
        rotationSpeed = rotationSpeed + 0.5
        updateStatus()

    elseif key == Enum.KeyCode.KeypadOne then
        rotationSpeed = math.max(rotationSpeed - 0.5, 0)
        updateStatus()

    -- ADJUST WOBBLE AMOUNT
    elseif key == Enum.KeyCode.KeypadTwo then
        wobbleAmount = math.max(wobbleAmount - 0.5, 0)
        updateStatus()

    elseif key == Enum.KeyCode.KeypadThree then
        wobbleAmount = wobbleAmount + 0.5
        updateStatus()

    -- GRID SIZE DOWN
    elseif key == Enum.KeyCode.G then
        gridSize = math.max(1, gridSize - 1)

    -- GRID SIZE UP
    elseif key == Enum.KeyCode.H then
        gridSize = gridSize + 1

    -- NUDGE CONTROLLED PARTS
    elseif key == Enum.KeyCode.Left then
        for part, _ in pairs(controlledParts) do
            local bodyPos = part:FindFirstChildOfClass("BodyPosition")
            if bodyPos then
                bodyPos.Position += Vector3.new(-nudgeStep, 0, 0)
            end
        end
    elseif key == Enum.KeyCode.Right then
        for part, _ in pairs(controlledParts) do
            local bodyPos = part:FindFirstChildOfClass("BodyPosition")
            if bodyPos then
                bodyPos.Position += Vector3.new(nudgeStep, 0, 0)
            end
        end
    elseif key == Enum.KeyCode.Up then
        for part, _ in pairs(controlledParts) do
            local bodyPos = part:FindFirstChildOfClass("BodyPosition")
            if bodyPos then
                bodyPos.Position += Vector3.new(0, nudgeStep, 0)
            end
        end
    elseif key == Enum.KeyCode.Down then
        for part, _ in pairs(controlledParts) do
            local bodyPos = part:FindFirstChildOfClass("BodyPosition")
            if bodyPos then
                bodyPos.Position += Vector3.new(0, -nudgeStep, 0)
            end
        end
	elseif key == Enum.KeyCode.P then
		local Character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
		orbitTarget = Character.HumanoidRootPart
		updateStatus()
    end
end

-- Update rotation in real-time
RunService.Heartbeat:Connect(function(deltaTime)
    if formationActive then
        updateRotation(deltaTime)
    end
end)

-- Update ghost in real-time
RunService.RenderStepped:Connect(function()
    updateGhost()
end)

-- Initial setup
initUI()
UserInputService.InputBegan:Connect(onInput)

Notification("OPTIMIZED SKIBIDI MACHINE LOADED! 💀🔥🚀")
Notification("Character references only when needed! Task.spawn for non-blocking operations!")
Notification("Aim at ANY part and press Numpad 4 to make everything orbit it!")
