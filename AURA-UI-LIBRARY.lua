--[[
	╔══════════════════════════════════════════════════╗
	║              AURA UI LIBRARY v1.0.0              ║
	║      UI Library Moderna y Modular para Roblox    ║
	║                                                  ║
	║  Uso:                                            ║
	║  local AuraUI = require(game.ReplicatedStorage.  ║
	║                      AuraUI)                     ║
	║  local window = AuraUI:CreateWindow({            ║
	║      Name = "Mi Panel"                           ║
	║  })                                              ║
	║  local tab = window:CreateTab("Principal")       ║
	║  tab:Button({Text="Hola", Callback=function()    ║
	║      print("Click") end})                        ║
	╚══════════════════════════════════════════════════╝
]]

local AuraUI = {}
AuraUI.__index = AuraUI
AuraUI.Version = "1.0.0"

-- ═══════════════════════════════════════════════════════
-- SERVICIOS
-- ═══════════════════════════════════════════════════════
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

-- ═══════════════════════════════════════════════════════
-- THEME MANAGER (Motor de Temas)
-- ═══════════════════════════════════════════════════════
local ThemeManager = {}
ThemeManager.__index = ThemeManager

local Themes = {
	Dark = {
		Background = Color3.fromRGB(20, 20, 22),
		Surface = Color3.fromRGB(30, 30, 34),
		SurfaceHover = Color3.fromRGB(40, 40, 45),
		Text = Color3.fromRGB(240, 240, 240),
		TextSecondary = Color3.fromRGB(160, 160, 165),
		Border = Color3.fromRGB(50, 50, 55),
		Accent = Color3.fromRGB(100, 150, 255),
		Success = Color3.fromRGB(80, 200, 120),
		Error = Color3.fromRGB(255, 80, 80),
		Warning = Color3.fromRGB(255, 180, 50),
		Info = Color3.fromRGB(100, 150, 255),
	},
	Light = {
		Background = Color3.fromRGB(245, 245, 247),
		Surface = Color3.fromRGB(255, 255, 255),
		SurfaceHover = Color3.fromRGB(235, 235, 240),
		Text = Color3.fromRGB(20, 20, 25),
		TextSecondary = Color3.fromRGB(100, 100, 110),
		Border = Color3.fromRGB(210, 210, 215),
		Accent = Color3.fromRGB(60, 120, 230),
		Success = Color3.fromRGB(50, 180, 100),
		Error = Color3.fromRGB(230, 60, 60),
		Warning = Color3.fromRGB(230, 160, 40),
		Info = Color3.fromRGB(60, 120, 230),
	},
}

local CurrentThemeName = "Dark"
local CurrentTheme = Themes.Dark
local Subscribers = {}

function ThemeManager:Apply(themeName, customOverrides)
	if Themes[themeName] then
		CurrentThemeName = themeName
		CurrentTheme = Themes[themeName]
	end
	if customOverrides then
		for key, value in pairs(customOverrides) do
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

function ThemeManager:Unsubscribe(object)
	local idx = table.find(Subscribers, object)
	if idx then table.remove(Subscribers, idx) end
end

AuraUI.ThemeManager = ThemeManager

-- ═══════════════════════════════════════════════════════
-- COMPONENTE: LABEL
-- ═══════════════════════════════════════════════════════
local Label = {}
Label.__index = Label

function Label.new(parent, options)
	local self = setmetatable({}, Label)
	local label = Create("TextLabel", {
		Name = options.Name or "Label",
		Text = options.Text or "Label",
		TextColor3 = options.Secondary and ThemeManager:Get("TextSecondary") or ThemeManager:Get("Text"),
		TextSize = options.Size or 13,
		Font = options.Bold and Enum.Font.GothamBold or Enum.Font.Gotham,
		Size = UDim2.new(1, 0, 0, 20),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Parent = parent
	})
	Create("UIPadding", {
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
		Parent = label
	})
	self.Label = label
	ThemeManager:Subscribe(self)
	return self
end

function Label:SetText(text)
	self.Label.Text = text
end

function Label:UpdateStyle()
	self.Label.TextColor3 = ThemeManager:Get("Text")
end

-- ═══════════════════════════════════════════════════════
-- COMPONENTE: DIVIDER
-- ═══════════════════════════════════════════════════════
local Divider = {}
Divider.__index = Divider

