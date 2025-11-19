local library = {}

local function ClearChildrenOfType(Parent, ClassName: string)
	for _, v in ipairs(Parent:GetChildren()) do
		if v:IsA(ClassName) then
			v:Destroy()
		end
	end
end

function library:Initialize()
	local UILib = Instance.new("ScreenGui")
	local Window = Instance.new("Frame")
	local Tabs = Instance.new("Frame")
	local UICorner = Instance.new("UICorner")
	local ScrollingFrame = Instance.new("ScrollingFrame")
	local UIListLayout = Instance.new("UIListLayout")
	local Buttons = Instance.new("Frame")
	local UICorner_2 = Instance.new("UICorner")
	local ScrollingFrame_2 = Instance.new("ScrollingFrame")
	local UIListLayout_2 = Instance.new("UIListLayout")
	local UiLabel = Instance.new("Frame")
	local TextLabel = Instance.new("TextLabel")

	--Properties:

	UILib.Name = "UI Lib"
	UILib.Parent = script
	UILib.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	Window.Name = "Window"
	Window.Parent = UILib
	Window.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	Window.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Window.BorderSizePixel = 0
	Window.Position = UDim2.new(0.29756847, 0, 0.236877516, 0)
	Window.Size = UDim2.new(0.589361727, 0, 0.510228634, 0)
	Instance.new("UIDragDetector", Window)

	Tabs.Name = "Tabs"
	Tabs.Parent = Window
	Tabs.BackgroundColor3 = Color3.fromRGB(71, 71, 71)
	Tabs.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Tabs.BorderSizePixel = 0
	Tabs.Position = UDim2.new(0.0412361138, 0, 0.146479696, 0)
	Tabs.Size = UDim2.new(0.270758092, 0, 0.714622617, 0)

	UICorner.Parent = Tabs

	ScrollingFrame.Parent = Tabs
	ScrollingFrame.Active = true
	ScrollingFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ScrollingFrame.BackgroundTransparency = 1.000
	ScrollingFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ScrollingFrame.BorderSizePixel = 0
	ScrollingFrame.Position = UDim2.new(0, 0, 3.02154234e-07, 0)
	ScrollingFrame.Size = UDim2.new(0, 225, 0, 300)
	ScrollingFrame.CanvasSize = UDim2.new(0, 0, 10, 0)

	UIListLayout.Parent = ScrollingFrame
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

	Buttons.Name = "Buttons"
	Buttons.Parent = Window
	Buttons.BackgroundColor3 = Color3.fromRGB(71, 71, 71)
	Buttons.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Buttons.BorderSizePixel = 0
	Buttons.Position = UDim2.new(0.366204709, 0, 0.141417637, 0)
	Buttons.Size = UDim2.new(0.570397079, 0, 0.714622617, 0)

	UICorner_2.Parent = Buttons

	ScrollingFrame_2.Parent = Buttons
	ScrollingFrame_2.Active = true
	ScrollingFrame_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ScrollingFrame_2.BackgroundTransparency = 1.000
	ScrollingFrame_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ScrollingFrame_2.BorderSizePixel = 0
	ScrollingFrame_2.Position = UDim2.new(1.28766146e-07, 0, -1.00718083e-07, 0)
	ScrollingFrame_2.Size = UDim2.new(0, 474, 0, 303)
	ScrollingFrame_2.CanvasSize = UDim2.new(0, 0, 10, 0)

	UIListLayout_2.Parent = ScrollingFrame_2
	UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder

	UiLabel.Name = "UiLabel"
	UiLabel.Parent = Window
	UiLabel.BackgroundColor3 = Color3.fromRGB(71, 71, 71)
	UiLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
	UiLabel.BorderSizePixel = 0
	UiLabel.Position = UDim2.new(0.0412361138, 0, 0.0300058331, 0)
	UiLabel.Size = UDim2.new(0.896510184, 0, 0.0801886767, 0)

	TextLabel.Parent = UiLabel
	TextLabel.BackgroundColor3 = Color3.fromRGB(71, 71, 71)
	TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TextLabel.BorderSizePixel = 0
	TextLabel.Position = UDim2.new(0.323426574, 0, 0, 0)
	TextLabel.Size = UDim2.new(0.26845637, 0, 1, 0)
	TextLabel.Font = Enum.Font.SourceSansBold
	TextLabel.Text = "Ui"
	TextLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
	TextLabel.TextScaled = true
	TextLabel.TextSize = 14.000
	TextLabel.TextWrapped = true
