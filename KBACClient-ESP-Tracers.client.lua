--!strict
-- KBAC CLIENT
-- Place this LocalScript in StarterPlayer > StarterPlayerScripts.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("KBACClient")
if oldGui then oldGui:Destroy() end

local oldAimOverlay = playerGui:FindFirstChild("KBACAimOverlay")
if oldAimOverlay then oldAimOverlay:Destroy() end

local oldBlur = Lighting:FindFirstChild("KBACClientBlur")
if oldBlur then oldBlur:Destroy() end

local oldEffects = workspace:FindFirstChild("KBACClientEffects")
if oldEffects then oldEffects:Destroy() end

local effectsFolder = Instance.new("Folder")
effectsFolder.Name = "KBACClientEffects"
effectsFolder.Parent = workspace

local COLORS = {
	white = Color3.fromRGB(255, 255, 255),
	text = Color3.fromRGB(255, 255, 255),
	muted = Color3.fromRGB(225, 231, 240),
	dark = Color3.fromRGB(13, 16, 22),
	glass = Color3.fromRGB(52, 61, 76),
}

local function corner(parent: Instance, radius: number)
	local item = Instance.new("UICorner")
	item.CornerRadius = UDim.new(0, radius)
	item.Parent = parent
	return item
end

local function stroke(parent: Instance, transparency: number, thickness: number?)
	local item = Instance.new("UIStroke")
	item.Color = COLORS.white
	item.Transparency = transparency
	item.Thickness = thickness or 1
	item.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	item.Parent = parent
	return item
end

local function gradient(parent: Instance, top: Color3, bottom: Color3, rotation: number?)
	local item = Instance.new("UIGradient")
	item.Color = ColorSequence.new(top, bottom)
	item.Rotation = rotation or 90
	item.Parent = parent
	return item
end

local gui = Instance.new("ScreenGui")
gui.Name = "KBACClient"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 1000
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local blur = Instance.new("BlurEffect")
blur.Name = "KBACClientBlur"
blur.Size = 0
blur.Parent = Lighting

-- Always-visible mobile/desktop launcher.
local openButton = Instance.new("TextButton")
openButton.Name = "OpenButton"
openButton.AnchorPoint = Vector2.new(0, 0)
openButton.Position = UDim2.fromOffset(18, 180)
openButton.Size = UDim2.fromOffset(58, 58)
openButton.BackgroundColor3 = Color3.fromRGB(8, 10, 14)
openButton.BackgroundTransparency = 0.52
openButton.BorderSizePixel = 0
openButton.Text = "K"
openButton.TextColor3 = COLORS.text
openButton.TextSize = 26
openButton.Font = Enum.Font.GothamBold
openButton.AutoButtonColor = false
openButton.ZIndex = 50
openButton.Parent = gui
corner(openButton, 18)
stroke(openButton, 0.2, 1.35)
gradient(openButton, Color3.fromRGB(55, 59, 68), Color3.fromRGB(5, 7, 10), 125)

local launcherDragging = false
local launcherMoved = false
local launcherDragDistance = 0
local launcherDragStart = Vector2.zero
local launcherPositionStart = Vector2.zero
local launcherDragInput: InputObject? = nil

local buttonShine = Instance.new("Frame")
buttonShine.Name = "Shine"
buttonShine.Position = UDim2.fromOffset(7, 5)
buttonShine.Size = UDim2.new(1, -14, 0, 19)
buttonShine.BackgroundColor3 = COLORS.white
buttonShine.BackgroundTransparency = 0.72
buttonShine.BorderSizePixel = 0
buttonShine.ZIndex = 51
buttonShine.Parent = openButton
corner(buttonShine, 11)
local buttonShineGradient = Instance.new("UIGradient")
buttonShineGradient.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.35),
	NumberSequenceKeypoint.new(1, 1),
})
buttonShineGradient.Rotation = 90
buttonShineGradient.Parent = buttonShine

openButton.InputBegan:Connect(function(input: InputObject)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
	launcherDragging = true
	launcherDragDistance = 0
	launcherDragInput = input
	launcherDragStart = Vector2.new(input.Position.X, input.Position.Y)
	launcherPositionStart = Vector2.new(openButton.Position.X.Offset, openButton.Position.Y.Offset)
end)

UserInputService.InputChanged:Connect(function(input: InputObject)
	if not launcherDragging then return end
	local isMouseMove = input.UserInputType == Enum.UserInputType.MouseMovement
	local isActiveTouch = input.UserInputType == Enum.UserInputType.Touch and input == launcherDragInput
	if not isMouseMove and not isActiveTouch then return end
	local current = Vector2.new(input.Position.X, input.Position.Y)
	local delta = current - launcherDragStart
	launcherDragDistance = delta.Magnitude
	if launcherDragDistance > 6 then launcherMoved = true end
	local camera = workspace.CurrentCamera
	if not camera then return end
	local viewport = camera.ViewportSize
	local buttonSize = openButton.AbsoluteSize
	local x = math.clamp(launcherPositionStart.X + delta.X, 6, viewport.X - buttonSize.X - 6)
	local y = math.clamp(launcherPositionStart.Y + delta.Y, 6, viewport.Y - buttonSize.Y - 6)
	openButton.Position = UDim2.fromOffset(x, y)
end)

UserInputService.InputEnded:Connect(function(input: InputObject)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input == launcherDragInput then
		launcherDragging = false
		launcherDragInput = nil
	end
end)

local panel = Instance.new("Frame")
panel.Name = "MainPanel"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.53)
panel.Size = UDim2.fromOffset(570, 440)
panel.BackgroundColor3 = COLORS.glass
panel.BackgroundTransparency = 0.32
panel.BorderSizePixel = 0
panel.Visible = false
panel.ClipsDescendants = true
panel.ZIndex = 10
panel.Parent = gui
corner(panel, 31)
stroke(panel, 0.12, 1.35)
gradient(panel, Color3.fromRGB(89, 103, 125), Color3.fromRGB(24, 29, 40), 125)

local panelScale = Instance.new("UIScale")
panelScale.Scale = 1
panelScale.Parent = panel
local responsiveScale = 1

local reflection = Instance.new("Frame")
reflection.Name = "TopReflection"
reflection.Position = UDim2.fromOffset(3, 3)
reflection.Size = UDim2.new(1, -6, 0, 118)
reflection.BackgroundColor3 = COLORS.white
reflection.BackgroundTransparency = 0.84
reflection.BorderSizePixel = 0
reflection.ZIndex = 11
reflection.Parent = panel
corner(reflection, 28)
local reflectionFade = Instance.new("UIGradient")
reflectionFade.Rotation = 90
reflectionFade.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.18),
	NumberSequenceKeypoint.new(0.5, 0.78),
	NumberSequenceKeypoint.new(1, 1),
})
reflectionFade.Parent = reflection

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Position = UDim2.fromOffset(28, 18)
title.Size = UDim2.new(1, -100, 0, 31)
title.BackgroundTransparency = 1
title.Text = "KBAC CLIENT"
title.TextColor3 = COLORS.text
title.TextSize = 25
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 15
title.Parent = panel

local subtitle = Instance.new("TextLabel")
subtitle.Name = "Subtitle"
subtitle.Position = UDim2.fromOffset(29, 50)
subtitle.Size = UDim2.new(1, -100, 0, 20)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Shooter Control Center"
subtitle.TextColor3 = COLORS.muted
subtitle.TextSize = 13
subtitle.Font = Enum.Font.GothamMedium
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.ZIndex = 15
subtitle.Parent = panel

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.AnchorPoint = Vector2.new(1, 0)
closeButton.Position = UDim2.new(1, -21, 0, 20)
closeButton.Size = UDim2.fromOffset(38, 38)
closeButton.BackgroundColor3 = COLORS.white
closeButton.BackgroundTransparency = 0.73
closeButton.BorderSizePixel = 0
closeButton.Text = "×"
closeButton.TextColor3 = COLORS.text
closeButton.TextSize = 23
closeButton.Font = Enum.Font.GothamMedium
closeButton.AutoButtonColor = false
closeButton.ZIndex = 20
closeButton.Parent = panel
corner(closeButton, 19)
stroke(closeButton, 0.4, 1.1)

local separator = Instance.new("Frame")
separator.Position = UDim2.fromOffset(28, 80)
separator.Size = UDim2.new(1, -56, 0, 1)
separator.BackgroundColor3 = COLORS.white
separator.BackgroundTransparency = 0.88
separator.BorderSizePixel = 0
separator.ZIndex = 14
separator.Parent = panel

local tabBar = Instance.new("Frame")
tabBar.Name = "TabBar"
tabBar.Position = UDim2.fromOffset(25, 94)
tabBar.Size = UDim2.new(1, -50, 0, 54)
tabBar.BackgroundColor3 = Color3.fromRGB(23, 29, 42)
tabBar.BackgroundTransparency = 0.24
tabBar.BorderSizePixel = 0
tabBar.ZIndex = 14
tabBar.Parent = panel
corner(tabBar, 17)
stroke(tabBar, 0.5, 1.1)

local tabPadding = Instance.new("UIPadding")
tabPadding.PaddingLeft = UDim.new(0, 5)
tabPadding.PaddingRight = UDim.new(0, 5)
tabPadding.PaddingTop = UDim.new(0, 5)
tabPadding.PaddingBottom = UDim.new(0, 5)
tabPadding.Parent = tabBar

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabLayout.Padding = UDim.new(0, 5)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Parent = tabBar

local content = Instance.new("Frame")
content.Name = "Content"
content.Position = UDim2.fromOffset(25, 161)
content.Size = UDim2.new(1, -50, 1, -186)
content.BackgroundColor3 = Color3.fromRGB(22, 28, 40)
content.BackgroundTransparency = 0.34
content.BorderSizePixel = 0
content.ClipsDescendants = true
content.ZIndex = 13
content.Parent = panel
corner(content, 23)
stroke(content, 0.52, 1.1)

type PageRecord = {
	Page: Frame,
	Modules: ScrollingFrame,
	EmptyText: TextLabel,
}

local pages: {[string]: PageRecord} = {}
local tabButtons: {[string]: {Button: TextButton, Stroke: UIStroke}} = {}
local selectedTab = ""

