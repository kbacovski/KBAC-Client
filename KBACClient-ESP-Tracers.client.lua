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
if oldGui then
	local previousAimBinding = oldGui:GetAttribute("AimRenderStepName")
	pcall(function()
		RunService:UnbindFromRenderStep(if type(previousAimBinding) == "string" then previousAimBinding else "KBACClientAim")
	end)
	local previousRivalsBinding = oldGui:GetAttribute("RivalsRenderStepName")
	if type(previousRivalsBinding) == "string" then
		pcall(function() RunService:UnbindFromRenderStep(previousRivalsBinding) end)
	end
	oldGui:Destroy()
end

local oldAimOverlay = playerGui:FindFirstChild("KBACAimOverlay")
if oldAimOverlay then oldAimOverlay:Destroy() end

local oldRivalsOverlay = playerGui:FindFirstChild("KBACRivalsOverlay")
if oldRivalsOverlay then oldRivalsOverlay:Destroy() end

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

-- Strong references retain GUI text bindings across Roblox garbage collection.
-- They are cleared with the GUI; changing language only updates displayed text.
local i18n = {
	Language = "en",
	Bindings = {} :: {[Instance]: string},
	OnChanged = nil :: (() -> ())?,
	Russian = {
		["KBAC CLIENT"] = "КЛИЕНТ КБАК",
		["K"] = "К",
		["RIVALS"] = "РИВАЛС",
		["BloxStrike"] = "БлоксСтрайк",
		["English"] = "Английский",
		["AIM"] = "НАВЕДЕНИЕ",
		["ESP"] = "ПОДСВЕТКА",
		["NOCLIP"] = "СКВОЗЬ СТЕНЫ",
		["INFINITE JUMP"] = "БЕСКОНЕЧНЫЙ ПРЫЖОК",
		["Walk through walls"] = "Проход сквозь стены",
		["Jump again while in the air"] = "Повторный прыжок в воздухе",
		["OTHER"] = "ДРУГОЕ",
		["COMBAT"] = "БОЙ",
		["VISUALS"] = "ВИЗУАЛ",
		["Functions designed for RIVALS"] = "Функции для Ривалс",
		["Functions designed for BloxStrike"] = "Функции для БлоксСтрайк",
		["Interface and general settings"] = "Интерфейс и общие настройки",
		["Shooter Control Center · RIVALS"] = "Панель управления · Ривалс",
		["No functions added yet"] = "Пока нет функций",
		["No combat functions added yet"] = "Боевые функции пока не добавлены",
		["No other functions added yet"] = "Другие функции пока не добавлены",
		["Player highlighting"] = "Подсветка игроков",
		["ESP MODE"] = "РЕЖИМ ПОДСВЕТКИ",
		["PLAYER"] = "ИГРОК",
		["BOX"] = "РАМКА",
		["SKELETON"] = "СКЕЛЕТ",
		["COLOR"] = "ЦВЕТ",
		["TRACERS"] = "ТРЕЙСЕРЫ",
		["Direction indicators for players"] = "Указатели направления к игрокам",
		["MODE"] = "РЕЖИМ",
		["CLASSIC"] = "ЛИНИИ",
		["ARROWS"] = "СТРЕЛКИ",
		["THICKNESS / SIZE"] = "ТОЛЩИНА / РАЗМЕР",
		["Temporarily unavailable"] = "Временно недоступен",
		["HITBOX"] = "ХИТБОКС",
		["Other players' head size"] = "Размер голов других игроков",
		["HEAD SIZE"] = "РАЗМЕР ГОЛОВЫ",
		["ON"] = "ВКЛ",
		["OFF"] = "ВЫКЛ",
		["Head aim · close the menu to use"] = "В голову · работает при закрытом меню",
		["TARGET SELECTION"] = "ВЫБОР ЦЕЛИ",
		["Nearest"] = "Ближайшая",
		["In circle"] = "В круге",
		["Until death"] = "До смерти",
		["Nearest target in any direction (360°). Respects the wall setting; ignores the circle."] = "Ближайшая цель в любом направлении (360°). Учитывает стены, но не круг.",
		["Selects a head near the center and holds it inside the circle. Respects the wall setting."] = "Выбирает голову у центра и удерживает внутри круга. Учитывает настройку стен.",
		["Acquires inside the circle, holds until death. Pauses behind walls unless they are ignored."] = "Захват в круге, удержание до смерти. За стеной пауза, если стены не игнорируются.",
		["CIRCLE RADIUS"] = "РАДИУС КРУГА",
		["CIRCLE COLOR"] = "ЦВЕТ КРУГА",
		["ENEMIES ONLY"] = "ТОЛЬКО ПРОТИВНИКИ",
		["IGNORE WALLS"] = "ИГНОРИРОВАТЬ СТЕНЫ",
		["TURN CHARACTER"] = "ПОВОРОТ ПЕРСОНАЖА",
		["SHOW AIM BUTTON"] = "КНОПКА НАВЕДЕНИЯ",
		["Outline and soft player fill"] = "Подсветка силуэта и мягкая заливка",
		["HIGHLIGHT COLOR"] = "ЦВЕТ ПОДСВЕТКИ",
		["TRANSPARENCY"] = "ПРОЗРАЧНОСТЬ",
		["Direction lines to players"] = "Линии направления к игрокам",
		["LINE COLOR"] = "ЦВЕТ ЛИНИЙ",
		["THICKNESS"] = "ТОЛЩИНА",
		["LANGUAGE"] = "ЯЗЫК",
		["Choose the interface language"] = "Выбери язык интерфейса",
		["Applies to all tabs. Your settings stay the same."] = "Для всех вкладок. Твои настройки сохраняются.",
	},
}

function i18n.Text(instance: any, english: string)
	local russian = i18n.Russian[english]
	i18n.Bindings[instance] = if russian then english else nil
	instance.AutoLocalize = false
	instance.Text = if i18n.Language == "ru" and russian then russian else english
end

function i18n.SetLanguage(language: string)
	if language ~= "en" and language ~= "ru" then return end
	i18n.Language = language
	for instance, english in pairs(i18n.Bindings) do
		(instance :: any).Text = if language == "ru" then i18n.Russian[english] else english
	end
	if i18n.OnChanged then i18n.OnChanged() end
end
-- END LOCALIZATION

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
gui:SetAttribute("ClientBuild", "ui-snow-bounds-3")
gui:SetAttribute("AimStatus", "Temporarily unavailable")
gui:SetAttribute("HitboxEnabled", false)

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
i18n.Text(openButton, "K")
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

-- Decorative snow stays behind the controls and never handles input.
local function setupMenuSnow()
	local layer = Instance.new("Frame")
	layer.Name = "SnowBackground"
	layer.Size = UDim2.fromScale(1, 1)
	layer.BackgroundTransparency = 1
	layer.BorderSizePixel = 0
	layer.ClipsDescendants = true
	layer.Active = false
	layer.Selectable = false
	layer.ZIndex = 12
	layer.Parent = panel
	local flakes = {}
	local random = Random.new()
	local columns, rows = 6, 4
	-- Work in menu coordinates so UIScale scales particles and bounds together.
	local width, height = panel.Size.X.Offset, panel.Size.Y.Offset
	local cornerRadius = 31
	local elapsed = 0
	local function startX(column: number): number
		local margin = cornerRadius + 6
		return (margin + (width - margin * 2) * (column + random:NextNumber(0.08, 0.92)) / columns) / width
	end
	local function draw(flake)
		local drift = math.sin(elapsed * 0.65 + flake.Phase) * 0.018
		local x, y = (flake.X + drift) * width, flake.Y * height
		-- Distance to the rounded panel boundary. Never rely on clipping rotated GUI objects.
		local qx = math.abs(x - width * 0.5) - (width * 0.5 - cornerRadius)
		local qy = math.abs(y - height * 0.5) - (height * 0.5 - cornerRadius)
		local outside = math.sqrt(math.max(qx, 0)^2 + math.max(qy, 0)^2)
		local clearance = cornerRadius - outside - math.min(math.max(qx, qy), 0) - flake.Radius
		flake.Object.Visible = flake.Delay <= 0 and clearance > 0
		if not flake.Object.Visible then return end
		flake.Object.Position = UDim2.fromScale(x / width, flake.Y)
		flake.Object.Rotation = (elapsed * flake.Spin + flake.Phase * 20) % 360
		local opacity = math.clamp(clearance / 12, 0, 1)
		for _, item in ipairs(flake.Lines) do
			item.BackgroundTransparency = 1 - (1 - flake.Alpha) * opacity
		end
	end
	local function line(parent: Instance, y: number, length: number, rotation: number, alpha: number)
		local item = Instance.new("Frame")
		item.AnchorPoint = Vector2.new(0.5, 0.5)
		item.Position = UDim2.fromScale(0.5, y)
		item.Size = UDim2.fromOffset(1, length)
		item.Rotation = rotation
		item.BackgroundColor3 = Color3.fromRGB(220, 236, 255)
		item.BackgroundTransparency = alpha
		item.BorderSizePixel = 0
		item.Active = false
		item.Selectable = false
		item.ZIndex = 12
		item.Parent = parent
		return item
	end
	for index = 1, columns * rows do
		local size = 7 + (index % 6) * 2
		local flake = Instance.new("Frame")
		flake.Name = "Snowflake"
		flake.AnchorPoint = Vector2.new(0.5, 0.5)
		flake.Size = UDim2.fromOffset(size, size)
		flake.BackgroundTransparency = 1
		flake.Visible = false
		flake.Active = false
		flake.Selectable = false
		flake.ZIndex = 12
		flake.Parent = layer
		local lines = {}
		local alpha = 0.44 + (index % 4) * 0.09
		for axis = 0, 2 do
			local stem = line(flake, 0.5, size, axis * 60, alpha)
			table.insert(lines, stem)
			if size >= 13 then
				for _, y in ipairs({0.22, 0.78}) do
					table.insert(lines, line(stem, y, size * 0.32, -45, alpha))
					table.insert(lines, line(stem, y, size * 0.32, 45, alpha))
				end
			end
		end
		-- Independent jitter in each grid cell fills the whole background immediately.
		local column, row = (index - 1) % columns, math.floor((index - 1) / columns)
		local margin = cornerRadius + 6
		local y = (margin + (height - margin * 2) * (row + random:NextNumber(0.08, 0.92)) / rows) / height
		local flakeState = {Object = flake, Lines = lines, Alpha = alpha,
			X = startX(column), Y = y, Column = column, Radius = size * 0.75 + 2,
			Phase = random:NextNumber(0, math.pi * 2), Speed = random:NextNumber(0.035, 0.075),
			Spin = random:NextNumber(5, 10) * (index % 2 == 0 and 1 or -1), Delay = 0}
		table.insert(flakes, flakeState)
		draw(flakeState)
	end
	local connection = RunService.RenderStepped:Connect(function(deltaTime: number)
		if not panel.Visible then return end
		local step = math.clamp(deltaTime, 0, 0.05)
		elapsed += step
		for _, flake in ipairs(flakes) do
			if flake.Delay > 0 then
				flake.Delay -= step
				if flake.Delay <= 0 then
					flake.X = startX(flake.Column)
					flake.Y = 0
					flake.Phase = random:NextNumber(0, math.pi * 2)
				end
			else
				flake.Y += flake.Speed * step
				if flake.Y * height >= height - flake.Radius then
					flake.Delay = random:NextNumber(0.15, 0.7)
				end
			end
			draw(flake)
		end
	end)
	gui.Destroying:Connect(function()
		connection:Disconnect()
		table.clear(flakes)
	end)
