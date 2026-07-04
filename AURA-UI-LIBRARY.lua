-- ==========================================
-- 🚀 AURA UI LIBRARY v2.0 - MEJORADA
-- ==========================================

local AuraUI = {}
AuraUI.__index = AuraUI

-- Servicios
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Helper para crear instancias
local function Create(class, props)
	local inst = Instance.new(class)
	for k, v in pairs(props or {}) do inst[k] = v end
	return inst
end

-- ==========================================
-- 🎨 SISTEMA DE TEMAS MEJORADO (3 TONOS)
-- ==========================================
local ThemeManager = {}
ThemeManager.__index = ThemeManager

local Themes = {
	Dark = {
		-- Tono Primario (Acentos, botones principales)
		Primary = Color3.fromRGB(100, 150, 255),
		PrimaryHover = Color3.fromRGB(120, 170, 255),
		
		-- Tono Secundario (Bordes, elementos secundarios)
		Secondary = Color3.fromRGB(60, 60, 70),
		SecondaryHover = Color3.fromRGB(80, 80, 90),
		
		-- Tono de Fondo (GUI principal, ventanas)
		Background = Color3.fromRGB(20, 20, 25),
		Surface = Color3.fromRGB(30, 30, 35),
		SurfaceHover = Color3.fromRGB(40, 40, 45),
		
		-- Textos
		Text = Color3.fromRGB(240, 240, 240),
		TextSecondary = Color3.fromRGB(160, 160, 165),
		
		-- Estados
		Success = Color3.fromRGB(80, 200, 120),
		Error = Color3.fromRGB(255, 80, 80),
		Warning = Color3.fromRGB(255, 180, 50),
		Info = Color3.fromRGB(100, 150, 255),
	},
	Light = {
		Primary = Color3.fromRGB(60, 120, 230),
		PrimaryHover = Color3.fromRGB(80, 140, 250),
		
		Secondary = Color3.fromRGB(200, 200, 210),
		SecondaryHover = Color3.fromRGB(180, 180, 190),
		
		Background = Color3.fromRGB(245, 245, 250),
		Surface = Color3.fromRGB(255, 255, 255),
		SurfaceHover = Color3.fromRGB(235, 235, 240),
		
		Text = Color3.fromRGB(20, 20, 25),
		TextSecondary = Color3.fromRGB(100, 100, 110),
		
		Success = Color3.fromRGB(50, 180, 100),
		Error = Color3.fromRGB(230, 60, 60),
		Warning = Color3.fromRGB(230, 160, 40),
		Info = Color3.fromRGB(60, 120, 230),
	},
	Custom = {
		Primary = Color3.fromRGB(255, 100, 150),
		PrimaryHover = Color3.fromRGB(255, 120, 170),
		
		Secondary = Color3.fromRGB(80, 50, 60),
		SecondaryHover = Color3.fromRGB(100, 70, 80),
		
		Background = Color3.fromRGB(25, 15, 20),
		Surface = Color3.fromRGB(35, 25, 30),
		SurfaceHover = Color3.fromRGB(45, 35, 40),
		
		Text = Color3.fromRGB(255, 240, 245),
		TextSecondary = Color3.fromRGB(200, 180, 190),
		
		Success = Color3.fromRGB(100, 255, 150),
		Error = Color3.fromRGB(255, 100, 100),
		Warning = Color3.fromRGB(255, 200, 100),
		Info = Color3.fromRGB(255, 100, 150),
	}
}

local CurrentThemeName = "Dark"
local CurrentTheme = Themes.Dark
local Subscribers = {}

function ThemeManager:Apply(themeName, customColors)
	if Themes[themeName] then
		CurrentThemeName = themeName
		CurrentTheme = Themes[themeName]
	end
	if customColors then
		for key, value in pairs(customColors) do
			CurrentTheme[key] = value
		end
	end
	for _, subscriber in ipairs(Subscribers) do
		if subscriber.UpdateStyle then
			pcall(function() subscriber:UpdateStyle() end)
		end
	end
end

function ThemeManager:Get(key)
	return CurrentTheme[key] or Color3.new(1, 1, 1)
end

function ThemeManager:GetCurrentThemeName()
	return CurrentThemeName
end

function ThemeManager:Subscribe(object)
	if not table.find(Subscribers, object) then
		table.insert(Subscribers, object)
	end
end

AuraUI.ThemeManager = ThemeManager