local function createPage(id: string, heading: string, description: string): PageRecord
	local page = Instance.new("Frame")
	page.Name = id .. "Page"
	page.Size = UDim2.fromScale(1, 1)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.Visible = false
	page.ZIndex = 14
	page.Parent = content

	local pageTitle = Instance.new("TextLabel")
	pageTitle.Position = UDim2.fromOffset(24, 18)
	pageTitle.Size = UDim2.new(1, -48, 0, 31)
	pageTitle.BackgroundTransparency = 1
	pageTitle.Text = heading
	pageTitle.TextColor3 = COLORS.text
	pageTitle.TextSize = 21
	pageTitle.Font = Enum.Font.GothamBold
	pageTitle.TextXAlignment = Enum.TextXAlignment.Left
	pageTitle.ZIndex = 15
	pageTitle.Parent = page

	local descriptionLabel = Instance.new("TextLabel")
	descriptionLabel.Position = UDim2.fromOffset(25, 50)
	descriptionLabel.Size = UDim2.new(1, -50, 0, 22)
	descriptionLabel.BackgroundTransparency = 1
	descriptionLabel.Text = description
	descriptionLabel.TextColor3 = COLORS.muted
	descriptionLabel.TextSize = 13
	descriptionLabel.Font = Enum.Font.GothamMedium
	descriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
	descriptionLabel.TextTruncate = Enum.TextTruncate.AtEnd
	descriptionLabel.ZIndex = 15
	descriptionLabel.Parent = page

	local line = Instance.new("Frame")
	line.Position = UDim2.fromOffset(24, 86)
	line.Size = UDim2.new(1, -48, 0, 1)
	line.BackgroundColor3 = COLORS.white
	line.BackgroundTransparency = 0.89
	line.BorderSizePixel = 0
	line.ZIndex = 15
	line.Parent = page

	local modules = Instance.new("ScrollingFrame")
	modules.Name = "Modules"
	modules.Position = UDim2.fromOffset(20, 14)
	modules.Size = UDim2.new(1, -40, 1, -27)
	modules.BackgroundTransparency = 1
	modules.BorderSizePixel = 0
	modules.ClipsDescendants = true
	modules.ScrollBarThickness = 2
	modules.ScrollBarImageColor3 = Color3.fromRGB(190, 196, 207)
	modules.ScrollBarImageTransparency = 0.45
	modules.ScrollingDirection = Enum.ScrollingDirection.Y
	modules.AutomaticCanvasSize = Enum.AutomaticSize.Y
	modules.CanvasSize = UDim2.fromOffset(0, 0)
	modules.ZIndex = 15
	modules.Parent = page

	local pageHeader = Instance.new("Frame")
	pageHeader.Name = "PageHeader"
	pageHeader.Size = UDim2.new(1, 0, 0, 82)
	pageHeader.BackgroundTransparency = 1
	pageHeader.BorderSizePixel = 0
	pageHeader.LayoutOrder = 0
	pageHeader.ZIndex = 15
	pageHeader.Parent = modules
	pageTitle.Position = UDim2.fromOffset(4, 4)
	pageTitle.Size = UDim2.new(1, -8, 0, 31)
	pageTitle.Parent = pageHeader
	descriptionLabel.Position = UDim2.fromOffset(5, 36)
	descriptionLabel.Size = UDim2.new(1, -10, 0, 22)
	descriptionLabel.Parent = pageHeader
	line.Position = UDim2.fromOffset(4, 76)
	line.Size = UDim2.new(1, -8, 0, 1)
	line.Parent = pageHeader

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Parent = modules

	local empty = Instance.new("TextLabel")
	empty.Name = "EmptyText"
	empty.Size = UDim2.new(1, 0, 0, 48)
	empty.BackgroundTransparency = 1
	empty.Text = "No functions added yet"
	empty.TextColor3 = COLORS.muted
	empty.TextTransparency = 0.25
	empty.TextSize = 14
	empty.Font = Enum.Font.GothamMedium
	empty.LayoutOrder = 1
	empty.ZIndex = 16
	empty.Parent = modules

	local record: PageRecord = {Page = page, Modules = modules, EmptyText = empty}
	pages[id] = record
	return record
end

local function createTab(id: string, text: string, order: number)
	local button = Instance.new("TextButton")
	button.Name = id .. "Tab"
	button.Size = UDim2.new(1 / 3, -7, 1, 0)
	button.BackgroundColor3 = COLORS.white
	button.BackgroundTransparency = 1
	button.BorderSizePixel = 0
	button.Text = text
	button.TextColor3 = COLORS.muted
	button.TextSize = 13
	button.Font = Enum.Font.GothamSemibold
	button.AutoButtonColor = false
	button.LayoutOrder = order
	button.ZIndex = 15
	button.Parent = tabBar
	corner(button, 13)
	local outline = stroke(button, 1)
	outline.Name = "ActiveStroke"
	tabButtons[id] = {Button = button, Stroke = outline}
end

createPage("RIVALS", "RIVALS", "Functions designed for RIVALS")
createPage("BloxStrike", "BloxStrike", "Functions designed for BloxStrike")
createPage("OTHER", "OTHER", "Universal functions for other shooter modes")

createTab("RIVALS", "RIVALS", 1)
createTab("BloxStrike", "BloxStrike", 2)
createTab("OTHER", "OTHER", 3)

local quickTween = TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

local function switchTab(name: string)
	if not pages[name] or selectedTab == name then return end
	selectedTab = name
	for id, record in pairs(pages) do
		record.Page.Visible = (id == name)
	end
	for id, record in pairs(tabButtons) do
		local active = (id == name)
		TweenService:Create(record.Button, quickTween, {
			BackgroundColor3 = active and Color3.fromRGB(18, 21, 27) or COLORS.white,
			BackgroundTransparency = active and 0.58 or 1,
			TextColor3 = active and COLORS.text or COLORS.muted,
		}):Play()
		TweenService:Create(record.Stroke, quickTween, {
			Transparency = active and 0.32 or 1,
		}):Play()
	end
end

for id, record in pairs(tabButtons) do
	record.Button.Activated:Connect(function()
		switchTab(id)
	end)
end
switchTab("RIVALS")

--============================================================
-- BLOXSTRIKE ESP
-- Targets every character model inside Workspace.Characters,
-- including models in its nested team folders.
--============================================================

pages["BloxStrike"].EmptyText.Visible = false

local bloxModules = pages["BloxStrike"].Modules
local selectedBloxCategory = "Visuals"
local categoryButtons: {[string]: {Button: TextButton, Stroke: UIStroke}} = {}

local categoryBar = Instance.new("Frame")
categoryBar.Name = "CategoryBar"
categoryBar.Position = UDim2.fromOffset(4, 0)
categoryBar.Size = UDim2.new(1, -18, 0, 44)
categoryBar.BackgroundColor3 = Color3.fromRGB(16, 20, 28)
categoryBar.BackgroundTransparency = 0.52
categoryBar.BorderSizePixel = 0
categoryBar.LayoutOrder = 1
categoryBar.ZIndex = 17
categoryBar.Parent = bloxModules
corner(categoryBar, 14)
stroke(categoryBar, 0.68, 1)

local categoryLayout = Instance.new("UIListLayout")
categoryLayout.FillDirection = Enum.FillDirection.Horizontal
categoryLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
categoryLayout.VerticalAlignment = Enum.VerticalAlignment.Center
categoryLayout.Padding = UDim.new(0, 5)
categoryLayout.SortOrder = Enum.SortOrder.LayoutOrder
categoryLayout.Parent = categoryBar

local categoryPadding = Instance.new("UIPadding")
categoryPadding.PaddingLeft = UDim.new(0, 5)
categoryPadding.PaddingRight = UDim.new(0, 5)
categoryPadding.PaddingTop = UDim.new(0, 5)
categoryPadding.PaddingBottom = UDim.new(0, 5)
categoryPadding.Parent = categoryBar

local combatEmpty = Instance.new("TextLabel")
combatEmpty.Name = "CombatEmpty"
combatEmpty.Size = UDim2.new(1, -10, 0, 54)
combatEmpty.BackgroundTransparency = 1
combatEmpty.Text = "No combat functions added yet"
combatEmpty.TextColor3 = COLORS.muted
combatEmpty.TextTransparency = 0.25
combatEmpty.TextSize = 13
combatEmpty.Font = Enum.Font.GothamMedium
combatEmpty.LayoutOrder = 2
combatEmpty.Visible = false
combatEmpty.ZIndex = 17
combatEmpty.Parent = bloxModules

local otherEmpty = combatEmpty:Clone()
otherEmpty.Name = "OtherEmpty"
otherEmpty.Text = "No other functions added yet"
otherEmpty.Visible = false
otherEmpty.Parent = bloxModules

local function createCategoryButton(name: string, order: number)
	local button = Instance.new("TextButton")
	button.Name = name .. "Category"
	button.Size = UDim2.new(1 / 3, -7, 1, 0)
	button.BackgroundColor3 = Color3.fromRGB(13, 16, 22)
	button.BackgroundTransparency = name == selectedBloxCategory and 0.38 or 1
	button.BorderSizePixel = 0
	button.Text = string.upper(name)
	button.TextColor3 = name == selectedBloxCategory and COLORS.text or COLORS.muted
	button.TextSize = 11
	button.Font = Enum.Font.GothamSemibold
	button.AutoButtonColor = false
	button.LayoutOrder = order
	button.ZIndex = 18
	button.Parent = categoryBar
	corner(button, 10)
	local outline = stroke(button, name == selectedBloxCategory and 0.38 or 1, 1)
	categoryButtons[name] = {Button = button, Stroke = outline}
end

createCategoryButton("Combat", 1)
createCategoryButton("Visuals", 2)
createCategoryButton("Other", 3)

local espEnabled = false
local espExpanded = false
local espMode = "Highlight"
local espColor = Color3.fromRGB(255, 70, 82)

local espOverlay = Instance.new("Frame")
espOverlay.Name = "ESPOverlay"
espOverlay.Size = UDim2.fromScale(1, 1)
espOverlay.BackgroundTransparency = 1
espOverlay.BorderSizePixel = 0
espOverlay.ZIndex = 100
espOverlay.Parent = gui

type PlayerPartEffect = {Fill: BoxHandleAdornment, Glow: BoxHandleAdornment}
local trackedHighlights: {[Model]: Folder} = {}
local trackedPlayerParts: {[Model]: {[BasePart]: PlayerPartEffect}} = {}
local trackedBoxes: {[Model]: Frame} = {}
local trackedSkeletons: {[Model]: Frame} = {}
local trackedLifecycleConnections: {[Model]: {RBXScriptConnection}} = {}
local charactersFolder: Instance? = nil
local cleanedCharactersFolder: Instance? = nil

local function belongsToPlayer(model: Model): boolean
	for _, otherPlayer in ipairs(Players:GetPlayers()) do
		if model.Name == otherPlayer.Name or model.Name == otherPlayer.DisplayName then return true end
	end
	return false
end

local function isLocalPlayerModel(model: Model): boolean
	local localCharacter = player.Character
	if localCharacter then
		if model == localCharacter or model:IsAncestorOf(localCharacter) or localCharacter:IsAncestorOf(model) then return true end
	end
	local lowerName = string.lower(model.Name)
	if lowerName == string.lower(player.Name) or lowerName == string.lower(player.DisplayName) then return true end
	local modelUserId = model:GetAttribute("UserId") or model:GetAttribute("PlayerUserId")
	return modelUserId == player.UserId
end

local function looksLikeCharacter(model: Model): boolean
	if not charactersFolder or not model:IsDescendantOf(charactersFolder) then return false end
	if isLocalPlayerModel(model) then return false end
	local humanoid = model:FindFirstChildWhichIsA("Humanoid")
	if humanoid and humanoid.Health <= 0 then return false end
	local hasVisibleBodyPart = false
	for _, descendant in ipairs(model:GetDescendants()) do
		if descendant:IsA("BasePart") and descendant.Name ~= "HumanoidRootPart" and descendant.Transparency < 0.95 then
			hasVisibleBodyPart = true
			break
		end
	end
	if not hasVisibleBodyPart then return false end
	if belongsToPlayer(model) then return true end
	if model:FindFirstChildWhichIsA("Humanoid") or model:FindFirstChildWhichIsA("AnimationController") then return true end
	for _, bodyName in ipairs({"Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso"}) do
		if model:FindFirstChild(bodyName) then return true end
	end
	local ancestor = model.Parent
	while ancestor and ancestor ~= charactersFolder do
		if ancestor:IsA("Model") and ancestor:FindFirstChildWhichIsA("BasePart") then return false end
		ancestor = ancestor.Parent
	end
	return true
