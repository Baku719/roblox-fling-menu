local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local flingEvent = ReplicatedStorage:WaitForChild("FlingPlayer")

-- ===== GUI Setup =====
local gui = Instance.new("ScreenGui")
gui.Name = "TouchFlingMenu"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

-- Main Panel
local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.new(0, 320, 0, 500)
panel.Position = UDim2.new(0, -350, 0.5, -250)
panel.AnchorPoint = Vector2.new(0, 0.5)
panel.BackgroundColor3 = Color3.fromRGB(18, 22, 30)
panel.BorderSizePixel = 0
panel.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 20)
corner.Parent = panel

-- Shadow
local shadow = Instance.new("ImageLabel")
shadow.Size = UDim2.new(1, 18, 1, 18)
shadow.Position = UDim2.new(0, -9, 0, -9)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://131604521"
shadow.ImageTransparency = 0.45
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 118, 118)
shadow.Parent = panel

-- Handle Bar
local handleFrame = Instance.new("Frame")
handleFrame.Size = UDim2.new(1, -24, 0, 28)
handleFrame.Position = UDim2.new(0, 12, 0, 12)
handleFrame.BackgroundColor3 = Color3.fromRGB(42, 46, 56)
handleFrame.BorderSizePixel = 0
handleFrame.Parent = panel

local handleCorner = Instance.new("UICorner")
handleCorner.CornerRadius = UDim.new(0, 14)
handleCorner.Parent = handleFrame

local handleBar = Instance.new("Frame")
handleBar.Size = UDim2.new(0, 72, 0, 5)
handleBar.Position = UDim2.new(0.5, -36, 0.5, -2.5)
handleBar.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
handleBar.BorderSizePixel = 0
handleBar.Parent = handleFrame

local handleBarCorner = Instance.new("UICorner")
handleBarCorner.CornerRadius = UDim.new(0, 999)
handleBarCorner.Parent = handleBar

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -32, 0, 40)
titleLabel.Position = UDim2.new(0, 16, 0, 48)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "👥 PLAYERS"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 20
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = panel

-- Players List
local playersList = Instance.new("ScrollingFrame")
playersList.Name = "PlayersList"
playersList.Size = UDim2.new(1, -20, 1, -110)
playersList.Position = UDim2.new(0, 10, 0, 95)
playersList.BackgroundTransparency = 1
playersList.BorderSizePixel = 0
playersList.ScrollBarThickness = 5
playersList.CanvasSize = UDim2.new()
playersList.AutomaticCanvasSize = Enum.AutomaticSize.Y
playersList.Parent = panel

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = playersList

-- ===== State =====
local isOpen = false
local activeTouch = nil
local touchStartX = 0

-- ===== Functions =====
local function openMenu()
	if isOpen then return end
	isOpen = true

	local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	local tween = TweenService:Create(panel, tweenInfo, {
		Position = UDim2.new(0, 15, 0.5, -250)
	})
	tween:Play()
end

local function closeMenu()
	if not isOpen then return end
	isOpen = false

	local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	local tween = TweenService:Create(panel, tweenInfo, {
		Position = UDim2.new(0, -350, 0.5, -250)
	})
	tween:Play()
end

local function createPlayerButton(player)
	local btn = Instance.new("TextButton")
	btn.Name = player.Name
	btn.Size = UDim2.new(1, -8, 0, 56)
	btn.BackgroundColor3 = Color3.fromRGB(65, 85, 120)
	btn.BorderSizePixel = 0
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.Parent = playersList

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 14)
	btnCorner.Parent = btn

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Transparency = 0.8
	stroke.Thickness = 1
	stroke.Parent = btn

	-- Player Name Label
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -20, 0, 28)
	nameLabel.Position = UDim2.new(0, 12, 0, 6)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = player.Name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.Font = Enum.Font.GothamSemibold
	nameLabel.TextSize = 16
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = btn

	-- Player Status Label
	local statusLabel = Instance.new("TextLabel")
	statusLabel.Size = UDim2.new(1, -20, 0, 20)
	statusLabel.Position = UDim2.new(0, 12, 0, 28)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Text = "Ready to fling"
	statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	statusLabel.Font = Enum.Font.Gotham
	statusLabel.TextSize = 12
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.Parent = btn

	-- Mouse interactions
	btn.MouseEnter:Connect(function()
		local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tween = TweenService:Create(btn, tweenInfo, {
			BackgroundColor3 = Color3.fromRGB(85, 110, 155)
		})
		tween:Play()
	end)

	btn.MouseLeave:Connect(function()
		local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tween = TweenService:Create(btn, tweenInfo, {
			BackgroundColor3 = Color3.fromRGB(65, 85, 120)
		})
		tween:Play()
	end)

	btn.MouseButton1Click:Connect(function()
		if player == localPlayer then
			statusLabel.Text = "❌ Can't fling yourself"
			statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
			task.wait(2)
			statusLabel.Text = "Ready to fling"
			statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
			return
		end

		statusLabel.Text = "⚡ Flinging..."
		statusLabel.TextColor3 = Color3.fromRGB(255, 200, 87)

		flingEvent:FireServer(player)

		task.wait(0.5)
		if btn.Parent then
			statusLabel.Text = "Ready to fling"
			statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
		end
	end)

	return btn
end

local function refreshPlayerList()
	for _, child in ipairs(playersList:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	local playerCount = 0
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= localPlayer then
			createPlayerButton(player)
			playerCount = playerCount + 1
		end
	end

	if playerCount == 0 then
		local emptyLabel = Instance.new("TextLabel")
		emptyLabel.Size = UDim2.new(1, -8, 0, 40)
		emptyLabel.BackgroundTransparency = 1
		emptyLabel.Text = "No other players"
		emptyLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
		emptyLabel.Font = Enum.Font.Gotham
		emptyLabel.TextSize = 14
		emptyLabel.Parent = playersList
	end
end

-- ===== Events =====
Players.PlayerAdded:Connect(function()
	task.wait(0.1)
	refreshPlayerList()
end)

Players.PlayerRemoving:Connect(function()
	task.wait(0.1)
	refreshPlayerList()
end)

-- ===== Touch Controls =====
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType ~= Enum.UserInputType.Touch then return end

	activeTouch = input
	touchStartX = input.Position.X
end)

UserInputService.InputChanged:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType ~= Enum.UserInputType.Touch then return end
	if input ~= activeTouch then return end

	local deltaX = input.Position.X - touchStartX

	if not isOpen and deltaX > 100 then
		openMenu()
	elseif isOpen and deltaX < -100 then
		closeMenu()
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.Touch and input == activeTouch then
		activeTouch = nil
	end
end)

-- ===== Initialize =====
refreshPlayerList()
closeMenu()

print("TouchFlingMenu loaded successfully")
