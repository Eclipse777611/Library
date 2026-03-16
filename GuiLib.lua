```lua
--// Potassium Style GUI Library
--// Rounded + Animated

local UILib = {}
UILib.__index = UILib

-- Services
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Theme
UILib.Theme = {
    Background = Color3.fromRGB(20,20,20),
    Section = Color3.fromRGB(35,35,35),
    Item = Color3.fromRGB(40,40,40),
    Accent = Color3.fromRGB(120,190,255),
    Text = Color3.fromRGB(255,255,255),
    Stroke = Color3.fromRGB(60,60,60)
}

-- Tween helper
local function Tween(obj,time,props)
    TweenService:Create(obj,TweenInfo.new(time,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),props):Play()
end

-- Round helper
local function Round(obj,radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,radius or 8)
    corner.Parent = obj
end

-- Stroke helper
local function Stroke(obj)
    local s = Instance.new("UIStroke")
    s.Color = UILib.Theme.Stroke
    s.Thickness = 1
    s.Parent = obj
end

function UILib:CreateWindow(data)

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PotassiumUI"
    ScreenGui.Parent = PlayerGui

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0,640,0,420)
    Main.Position = UDim2.new(0.5,-320,0.5,-210)
    Main.BackgroundColor3 = UILib.Theme.Background
    Main.Parent = ScreenGui
    Main.Active = true

    Round(Main,12)
    Stroke(Main)

    -- Dragging
    local dragging=false
    local dragStart
    local startPos

    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging=true
            dragStart=input.Position
            startPos=Main.Position
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta=input.Position-dragStart
            Main.Position=startPos+UDim2.new(0,delta.X,0,delta.Y)
        end
    end)

    Main.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging=false
        end
    end)

    -- Title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1,0,0,40)
    Title.BackgroundTransparency = 1
    Title.Text = data.Name or "Potassium UI"
    Title.TextColor3 = UILib.Theme.Text
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.Parent = Main

    -- Tabs
    local Tabs = Instance.new("Frame")
    Tabs.Size = UDim2.new(0,150,1,-40)
    Tabs.Position = UDim2.new(0,0,0,40)
    Tabs.BackgroundColor3 = UILib.Theme.Section
    Tabs.Parent = Main

    Round(Tabs,10)

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Parent = Tabs

    -- Pages
    local Pages = Instance.new("Frame")
    Pages.Size = UDim2.new(1,-150,1,-40)
    Pages.Position = UDim2.new(0,150,0,40)
    Pages.BackgroundTransparency = 1
    Pages.Parent = Main

    local Window = {}

    function Window:CreateTab(tabData)

        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1,0,0,40)
        TabButton.BackgroundColor3 = UILib.Theme.Item
        TabButton.TextColor3 = UILib.Theme.Text
        TabButton.Text = tabData.Name
        TabButton.Font = Enum.Font.Gotham
        TabButton.TextSize = 14
        TabButton.Parent = Tabs

        Round(TabButton,6)

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1,0,1,0)
        Page.Visible=false
        Page.BackgroundTransparency=1
        Page.Parent=Pages

        local Layout = Instance.new("UIListLayout")
        Layout.Padding = UDim.new(0,6)
        Layout.Parent = Page

        TabButton.MouseButton1Click:Connect(function()

            for _,v in pairs(Pages:GetChildren()) do
                if v:IsA("ScrollingFrame") then
                    v.Visible=false
                end
            end

            Page.Visible=true
            Page.Position=UDim2.new(1,0,0,0)

            Tween(Page,.25,{Position=UDim2.new(0,0,0,0)})

        end)

        local Tab = {}

        function Tab:AddSection(name)

            local Section = Instance.new("Frame")
            Section.Size = UDim2.new(1,-10,0,40)
            Section.BackgroundColor3 = UILib.Theme.Section
            Section.Parent = Page

            Round(Section,8)
            Stroke(Section)

            local Label = Instance.new("TextLabel")
            Label.BackgroundTransparency = 1
            Label.Size = UDim2.new(1,0,1,0)
            Label.Text = name
            Label.TextColor3 = UILib.Theme.Text
            Label.Font = Enum.Font.GothamBold
            Label.TextSize = 14
            Label.Parent = Section

        end

        function Tab:AddButton(data)

            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1,-10,0,36)
            Button.BackgroundColor3 = UILib.Theme.Item
            Button.TextColor3 = UILib.Theme.Text
            Button.Text = data.Name
            Button.Font = Enum.Font.Gotham
            Button.TextSize = 14
            Button.Parent = Page

            Round(Button,6)

            Button.MouseEnter:Connect(function()
                Tween(Button,.15,{BackgroundColor3=Color3.fromRGB(55,55,55)})
            end)

            Button.MouseLeave:Connect(function()
                Tween(Button,.15,{BackgroundColor3=UILib.Theme.Item})
            end)

            Button.MouseButton1Click:Connect(function()
                Tween(Button,.1,{BackgroundColor3=UILib.Theme.Accent})
                task.wait(.1)
                Tween(Button,.1,{BackgroundColor3=UILib.Theme.Item})

                if data.Callback then
                    data.Callback()
                end
            end)

        end

        function Tab:AddToggle(data)

            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1,-10,0,36)
            Frame.BackgroundColor3 = UILib.Theme.Item
            Frame.Parent = Page

            Round(Frame,6)

            local Text = Instance.new("TextLabel")
            Text.BackgroundTransparency=1
            Text.Position=UDim2.new(0,10,0,0)
            Text.Size=UDim2.new(1,-40,1,0)
            Text.Text=data.Name
            Text.TextColor3=UILib.Theme.Text
            Text.Font=Enum.Font.Gotham
            Text.TextSize=14
            Text.TextXAlignment=Enum.TextXAlignment.Left
            Text.Parent=Frame

            local Box = Instance.new("Frame")
            Box.Size=UDim2.new(0,22,0,22)
            Box.Position=UDim2.new(1,-30,.5,-11)
            Box.BackgroundColor3=Color3.fromRGB(70,70,70)
            Box.Parent=Frame

            Round(Box,4)

            local Value=data.Default or false

            Frame.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 then

                    Value=not Value

                    if Value then
                        Tween(Box,.2,{BackgroundColor3=UILib.Theme.Accent})
                    else
                        Tween(Box,.2,{BackgroundColor3=Color3.fromRGB(70,70,70)})
                    end

                    if data.Callback then
                        data.Callback(Value)
                    end

                end
            end)

        end

        function Tab:AddTextbox(data)

            local Box = Instance.new("TextBox")
            Box.Size = UDim2.new(1,-10,0,36)
            Box.BackgroundColor3 = UILib.Theme.Item
            Box.TextColor3 = UILib.Theme.Text
            Box.PlaceholderText = data.Name
            Box.Font = Enum.Font.Gotham
            Box.TextSize = 14
            Box.Parent = Page

            Round(Box,6)

            Box.FocusLost:Connect(function()
                if data.Callback then
                    data.Callback(Box.Text)
                end
            end)

        end

        return Tab
    end

    return Window
end

function UILib:Notify(data)

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0,260,0,60)
    Frame.Position = UDim2.new(1,-270,1,-80)
    Frame.BackgroundColor3 = UILib.Theme.Section
    Frame.Parent = PlayerGui

    Round(Frame,8)
    Stroke(Frame)

    local Text = Instance.new("TextLabel")
    Text.BackgroundTransparency=1
    Text.Size=UDim2.new(1,-10,1,-10)
    Text.Position=UDim2.new(0,5,0,5)
    Text.Text=data.Title.." - "..data.Text
    Text.TextColor3=UILib.Theme.Text
    Text.Font=Enum.Font.Gotham
    Text.TextWrapped=true
    Text.TextSize=14
    Text.Parent=Frame

    Tween(Frame,.25,{Position=UDim2.new(1,-270,1,-140)})

    task.wait(data.Time or 3)

    Tween(Frame,.25,{Position=UDim2.new(1,0,1,-140)})
    task.wait(.25)

    Frame:Destroy()

end

return UILib