end

local function destroyTracked(model: Model)
	local connections = trackedLifecycleConnections[model]
	if connections then
		for _, connection in ipairs(connections) do connection:Disconnect() end
	end
	trackedLifecycleConnections[model] = nil
	local highlight = trackedHighlights[model]
	if highlight then highlight:Destroy() end
	trackedHighlights[model] = nil
	local partEffects = trackedPlayerParts[model]
	if partEffects then
		for _, effect in pairs(partEffects) do
			effect.Fill:Destroy()
			effect.Glow:Destroy()
		end
	end
	trackedPlayerParts[model] = nil
	local box = trackedBoxes[model]
	if box then box:Destroy() end
	trackedBoxes[model] = nil
	local skeleton = trackedSkeletons[model]
	if skeleton then skeleton:Destroy() end
	trackedSkeletons[model] = nil
end

local function isHighlightBodyPart(part: BasePart, model: Model): boolean
	local lowerName = string.lower(part.Name)
	if part.Name == "HumanoidRootPart"
		or string.find(lowerName, "hitbox", 1, true)
		or string.find(lowerName, "collision", 1, true)
		or string.find(lowerName, "camera", 1, true)
	then
		return false
	end
	local ancestor = part.Parent
	while ancestor and ancestor ~= model do
		if ancestor:IsA("Accessory") or ancestor:IsA("Tool") then return false end
		ancestor = ancestor.Parent
	end
	return true
end

local function syncPlayerHighlight(model: Model, container: Folder)
	local partEffects = trackedPlayerParts[model]
	if not partEffects then
		partEffects = {}
		trackedPlayerParts[model] = partEffects
	end
	local currentParts: {[BasePart]: boolean} = {}
	for _, descendant in ipairs(model:GetDescendants()) do
		if descendant:IsA("BasePart") and isHighlightBodyPart(descendant, model) then
			currentParts[descendant] = true
			local effect = partEffects[descendant]
			if not effect or not effect.Fill.Parent or not effect.Glow.Parent then
				if effect then
					effect.Fill:Destroy()
					effect.Glow:Destroy()
				end
				local fill = Instance.new("BoxHandleAdornment")
				fill.Name = "PlayerFill"
				fill.AlwaysOnTop = true
				fill.ZIndex = 8
				fill.Parent = container
				local glow = Instance.new("BoxHandleAdornment")
				glow.Name = "PlayerGlow"
				glow.AlwaysOnTop = true
				glow.ZIndex = 7
				glow.Parent = container
				effect = {Fill = fill, Glow = glow}
				partEffects[descendant] = effect
			end
			effect.Fill.Size = descendant.Size * 1.01
			effect.Fill.CFrame = CFrame.new()
			effect.Fill.Color3 = espColor
			effect.Fill.Transparency = 0.4
			effect.Glow.Size = descendant.Size * 1.08
			effect.Glow.CFrame = CFrame.new()
			effect.Glow.Color3 = espColor
			effect.Glow.Transparency = 0.78
			local shouldShow = espEnabled and espMode == "Highlight"
			effect.Fill.Adornee = if shouldShow then descendant else nil
			effect.Glow.Adornee = if shouldShow then descendant else nil
		end
	end
	for part, effect in pairs(partEffects) do
		if not currentParts[part] or not part.Parent then
			effect.Fill:Destroy()
			effect.Glow:Destroy()
			partEffects[part] = nil
		end
	end
end

local function createBox(model: Model): Frame
	local box = Instance.new("Frame")
	box.Name = "ESPBox_" .. model.Name
	box.BackgroundTransparency = 1
	box.BorderSizePixel = 0
	box.Visible = false
	box.ZIndex = 101
	box.Parent = espOverlay
	local boxStroke = Instance.new("UIStroke")
	boxStroke.Name = "BoxStroke"
	boxStroke.Color = espColor
	boxStroke.Thickness = 1
	boxStroke.Transparency = 0
	boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	boxStroke.Parent = box
	trackedBoxes[model] = box
	return box
end

local function createSkeleton(model: Model): Frame
	local skeleton = Instance.new("Frame")
	skeleton.Name = "ESPSkeleton_" .. model.Name
	skeleton.Size = UDim2.fromScale(1, 1)
	skeleton.BackgroundTransparency = 1
	skeleton.BorderSizePixel = 0
	skeleton.Visible = false
	skeleton.ZIndex = 102
	skeleton.Parent = espOverlay
	trackedSkeletons[model] = skeleton
	return skeleton
end

local function trackModel(model: Model)
	if trackedHighlights[model] or not looksLikeCharacter(model) then return end
	for _, descendant in ipairs(model:GetDescendants()) do
		if descendant.Name == "KBAC_ESP_Highlight" or descendant.Name == "KBAC_ESP_Fill" then
			descendant:Destroy()
		end
	end
	local playerEffect = Instance.new("Folder")
	playerEffect.Name = "PlayerEffect_" .. model.Name
	playerEffect.Parent = effectsFolder
	trackedHighlights[model] = playerEffect
	syncPlayerHighlight(model, playerEffect)
	createBox(model)
	createSkeleton(model)
	local connections: {RBXScriptConnection} = {}
	local humanoid = model:FindFirstChildWhichIsA("Humanoid")
	if humanoid then
		table.insert(connections, humanoid.Died:Connect(function()
			destroyTracked(model)
		end))
	end
	table.insert(connections, model.AncestryChanged:Connect(function()
		if not charactersFolder or not model:IsDescendantOf(charactersFolder) then
			destroyTracked(model)
		end
	end))
	trackedLifecycleConnections[model] = connections
end

local function scanCharacters()
	charactersFolder = workspace:FindFirstChild("Characters")
	if not charactersFolder then
		local staleModels = {}
		for model in pairs(trackedHighlights) do table.insert(staleModels, model) end
		for _, model in ipairs(staleModels) do destroyTracked(model) end
		cleanedCharactersFolder = nil
		return
	end
	if cleanedCharactersFolder ~= charactersFolder then
		for _, descendant in ipairs(charactersFolder:GetDescendants()) do
			if descendant.Name == "KBAC_ESP_Highlight" or descendant.Name == "KBAC_ESP_Fill" then
				descendant:Destroy()
			end
		end
		cleanedCharactersFolder = charactersFolder
	end
	local currentModels: {[Model]: boolean} = {}
	for _, descendant in ipairs(charactersFolder:GetDescendants()) do
		if descendant:IsA("Model") and looksLikeCharacter(descendant) then
			currentModels[descendant] = true
			trackModel(descendant)
		end
	end
	local staleModels = {}
	for model in pairs(trackedHighlights) do
		if not currentModels[model] then table.insert(staleModels, model) end
	end
	for _, model in ipairs(staleModels) do destroyTracked(model) end
end

local function refreshESPVisuals()
	for model, playerEffect in pairs(trackedHighlights) do
		if not model.Parent then
			destroyTracked(model)
		elseif playerEffect.Parent ~= effectsFolder then
			destroyTracked(model)
			trackModel(model)
		else
			syncPlayerHighlight(model, playerEffect)
		end
	end
	for _, box in pairs(trackedBoxes) do
		local boxStroke = box:FindFirstChild("BoxStroke")
		if boxStroke and boxStroke:IsA("UIStroke") then boxStroke.Color = espColor end
		if not (espEnabled and espMode == "Box") then box.Visible = false end
	end
	for _, skeleton in pairs(trackedSkeletons) do
		skeleton.Visible = espEnabled and espMode == "Skeleton"
		for _, line in ipairs(skeleton:GetChildren()) do
			if line:IsA("Frame") then line.BackgroundColor3 = espColor end
		end
	end
end

local card = Instance.new("Frame")
card.Name = "ESPCard"
card.Size = UDim2.new(1, -10, 0, 68)
card.BackgroundColor3 = Color3.fromRGB(44, 54, 71)
card.BackgroundTransparency = 0.5
card.BorderSizePixel = 0
card.ClipsDescendants = true
card.LayoutOrder = 2
card.ZIndex = 17
card.Parent = bloxModules
corner(card, 18)

local cardButton = Instance.new("TextButton")
cardButton.Name = "OpenSettings"
cardButton.Size = UDim2.new(1, -78, 0, 68)
cardButton.BackgroundTransparency = 1
cardButton.BorderSizePixel = 0
cardButton.Text = ""
cardButton.AutoButtonColor = false
cardButton.ZIndex = 18
cardButton.Parent = card

local espTitle = Instance.new("TextLabel")
espTitle.Position = UDim2.fromOffset(18, 10)
espTitle.Size = UDim2.new(1, -55, 0, 25)
espTitle.BackgroundTransparency = 1
espTitle.Text = "ESP"
espTitle.TextColor3 = COLORS.text
espTitle.TextSize = 18
espTitle.Font = Enum.Font.GothamBold
espTitle.TextXAlignment = Enum.TextXAlignment.Left
espTitle.ZIndex = 19
espTitle.Parent = cardButton

local espDescription = Instance.new("TextLabel")
espDescription.Position = UDim2.fromOffset(18, 35)
espDescription.Size = UDim2.new(1, -55, 0, 19)
espDescription.BackgroundTransparency = 1
espDescription.Text = "Player highlighting"
espDescription.TextColor3 = COLORS.muted
espDescription.TextSize = 11
espDescription.Font = Enum.Font.GothamMedium
espDescription.TextXAlignment = Enum.TextXAlignment.Left
espDescription.TextTruncate = Enum.TextTruncate.AtEnd
espDescription.ZIndex = 19
espDescription.Parent = cardButton

local toggle = Instance.new("TextButton")
toggle.Name = "ESPToggle"
toggle.AnchorPoint = Vector2.new(1, 0.5)
toggle.Position = UDim2.new(1, -14, 0, 34)
toggle.Size = UDim2.fromOffset(52, 30)
toggle.BackgroundColor3 = Color3.fromRGB(104, 112, 127)
toggle.BackgroundTransparency = 0.18
toggle.BorderSizePixel = 0
toggle.Text = ""
toggle.AutoButtonColor = false
toggle.ZIndex = 22
toggle.Parent = card
corner(toggle, 15)
stroke(toggle, 0.55)

local toggleKnob = Instance.new("Frame")
toggleKnob.Name = "Knob"
toggleKnob.Position = UDim2.fromOffset(3, 3)
toggleKnob.Size = UDim2.fromOffset(24, 24)
toggleKnob.BackgroundColor3 = COLORS.white
toggleKnob.BorderSizePixel = 0
toggleKnob.ZIndex = 23
toggleKnob.Parent = toggle
corner(toggleKnob, 12)

