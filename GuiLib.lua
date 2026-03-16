--[[
    Universal Executor GUI Library v2.0
    Compatible with most Roblox executors (Synapse, Krnl, Script-Ware, etc.)
    Features: Windows, Tabs, Buttons, Toggles, Sliders, Dropdowns, TextBoxes, Labels, Notifications
]]

local Library = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Services check (for compatibility)
local function checkServices()
    local services = {
        UserInputService = UserInputService,
        TweenService = TweenService,
        RunService = RunService,
        Players = Players
    }
    return services
end

-- Theme settings (easily customizable)
Library.Theme = {
    Background = Color3.fromRGB(25, 25, 25),
    Secondary = Color3.fromRGB(35, 35, 35),
    Accent = Color3.fromRGB(0, 120, 215),
    AccentDark = Color3.fromRGB(0, 85, 170),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(180, 180, 180),
    Border = Color3.fromRGB(45, 45, 45),
    Shadow = Color3.fromRGB(0, 0, 0),
    Success = Color3.fromRGB(76, 175, 80),
    Warning = Color3.fromRGB(255, 193, 7),
    Error = Color3.fromRGB(244, 67, 54)
}

-- Font settings
Library.Fonts = {
    UI = Drawing.Fonts.UI,           -- Standard UI font
    Monospace = Drawing.Fonts.Monospace, -- Code font
    System = Drawing.Fonts.System     -- System default
}

-- Core Drawing functions wrapper (for compatibility)
local function newDrawObject(type, properties)
    local obj = Drawing.new(type)
    if properties then
        for prop, value in pairs(properties) do
            obj[prop] = value
        end
    end
    return obj
end