end
setupMenuSnow()
-- END MENU SNOW

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Position = UDim2.fromOffset(28, 18)
title.Size = UDim2.new(1, -100, 0, 31)
title.BackgroundTransparency = 1
i18n.Text(title, "KBAC CLIENT")
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
i18n.Text(subtitle, "Shooter Control Center · RIVALS")
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
i18n.Text(closeButton, "×")
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
	i18n.Text(pageTitle, heading)
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
	i18n.Text(descriptionLabel, description)
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
	i18n.Text(empty, "No functions added yet")
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
	i18n.Text(button, text)
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
createPage("OTHER", "OTHER", "Interface and general settings")

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
switchTab("BloxStrike")

--============================================================
-- BLOXSTRIKE ESP
-- Targets every character model inside Workspace.Characters,
-- including models in its nested team folders.
--============================================================

pages["BloxStrike"].EmptyText.Visible = false

local bloxModules = pages["BloxStrike"].Modules
-- The game tab already names this page. Its repeated header pushed the
-- second Combat card almost entirely below the visible scrolling area.
local bloxHeader = bloxModules:FindFirstChild("PageHeader")
if bloxHeader and bloxHeader:IsA("Frame") then bloxHeader.Visible = false end
local selectedBloxCategory = "Combat"
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
i18n.Text(combatEmpty, "No combat functions added yet")
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
i18n.Text(otherEmpty, "No other functions added yet")
otherEmpty.Visible = false
otherEmpty.Parent = bloxModules

local function createCategoryButton(name: string, order: number)
	local button = Instance.new("TextButton")
	button.Name = name .. "Category"
	button.Size = UDim2.new(1 / 3, -7, 1, 0)
	button.BackgroundColor3 = Color3.fromRGB(13, 16, 22)
	button.BackgroundTransparency = name == selectedBloxCategory and 0.38 or 1
	button.BorderSizePixel = 0
	i18n.Text(button, string.upper(name))
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

-- HITBOX scales actual Head parts from their saved original size.
-- It changes the local client only; the game's server decides hit registration.
type HitboxHeadState = {
	Model: Model,
	Size: Vector3,
	CanCollide: boolean,
	CanQuery: boolean,
	Massless: boolean,
	Mesh: SpecialMesh?,
	MeshScale: Vector3?,
}
local hitbox = {
	Enabled = false,
	Multiplier = 3,
	Originals = {} :: {[BasePart]: HitboxHeadState},
	InactiveModels = setmetatable({}, {__mode = "k"}) :: {[Model]: boolean},
	Characters = {} :: {[Player]: Model},
}

function hitbox.ClearHeadBackup(head: BasePart)
	for _, name in ipairs({"Size", "CanCollide", "CanQuery", "Massless"}) do
		head:SetAttribute("KBAC_HitboxBase" .. name, nil)
	end
end

function hitbox.RestoreInherited(instance: Instance)
	-- A ragdoll can be cloned before the live model is removed. Its parts
	-- are new instances, so the Originals table cannot identify them. Keep
	-- the baseline on the modified parts as well, so Clone carries it over.
	if instance:IsA("BasePart") then
		if hitbox.Originals[instance] then return end
		local size = instance:GetAttribute("KBAC_HitboxBaseSize")
		if typeof(size) ~= "Vector3" then return end
		instance.Size = size
		for _, property in ipairs({"CanCollide", "CanQuery", "Massless"}) do
			local saved = instance:GetAttribute("KBAC_HitboxBase" .. property)
			if type(saved) == "boolean" then (instance :: any)[property] = saved end
		end
		hitbox.ClearHeadBackup(instance)
		for _, child in ipairs(instance:GetChildren()) do
			if child:IsA("SpecialMesh") then hitbox.RestoreInherited(child) end
		end
	elseif instance:IsA("SpecialMesh") then
		local parent = instance.Parent
		if parent and parent:IsA("BasePart") then
			local original = hitbox.Originals[parent]
			if original and original.Mesh == instance then return end
		end
		local scale = instance:GetAttribute("KBAC_HitboxBaseScale")
		if typeof(scale) == "Vector3" then
			instance.Scale = scale
			instance:SetAttribute("KBAC_HitboxBaseScale", nil)
		end
	end
end

function hitbox.RestoreHead(head: BasePart)
	local original = hitbox.Originals[head]
	if not original then return end
	-- A detached head may be reparented into a corpse later. Restore it even
	-- while Parent is nil rather than discarding its only saved baseline.
	head.Size = original.Size
	head.CanCollide = original.CanCollide
	head.CanQuery = original.CanQuery
	head.Massless = original.Massless
	hitbox.ClearHeadBackup(head)
	if original.Mesh and original.MeshScale then
		original.Mesh.Scale = original.MeshScale
		original.Mesh:SetAttribute("KBAC_HitboxBaseScale", nil)
	end
	hitbox.Originals[head] = nil
end

function hitbox.RestoreAll()
	for head in pairs(hitbox.Originals) do hitbox.RestoreHead(head) end
end

function hitbox.RestoreModel(model: Model)
	for head, original in pairs(hitbox.Originals) do
		if original.Model == model then hitbox.RestoreHead(head) end
	end
end

function hitbox.RetireModel(model: Model)
	-- A corpse may keep its player name and stay in Workspace after removal.
	-- Keep it excluded so the next heartbeat cannot enlarge it again.
	hitbox.InactiveModels[model] = true
	hitbox.RestoreModel(model)
end

function hitbox.CharacterAdded(owner: Player, model: Model)
	local previous = hitbox.Characters[owner]
	if previous and previous ~= model then hitbox.RetireModel(previous) end
	hitbox.Characters[owner] = model
	hitbox.InactiveModels[model] = nil
end

function hitbox.CharacterRemoving(owner: Player, model: Model)
	hitbox.RetireModel(model)
	if hitbox.Characters[owner] == model then hitbox.Characters[owner] = nil end
end

function hitbox.HasDeathSignal(instance: Instance): boolean
	-- Custom characters can expose state without a Humanoid. Missing values
	-- are unknown, not a death signal; only explicit values disable scaling.
	for _, name in ipairs({"Dead", "IsDead", "Alive", "IsAlive", "Health", "CurrentHealth", "State"}) do
		local function isDead(value): boolean
			if name == "Dead" or name == "IsDead" then return value == true end
			if name == "Alive" or name == "IsAlive" then return value == false end
			if name == "Health" or name == "CurrentHealth" then return type(value) == "number" and value <= 0 end
			return type(value) == "string" and (string.lower(value) == "dead" or string.lower(value) == "eliminated")
		end
		if isDead(instance:GetAttribute(name)) then return true end
		local child = instance:FindFirstChild(name)
		if child and (child:IsA("BoolValue") or child:IsA("NumberValue") or child:IsA("IntValue") or child:IsA("StringValue"))
			and isDead(child.Value) then return true end
	end
	return false
end

function hitbox.FindHead(model: Model): BasePart?
	local direct = model:FindFirstChild("Head")
	if direct and direct:IsA("BasePart") then return direct end
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") and string.lower(part.Name) == "head" then
			local ancestor: Instance? = part.Parent
			local isBody = true
			while ancestor and ancestor ~= model do
				if ancestor:IsA("Accessory") or ancestor:IsA("Tool") or ancestor.Name == "WeaponModel" then
					isBody = false
					break
				end
				ancestor = ancestor.Parent
			end
			if isBody then return part end
		end
	end
	return nil
end

function hitbox.IsPlayerTarget(model: Model, currentPlayers: {Player}): boolean
	if hitbox.InactiveModels[model] or isLocalPlayerModel(model) or not model:IsDescendantOf(workspace)
		or hitbox.HasDeathSignal(model) then return false end
	local ownerId = model:GetAttribute("UserId") or model:GetAttribute("PlayerUserId")
	for _, other in ipairs(currentPlayers) do
		if other ~= player and (other.Character == model or model.Name == other.Name
			or model.Name == other.DisplayName or ownerId == other.UserId) then
			-- Prefer the current character over an old model with the same name.
			if other.Character and other.Character ~= model then continue end
			if not hitbox.HasDeathSignal(other) then return true end
		end
	end
	return false