local settings = Instance.new("Frame")
settings.Name = "Settings"
settings.Position = UDim2.fromOffset(12, 76)
settings.Size = UDim2.new(1, -24, 0, 128)
settings.BackgroundColor3 = Color3.fromRGB(25, 32, 46)
settings.BackgroundTransparency = 0.54
settings.BorderSizePixel = 0
settings.Visible = false
settings.ZIndex = 18
settings.Parent = card
corner(settings, 15)
stroke(settings, 0.58)

local modeLabel = Instance.new("TextLabel")
modeLabel.Position = UDim2.fromOffset(12, 8)
modeLabel.Size = UDim2.new(1, -24, 0, 19)
modeLabel.BackgroundTransparency = 1
modeLabel.Text = "ESP MODE"
modeLabel.TextColor3 = COLORS.muted
modeLabel.TextSize = 10
modeLabel.Font = Enum.Font.GothamBold
modeLabel.TextXAlignment = Enum.TextXAlignment.Left
modeLabel.ZIndex = 19
modeLabel.Parent = settings

local modeButtons: {[string]: TextButton} = {}
local function createModeButton(name: string, text: string, index: number)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Position = UDim2.new((index - 1) / 3, index == 1 and 12 or 4, 0, 30)
	button.Size = UDim2.new(1 / 3, -12, 0, 34)
	button.BackgroundColor3 = name == espMode and Color3.fromRGB(16, 19, 25) or Color3.fromRGB(30, 35, 45)
	button.BackgroundTransparency = name == espMode and 0.55 or 0.76
	button.BorderSizePixel = 0
	button.Text = text
	button.TextColor3 = COLORS.text
	button.TextSize = 12
	button.Font = Enum.Font.GothamSemibold
	button.AutoButtonColor = false
	button.ZIndex = 20
	button.Parent = settings
	corner(button, 11)
	stroke(button, name == espMode and 0.25 or 0.68)
	modeButtons[name] = button
	button.Activated:Connect(function()
		espMode = name
		for modeName, modeButton in pairs(modeButtons) do
			TweenService:Create(modeButton, quickTween, {
				BackgroundColor3 = modeName == espMode and Color3.fromRGB(16, 19, 25) or Color3.fromRGB(30, 35, 45),
				BackgroundTransparency = modeName == espMode and 0.55 or 0.76,
			}):Play()
			local outline = modeButton:FindFirstChildWhichIsA("UIStroke")
			if outline then outline.Transparency = modeName == espMode and 0.32 or 0.72 end
		end
		scanCharacters()
		refreshESPVisuals()
	end)
end
createModeButton("Highlight", "PLAYER", 1)
createModeButton("Box", "BOX", 2)
createModeButton("Skeleton", "SKELETON", 3)

local colorTitle = Instance.new("TextLabel")
colorTitle.Position = UDim2.fromOffset(12, 71)
colorTitle.Size = UDim2.new(1, -24, 0, 18)
colorTitle.BackgroundTransparency = 1
colorTitle.Text = "COLOR"
colorTitle.TextColor3 = COLORS.muted
colorTitle.TextSize = 10
colorTitle.Font = Enum.Font.GothamBold
colorTitle.TextXAlignment = Enum.TextXAlignment.Left
colorTitle.ZIndex = 19
colorTitle.Parent = settings

local palette = Instance.new("Frame")
palette.Name = "ColorPalette"
palette.Position = UDim2.fromOffset(12, 91)
palette.Size = UDim2.new(1, -24, 0, 26)
palette.BackgroundTransparency = 1
palette.BorderSizePixel = 0
palette.ZIndex = 20
palette.Parent = settings
local paletteLayout = Instance.new("UIListLayout")
paletteLayout.FillDirection = Enum.FillDirection.Horizontal
paletteLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
paletteLayout.Padding = UDim.new(0, 8)
paletteLayout.Parent = palette

local paletteEntries: {{Stroke: UIStroke, Color: Color3}} = {}

local function updateColorUI()
	for _, entry in ipairs(paletteEntries) do
		local selected = entry.Color == espColor
		entry.Stroke.Transparency = selected and 0.05 or 0.65
		entry.Stroke.Thickness = selected and 2 or 1
	end
	refreshESPVisuals()
end

local function selectPaletteColor(color: Color3)
	espColor = color
	updateColorUI()
end

for _, color in ipairs({
	Color3.fromRGB(255, 70, 82), Color3.fromRGB(255, 170, 45),
	Color3.fromRGB(255, 235, 70), Color3.fromRGB(70, 235, 135),
	Color3.fromRGB(70, 190, 255), Color3.fromRGB(150, 105, 255),
	Color3.fromRGB(255, 105, 220), Color3.fromRGB(255, 255, 255),
}) do
	local button = Instance.new("TextButton")
	button.Size = UDim2.fromOffset(24, 24)
	button.BackgroundColor3 = color
	button.BorderSizePixel = 0
	button.Text = ""
	button.AutoButtonColor = false
	button.ZIndex = 21
	button.Parent = palette
	corner(button, 12)
	local outline = stroke(button, 0.65, 1)
	table.insert(paletteEntries, {Stroke = outline, Color = color})
	button.Activated:Connect(function()
		selectPaletteColor(color)
	end)
end
updateColorUI()

--============================================================
-- BLOXSTRIKE TRACERS
--============================================================

local tracerEnabled = false
local tracerExpanded = false
local tracerMode = "Classic"
local tracerColor = Color3.fromRGB(255, 70, 82)
local tracerThickness = 2
local arrowSize = 28
local tracerLines: {[Model]: Frame} = {}
local tracerArrows: {[Model]: Frame} = {}

local tracerOverlay = Instance.new("Frame")
tracerOverlay.Name = "TracerOverlay"
tracerOverlay.Size = UDim2.fromScale(1, 1)
tracerOverlay.BackgroundTransparency = 1
tracerOverlay.BorderSizePixel = 0
tracerOverlay.ZIndex = 110
tracerOverlay.Parent = gui

local tracerCard = Instance.new("Frame")
tracerCard.Name = "TracerCard"
tracerCard.Size = UDim2.new(1, -10, 0, 68)
tracerCard.BackgroundColor3 = Color3.fromRGB(44, 54, 71)
tracerCard.BackgroundTransparency = 0.5
tracerCard.BorderSizePixel = 0
tracerCard.ClipsDescendants = true
tracerCard.LayoutOrder = 3
tracerCard.ZIndex = 17
tracerCard.Parent = bloxModules
corner(tracerCard, 18)
stroke(tracerCard, 0.62, 1)

local tracerOpen = Instance.new("TextButton")
tracerOpen.Size = UDim2.new(1, -78, 0, 68)
tracerOpen.BackgroundTransparency = 1
tracerOpen.Text = ""
tracerOpen.AutoButtonColor = false
tracerOpen.ZIndex = 18
tracerOpen.Parent = tracerCard

local tracerTitle = Instance.new("TextLabel")
tracerTitle.Position = UDim2.fromOffset(18, 10)
tracerTitle.Size = UDim2.new(1, -35, 0, 25)
tracerTitle.BackgroundTransparency = 1
tracerTitle.Text = "TRACERS"
tracerTitle.TextColor3 = COLORS.text
tracerTitle.TextSize = 18
tracerTitle.Font = Enum.Font.GothamBold
tracerTitle.TextXAlignment = Enum.TextXAlignment.Left
tracerTitle.ZIndex = 19
tracerTitle.Parent = tracerOpen

local tracerDescription = tracerTitle:Clone()
tracerDescription.Position = UDim2.fromOffset(18, 35)
tracerDescription.Size = UDim2.new(1, -35, 0, 19)
tracerDescription.Text = "Direction indicators for players"
tracerDescription.TextColor3 = COLORS.muted
tracerDescription.TextSize = 11
tracerDescription.Font = Enum.Font.GothamMedium
tracerDescription.Parent = tracerOpen

local tracerToggle = Instance.new("TextButton")
tracerToggle.AnchorPoint = Vector2.new(1, 0.5)
tracerToggle.Position = UDim2.new(1, -14, 0, 34)
tracerToggle.Size = UDim2.fromOffset(52, 30)
tracerToggle.BackgroundColor3 = Color3.fromRGB(104, 112, 127)
tracerToggle.BackgroundTransparency = 0.18
tracerToggle.BorderSizePixel = 0
tracerToggle.Text = ""
tracerToggle.AutoButtonColor = false
tracerToggle.ZIndex = 22
tracerToggle.Parent = tracerCard
corner(tracerToggle, 15)
stroke(tracerToggle, 0.55)

local tracerKnob = Instance.new("Frame")
tracerKnob.Position = UDim2.fromOffset(3, 3)
tracerKnob.Size = UDim2.fromOffset(24, 24)
tracerKnob.BackgroundColor3 = COLORS.white
tracerKnob.BorderSizePixel = 0
tracerKnob.ZIndex = 23
tracerKnob.Parent = tracerToggle
corner(tracerKnob, 12)

local tracerSettings = Instance.new("Frame")
tracerSettings.Position = UDim2.fromOffset(12, 76)
tracerSettings.Size = UDim2.new(1, -24, 0, 168)
tracerSettings.BackgroundColor3 = Color3.fromRGB(25, 32, 46)
tracerSettings.BackgroundTransparency = 0.54
tracerSettings.BorderSizePixel = 0
tracerSettings.Visible = false
tracerSettings.ZIndex = 18
tracerSettings.Parent = tracerCard
corner(tracerSettings, 15)
stroke(tracerSettings, 0.58)

local tracerModeLabel = Instance.new("TextLabel")
tracerModeLabel.Position = UDim2.fromOffset(12, 8)
tracerModeLabel.Size = UDim2.new(1, -24, 0, 18)
tracerModeLabel.BackgroundTransparency = 1
tracerModeLabel.Text = "MODE"
tracerModeLabel.TextColor3 = COLORS.muted
tracerModeLabel.TextSize = 10
tracerModeLabel.Font = Enum.Font.GothamBold
tracerModeLabel.TextXAlignment = Enum.TextXAlignment.Left
tracerModeLabel.ZIndex = 19
tracerModeLabel.Parent = tracerSettings

local tracerModeButtons: {[string]: TextButton} = {}
local function refreshTracerModeButtons()
	for name, button in pairs(tracerModeButtons) do
		local active = name == tracerMode
		button.BackgroundTransparency = active and 0.48 or 0.78
		local outline = button:FindFirstChildWhichIsA("UIStroke")
		if outline then outline.Transparency = active and 0.32 or 0.75 end
	end
end

local function createTracerMode(name: string, text: string, index: number)
	local button = Instance.new("TextButton")
	button.Position = UDim2.new((index - 1) * 0.5, index == 1 and 12 or 6, 0, 29)
	button.Size = UDim2.new(0.5, -18, 0, 32)
	button.BackgroundColor3 = Color3.fromRGB(16, 19, 25)
	button.BorderSizePixel = 0
	button.Text = text
	button.TextColor3 = COLORS.text
	button.TextSize = 11
	button.Font = Enum.Font.GothamSemibold
	button.AutoButtonColor = false
	button.ZIndex = 20
	button.Parent = tracerSettings
	corner(button, 10)
	stroke(button, 0.7)
	tracerModeButtons[name] = button
	button.Activated:Connect(function()
		tracerMode = name
		refreshTracerModeButtons()
	end)