-- ==========================================
-- 🔔 SISTEMA DE NOTIFICACIONES
-- ==========================================
local Notification = {}
local Notifications = {}

local function GetNotificationGui()
	local gui = PlayerGui:FindFirstChild("AuraNotifications")
	if not gui then
		gui = Create("ScreenGui", {
			Name = "AuraNotifications",
			ResetOnSpawn = false,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			Parent = PlayerGui
		})
	end
	return gui
end

function Notification:Show(options)
	options = options or {}
	local title = options.Title or "Notification"
	local message = options.Message or ""
	local type = options.Type or "Info"
	local duration = options.Duration or 4

	local gui = GetNotificationGui()

	local toast = Create("Frame", {
		Name = "Toast",
		Size = UDim2.new(0, 300, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = ThemeManager:Get("Surface"),
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
		Parent = gui
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = toast })
	Create("UIStroke", {
		Color = ThemeManager:Get("Secondary"),
		Thickness = 2,
		Transparency = 0.3,
		Parent = toast
	})

	local accentBar = Create("Frame", {
		Size = UDim2.new(0, 4, 1, 0),
		BackgroundColor3 = ThemeManager:Get(type) or ThemeManager:Get("Primary"),
		BorderSizePixel = 0,
		Parent = toast
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 2), Parent = accentBar })

	Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Parent = toast
	})

	local content = Create("Frame", {
		Size = UDim2.new(1, -4, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = toast
	})
	Create("UIPadding", {
		PaddingTop = UDim.new(0, 12),
		PaddingBottom = UDim.new(0, 12),
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		Parent = content
	})
	Create("UIListLayout", {
		Padding = UDim.new(0, 5),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = content
	})

	Create("TextLabel", {
		Text = title,
		TextColor3 = ThemeManager:Get("Text"),
		TextSize = 14,
		Font = Enum.Font.GothamBold,
		Size = UDim2.new(1, 0, 0, 18),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Parent = content
	})

	Create("TextLabel", {
		Text = message,
		TextColor3 = ThemeManager:Get("TextSecondary"),
		TextSize = 12,
		Font = Enum.Font.Gotham,
		Size = UDim2.new(1, 0, 0, 15),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Parent = content
	})

	local index = #Notifications
	toast.Position = UDim2.new(1, -320, 1, -70 - (index * 80))
	table.insert(Notifications, toast)

	task.spawn(function()
		task.wait(0.1)
		local targetHeight = content.AbsoluteSize.Y + 24
		TweenService:Create(toast, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 300, 0, targetHeight)
		}):Play()
	end)

	task.delay(duration, function()
		self:Dismiss(toast)
	end)
end

function Notification:Dismiss(toast)
	TweenService:Create(toast, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Position = UDim2.new(1, 50, toast.Position.Y.Scale, toast.Position.Y.Offset),
		BackgroundTransparency = 1
	}):Play()
	task.delay(0.35, function()
		local idx = table.find(Notifications, toast)
		if idx then table.remove(Notifications, idx) end
		toast:Destroy()
		self:Reposition()
	end)
end

function Notification:Reposition()
	for i, toast in ipairs(Notifications) do
		TweenService:Create(toast, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
			Position = UDim2.new(1, -320, 1, -70 - ((i-1) * 80))
		}):Play()
	end
end

-- ==========================================
-- 🪟 COMPONENTE: VENTANA (CON BOTÓN X)
-- ==========================================
local Window = {}
Window.__index = Window

function Window.new(options)
	local self = setmetatable({}, Window)
	self.Name = options.Name or "Aura Window"
	self.Size = options.Size or UDim2.new(0, 550, 0, 400)
	self.Position = options.Position or UDim2.new(0.5, -275, 0.5, -200)
	self.Visible = true
	self.Tabs = {}
	self.ActiveTab = nil

	self:BuildUI()
	ThemeManager:Subscribe(self)
	return self
end

