local NemoZLibrary = {}

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer

local TargetParent = nil
pcall(function() TargetParent = gethui() end)
if not TargetParent then pcall(function() TargetParent = CoreGui end) end
if not TargetParent then TargetParent = Player:WaitForChild("PlayerGui") end

function NemoZLibrary:CreateWindow(config)
    local Window = {
        TabButtons = {},
        TabPages = {}
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

    for i = 1, 35 do
        local star = Instance.new("Frame", IntroBackground)
        star.Size = UDim2.new(0, math.random(2, 4), 0, math.random(2, 4))
        star.Position = UDim2.new(math.random(), 0, math.random(), 0)
        star.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        star.BackgroundTransparency = math.random(20, 80) / 100
        Instance.new("UICorner", star).CornerRadius = UDim.new(1, 0)
    end

    local IntroCenterHolder = Instance.new("Frame", IntroBackground)
    IntroCenterHolder.Size = UDim2.new(0, 120, 0, 120)
    IntroCenterHolder.Position = UDim2.new(0.5, -60, 0.5, -110)
    IntroCenterHolder.BackgroundTransparency = 1

    local rotatingSquares = {}
    for i = 1, 12 do
        local sq = Instance.new("Frame", IntroCenterHolder)
        sq.Size = UDim2.new(0, 24, 0, 24)
        sq.Position = UDim2.new(0.5, -12, 0.5, -12)
        sq.BackgroundColor3 = Color3.fromRGB(46, 80, 144)
        sq.BorderSizePixel = 0
        Instance.new("UICorner", sq).CornerRadius = UDim.new(0, 6)
        table.insert(rotatingSquares, sq)
    end

    task.spawn(function()
        local angle = 0
        while IntroGui and IntroGui.Parent do
            angle = angle + 2
            for idx, sq in ipairs(rotatingSquares) do
                local rad = math.rad(angle + (idx * 30))
                local dist = 38 + (idx % 2) * 6
                sq.Position = UDim2.new(0.5, math.cos(rad) * dist - 12, 0.5, math.sin(rad) * dist - 12)
            end
            task.wait(0.03)
        end
    end)

    local IntroTitle = Instance.new("TextLabel", IntroBackground)
    IntroTitle.Size = UDim2.new(1, 0, 0, 80)
    IntroTitle.Position = UDim2.new(0, 0, 0.5, 20)
    IntroTitle.BackgroundTransparency = 1
    IntroTitle.Text = ""
    IntroTitle.TextColor3 = Color3.fromRGB(46, 80, 144)
    IntroTitle.Font = Enum.Font.GothamBold
    IntroTitle.TextSize = 42
    IntroTitle.TextXAlignment = Enum.TextXAlignment.Center

    task.spawn(function()
        task.wait(0.5)
        for i = 1, string.len(Name) do
            if not IntroTitle or not IntroTitle.Parent then break end
            IntroTitle.Text = string.sub(Name, 1, i)
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
                if MainWindow then MainWindow.Visible = true end
            end)
        end
    end)

    local ScreenGui = Instance.new("ScreenGui", TargetParent)
    ScreenGui.Name = "NemoZ_MainOnlyMenu"
    ScreenGui.IgnoreGuiInset = true

    for i = 4, 1, -1 do
        local auraLayer = Instance.new("Frame", ScreenGui)
        auraLayer.Size = UDim2.new(0, 500 + (i * 16), 0, 300 + (i * 16))
        auraLayer.Position = UDim2.new(0.5, -250 - (i * 8), 0.5, -150 - (i * 8))
        auraLayer.BackgroundColor3 = Color3.fromRGB(46, 80, 144)
        auraLayer.BackgroundTransparency = 0.75 + (i * 0.05)
        auraLayer.BorderSizePixel = 0
        Instance.new("UICorner", auraLayer).CornerRadius = UDim.new(0, 15 + i)
    end

    MainWindow = Instance.new("Frame", ScreenGui)
    MainWindow.Size = UDim2.new(0, 500, 0, 300)
    MainWindow.Position = UDim2.new(0.5, -250, 0.5, -150)
    MainWindow.BackgroundColor3 = Color3.fromRGB(54, 69, 79)
    MainWindow.BorderSizePixel = 0
    MainWindow.Active = true
    MainWindow.Visible = false 

    Instance.new("UICorner", MainWindow).CornerRadius = UDim.new(0, 15)
    
    local MainStroke = Instance.new("UIStroke", MainWindow)
    MainStroke.Color = Color3.fromRGB(46, 80, 144)
    MainStroke.Thickness = 1.5

    local Header = Instance.new("Frame", MainWindow)
    Header.Size = UDim2.new(1, 0, 0, 80)
    Header.BackgroundColor3 = Color3.fromRGB(54, 69, 79)
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 15)

    local mainDragging, mainDragStart, mainStartPos
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
            MainWindow.Position = UDim2.new(mainStartPos.X.Scale, mainStartPos.X.Offset + delta.X, mainStartPos.Y.Scale, mainStartPos.Y.Offset + delta.Y)
        end
    end)
    Header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            mainDragging = false
        end
    end)

    local Title = Instance.new("TextLabel", Header)
    Title.Text = Name
    Title.Size = UDim2.new(0.3, 0, 0.5, 0)
    Title.Position = UDim2.new(0.04, 0, 0, 0)
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.GothamBold
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local HomeButton = Instance.new("TextButton", Header)
    HomeButton.Size = UDim2.new(0, 50, 0, 28)
    HomeButton.Position = UDim2.new(0.52, 0, 0.12, 0)
    HomeButton.Text = "Home"
    HomeButton.TextColor3 = Color3.new(1, 1, 1)
    HomeButton.Font = Enum.Font.GothamMedium
    HomeButton.TextSize = 11
    HomeButton.BackgroundColor3 = Color3.fromRGB(46, 80, 144)
    Instance.new("UICorner", HomeButton).CornerRadius = UDim.new(0, 8)

    local StatsButton = Instance.new("TextButton", Header)
    StatsButton.Size = UDim2.new(0, 50, 0, 28)
    StatsButton.Position = UDim2.new(0.66, 0, 0.12, 0)
    StatsButton.Text = "Stats"
    StatsButton.TextColor3 = Color3.new(1, 1, 1)
    StatsButton.Font = Enum.Font.GothamMedium
    StatsButton.TextSize = 11
    StatsButton.BackgroundColor3 = Color3.fromRGB(46, 80, 144)
    Instance.new("UICorner", StatsButton).CornerRadius = UDim.new(0, 8)

    local Close = Instance.new("TextButton", Header)
    Close.Size = UDim2.new(0, 28, 0, 28)
    Close.Position = UDim2.new(0.90, 0, 0.12, 0)
    Close.Text = "×"
    Close.TextColor3 = Color3.new(1, 1, 1)
    Close.Font = Enum.Font.GothamBold
    Close.TextSize = 14
    Close.BackgroundColor3 = Color3.fromRGB(46, 80, 144)
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
    Sidebar.BackgroundColor3 = Color3.fromRGB(40, 52, 60)
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

    local HomePanel = Instance.new("ScrollingFrame", PageContainer)
    HomePanel.Size = UDim2.new(1, 0, 1, 0)
    HomePanel.BackgroundTransparency = 1
    HomePanel.ScrollBarThickness = 5
    HomePanel.ScrollBarImageColor3 = Color3.new(1, 1, 1)
    HomePanel.Visible = false
    HomePanel.Active = true
    HomePanel.ScrollingDirection = Enum.ScrollingDirection.Y

    local homeLayout = Instance.new("UIListLayout", HomePanel)
    homeLayout.Padding = UDim.new(0, 15)
    homeLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    homeLayout.SortOrder = Enum.SortOrder.LayoutOrder
    local homePadding = Instance.new("UIPadding", HomePanel)
    homePadding.PaddingTop = UDim.new(0, 20)

    homeLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        HomePanel.CanvasSize = UDim2.new(0, 0, 0, homeLayout.AbsoluteContentSize.Y + 40)
    end)

    local function addSpecialColorPickers(parentPage)
        local cp1Container = Instance.new("Frame", parentPage)
        cp1Container.Size = UDim2.new(0.9, 0, 0, 55)
        cp1Container.BackgroundColor3 = Color3.fromRGB(54, 69, 79)
        Instance.new("UICorner", cp1Container).CornerRadius = UDim.new(0, 8)
        Instance.new("UIStroke", cp1Container).Color = Color3.fromRGB(46, 80, 144)

        local cp1Title = Instance.new("TextLabel", cp1Container)
        cp1Title.Size = UDim2.new(0.6, 0, 1, 0)
        cp1Title.Position = UDim2.new(0, 15, 0, 0)
        cp1Title.Text = "Accent Color (#2E5090)"
        cp1Title.TextColor3 = Color3.new(1, 1, 1)
        cp1Title.Font = Enum.Font.GothamMedium
        cp1Title.BackgroundTransparency = 1
        cp1Title.TextXAlignment = Enum.TextXAlignment.Left

        local cp1Circle = Instance.new("Frame", cp1Container)
        cp1Circle.Size = UDim2.new(0, 35, 0, 35)
        cp1Circle.Position = UDim2.new(1, -45, 0.5, -17)
        cp1Circle.BackgroundColor3 = Color3.fromRGB(46, 80, 144)
        Instance.new("UICorner", cp1Circle).CornerRadius = UDim.new(1, 0)

        local cp2Container = Instance.new("Frame", parentPage)
        cp2Container.Size = UDim2.new(0.9, 0, 0, 55)
        cp2Container.BackgroundColor3 = Color3.fromRGB(54, 69, 79)
        Instance.new("UICorner", cp2Container).CornerRadius = UDim.new(0, 8)
        Instance.new("UIStroke", cp2Container).Color = Color3.fromRGB(46, 80, 144)

        local cp2Title = Instance.new("TextLabel", cp2Container)
        cp2Title.Size = UDim2.new(0.6, 0, 1, 0)
        cp2Title.Position = UDim2.new(0, 15, 0, 0)
        cp2Title.Text = "Background Color (#36454F)"
        cp2Title.TextColor3 = Color3.new(1, 1, 1)
        cp2Title.Font = Enum.Font.GothamMedium
        cp2Title.BackgroundTransparency = 1
        cp2Title.TextXAlignment = Enum.TextXAlignment.Left

        local cp2Circle = Instance.new("Frame", cp2Container)
        cp2Circle.Size = UDim2.new(0, 35, 0, 35)
        cp2Circle.Position = UDim2.new(1, -45, 0.5, -17)
        cp2Circle.BackgroundColor3 = Color3.fromRGB(54, 69, 79)
        Instance.new("UICorner", cp2Circle).CornerRadius = UDim.new(1, 0)

        local rgbContainer = Instance.new("Frame", parentPage)
        rgbContainer.Size = UDim2.new(0.9, 0, 0, 180)
        rgbContainer.BackgroundColor3 = Color3.fromRGB(54, 69, 79)
        Instance.new("UICorner", rgbContainer).CornerRadius = UDim.new(0, 8)
        Instance.new("UIStroke", rgbContainer).Color = Color3.fromRGB(46, 80, 144)

        local rgbTitle = Instance.new("TextLabel", rgbContainer)
        rgbTitle.Size = UDim2.new(1, -20, 0, 35)
        rgbTitle.Position = UDim2.new(0, 15, 0, 0)
        rgbTitle.Text = "RGB Color Gradient Picker"
        rgbTitle.TextColor3 = Color3.new(1, 1, 1)
        rgbTitle.Font = Enum.Font.GothamBold
        rgbTitle.BackgroundTransparency = 1
        rgbTitle.TextXAlignment = Enum.TextXAlignment.Left

        local chart = Instance.new("Frame", rgbContainer)
        chart.Size = UDim2.new(1, -30, 0, 110)
        chart.Position = UDim2.new(0, 15, 0, 40)
        chart.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        chart.BorderSizePixel = 0
        Instance.new("UICorner", chart).CornerRadius = UDim.new(0, 6)

        local chartGradient = Instance.new("UIGradient", chart)
        chartGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
        })

        local chartCircleO = Instance.new("Frame", chart)
        chartCircleO.Size = UDim2.new(0, 20, 0, 20)
        chartCircleO.Position = UDim2.new(0.5, -10, 0.5, -10)
        chartCircleO.BackgroundColor3 = Color3.new(1, 1, 1)
        Instance.new("UICorner", chartCircleO).CornerRadius = UDim.new(1, 0)
        local cStroke = Instance.new("UIStroke", chartCircleO)
        cStroke.Color = Color3.fromRGB(0, 0, 0)
        cStroke.Thickness = 2
    end

    addSpecialColorPickers(HomePanel)

    HomeButton.MouseButton1Click:Connect(function()
        HomePanel.Visible = true
        for _, p in ipairs(Window.TabPages) do p.Visible = false end
        for _, b in ipairs(Window.TabButtons) do b.BackgroundColor3 = Color3.fromRGB(40, 52, 60) end
    end)

    local MiniScreenGui = Instance.new("ScreenGui", TargetParent)
    MiniScreenGui.Name = "NemoZ_DeltaCustomMiniMenu"
    MiniScreenGui.IgnoreGuiInset = true

    local MiniMainFrame = Instance.new("Frame", MiniScreenGui)
    MiniMainFrame.Name = "MainFrame"
    MiniMainFrame.Size = UDim2.new(0, 135, 0, 40)
    MiniMainFrame.Position = UDim2.new(0.5, -67, 0, 0)
    MiniMainFrame.BackgroundColor3 = Color3.fromRGB(54, 69, 79)
    MiniMainFrame.BorderSizePixel = 0
    MiniMainFrame.Active = true
    MiniMainFrame.ZIndex = 2
    MiniMainFrame.Visible = false

    local MiniUICorner = Instance.new("UICorner", MiniMainFrame)
    MiniUICorner.CornerRadius = UDim.new(0, 12)

    local MiniUIStroke = Instance.new("UIStroke", MiniMainFrame)
    MiniUIStroke.Thickness = 1
    MiniUIStroke.Color = Color3.fromRGB(46, 80, 144)
    MiniUIStroke.Transparency = 1

    local MiniTopOverlay = Instance.new("Frame", MiniMainFrame)
    MiniTopOverlay.Name = "TopOverlay"
    MiniTopOverlay.Size = UDim2.new(1, 0, 0, 12)
    MiniTopOverlay.Position = UDim2.new(0, 0, 0, 0)
    MiniTopOverlay.BackgroundColor3 = Color3.fromRGB(54, 69, 79)
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
    MiniDivider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
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
        MiniUIStroke.Transparency = 1 
        
        if endY <= 3 then
            MiniMainFrame.BackgroundColor3 = Color3.fromRGB(54, 69, 79)
            MiniTopOverlay.BackgroundColor3 = Color3.fromRGB(54, 69, 79)
            MiniUICorner.CornerRadius = UDim.new(0, 12)
            MiniTopOverlay.Visible = true
            MiniMainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, 0)
        else
            MiniMainFrame.BackgroundColor3 = Color3.fromRGB(54, 69, 79)
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
        MiniMainFrame.Visible = true
    end)

    MiniOpenButton.MouseButton1Click:Connect(function()
        MainWindow.Visible = true
        MiniMainFrame.Visible = false
    end)

    local isMini = false
    StatsButton.MouseButton1Click:Connect(function()
        isMini = not isMini
        MainWindow.Size = isMini and UDim2.new(0, 500, 0, 80) or UDim2.new(0, 500, 0, 300)
        Sidebar.Visible = not isMini
        PageContainer.Visible = not isMini
        HomePanel.Visible = false
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
            FpsLabel.TextColor3 = (fps < 30) and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(46, 80, 144)
            
            PingLabel.Text = "PING: " .. ping
            PingLabel.TextColor3 = (ping > 100) and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(46, 80, 144)
            
            LossLabel.Text = "LOSS: 0%"
            LossLabel.TextColor3 = Color3.fromRGB(46, 80, 144)
            
            lastTick = tick()
            frames = 0
        end
    end)

    function Window:CreateTab(name, imageId)
        local TabData = {}
        
        local tabBtn = Instance.new("TextButton", Sidebar)
        tabBtn.Size = UDim2.new(0.9, 0, 0, 35)
        tabBtn.BackgroundColor3 = Color3.fromRGB(40, 52, 60)
        tabBtn.Text = "   " .. name
        tabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        tabBtn.Font = Enum.Font.GothamMedium
        tabBtn.TextSize = 12
        tabBtn.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 8)

        local icon = Instance.new("ImageLabel", tabBtn)
        icon.Size = UDim2.new(0, 16, 0, 16)
        icon.Position = UDim2.new(0, 10, 0.5, -8)
        icon.BackgroundTransparency = 1
        icon.Image = "rbxassetid://" .. tostring(imageId)
        icon.ImageColor3 = Color3.fromRGB(150, 150, 150)

        local page = Instance.new("ScrollingFrame", PageContainer)
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.ScrollBarThickness = 5
        page.ScrollBarImageColor3 = Color3.new(1, 1, 1)
        page.Visible = false
        page.Active = true
        page.ScrollingDirection = Enum.ScrollingDirection.Y
        
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
            HomePanel.Visible = false
            for i, btn in ipairs(Window.TabButtons) do
                btn.BackgroundColor3 = Color3.fromRGB(40, 52, 60)
                btn.TextColor3 = Color3.fromRGB(150, 150, 150)
                if btn:FindFirstChildOfClass("ImageLabel") then
                    btn:FindFirstChildOfClass("ImageLabel").ImageColor3 = Color3.fromRGB(150, 150, 150)
                end
                Window.TabPages[i].Visible = false
            end
            tabBtn.BackgroundColor3 = Color3.fromRGB(46, 80, 144)
            tabBtn.TextColor3 = Color3.new(1, 1, 1)
            if icon then icon.ImageColor3 = Color3.new(1, 1, 1) end
            page.Visible = true
        end)

        table.insert(Window.TabButtons, tabBtn)
        table.insert(Window.TabPages, page)

        if #Window.TabButtons == 1 then
            tabBtn.BackgroundColor3 = Color3.fromRGB(46, 80, 144)
            tabBtn.TextColor3 = Color3.new(1, 1, 1)
            if icon then icon.ImageColor3 = Color3.new(1, 1, 1) end
            page.Visible = true
        end

        local function addAuraToElement(element)
            local outerAura = Instance.new("UIStroke", element)
            outerAura.Color = Color3.fromRGB(46, 80, 144)
            outerAura.Thickness = 2.5
            outerAura.Transparency = 0.4
        end

        function TabData:CreateButton(btnName, callback)
            local btn = Instance.new("TextButton", page)
            btn.Size = UDim2.new(0.9, 0, 0, 45)
            btn.BackgroundColor3 = Color3.fromRGB(54, 69, 79)
            btn.Text = "  " .. btnName
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Font = Enum.Font.GothamMedium
            btn.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
            addAuraToElement(btn)

            btn.MouseButton1Click:Connect(callback)
            return btn
        end

        function TabData:CreateToggle(toggleName, callback)
            local state = false
            local btn = Instance.new("TextButton", page)
            btn.Size = UDim2.new(0.9, 0, 0, 45)
            btn.BackgroundColor3 = Color3.fromRGB(54, 69, 79)
            btn.Text = "  " .. toggleName 
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Font = Enum.Font.GothamMedium
            btn.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
            addAuraToElement(btn)
            
            local sliderBg = Instance.new("Frame", btn)
            sliderBg.Size = UDim2.new(0, 50, 0, 25)
            sliderBg.Position = UDim2.new(1, -60, 0.5, -12)
            sliderBg.BackgroundColor3 = Color3.fromRGB(40, 52, 60) 
            Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)
            
            local sliderKnob = Instance.new("Frame", sliderBg)
            sliderKnob.Size = UDim2.new(0.5, 0, 1, 0)
            sliderKnob.BackgroundColor3 = Color3.new(1, 1, 1)
            Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)
            
            btn.MouseButton1Click:Connect(function()
                state = not state
                sliderBg.BackgroundColor3 = state and Color3.fromRGB(46, 80, 144) or Color3.fromRGB(40, 52, 60)
                sliderKnob.Position = state and UDim2.new(0.5, 0, 0, 0) or UDim2.new(0, 0, 0, 0)
                pcall(function() callback(state) end)
            end)
            return btn
        end

        function TabData:CreateDropdown(dropName, options, callback)
            local selectedItems = {}
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 45) 
            container.BackgroundColor3 = Color3.fromRGB(54, 69, 79)
            container.ClipsDescendants = true 
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
            addAuraToElement(container)

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
            valueBox.BackgroundColor3 = Color3.fromRGB(40, 52, 60)
            Instance.new("UICorner", valueBox).CornerRadius = UDim.new(0, 5)

            local selectedText = Instance.new("TextLabel", valueBox)
            selectedText.Size = UDim2.new(1, -15, 1, 0)
            selectedText.Position = UDim2.new(0, 0, 0, 0)
            selectedText.Text = "Select..."
            selectedText.TextColor3 = Color3.fromRGB(150, 150, 150)
            selectedText.Font = Enum.Font.Gotham
            selectedText.TextSize = 12
            selectedText.BackgroundTransparency = 1
            selectedText.TextXAlignment = Enum.TextXAlignment.Right

            local dropIcon = Instance.new("ImageLabel", topBar)
            dropIcon.Size = UDim2.new(0, 18, 0, 18)
            dropIcon.Position = UDim2.new(1, -25, 0.5, -9)
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
                itemBtn.BackgroundColor3 = Color3.fromRGB(48, 62, 70)
                itemBtn.Text = ""
                itemBtn.BorderSizePixel = 0

                local checkBg = Instance.new("Frame", itemBtn)
                checkBg.Size = UDim2.new(0, 16, 0, 16)
                checkBg.Position = UDim2.new(0, 15, 0.5, -8)
                checkBg.BackgroundColor3 = Color3.fromRGB(40, 52, 60)
                Instance.new("UICorner", checkBg).CornerRadius = UDim.new(0, 4)

                local checkFill = Instance.new("Frame", checkBg)
                checkFill.Size = UDim2.new(1, -4, 1, -4)
                checkFill.Position = UDim2.new(0, 2, 0, 2)
                checkFill.BackgroundColor3 = Color3.fromRGB(46, 80, 144)
                checkFill.Visible = false 
                Instance.new("UICorner", checkFill).CornerRadius = UDim.new(0, 2)

                local itemText = Instance.new("TextLabel", itemBtn)
                itemText.Size = UDim2.new(1, -50, 1, 0)
                itemText.Position = UDim2.new(0, 40, 0, 0)
                itemText.Text = opt
                itemText.TextColor3 = Color3.fromRGB(200, 200, 200)
                itemText.Font = Enum.Font.Gotham
                itemText.TextSize = 13
                itemText.TextXAlignment = Enum.TextXAlignment.Left
                itemText.BackgroundTransparency = 1

                itemBtn.MouseButton1Click:Connect(function()
                    local idx = table.find(selectedItems, opt)
                    if idx then
                        table.remove(selectedItems, idx)
                        checkFill.Visible = false
                        itemText.TextColor3 = Color3.fromRGB(200, 200, 200)
                    else
                        table.insert(selectedItems, opt)
                        checkFill.Visible = true
                        itemText.TextColor3 = Color3.new(1, 1, 1)
                    end
                    if #selectedItems > 0 then
                        selectedText.Text = table.concat(selectedItems, ", ")
                        selectedText.TextColor3 = Color3.new(1, 1, 1)
                    else
                        selectedText.Text = "Select..."
                        selectedText.TextColor3 = Color3.fromRGB(150, 150, 150)
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
            container.BackgroundColor3 = Color3.fromRGB(54, 69, 79)
            container.ClipsDescendants = true 
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
            addAuraToElement(container)

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
            valueBox.BackgroundColor3 = Color3.fromRGB(40, 52, 60)
            Instance.new("UICorner", valueBox).CornerRadius = UDim.new(0, 5)

            local selectedText = Instance.new("TextLabel", valueBox)
            selectedText.Size = UDim2.new(1, -15, 1, 0)
            selectedText.Position = UDim2.new(0, 0, 0, 0)
            selectedText.Text = "Select..."
            selectedText.TextColor3 = Color3.fromRGB(150, 150, 150)
            selectedText.Font = Enum.Font.Gotham
            selectedText.TextSize = 12
            selectedText.BackgroundTransparency = 1
            selectedText.TextXAlignment = Enum.TextXAlignment.Right

            local dropIcon = Instance.new("ImageLabel", topBar)
            dropIcon.Size = UDim2.new(0, 18, 0, 18)
            dropIcon.Position = UDim2.new(1, -25, 0.5, -9)
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
                itemBtn.BackgroundColor3 = Color3.fromRGB(48, 62, 70)
                itemBtn.Text = ""
                itemBtn.BorderSizePixel = 0

                local checkBg = Instance.new("Frame", itemBtn)
                checkBg.Size = UDim2.new(0, 16, 0, 16)
                checkBg.Position = UDim2.new(0, 15, 0.5, -8)
                checkBg.BackgroundColor3 = Color3.fromRGB(40, 52, 60)
                Instance.new("UICorner", checkBg).CornerRadius = UDim.new(1, 0)

                local checkFill = Instance.new("Frame", checkBg)
                checkFill.Size = UDim2.new(1, -6, 1, -6)
                checkFill.Position = UDim2.new(0, 3, 0, 3)
                checkFill.BackgroundColor3 = Color3.fromRGB(46, 80, 144)
                checkFill.Visible = false 
                Instance.new("UICorner", checkFill).CornerRadius = UDim.new(1, 0)

                local itemText = Instance.new("TextLabel", itemBtn)
                itemText.Size = UDim2.new(1, -50, 1, 0)
                itemText.Position = UDim2.new(0, 40, 0, 0)
                itemText.Text = opt
                itemText.TextColor3 = Color3.fromRGB(200, 200, 200)
                itemText.Font = Enum.Font.Gotham
                itemText.TextSize = 13
                itemText.TextXAlignment = Enum.TextXAlignment.Left
                itemText.BackgroundTransparency = 1

                table.insert(itemElements, {Option = opt, Fill = checkFill, TextLabel = itemText})

                itemBtn.MouseButton1Click:Connect(function()
                    selectedItem = opt
                    selectedText.Text = opt
                    selectedText.TextColor3 = Color3.new(1, 1, 1)

                    for _, el in ipairs(itemElements) do
                        if el.Option == selectedItem then
                            el.Fill.Visible = true
                            el.TextLabel.TextColor3 = Color3.new(1, 1, 1)
                        else
                            el.Fill.Visible = false
                            el.TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
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
            container.BackgroundColor3 = Color3.fromRGB(54, 69, 79)
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
            addAuraToElement(container)
            
            local title = Instance.new("TextLabel", container)
            title.Size = UDim2.new(0.3, 0, 1, 0)
            title.Position = UDim2.new(0, 15, 0, 0)
            title.Text = sliderName
            title.TextColor3 = Color3.new(1, 1, 1)
            title.Font = Enum.Font.GothamMedium
            title.BackgroundTransparency = 1
            title.TextXAlignment = Enum.TextXAlignment.Left

            local valueBox = Instance.new("TextBox", container)
            valueBox.Size = UDim2.new(0, 40, 0, 30)
            valueBox.Position = UDim2.new(0, 100, 0.5, -15) 
            valueBox.BackgroundColor3 = Color3.fromRGB(40, 52, 60)
            valueBox.Text = tostring(max)
            valueBox.TextColor3 = Color3.new(1, 1, 1)
            valueBox.Font = Enum.Font.GothamBold
            Instance.new("UICorner", valueBox).CornerRadius = UDim.new(0, 4)

            local sliderBg = Instance.new("Frame", container)
            sliderBg.Size = UDim2.new(0.4, 0, 0, 6)
            sliderBg.Position = UDim2.new(0, 150, 0.5, -3) 
            sliderBg.BackgroundColor3 = Color3.fromRGB(40, 52, 60)
            Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

            local progress = Instance.new("Frame", sliderBg)
            progress.Size = UDim2.new(1, 0, 1, 0)
            progress.BackgroundColor3 = Color3.fromRGB(46, 80, 144)
            Instance.new("UICorner", progress).CornerRadius = UDim.new(1, 0)

            local knob = Instance.new("ImageLabel", sliderBg)
            knob.AnchorPoint = Vector2.new(0.5, 0.5) 
            knob.Size = UDim2.new(0, 22, 0, 22)
            knob.Position = UDim2.new(1, 0, 0.5, 0)
            knob.BackgroundTransparency = 1
            knob.Image = "rbxassetid://5639840603"
            knob.ZIndex = 5

            local hitbox = Instance.new("TextButton", sliderBg)
            hitbox.AnchorPoint = Vector2.new(0.5, 0.5)
            hitbox.Size = UDim2.new(1, 30, 0, 40) 
            hitbox.Position = UDim2.new(0.5, 0, 0.5, 0)
            hitbox.BackgroundTransparency = 1
            hitbox.Text = ""
            hitbox.ZIndex = 10

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
            label.Size = UDim2.new(0.9, 0, 0, 30)
            label.BackgroundTransparency = 1
            label.Text = "  " .. labelText
            label.TextColor3 = Color3.fromRGB(180, 185, 195)
            label.Font = Enum.Font.GothamMedium
            label.TextSize = 13
            label.TextXAlignment = Enum.TextXAlignment.Left
            return label
        end

        function TabData:CreateParagraph(titleText, contentText)
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 75)
            container.BackgroundColor3 = Color3.fromRGB(54, 69, 79)
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
            addAuraToElement(container)

            local pTitle = Instance.new("TextLabel", container)
            pTitle.Size = UDim2.new(1, -20, 0, 25)
            pTitle.Position = UDim2.new(0, 10, 0, 5)
            pTitle.Text = titleText
            pTitle.TextColor3 = Color3.new(1, 1, 1)
            pTitle.Font = Enum.Font.GothamBold
            pTitle.TextSize = 13
            pTitle.BackgroundTransparency = 1
            pTitle.TextXAlignment = Enum.TextXAlignment.Left

            local pDesc = Instance.new("TextLabel", container)
            pDesc.Size = UDim2.new(1, -20, 0, 40)
            pDesc.Position = UDim2.new(0, 10, 0, 28)
            pDesc.Text = contentText
            pDesc.TextColor3 = Color3.fromRGB(200, 205, 215)
            pDesc.Font = Enum.Font.Gotham
            pDesc.TextSize = 12
            pDesc.BackgroundTransparency = 1
            pDesc.TextXAlignment = Enum.TextXAlignment.Left
            pDesc.TextWrapped = true

            return container
        end

        function TabData:CreateColorPicker(pickerName, defaultColor, callback)
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 45)
            container.BackgroundColor3 = Color3.fromRGB(54, 69, 79)
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
            addAuraToElement(container)

            local title = Instance.new("TextLabel", container)
            title.Size = UDim2.new(0.6, 0, 1, 0)
            title.Position = UDim2.new(0, 15, 0, 0)
            title.Text = pickerName
            title.TextColor3 = Color3.new(1, 1, 1)
            title.Font = Enum.Font.GothamMedium
            title.BackgroundTransparency = 1
            title.TextXAlignment = Enum.TextXAlignment.Left

            local cpBtn = Instance.new("TextButton", container)
            cpBtn.Size = UDim2.new(0, 30, 0, 30)
            cpBtn.Position = UDim2.new(1, -40, 0.5, -15)
            cpBtn.BackgroundColor3 = defaultColor or Color3.fromRGB(46, 80, 144)
            cpBtn.Text = ""
            Instance.new("UICorner", cpBtn).CornerRadius = UDim.new(1, 0)

            cpBtn.MouseButton1Click:Connect(function()
                pcall(function() callback(cpBtn.BackgroundColor3) end)
            end)

            return container
        end

        function TabData:CreateKeybind(keybindName, defaultKey, callback)
            local currentKey = defaultKey or Enum.KeyCode.F
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 45)
            container.BackgroundColor3 = Color3.fromRGB(54, 69, 79)
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
            addAuraToElement(container)

            local title = Instance.new("TextLabel", container)
            title.Size = UDim2.new(0.5, 0, 1, 0)
            title.Position = UDim2.new(0, 15, 0, 0)
            title.Text = keybindName
            title.TextColor3 = Color3.new(1, 1, 1)
            title.Font = Enum.Font.GothamMedium
            title.BackgroundTransparency = 1
            title.TextXAlignment = Enum.TextXAlignment.Left

            local keyBtn = Instance.new("TextButton", container)
            keyBtn.Size = UDim2.new(0, 80, 0, 28)
            keyBtn.Position = UDim2.new(1, -95, 0.5, -14)
            keyBtn.BackgroundColor3 = Color3.fromRGB(40, 52, 60)
            keyBtn.Text = tostring(currentKey.Name)
            keyBtn.TextColor3 = Color3.new(1, 1, 1)
            keyBtn.Font = Enum.Font.GothamBold
            keyBtn.TextSize = 12
            Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0, 5)

            local listening = false
            keyBtn.MouseButton1Click:Connect(function()
                listening = true
                keyBtn.Text = "..."
            end)

            UserInputService.InputBegan:Connect(function(input)
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    currentKey = input.KeyCode
                    keyBtn.Text = tostring(currentKey.Name)
                    listening = false
                    pcall(function() callback(currentKey) end)
                end
            end)

            return container
        end

        function TabData:CreateSection(sectionName)
            local section = Instance.new("TextLabel", page)
            section.Size = UDim2.new(0.9, 0, 0, 25)
            section.BackgroundTransparency = 1
            section.Text = "  " .. string.upper(sectionName)
            section.TextColor3 = Color3.fromRGB(46, 80, 144)
            section.Font = Enum.Font.GothamBold
            section.TextSize = 12
            section.TextXAlignment = Enum.TextXAlignment.Left
            return section
        end

        function TabData:CreateTextBox(boxName, placeholder, callback)
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 45)
            container.BackgroundColor3 = Color3.fromRGB(54, 69, 79)
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
            addAuraToElement(container)

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
            inputBox.BackgroundColor3 = Color3.fromRGB(40, 52, 60)
            inputBox.Text = ""
            inputBox.PlaceholderText = placeholder or "Type..."
            inputBox.PlaceholderColor3 = Color3.fromRGB(120, 125, 135)
            inputBox.TextColor3 = Color3.new(1, 1, 1)
            inputBox.Font = Enum.Font.Gotham
            inputBox.TextSize = 12
            Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 5)

            inputBox.FocusLost:Connect(function(enterPressed)
                pcall(function() callback(inputBox.Text, enterPressed) end)
            end)

            return container
        end

        return TabData
    end

    return Window
end

return NemoZLibrary