end
createTracerMode("Classic", "CLASSIC", 1)
createTracerMode("Arrows", "ARROWS", 2)
refreshTracerModeButtons()

local tracerColorLabel = tracerModeLabel:Clone()
tracerColorLabel.Position = UDim2.fromOffset(12, 67)
tracerColorLabel.Text = "COLOR"
tracerColorLabel.Parent = tracerSettings

local tracerPalette = Instance.new("Frame")
tracerPalette.Position = UDim2.fromOffset(12, 87)
tracerPalette.Size = UDim2.new(1, -24, 0, 26)
tracerPalette.BackgroundTransparency = 1
tracerPalette.ZIndex = 20
tracerPalette.Parent = tracerSettings
local tracerPaletteLayout = Instance.new("UIListLayout")
tracerPaletteLayout.FillDirection = Enum.FillDirection.Horizontal
tracerPaletteLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tracerPaletteLayout.Padding = UDim.new(0, 8)
tracerPaletteLayout.Parent = tracerPalette
for _, color in ipairs({
	Color3.fromRGB(255, 70, 82), Color3.fromRGB(255, 170, 45),
	Color3.fromRGB(255, 235, 70), Color3.fromRGB(70, 235, 135),
	Color3.fromRGB(70, 190, 255), Color3.fromRGB(150, 105, 255),
	Color3.fromRGB(255, 105, 220), Color3.fromRGB(255, 255, 255),
}) do
	local dot = Instance.new("TextButton")
	dot.Size = UDim2.fromOffset(24, 24)
	dot.BackgroundColor3 = color
	dot.BorderSizePixel = 0
	dot.Text = ""
	dot.AutoButtonColor = false
	dot.ZIndex = 21
	dot.Parent = tracerPalette
	corner(dot, 12)
	stroke(dot, 0.55)
	dot.Activated:Connect(function() tracerColor = color end)
end

local sizeLabel = tracerModeLabel:Clone()
sizeLabel.Position = UDim2.fromOffset(12, 119)
sizeLabel.Text = "THICKNESS / SIZE"
sizeLabel.Parent = tracerSettings

local sizeValue = sizeLabel:Clone()
sizeValue.Position = UDim2.new(1, -54, 0, 119)
sizeValue.Size = UDim2.fromOffset(42, 18)
sizeValue.TextXAlignment = Enum.TextXAlignment.Right
sizeValue.Parent = tracerSettings

local sizeTrack = Instance.new("Frame")
sizeTrack.Position = UDim2.fromOffset(14, 145)
sizeTrack.Size = UDim2.new(1, -28, 0, 6)
sizeTrack.BackgroundColor3 = Color3.fromRGB(105, 114, 130)
sizeTrack.BackgroundTransparency = 0.35
sizeTrack.BorderSizePixel = 0
sizeTrack.Active = true
sizeTrack.ZIndex = 20
sizeTrack.Parent = tracerSettings
corner(sizeTrack, 3)

local sizeFill = Instance.new("Frame")
sizeFill.Size = UDim2.new(0.2, 0, 1, 0)
sizeFill.BackgroundColor3 = tracerColor
sizeFill.BorderSizePixel = 0
sizeFill.ZIndex = 21
sizeFill.Parent = sizeTrack
corner(sizeFill, 3)

local sizeKnob = Instance.new("Frame")
sizeKnob.AnchorPoint = Vector2.new(0.5, 0.5)
sizeKnob.Position = UDim2.new(0.2, 0, 0.5, 0)
sizeKnob.Size = UDim2.fromOffset(18, 18)
sizeKnob.BackgroundColor3 = COLORS.white
sizeKnob.BorderSizePixel = 0
sizeKnob.ZIndex = 22
sizeKnob.Parent = sizeTrack
corner(sizeKnob, 9)

local function refreshTracerSizeUI()
	local alpha
	if tracerMode == "Classic" then
		alpha = (tracerThickness - 1) / 5
		sizeValue.Text = string.format("%.1f", tracerThickness)
	else
		alpha = (arrowSize - 16) / 36
		sizeValue.Text = tostring(math.round(arrowSize))
	end
	sizeFill.Size = UDim2.new(alpha, 0, 1, 0)
	sizeFill.BackgroundColor3 = tracerColor
	sizeKnob.Position = UDim2.new(alpha, 0, 0.5, 0)
end

for _, button in pairs(tracerModeButtons) do
	button.Activated:Connect(function() task.defer(refreshTracerSizeUI) end)
end

local draggingSize = false
local function setTracerSizeFromX(x: number)
	local alpha = math.clamp((x - sizeTrack.AbsolutePosition.X) / math.max(sizeTrack.AbsoluteSize.X, 1), 0, 1)
	if tracerMode == "Classic" then tracerThickness = 1 + alpha * 5 else arrowSize = 16 + alpha * 36 end
	refreshTracerSizeUI()
end
sizeTrack.InputBegan:Connect(function(input: InputObject)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		draggingSize = true
		setTracerSizeFromX(input.Position.X)
	end
end)
UserInputService.InputChanged:Connect(function(input: InputObject)
	if draggingSize and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		setTracerSizeFromX(input.Position.X)
	end
end)
UserInputService.InputEnded:Connect(function(input: InputObject)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingSize = false end
end)
refreshTracerSizeUI()

tracerToggle.Activated:Connect(function()
	tracerEnabled = not tracerEnabled
	TweenService:Create(tracerToggle, quickTween, {
		BackgroundColor3 = tracerEnabled and Color3.fromRGB(10, 12, 16) or Color3.fromRGB(104, 112, 127),
		BackgroundTransparency = tracerEnabled and 0.42 or 0.18,
	}):Play()
	TweenService:Create(tracerKnob, quickTween, {
		Position = tracerEnabled and UDim2.fromOffset(25, 3) or UDim2.fromOffset(3, 3),
	}):Play()
	if not tracerEnabled then
		for _, line in pairs(tracerLines) do line.Visible = false end
		for _, arrow in pairs(tracerArrows) do arrow.Visible = false end
	end
end)

tracerOpen.Activated:Connect(function()
	tracerExpanded = not tracerExpanded
	tracerSettings.Visible = true
	TweenService:Create(tracerCard, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Size = UDim2.new(1, -10, 0, tracerExpanded and 256 or 68),
	}):Play()
	if not tracerExpanded then task.delay(0.25, function() if not tracerExpanded then tracerSettings.Visible = false end end) end
end)

-- Aim assist uses the same tracked BloxStrike characters as ESP.
local aimEnabled = false
local aimExpanded = false
local aimRadius = 120
local aimColor = Color3.fromRGB(255, 70, 82)
local savedAimHumanoid: Humanoid? = nil
local savedAutoRotate: boolean? = nil
local savedAimCamera: Camera? = nil
local savedAimCameraType = Enum.CameraType.Custom
local savedAimMouseBehavior = Enum.MouseBehavior.Default
local savedAimCameraOffset: Vector3? = nil
local lockedAimModel: Model? = nil
local lockedAimPart: BasePart? = nil
local aimLockStartedAt = 0
local aimMouseTravel = 0

local function restoreAimAutoRotate()
	if savedAimHumanoid and savedAimHumanoid.Parent and savedAutoRotate ~= nil then
		savedAimHumanoid.AutoRotate = savedAutoRotate
	end
	savedAimHumanoid = nil
	savedAutoRotate = nil
end

local function restoreAimCameraControl()
	if savedAimCamera then
		if savedAimCamera.Parent then savedAimCamera.CameraType = savedAimCameraType end
		UserInputService.MouseBehavior = savedAimMouseBehavior
	end
	savedAimCamera = nil
	savedAimCameraOffset = nil
	aimMouseTravel = 0
end

local aimOverlayGui = Instance.new("ScreenGui")
aimOverlayGui.Name = "KBACAimOverlay"
aimOverlayGui.ResetOnSpawn = false
aimOverlayGui.IgnoreGuiInset = true
aimOverlayGui.ScreenInsets = Enum.ScreenInsets.None
aimOverlayGui.DisplayOrder = gui.DisplayOrder + 1
aimOverlayGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
aimOverlayGui.Parent = playerGui

local aimOverlayRoot = Instance.new("Frame")
aimOverlayRoot.Name = "AimOverlayRoot"
aimOverlayRoot.Size = UDim2.fromScale(1, 1)
aimOverlayRoot.BackgroundTransparency = 1
aimOverlayRoot.BorderSizePixel = 0
aimOverlayRoot.Parent = aimOverlayGui

local aimCircle = Instance.new("Frame")
aimCircle.Name = "AimFOVCircle"
aimCircle.AnchorPoint = Vector2.new(0.5, 0.5)
aimCircle.Position = UDim2.fromScale(0.5, 0.5)
aimCircle.Size = UDim2.fromOffset(aimRadius * 2, aimRadius * 2)
aimCircle.BackgroundTransparency = 1
aimCircle.BorderSizePixel = 0
aimCircle.Visible = false
aimCircle.ZIndex = 120
aimCircle.Parent = aimOverlayRoot
local aimCircleCorner = corner(aimCircle, 0)
aimCircleCorner.CornerRadius = UDim.new(1, 0)
local aimCircleStroke = stroke(aimCircle, 0.1, 2)
aimCircleStroke.Color = aimColor

local aimCard = Instance.new("Frame")
aimCard.Name = "AimCard"
aimCard.Size = UDim2.new(1, -10, 0, 68)
aimCard.BackgroundColor3 = Color3.fromRGB(44, 54, 71)
aimCard.BackgroundTransparency = 0.5
aimCard.BorderSizePixel = 0
aimCard.ClipsDescendants = true
aimCard.LayoutOrder = 2
aimCard.Visible = false
aimCard.ZIndex = 17
aimCard.Parent = bloxModules
corner(aimCard, 18)
stroke(aimCard, 0.62, 1)

local aimOpen = Instance.new("TextButton")
aimOpen.Size = UDim2.new(1, -78, 0, 68)
aimOpen.BackgroundTransparency = 1
aimOpen.Text = ""
aimOpen.AutoButtonColor = false
aimOpen.ZIndex = 18
aimOpen.Parent = aimCard

local aimTitle = tracerTitle:Clone()
aimTitle.Text = "AIM"
aimTitle.Parent = aimOpen
local aimDescription = tracerDescription:Clone()
aimDescription.Text = "Target lock; move mouse to release"
aimDescription.Parent = aimOpen
local function setAimStatus(message: string)
	if aimDescription.Text ~= message then aimDescription.Text = message end
end

local aimToggle = tracerToggle:Clone()
aimToggle.Name = "AimToggle"
aimToggle.Parent = aimCard
local aimKnob = aimToggle:FindFirstChildWhichIsA("Frame") :: Frame

local aimSettings = Instance.new("Frame")
aimSettings.Position = UDim2.fromOffset(12, 76)
aimSettings.Size = UDim2.new(1, -24, 0, 118)
aimSettings.BackgroundColor3 = Color3.fromRGB(25, 32, 46)
aimSettings.BackgroundTransparency = 0.54
aimSettings.BorderSizePixel = 0
aimSettings.Visible = false
aimSettings.ZIndex = 18
aimSettings.Parent = aimCard
corner(aimSettings, 15)
stroke(aimSettings, 0.58)