function Window:BuildUI()
	local ScreenGui = Create("ScreenGui", {
		Name = "Aura_" .. self.Name,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = PlayerGui
	})
	self.Gui = ScreenGui

	local MainFrame = Create("Frame", {
		Name = "MainFrame",
		Size = self.Size,
		Position = self.Position,
		BackgroundColor3 = ThemeManager:Get("Background"),
		BackgroundTransparency = 0.02,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = ScreenGui
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = MainFrame })
	Create("UIStroke", {
		Color = ThemeManager:Get("Secondary"),
		Thickness = 2,
		Transparency = 0.2,
		Parent = MainFrame
	})
	self.MainFrame = MainFrame

	-- Title Bar con botón X
	local TitleBar = Create("Frame", {
		Name = "TitleBar",
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = ThemeManager:Get("Surface"),
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		Parent = MainFrame
	})

	Create("TextLabel", {
		Name = "Title",
		Text = self.Name,
		TextColor3 = ThemeManager:Get("Text"),
		TextSize = 14,
		Font = Enum.Font.GothamBold,
		Size = UDim2.new(1, -90, 1, 0),
		Position = UDim2.new(0, 15, 0, 0),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = TitleBar
	})

	-- Botón X para cerrar
	local closeBtn = Create("TextButton", {
		Name = "Close",
		Text = "✕",
		Size = UDim2.new(0, 32, 0, 32),
		Position = UDim2.new(1, -38, 0, 4),
		BackgroundColor3 = ThemeManager:Get("Error"),
		BackgroundTransparency = 0.8,
		BorderSizePixel = 0,
		TextColor3 = ThemeManager:Get("Text"),
		TextSize = 16,
		Font = Enum.Font.GothamBold,
		Parent = TitleBar
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = closeBtn })

	closeBtn.MouseEnter:Connect(function()
		TweenService:Create(closeBtn, TweenInfo.new(0.15), {
			BackgroundTransparency = 0.3,
			TextColor3 = Color3.new(1, 1, 1)
		}):Play()
	end)
	closeBtn.MouseLeave:Connect(function()
		TweenService:Create(closeBtn, TweenInfo.new(0.15), {
			BackgroundTransparency = 0.8,
			TextColor3 = ThemeManager:Get("Text")
		}):Play()
	end)
	closeBtn.MouseButton1Click:Connect(function() self:Toggle() end)

	-- Tab Container
	local TabContainer = Create("Frame", {
		Name = "TabContainer",
		Size = UDim2.new(1, 0, 0, 40),
		Position = UDim2.new(0, 0, 0, 40),
		BackgroundColor3 = ThemeManager:Get("Surface"),
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		Parent = MainFrame
	})
	Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 3),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = TabContainer
	})
	self.TabContainer = TabContainer

	-- Content Container
	local ContentContainer = Create("Frame", {
		Name = "ContentContainer",
		Size = UDim2.new(1, 0, 1, -80),
		Position = UDim2.new(0, 0, 0, 80),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = MainFrame
	})
	self.ContentContainer = ContentContainer

	self:MakeDraggable(TitleBar)
end

function Window:MakeDraggable(dragPart)
	local dragging, dragInput, mousePos, framePos

	dragPart.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			mousePos = input.Position
			framePos = self.MainFrame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)

	dragPart.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - mousePos
			self.MainFrame.Position = UDim2.new(
				framePos.X.Scale, framePos.X.Offset + delta.X,
				framePos.Y.Scale, framePos.Y.Offset + delta.Y
			)
		end
	end)
end

function Window:CreateTab(name)
	local tab = { Name = name, Elements = {} }

	local tabBtn = Create("TextButton", {
		Name = "Tab_" .. name,
		Text = name,
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = ThemeManager:Get("Primary"),
		BackgroundTransparency = 1,
		TextColor3 = ThemeManager:Get("TextSecondary"),
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
		BorderSizePixel = 0,
		Parent = self.TabContainer
	})
	Create("UIPadding", {
		PaddingLeft = UDim.new(0, 14),
		PaddingRight = UDim.new(0, 14),
		Parent = tabBtn
	})

	local tabContent = Create("ScrollingFrame", {
		Name = "TabContent_" .. name,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = ThemeManager:Get("Primary"),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false,
		Parent = self.ContentContainer
	})
	Create("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = tabContent
	})
	Create("UIPadding", {
		PaddingTop = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		Parent = tabContent
	})

	tab.Button = tabBtn
	tab.Content = tabContent

	tabBtn.MouseButton1Click:Connect(function()
		self:SelectTab(tab)
	end)

	table.insert(self.Tabs, tab)

	if not self.ActiveTab then
		self:SelectTab(tab)
	end

	-- Métodos del tab
	function tab:Label(text, bold) return Label.new(tabContent, {Text = text, Bold = bold}) end
	function tab:Divider() return Divider.new(tabContent) end
	function tab:Button(text, callback) return Button.new(tabContent, {Text = text, Callback = callback}) end
	function tab:Toggle(text, default, callback) return Toggle.new(tabContent, {Text = text, Default = default, Callback = callback}) end
	function tab:Slider(text, min, max, default, callback) return Slider.new(tabContent, {Text = text, Min = min, Max = max, Default = default, Callback = callback}) end

	return tab
