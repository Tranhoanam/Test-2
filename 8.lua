local NemoZLibrary = {}

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer

local TargetParent = nil
pcall(function() TargetParent = gethui() end)
if not TargetParent then
    pcall(function() TargetParent = CoreGui end)
end
if not TargetParent then TargetParent = Player:WaitForChild("PlayerGui") end

local PrimaryColor = Color3.fromRGB(46, 80, 144)
local CharcoalColor = Color3.fromRGB(54, 69, 79)
local CurrentThemeColor = PrimaryColor

function NemoZLibrary:CreateWindow(config)
    local Window = {
        TabButtons = {},
        TabPages = {},
        CurrentAuraColor = PrimaryColor
    }
    
    local Name = config.Name or "NemoZ Menu"

    if TargetParent:FindFirstChild("NemoZ_MainOnlyMenu") then TargetParent["NemoZ_MainOnlyMenu"]:Destroy() end
    if TargetParent:FindFirstChild("NemoZ_DeltaCustomMiniMenu") then TargetParent["NemoZ_DeltaCustomMiniMenu"]:Destroy() end
    if TargetParent:FindFirstChild("NemoZ_IntroScreen") then TargetParent["NemoZ_IntroScreen"]:Destroy() end

    local MainWindow

    local IntroGui = Instance.new("ScreenGui", TargetParent)
    IntroGui.Name = "NemoZ_IntroScreen"
    IntroGui.IgnoreGuiInset = true
    IntroGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local IntroBackground = Instance.new("Frame", IntroGui)
    IntroBackground.Size = UDim2.new(1, 0, 1, 0)
    IntroBackground.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    IntroBackground.BorderSizePixel = 0
    IntroBackground.BackgroundTransparency = 0

    for i = 1, 40 do
        local star = Instance.new("Frame", IntroBackground)
        star.Size = UDim2.new(0, math.random(2, 4), 0, math.random(2, 4))
        star.Position = UDim2.new(math.random(), 0, math.random(), 0)
        star.BackgroundColor3 = Color3.new(1, 1, 1)
        star.BackgroundTransparency = math.random(2, 8) / 10
        Instance.new("UICorner", star).CornerRadius = UDim.new(1, 0)
    end

    local IntroSpinnerHolder = Instance.new("Frame", IntroBackground)
    IntroSpinnerHolder.Size = UDim2.new(0, 120, 0, 120)
    IntroSpinnerHolder.Position = UDim2.new(0.5, -60, 0.5, -90)
    IntroSpinnerHolder.BackgroundTransparency = 1

    local spinnerRadius = 40
    local totalSquares = 12
    for i = 1, totalSquares do
        local angle = (i / totalSquares) * (math.pi * 2)
        local sq = Instance.new("Frame", IntroSpinnerHolder)
        sq.Size = UDim2.new(0, 16, 0, 16)
        sq.Position = UDim2.new(0.5, math.cos(angle) * spinnerRadius - 8, 0.5, math.sin(angle) * spinnerRadius - 8)
        sq.BackgroundColor3 = PrimaryColor
        sq.BorderSizePixel = 0
        Instance.new("UICorner", sq).CornerRadius = UDim.new(0, 5)
    end

    task.spawn(function()
        local rot = 0
        while IntroSpinnerHolder and IntroSpinnerHolder.Parent do
            rot = (rot + 2) % 360
            IntroSpinnerHolder.Rotation = rot
            task.wait(0.03)
        end
    end)

    local IntroTitle = Instance.new("TextLabel", IntroBackground)
    IntroTitle.Size = UDim2.new(1, 0, 0, 60)
    IntroTitle.Position = UDim2.new(0, 0, 0.5, 30)
    IntroTitle.BackgroundTransparency = 1
    IntroTitle.Text = ""
    IntroTitle.TextColor3 = Color3.fromRGB(230, 235, 245)
    IntroTitle.Font = Enum.Font.GothamBold
    IntroTitle.TextSize = 32
    IntroTitle.TextXAlignment = Enum.TextXAlignment.Center

    task.spawn(function()
        task.wait(0.5)
        local fullText = Name
        for i = 1, #fullText do
            IntroTitle.Text = string.sub(fullText, 1, i)
            task.wait(0.08)
        end
    end)

    task.delay(5, function()
        if IntroBackground and IntroGui then
            local fadeOutBg = TweenService:Create(IntroBackground, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1})
            local fadeOutText = TweenService:Create(IntroTitle, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1})
            fadeOutBg:Play()
            fadeOutText:Play()
            
            fadeOutBg.Completed:Connect(function()
                IntroGui:Destroy()
                if MainWindow then
                    MainWindow.Visible = true
                end
            end)
        end
    end)

    local ScreenGui = Instance.new("ScreenGui", TargetParent)
    ScreenGui.Name = "NemoZ_MainOnlyMenu"
    ScreenGui.IgnoreGuiInset = true

    local Aura4 = Instance.new("Frame", ScreenGui)
    Aura4.Size = UDim2.new(0, 540, 0, 340)
    Aura4.Position = UDim2.new(0.5, -270, 0.5, -170)
    Aura4.BackgroundColor3 = PrimaryColor
    Aura4.BackgroundTransparency = 0.92
    Instance.new("UICorner", Aura4).CornerRadius = UDim.new(0, 24)

    local Aura3 = Instance.new("Frame", ScreenGui)
    Aura3.Size = UDim2.new(0, 526, 0, 326)
    Aura3.Position = UDim2.new(0.5, -263, 0.5, -163)
    Aura3.BackgroundColor3 = PrimaryColor
    Aura3.BackgroundTransparency = 0.85
    Instance.new("UICorner", Aura3).CornerRadius = UDim.new(0, 20)

    local Aura2 = Instance.new("Frame", ScreenGui)
    Aura2.Size = UDim2.new(0, 514, 0, 314)
    Aura2.Position = UDim2.new(0.5, -257, 0.5, -157)
    Aura2.BackgroundColor3 = PrimaryColor
    Aura2.BackgroundTransparency = 0.7
    Instance.new("UICorner", Aura2).CornerRadius = UDim.new(0, 18)

    MainWindow = Instance.new("Frame", ScreenGui)
    MainWindow.Size = UDim2.new(0, 500, 0, 300)
    MainWindow.Position = UDim2.new(0.5, -250, 0.5, -150)
    MainWindow.BackgroundColor3 = CharcoalColor
    MainWindow.BorderSizePixel = 0
    MainWindow.Active = true
    MainWindow.Visible = false 
    
    local mainDragging, mainDragStart, mainStartPos

    Instance.new("UICorner", MainWindow).CornerRadius = UDim.new(0, 15)
    
    local MainStroke = Instance.new("UIStroke", MainWindow)
    MainStroke.Color = PrimaryColor
    MainStroke.Thickness = 1.5

    local Header = Instance.new("Frame", MainWindow)
    Header.Size = UDim2.new(1, 0, 0, 80)
    Header.BackgroundColor3 = Color3.fromRGB(40, 48, 58)
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 15)

    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            mainDragging = true
            mainDragStart = input.Position
            mainStartPos = MainWindow.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if mainDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - mainDragStart
            local newPos = UDim2.new(mainStartPos.X.Scale, mainStartPos.X.Offset + delta.X, mainStartPos.Y.Scale, mainStartPos.Y.Offset + delta.Y)
            MainWindow.Position = newPos
            Aura2.Position = UDim2.new(newPos.X.Scale, newPos.X.Offset - 7, newPos.Y.Scale, newPos.Y.Offset - 7)
            Aura3.Position = UDim2.new(newPos.X.Scale, newPos.X.Offset - 13, newPos.Y.Scale, newPos.Y.Offset - 13)
            Aura4.Position = UDim2.new(newPos.X.Scale, newPos.X.Offset - 20, newPos.Y.Scale, newPos.Y.Offset - 20)
        end
    end)
    Header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            mainDragging = false
        end
    end)

    local Title = Instance.new("TextLabel", Header)
    Title.Text = Name
    Title.Size = UDim2.new(0.35, 0, 0.5, 0)
    Title.Position = UDim2.new(0.04, 0, 0, 0)
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.GothamBold
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local HomeButton = Instance.new("TextButton", Header)
    HomeButton.Size = UDim2.new(0, 50, 0, 28)
    HomeButton.Position = UDim2.new(0.58, 0, 0.12, 0)
    HomeButton.Text = "Home"
    HomeButton.TextColor3 = Color3.new(1, 1, 1)
    HomeButton.Font = Enum.Font.GothamMedium
    HomeButton.TextSize = 11
    HomeButton.BackgroundColor3 = PrimaryColor
    Instance.new("UICorner", HomeButton).CornerRadius = UDim.new(0, 8)

    local StatsButton = Instance.new("TextButton", Header)
    StatsButton.Size = UDim2.new(0, 50, 0, 28)
    StatsButton.Position = UDim2.new(0.70, 0, 0.12, 0)
    StatsButton.Text = "Stats"
    StatsButton.TextColor3 = Color3.new(1, 1, 1)
    StatsButton.Font = Enum.Font.GothamMedium
    StatsButton.TextSize = 11
    StatsButton.BackgroundColor3 = Color3.fromRGB(65, 75, 90)
    Instance.new("UICorner", StatsButton).CornerRadius = UDim.new(0, 8)

    local Close = Instance.new("TextButton", Header)
    Close.Size = UDim2.new(0, 28, 0, 28)
    Close.Position = UDim2.new(0.91, 0, 0.12, 0)
    Close.Text = "×"
    Close.TextColor3 = Color3.new(1, 1, 1)
    Close.Font = Enum.Font.GothamBold
    Close.TextSize = 14
    Close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 8)

    local StatsFrame = Instance.new("Frame", Header)
    StatsFrame.Size = UDim2.new(1, 0, 0.5, 0)
    StatsFrame.Position = UDim2.new(0, 0, 0.5, 0)
    StatsFrame.BackgroundTransparency = 1

    local function createStatLabel(posX)
        local lbl = Instance.new("TextLabel", StatsFrame)
        lbl.Size = UDim2.new(0.33, 0, 1, 0)
        lbl.Position = UDim2.new(posX, 0, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Center
        return lbl
    end

    local PingLabel = createStatLabel(0)
    local FpsLabel = createStatLabel(0.33)
    local LossLabel = createStatLabel(0.66)

    local Sidebar = Instance.new("ScrollingFrame", MainWindow)
    Sidebar.Size = UDim2.new(0, 130, 1, -80)
    Sidebar.Position = UDim2.new(0, 0, 0, 80)
    Sidebar.BackgroundColor3 = Color3.fromRGB(45, 55, 68)
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 2
    Sidebar.Active = true
    Sidebar.ScrollingDirection = Enum.ScrollingDirection.Y
    Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)

    local SidebarLayout = Instance.new("UIListLayout", Sidebar)
    SidebarLayout.Padding = UDim.new(0, 5)
    SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local SidebarPadding = Instance.new("UIPadding", Sidebar)
    SidebarPadding.PaddingTop = UDim.new(0, 10)

    SidebarLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Sidebar.CanvasSize = UDim2.new(0, 0, 0, SidebarLayout.AbsoluteContentSize.Y + 20)
    end)

    local PageContainer = Instance.new("Frame", MainWindow)
    PageContainer.Size = UDim2.new(1, -130, 1, -80)
    PageContainer.Position = UDim2.new(0, 130, 0, 80)
    PageContainer.BackgroundTransparency = 1

    local HomeContainer = Instance.new("ScrollingFrame", PageContainer)
    HomeContainer.Size = UDim2.new(1, 0, 1, 0)
    HomeContainer.BackgroundTransparency = 1
    HomeContainer.ScrollBarThickness = 4
    HomeContainer.Visible = false
    HomeContainer.ScrollingDirection = Enum.ScrollingDirection.Y
    HomeContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    HomeContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local homeLayout = Instance.new("UIListLayout", HomeContainer)
    homeLayout.Padding = UDim.new(0, 15)
    homeLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    homeLayout.SortOrder = Enum.SortOrder.LayoutOrder
    local homePadding = Instance.new("UIPadding", HomeContainer)
    homePadding.PaddingTop = UDim.new(0, 20)

    homeLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        HomeContainer.CanvasSize = UDim2.new(0, 0, 0, homeLayout.AbsoluteContentSize.Y + 40)
    end)

    local MiniScreenGui = Instance.new("ScreenGui", TargetParent)
    MiniScreenGui.Name = "NemoZ_DeltaCustomMiniMenu"
    MiniScreenGui.IgnoreGuiInset = true

    local MiniMainFrame = Instance.new("Frame", MiniScreenGui)
    MiniMainFrame.Name = "MainFrame"
    MiniMainFrame.Size = UDim2.new(0, 135, 0, 40)
    MiniMainFrame.Position = UDim2.new(0.5, -67, 0, 0)
    MiniMainFrame.BackgroundColor3 = CharcoalColor
    MiniMainFrame.BorderSizePixel = 0
    MiniMainFrame.Active = true
    MiniMainFrame.ZIndex = 2
    MiniMainFrame.Visible = false

    local MiniUICorner = Instance.new("UICorner", MiniMainFrame)
    MiniUICorner.CornerRadius = UDim.new(0, 12)

    local MiniUIStroke = Instance.new("UIStroke", MiniMainFrame)
    MiniUIStroke.Thickness = 1
    MiniUIStroke.Color = PrimaryColor
    MiniUIStroke.Transparency = 0.5

    local MiniTopOverlay = Instance.new("Frame", MiniMainFrame)
    MiniTopOverlay.Name = "TopOverlay"
    MiniTopOverlay.Size = UDim2.new(1, 0, 0, 12)
    MiniTopOverlay.Position = UDim2.new(0, 0, 0, 0)
    MiniTopOverlay.BackgroundColor3 = CharcoalColor
    MiniTopOverlay.BorderSizePixel = 0
    MiniTopOverlay.Visible = true
    MiniTopOverlay.ZIndex = 1

    local MiniDragButton = Instance.new("ImageButton", MiniMainFrame)
    MiniDragButton.Name = "DragButton"
    MiniDragButton.Size = UDim2.new(0, 42, 0, 40)
    MiniDragButton.Position = UDim2.new(0, 0, 0, 0)
    MiniDragButton.BackgroundTransparency = 1
    MiniDragButton.Image = "rbxassetid://94225529221725"
    MiniDragButton.ZIndex = 3

    local MiniDivider = Instance.new("Frame", MiniMainFrame)
    MiniDivider.Name = "Divider"
    MiniDivider.Size = UDim2.new(0, 1, 0, 20)
    MiniDivider.Position = UDim2.new(0, 42, 0, 10)
    MiniDivider.BackgroundColor3 = Color3.new(1, 1, 1)
    MiniDivider.BackgroundTransparency = 0.8
    MiniDivider.BorderSizePixel = 0
    MiniDivider.ZIndex = 3

    local MiniOpenButton = Instance.new("TextButton", MiniMainFrame)
    MiniOpenButton.Name = "OpenButton"
    MiniOpenButton.Size = UDim2.new(0, 85, 0, 40)
    MiniOpenButton.Position = UDim2.new(0, 46, 0, 0)
    MiniOpenButton.BackgroundTransparency = 1
    MiniOpenButton.Text = "open"
    MiniOpenButton.TextColor3 = Color3.fromRGB(230, 235, 245)
    MiniOpenButton.TextSize = 15
    MiniOpenButton.Font = Enum.Font.GothamBold
    MiniOpenButton.ZIndex = 3

    local dragging, dragInput, dragStart, startPos

    local function updateMini(input)
        local delta = input.Position - dragStart
        local endY = startPos.Y.Offset + delta.Y
        if endY < 0 then endY = 0 end
        
        if endY <= 3 then
            MiniMainFrame.BackgroundColor3 = CharcoalColor
            MiniTopOverlay.BackgroundColor3 = CharcoalColor
            MiniUICorner.CornerRadius = UDim.new(0, 12)
            MiniTopOverlay.Visible = true
            MiniMainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, 0)
        else
            MiniMainFrame.BackgroundColor3 = CharcoalColor
            MiniUICorner.CornerRadius = UDim.new(0, 8)
            MiniTopOverlay.Visible = false
            TweenService:Create(MiniMainFrame, TweenInfo.new(0.08), {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, endY)}):Play()
        end
    end

    MiniDragButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MiniMainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput or (dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch)) then
            dragInput = input
            if dragging then updateMini(input) end
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    Close.MouseButton1Click:Connect(function()
        MainWindow.Visible = false
        Aura2.Visible = false
        Aura3.Visible = false
        Aura4.Visible = false
        MiniMainFrame.Visible = true
    end)

    MiniOpenButton.MouseButton1Click:Connect(function()
        MainWindow.Visible = true
        Aura2.Visible = true
        Aura3.Visible = true
        Aura4.Visible = true
        MiniMainFrame.Visible = false
    end)

    local isMini = false
    StatsButton.MouseButton1Click:Connect(function()
        isMini = not isMini
        MainWindow.Size = isMini and UDim2.new(0, 500, 0, 80) or UDim2.new(0, 500, 0, 300)
        Sidebar.Visible = not isMini
        PageContainer.Visible = not isMini
        HomeContainer.Visible = false
    end)

    HomeButton.MouseButton1Click:Connect(function()
        HomeContainer.Visible = not HomeContainer.Visible
        for _, page in ipairs(Window.TabPages) do
            page.Visible = false
        end
    end)

    local lastTick = tick()
    local frames = 0
    RunService.RenderStepped:Connect(function()
        frames += 1
        if tick() - lastTick >= 0.5 then
            local fps = math.floor(frames / (tick() - lastTick))
            local success, pingVal = pcall(function() return Player:GetNetworkPing() end)
            local ping = success and math.floor(pingVal * 1000) or 0
            
            FpsLabel.Text = "FPS: " .. fps
            FpsLabel.TextColor3 = (fps < 30) and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(50, 150, 255)
            
            PingLabel.Text = "PING: " .. ping
            PingLabel.TextColor3 = (ping > 100) and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(50, 150, 255)
            
            LossLabel.Text = "LOSS: 0%"
            LossLabel.TextColor3 = Color3.fromRGB(50, 150, 255)
            
            lastTick = tick()
            frames = 0
        end
    end)

    function Window:CreateTab(name, imageId)
        local TabData = {}
        
        local tabBtn = Instance.new("TextButton", Sidebar)
        tabBtn.Size = UDim2.new(0.9, 0, 0, 35)
        tabBtn.BackgroundColor3 = Color3.fromRGB(52, 63, 78)
        tabBtn.Text = "      " .. name
        tabBtn.TextColor3 = Color3.fromRGB(180, 190, 205)
        tabBtn.Font = Enum.Font.GothamMedium
        tabBtn.TextSize = 12
        tabBtn.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 8)

        local icon = Instance.new("ImageLabel", tabBtn)
        icon.Size = UDim2.new(0, 16, 0, 16)
        icon.Position = UDim2.new(0, 10, 0.5, -8)
        icon.BackgroundTransparency = 1
        icon.Image = "rbxassetid://" .. tostring(imageId)
        icon.ImageColor3 = Color3.fromRGB(180, 190, 205)

        local page = Instance.new("ScrollingFrame", PageContainer)
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.ScrollBarThickness = 4
        page.Visible = false
        page.ScrollingDirection = Enum.ScrollingDirection.Y
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        
        local pagePadding = Instance.new("UIPadding", page)
        pagePadding.PaddingTop = UDim.new(0, 20)
        
        local pageLayout = Instance.new("UIListLayout", page)
        pageLayout.Padding = UDim.new(0, 15)
        pageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        pageLayout.SortOrder = Enum.SortOrder.LayoutOrder

        pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 40)
        end)

        tabBtn.MouseButton1Click:Connect(function()
            HomeContainer.Visible = false
            for i, btn in ipairs(Window.TabButtons) do
                btn.BackgroundColor3 = Color3.fromRGB(52, 63, 78)
                btn.TextColor3 = Color3.fromRGB(180, 190, 205)
                if btn:FindFirstChildOfClass("ImageLabel") then
                    btn:FindFirstChildOfClass("ImageLabel").ImageColor3 = Color3.fromRGB(180, 190, 205)
                end
                Window.TabPages[i].Visible = false
            end
            tabBtn.BackgroundColor3 = CurrentThemeColor
            tabBtn.TextColor3 = Color3.new(1, 1, 1)
            if icon then icon.ImageColor3 = Color3.new(1, 1, 1) end
            page.Visible = true
        end)

        table.insert(Window.TabButtons, tabBtn)
        table.insert(Window.TabPages, page)

        if #Window.TabButtons == 1 then
            tabBtn.BackgroundColor3 = CurrentThemeColor
            tabBtn.TextColor3 = Color3.new(1, 1, 1)
            if icon then icon.ImageColor3 = Color3.new(1, 1, 1) end
            page.Visible = true
        end

        function TabData:CreateButton(btnName, callback)
            local btn = Instance.new("TextButton", page)
            btn.Size = UDim2.new(0.9, 0, 0, 45)
            btn.BackgroundColor3 = CharcoalColor
            btn.Text = "  " .. btnName
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Font = Enum.Font.GothamMedium
            btn.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
            
            local stroke1 = Instance.new("UIStroke", btn)
            stroke1.Color = CurrentThemeColor
            stroke1.Thickness = 1.5
            stroke1.Transparency = 0.3

            local btnIcon = Instance.new("ImageLabel", btn)
            btnIcon.Size = UDim2.new(0, 24, 0, 24) 
            btnIcon.Position = UDim2.new(1, -35, 0.5, -12) 
            btnIcon.BackgroundTransparency = 1
            btnIcon.Image = "rbxassetid://12333784627"

            btn.MouseButton1Click:Connect(callback)
            return btn
        end

        function TabData:CreateToggle(toggleName, callback)
            local state = false
            local btn = Instance.new("TextButton", page)
            btn.Size = UDim2.new(0.9, 0, 0, 45)
            btn.BackgroundColor3 = CharcoalColor
            btn.Text = "  " .. toggleName 
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Font = Enum.Font.GothamMedium
            btn.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
            
            local stroke = Instance.new("UIStroke", btn)
            stroke.Color = CurrentThemeColor
            stroke.Thickness = 1.5
            stroke.Transparency = 0.3
            
            local sliderBg = Instance.new("Frame", btn)
            sliderBg.Size = UDim2.new(0, 45, 0, 22)
            sliderBg.Position = UDim2.new(1, -55, 0.5, -11)
            sliderBg.BackgroundColor3 = Color3.fromRGB(65, 75, 90)
            Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)
            
            local sliderKnob = Instance.new("Frame", sliderBg)
            sliderKnob.Size = UDim2.new(0, 18, 0, 18)
            sliderKnob.Position = UDim2.new(0, 2, 0.5, -9)
            sliderKnob.BackgroundColor3 = Color3.new(1, 1, 1)
            Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)
            
            btn.MouseButton1Click:Connect(function()
                state = not state
                sliderBg.BackgroundColor3 = state and CurrentThemeColor or Color3.fromRGB(65, 75, 90)
                local targetPos = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
                TweenService:Create(sliderKnob, TweenInfo.new(0.2), {Position = targetPos}):Play()
                pcall(function() callback(state) end)
            end)
            return btn
        end

        function TabData:CreateDropdown(dropName, options, callback)
            local selectedItems = {}
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 45) 
            container.BackgroundColor3 = CharcoalColor
            container.ClipsDescendants = true 
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
            Instance.new("UIStroke", container).Color = CurrentThemeColor

            local topBar = Instance.new("TextButton", container)
            topBar.Size = UDim2.new(1, 0, 0, 45)
            topBar.BackgroundTransparency = 1
            topBar.Text = ""

            local title = Instance.new("TextLabel", topBar)
            title.Size = UDim2.new(0.4, 0, 1, 0)
            title.Position = UDim2.new(0, 15, 0, 0)
            title.Text = dropName
            title.TextColor3 = Color3.new(1, 1, 1)
            title.Font = Enum.Font.GothamMedium
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.BackgroundTransparency = 1

            local valueBox = Instance.new("Frame", topBar)
            valueBox.Size = UDim2.new(0, 100, 0, 25) 
            valueBox.Position = UDim2.new(1, -135, 0.5, -12)
            valueBox.BackgroundColor3 = Color3.fromRGB(45, 55, 68)
            Instance.new("UICorner", valueBox).CornerRadius = UDim.new(0, 6)

            local selectedText = Instance.new("TextLabel", valueBox)
            selectedText.Size = UDim2.new(1, -15, 1, 0)
            selectedText.Position = UDim2.new(0, 0, 0, 0)
            selectedText.Text = "Select..."
            selectedText.TextColor3 = Color3.fromRGB(180, 190, 205)
            selectedText.Font = Enum.Font.Gotham
            selectedText.TextSize = 12
            selectedText.BackgroundTransparency = 1
            selectedText.TextTruncate = Enum.TextTruncate.AtEnd
            selectedText.TextXAlignment = Enum.TextXAlignment.Right

            local dropIcon = Instance.new("ImageLabel", topBar)
            dropIcon.Size = UDim2.new(0, 16, 0, 16)
            dropIcon.Position = UDim2.new(1, -24, 0.5, -8)
            dropIcon.Image = "rbxassetid://5279719038"
            dropIcon.BackgroundTransparency = 1

            local listHeight = math.min(#options * 35, 140) 
            local listFrame = Instance.new("ScrollingFrame", container)
            listFrame.Size = UDim2.new(1, 0, 0, listHeight)
            listFrame.Position = UDim2.new(0, 0, 0, 45)
            listFrame.BackgroundTransparency = 1
            listFrame.BorderSizePixel = 0
            listFrame.ScrollBarThickness = 4
            listFrame.Active = true
            listFrame.ScrollingDirection = Enum.ScrollingDirection.Y
            listFrame.CanvasSize = UDim2.new(0, 0, 0, #options * 35)

            local isExpanded = false
            topBar.MouseButton1Click:Connect(function()
                isExpanded = not isExpanded
                local targetHeight = isExpanded and (45 + listHeight) or 45
                TweenService:Create(container, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Size = UDim2.new(0.9, 0, 0, targetHeight)}):Play()
                TweenService:Create(dropIcon, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Rotation = isExpanded and 180 or 0}):Play()
            end)

            for i, opt in ipairs(options) do
                local itemBtn = Instance.new("TextButton", listFrame)
                itemBtn.Size = UDim2.new(1, 0, 0, 35)
                itemBtn.Position = UDim2.new(0, 0, 0, (i-1)*35)
                itemBtn.BackgroundColor3 = Color3.fromRGB(48, 58, 72)
                itemBtn.Text = ""
                itemBtn.BorderSizePixel = 0

                local checkBg = Instance.new("Frame", itemBtn)
                checkBg.Size = UDim2.new(0, 16, 0, 16)
                checkBg.Position = UDim2.new(0, 15, 0.5, -8)
                checkBg.BackgroundColor3 = Color3.fromRGB(65, 75, 90)
                Instance.new("UICorner", checkBg).CornerRadius = UDim.new(0, 4)

                local checkFill = Instance.new("Frame", checkBg)
                checkFill.Size = UDim2.new(1, -4, 1, -4)
                checkFill.Position = UDim2.new(0, 2, 0, 2)
                checkFill.BackgroundColor3 = CurrentThemeColor
                checkFill.Visible = false 
                Instance.new("UICorner", checkFill).CornerRadius = UDim.new(0, 2)

                local itemText = Instance.new("TextLabel", itemBtn)
                itemText.Size = UDim2.new(1, -50, 1, 0)
                itemText.Position = UDim2.new(0, 40, 0, 0)
                itemText.Text = opt
                itemText.TextColor3 = Color3.fromRGB(200, 210, 225)
                itemText.Font = Enum.Font.Gotham
                itemText.TextSize = 13
                itemText.TextXAlignment = Enum.TextXAlignment.Left
                itemText.BackgroundTransparency = 1

                itemBtn.MouseButton1Click:Connect(function()
                    local idx = table.find(selectedItems, opt)
                    if idx then
                        table.remove(selectedItems, idx)
                        checkFill.Visible = false
                    else
                        table.insert(selectedItems, opt)
                        checkFill.Visible = true
                    end
                    if #selectedItems > 0 then
                        selectedText.Text = table.concat(selectedItems, ", ")
                        selectedText.TextColor3 = Color3.new(1, 1, 1)
                    else
                        selectedText.Text = "Select..."
                        selectedText.TextColor3 = Color3.fromRGB(180, 190, 205)
                    end
                    pcall(function() callback(selectedItems) end)
                end)
            end
            return container
        end

        function TabData:CreateDropdownTarget(dropName, options, callback)
            local selectedItem = nil
            local itemElements = {}

            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 45) 
            container.BackgroundColor3 = CharcoalColor
            container.ClipsDescendants = true 
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
            Instance.new("UIStroke", container).Color = CurrentThemeColor

            local topBar = Instance.new("TextButton", container)
            topBar.Size = UDim2.new(1, 0, 0, 45)
            topBar.BackgroundTransparency = 1
            topBar.Text = ""

            local title = Instance.new("TextLabel", topBar)
            title.Size = UDim2.new(0.4, 0, 1, 0)
            title.Position = UDim2.new(0, 15, 0, 0)
            title.Text = dropName
            title.TextColor3 = Color3.new(1, 1, 1)
            title.Font = Enum.Font.GothamMedium
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.BackgroundTransparency = 1

            local valueBox = Instance.new("Frame", topBar)
            valueBox.Size = UDim2.new(0, 100, 0, 25) 
            valueBox.Position = UDim2.new(1, -135, 0.5, -12)
            valueBox.BackgroundColor3 = Color3.fromRGB(45, 55, 68)
            Instance.new("UICorner", valueBox).CornerRadius = UDim.new(0, 6)

            local selectedText = Instance.new("TextLabel", valueBox)
            selectedText.Size = UDim2.new(1, -15, 1, 0)
            selectedText.Position = UDim2.new(0, 0, 0, 0)
            selectedText.Text = "Select..."
            selectedText.TextColor3 = Color3.fromRGB(180, 190, 205)
            selectedText.Font = Enum.Font.Gotham
            selectedText.TextSize = 12
            selectedText.BackgroundTransparency = 1
            selectedText.TextTruncate = Enum.TextTruncate.AtEnd
            selectedText.TextXAlignment = Enum.TextXAlignment.Right

            local dropIcon = Instance.new("ImageLabel", topBar)
            dropIcon.Size = UDim2.new(0, 16, 0, 16)
            dropIcon.Position = UDim2.new(1, -24, 0.5, -8)
            dropIcon.Image = "rbxassetid://5279719038"
            dropIcon.BackgroundTransparency = 1

            local listHeight = math.min(#options * 35, 140) 
            local listFrame = Instance.new("ScrollingFrame", container)
            listFrame.Size = UDim2.new(1, 0, 0, listHeight)
            listFrame.Position = UDim2.new(0, 0, 0, 45)
            listFrame.BackgroundTransparency = 1
            listFrame.BorderSizePixel = 0
            listFrame.ScrollBarThickness = 4
            listFrame.Active = true
            listFrame.ScrollingDirection = Enum.ScrollingDirection.Y
            listFrame.CanvasSize = UDim2.new(0, 0, 0, #options * 35)

            local isExpanded = false
            topBar.MouseButton1Click:Connect(function()
                isExpanded = not isExpanded
                local targetHeight = isExpanded and (45 + listHeight) or 45
                TweenService:Create(container, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Size = UDim2.new(0.9, 0, 0, targetHeight)}):Play()
                TweenService:Create(dropIcon, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Rotation = isExpanded and 180 or 0}):Play()
            end)

            for i, opt in ipairs(options) do
                local itemBtn = Instance.new("TextButton", listFrame)
                itemBtn.Size = UDim2.new(1, 0, 0, 35)
                itemBtn.Position = UDim2.new(0, 0, 0, (i-1)*35)
                itemBtn.BackgroundColor3 = Color3.fromRGB(48, 58, 72)
                itemBtn.Text = ""
                itemBtn.BorderSizePixel = 0

                local checkBg = Instance.new("Frame", itemBtn)
                checkBg.Size = UDim2.new(0, 16, 0, 16)
                checkBg.Position = UDim2.new(0, 15, 0.5, -8)
                checkBg.BackgroundColor3 = Color3.fromRGB(65, 75, 90)
                Instance.new("UICorner", checkBg).CornerRadius = UDim.new(1, 0)

                local checkFill = Instance.new("Frame", checkBg)
                checkFill.Size = UDim2.new(1, -6, 1, -6)
                checkFill.Position = UDim2.new(0, 3, 0, 3)
                checkFill.BackgroundColor3 = CurrentThemeColor
                checkFill.Visible = false 
                Instance.new("UICorner", checkFill).CornerRadius = UDim.new(1, 0)

                local itemText = Instance.new("TextLabel", itemBtn)
                itemText.Size = UDim2.new(1, -50, 1, 0)
                itemText.Position = UDim2.new(0, 40, 0, 0)
                itemText.Text = opt
                itemText.TextColor3 = Color3.fromRGB(200, 210, 225)
                itemText.Font = Enum.Font.Gotham
                itemText.TextSize = 13
                itemText.TextXAlignment = Enum.TextXAlignment.Left
                itemText.BackgroundTransparency = 1

                table.insert(itemElements, {
                    Option = opt,
                    Fill = checkFill,
                    TextLabel = itemText
                })

                itemBtn.MouseButton1Click:Connect(function()
                    selectedItem = opt
                    selectedText.Text = opt
                    selectedText.TextColor3 = Color3.new(1, 1, 1)

                    for _, el in ipairs(itemElements) do
                        if el.Option == selectedItem then
                            el.Fill.Visible = true
                        else
                            el.Fill.Visible = false
                        end
                    end

                    isExpanded = false
                    TweenService:Create(container, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Size = UDim2.new(0.9, 0, 0, 45)}):Play()
                    TweenService:Create(dropIcon, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Rotation = 0}):Play()

                    pcall(function() callback(selectedItem) end)
                end)
            end
            return container
        end

        function TabData:CreateSlider(sliderName, min, max, callback)
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 60)
            container.BackgroundColor3 = CharcoalColor
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
            Instance.new("UIStroke", container).Color = CurrentThemeColor
            
            local title = Instance.new("TextLabel", container)
            title.Size = UDim2.new(0.3, 0, 1, 0)
            title.Position = UDim2.new(0, 15, 0, 0)
            title.Text = sliderName
            title.TextColor3 = Color3.new(1, 1, 1)
            title.Font = Enum.Font.GothamMedium
            title.BackgroundTransparency = 1
            title.TextXAlignment = Enum.TextXAlignment.Left

            local valueBox = Instance.new("TextBox", container)
            valueBox.Size = UDim2.new(0, 45, 0, 28)
            valueBox.Position = UDim2.new(0, 110, 0.5, -14) 
            valueBox.BackgroundColor3 = Color3.fromRGB(45, 55, 68)
            valueBox.Text = tostring(max)
            valueBox.TextColor3 = Color3.new(1, 1, 1)
            valueBox.Font = Enum.Font.GothamBold
            Instance.new("UICorner", valueBox).CornerRadius = UDim.new(0, 6)

            local sliderBg = Instance.new("Frame", container)
            sliderBg.Size = UDim2.new(0.35, 0, 0, 6)
            sliderBg.Position = UDim2.new(0, 170, 0.5, -3) 
            sliderBg.BackgroundColor3 = Color3.fromRGB(65, 75, 90)
            Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

            local progress = Instance.new("Frame", sliderBg)
            progress.Size = UDim2.new(1, 0, 1, 0)
            progress.BackgroundColor3 = CurrentThemeColor
            Instance.new("UICorner", progress).CornerRadius = UDim.new(1, 0)

            local knob = Instance.new("Frame", sliderBg)
            knob.AnchorPoint = Vector2.new(0.5, 0.5) 
            knob.Size = UDim2.new(0, 16, 0, 16)
            knob.Position = UDim2.new(1, 0, 0.5, 0)
            knob.BackgroundColor3 = Color3.new(1, 1, 1)
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

            local hitbox = Instance.new("TextButton", sliderBg)
            hitbox.AnchorPoint = Vector2.new(0.5, 0.5)
            hitbox.Size = UDim2.new(1, 30, 0, 40) 
            hitbox.Position = UDim2.new(0.5, 0, 0.5, 0)
            hitbox.BackgroundTransparency = 1
            hitbox.Text = ""

            local sDragging = false
            local function updateSlider(inputX)
                local sliderX = sliderBg.AbsolutePosition.X
                local sliderWidth = sliderBg.AbsoluteSize.X
                local percent = math.clamp((inputX - sliderX) / sliderWidth, 0, 1)
                local val = math.floor(min + ((max - min) * percent))
                knob.Position = UDim2.new(percent, 0, 0.5, 0)
                progress.Size = UDim2.new(percent, 0, 1, 0)
                valueBox.Text = tostring(val)
                pcall(function() callback(val) end)
            end

            hitbox.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sDragging = true
                    page.ScrollingEnabled = false 
                    updateSlider(input.Position.X)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if sDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(input.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sDragging = false
                    page.ScrollingEnabled = true 
                end
            end)

            valueBox.FocusLost:Connect(function()
                local num = tonumber(valueBox.Text)
                if num then 
                    local clamped = math.clamp(num, min, max)
                    local percent = (clamped - min) / (max - min)
                    knob.Position = UDim2.new(percent, 0, 0.5, 0)
                    progress.Size = UDim2.new(percent, 0, 1, 0)
                    valueBox.Text = tostring(clamped)
                    pcall(function() callback(clamped) end)
                else
                    valueBox.Text = tostring(min)
                end
            end)
        end

        function TabData:CreateLabel(labelText)
            local label = Instance.new("TextLabel", page)
            label.Size = UDim2.new(0.9, 0, 0, 25)
            label.BackgroundTransparency = 1
            label.Text = "  " .. labelText
            label.TextColor3 = Color3.fromRGB(200, 210, 225)
            label.Font = Enum.Font.GothamMedium
            label.TextSize = 13
            label.TextXAlignment = Enum.TextXAlignment.Left
            return label
        end

        function TabData:CreateParagraph(titleText, contentText)
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 75)
            container.BackgroundColor3 = CharcoalColor
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
            Instance.new("UIStroke", container).Color = CurrentThemeColor

            local t = Instance.new("TextLabel", container)
            t.Size = UDim2.new(1, -20, 0, 25)
            t.Position = UDim2.new(0, 10, 0, 5)
            t.BackgroundTransparency = 1
            t.Text = titleText
            t.TextColor3 = Color3.new(1, 1, 1)
            t.Font = Enum.Font.GothamBold
            t.TextSize = 13
            t.TextXAlignment = Enum.TextXAlignment.Left

            local c = Instance.new("TextLabel", container)
            c.Size = UDim2.new(1, -20, 0, 40)
            c.Position = UDim2.new(0, 10, 0, 30)
            c.BackgroundTransparency = 1
            c.Text = contentText
            c.TextColor3 = Color3.fromRGB(180, 190, 205)
            c.Font = Enum.Font.Gotham
            c.TextSize = 12
            c.TextWrapped = true
            c.TextXAlignment = Enum.TextXAlignment.Left
            c.TextYAlignment = Enum.TextYAlignment.Top
            return container
        end

        function TabData:CreateKeybind(keybindName, defaultKey, callback)
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 45)
            container.BackgroundColor3 = CharcoalColor
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
            Instance.new("UIStroke", container).Color = CurrentThemeColor

            local title = Instance.new("TextLabel", container)
            title.Size = UDim2.new(0.5, 0, 1, 0)
            title.Position = UDim2.new(0, 15, 0, 0)
            title.BackgroundTransparency = 1
            title.Text = keybindName
            title.TextColor3 = Color3.new(1, 1, 1)
            title.Font = Enum.Font.GothamMedium
            title.TextXAlignment = Enum.TextXAlignment.Left

            local currentKey = defaultKey or Enum.KeyCode.RightShift
            local bindBtn = Instance.new("TextButton", container)
            bindBtn.Size = UDim2.new(0, 90, 0, 28)
            bindBtn.Position = UDim2.new(1, -100, 0.5, -14)
            bindBtn.BackgroundColor3 = Color3.fromRGB(45, 55, 68)
            bindBtn.Text = currentKey.Name
            bindBtn.TextColor3 = Color3.new(1, 1, 1)
            bindBtn.Font = Enum.Font.GothamBold
            bindBtn.TextSize = 12
            Instance.new("UICorner", bindBtn).CornerRadius = UDim.new(0, 6)

            local listening = false
            bindBtn.MouseButton1Click:Connect(function()
                listening = true
                bindBtn.Text = "..."
            end)

            UserInputService.InputBegan:Connect(function(input)
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    currentKey = input.KeyCode
                    bindBtn.Text = currentKey.Name
                    listening = false
                    pcall(function() callback(currentKey) end)
                end
            end)
            return container
        end

        function TabData:CreateSection(sectionName)
            local sec = Instance.new("TextLabel", page)
            sec.Size = UDim2.new(0.9, 0, 0, 30)
            sec.BackgroundTransparency = 1
            sec.Text = "--- " .. sectionName .. " ---"
            sec.TextColor3 = CurrentThemeColor
            sec.Font = Enum.Font.GothamBold
            sec.TextSize = 13
            sec.TextXAlignment = Enum.TextXAlignment.Center
            return sec
        end

        function TabData:CreateTextBox(boxName, placeholder, callback)
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 45)
            container.BackgroundColor3 = CharcoalColor
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
            local stroke = Instance.new("UIStroke", container)
            stroke.Color = CurrentThemeColor
            stroke.Thickness = 1.5

            local title = Instance.new("TextLabel", container)
            title.Size = UDim2.new(0.4, 0, 1, 0)
            title.Position = UDim2.new(0, 15, 0, 0)
            title.Text = boxName
            title.TextColor3 = Color3.new(1, 1, 1)
            title.Font = Enum.Font.GothamMedium
            title.BackgroundTransparency = 1
            title.TextXAlignment = Enum.TextXAlignment.Left

            local inputBox = Instance.new("TextBox", container)
            inputBox.Size = UDim2.new(0, 150, 0, 30)
            inputBox.Position = UDim2.new(1, -165, 0.5, -15)
            inputBox.BackgroundColor3 = Color3.fromRGB(45, 55, 68)
            inputBox.Text = ""
            inputBox.PlaceholderText = placeholder or "Type..."
            inputBox.PlaceholderColor3 = Color3.fromRGB(150, 160, 175)
            inputBox.TextColor3 = Color3.new(1, 1, 1)
            inputBox.Font = Enum.Font.Gotham
            inputBox.TextSize = 12
            Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 6)

            inputBox.FocusLost:Connect(function(enterPressed)
                pcall(function() callback(inputBox.Text, enterPressed) end)
            end)

            return container
        end

        return TabData
    end

    local function CreateColorPickerForHome()
        local container = Instance.new("Frame", HomeContainer)
        container.Size = UDim2.new(0.9, 0, 0, 160)
        container.BackgroundColor3 = CharcoalColor
        Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
        Instance.new("UIStroke", container).Color = CurrentThemeColor

        local title = Instance.new("TextLabel", container)
        title.Size = UDim2.new(1, -20, 0, 30)
        title.Position = UDim2.new(0, 15, 0, 5)
        title.BackgroundTransparency = 1
        title.Text = "Aura Color Gradient Picker (RGB)"
        title.TextColor3 = Color3.new(1, 1, 1)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 13
        title.TextXAlignment = Enum.TextXAlignment.Left

        local function makeColorSlider(name, yPos, defaultVal, colorCallback)
            local lbl = Instance.new("TextLabel", container)
            lbl.Size = UDim2.new(0, 30, 0, 25)
            lbl.Position = UDim2.new(0, 15, 0, yPos)
            lbl.BackgroundTransparency = 1
            lbl.Text = name
            lbl.TextColor3 = Color3.new(1, 1, 1)
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 12

            local sliderBg = Instance.new("Frame", container)
            sliderBg.Size = UDim2.new(0.65, 0, 0, 6)
            sliderBg.Position = UDim2.new(0, 50, 0, yPos + 10)
            sliderBg.BackgroundColor3 = Color3.fromRGB(65, 75, 90)
            Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

            local fill = Instance.new("Frame", sliderBg)
            fill.Size = UDim2.new(defaultVal / 255, 0, 1, 0)
            fill.BackgroundColor3 = CurrentThemeColor
            Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

            local knob = Instance.new("Frame", sliderBg)
            knob.AnchorPoint = Vector2.new(0.5, 0.5)
            knob.Size = UDim2.new(0, 14, 0, 14)
            knob.Position = UDim2.new(defaultVal / 255, 0, 0.5, 0)
            knob.BackgroundColor3 = Color3.new(1, 1, 1)
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

            local hitbox = Instance.new("TextButton", sliderBg)
            hitbox.Size = UDim2.new(1, 20, 1, 20)
            hitbox.Position = UDim2.new(0, -10, 0, -10)
            hitbox.BackgroundTransparency = 1
            hitbox.Text = ""

            local draggingColor = false
            hitbox.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingColor = true
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if draggingColor and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local posX = sliderBg.AbsolutePosition.X
                    local width = sliderBg.AbsoluteSize.X
                    local p = math.clamp((input.Position.X - posX) / width, 0, 1)
                    knob.Position = UDim2.new(p, 0, 0.5, 0)
                    fill.Size = UDim2.new(p, 0, 1, 0)
                    colorCallback(math.floor(p * 255))
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingColor = false
                end
            end)
        end

        local curR, curG, curB = 46, 80, 144
        makeColorSlider("R", 45, curR, function(v)
            curR = v
            CurrentThemeColor = Color3.fromRGB(curR, curG, curB)
            MainStroke.Color = CurrentThemeColor
            Aura2.BackgroundColor3 = CurrentThemeColor
            Aura3.BackgroundColor3 = CurrentThemeColor
            Aura4.BackgroundColor3 = CurrentThemeColor
            HomeButton.BackgroundColor3 = CurrentThemeColor
        end)
        makeColorSlider("G", 80, curG, function(v)
            curG = v
            CurrentThemeColor = Color3.fromRGB(curR, curG, curB)
            MainStroke.Color = CurrentThemeColor
            Aura2.BackgroundColor3 = CurrentThemeColor
            Aura3.BackgroundColor3 = CurrentThemeColor
            Aura4.BackgroundColor3 = CurrentThemeColor
            HomeButton.BackgroundColor3 = CurrentThemeColor
        end)
        makeColorSlider("B", 115, curB, function(v)
            curB = v
            CurrentThemeColor = Color3.fromRGB(curR, curG, curB)
            MainStroke.Color = CurrentThemeColor
            Aura2.BackgroundColor3 = CurrentThemeColor
            Aura3.BackgroundColor3 = CurrentThemeColor
            Aura4.BackgroundColor3 = CurrentThemeColor
            HomeButton.BackgroundColor3 = CurrentThemeColor
        end)
    end

    CreateColorPickerForHome()

    return Window
end

return NemoZLibrary