local aimColorLabel = tracerModeLabel:Clone()
aimColorLabel.Position = UDim2.fromOffset(12, 9)
aimColorLabel.Text = "CIRCLE COLOR"
aimColorLabel.Parent = aimSettings

local aimPalette = Instance.new("Frame")
aimPalette.Position = UDim2.fromOffset(12, 29)
aimPalette.Size = UDim2.new(1, -24, 0, 26)
aimPalette.BackgroundTransparency = 1
aimPalette.ZIndex = 20
aimPalette.Parent = aimSettings
local aimPaletteLayout = Instance.new("UIListLayout")
aimPaletteLayout.FillDirection = Enum.FillDirection.Horizontal
aimPaletteLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
aimPaletteLayout.Padding = UDim.new(0, 8)
aimPaletteLayout.Parent = aimPalette
local aimSizeFill = Instance.new("Frame")
local aimSwatches: {{Color: Color3, Outline: UIStroke}} = {}
for _, color in ipairs({
	Color3.fromRGB(255, 70, 82), Color3.fromRGB(255, 170, 45),
	Color3.fromRGB(255, 235, 70), Color3.fromRGB(70, 235, 135),
	Color3.fromRGB(70, 190, 255), Color3.fromRGB(150, 105, 255),
	Color3.fromRGB(255, 105, 220), Color3.fromRGB(255, 255, 255),
}) do
	local dot = Instance.new("TextButton")
	dot.Size = UDim2.fromOffset(24, 24)
	dot.BackgroundColor3 = color
	dot.BorderSizePixel = 0
	dot.Text = ""
	dot.AutoButtonColor = false
	dot.ZIndex = 21
	dot.Parent = aimPalette
	corner(dot, 12)
	local outline = stroke(dot, 0.65)
	table.insert(aimSwatches, {Color = color, Outline = outline})
	dot.Activated:Connect(function()
		aimColor = color
		aimCircleStroke.Color = color
		aimSizeFill.BackgroundColor3 = color
		for _, swatch in ipairs(aimSwatches) do
			swatch.Outline.Transparency = if swatch.Color == color then 0.05 else 0.65
		end
	end)
end
aimSwatches[1].Outline.Transparency = 0.05

local aimSizeLabel = aimColorLabel:Clone()
aimSizeLabel.Position = UDim2.fromOffset(12, 63)
aimSizeLabel.Text = "CIRCLE RADIUS"
aimSizeLabel.Parent = aimSettings
local aimSizeValue = aimSizeLabel:Clone()
aimSizeValue.Position = UDim2.new(1, -66, 0, 63)
aimSizeValue.Size = UDim2.fromOffset(54, 18)
aimSizeValue.TextXAlignment = Enum.TextXAlignment.Right
aimSizeValue.Parent = aimSettings

local aimSizeTrack = Instance.new("Frame")
aimSizeTrack.Position = UDim2.fromOffset(14, 99)
aimSizeTrack.Size = UDim2.new(1, -28, 0, 6)
aimSizeTrack.BackgroundColor3 = Color3.fromRGB(105, 114, 130)
aimSizeTrack.BackgroundTransparency = 0.35
aimSizeTrack.BorderSizePixel = 0
aimSizeTrack.Active = true
aimSizeTrack.ZIndex = 20
aimSizeTrack.Parent = aimSettings
corner(aimSizeTrack, 3)
aimSizeFill.BackgroundColor3 = aimColor
aimSizeFill.BorderSizePixel = 0
aimSizeFill.ZIndex = 21
aimSizeFill.Parent = aimSizeTrack
corner(aimSizeFill, 3)
local aimSizeKnob = Instance.new("Frame")
aimSizeKnob.AnchorPoint = Vector2.new(0.5, 0.5)
aimSizeKnob.Size = UDim2.fromOffset(18, 18)
aimSizeKnob.BackgroundColor3 = COLORS.white
aimSizeKnob.BorderSizePixel = 0
aimSizeKnob.ZIndex = 22
aimSizeKnob.Parent = aimSizeTrack
corner(aimSizeKnob, 9)
local aimSizeHit = Instance.new("Frame")
aimSizeHit.AnchorPoint = Vector2.new(0, 0.5)
aimSizeHit.Position = UDim2.new(0, 0, 0.5, 0)
aimSizeHit.Size = UDim2.new(1, 0, 0, 30)
aimSizeHit.BackgroundTransparency = 1
aimSizeHit.Active = true
aimSizeHit.ZIndex = 23
aimSizeHit.Parent = aimSizeTrack

local function refreshAimSize()
	local alpha = (aimRadius - 30) / 270
	aimSizeValue.Text = tostring(aimRadius) .. " px"
	aimCircle.Size = UDim2.fromOffset(aimRadius * 2, aimRadius * 2)
	aimSizeFill.Size = UDim2.new(alpha, 0, 1, 0)
	aimSizeFill.BackgroundColor3 = aimColor
	aimSizeKnob.Position = UDim2.new(alpha, 0, 0.5, 0)
end

local draggingAimSize = false
local aimDragInput: InputObject? = nil
local function setAimSizeFromX(x: number)
	local alpha = math.clamp((x - aimSizeTrack.AbsolutePosition.X) / math.max(aimSizeTrack.AbsoluteSize.X, 1), 0, 1)
	aimRadius = math.round(30 + alpha * 270)
	refreshAimSize()
end
aimSizeHit.InputBegan:Connect(function(input: InputObject)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		draggingAimSize = true
		aimDragInput = input
		setAimSizeFromX(input.Position.X)
	end
end)
UserInputService.InputChanged:Connect(function(input: InputObject)
	if draggingAimSize and (input.UserInputType == Enum.UserInputType.MouseMovement or input == aimDragInput) then
		setAimSizeFromX(input.Position.X)
	end
end)
UserInputService.InputEnded:Connect(function(input: InputObject)
	if input == aimDragInput then
		draggingAimSize = false
		aimDragInput = nil
	end
end)
refreshAimSize()

local function setAimEnabled(shouldEnable: boolean)
	aimEnabled = shouldEnable
	setAimStatus("Target lock; move mouse to release")
	TweenService:Create(aimToggle, quickTween, {
		BackgroundColor3 = aimEnabled and Color3.fromRGB(10, 12, 16) or Color3.fromRGB(104, 112, 127),
		BackgroundTransparency = aimEnabled and 0.42 or 0.18,
	}):Play()
	TweenService:Create(aimKnob, quickTween, {
		Position = aimEnabled and UDim2.fromOffset(25, 3) or UDim2.fromOffset(3, 3),
	}):Play()
	aimCircle.Visible = aimEnabled
	if not aimEnabled then
		lockedAimModel = nil
		lockedAimPart = nil
		restoreAimCameraControl()
		restoreAimAutoRotate()
	end
end

aimToggle.Activated:Connect(function()
	setAimEnabled(not aimEnabled)
end)

aimOpen.Activated:Connect(function()
	aimExpanded = not aimExpanded
	aimSettings.Visible = true
	TweenService:Create(aimCard, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Size = UDim2.new(1, -10, 0, aimExpanded and 206 or 68),
	}):Play()
	if not aimExpanded then task.delay(0.25, function() if not aimExpanded then aimSettings.Visible = false end end) end
end)

local function switchBloxCategory(name: string)
	selectedBloxCategory = name
	card.Visible = name == "Visuals"
	tracerCard.Visible = name == "Visuals"
	aimCard.Visible = name == "Combat"
	combatEmpty.Visible = false
	otherEmpty.Visible = name == "Other"
	for categoryName, record in pairs(categoryButtons) do
		local active = categoryName == name
		TweenService:Create(record.Button, quickTween, {
			BackgroundTransparency = active and 0.38 or 1,
			TextColor3 = active and COLORS.text or COLORS.muted,
		}):Play()
		TweenService:Create(record.Stroke, quickTween, {
			Transparency = active and 0.38 or 1,
		}):Play()
	end
end

for categoryName, record in pairs(categoryButtons) do
	record.Button.Activated:Connect(function()
		switchBloxCategory(categoryName)
	end)
end
switchBloxCategory("Visuals")

toggle.Activated:Connect(function()
	espEnabled = not espEnabled
	TweenService:Create(toggle, quickTween, {
		BackgroundColor3 = espEnabled and Color3.fromRGB(10, 12, 16) or Color3.fromRGB(50, 55, 66),
		BackgroundTransparency = espEnabled and 0.42 or 0.55,
	}):Play()
	TweenService:Create(toggleKnob, quickTween, {
		Position = espEnabled and UDim2.fromOffset(25, 3) or UDim2.fromOffset(3, 3),
	}):Play()
	scanCharacters()
	refreshESPVisuals()
end)

cardButton.Activated:Connect(function()
	espExpanded = not espExpanded
	settings.Visible = true
	TweenService:Create(card, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Size = UDim2.new(1, -10, 0, espExpanded and 216 or 68),
	}):Play()
	if not espExpanded then task.delay(0.25, function() if not espExpanded then settings.Visible = false end end) end
end)

local function rescanESP()
	scanCharacters()
	refreshESPVisuals()
end

local rescanScheduled = false
local function scheduleESPRescans()
	if rescanScheduled then return end
	rescanScheduled = true
	task.defer(function()
		if gui.Parent then rescanESP() end
		rescanScheduled = false
	end)
end

local function hookPlayer(otherPlayer: Player)
	otherPlayer:GetPropertyChangedSignal("Team"):Connect(scheduleESPRescans)
	otherPlayer.CharacterAdded:Connect(scheduleESPRescans)
	scheduleESPRescans()
end

for _, otherPlayer in ipairs(Players:GetPlayers()) do hookPlayer(otherPlayer) end
Players.PlayerAdded:Connect(hookPlayer)
Players.PlayerRemoving:Connect(scheduleESPRescans)

workspace.ChildAdded:Connect(function(child: Instance)
	if child.Name == "Characters" then
		charactersFolder = child
		scheduleESPRescans()
	end
end)

workspace.DescendantAdded:Connect(function(descendant: Instance)
	if charactersFolder and descendant:IsDescendantOf(charactersFolder) then
		local cursor: Instance? = descendant
		while cursor and cursor ~= charactersFolder do
			if cursor:IsA("Model") and looksLikeCharacter(cursor) then
				trackModel(cursor)
				refreshESPVisuals()
				break
			end
			cursor = cursor.Parent
		end
		scheduleESPRescans()
	end
end)

workspace.DescendantRemoving:Connect(function(descendant: Instance)
	if descendant:IsA("Model") and trackedHighlights[descendant] then destroyTracked(descendant) end
end)

local rescanClock = 0
RunService.Heartbeat:Connect(function(deltaTime: number)
	rescanClock += deltaTime
	if rescanClock < 0.25 then return end
	rescanClock = 0
	rescanESP()
end)

local function getBodyPart(model: Model, ...: string): BasePart?
	for _, name in ipairs({...}) do
		local part = model:FindFirstChild(name, true)
		if part and part:IsA("BasePart") then return part end
	end
	return nil
end