function Divider.new(parent)
	local self = setmetatable({}, Divider)
	local container = Create("Frame", {
		Name = "Divider",
		Size = UDim2.new(1, 0, 0, 10),
		BackgroundTransparency = 1,
		Parent = parent
	})
	local line = Create("Frame", {
		Size = UDim2.new(1, -20, 0, 1),
		Position = UDim2.new(0, 10, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = ThemeManager:Get("Border"),
		BorderSizePixel = 0,
		Parent = container
	})
	self.Line = line
	ThemeManager:Subscribe(self)
	return self
end

function Divider:UpdateStyle()
	self.Line.BackgroundColor3 = ThemeManager:Get("Border")
end

-- ═══════════════════════════════════════════════════════
-- COMPONENTE: BUTTON (con Ripple Effect)
-- ═══════════════════════════════════════════════════════
local Button = {}
Button.__index = Button

function Button.new(parent, options)
	local self = setmetatable({}, Button)
	self.Callback = options.Callback

	local btn = Create("TextButton", {
		Name = options.Name or "Button",
		Text = options.Text or "Button",
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = ThemeManager:Get("Surface"),
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		TextColor3 = ThemeManager:Get("Text"),
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
		AutoButtonColor = false,
		ClipsDescendants = true,
		Parent = parent
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btn })
	Create("UIStroke", {
		Color = ThemeManager:Get("Border"),
		Thickness = 1,
		Transparency = 0.5,
		Parent = btn
	})
	self.Btn = btn

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {
			BackgroundColor3 = ThemeManager:Get("SurfaceHover"),
			BackgroundTransparency = 0.1
		}):Play()
	end)

	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {
			BackgroundColor3 = ThemeManager:Get("Surface"),
			BackgroundTransparency = 0.3
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
		BackgroundColor3 = ThemeManager:Get("Accent"),
		BackgroundTransparency = 0.6,
		Size = UDim2.new(0, 0, 0, 0),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Parent = self.Btn
	})
	Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ripple })
	TweenService:Create(ripple, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(3, 0, 3, 0),
		BackgroundTransparency = 1
	}):Play()
	game.Debris:AddItem(ripple, 0.5)
end

function Button:UpdateStyle()
	self.Btn.BackgroundColor3 = ThemeManager:Get("Surface")
	self.Btn.TextColor3 = ThemeManager:Get("Text")
end

-- ═══════════════════════════════════════════════════════
-- COMPONENTE: TOGGLE
-- ═══════════════════════════════════════════════════════
local Toggle = {}
Toggle.__index = Toggle

function Toggle.new(parent, options)
	local self = setmetatable({}, Toggle)
	self.Value = options.Default or false
	self.Callback = options.Callback

	local container = Create("TextButton", {
		Name = options.Name or "Toggle",
		Text = "",
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = ThemeManager:Get("Surface"),
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Parent = parent
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = container })

	local label = Create("TextLabel", {
		Text = options.Text or "Toggle",
		TextColor3 = ThemeManager:Get("Text"),
		TextSize = 13,
		Font = Enum.Font.Gotham,
		Size = UDim2.new(1, -50, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = container
	})

	local track = Create("Frame", {
		Size = UDim2.new(0, 34, 0, 18),
		Position = UDim2.new(1, -42, 0.5, -9),
		BackgroundColor3 = ThemeManager:Get("Border"),
		BorderSizePixel = 0,
		Parent = container
	})
	Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })

	local knob = Create("Frame", {
		Size = UDim2.new(0, 14, 0, 14),
		Position = UDim2.new(0, 2, 0.5, -7),
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

function Toggle:GetValue()
	return self.Value
end

function Toggle:UpdateVisual()
	local targetPos = self.Value and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
	local targetColor = self.Value and ThemeManager:Get("Accent") or ThemeManager:Get("Border")
	TweenService:Create(self.Knob, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { Position = targetPos }):Play()
	TweenService:Create(self.Track, TweenInfo.new(0.2), { BackgroundColor3 = targetColor }):Play()
end

function Toggle:UpdateStyle()
	self.Container.BackgroundColor3 = ThemeManager:Get("Surface")
	self:UpdateVisual()
end

-- ═══════════════════════════════════════════════════════
-- COMPONENTE: SLIDER
-- ═══════════════════════════════════════════════════════
local Slider = {}
Slider.__index = Slider

function Slider.new(parent, options)
	local self = setmetatable({}, Slider)
	self.Min = options.Min or 0
	self.Max = options.Max or 100
	self.Value = options.Default or self.Min
	self.Callback = options.Callback
	self.Precise = options.Precise or 1

	local container = Create("Frame", {
		Name = options.Name or "Slider",
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = ThemeManager:Get("Surface"),
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		Parent = parent
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = container })

	local label = Create("TextLabel", {
		Text = options.Text or "Slider",
		TextColor3 = ThemeManager:Get("Text"),
		TextSize = 13,
		Font = Enum.Font.Gotham,
		Size = UDim2.new(1, -50, 0, 20),
		Position = UDim2.new(0, 10, 0, 4),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = container
	})

	local valueLabel = Create("TextLabel", {
		Text = tostring(self.Value),
		TextColor3 = ThemeManager:Get("TextSecondary"),
		TextSize = 12,
		Font = Enum.Font.GothamMedium,
		Size = UDim2.new(0, 40, 0, 20),
		Position = UDim2.new(1, -45, 0, 4),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = container
	})
	self.ValueLabel = valueLabel

	local track = Create("TextButton", {
		Text = "",
		Size = UDim2.new(1, -20, 0, 6),
		Position = UDim2.new(0, 10, 0, 28),
		BackgroundColor3 = ThemeManager:Get("Border"),
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Parent = container
	})
	Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })

	local fill = Create("Frame", {
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = ThemeManager:Get("Accent"),
		BorderSizePixel = 0,
		Parent = track
	})
	Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })

	local knob = Create("Frame", {
		Size = UDim2.new(0, 12, 0, 12),
		Position = UDim2.new(1, -6, 0.5, -6),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Parent = fill
	})
	Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })
	Create("UIStroke", { Color = ThemeManager:Get("Accent"), Thickness = 2, Parent = knob })

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
	local rawValue = self.Min + (self.Max - self.Min) * percent
	self.Value = math.floor(rawValue / self.Precise + 0.5) * self.Precise
	self:UpdateVisual()
	if self.Callback then self.Callback(self.Value) end