--[[
    MAIN WINDOW CREATION
]]
function Library:CreateWindow(config)
    config = config or {}
    local windowConfig = {
        Title = config.Title or "Executor GUI",
        Size = config.Size or Vector2.new(500, 350),
        Position = config.Position or Vector2.new(100, 100),
        ShowCloseButton = config.ShowCloseButton ~= false,
        ShowMinimizeButton = config.ShowMinimizeButton ~= false,
        Draggable = config.Draggable ~= false,
        Resizable = config.Resizable or false,
        Theme = config.Theme or Library.Theme
    }
    
    local window = {
        Config = windowConfig,
        Tabs = {},
        ActiveTab = nil,
        Dragging = { Active = false, Offset = Vector2.new(0, 0) },
        Resizing = { Active = false, Direction = nil, StartSize = Vector2.new(0, 0), StartPos = Vector2.new(0, 0) },
        Minimized = false,
        Visible = true,
        Elements = {}
    }
    
    -- Create window frame
    window.Objects = {}
    
    -- Main background
    window.Objects.Background = newDrawObject("Square", {
        Size = windowConfig.Size,
        Position = windowConfig.Position,
        Color = windowConfig.Theme.Background,
        Transparency = 0,
        Filled = true,
        Visible = true,
        ZIndex = 1
    })
    
    -- Border
    window.Objects.Border = newDrawObject("Square", {
        Size = windowConfig.Size,
        Position = windowConfig.Position,
        Color = windowConfig.Theme.Border,
        Transparency = 0,
        Thickness = 1,
        Filled = false,
        Visible = true,
        ZIndex = 2
    })
    
    -- Title bar
    window.Objects.TitleBar = newDrawObject("Square", {
        Size = Vector2.new(windowConfig.Size.X, 25),
        Position = windowConfig.Position,
        Color = windowConfig.Theme.Secondary,
        Transparency = 0,
        Filled = true,
        Visible = true,
        ZIndex = 3
    })
    
    -- Title text
    window.Objects.TitleText = newDrawObject("Text", {
        Text = windowConfig.Title,
        Size = 16,
        Position = windowConfig.Position + Vector2.new(10, 5),
        Color = windowConfig.Theme.Text,
        Center = false,
        Outline = true,
        Font = Library.Fonts.UI,
        Visible = true,
        ZIndex = 4
    })
    
    -- Close button (X)
    if windowConfig.ShowCloseButton then
        window.Objects.CloseBtn = newDrawObject("Square", {
            Size = Vector2.new(20, 20),
            Position = windowConfig.Position + Vector2.new(windowConfig.Size.X - 25, 2.5),
            Color = windowConfig.Theme.Error,
            Transparency = 0.3,
            Filled = true,
            Visible = true,
            ZIndex = 4
        })
        
        window.Objects.CloseText = newDrawObject("Text", {
            Text = "×",
            Size = 20,
            Position = windowConfig.Position + Vector2.new(windowConfig.Size.X - 20, 0),
            Color = windowConfig.Theme.Text,
            Center = true,
            Font = Library.Fonts.UI,
            Visible = true,
            ZIndex = 5
        })
    end
    
    -- Minimize button
    if windowConfig.ShowMinimizeButton then
        window.Objects.MinimizeBtn = newDrawObject("Square", {
            Size = Vector2.new(20, 20),
            Position = windowConfig.Position + Vector2.new(windowConfig.Size.X - 50, 2.5),
            Color = windowConfig.Theme.Warning,
            Transparency = 0.3,
            Filled = true,
            Visible = true,
            ZIndex = 4
        })
        
        window.Objects.MinimizeText = newDrawObject("Text", {
            Text = "−",
            Size = 20,
            Position = windowConfig.Position + Vector2.new(windowConfig.Size.X - 40, 0),
            Color = windowConfig.Theme.Text,
            Center = true,
            Font = Library.Fonts.UI,
            Visible = true,
            ZIndex = 5
        })
    end
    
    -- Tab bar background
    window.Objects.TabBar = newDrawObject("Square", {
        Size = Vector2.new(windowConfig.Size.X, 30),
        Position = windowConfig.Position + Vector2.new(0, 25),
        Color = windowConfig.Theme.Secondary,
        Transparency = 0.2,
        Filled = true,
        Visible = true,
        ZIndex = 3
    })
    
    -- Content area background
    window.Objects.ContentArea = newDrawObject("Square", {
        Size = Vector2.new(windowConfig.Size.X - 10, windowConfig.Size.Y - 70),
        Position = windowConfig.Position + Vector2.new(5, 60),
        Color = windowConfig.Theme.Background,
        Transparency = 0,
        Filled = true,
        Visible = true,
        ZIndex = 2
    })
    
    -- Shadow effect
    window.Objects.Shadow = newDrawObject("Square", {
        Size = windowConfig.Size + Vector2.new(10, 10),
        Position = windowConfig.Position - Vector2.new(5, 5),
        Color = windowConfig.Theme.Shadow,
        Transparency = 0.5,
        Filled = true,
        Visible = true,
        ZIndex = 0
    })
    
    --[[
        WINDOW METHODS
    ]]
    
    -- Add a new tab
    function window:AddTab(name)
        local tab = {
            Name = name,
            Elements = {},
            Objects = {},
            Parent = self,
            Position = #self.Tabs + 1
        }
        
        -- Create tab button
        local tabBtnPos = self.Config.Position + Vector2.new(10 + ((#self.Tabs) * 80), 30)
        tab.Objects.Button = newDrawObject("Square", {
            Size = Vector2.new(70, 25),
            Position = tabBtnPos,
            Color = self.Config.Theme.Secondary,
            Transparency = 0.5,
            Filled = true,
            Visible = true,
            ZIndex = 4
        })
        
        tab.Objects.Text = newDrawObject("Text", {
            Text = name,
            Size = 14,
            Position = tabBtnPos + Vector2.new(35, 12.5),
            Color = self.Config.Theme.Text,
            Center = true,
            Font = Library.Fonts.UI,
            Visible = true,
            ZIndex = 5
        })
        
        -- Set as active tab if first
        if #self.Tabs == 0 then
            self.ActiveTab = tab
            tab.Objects.Button.Color = self.Config.Theme.Accent
        end
        
        table.insert(self.Tabs, tab)
        return tab
    end
    
    --[[
        ELEMENT CREATION METHODS (per tab)
    ]]
    
    -- Button element
    function window:AddButton(tab, config)
        config = config or {}
        local element = {
            Type = "Button",
            Text = config.Text or "Button",
            Callback = config.Callback or function() end,
            Tooltip = config.Tooltip or "",
            Position = config.Position or Vector2.new(10, 10 + (#tab.Elements * 35)),
            Size = config.Size or Vector2.new(150, 25),
            Hovered = false,
            Pressed = false
        }
        
        -- Create button objects
        element.Objects = {}
        
        -- Background
        element.Objects.Background = newDrawObject("Square", {
            Size = element.Size,
            Position = self.Config.Position + Vector2.new(10, 70) + element.Position,
            Color = self.Config.Theme.Secondary,
            Transparency = 0.2,
            Filled = true,
            Visible = true,
            ZIndex = 4
        })
        
        -- Border
        element.Objects.Border = newDrawObject("Square", {
            Size = element.Size,
            Position = self.Config.Position + Vector2.new(10, 70) + element.Position,
            Color = self.Config.Theme.Accent,
            Transparency = 0.5,
            Thickness = 1,
            Filled = false,
            Visible = true,
            ZIndex = 5
        })
        
        -- Text
        element.Objects.Text = newDrawObject("Text", {
            Text = element.Text,
            Size = 14,
            Position = self.Config.Position + Vector2.new(10, 70) + element.Position + Vector2.new(element.Size.X/2, element.Size.Y/2),
            Color = self.Config.Theme.Text,
            Center = true,
            Font = Library.Fonts.UI,
            Visible = true,
            ZIndex = 6
        })
        
        table.insert(tab.Elements, element)
        return element
    end
    
    -- Toggle element
    function window:AddToggle(tab, config)
        config = config or {}
        local element = {
            Type = "Toggle",
            Text = config.Text or "Toggle",
            Value = config.Default or false,
            Callback = config.Callback or function() end,
            Position = config.Position or Vector2.new(10, 10 + (#tab.Elements * 35)),
            Hovered = false
        }
        
        -- Create toggle objects
        element.Objects = {}
        
        -- Background
        element.Objects.Background = newDrawObject("Square", {
            Size = Vector2.new(150, 25),
            Position = self.Config.Position + Vector2.new(10, 70) + element.Position,
            Color = self.Config.Theme.Secondary,
            Transparency = 0.2,
            Filled = true,
            Visible = true,
            ZIndex = 4
        })
        
        -- Toggle box
        element.Objects.Box = newDrawObject("Square", {
            Size = Vector2.new(20, 20),
            Position = self.Config.Position + Vector2.new(15, 70) + element.Position + Vector2.new(0, 2.5),
            Color = element.Value and self.Config.Theme.Success or self.Config.Theme.Error,
            Filled = true,
            Visible = true,
            ZIndex = 5
        })
        
        -- Checkmark
        element.Objects.Check = newDrawObject("Text", {
            Text = "✓",
            Size = 16,
            Position = self.Config.Position + Vector2.new(25, 70) + element.Position + Vector2.new(0, 5),
            Color = self.Config.Theme.Text,
            Center = true,
            Visible = element.Value,
            ZIndex = 6
        })
        
        -- Label
        element.Objects.Label = newDrawObject("Text", {
            Text = element.Text,
            Size = 14,
            Position = self.Config.Position + Vector2.new(40, 70) + element.Position + Vector2.new(0, 12.5),
            Color = self.Config.Theme.Text,
            Center = false,
            Font = Library.Fonts.UI,
            Visible = true,
            ZIndex = 5
        })
        
        table.insert(tab.Elements, element)
        return element
    end
    
    -- Slider element
    function window:AddSlider(tab, config)
        config = config or {}
        local element = {
            Type = "Slider",
            Text = config.Text or "Slider",
            Min = config.Min or 0,
            Max = config.Max or 100,
            Value = config.Default or 50,
            Callback = config.Callback or function() end,
            Position = config.Position or Vector2.new(10, 10 + (#tab.Elements * 45)),
            Dragging = false
        }
        
        element.Objects = {}
        
        -- Background
        element.Objects.Background = newDrawObject("Square", {
            Size = Vector2.new(200, 35),
            Position = self.Config.Position + Vector2.new(10, 70) + element.Position,
            Color = self.Config.Theme.Secondary,
            Transparency = 0.2,
            Filled = true,
            Visible = true,
            ZIndex = 4
        })
        
        -- Label
        element.Objects.Label = newDrawObject("Text", {
            Text = element.Text,
            Size = 14,
            Position = self.Config.Position + Vector2.new(15, 70) + element.Position + Vector2.new(0, 8),
            Color = self.Config.Theme.Text,
            Center = false,
            Font = Library.Fonts.UI,
            Visible = true,
            ZIndex = 5
        })
        
        -- Value display
        element.Objects.ValueText = newDrawObject("Text", {
            Text = tostring(element.Value),
            Size = 12,
            Position = self.Config.Position + Vector2.new(190, 70) + element.Position + Vector2.new(0, 8),
            Color = self.Config.Theme.Accent,
            Center = true,
            Font = Library.Fonts.Monospace,
            Visible = true,
            ZIndex = 5
        })
        
        -- Slider bar background
        element.Objects.SliderBg = newDrawObject("Square", {
            Size = Vector2.new(180, 5),
            Position = self.Config.Position + Vector2.new(20, 70) + element.Position + Vector2.new(0, 22),
            Color = self.Config.Theme.Background,
            Filled = true,
            Visible = true,
            ZIndex = 5
        })
        
        -- Slider bar fill
        local fillPercent = (element.Value - element.Min) / (element.Max - element.Min)
        element.Objects.SliderFill = newDrawObject("Square", {
            Size = Vector2.new(180 * fillPercent, 5),
            Position = self.Config.Position + Vector2.new(20, 70) + element.Position + Vector2.new(0, 22),
            Color = self.Config.Theme.Accent,
            Filled = true,
            Visible = true,
            ZIndex = 6
        })
        
        -- Slider handle
        element.Objects.Handle = newDrawObject("Circle", {
            Radius = 4,
            Position = self.Config.Position + Vector2.new(20 + (180 * fillPercent), 70) + element.Position + Vector2.new(0, 24.5),
            Color = self.Config.Theme.Text,
            Filled = true,
            Visible = true,
            ZIndex = 7
        })
        
        table.insert(tab.Elements, element)
        return element
    end
    
    -- Dropdown element
    function window:AddDropdown(tab, config)
        config = config or {}
        local element = {
            Type = "Dropdown",
            Text = config.Text or "Dropdown",
            Options = config.Options or {},
            Selected = config.Default or (config.Options and config.Options[1]) or "",
            Callback = config.Callback or function() end,
            Position = config.Position or Vector2.new(10, 10 + (#tab.Elements * 55)),
            Expanded = false,
            HoveredIndex = nil
        }
        
        element.Objects = {}
        
        -- Background
        element.Objects.Background = newDrawObject("Square", {
            Size = Vector2.new(200, 30),
            Position = self.Config.Position + Vector2.new(10, 70) + element.Position,
            Color = self.Config.Theme.Secondary,
            Transparency = 0.2,
            Filled = true,
            Visible = true,
            ZIndex = 4
        })
        
        -- Label
        element.Objects.Label = newDrawObject("Text", {
            Text = element.Text,
            Size = 14,
            Position = self.Config.Position + Vector2.new(15, 70) + element.Position + Vector2.new(0, 15),
            Color = self.Config.Theme.Text,
            Center = false,
            Font = Library.Fonts.UI,
            Visible = true,
            ZIndex = 5
        })
        
        -- Selected value display
        element.Objects.SelectedText = newDrawObject("Text", {
            Text = element.Selected,
            Size = 14,
            Position = self.Config.Position + Vector2.new(190, 70) + element.Position + Vector2.new(0, 15),
            Color = self.Config.Theme.Accent,
            Center = true,
            Font = Library.Fonts.UI,
            Visible = true,
            ZIndex = 5
        })
        
        -- Arrow
        element.Objects.Arrow = newDrawObject("Triangle", {
            PointA = self.Config.Position + Vector2.new(190, 70) + element.Position + Vector2.new(-5, 20),
            PointB = self.Config.Position + Vector2.new(190, 70) + element.Position + Vector2.new(0, 25),
            PointC = self.Config.Position + Vector2.new(190, 70) + element.Position + Vector2.new(5, 20),
            Color = self.Config.Theme.Text,
            Filled = true,
            Visible = true,
            ZIndex = 5
        })
        
        -- Dropdown container (initially hidden)
        element.Objects.DropdownBg = newDrawObject("Square", {
            Size = Vector2.new(200, math.min(#element.Options * 25, 150)),
            Position = self.Config.Position + Vector2.new(10, 100) + element.Position,
            Color = self.Config.Theme.Background,
            Filled = true,
            Visible = false,
            ZIndex = 8,
            Transparency = 0.95
        })
        
        -- Option objects will be created dynamically when expanded
        
        table.insert(tab.Elements, element)
        return element
    end
    
    -- TextBox element
    function window:AddTextBox(tab, config)
        config = config or {}
        local element = {
            Type = "TextBox",
            Text = config.Text or "Input",
            Placeholder = config.Placeholder or "Type here...",
            Value = config.Default or "",
            Callback = config.Callback or function() end,
            Position = config.Position or Vector2.new(10, 10 + (#tab.Elements * 45)),
            Focused = false,
            Numeric = config.Numeric or false
        }
        
        element.Objects = {}
        
        -- Background
        element.Objects.Background = newDrawObject("Square", {
            Size = Vector2.new(200, 30),
            Position = self.Config.Position + Vector2.new(10, 70) + element.Position,
            Color = self.Config.Theme.Secondary,
            Transparency = 0.2,
            Filled = true,
            Visible = true,
            ZIndex = 4
        })
        
        -- Label
        element.Objects.Label = newDrawObject("Text", {
            Text = element.Text,
            Size = 14,
            Position = self.Config.Position + Vector2.new(15, 70) + element.Position + Vector2.new(0, 8),
            Color = self.Config.Theme.Text,
            Center = false,
            Font = Library.Fonts.UI,
            Visible = true,
            ZIndex = 5
        })
        
        -- Input box
        element.Objects.InputBg = newDrawObject("Square", {
            Size = Vector2.new(180, 20),
            Position = self.Config.Position + Vector2.new(20, 70) + element.Position + Vector2.new(0, 15),
            Color = self.Config.Theme.Background,
            Filled = true,
            Visible = true,
            ZIndex = 5
        })
        
        -- Input text
        element.Objects.InputText = newDrawObject("Text", {
            Text = element.Value ~= "" and element.Value or element.Placeholder,
            Size = 12,
            Position = self.Config.Position + Vector2.new(25, 70) + element.Position + Vector2.new(0, 22),
            Color = element.Value ~= "" and self.Config.Theme.Text or self.Config.Theme.TextDim,
            Center = false,
            Font = Library.Fonts.Monospace,
            Visible = true,
            ZIndex = 6
        })
        
        table.insert(tab.Elements, element)
        return element
    end
    
    -- Label element
    function window:AddLabel(tab, config)
        config = config or {}
        local element = {
            Type = "Label",
            Text = config.Text or "Label",
            Color = config.Color or self.Config.Theme.Text,
            Position = config.Position or Vector2.new(10, 10 + (#tab.Elements * 25)),
            Size = config.Size or 14
        }
        
        element.Objects = {}
        
        -- Text
        element.Objects.Text = newDrawObject("Text", {
            Text = element.Text,
            Size = element.Size,
            Position = self.Config.Position + Vector2.new(15, 70) + element.Position + Vector2.new(0, element.Size/2),
            Color = element.Color,
            Center = false,
            Font = Library.Fonts.UI,
            Visible = true,
            ZIndex = 4
        })
        
        table.insert(tab.Elements, element)
        return element
    end
    
    --[[
        NOTIFICATION SYSTEM
    ]]
    
    Library.Notifications = {}
    
    function Library:Notify(config)
        config = config or {}
        local notif = {
            Title = config.Title or "Notification",
            Content = config.Content or "",
            Duration = config.Duration or 3,
            Type = config.Type or "Info", -- "Info", "Success", "Warning", "Error"
            StartTime = tick(),
            Objects = {}
        }
        
        -- Set color based on type
        local color
        if notif.Type == "Success" then
            color = self.Theme.Success
        elseif notif.Type == "Warning" then
            color = self.Theme.Warning
        elseif notif.Type == "Error" then
            color = self.Theme.Error
        else
            color = self.Theme.Accent
        end
        
        -- Position from top-right
        local yPos = 50 + (#self.Notifications * 70)
        
        -- Background
        notif.Objects.Background = newDrawObject("Square", {
            Size = Vector2.new(250, 60),
            Position = Vector2.new(800, yPos),
            Color = self.Theme.Secondary,
            Transparency = 0.1,
            Filled = true,
            Visible = true,
            ZIndex = 100
        })
        
        -- Accent bar
        notif.Objects.Accent = newDrawObject("Square", {
            Size = Vector2.new(5, 60),
            Position = Vector2.new(800, yPos),
            Color = color,
            Filled = true,
            Visible = true,
            ZIndex = 101
        })
        
        -- Title
        notif.Objects.Title = newDrawObject("Text", {
            Text = notif.Title,
            Size = 14,
            Position = Vector2.new(815, yPos + 8),
            Color = self.Theme.Text,
            Center = false,
            Font = Library.Fonts.UI,
            Bold = true,
            Visible = true,
            ZIndex = 101
        })
        
        -- Content
        notif.Objects.Content = newDrawObject("Text", {
            Text = notif.Content,
            Size = 12,
            Position = Vector2.new(815, yPos + 28),
            Color = self.Theme.TextDim,
            Center = false,
            Font = Library.Fonts.UI,
            Visible = true,
            ZIndex = 101
        })
        
        -- Close button
        notif.Objects.Close = newDrawObject("Text", {
            Text = "×",
            Size = 16,
            Position = Vector2.new(1035, yPos + 8),
            Color = self.Theme.TextDim,
            Center = true,
            Font = Library.Fonts.UI,
            Visible = true,
            ZIndex = 101
        })
        
        table.insert(self.Notifications, notif)
        
        -- Auto-remove after duration
        task.delay(notif.Duration, function()
            notif.Objects.Background.Visible = false
            notif.Objects.Accent.Visible = false
            notif.Objects.Title.Visible = false
            notif.Objects.Content.Visible = false
            notif.Objects.Close.Visible = false
            for i, n in ipairs(self.Notifications) do
                if n == notif then
                    table.remove(self.Notifications, i)
                    break
                end
            end
        end)
        
        return notif
    end
    
    --[[
        INPUT HANDLING
    ]]
    
    local function isMouseOver(obj, mousePos)
        if not obj.Visible then return false end
        
        local objType = obj.Type or "Square"
        
        if objType == "Square" or objType == "Text" then
            local pos = obj.Position
            local size = obj.Size or Vector2.new(obj.TextBounds.X, obj.TextBounds.Y)
            
            if objType == "Text" then
                size = Vector2.new(obj.TextBounds.X, obj.TextBounds.Y)
                -- Adjust for text centering
                if obj.Center then
                    pos = pos - Vector2.new(size.X/2, size.Y/2)
                end
            end
            
            return mousePos.X >= pos.X and mousePos.X <= pos.X + size.X and
                   mousePos.Y >= pos.Y and mousePos.Y <= pos.Y + size.Y
        elseif objType == "Circle" then
            local dist = (mousePos - obj.Position).Magnitude
            return dist <= obj.Radius
        end
        
        return false
    end
    
    -- Main input loop
    RunService.Heartbeat:Connect(function()
        local mousePos = Vector2.new(Mouse.X, Mouse.Y)
        
        -- Window dragging
        if window.Dragging.Active then
            local newPos = mousePos - window.Dragging.Offset
            window:SetPosition(newPos)
        end
        
        -- Check for UI interactions
        for _, tab in ipairs(window.Tabs) do
            -- Tab buttons
            if tab.Objects.Button and tab.Objects.Button.Visible then
                if isMouseOver(tab.Objects.Button, mousePos) then
                    tab.Objects.Button.Transparency = 0.2
                    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                        window.ActiveTab = tab
                        for _, t in ipairs(window.Tabs) do
                            t.Objects.Button.Color = window.Config.Theme.Secondary
                        end
                        tab.Objects.Button.Color = window.Config.Theme.Accent
                    end
                else
                    tab.Objects.Button.Transparency = 0.5
                end
            end
            
            -- Elements in active tab
            if window.ActiveTab == tab then
                for _, element in ipairs(tab.Elements) do
                    if element.Type == "Button" then
                        if isMouseOver(element.Objects.Background, mousePos) then
                            element.Objects.Background.Color = window.Config.Theme.Accent
                            element.Objects.Background.Transparency = 0.1
                            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and not element.Pressed then
                                element.Pressed = true
                                element.Callback()
                            elseif not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                                element.Pressed = false
                            end
                        else
                            element.Objects.Background.Color = window.Config.Theme.Secondary
                            element.Objects.Background.Transparency = 0.2
                        end
                        
                    elseif element.Type == "Toggle" then
                        if isMouseOver(element.Objects.Background, mousePos) then
                            element.Objects.Background.Color = window.Config.Theme.Accent
                            element.Objects.Background.Transparency = 0.1
                            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and not element.Hovered then
                                element.Hovered = true
                                element.Value = not element.Value
                                element.Objects.Box.Color = element.Value and window.Config.Theme.Success or window.Config.Theme.Error
                                element.Objects.Check.Visible = element.Value
                                element.Callback(element.Value)
                            elseif not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                                element.Hovered = false
                            end
                        else
                            element.Objects.Background.Color = window.Config.Theme.Secondary
                            element.Objects.Background.Transparency = 0.2
                        end
                        
                    elseif element.Type == "Slider" then
                        if isMouseOver(element.Objects.SliderBg, mousePos) or element.Dragging then
                            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                                element.Dragging = true
                                local relativeX = mousePos.X - (window.Config.Position.X + 20 + element.Position.X + 10)
                                local percent = math.clamp(relativeX / 180, 0, 1)
                                local newValue = element.Min + (element.Max - element.Min) * percent
                                newValue = math.floor(newValue * 100) / 100
                                
                                element.Value = newValue
                                element.Objects.ValueText.Text = tostring(newValue)
                                element.Objects.SliderFill.Size = Vector2.new(180 * percent, 5)
                                element.Objects.Handle.Position = window.Config.Position + Vector2.new(20 + (180 * percent), 70) + element.Position + Vector2.new(0, 24.5)
                                element.Callback(newValue)
                            else
                                element.Dragging = false
                            end
                        end
                        
                    elseif element.Type == "Dropdown" then
                        -- Main dropdown click
                        if isMouseOver(element.Objects.Background, mousePos) then
                            element.Objects.Background.Color = window.Config.Theme.Accent
                            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and not element.Hovered then
                                element.Hovered = true
                                element.Expanded = not element.Expanded
                                element.Objects.DropdownBg.Visible = element.Expanded
                                
                                -- Create option objects if expanded
                                if element.Expanded then
                                    for i, option in ipairs(element.Options) do
                                        local optY = window.Config.Position.Y + 100 + element.Position.Y + ((i-1) * 25)
                                        
                                        -- Option background
                                        local optBg = newDrawObject("Square", {
                                            Size = Vector2.new(200, 25),
                                            Position = Vector2.new(window.Config.Position.X + 10, optY),
                                            Color = window.Config.Theme.Background,
                                            Filled = true,
                                            Visible = true,
                                            ZIndex = 9,
                                            Transparency = 0.95
                                        })
                                        
                                        -- Option text
                                        local optText = newDrawObject("Text", {
                                            Text = option,
                                            Size = 12,
                                            Position = Vector2.new(window.Config.Position.X + 110, optY + 12.5),
                                            Color = window.Config.Theme.Text,
                                            Center = true,
                                            Font = Library.Fonts.UI,
                                            Visible = true,
                                            ZIndex = 10
                                        })
                                        
                                        element.Objects["Option_"..i] = {Bg = optBg, Text = optText}
                                    end
                                else
                                    -- Remove option objects
                                    for i in ipairs(element.Options) do
                                        if element.Objects["Option_"..i] then
                                            element.Objects["Option_"..i].Bg.Visible = false
                                            element.Objects["Option_"..i].Text.Visible = false
                                        end
                                    end
                                end
                            elseif not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                                element.Hovered = false
                            end
                        else
                            element.Objects.Background.Color = window.Config.Theme.Secondary
                        end
                        
                        -- Check option clicks
                        if element.Expanded then
                            for i, option in ipairs(element.Options) do
                                if element.Objects["Option_"..i] then
                                    local optBg = element.Objects["Option_"..i].Bg
                                    if isMouseOver(optBg, mousePos) then
                                        optBg.Color = window.Config.Theme.Accent
                                        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and not element.HoveredIndex then
                                            element.HoveredIndex = i
                                            element.Selected = option
                                            element.Objects.SelectedText.Text = option
                                            element.Callback(option)
                                            
                                            -- Close dropdown
                                            element.Expanded = false
                                            element.Objects.DropdownBg.Visible = false
                                            for j in ipairs(element.Options) do
                                                if element.Objects["Option_"..j] then
                                                    element.Objects["Option_"..j].Bg.Visible = false
                                                    element.Objects["Option_"..j].Text.Visible = false
                                                end
                                            end
                                        elseif not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                                            element.HoveredIndex = nil
                                        end
                                    else
                                        optBg.Color = window.Config.Theme.Background
                                    end
                                end
                            end
                        end
                        
                    elseif element.Type == "TextBox" then
                        if isMouseOver(element.Objects.InputBg, mousePos) then
                            element.Objects.InputBg.Color = window.Config.Theme.Accent
                            element.Objects.InputBg.Transparency = 0.2
                            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and not element.Focused then
                                element.Focused = true
                            end
                        else
                            element.Objects.InputBg.Color = window.Config.Theme.Background
                            element.Objects.InputBg.Transparency = 0
                        end
                        
                        -- Handle text input (simplified - would need key event handling)
                        -- In a real implementation, you'd connect to UserInputService.InputBegan
                    end
                end
            end
        end
        
        -- Close button
        if window.Objects.CloseBtn and isMouseOver(window.Objects.CloseBtn, mousePos) then
            window.Objects.CloseBtn.Transparency = 0
            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                window.Visible = false
                for _, obj in pairs(window.Objects) do
                    if obj and obj.Visible ~= nil then
                        obj.Visible = false
                    end
                end
            end
        elseif window.Objects.CloseBtn then
            window.Objects.CloseBtn.Transparency = 0.3
        end
        
        -- Minimize button
        if window.Objects.MinimizeBtn and isMouseOver(window.Objects.MinimizeBtn, mousePos) then
            window.Objects.MinimizeBtn.Transparency = 0
            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                window.Minimized = not window.Minimized
                if window.Minimized then
                    window.Objects.ContentArea.Visible = false
                    window.Objects.TabBar.Visible = false
                    window.Objects.Border.Size = Vector2.new(window.Config.Size.X, 25)
                    window.Objects.Background.Size = Vector2.new(window.Config.Size.X, 25)
                else
                    window.Objects.ContentArea.Visible = true
                    window.Objects.TabBar.Visible = true
                    window.Objects.Border.Size = window.Config.Size
                    window.Objects.Background.Size = window.Config.Size
                end
            end
        elseif window.Objects.MinimizeBtn then
            window.Objects.MinimizeBtn.Transparency = 0.3
        end
        
        -- Dragging
        if window.Config.Draggable and isMouseOver(window.Objects.TitleBar, mousePos) then
            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and not window.Dragging.Active then
                window.Dragging.Active = true
                window.Dragging.Offset = mousePos - window.Config.Position
            end
        end
        
        if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            window.Dragging.Active = false
        end
    end)
    
    --[[
        UTILITY FUNCTIONS
    ]]
    
    function window:SetPosition(newPos)
        self.Config.Position = newPos
        local offset = newPos - self.Config.Position
        
        -- Update all object positions
        for _, obj in pairs(self.Objects) do
            if obj.Position then
                obj.Position = obj.Position + offset
            end
        end
    end
    
    function window:SetVisible(visible)
        self.Visible = visible
        for _, obj in pairs(self.Objects) do
            if obj and obj.Visible ~= nil then
                obj.Visible = visible
            end
        end
    end
    
    function window:Destroy()
        for _, obj in pairs(self.Objects) do
            if obj and obj.Remove then
                obj:Remove()
            end
        end
    end
    
    return window
end

--[[
    EXAMPLE USAGE
]]

-- Create main window
local MainWindow = Library:CreateWindow({
    Title = "Potassium Executor",
    Size = Vector2.new(600, 400),
    Position = Vector2.new(200, 150),
    Draggable = true,
    Resizable = false
})

-- Create tabs
local CombatTab = MainWindow:AddTab("Combat")
local VisualsTab = MainWindow:AddTab("Visuals")
local MovementTab = MainWindow:AddTab("Movement")
local SettingsTab = MainWindow:AddTab("Settings")

-- Add elements to Combat tab
MainWindow:AddButton(CombatTab, {
    Text = "Aimbot",
    Position = Vector2.new(10, 10),
    Callback = function()
        Library:Notify({
            Title = "Aimbot",
            Content = "Aimbot toggled!",
            Type = "Success"
        })
    end
})

MainWindow:AddToggle(CombatTab, {
    Text = "ESP",
    Default = false,
    Position = Vector2.new(10, 50),
    Callback = function(value)
        Library:Notify({
            Title = "ESP",
            Content = value and "ESP Enabled" or "ESP Disabled",
            Type = value and "Success" or "Warning"
        })
    end
})

MainWindow:AddSlider(CombatTab, {
    Text = "Aimbot Smoothness",
    Min = 0,
    Max = 100,
    Default = 50,
    Position = Vector2.new(10, 90),
    Callback = function(value)
        print("Smoothness set to:", value)
    end
})

-- Add elements to Visuals tab
MainWindow:AddLabel(VisualsTab, {
    Text = "Visual Settings",
    Color = Color3.fromRGB(0, 120, 215),
    Size = 16,
    Position = Vector2.new(10, 10)
})

MainWindow:AddDropdown(VisualsTab, {
    Text = "Box ESP Style",
    Options = {"2D Box", "3D Box", "Corner Box", "None"},
    Default = "2D Box",
    Position = Vector2.new(10, 40),
    Callback = function(selected)
        print("ESP Style:", selected)
    end
})

MainWindow:AddTextBox(VisualsTab, {
    Text = "Custom Name",
    Placeholder = "Enter name...",
    Position = Vector2.new(10, 100),
    Callback = function(text)
        print("Name set to:", text)
    end
})

-- Add elements to Movement tab
MainWindow:AddToggle(MovementTab, {
    Text = "Speed Hack",
    Default = false,
    Position = Vector2.new(10, 10),
    Callback = function(value)
        print("Speed Hack:", value)
    end
})

MainWindow:AddSlider(MovementTab, {
    Text = "Speed Multiplier",
    Min = 1,
    Max = 10,
    Default = 2,
    Position = Vector2.new(10, 50),
    Callback = function(value)
        print("Speed multiplier:", value)
    end
})

-- Add elements to Settings tab
MainWindow:AddButton(SettingsTab, {
    Text = "Save Settings",
    Position = Vector2.new(10, 10),
    Callback = function()
        Library:Notify({
            Title = "Settings",
            Content = "Settings saved successfully!",
            Type = "Success"
        })
    end
})

MainWindow:AddButton(SettingsTab, {
    Text = "Load Settings",
    Position = Vector2.new(10, 50),
    Callback = function()
        Library:Notify({
            Title = "Settings",
            Content = "Settings loaded!",
            Type = "Info"
        })
    end
})

-- Example notification
task.wait(2)
Library:Notify({
    Title = "Welcome!",
    Content = "GUI Library loaded successfully",
    Type = "Success",
    Duration = 5
})

-- Cleanup on script unload
script:Destroy()