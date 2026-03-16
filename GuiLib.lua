-- Potassium UI Library
-- Professional Animated GUI

local UILib = {}
UILib.__index = UILib

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

UILib.Flags = {}

-- Default Theme
UILib.Theme = {
    Background = Color3.fromRGB(25,25,25),
    Tab = Color3.fromRGB(35,35,35),
    Accent = Color3.fromRGB(0,170,255),
    Text = Color3.fromRGB(255,255,255)
}

local function Tween(obj,time,props)
    TweenService:Create(obj,TweenInfo.new(time,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),props):Play()
end

function UILib:CreateWindow(data)

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PotassiumUI"
    ScreenGui.Parent = PlayerGui

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0,600,0,400)
    Main.Position = UDim2.new(0.5,-300,0.5,-200)
    Main.BackgroundColor3 = UILib.Theme.Background
    Main.Parent = ScreenGui

    Main.Active = true

    -- Dragging
    local dragging = false
    local dragStart
    local startPos

    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)

    Main.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = startPos + UDim2.new(0,delta.X,0,delta.Y)
        end
    end)

    -- Title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1,0,0,40)
    Title.BackgroundTransparency = 1
    Title.Text = data.Name or "Potassium UI"
    Title.TextColor3 = UILib.Theme.Text
    Title.TextScaled = true
    Title.Parent = Main

    -- Tabs container
    local TabButtons = Instance.new("Frame")
    TabButtons.Size = UDim2.new(0,140,1,-40)
    TabButtons.Position = UDim2.new(0,0,0,40)
    TabButtons.BackgroundColor3 = UILib.Theme.Tab
    TabButtons.Parent = Main

    local Pages = Instance.new("Frame")
    Pages.Size = UDim2.new(1,-140,1,-40)
    Pages.Position = UDim2.new(0,140,0,40)
    Pages.BackgroundTransparency = 1
    Pages.Parent = Main

    local Window = {}

    function Window:CreateTab(tabData)

        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1,0,0,40)
        Button.BackgroundColor3 = UILib.Theme.Tab
        Button.Text = tabData.Name
        Button.TextColor3 = UILib.Theme.Text
        Button.Parent = TabButtons

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1,0,1,0)
        Page.Visible = false
        Page.Parent = Pages

        Button.MouseButton1Click:Connect(function()

            for _,v in pairs(Pages:GetChildren()) do
                if v:IsA("ScrollingFrame") then
                    v.Visible = false
                end
            end

            Page.Visible = true
            Page.Position = UDim2.new(1,0,0,0)

            Tween(Page,0.3,{Position = UDim2.new(0,0,0,0)})

        end)

        local Tab = {}

        function Tab:AddButton(data)

            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1,-10,0,35)
            Button.Position = UDim2.new(0,5,0,0)
            Button.BackgroundColor3 = UILib.Theme.Tab
            Button.Text = data.Name
            Button.TextColor3 = UILib.Theme.Text
            Button.Parent = Page

            Button.MouseButton1Click:Connect(function()
                Tween(Button,0.1,{BackgroundColor3 = UILib.Theme.Accent})
                task.wait(.1)
                Tween(Button,0.1,{BackgroundColor3 = UILib.Theme.Tab})

                if data.Callback then
                    data.Callback()
                end
            end)

        end

        function Tab:AddToggle(data)

            local Toggle = Instance.new("TextButton")
            Toggle.Size = UDim2.new(1,-10,0,35)
            Toggle.BackgroundColor3 = UILib.Theme.Tab
            Toggle.Text = data.Name
            Toggle.TextColor3 = UILib.Theme.Text
            Toggle.Parent = Page

            local Value = data.Default or false

            Toggle.MouseButton1Click:Connect(function()

                Value = not Value

                if Value then
                    Tween(Toggle,0.2,{BackgroundColor3 = UILib.Theme.Accent})
                else
                    Tween(Toggle,0.2,{BackgroundColor3 = UILib.Theme.Tab})
                end

                if data.Flag then
                    UILib.Flags[data.Flag] = Value
                end

                if data.Callback then
                    data.Callback(Value)
                end

            end)

        end

        function Tab:AddSlider(data)

            local Slider = Instance.new("Frame")
            Slider.Size = UDim2.new(1,-10,0,40)
            Slider.BackgroundColor3 = UILib.Theme.Tab
            Slider.Parent = Page

            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new(0,0,1,0)
            Fill.BackgroundColor3 = UILib.Theme.Accent
            Fill.Parent = Slider

            local dragging = false

            Slider.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                end
            end)

            Slider.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)

            UserInputService.InputChanged:Connect(function(i)

                if dragging then

                    local size = math.clamp(
                        (i.Position.X - Slider.AbsolutePosition.X) / Slider.AbsoluteSize.X,
                        0,1
                    )

                    Fill.Size = UDim2.new(size,0,1,0)

                    local value = math.floor(
                        data.Min + (data.Max-data.Min)*size
                    )

                    if data.Callback then
                        data.Callback(value)
                    end

                end

            end)

        end

        return Tab
    end

    return Window
end

function UILib:Notify(data)

    local Notify = Instance.new("TextLabel")
    Notify.Size = UDim2.new(0,250,0,60)
    Notify.Position = UDim2.new(1,-260,1,-80)
    Notify.BackgroundColor3 = UILib.Theme.Tab
    Notify.Text = data.Title.." - "..data.Text
    Notify.TextColor3 = UILib.Theme.Text
    Notify.Parent = PlayerGui

    Tween(Notify,0.3,{Position = UDim2.new(1,-260,1,-140)})

    task.wait(data.Time or 3)

    Tween(Notify,0.3,{Position = UDim2.new(1,0,1,-140)})
    task.wait(.3)

    Notify:Destroy()

end

return UILib