end

function hitbox.Apply(head: BasePart, model: Model)
	local original = hitbox.Originals[head]
	if not original then
		-- If a cloned character becomes a new live character, normalize it
		-- before saving its baseline to avoid multiplying an enlarged size.
		hitbox.RestoreInherited(head)
		original = {
			Model = model, Size = head.Size,
			CanCollide = head.CanCollide, CanQuery = head.CanQuery, Massless = head.Massless,
		}
		hitbox.Originals[head] = original
		head:SetAttribute("KBAC_HitboxBaseSize", original.Size)
		head:SetAttribute("KBAC_HitboxBaseCanCollide", original.CanCollide)
		head:SetAttribute("KBAC_HitboxBaseCanQuery", original.CanQuery)
		head:SetAttribute("KBAC_HitboxBaseMassless", original.Massless)
	end
	local mesh = head:FindFirstChildWhichIsA("SpecialMesh")
	if mesh and mesh.MeshType ~= Enum.MeshType.FileMesh then mesh = nil end
	if original.Mesh ~= mesh then
		if original.Mesh and original.MeshScale then
			original.Mesh.Scale = original.MeshScale
			original.Mesh:SetAttribute("KBAC_HitboxBaseScale", nil)
		end
		if mesh then hitbox.RestoreInherited(mesh) end
		original.Mesh = mesh
		original.MeshScale = if mesh then mesh.Scale else nil
		if mesh then mesh:SetAttribute("KBAC_HitboxBaseScale", original.MeshScale) end
	end
	-- File meshes have an independent visual scale; MeshParts follow Size.
	local targetSize = original.Size * hitbox.Multiplier
	if head.Size ~= targetSize then head.Size = targetSize end
	head.CanCollide = false
	head.CanQuery = true
	head.Massless = true
	if mesh and original.MeshScale then
		local targetScale = original.MeshScale * hitbox.Multiplier
		if mesh.Scale ~= targetScale then mesh.Scale = targetScale end
	end
end

function hitbox.Sync(): number
	if not hitbox.Enabled or hitbox.Multiplier <= 1 then
		hitbox.RestoreAll()
		return 0
	end
	local activeHeads: {[BasePart]: boolean} = {}
	local currentPlayers = Players:GetPlayers()
	local count = 0
	for model in pairs(trackedHighlights) do
		if model.Parent and charactersFolder and model:IsDescendantOf(charactersFolder)
			and hitbox.IsPlayerTarget(model, currentPlayers) then
			local humanoid = model:FindFirstChildWhichIsA("Humanoid", true)
			if not humanoid or humanoid.Health > 0 then
				local head = hitbox.FindHead(model)
				if head and head.Parent and not activeHeads[head] then
					activeHeads[head] = true
					hitbox.Apply(head, model)
					count += 1
				end
			end
		end
	end
	for head in pairs(hitbox.Originals) do
		if not activeHeads[head] then hitbox.RestoreHead(head) end
	end
	return count
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
	hitbox.RestoreModel(model)
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
			hitbox.RetireModel(model)
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
		if descendant:IsA("Model") then
			if looksLikeCharacter(descendant) then
				currentModels[descendant] = true
				trackModel(descendant)
			end
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
stroke(card, 0.62, 1)

local cardButton = Instance.new("TextButton")
cardButton.Name = "OpenSettings"
cardButton.Size = UDim2.new(1, -78, 0, 68)
cardButton.BackgroundTransparency = 1
cardButton.BorderSizePixel = 0
i18n.Text(cardButton, "")
cardButton.AutoButtonColor = false
cardButton.ZIndex = 18
cardButton.Parent = card

local espTitle = Instance.new("TextLabel")
espTitle.Position = UDim2.fromOffset(18, 10)
espTitle.Size = UDim2.new(1, -55, 0, 25)
espTitle.BackgroundTransparency = 1
i18n.Text(espTitle, "ESP")
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
i18n.Text(espDescription, "Player highlighting")
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
i18n.Text(toggle, "")
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
i18n.Text(modeLabel, "ESP MODE")
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
	i18n.Text(button, text)
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
i18n.Text(colorTitle, "COLOR")
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
	i18n.Text(button, "")
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
i18n.Text(tracerOpen, "")
tracerOpen.AutoButtonColor = false
tracerOpen.ZIndex = 18
tracerOpen.Parent = tracerCard

local tracerTitle = Instance.new("TextLabel")
tracerTitle.Position = UDim2.fromOffset(18, 10)
tracerTitle.Size = UDim2.new(1, -35, 0, 25)
tracerTitle.BackgroundTransparency = 1
i18n.Text(tracerTitle, "TRACERS")
tracerTitle.TextColor3 = COLORS.text
tracerTitle.TextSize = 18
tracerTitle.Font = Enum.Font.GothamBold
tracerTitle.TextXAlignment = Enum.TextXAlignment.Left
tracerTitle.ZIndex = 19
tracerTitle.Parent = tracerOpen

local tracerDescription = tracerTitle:Clone()
tracerDescription.Position = UDim2.fromOffset(18, 35)
tracerDescription.Size = UDim2.new(1, -35, 0, 19)
i18n.Text(tracerDescription, "Direction indicators for players")
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
i18n.Text(tracerToggle, "")
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
i18n.Text(tracerModeLabel, "MODE")
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
	i18n.Text(button, text)
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
i18n.Text(tracerColorLabel, "COLOR")
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
	i18n.Text(dot, "")
	dot.AutoButtonColor = false
	dot.ZIndex = 21
	dot.Parent = tracerPalette
	corner(dot, 12)
	stroke(dot, 0.55)
	dot.Activated:Connect(function() tracerColor = color end)
end

local sizeLabel = tracerModeLabel:Clone()
sizeLabel.Position = UDim2.fromOffset(12, 119)
i18n.Text(sizeLabel, "THICKNESS / SIZE")
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
		BackgroundColor3 = tracerEnabled and Color3.fromRGB(23, 126, 76) or Color3.fromRGB(104, 112, 127),
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

-- AIM is intentionally unavailable until the custom character controller is understood.
local aimCard = Instance.new("Frame")
aimCard.Name = "AimCard"
aimCard.Size = UDim2.new(1, -10, 0, 68)
aimCard.BackgroundColor3 = Color3.fromRGB(44, 54, 71)
aimCard.BackgroundTransparency = 0.65
aimCard.BorderSizePixel = 0
aimCard.LayoutOrder = 3
aimCard.Visible = false
aimCard.ZIndex = 17
aimCard.Parent = bloxModules
corner(aimCard, 18)
stroke(aimCard, 0.62, 1)
do
	local title = tracerTitle:Clone()
	i18n.Text(title, "AIM")
	title.TextTransparency = 0.4
	title.Parent = aimCard
	local description = tracerDescription:Clone()
	i18n.Text(description, "Temporarily unavailable")
	description.TextTransparency = 0.2
	description.Size = UDim2.new(1, -90, 0, 19)
	description.Parent = aimCard
	local disabledToggle = tracerToggle:Clone()
	disabledToggle.Name = "AimUnavailable"
	disabledToggle.Active = false
	disabledToggle.Selectable = false
	disabledToggle.BackgroundTransparency = 0.65
	disabledToggle.Parent = aimCard
	local knob = disabledToggle:FindFirstChildWhichIsA("Frame")
	if knob then knob.BackgroundTransparency = 0.55 end
end

local hitboxCard = Instance.new("Frame")
hitboxCard.Name = "HitboxCard"
hitboxCard.Size = UDim2.new(1, -10, 0, 68)
hitboxCard.BackgroundColor3 = Color3.fromRGB(44, 54, 71)
hitboxCard.BackgroundTransparency = 0.5
hitboxCard.BorderSizePixel = 0
hitboxCard.ClipsDescendants = true
hitboxCard.LayoutOrder = 2
hitboxCard.Visible = false
hitboxCard.ZIndex = 17
hitboxCard.Parent = bloxModules
corner(hitboxCard, 18)
stroke(hitboxCard, 0.62, 1)