end

function Window:SelectTab(tab)
	if self.ActiveTab then
		self.ActiveTab.Button.BackgroundTransparency = 1
		self.ActiveTab.Button.TextColor3 = ThemeManager:Get("TextSecondary")
		self.ActiveTab.Content.Visible = false
	end
	self.ActiveTab = tab
	tab.Button.BackgroundTransparency = 0.2
	tab.Button.TextColor3 = ThemeManager:Get("Text")
	tab.Content.Visible = true
end

function Window:Toggle()
	self.Visible = not self.Visible
	if self.Visible then
		self.Gui.Enabled = true
		self.MainFrame.Size = UDim2.new(0, 0, 0, 0)
		TweenService:Create(self.MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Size = self.Size
		}):Play()
	else
		TweenService:Create(self.MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 0, 0, 0)
		}):Play()
		task.delay(0.3, function() self.Gui.Enabled = false end)
	end
end

function Window:UpdateStyle()
	self.MainFrame.BackgroundColor3 = ThemeManager:Get("Background")
end

-- ==========================================
-- 🎯 COMPONENTES BÁSICOS
-- ==========================================
local Label = {}
Label.__index = Label

function Label.new(parent, options)
	local self = setmetatable({}, Label)
	local label = Create("TextLabel", {
		Name = options.Name or "Label",
		Text = options.Text or "Label",
		TextColor3 = options.Secondary and ThemeManager:Get("TextSecondary") or ThemeManager:Get("Text"),
		TextSize = options.Size or 14,
		Font = options.Bold and Enum.Font.GothamBold or Enum.Font.Gotham,
		Size = UDim2.new(1, 0, 0, 22),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Parent = parent
	})
	Create("UIPadding", {
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		Parent = label
	})
	self.Label = label
	ThemeManager:Subscribe(self)
	return self
end

function Label:UpdateStyle()
	self.Label.TextColor3 = ThemeManager:Get("Text")
end

local Divider = {}
Divider.__index = Divider

function Divider.new(parent)
	local self = setmetatable({}, Divider)
	local container = Create("Frame", {
		Name = "Divider",
		Size = UDim2.new(1, 0, 0, 12),
		BackgroundTransparency = 1,
		Parent = parent
	})
	local line = Create("Frame", {
		Size = UDim2.new(1, -24, 0, 2),
		Position = UDim2.new(0, 12, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = ThemeManager:Get("Secondary"),
		BorderSizePixel = 0,
		Parent = container
	})
	Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = line })
	self.Line = line
	ThemeManager:Subscribe(self)
	return self
end

function Divider:UpdateStyle()
	self.Line.BackgroundColor3 = ThemeManager:Get("Secondary")
end

local Button = {}
Button.__index = Button

function Button.new(parent, options)
	local self = setmetatable({}, Button)
	self.Callback = options.Callback

	local btn = Create("TextButton", {
		Name = options.Name or "Button",
		Text = options.Text or "Button",
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundColor3 = ThemeManager:Get("Surface"),
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		TextColor3 = ThemeManager:Get("Text"),
		TextSize = 14,
		Font = Enum.Font.GothamMedium,
		AutoButtonColor = false,
		ClipsDescendants = true,
		Parent = parent
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = btn })
	Create("UIStroke", {
		Color = ThemeManager:Get("Secondary"),
		Thickness = 2,
		Transparency = 0.4,
		Parent = btn
	})
	self.Btn = btn

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {
			BackgroundColor3 = ThemeManager:Get("SurfaceHover"),
			BackgroundTransparency = 0.05
		}):Play()
	end)

	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {
			BackgroundColor3 = ThemeManager:Get("Surface"),
			BackgroundTransparency = 0.2
		}):Play()
	end)

	btn.MouseButton1Click:Connect(function()
		self:Ripple()
		if self.Callback then self.Callback() end
	end)

	ThemeManager:Subscribe(self)
	return self
end

function Button:Ripple()
	local ripple = Create("Frame", {
		BackgroundColor3 = ThemeManager:Get("Primary"),
		BackgroundTransparency = 0.5,
		Size = UDim2.new(0, 0, 0, 0),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Parent = self.Btn
	})
	Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ripple })
	TweenService:Create(ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(3, 0, 3, 0),
		BackgroundTransparency = 1
	}):Play()
	game.Debris:AddItem(ripple, 0.6)