local function getSkeletonPairs(model: Model)
	local pairsList = {}
	local head = getBodyPart(model, "Head")
	local upper = getBodyPart(model, "UpperTorso", "Torso", "HumanoidRootPart")
	local lower = getBodyPart(model, "LowerTorso", "Torso", "HumanoidRootPart")
	local function add(a: BasePart?, b: BasePart?)
		if a and b and a ~= b then table.insert(pairsList, {a, b}) end
	end
	add(head, upper)
	add(upper, lower)
	add(upper, getBodyPart(model, "LeftUpperArm", "Left Arm"))
	add(getBodyPart(model, "LeftUpperArm"), getBodyPart(model, "LeftLowerArm"))
	add(getBodyPart(model, "LeftLowerArm"), getBodyPart(model, "LeftHand"))
	add(upper, getBodyPart(model, "RightUpperArm", "Right Arm"))
	add(getBodyPart(model, "RightUpperArm"), getBodyPart(model, "RightLowerArm"))
	add(getBodyPart(model, "RightLowerArm"), getBodyPart(model, "RightHand"))
	add(lower, getBodyPart(model, "LeftUpperLeg", "Left Leg"))
	add(getBodyPart(model, "LeftUpperLeg"), getBodyPart(model, "LeftLowerLeg"))
	add(getBodyPart(model, "LeftLowerLeg"), getBodyPart(model, "LeftFoot"))
	add(lower, getBodyPart(model, "RightUpperLeg", "Right Leg"))
	add(getBodyPart(model, "RightUpperLeg"), getBodyPart(model, "RightLowerLeg"))
	add(getBodyPart(model, "RightLowerLeg"), getBodyPart(model, "RightFoot"))
	return pairsList
end

local function ensureSkeletonLine(container: Frame, index: number): Frame
	local name = "Line" .. tostring(index)
	local existing = container:FindFirstChild(name)
	if existing and existing:IsA("Frame") then return existing end
	local line = Instance.new("Frame")
	line.Name = name
	line.AnchorPoint = Vector2.new(0.5, 0.5)
	line.BorderSizePixel = 0
	line.BackgroundColor3 = espColor
	line.ZIndex = 103
	line.Parent = container
	corner(line, 2)
	return line
end

local function ensureTracerLine(model: Model): Frame
	local line = tracerLines[model]
	if line and line.Parent then return line end
	line = Instance.new("Frame")
	line.Name = "Tracer_" .. model.Name
	line.AnchorPoint = Vector2.new(0.5, 0.5)
	line.BorderSizePixel = 0
	line.ZIndex = 111
	line.Parent = tracerOverlay
	corner(line, 3)
	local fade = Instance.new("UIGradient")
	fade.Name = "Fade"
	fade.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.72),
		NumberSequenceKeypoint.new(0.7, 0.12),
		NumberSequenceKeypoint.new(1, 0),
	})
	fade.Parent = line
	tracerLines[model] = line
	return line
end

local function ensureTracerArrow(model: Model): Frame
	local arrow = tracerArrows[model]
	if arrow and arrow.Parent then return arrow end
	arrow = Instance.new("Frame")
	arrow.Name = "Arrow_" .. model.Name
	arrow.AnchorPoint = Vector2.new(0.5, 0.5)
	arrow.BackgroundTransparency = 1
	arrow.BorderSizePixel = 0
	arrow.ZIndex = 112
	arrow.Parent = tracerOverlay
	for _, data in ipairs({{"Upper", -38}, {"Lower", 38}}) do
		local arm = Instance.new("Frame")
		arm.Name = data[1] :: string
		arm.AnchorPoint = Vector2.new(1, 0.5)
		arm.Position = UDim2.new(0.88, 0, 0.5, 0)
		arm.Size = UDim2.new(0.68, 0, 0, 3)
		arm.BackgroundColor3 = tracerColor
		arm.BorderSizePixel = 0
		arm.Rotation = data[2] :: number
		arm.ZIndex = 113
		arm.Parent = arrow
		corner(arm, 3)
	end
	tracerArrows[model] = arrow
	return arrow
end

local function hideTracerVisuals()
	for _, line in pairs(tracerLines) do line.Visible = false end
	for _, arrow in pairs(tracerArrows) do arrow.Visible = false end
end

local function getLocalAimRoot(): (BasePart?, Humanoid?, Model?)
	local function findRoot(character: Model): BasePart?
		local root = character:FindFirstChild("HumanoidRootPart", true)
		if root and root:IsA("BasePart") then return root end
		local humanoid = character:FindFirstChildWhichIsA("Humanoid", true)
		if humanoid and humanoid.RootPart then return humanoid.RootPart end
		if character.PrimaryPart then return character.PrimaryPart end
		return getBodyPart(character, "RootPart", "Root")
	end
	local character = player.Character
	local root = if character then findRoot(character) else nil
	if root then
		return root, character:FindFirstChildWhichIsA("Humanoid", true), character
	end
	if charactersFolder then
		for _, descendant in ipairs(charactersFolder:GetDescendants()) do
			if descendant:IsA("Model") and isLocalPlayerModel(descendant) then
				local localRoot = findRoot(descendant)
				if localRoot then
					return localRoot, descendant:FindFirstChildWhichIsA("Humanoid", true), descendant
				end
			end
		end
	end
	return nil, nil, nil
end

local aimMuzzleNames = {"Muzzle", "MuzzleAttachment", "BarrelEnd", "FirePoint", "ShootPoint"}
local function getAimMuzzlePosition(character: Model): Vector3?
	local weapon = character:FindFirstChildWhichIsA("Tool")
	local searchRoot: Instance = weapon or character
	for _, name in ipairs(aimMuzzleNames) do
		local muzzle = searchRoot:FindFirstChild(name, true)
		if muzzle and muzzle:IsA("Attachment") then return muzzle.WorldPosition end
		if muzzle and muzzle:IsA("BasePart") then return muzzle.Position end
	end
	if weapon then
		local handle = weapon:FindFirstChild("Handle", true)
		if handle and handle:IsA("BasePart") then return handle.Position end
	end
	return nil
end

RunService:BindToRenderStep("KBACClientAim", Enum.RenderPriority.Last.Value, function()
	if not aimEnabled then return end

	local camera = workspace.CurrentCamera
	if not camera then
		setAimStatus("AIM: camera unavailable")
		lockedAimModel = nil
		restoreAimCameraControl()
		restoreAimAutoRotate()
		return
	end
	if savedAimCamera and savedAimCamera ~= camera then restoreAimCameraControl() end

	local viewport = camera.ViewportSize
	local overlaySize = aimOverlayRoot.AbsoluteSize
	local viewHeight = if overlaySize.Y > 2 then overlaySize.Y else viewport.Y
	local focalLength = if viewHeight > 2 then viewHeight / (2 * math.tan(math.rad(camera.FieldOfView) * 0.5)) else 0
	local aimCandidates = trackedHighlights

	local targetPart: BasePart? = nil
	if lockedAimModel then
		local humanoid = lockedAimModel:FindFirstChildWhichIsA("Humanoid", true)
		if lockedAimModel.Parent and aimCandidates[lockedAimModel] and (not humanoid or humanoid.Health > 0) then
			local highlightedParts = trackedPlayerParts[lockedAimModel]
			if lockedAimPart and highlightedParts and highlightedParts[lockedAimPart] and lockedAimPart.Parent then
				targetPart = lockedAimPart
			end
		else
			lockedAimModel = nil
			lockedAimPart = nil
		end
	end
	if lockedAimModel and not targetPart then
		lockedAimModel = nil
		lockedAimPart = nil
	end

	if not lockedAimModel then
		local closestDistance = aimRadius
		local nearestDistance = math.huge
		local candidateCount = 0
		for model in pairs(aimCandidates) do
			if model.Parent and not isLocalPlayerModel(model) then
				local humanoid = model:FindFirstChildWhichIsA("Humanoid", true)
				if not humanoid or humanoid.Health > 0 then
					local highlightedParts = trackedPlayerParts[model]
					if highlightedParts then
						for part in pairs(highlightedParts) do
							if part.Parent and part:IsDescendantOf(model) then
								candidateCount += 1
								local point = camera.CFrame:PointToObjectSpace(part.Position)
								if point.Z < -0.01 and focalLength > 0 then
									local distance = Vector2.new(point.X, point.Y).Magnitude * focalLength / -point.Z
									nearestDistance = math.min(nearestDistance, distance)
									if distance <= closestDistance then
										closestDistance = distance
										targetPart = part
										lockedAimModel = model
										lockedAimPart = part
									end
								end
							end
						end
					end
				end
			end
		end
		if not targetPart then
			if candidateCount == 0 then
				setAimStatus("AIM: no character parts found")
			elseif nearestDistance < math.huge then
				setAimStatus("AIM: nearest " .. math.round(nearestDistance) .. "px / circle " .. aimRadius .. "px")
			else
				setAimStatus("AIM: targets are behind camera")
			end
		end
	end

	if not targetPart or not targetPart.Parent then
		if not next(aimCandidates) then setAimStatus("AIM: no characters found") end
		lockedAimModel = nil
		lockedAimPart = nil
		restoreAimCameraControl()
		restoreAimAutoRotate()
		return
	end

	if savedAimCamera and not panel.Visible and UserInputService.MouseEnabled and os.clock() - aimLockStartedAt > 0.4 then
		aimMouseTravel += UserInputService:GetMouseDelta().Magnitude
		if aimMouseTravel >= 150 then
			setAimEnabled(false)
			setAimStatus("AIM: released by mouse")
			return
		end
	end

	local root, humanoid, character = getLocalAimRoot()
	local hasRoot = root ~= nil and root.Parent ~= nil
	if not savedAimCamera then
		savedAimCamera = camera
		savedAimCameraType = camera.CameraType
		savedAimMouseBehavior = UserInputService.MouseBehavior
		aimLockStartedAt = os.clock()
		aimMouseTravel = 0
	end
	if panel.Visible then
		aimLockStartedAt = os.clock()
		aimMouseTravel = 0
	end
	camera.CameraType = Enum.CameraType.Scriptable
	if UserInputService.MouseEnabled then
		UserInputService.MouseBehavior = if panel.Visible then Enum.MouseBehavior.Default else Enum.MouseBehavior.LockCenter
	end

	local aimPoint = targetPart.Position
	if humanoid ~= savedAimHumanoid then
		restoreAimAutoRotate()
		if humanoid then
			savedAimHumanoid = humanoid
			savedAutoRotate = humanoid.AutoRotate
			humanoid.AutoRotate = false
		end
	end

	if hasRoot and root then
		local horizontalTarget = Vector3.new(aimPoint.X, root.Position.Y, aimPoint.Z)
		local toTarget = horizontalTarget - root.Position
		local distance = toTarget.Magnitude
		if distance > 0.01 then
			local direction = toTarget / distance
			local muzzlePosition = if character then getAimMuzzlePosition(character) else nil
			if muzzlePosition then
				local rightOffset = root.CFrame:PointToObjectSpace(muzzlePosition).X
				if math.abs(rightOffset) < distance then
					local correction = -math.asin(rightOffset / distance)
					local right = Vector3.new(-direction.Z, 0, direction.X)
					direction = direction * math.cos(correction) + right * math.sin(correction)
				end
			end
			root.CFrame = CFrame.lookAt(root.Position, root.Position + direction)
		end
	end

	local cameraPosition = camera.CFrame.Position
	if hasRoot and root then
		if savedAimCameraOffset then
			cameraPosition = root.CFrame:PointToWorldSpace(savedAimCameraOffset)
		else
			savedAimCameraOffset = root.CFrame:PointToObjectSpace(cameraPosition)
		end
	end
	if (aimPoint - cameraPosition).Magnitude > 0.01 then
		camera.CFrame = CFrame.lookAt(cameraPosition, aimPoint)
		camera.Focus = CFrame.new(aimPoint)
	end
	setAimStatus(if hasRoot then "AIM: target locked" else "AIM: camera locked; character missing")
end)