end

function library:CreateWindow(Data: {Name: string, HideKey: Enum.KeyCode})
	local WindowCode = {}

	local Gui = script["UI Lib"]:Clone()
	Gui.Window.UiLabel.TextLabel.Text = Data.Name
	Gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
	
	game:GetService("UserInputService").InputBegan:Connect(function(I, G)
		if G then return end
		if I.KeyCode == Data.HideKey then
			Gui.Window.Visible = not Gui.Window.Visible
		end
	end)

	-- FrameData holds buttons per tab index
	local FrameData = {}
	local CurrentTabIndex = 1

	--------------------------------------------------------------------
	-- Method: CreateTab
	--------------------------------------------------------------------
	function WindowCode:CreateTab(TabData: {{TabName: string}})
		for i = 1, #TabData do
			task.wait()
			-- Create Tab Button
			local TextButton = Instance.new("TextButton")
			local UICorner = Instance.new("UICorner")

			TextButton.BackgroundColor3 = Color3.fromRGB(51, 52, 52)
			TextButton.BorderSizePixel = 0
			TextButton.Size = UDim2.new(1, 0, 0, 30)
			TextButton.Font = Enum.Font.SourceSans
			TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
			TextButton.TextScaled = true
			TextButton.TextWrapped = true

			TextButton.Name = TabData[i].TabName
			TextButton.Text = TabData[i].TabName
			UICorner.Parent = TextButton
			TextButton.Parent = Gui.Window.Tabs.ScrollingFrame

			-- Create storage for this tab
			FrameData[i] = FrameData[i] or {Buttons = {}}

			-- Clicking a tab loads the buttons
			TextButton.MouseButton1Click:Connect(function()
				CurrentTabIndex = i

				-- Clear previous buttons
				ClearChildrenOfType(Gui.Window.Buttons.ScrollingFrame, "TextButton")

				-- Populate new buttons
				for _, ButtonData in ipairs(FrameData[i].Buttons) do
					local B = Instance.new("TextButton")
					local UICorner2 = Instance.new("UICorner")

					B.BackgroundColor3 = Color3.fromRGB(51, 52, 52)
					B.BorderSizePixel = 0
					B.Size = UDim2.new(0, 282, 0, 50)
					B.Font = Enum.Font.SourceSans
					B.Text = ButtonData.Name
					B.TextColor3 = Color3.fromRGB(255, 255, 255)
					B.TextScaled = true
					B.TextWrapped = true

					UICorner2.Parent = B
					B.Parent = Gui.Window.Buttons.ScrollingFrame

					B.Activated:Connect(function()
						local S, E = pcall(function()
							ButtonData.Function()
						end)
						
						if not S then
							warn("[".. Gui.Window.UiLabel.TextLabel.Text .."] ".. E)
						end
					end)
				end
			end)
		end
	end

	--------------------------------------------------------------------
	-- Method: AddButton
	--------------------------------------------------------------------
	function WindowCode:AddButton(TabIndex: number, Name: string, Callback: () -> ())
		if not FrameData[TabIndex] then
			FrameData[TabIndex] = {Buttons = {}}
		end

		table.insert(FrameData[TabIndex].Buttons, {
			Name = Name,
			Function = Callback
		})
	end
	
	--------------------------------------------------------------------
	-- Method: Notification
	--------------------------------------------------------------------
	function WindowCode:Notification(...)
		local StarterGui = game:GetService("StarterGui")
		local args = {...}
		
		pcall(function()
			StarterGui:SetCore("SendNotification", {
				Title = Gui.Window.UiLabel.TextLabel.Text,
				Text = table.concat(args, " "),
				Duration = 5,
			})
		end)
	end

	return WindowCode
end

return library