local hitboxConnections: {RBXScriptConnection} = {}
do
	local expanded = false
	local open = Instance.new("TextButton")
	open.Name = "OpenHitboxSettings"
	open.Size = UDim2.new(1, -78, 0, 68)
	open.BackgroundTransparency = 1
	i18n.Text(open, "")
	open.AutoButtonColor = false
	open.ZIndex = 18
	open.Parent = hitboxCard
	local title = tracerTitle:Clone()
	i18n.Text(title, "HITBOX")
	title.Parent = open
	local description = tracerDescription:Clone()
	i18n.Text(description, "Other players' head size")
	description.Parent = open
	local button = tracerToggle:Clone()
	button.Name = "HitboxToggle"
	button.Parent = hitboxCard
	local knob = button:FindFirstChildWhichIsA("Frame") :: Frame

	local settingsPanel = Instance.new("Frame")
	settingsPanel.Name = "HitboxSettings"
	settingsPanel.Position = UDim2.fromOffset(12, 76)
	settingsPanel.Size = UDim2.new(1, -24, 0, 78)
	settingsPanel.BackgroundColor3 = Color3.fromRGB(25, 32, 46)
	settingsPanel.BackgroundTransparency = 0.54
	settingsPanel.BorderSizePixel = 0
	settingsPanel.Visible = false
	settingsPanel.ZIndex = 18
	settingsPanel.Parent = hitboxCard
	corner(settingsPanel, 15)
	stroke(settingsPanel, 0.58)
	local label = tracerModeLabel:Clone()
	label.Position = UDim2.fromOffset(12, 9)
	label.Size = UDim2.new(1, -170, 0, 24)
	i18n.Text(label, "HEAD SIZE")
	label.Parent = settingsPanel
	local value = label:Clone()
	value.Name = "HeadSizeValue"
	value.Position = UDim2.new(1, -109, 0, 9)
	value.Size = UDim2.fromOffset(60, 24)
	value.TextXAlignment = Enum.TextXAlignment.Center
	value.Parent = settingsPanel

	local function stepButton(text: string, x: number): TextButton
		local item = Instance.new("TextButton")
		item.Size = UDim2.fromOffset(28, 26)
		item.Position = UDim2.new(1, x, 0, 8)
		item.BackgroundColor3 = Color3.fromRGB(46, 55, 70)
		item.BackgroundTransparency = 0.3
		item.TextColor3 = COLORS.white
		item.TextSize = 20
		i18n.Text(item, text)
		item.Font = Enum.Font.GothamSemibold
		item.ZIndex = 22
		item.Parent = settingsPanel
		corner(item, 7)
		stroke(item, 0.65)
		return item
	end
	local minus = stepButton("−", -143)
	local plus = stepButton("+", -40)
	local track = Instance.new("Frame")
	track.Position = UDim2.fromOffset(14, 55)
	track.Size = UDim2.new(1, -28, 0, 6)
	track.BackgroundColor3 = Color3.fromRGB(105, 114, 130)
	track.BackgroundTransparency = 0.35
	track.BorderSizePixel = 0
	track.ZIndex = 20
	track.Parent = settingsPanel
	corner(track, 3)
	local fill = Instance.new("Frame")
	fill.BackgroundColor3 = Color3.fromRGB(255, 70, 82)
	fill.BorderSizePixel = 0
	fill.ZIndex = 21
	fill.Parent = track
	corner(fill, 3)
	local thumb = Instance.new("Frame")
	thumb.AnchorPoint = Vector2.new(0.5, 0.5)
	thumb.Size = UDim2.fromOffset(18, 18)
	thumb.BackgroundColor3 = COLORS.white
	thumb.BorderSizePixel = 0
	thumb.ZIndex = 22
	thumb.Parent = track
	corner(thumb, 9)
	local hit = Instance.new("Frame")
	hit.AnchorPoint = Vector2.new(0, 0.5)
	hit.Position = UDim2.fromScale(0, 0.5)
	hit.Size = UDim2.new(1, 0, 0, 32)
	hit.BackgroundTransparency = 1
	hit.Active = true
	hit.ZIndex = 23
	hit.Parent = track

	local function refreshSize()
		local alpha = (hitbox.Multiplier - 1) / 19
		value.Text = string.format("%.1f×", hitbox.Multiplier)
		fill.Size = UDim2.new(alpha, 0, 1, 0)
		thumb.Position = UDim2.new(alpha, 0, 0.5, 0)
		gui:SetAttribute("HitboxMultiplier", hitbox.Multiplier)
	end
	local function setSize(multiplier: number)
		hitbox.Multiplier = math.clamp(math.round(multiplier * 2) / 2, 1, 20)
		refreshSize()
		if hitbox.Enabled then hitbox.Sync() refreshESPVisuals() end
	end
	local function setFromX(x: number)
		local alpha = math.clamp((x - track.AbsolutePosition.X) / math.max(1, track.AbsoluteSize.X), 0, 1)
		setSize(1 + alpha * 19)
	end
	local dragInput: InputObject? = nil
	hit.InputBegan:Connect(function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
			setFromX(input.Position.X)
		end
	end)
	table.insert(hitboxConnections, UserInputService.InputChanged:Connect(function(input: InputObject)
		if dragInput and (input == dragInput or input.UserInputType == Enum.UserInputType.MouseMovement) then
			setFromX(input.Position.X)
		end
	end))
	table.insert(hitboxConnections, UserInputService.InputEnded:Connect(function(input: InputObject)
		if input == dragInput or input.UserInputType == Enum.UserInputType.MouseButton1 then dragInput = nil end
	end))
	minus.Activated:Connect(function() setSize(hitbox.Multiplier - 0.5) end)
	plus.Activated:Connect(function() setSize(hitbox.Multiplier + 0.5) end)
	button.Activated:Connect(function()
		hitbox.Enabled = not hitbox.Enabled
		gui:SetAttribute("HitboxEnabled", hitbox.Enabled)
		TweenService:Create(button, quickTween, {
			BackgroundColor3 = hitbox.Enabled and Color3.fromRGB(23, 126, 76) or Color3.fromRGB(104, 112, 127),
			BackgroundTransparency = hitbox.Enabled and 0.42 or 0.18,
		}):Play()
		TweenService:Create(knob, quickTween, {
			Position = UDim2.fromOffset(if hitbox.Enabled then 25 else 3, 3),
		}):Play()
		if hitbox.Enabled then scanCharacters() end
		gui:SetAttribute("HitboxCount", hitbox.Sync())
		refreshESPVisuals()
	end)
	open.Activated:Connect(function()
		expanded = not expanded
		settingsPanel.Visible = true
		TweenService:Create(hitboxCard, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = UDim2.new(1, -10, 0, if expanded then 166 else 68),
		}):Play()
		if not expanded then task.delay(0.25, function() if not expanded then settingsPanel.Visible = false end end) end
	end)
	refreshSize()
end
local hitboxHeartbeat = RunService.Heartbeat:Connect(function()
	if hitbox.Enabled and gui.Parent then gui:SetAttribute("HitboxCount", hitbox.Sync()) end
end)

local function switchBloxCategory(name: string)
	selectedBloxCategory = name
	bloxModules.CanvasPosition = Vector2.zero
	card.Visible = name == "Visuals"
	tracerCard.Visible = name == "Visuals"
	aimCard.Visible = name == "Combat"
	hitboxCard.Visible = name == "Combat"
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
switchBloxCategory("Combat")