end

function Slider:SetValue(value)
	self.Value = math.clamp(value, self.Min, self.Max)
	self:UpdateVisual()
	if self.Callback then self.Callback(self.Value) end
end

function Slider:GetValue()
	return self.Value
end

function Slider:UpdateVisual()
	local percent = (self.Value - self.Min) / (self.Max - self.Min)
	self.Fill.Size = UDim2.new(percent, 0, 1, 0)
	self.ValueLabel.Text = tostring(self.Value)
end

function Slider:UpdateStyle()
	self.Container.BackgroundColor3 = ThemeManager:Get("Surface")
	self.Track.BackgroundColor3 = ThemeManager:Get("Border")
	self.Fill.BackgroundColor3 = ThemeManager:Get("Accent")
end

-- ═══════════════════════════════════════════════════════
-- COMPONENTE: NOTIFICATION (Toast System)
-- ═══════════════════════════════════════════════════════
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
		Size = UDim2.new(0, 280, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = ThemeManager:Get("Surface"),
		BackgroundTransparency = 0.1,
		BorderSizePixel = 0,
		Parent = gui
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = toast })
	Create("UIStroke", {
		Color = ThemeManager:Get("Border"),
		Thickness = 1,
		Transparency = 0.4,
		Parent = toast
	})

	local accentBar = Create("Frame", {
		Size = UDim2.new(0, 3, 1, 0),
		BackgroundColor3 = ThemeManager:Get(type) or ThemeManager:Get("Accent"),
		BorderSizePixel = 0,
		Parent = toast
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 2), Parent = accentBar })

	Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Parent = toast
	})

	local content = Create("Frame", {
		Size = UDim2.new(1, -3, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = toast
	})
	Create("UIPadding", {
		PaddingTop = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
		Parent = content
	})
	Create("UIListLayout", {
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = content
	})

	Create("TextLabel", {
		Text = title,
		TextColor3 = ThemeManager:Get("Text"),
		TextSize = 13,
		Font = Enum.Font.GothamBold,
		Size = UDim2.new(1, 0, 0, 16),
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
		Size = UDim2.new(1, 0, 0, 14),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Parent = content
	})

	local index = #Notifications
	toast.Position = UDim2.new(1, -300, 1, -60 - (index * 70))
	table.insert(Notifications, toast)

	task.spawn(function()
		task.wait(0.1)
		local targetHeight = content.AbsoluteSize.Y + 20
		TweenService:Create(toast, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 280, 0, targetHeight)
		}):Play()
	end)

	task.delay(duration, function()
		self:Dismiss(toast)
	end)
end

function Notification:Dismiss(toast)
	TweenService:Create(toast, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Position = UDim2.new(1, 50, toast.Position.Y.Scale, toast.Position.Y.Offset),
		BackgroundTransparency = 1
	}):Play()
	task.delay(0.3, function()
		local idx = table.find(Notifications, toast)
		if idx then table.remove(Notifications, idx) end
		toast:Destroy()
		self:Reposition()
	end)
end

function Notification:Reposition()
	for i, toast in ipairs(Notifications) do
		TweenService:Create(toast, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
			Position = UDim2.new(1, -300, 1, -60 - ((i-1) * 70))
		}):Play()
	end
end

-- ═══════════════════════════════════════════════════════
-- COMPONENTE: WINDOW (Ventana principal con Tabs)
-- ═══════════════════════════════════════════════════════
local Window = {}
Window.__index = Window