end

function Button:UpdateStyle()
	self.Btn.BackgroundColor3 = ThemeManager:Get("Surface")
	self.Btn.TextColor3 = ThemeManager:Get("Text")
end

local Toggle = {}
Toggle.__index = Toggle

function Toggle.new(parent, options)
	local self = setmetatable({}, Toggle)
	self.Value = options.Default or false
	self.Callback = options.Callback

	local container = Create("TextButton", {
		Name = options.Name or "Toggle",
		Text = "",
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundColor3 = ThemeManager:Get("Surface"),
		BackgroundTransparency = 0.4,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Parent = parent
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = container })

	local label = Create("TextLabel", {
		Text = options.Text or "Toggle",
		TextColor3 = ThemeManager:Get("Text"),
		TextSize = 14,
		Font = Enum.Font.Gotham,
		Size = UDim2.new(1, -60, 1, 0),
		Position = UDim2.new(0, 12, 0, 0),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = container
	})

	local track = Create("Frame", {
		Size = UDim2.new(0, 38, 0, 20),
		Position = UDim2.new(1, -48, 0.5, -10),
		BackgroundColor3 = ThemeManager:Get("Secondary"),
		BorderSizePixel = 0,
		Parent = container
	})
	Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })

	local knob = Create("Frame", {
		Size = UDim2.new(0, 16, 0, 16),
		Position = UDim2.new(0, 2, 0.5, -8),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Parent = track
	})
	Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })

	self.Track = track
	self.Knob = knob
	self.Container = container

	container.MouseButton1Click:Connect(function()
		self:SetValue(not self.Value)
	end)

	self:UpdateVisual()
	ThemeManager:Subscribe(self)
	return self
end

function Toggle:SetValue(value)
	self.Value = value
	self:UpdateVisual()
	if self.Callback then self.Callback(value) end
end

function Toggle:UpdateVisual()
	local targetPos = self.Value and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
	local targetColor = self.Value and ThemeManager:Get("Primary") or ThemeManager:Get("Secondary")
	TweenService:Create(self.Knob, TweenInfo.new(0.25, Enum.EasingStyle.Quad), { Position = targetPos }):Play()
	TweenService:Create(self.Track, TweenInfo.new(0.25), { BackgroundColor3 = targetColor }):Play()
end

function Toggle:UpdateStyle()
	self.Container.BackgroundColor3 = ThemeManager:Get("Surface")
	self:UpdateVisual()
end

local Slider = {}
Slider.__index = Slider

function Slider.new(parent, options)
	local self = setmetatable({}, Slider)
	self.Min = options.Min or 0
	self.Max = options.Max or 100
	self.Value = options.Default or self.Min
	self.Callback = options.Callback

	local container = Create("Frame", {
		Name = options.Name or "Slider",
		Size = UDim2.new(1, 0, 0, 45),
		BackgroundColor3 = ThemeManager:Get("Surface"),
		BackgroundTransparency = 0.4,
		BorderSizePixel = 0,
		Parent = parent
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = container })

	local label = Create("TextLabel", {
		Text = options.Text or "Slider",
		TextColor3 = ThemeManager:Get("Text"),
		TextSize = 14,
		Font = Enum.Font.Gotham,
		Size = UDim2.new(1, -60, 0, 22),
		Position = UDim2.new(0, 12, 0, 5),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = container
	})

	local valueLabel = Create("TextLabel", {
		Text = tostring(self.Value),
		TextColor3 = ThemeManager:Get("TextSecondary"),
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
		Size = UDim2.new(0, 50, 0, 22),
		Position = UDim2.new(1, -55, 0, 5),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = container
	})
	self.ValueLabel = valueLabel

	local track = Create("TextButton", {
		Text = "",
		Size = UDim2.new(1, -24, 0, 8),
		Position = UDim2.new(0, 12, 0, 30),
		BackgroundColor3 = ThemeManager:Get("Secondary"),
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Parent = container
	})
	Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })

	local fill = Create("Frame", {
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = ThemeManager:Get("Primary"),
		BorderSizePixel = 0,
		Parent = track
	})
	Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })

	local knob = Create("Frame", {
		Size = UDim2.new(0, 14, 0, 14),
		Position = UDim2.new(1, -7, 0.5, -7),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Parent = fill
	})
	Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })
	Create("UIStroke", { Color = ThemeManager:Get("Primary"), Thickness = 2, Parent = knob })

	self.Track = track
	self.Fill = fill
	self.Knob = knob
	self.Container = container

	local dragging = false
	track.MouseButton1Down:Connect(function() dragging = true end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			self:UpdateFromMouse(input.Position.X)
		end
	end)

	self:UpdateVisual()
	ThemeManager:Subscribe(self)
	return self