RunService.RenderStepped:Connect(function()
	if not espEnabled and not tracerEnabled then return end
	local camera = workspace.CurrentCamera
	if not camera then return end
	local topLeftInset = GuiService:GetGuiInset()

	if espEnabled and espMode == "Box" then
		for model, box in pairs(trackedBoxes) do
			if not model.Parent then destroyTracked(model) continue end
			local boundingCFrame, boundingSize = model:GetBoundingBox()
			local half = boundingSize * 0.5
			local minX, minY = math.huge, math.huge
			local maxX, maxY = -math.huge, -math.huge
			local visibleCorners = 0
			for x = -1, 1, 2 do
				for y = -1, 1, 2 do
					for z = -1, 1, 2 do
						local point = boundingCFrame:PointToWorldSpace(Vector3.new(half.X * x, half.Y * y, half.Z * z))
						local screenPoint = camera:WorldToViewportPoint(point)
						if screenPoint.Z > 0 then
							visibleCorners += 1
							minX, minY = math.min(minX, screenPoint.X), math.min(minY, screenPoint.Y)
							maxX, maxY = math.max(maxX, screenPoint.X), math.max(maxY, screenPoint.Y)
						end
					end
				end
			end
			box.Visible = visibleCorners > 0
			if visibleCorners > 0 then
				box.Position = UDim2.fromOffset(minX - topLeftInset.X, minY - topLeftInset.Y)
				box.Size = UDim2.fromOffset(math.max(2, maxX - minX), math.max(2, maxY - minY))
			end
		end
	elseif espEnabled and espMode == "Skeleton" then
		for model, container in pairs(trackedSkeletons) do
			if not model.Parent then destroyTracked(model) continue end
			container.Visible = true
			for _, child in ipairs(container:GetChildren()) do
				if child:IsA("Frame") then child.Visible = false end
			end
			for index, pair in ipairs(getSkeletonPairs(model)) do
				local a = pair[1] :: BasePart
				local b = pair[2] :: BasePart
				local pointA = camera:WorldToViewportPoint(a.Position)
				local pointB = camera:WorldToViewportPoint(b.Position)
				if pointA.Z > 0 and pointB.Z > 0 then
					local ax, ay = pointA.X - topLeftInset.X, pointA.Y - topLeftInset.Y
					local bx, by = pointB.X - topLeftInset.X, pointB.Y - topLeftInset.Y
					local dx, dy = bx - ax, by - ay
					local line = ensureSkeletonLine(container, index)
					line.BackgroundColor3 = espColor
					line.Position = UDim2.fromOffset((ax + bx) * 0.5, (ay + by) * 0.5)
					line.Size = UDim2.fromOffset(math.sqrt(dx * dx + dy * dy), 1.5)
					line.Rotation = math.deg(math.atan2(dy, dx))
					line.Visible = true
				end
			end
		end
	end

	if tracerEnabled then
		local viewport = camera.ViewportSize
		local screenCenter = Vector2.new(viewport.X * 0.5 - topLeftInset.X, viewport.Y * 0.5 - topLeftInset.Y)
		local arrowRadius = math.min(viewport.X, viewport.Y) * 0.28
		local minX, minY = 14, 14
		local maxX = viewport.X - topLeftInset.X - 14
		local maxY = viewport.Y - topLeftInset.Y - 14
		local activeModels: {[Model]: boolean} = {}
		for model in pairs(trackedHighlights) do
			if model.Parent and model:FindFirstChildWhichIsA("BasePart", true) then
				activeModels[model] = true
				local modelCFrame = model:GetBoundingBox()
				local point = camera:WorldToViewportPoint(modelCFrame.Position)
				local target = Vector2.new(point.X - topLeftInset.X, point.Y - topLeftInset.Y)
				local direction = target - screenCenter
				if point.Z < 0 then direction = -direction end
				if direction.Magnitude < 0.001 then direction = Vector2.new(0, -1) end
				local unitDirection = direction.Unit
				local angle = math.deg(math.atan2(unitDirection.Y, unitDirection.X))
				local horizontalDistance = if unitDirection.X >= 0 then maxX - screenCenter.X else screenCenter.X - minX
				local verticalDistance = if unitDirection.Y >= 0 then maxY - screenCenter.Y else screenCenter.Y - minY
				local horizontalScale = horizontalDistance / math.max(math.abs(unitDirection.X), 0.0001)
				local verticalScale = verticalDistance / math.max(math.abs(unitDirection.Y), 0.0001)
				local edgeTarget = screenCenter + unitDirection * math.min(horizontalScale, verticalScale)
				local targetOnScreen = point.Z > 0
					and target.X >= minX and target.X <= maxX
					and target.Y >= minY and target.Y <= maxY
				local line = ensureTracerLine(model)
				local arrow = ensureTracerArrow(model)
				if tracerMode == "Classic" then
					arrow.Visible = false
					local endpoint = if targetOnScreen then target else edgeTarget
					local delta = endpoint - screenCenter
					line.BackgroundColor3 = tracerColor
					line.Position = UDim2.fromOffset((screenCenter.X + endpoint.X) * 0.5, (screenCenter.Y + endpoint.Y) * 0.5)
					line.Size = UDim2.fromOffset(delta.Magnitude, tracerThickness)
					line.Rotation = math.deg(math.atan2(delta.Y, delta.X))
					line.Visible = true
				else
					line.Visible = false
					local arrowPosition = screenCenter + unitDirection * arrowRadius
					arrow.Position = UDim2.fromOffset(arrowPosition.X, arrowPosition.Y)
					arrow.Size = UDim2.fromOffset(arrowSize, arrowSize)
					for _, child in ipairs(arrow:GetChildren()) do
						if child:IsA("Frame") then
							child.BackgroundColor3 = tracerColor
							child.Size = UDim2.new(0.68, 0, 0, math.max(2, arrowSize * 0.1))
						end
					end
					arrow.Rotation = angle
					arrow.Visible = true
				end
			end
		end
		for model, line in pairs(tracerLines) do
			if not activeModels[model] then
				line:Destroy()
				tracerLines[model] = nil
			end
		end
		for model, arrow in pairs(tracerArrows) do
			if not activeModels[model] then
				arrow:Destroy()
				tracerArrows[model] = nil
			end
		end
	end
end)

local cameraConnection: RBXScriptConnection? = nil
local function updateResponsiveScale()
	local camera = workspace.CurrentCamera
	if not camera then return end
	local viewport = camera.ViewportSize
	local availableWidth = math.max(viewport.X - 24, 280)
	local availableHeight = math.max(viewport.Y - 40, 300)
	responsiveScale = math.min(1, availableWidth / 570, availableHeight / 440)
	panelScale.Scale = responsiveScale
	openButton.Size = viewport.X < 500 and UDim2.fromOffset(52, 52) or UDim2.fromOffset(58, 58)
	if not launcherMoved then
		local x = viewport.X < 500 and 10 or 18
		local y = math.max(6, (viewport.Y - openButton.AbsoluteSize.Y) * 0.5)
		openButton.Position = UDim2.fromOffset(x, y)
	else
		local x = math.clamp(openButton.Position.X.Offset, 6, viewport.X - openButton.AbsoluteSize.X - 6)
		local y = math.clamp(openButton.Position.Y.Offset, 6, viewport.Y - openButton.AbsoluteSize.Y - 6)
		openButton.Position = UDim2.fromOffset(x, y)
	end
end

local function bindCamera()
	if cameraConnection then cameraConnection:Disconnect() end
	local camera = workspace.CurrentCamera
	if camera then
		cameraConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateResponsiveScale)
	end
	updateResponsiveScale()
end
bindCamera()
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindCamera)

local opened = false
local animating = false
local openPosition = UDim2.fromScale(0.5, 0.5)
local closedPosition = UDim2.fromScale(0.5, 0.54)
local motionTween = TweenInfo.new(0.34, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local function pressEffect(button: GuiButton)
	local original = button.Size
	local smaller = UDim2.new(original.X.Scale, original.X.Offset - 4, original.Y.Scale, original.Y.Offset - 4)
	TweenService:Create(button, TweenInfo.new(0.07), {Size = smaller}):Play()
	task.delay(0.08, function()
		if button.Parent then TweenService:Create(button, TweenInfo.new(0.12), {Size = original}):Play() end
	end)
end

local function setOpen(shouldOpen: boolean)
	if animating or opened == shouldOpen then return end
	animating = true
	opened = shouldOpen

	if shouldOpen then
		panel.Visible = true
		panel.Position = closedPosition
		panelScale.Scale = responsiveScale * 0.96
		TweenService:Create(panel, motionTween, {Position = openPosition}):Play()
		TweenService:Create(panelScale, motionTween, {Scale = responsiveScale}):Play()
		TweenService:Create(blur, motionTween, {Size = 16}):Play()
	else
		TweenService:Create(panel, motionTween, {Position = closedPosition}):Play()
		TweenService:Create(blur, motionTween, {Size = 0}):Play()
	end

	task.delay(0.36, function()
		if not shouldOpen and not opened then panel.Visible = false end
		animating = false
	end)
end

openButton.Activated:Connect(function()
	if launcherDragDistance > 6 then return end
	pressEffect(openButton)
	setOpen(not opened)
end)

closeButton.Activated:Connect(function()
	pressEffect(closeButton)
	setOpen(false)
end)

UserInputService.InputBegan:Connect(function(input: InputObject, processed: boolean)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.K then setOpen(not opened) end
end)

-- Start ESP only after the menu controls are connected. If a custom character
-- contains an unexpected object, the launcher must still remain usable.
task.defer(function()
	local ok, message = pcall(function()
		scanCharacters()
		updateColorUI()
	end)
	if not ok then warn("KBAC ESP initialization: " .. tostring(message)) end
end)

local function disableAutoLocalization(instance: Instance)
	if instance:IsA("GuiObject") then instance.AutoLocalize = false end
end
task.defer(function()
	for _, descendant in ipairs(gui:GetDescendants()) do disableAutoLocalization(descendant) end
end)
gui.DescendantAdded:Connect(disableAutoLocalization)

gui.Destroying:Connect(function()
	if cameraConnection then cameraConnection:Disconnect() end
	RunService:UnbindFromRenderStep("KBACClientAim")
	if aimOverlayGui.Parent then aimOverlayGui:Destroy() end
	restoreAimCameraControl()
	restoreAimAutoRotate()
	for model in pairs(trackedHighlights) do destroyTracked(model) end
	if effectsFolder.Parent then effectsFolder:Destroy() end
	if blur.Parent then blur:Destroy() end
end)