function Window.new(options)
	local self = setmetatable({}, Window)
	self.Name = options.Name or "Aura Window"
	self.Size = options.Size or UDim2.new(0, 500, 0, 350)
	self.Position = options.Position or UDim2.new(0.5, -250, 0.5, -175)
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
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = ScreenGui
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = MainFrame })
	Create("UIStroke", {
		Color = ThemeManager:Get("Border"),
		Thickness = 1,
		Transparency = 0.3,
		Parent = MainFrame
	})
	self.MainFrame = MainFrame

	-- Title Bar
	local TitleBar = Create("Frame", {
		Name = "TitleBar",
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundColor3 = ThemeManager:Get("Surface"),
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		Parent = MainFrame
	})

	Create("TextLabel", {
		Name = "Title",
		Text = self.Name,
		TextColor3 = ThemeManager:Get("Text"),
		TextSize = 13,
		Font = Enum.Font.GothamBold,
		Size = UDim2.new(1, -80, 1, 0),
		Position = UDim2.new(0, 12, 0, 0),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = TitleBar
	})

	local btnSize = UDim2.new(0, 30, 0, 30)
	local closeBtn = Create("TextButton", {
		Name = "Close", Text = "✕", Size = btnSize,
		Position = UDim2.new(1, -35, 0, 3),
		BackgroundTransparency = 1, TextColor3 = ThemeManager:Get("TextSecondary"),
		TextSize = 14, Font = Enum.Font.GothamBold, Parent = TitleBar
	})
	closeBtn.MouseEnter:Connect(function()
		TweenService:Create(closeBtn, TweenInfo.new(0.15), { TextColor3 = ThemeManager:Get("Error") }):Play()
	end)
	closeBtn.MouseLeave:Connect(function()
		TweenService:Create(closeBtn, TweenInfo.new(0.15), { TextColor3 = ThemeManager:Get("TextSecondary") }):Play()
	end)
	closeBtn.MouseButton1Click:Connect(function() self:Toggle() end)

	-- Tab Container
	local TabContainer = Create("Frame", {
		Name = "TabContainer",
		Size = UDim2.new(1, 0, 0, 36),
		Position = UDim2.new(0, 0, 0, 36),
		BackgroundColor3 = ThemeManager:Get("Surface"),
		BackgroundTransparency = 0.7,
		BorderSizePixel = 0,
		Parent = MainFrame
	})
	Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 2),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = TabContainer
	})
	self.TabContainer = TabContainer

	-- Content Container
	local ContentContainer = Create("Frame", {
		Name = "ContentContainer",
		Size = UDim2.new(1, 0, 1, -72),
		Position = UDim2.new(0, 0, 0, 72),
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
		BackgroundColor3 = ThemeManager:Get("Accent"),
		BackgroundTransparency = 1,
		TextColor3 = ThemeManager:Get("TextSecondary"),
		TextSize = 12,
		Font = Enum.Font.GothamMedium,
		BorderSizePixel = 0,
		Parent = self.TabContainer
	})
	Create("UIPadding", {
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		Parent = tabBtn
	})

	local tabContent = Create("ScrollingFrame", {
		Name = "TabContent_" .. name,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = ThemeManager:Get("Accent"),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false,
		Parent = self.ContentContainer
	})
	Create("UIListLayout", {
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = tabContent
	})
	Create("UIPadding", {
		PaddingTop = UDim.new(0, 8),
		PaddingBottom = UDim.new(0, 8),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
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

	-- Métodos del tab para añadir componentes
	function tab:Button(opts) return Button.new(tabContent, opts) end
	function tab:Toggle(opts) return Toggle.new(tabContent, opts) end
	function tab:Slider(opts) return Slider.new(tabContent, opts) end
	function tab:Label(opts) return Label.new(tabContent, opts) end
	function tab:Divider() return Divider.new(tabContent) end

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
		TweenService:Create(self.MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Size = self.Size
		}):Play()
	else
		TweenService:Create(self.MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 0, 0, 0)
		}):Play()
		task.delay(0.2, function() self.Gui.Enabled = false end)
	end
end

function Window:UpdateStyle()
	self.MainFrame.BackgroundColor3 = ThemeManager:Get("Background")
end

-- ═══════════════════════════════════════════════════════
-- API PRINCIPAL DE AuraUI
-- ═══════════════════════════════════════════════════════
function AuraUI:CreateWindow(options)
	options = options or {}
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

function AuraUI:LoadConfig(configTable)
	if configTable and configTable.Theme then
		self:SetTheme(configTable.Theme, configTable.CustomColors)
	end
end

return AuraUI