end

function Slider:UpdateFromMouse(mouseX)
	local absPos = self.Track.AbsolutePosition.X
	local absSize = self.Track.AbsoluteSize.X
	local percent = math.clamp((mouseX - absPos) / absSize, 0, 1)
	self.Value = math.floor(self.Min + (self.Max - self.Min) * percent)
	self:UpdateVisual()
	if self.Callback then self.Callback(self.Value) end
end

function Slider:UpdateVisual()
	local percent = (self.Value - self.Min) / (self.Max - self.Min)
	self.Fill.Size = UDim2.new(percent, 0, 1, 0)
	self.ValueLabel.Text = tostring(self.Value)
end

function Slider:UpdateStyle()
	self.Container.BackgroundColor3 = ThemeManager:Get("Surface")
	self.Track.BackgroundColor3 = ThemeManager:Get("Secondary")
	self.Fill.BackgroundColor3 = ThemeManager:Get("Primary")
end

-- ==========================================
-- 🎯 BOTÓN FLOTANTE CON ICONO
-- ==========================================
local FloatingButton = {}
FloatingButton.__index = FloatingButton

function FloatingButton.new(iconId, callback)
	local self = setmetatable({}, FloatingButton)
	self.Callback = callback
	self.Visible = true

	local gui = Create("ScreenGui", {
		Name = "AuraFloatingButton",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = PlayerGui
	})
	self.Gui = gui

	local btn = Create("TextButton", {
		Name = "FloatingBtn",
		Text = "",
		Size = UDim2.new(0, 60, 0, 60),
		Position = UDim2.new(1, -80, 1, -80),
		BackgroundColor3 = ThemeManager:Get("Primary"),
		BackgroundTransparency = 0.1,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Parent = gui
	})
	Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = btn })
	Create("UIStroke", {
		Color = ThemeManager:Get("Secondary"),
		Thickness = 3,
		Transparency = 0.2,
		Parent = btn
	})

	local icon = Create("ImageLabel", {
		Name = "Icon",
		Image = "rbxassetid://" .. tostring(iconId),
		Size = UDim2.new(0, 36, 0, 36),
		Position = UDim2.new(0.5, -18, 0.5, -18),
		BackgroundTransparency = 1,
		Parent = btn
	})

	self.Btn = btn

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {
			Size = UDim2.new(0, 68, 0, 68),
			BackgroundTransparency = 0
		}):Play()
	end)

	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {
			Size = UDim2.new(0, 60, 0, 60),
			BackgroundTransparency = 0.1
		}):Play()
	end)

	btn.MouseButton1Click:Connect(function()
		if self.Callback then self.Callback() end
	end)

	-- Hacer arrastrable
	local dragging, dragInput, mousePos, btnPos
	btn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			mousePos = input.Position
			btnPos = btn.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	btn.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - mousePos
			btn.Position = UDim2.new(
				btnPos.X.Scale, btnPos.X.Offset + delta.X,
				btnPos.Y.Scale, btnPos.Y.Offset + delta.Y
			)
		end
	end)

	ThemeManager:Subscribe(self)
	return self
end

function FloatingButton:Toggle()
	self.Visible = not self.Visible
	self.Gui.Enabled = self.Visible
end

function FloatingButton:UpdateStyle()
	self.Btn.BackgroundColor3 = ThemeManager:Get("Primary")
end

-- ==========================================
-- 🎮 API PRINCIPAL
-- ==========================================
function AuraUI:CreateWindow(options)
	return Window.new(options)
end

function AuraUI:SetTheme(themeName, customColors)
	ThemeManager:Apply(themeName, customColors)
end

function AuraUI:GetTheme()
	return ThemeManager:GetCurrentThemeName()
end

function AuraUI:Notify(options)
	Notification:Show(options)
end

function AuraUI:CreateFloatingButton(iconId, callback)
	return FloatingButton.new(iconId, callback)
end

-- ==========================================
-- 🚀 RETORNAR LIBRERÍA
-- ==========================================
return AuraUI