toggle.Activated:Connect(function()
	espEnabled = not espEnabled
	TweenService:Create(toggle, quickTween, {
		BackgroundColor3 = espEnabled and Color3.fromRGB(23, 126, 76) or Color3.fromRGB(50, 55, 66),
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

local playerConnections: {[Player]: {RBXScriptConnection}} = {}
local function unhookPlayer(otherPlayer: Player)
	local connections = playerConnections[otherPlayer]
	if connections then
		for _, connection in ipairs(connections) do connection:Disconnect() end
	end
	playerConnections[otherPlayer] = nil
	local character = hitbox.Characters[otherPlayer] or otherPlayer.Character
	if character then hitbox.CharacterRemoving(otherPlayer, character) end
end

local function hookPlayer(otherPlayer: Player)
	if playerConnections[otherPlayer] then return end
	playerConnections[otherPlayer] = {
		otherPlayer:GetPropertyChangedSignal("Team"):Connect(scheduleESPRescans),
		otherPlayer.CharacterAdded:Connect(function(model: Model)
			hitbox.CharacterAdded(otherPlayer, model)
			scheduleESPRescans()
		end),
		otherPlayer.CharacterRemoving:Connect(function(model: Model)
			hitbox.CharacterRemoving(otherPlayer, model)
			scheduleESPRescans()
		end),
	}
	if otherPlayer.Character then hitbox.CharacterAdded(otherPlayer, otherPlayer.Character) end
	scheduleESPRescans()
end

for _, otherPlayer in ipairs(Players:GetPlayers()) do hookPlayer(otherPlayer) end
table.insert(hitboxConnections, Players.PlayerAdded:Connect(hookPlayer))
table.insert(hitboxConnections, Players.PlayerRemoving:Connect(function(otherPlayer: Player)
	unhookPlayer(otherPlayer)
	scheduleESPRescans()
end))

workspace.ChildAdded:Connect(function(child: Instance)
	if child.Name == "Characters" then
		charactersFolder = child
		scheduleESPRescans()
	end
end)

workspace.DescendantAdded:Connect(function(descendant: Instance)
	if not gui.Parent then return end
	-- Corpse models usually live outside Characters and are never tracked by
	-- ESP. Normalize inherited hitbox changes before the Characters filter.
	hitbox.RestoreInherited(descendant)
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

-- Recover marked copies already present when this version is reloaded.
for _, descendant in ipairs(workspace:GetDescendants()) do hitbox.RestoreInherited(descendant) end

workspace.DescendantRemoving:Connect(function(descendant: Instance)
	if descendant:IsA("Model") and trackedHighlights[descendant] then destroyTracked(descendant) end
end)

local rescanClock = 0
local espHeartbeatConnection = RunService.Heartbeat:Connect(function(deltaTime: number)
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

local visualRenderConnection = RunService.RenderStepped:Connect(function()
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

--============================================================
-- RIVALS: separate controls and standard Player.Character adapter.
--============================================================
local function setupRivalsPage()
	local rivals = {
		Aim = false, ESP = false, Tracers = false, Noclip = false, InfiniteJump = false,
		Radius = 120, AimColor = Color3.fromRGB(150, 105, 255),
		ESPColor = Color3.fromRGB(255, 70, 82), FillTransparency = 0.6,
		TracerColor = Color3.fromRGB(70, 190, 255), Thickness = 2,
		EnemiesOnly = true, TurnBody = true, TargetMode = "Circle", ShowAimButton = false, IgnoreWalls = false,
	}
	local config: any = rivals
	local cards = {}
	local lockedTarget: {Owner: Player, Model: Model}? = nil
	local connections: {RBXScriptConnection} = {}
	local stopped = false
	local visuals: {[Player]: {Model: Model, Highlight: Highlight, Line: Frame}} = {}
	local turningHumanoid: Humanoid? = nil
	local savedAutoRotate = true
	local modules = pages["RIVALS"].Modules
	pages["RIVALS"].EmptyText.Visible = false
	local header = modules:FindFirstChild("PageHeader")
	if header and header:IsA("Frame") then header.Visible = false end

	local overlay = Instance.new("ScreenGui")
	overlay.Name = "KBACRivalsOverlay"
	overlay.ResetOnSpawn = false
	overlay.IgnoreGuiInset = true
	overlay.ScreenInsets = Enum.ScreenInsets.None
	overlay.DisplayOrder = gui.DisplayOrder - 1
	overlay.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	overlay.Parent = playerGui
	local visualFolder = Instance.new("Folder")
	visualFolder.Name = "RivalsVisuals"
	visualFolder.Parent = effectsFolder

	local circle = Instance.new("Frame")
	circle.Name = "AimCircle"
	circle.AnchorPoint = Vector2.new(0.5, 0.5)
	circle.Position = UDim2.fromScale(0.5, 0.5)
	circle.Size = UDim2.fromOffset(rivals.Radius * 2, rivals.Radius * 2)
	circle.BackgroundTransparency = 1
	circle.BorderSizePixel = 0
	circle.Visible = false
	circle.ZIndex = 5
	circle.Parent = overlay
	corner(circle, 1000)
	local circleOutline = stroke(circle, 0.15, 1.5)
	circleOutline.Color = rivals.AimColor

	local function releaseBody()
		if turningHumanoid then
			turningHumanoid.AutoRotate = savedAutoRotate
			turningHumanoid = nil
		end
	end

	-- RIVALS TARGET ADAPTER BEGIN
	local function isAlive(model: Model): boolean
		if not model:IsDescendantOf(workspace) then return false end
		if model:GetAttribute("Dead") == true or model:GetAttribute("IsDead") == true
			or model:GetAttribute("Alive") == false or model:GetAttribute("IsAlive") == false then return false end
		local health = model:GetAttribute("Health")
		if type(health) == "number" and health <= 0 then return false end
		local humanoid = model:FindFirstChildWhichIsA("Humanoid", true)
		return not humanoid or humanoid.Health > 0
	end

	local function characterParts(other: Player): (Model?, BasePart?, BasePart?)
		if other == player then return nil, nil, nil end
		local model = other.Character
		if not model or not isAlive(model) then return nil, nil, nil end
		local head = model:FindFirstChild("Head")
		local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso")
		return model, if head and head:IsA("BasePart") then head else nil,
			if root and root:IsA("BasePart") then root else nil
	end

	local function isEnemy(other: Player): boolean
		return not rivals.EnemiesOnly or player.Neutral or other.Neutral
			or player.Team == nil or other.Team == nil or player.Team ~= other.Team
	end

	local function screenDistance(camera: Camera, position: Vector3): number?
		local point, onScreen = camera:WorldToViewportPoint(position)
		if not onScreen or point.Z <= 0 then return nil end
		local dx, dy = point.X - camera.ViewportSize.X * 0.5, point.Y - camera.ViewportSize.Y * 0.5
		local distance = math.sqrt(dx * dx + dy * dy)
		return if distance <= rivals.Radius then distance else nil
	end

	local function unobstructed(camera: Camera, model: Model, head: BasePart): boolean
		if rivals.IgnoreWalls then return true end
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		local excluded: {Instance} = {effectsFolder, camera}
		if player.Character then table.insert(excluded, player.Character) end
		params.FilterDescendantsInstances = excluded
		local result = workspace:Raycast(camera.CFrame.Position, head.Position - camera.CFrame.Position, params)
		return result == nil or result.Instance:IsDescendantOf(model)
	end

	local function findTarget(camera: Camera, currentPlayers: {Player}): BasePart?
		-- Circle and Lock keep the acquired player rather than switching to
		-- whichever head happens to be closest to the crosshair this frame.
		if lockedTarget and rivals.TargetMode ~= "Nearest" then
			local model, head = characterParts(lockedTarget.Owner)
			if table.find(currentPlayers, lockedTarget.Owner) and model == lockedTarget.Model and head and isEnemy(lockedTarget.Owner) then
				if rivals.TargetMode == "Lock" then
					-- Remember the same target behind cover, but only move the
					-- camera through cover when IgnoreWalls is explicitly enabled.
					return if unobstructed(camera, model, head) then head else nil
				end
				if screenDistance(camera, head.Position) and unobstructed(camera, model, head) then return head end
			end
			lockedTarget = nil
		end
		local best: BasePart? = nil
		local bestOwner: Player? = nil
		local bestModel: Model? = nil
		local bestDistance = math.huge
		local localCharacter = player.Character
		local localRoot = if localCharacter then localCharacter:FindFirstChild("HumanoidRootPart") else nil
		local origin = if localRoot and localRoot:IsA("BasePart") then localRoot.Position else camera.CFrame.Position
		for _, other in ipairs(currentPlayers) do
			local model, head, root = characterParts(other)
			if model and head and isEnemy(other) then
				local distance: number? = nil
				if rivals.TargetMode == "Nearest" then
					-- Distance in the world, independent of camera direction and FOV.
					distance = ((root or head).Position - origin).Magnitude
				else
					distance = screenDistance(camera, head.Position)
				end
				if distance and distance < bestDistance and unobstructed(camera, model, head) then
					best, bestDistance, bestOwner, bestModel = head, distance, other, model
				end
			end
		end
		lockedTarget = if bestOwner and bestModel then {Owner = bestOwner, Model = bestModel} else nil
		return best
	end
	-- RIVALS TARGET ADAPTER END

	local originalCollisions: {[BasePart]: boolean} = {}
	local noclipCharacter: Model? = nil
	local lastJumpAt = -math.huge
	local function restoreCollisions()
		for part, canCollide in pairs(originalCollisions) do
			part.CanCollide = canCollide
			originalCollisions[part] = nil
		end
		noclipCharacter = nil
	end

	local function syncNoclip()
		local character = player.Character
		if stopped or not rivals.Noclip or not character or not isAlive(character) then
			restoreCollisions()
			return
		end
		if noclipCharacter ~= character then
			restoreCollisions()
			noclipCharacter = character
		end
		-- Restore detached parts; remember each new part's original collision flag.
		for part, canCollide in pairs(originalCollisions) do
			if not part:IsDescendantOf(character) then
				part.CanCollide = canCollide
				originalCollisions[part] = nil
			end
		end
		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				if originalCollisions[part] == nil then originalCollisions[part] = part.CanCollide end
				part.CanCollide = false
			end
		end
	end

	local function onJumpRequest()
		if stopped or not rivals.InfiniteJump or panel.Visible or UserInputService:GetFocusedTextBox() then return end
		local character = player.Character
		if not character or not isAlive(character) then return end
		local humanoid = character:FindFirstChildWhichIsA("Humanoid")
		local root = character:FindFirstChild("HumanoidRootPart")
		if not humanoid or not root or not root:IsA("BasePart") or root.Anchored
			or humanoid.SeatPart or humanoid.PlatformStand then return end
		local now = os.clock()
		if now - lastJumpAt < 0.12 then return end
		local speed = if humanoid.UseJumpPower then humanoid.JumpPower
			else math.sqrt(2 * math.max(workspace.Gravity, 0) * math.max(humanoid.JumpHeight, 0))
		if speed <= 0 then return end
		lastJumpAt = now
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		-- A repeated request while already jumping still needs a fresh impulse.
		-- Preserve horizontal motion and the game's jump strength settings.
		local velocity = root.AssemblyLinearVelocity
		root.AssemblyLinearVelocity = Vector3.new(velocity.X, speed, velocity.Z)
	end

	local function destroyVisual(other: Player)
		local visual = visuals[other]
		if not visual then return end
		visual.Highlight:Destroy()
		visual.Line:Destroy()
		visuals[other] = nil
	end

	local function ensureVisual(other: Player, model: Model)
		local existing = visuals[other]
		if existing and existing.Model == model then return existing end
		destroyVisual(other)
		local highlight = Instance.new("Highlight")
		highlight.Name = "RivalsESP_" .. other.Name
		highlight.Adornee = model
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.Enabled = false
		highlight.Parent = visualFolder
		local line = Instance.new("Frame")
		line.Name = "RivalsTracer_" .. other.Name
		line.AnchorPoint = Vector2.new(0.5, 0.5)
		line.BorderSizePixel = 0
		line.Visible = false
		line.ZIndex = 2
		line.Parent = overlay
		corner(line, 3)
		local fade = Instance.new("UIGradient")
		fade.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.75), NumberSequenceKeypoint.new(1, 0.05),
		})
		fade.Parent = line
		local visual = {Model = model, Highlight = highlight, Line = line}
		visuals[other] = visual
		return visual
	end

	local quickButton = openButton:Clone()
	quickButton.Name = "RivalsAimQuickToggle"
	i18n.Text(quickButton, "AIM")
	quickButton.TextSize = 14
	quickButton.TextScaled = true
	local quickTextSize = Instance.new("UITextSizeConstraint")
	quickTextSize.MinTextSize = 8
	quickTextSize.MaxTextSize = 14
	quickTextSize.Parent = quickButton
	quickButton.Visible = false
	quickButton.Parent = gui
	local quickOutline = quickButton:FindFirstChildWhichIsA("UIStroke")
	local quickMoved = false
	local quickDragging = false
	local quickDragInput: InputObject? = nil
	local quickDragStart = Vector2.new(0, 0)
	local quickPositionStart = Vector2.new(0, 0)
	local quickDragDistance = 0
	local function placeQuickButton()
		local camera = workspace.CurrentCamera
		if not camera then return end
		local viewport = camera.ViewportSize
		local side = if viewport.X < 500 then 52 else 58
		quickButton.Size = UDim2.fromOffset(side, side)
		local x, y = quickButton.Position.X.Offset, quickButton.Position.Y.Offset
		if not quickMoved then
			x = openButton.Position.X.Offset + side + 10
			y = openButton.Position.Y.Offset
			if x + side > viewport.X - 6 then x = openButton.Position.X.Offset - side - 10 end
		end
		quickButton.Position = UDim2.fromOffset(math.clamp(x, 6, math.max(6, viewport.X - side - 6)),
			math.clamp(y, 6, math.max(6, viewport.Y - side - 6)))
	end
	quickButton.InputBegan:Connect(function(input: InputObject)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
		quickDragging = true
		quickDragInput = input
		quickDragDistance = 0
		quickDragStart = Vector2.new(input.Position.X, input.Position.Y)
		quickPositionStart = Vector2.new(quickButton.Position.X.Offset, quickButton.Position.Y.Offset)
	end)
		table.insert(connections, UserInputService.InputChanged:Connect(function(input: InputObject)
		if not quickDragging then return end
		local mouseDrag = quickDragInput and quickDragInput.UserInputType == Enum.UserInputType.MouseButton1
		if not ((mouseDrag and input.UserInputType == Enum.UserInputType.MouseMovement) or input == quickDragInput) then return end
		local delta = Vector2.new(input.Position.X, input.Position.Y) - quickDragStart
		quickDragDistance = delta.Magnitude
		if quickDragDistance <= 6 then return end
		quickMoved = true
		quickButton.Position = UDim2.fromOffset(quickPositionStart.X + delta.X, quickPositionStart.Y + delta.Y)
		placeQuickButton()
	end))
	table.insert(connections, UserInputService.InputEnded:Connect(function(input: InputObject)
		if input == quickDragInput or input.UserInputType == Enum.UserInputType.MouseButton1 then
			quickDragging = false
			quickDragInput = nil
		end
	end))

	local function refreshEnabled()
		gui:SetAttribute("RivalsAimEnabled", rivals.Aim)
		gui:SetAttribute("RivalsESPEnabled", rivals.ESP)
		gui:SetAttribute("RivalsTracersEnabled", rivals.Tracers)
		gui:SetAttribute("RivalsIgnoreWalls", rivals.IgnoreWalls)
		gui:SetAttribute("RivalsNoclipEnabled", rivals.Noclip)
		gui:SetAttribute("RivalsInfiniteJumpEnabled", rivals.InfiniteJump)
		syncNoclip()
		if not rivals.InfiniteJump then lastJumpAt = -math.huge end
		circle.Visible = rivals.Aim and rivals.TargetMode ~= "Nearest"
		quickButton.Visible = rivals.ShowAimButton
		quickButton.TextColor3 = if rivals.Aim then Color3.fromRGB(70, 235, 135) else COLORS.white
		if quickOutline then quickOutline.Color = quickButton.TextColor3 end
		placeQuickButton()
		for _, entry in ipairs(cards) do entry.RefreshToggle() end
		if not rivals.Aim then lockedTarget = nil releaseBody() end
		for _, visual in pairs(visuals) do
			visual.Highlight.Enabled = rivals.ESP
			if not rivals.Tracers then visual.Line.Visible = false end
		end
	end

	quickButton.Activated:Connect(function()
		if quickDragDistance > 6 then return end
		rivals.Aim = not rivals.Aim
		refreshEnabled()
	end)

	-- Shared card builder keeps all three outlines, switches and palettes consistent.
	local function label(parent: Instance, text: string, y: number): TextLabel
		local item = Instance.new("TextLabel")
		item.Position = UDim2.fromOffset(12, y)
		item.Size = UDim2.new(1, -24, 0, 18)
		item.BackgroundTransparency = 1
		i18n.Text(item, text)
		item.TextColor3 = COLORS.muted
		item.TextSize = 10
		item.Font = Enum.Font.GothamBold
		item.TextXAlignment = Enum.TextXAlignment.Left
		item.ZIndex = 21
		item.Parent = parent
		return item
	end

	local function makeCard(key: string, titleText: string, descriptionText: string, category: string, order: number, height: number)
		local card = Instance.new("Frame")
		card.Name = "Rivals" .. key .. "Card"
		card.Size = UDim2.new(1, -10, 0, 68)
		card.BackgroundColor3 = Color3.fromRGB(44, 54, 71)
		card.BackgroundTransparency = 0.5
		card.BorderSizePixel = 0
		card.ClipsDescendants = true
		card.LayoutOrder = order
		card.ZIndex = 17
		card.Parent = modules
		corner(card, 18)
		stroke(card, 0.62, 1)
		local open = Instance.new("TextButton")
		open.Name = "OpenSettings"
		open.Size = UDim2.new(1, -78, 0, 68)
		open.BackgroundTransparency = 1
		i18n.Text(open, "")
		open.AutoButtonColor = false
		open.ZIndex = 18
		open.Parent = card
		local titleLabel = label(open, titleText, 10)
		titleLabel.Position = UDim2.fromOffset(18, 10)
		titleLabel.Size = UDim2.new(1, -30, 0, 25)
		titleLabel.TextSize = 18
		titleLabel.TextScaled = true
		local titleLimit = Instance.new("UITextSizeConstraint")
		titleLimit.MinTextSize = 10
		titleLimit.MaxTextSize = 18
		titleLimit.Parent = titleLabel
		titleLabel.TextColor3 = COLORS.text
		local description = label(open, descriptionText, 35)
		description.Position = UDim2.fromOffset(18, 35)
		description.TextSize = 11
		description.Font = Enum.Font.GothamMedium
		description.TextTruncate = Enum.TextTruncate.AtEnd
		local toggle = Instance.new("TextButton")
		toggle.Name = "Toggle"
		toggle.AnchorPoint = Vector2.new(1, 0)
		toggle.Position = UDim2.new(1, -14, 0, 19)
		toggle.Size = UDim2.fromOffset(52, 30)
		toggle.BackgroundColor3 = Color3.fromRGB(104, 112, 127)
		toggle.BackgroundTransparency = 0.18
		toggle.BorderSizePixel = 0
		i18n.Text(toggle, "")
		toggle.AutoButtonColor = false
		toggle.ZIndex = 22
		toggle.Parent = card
		corner(toggle, 15)
		stroke(toggle, 0.55)
		local knob = Instance.new("Frame")
		knob.Position = UDim2.fromOffset(3, 3)
		knob.Size = UDim2.fromOffset(24, 24)
		knob.BackgroundColor3 = COLORS.white
		knob.BorderSizePixel = 0
		knob.ZIndex = 23
		knob.Parent = toggle
		corner(knob, 12)
		local settings = Instance.new("Frame")
		settings.Name = "Settings"
		settings.Position = UDim2.fromOffset(12, 76)
		settings.Size = UDim2.new(1, -24, 0, height)
		settings.BackgroundColor3 = Color3.fromRGB(25, 32, 46)
		settings.BackgroundTransparency = 0.54
		settings.BorderSizePixel = 0
		settings.Visible = false
		settings.ZIndex = 18
		settings.Parent = card
		corner(settings, 15)
		stroke(settings, 0.58)
		local record = {Card = card, Settings = settings, Height = height, Expanded = false, Category = category}
		table.insert(cards, record)
		open.Activated:Connect(function()
			if height == 0 then
				config[key] = not config[key]
				refreshEnabled()
				return
			end
			local expand = not record.Expanded
			for _, entry in ipairs(cards) do
				entry.Expanded = entry == record and expand
				entry.Settings.Visible = entry.Expanded
				entry.Card.Size = UDim2.new(1, -10, 0, if entry.Expanded then entry.Height + 88 else 68)
			end
			-- Bring the opened card header into view, including on phones.
			modules.CanvasPosition = Vector2.new(0, math.max(0, (order - 2) * 76))
		end)
		record.RefreshToggle = function()
			local enabled = config[key]
			TweenService:Create(toggle, quickTween, {
				BackgroundColor3 = if enabled then Color3.fromRGB(23, 126, 76) else Color3.fromRGB(104, 112, 127),
				BackgroundTransparency = if enabled then 0.42 else 0.18,
			}):Play()
			TweenService:Create(knob, quickTween, {Position = UDim2.fromOffset(if enabled then 25 else 3, 3)}):Play()
		end
		toggle.Activated:Connect(function()
			config[key] = not config[key]
			refreshEnabled()
		end)
		return settings
	end

	local function palette(parent: Instance, y: number, key: string, titleText: string)
		label(parent, titleText, y)
		local row = Instance.new("Frame")
		row.Name = key .. "Palette"
		row.Position = UDim2.fromOffset(12, y + 23)
		row.Size = UDim2.new(1, -24, 0, 26)
		row.BackgroundTransparency = 1
		row.ZIndex = 20
		row.Parent = parent
		local layout = Instance.new("UIListLayout")
		layout.FillDirection = Enum.FillDirection.Horizontal
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		layout.Padding = UDim.new(0, 8)
		layout.Parent = row
		local entries = {}
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
			i18n.Text(button, "")
			button.AutoButtonColor = false
			button.ZIndex = 22
			button.Parent = row
			corner(button, 12)
			local outline = stroke(button, if color == config[key] then 0.05 else 0.65, 2)
			table.insert(entries, {Stroke = outline, Color = color})
			button.Activated:Connect(function()
				config[key] = color
				for _, entry in ipairs(entries) do entry.Stroke.Transparency = if entry.Color == color then 0.05 else 0.65 end
				circleOutline.Color = rivals.AimColor
			end)
		end
	end

	local function slider(parent: Instance, y: number, key: string, titleText: string, minimum: number, maximum: number, step: number)
		local caption = label(parent, titleText, y)
		caption.Size = UDim2.new(1, -100, 0, 18)
		local valueLabel = label(parent, "", y)
		valueLabel.Position = UDim2.new(1, -84, 0, y)
		valueLabel.Size = UDim2.fromOffset(72, 18)
		valueLabel.TextXAlignment = Enum.TextXAlignment.Right
		local track = Instance.new("Frame")
		track.Name = key .. "Slider"
		track.Position = UDim2.fromOffset(14, y + 29)
		track.Size = UDim2.new(1, -28, 0, 6)
		track.BackgroundColor3 = Color3.fromRGB(105, 114, 130)
		track.BackgroundTransparency = 0.35
		track.BorderSizePixel = 0
		track.Active = true
		track.ZIndex = 21
		track.Parent = parent
		corner(track, 3)
		local fill = Instance.new("Frame")
		fill.BackgroundColor3 = COLORS.white
		fill.BackgroundTransparency = 0.15
		fill.BorderSizePixel = 0
		fill.ZIndex = 22
		fill.Parent = track
		corner(fill, 3)
		local knob = Instance.new("Frame")
		knob.AnchorPoint = Vector2.new(0.5, 0.5)
		knob.Size = UDim2.fromOffset(18, 18)
		knob.BackgroundColor3 = COLORS.white
		knob.BorderSizePixel = 0
		knob.ZIndex = 23
		knob.Parent = track
		corner(knob, 9)
		local touch: InputObject? = nil
		local dragging = false
		local function refresh()
			local value = config[key]
			local alpha = (value - minimum) / (maximum - minimum)
			fill.Size = UDim2.fromScale(alpha, 1)
			knob.Position = UDim2.fromScale(alpha, 0.5)
			valueLabel.Text = if step >= 1 then tostring(math.round(value)) else string.format("%.1f", value)
			circle.Size = UDim2.fromOffset(rivals.Radius * 2, rivals.Radius * 2)
		end
		local function setFromX(x: number)
			local alpha = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
			config[key] = math.clamp(math.round((minimum + alpha * (maximum - minimum)) / step) * step, minimum, maximum)
			refresh()
		end
		local function start(input: InputObject)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				touch = if input.UserInputType == Enum.UserInputType.Touch then input else nil
				setFromX(input.Position.X)
			end
		end
		track.InputBegan:Connect(start)
		knob.InputBegan:Connect(start)
		table.insert(connections, UserInputService.InputChanged:Connect(function(input: InputObject)
			if dragging and ((touch ~= nil and input == touch) or (touch == nil and input.UserInputType == Enum.UserInputType.MouseMovement)) then
				setFromX(input.Position.X)
			end
		end))
		table.insert(connections, UserInputService.InputEnded:Connect(function(input: InputObject)
			if input == touch or input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false touch = nil end
		end))
		refresh()
	end

	local function option(parent: Instance, y: number, key: string, titleText: string)
		local text = label(parent, titleText, y + 6)
		text.Size = UDim2.new(1, -95, 0, 18)
		local button = Instance.new("TextButton")
		button.Name = key .. "Option"
		button.Position = UDim2.new(1, -72, 0, y)
		button.Size = UDim2.fromOffset(60, 30)
		button.BackgroundColor3 = Color3.fromRGB(13, 16, 22)
		button.BackgroundTransparency = 0.35
		button.BorderSizePixel = 0
		button.TextColor3 = COLORS.white
		button.TextSize = 11
		button.Font = Enum.Font.GothamSemibold
		button.AutoButtonColor = false
		button.ZIndex = 22
		button.Parent = parent
		corner(button, 10)
		local outline = stroke(button, 0.6)
		local function refresh()
			local enabled = config[key]
			i18n.Text(button, if enabled then "ON" else "OFF")
			button.BackgroundColor3 = if enabled then Color3.fromRGB(23, 94, 64) else Color3.fromRGB(13, 16, 22)
			button.BackgroundTransparency = if enabled then 0.12 else 0.35
			button.TextColor3 = if enabled then Color3.fromRGB(111, 255, 171) else COLORS.muted
			outline.Color = if enabled then Color3.fromRGB(70, 235, 135) else COLORS.white
			outline.Transparency = if enabled then 0.15 else 0.65
			outline.Thickness = if enabled then 1.4 else 1
		end
		button.Activated:Connect(function()
			config[key] = not config[key]
			if not rivals.TurnBody then releaseBody() end
			refreshEnabled()
			refresh()
		end)
		refresh()
	end

	local aimSettings = makeCard("Aim", "AIM", "Head aim · close the menu to use", "Combat", 2, 376)
	label(aimSettings, "TARGET SELECTION", 10)
	local modeHelp = label(aimSettings, "", 68)
	modeHelp.Size = UDim2.new(1, -24, 0, 30)
	modeHelp.TextWrapped = true
	modeHelp.Font = Enum.Font.GothamMedium
	local targetModes = {
		{Key = "Nearest", Text = "Nearest", Help = "Nearest target in any direction (360°). Respects the wall setting; ignores the circle."},
		{Key = "Circle", Text = "In circle", Help = "Selects a head near the center and holds it inside the circle. Respects the wall setting."},
		{Key = "Lock", Text = "Until death", Help = "Acquires inside the circle, holds until death. Pauses behind walls unless they are ignored."},
	}
	local modeButtons = {}
	local function refreshMode()
		gui:SetAttribute("RivalsAimMode", rivals.TargetMode)
		for _, mode in ipairs(targetModes) do
			local active = rivals.TargetMode == mode.Key
			local entry = modeButtons[mode.Key]
			entry.Button.BackgroundTransparency = if active then 0.3 else 0.75
			entry.Stroke.Transparency = if active then 0.25 else 0.7
			if active then i18n.Text(modeHelp, mode.Help) end
		end
		refreshEnabled()
	end
	for index, mode in ipairs(targetModes) do
		local button = Instance.new("TextButton")
		button.Name = "AimMode_" .. mode.Key
		button.Position = UDim2.new((index - 1) / 3, 12, 0, 34)
		button.Size = UDim2.new(1 / 3, -16, 0, 28)
		button.BackgroundColor3 = Color3.fromRGB(13, 16, 22)
		button.BorderSizePixel = 0
		i18n.Text(button, mode.Text)
		button.TextColor3 = COLORS.text
		button.TextSize = 11
		button.Font = Enum.Font.GothamSemibold
		button.AutoButtonColor = false
		button.ZIndex = 22
		button.Parent = aimSettings
		corner(button, 10)
		modeButtons[mode.Key] = {Button = button, Stroke = stroke(button, 0.7)}
		button.Activated:Connect(function()
			rivals.TargetMode = mode.Key
			lockedTarget = nil
			releaseBody()
			refreshMode()
		end)
	end
	slider(aimSettings, 106, "Radius", "CIRCLE RADIUS", 40, 300, 5)
	palette(aimSettings, 158, "AimColor", "CIRCLE COLOR")
	option(aimSettings, 220, "EnemiesOnly", "ENEMIES ONLY")
	option(aimSettings, 258, "IgnoreWalls", "IGNORE WALLS")
	option(aimSettings, 296, "TurnBody", "TURN CHARACTER")
	option(aimSettings, 334, "ShowAimButton", "SHOW AIM BUTTON")
	refreshMode()
	local espSettings = makeCard("ESP", "ESP", "Outline and soft player fill", "Visuals", 2, 120)
	palette(espSettings, 10, "ESPColor", "HIGHLIGHT COLOR")
	slider(espSettings, 72, "FillTransparency", "TRANSPARENCY", 0.1, 0.9, 0.1)
	local tracerSettings = makeCard("Tracers", "TRACERS", "Direction lines to players", "Visuals", 3, 120)
	palette(tracerSettings, 10, "TracerColor", "LINE COLOR")
	slider(tracerSettings, 72, "Thickness", "THICKNESS", 1, 6, 0.5)
	makeCard("Noclip", "NOCLIP", "Walk through walls", "Other", 2, 0)
	makeCard("InfiniteJump", "INFINITE JUMP", "Jump again while in the air", "Other", 3, 0)

	local categoryBar = Instance.new("Frame")
	categoryBar.Name = "RivalsCategoryBar"
	categoryBar.Size = UDim2.new(1, -18, 0, 44)
	categoryBar.BackgroundColor3 = Color3.fromRGB(16, 20, 28)
	categoryBar.BackgroundTransparency = 0.52
	categoryBar.BorderSizePixel = 0
	categoryBar.LayoutOrder = 1
	categoryBar.ZIndex = 17
	categoryBar.Parent = modules
	corner(categoryBar, 14)
	stroke(categoryBar, 0.68, 1)
	local categoryLayout = Instance.new("UIListLayout")
	categoryLayout.FillDirection = Enum.FillDirection.Horizontal
	categoryLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	categoryLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	categoryLayout.SortOrder = Enum.SortOrder.LayoutOrder
	categoryLayout.Padding = UDim.new(0, 5)
	categoryLayout.Parent = categoryBar
	local categoryPadding = Instance.new("UIPadding")
	categoryPadding.PaddingLeft = UDim.new(0, 5)
	categoryPadding.PaddingRight = UDim.new(0, 5)
	categoryPadding.PaddingTop = UDim.new(0, 5)
	categoryPadding.PaddingBottom = UDim.new(0, 5)
	categoryPadding.Parent = categoryBar
	local otherEmpty = label(modules, "No functions added yet", 0)
	otherEmpty.Name = "RivalsOtherEmpty"
	otherEmpty.Size = UDim2.new(1, -10, 0, 54)
	otherEmpty.LayoutOrder = 2
	otherEmpty.TextSize = 13
	otherEmpty.TextXAlignment = Enum.TextXAlignment.Center
	otherEmpty.Visible = false
	local categoryButtons = {}
	local function selectCategory(name: string)
		gui:SetAttribute("RivalsCategory", name)
		modules.CanvasPosition = Vector2.new(0, 0)
		for _, entry in ipairs(cards) do
			entry.Card.Visible = entry.Category == name
			entry.Expanded = false
			entry.Settings.Visible = false
			entry.Card.Size = UDim2.new(1, -10, 0, 68)
		end
		otherEmpty.Visible = false
		for category, entry in pairs(categoryButtons) do
			local active = category == name
			entry.Button.BackgroundTransparency = if active then 0.38 else 1
			entry.Button.TextColor3 = if active then COLORS.text else COLORS.muted
			entry.Stroke.Transparency = if active then 0.38 else 1
		end
	end
	for order, name in ipairs({"Combat", "Visuals", "Other"}) do
		local button = Instance.new("TextButton")
		button.Name = name .. "Category"
		button.Size = UDim2.new(1 / 3, -7, 1, 0)
		button.BackgroundColor3 = Color3.fromRGB(13, 16, 22)
		button.BorderSizePixel = 0
		i18n.Text(button, string.upper(name))
		button.TextSize = 11
		button.Font = Enum.Font.GothamSemibold
		button.AutoButtonColor = false
		button.LayoutOrder = order
		button.ZIndex = 18
		button.Parent = categoryBar
		corner(button, 10)
		categoryButtons[name] = {Button = button, Stroke = stroke(button, 1, 1)}
		button.Activated:Connect(function() selectCategory(name) end)
	end
	selectCategory("Combat")

	local function turnBody(target: Vector3)
		local character = player.Character
		local humanoid = if character then character:FindFirstChildWhichIsA("Humanoid") else nil
		local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
		if not rivals.TurnBody or not humanoid or humanoid.Health <= 0 or not root or not root:IsA("BasePart")
			or root.Anchored or humanoid.SeatPart then releaseBody() return end
		if turningHumanoid ~= humanoid then
			releaseBody()
			turningHumanoid, savedAutoRotate = humanoid, humanoid.AutoRotate
		end
		humanoid.AutoRotate = false
		local position = root.Position
		local flat = Vector3.new(target.X, position.Y, target.Z)
		if (flat - position).Magnitude > 0.001 then root.CFrame = CFrame.lookAt(position, flat) end
	end

	local binding = "KBACClientRivalsAim"
	gui:SetAttribute("RivalsRenderStepName", binding)
	local function render()
		if stopped then return end
		local camera = workspace.CurrentCamera
		if not camera then circle.Visible = false releaseBody() return end
		circle.Visible = rivals.Aim and rivals.TargetMode ~= "Nearest"
		if quickButton.Visible then placeQuickButton() end
		local currentPlayers = if rivals.Aim or rivals.ESP or rivals.Tracers then Players:GetPlayers() else {}
		local localCharacter = player.Character
		local canAim = rivals.Aim and not panel.Visible and UserInputService:GetFocusedTextBox() == nil
			and localCharacter ~= nil and isAlive(localCharacter)
		local target = if canAim then findTarget(camera, currentPlayers) else nil
		if target and (target.Position - camera.CFrame.Position).Magnitude > 0.001 then
			camera.CFrame = CFrame.lookAt(camera.CFrame.Position, target.Position)
			turnBody(target.Position)
		else
			releaseBody()
		end
		local active: {[Player]: boolean} = {}
		if rivals.ESP or rivals.Tracers then
			for _, other in ipairs(currentPlayers) do
				local model, head, root = characterParts(other)
				if model then
					active[other] = true
					local visual = ensureVisual(other, model)
					visual.Highlight.Enabled = rivals.ESP
					visual.Highlight.FillColor = rivals.ESPColor
					visual.Highlight.OutlineColor = rivals.ESPColor:Lerp(COLORS.white, 0.35)
					visual.Highlight.FillTransparency = rivals.FillTransparency
					visual.Highlight.OutlineTransparency = 0.08
					visual.Line.Visible = false
					local destination = root or head
					if rivals.Tracers and destination then
						local projected, onScreen = camera:WorldToViewportPoint(destination.Position)
						if onScreen and projected.Z > 0 then
							local origin = Vector2.new(camera.ViewportSize.X * 0.5, camera.ViewportSize.Y - 10)
							local finish = Vector2.new(projected.X, projected.Y)
							local delta = finish - origin
							visual.Line.Position = UDim2.fromOffset((origin.X + finish.X) * 0.5, (origin.Y + finish.Y) * 0.5)
							visual.Line.Size = UDim2.fromOffset(delta.Magnitude, rivals.Thickness)
							visual.Line.Rotation = math.deg(math.atan2(delta.Y, delta.X))
							visual.Line.BackgroundColor3 = rivals.TracerColor
							visual.Line.Visible = true
						end
					end
				end
			end
		end
		for other in pairs(visuals) do if not active[other] then destroyVisual(other) end end
	end

	table.insert(connections, Players.PlayerRemoving:Connect(function(other: Player)
		if lockedTarget and lockedTarget.Owner == other then lockedTarget = nil end
		destroyVisual(other)
	end))
	table.insert(connections, player.CharacterRemoving:Connect(function()
		lockedTarget = nil
		releaseBody()
		restoreCollisions()
		lastJumpAt = -math.huge
	end))
	table.insert(connections, RunService.PreSimulation:Connect(syncNoclip))
	table.insert(connections, UserInputService.JumpRequest:Connect(onJumpRequest))
	gui.Destroying:Connect(function()
		stopped = true
		RunService:UnbindFromRenderStep(binding)
		for _, connection in ipairs(connections) do connection:Disconnect() end
		releaseBody()
		restoreCollisions()
		for other in pairs(visuals) do destroyVisual(other) end
		overlay:Destroy()
		visualFolder:Destroy()
	end)
	RunService:BindToRenderStep(binding, Enum.RenderPriority.Last.Value + 1, render)
	refreshEnabled()
	switchTab("RIVALS")
end
setupRivalsPage()

local function setupLanguagePage()
	local page = pages["OTHER"]
	page.EmptyText.Visible = false
	local header = page.Modules:FindFirstChild("PageHeader")
	if header and header:IsA("Frame") then header.Visible = false end
	local card = Instance.new("Frame")
	card.Name = "LanguageCard"
	card.Size = UDim2.new(1, -10, 0, 174)
	card.BackgroundColor3 = Color3.fromRGB(44, 54, 71)
	card.BackgroundTransparency = 0.5
	card.BorderSizePixel = 0
	card.LayoutOrder = 1
	card.ZIndex = 17
	card.Parent = page.Modules
	corner(card, 18)
	stroke(card, 0.62, 1)
	local function label(name: string, text: string, y: number, size: number)
		local item = Instance.new("TextLabel")
		item.Name = name
		item.Position = UDim2.fromOffset(18, y)
		item.Size = UDim2.new(1, -36, 0, 24)
		item.BackgroundTransparency = 1
		i18n.Text(item, text)
		item.TextColor3 = COLORS.muted
		item.TextSize = size
		item.Font = Enum.Font.GothamMedium
		item.TextXAlignment = Enum.TextXAlignment.Left
		item.ZIndex = 19
		item.Parent = card
		return item
	end
	local title = label("Title", "LANGUAGE", 12, 18)
	title.Font = Enum.Font.GothamBold
	title.TextColor3 = COLORS.text
	label("Description", "Choose the interface language", 40, 12)
	local note = label("Note", "Applies to all tabs. Your settings stay the same.", 134, 11)
	note.TextWrapped = true
	local buttons = {}
	local function refresh()
		gui:SetAttribute("UILanguage", i18n.Language)
		for language, entry in pairs(buttons) do
			local active = language == i18n.Language
			entry.Button.BackgroundColor3 = if active then Color3.fromRGB(23, 94, 64) else Color3.fromRGB(13, 16, 22)
			entry.Button.BackgroundTransparency = if active then 0.12 else 0.45
			entry.Button.TextColor3 = if active then Color3.fromRGB(111, 255, 171) else COLORS.muted
			entry.Stroke.Color = if active then Color3.fromRGB(70, 235, 135) else COLORS.white
			entry.Stroke.Transparency = if active then 0.15 else 0.65
		end
	end
	for index, language in ipairs({{Id = "en", Name = "English"}, {Id = "ru", Name = "Русский"}}) do
		local button = Instance.new("TextButton")
		button.Name = "Language_" .. language.Id
		button.Position = UDim2.new((index - 1) * 0.5, if index == 1 then 14 else 4, 0, 80)
		button.Size = UDim2.new(0.5, -18, 0, 42)
		button.BorderSizePixel = 0
		-- Display names are localized; stable language IDs remain en and ru.
		i18n.Text(button, language.Name)
		button.TextSize = 14
		button.Font = Enum.Font.GothamSemibold
		button.AutoButtonColor = false
		button.ZIndex = 20
		button.Parent = card
		corner(button, 12)
		buttons[language.Id] = {Button = button, Stroke = stroke(button, 0.65)}
		button.Activated:Connect(function() i18n.SetLanguage(language.Id) end)
	end
	i18n.OnChanged = refresh
	refresh()
end
setupLanguagePage()

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
	hitbox.Enabled = false
	hitboxHeartbeat:Disconnect()
	espHeartbeatConnection:Disconnect()
	visualRenderConnection:Disconnect()
	for _, connection in ipairs(hitboxConnections) do connection:Disconnect() end
	for otherPlayer in pairs(playerConnections) do unhookPlayer(otherPlayer) end
	hitbox.RestoreAll()
	for model in pairs(trackedHighlights) do destroyTracked(model) end
	if effectsFolder.Parent then effectsFolder:Destroy() end
	if blur.Parent then blur:Destroy() end
	i18n.OnChanged = nil
	table.clear(i18n.Bindings)
end)
