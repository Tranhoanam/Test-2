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
    local HomePanel

    -- ==========================================
    -- 1. MÀN HÌNH MỞ ĐẦU (INTRO SCREEN - 5 GIÂY)
    -- ==========================================
    local IntroGui = Instance.new("ScreenGui", TargetParent)
    IntroGui.Name = "NemoZ_IntroScreen"
    IntroGui.IgnoreGuiInset = true
    IntroGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local IntroBackground = Instance.new("Frame", IntroGui)
    IntroBackground.Size = UDim2.new(1, 0, 1, 0)
    IntroBackground.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    IntroBackground.BorderSizePixel = 0
    IntroBackground.BackgroundTransparency = 0

    -- Lớp sao trời (Starfield)
    for i = 1, 40 do
        local star = Instance.new("Frame", IntroBackground)
        star.Size = UDim2.new(0, math.random(2, 4), 0, math.random(2, 4))
        star.Position = UDim2.new(math.random(), 0, math.random(), 0)
        star.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        star.BackgroundTransparency = math.random(20, 80) / 100
        Instance.new("UICorner", star).CornerRadius = UDim.new(1, 0)
    end

    -- Lớp trung tâm: Khối xoay vòng tròn chuẩn mẫu hình ảnh
    local CenterLogoHolder = Instance.new("Frame", IntroBackground)
    CenterLogoHolder.Size = UDim2.new(0, 120, 0, 120)
    CenterLogoHolder.Position = UDim2.new(0.5, -60, 0.5, -90)
    CenterLogoHolder.BackgroundTransparency = 1

    for i = 1, 16 do
        local angle = (i / 16) * math.pi * 2
        local square = Instance.new("Frame", CenterLogoHolder)
        square.Size = UDim2.new(0, math.random(14, 22), 0, math.random(14, 22))
        square.Position = UDim2.new(0.5, math.cos(angle) * 35 - 10, 0.5, math.sin(angle) * 35 - 10)
        square.BackgroundColor3 = Color3.fromRGB(46, 80, 144) -- #2E5090
        square.BorderSizePixel = 0
        Instance.new("UICorner", square).CornerRadius = UDim.new(0, 6)
    end

    task.spawn(function()
        while IntroGui and IntroGui.Parent do
            CenterLogoHolder.Rotation = CenterLogoHolder.Rotation + 1.5
            task.wait(0.03)
        end
    end)

    local IntroSound = Instance.new("Sound", IntroGui)
    IntroSound.SoundId = "rbxassetid://125090389445721"
    IntroSound.Volume = 1
    pcall(function() IntroSound:Play() end)

    local IntroTitle = Instance.new("TextLabel", IntroBackground)
    IntroTitle.Size = UDim2.new(1, 0, 0, 80)
    IntroTitle.Position = UDim2.new(0, 0, 0.5, 25)
    IntroTitle.BackgroundTransparency = 1
    IntroTitle.Text = ""
    IntroTitle.TextColor3 = Color3.fromRGB(46, 80, 144)
    IntroTitle.Font = Enum.Font.GothamBold
    IntroTitle.TextSize = 42
    IntroTitle.TextXAlignment = Enum.TextXAlignment.Center

    task.spawn(function()
        task.wait(0.5)
        local targetText = "Nemo-z"
        for i = 1, #targetText do
            IntroTitle.Text = string.sub(targetText, 1, i)
            task.wait(0.2)
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
                if IntroSound then
                    IntroSound:Stop()
                    IntroSound:Destroy()
                end
                if MainWindow then
                    MainWindow.Visible = true
                end
            end)
        end
    end)

    -- ==========================================
    -- 2. HỆ THỐNG MENU CHÍNH & ĐA LỚP AURA
    -- ==========================================
    local ScreenGui = Instance.new("ScreenGui", TargetParent)
    ScreenGui.Name = "NemoZ_MainOnlyMenu"
    ScreenGui.IgnoreGuiInset = true

    -- 4 Lớp Aura khổng lồ bao bọc Main Window
    local AuraHolder = Instance.new("Folder", ScreenGui)
    AuraHolder.Name = "AuraFolder"

    for i = 4, 1, -1 do
        local auraLayer = Instance.new("Frame", AuraHolder)
        auraLayer.Size = UDim2.new(0, 500 + (i * 24), 0, 300 + (i * 24))
        auraLayer.Position = UDim2.new(0.5, -250 - (i * 12), 0.5, -150 - (i * 12))
        auraLayer.BackgroundColor3 = Color3.fromRGB(46, 80, 144)
        auraLayer.BackgroundTransparency = 0.85 + (i * 0.03)
        auraLayer.BorderSizePixel = 0
        Instance.new("UICorner", auraLayer).CornerRadius = UDim.new(0, 15 + (i * 4))
    end

    MainWindow = Instance.new("Frame", ScreenGui)
    MainWindow.Size = UDim2.new(0, 500, 0, 300)
    MainWindow.Position = UDim2.new(0.5, -250, 0.5, -150)
    MainWindow.BackgroundColor3 = Color3.fromRGB(54, 69, 79) -- #36454F Charcoal Gray
    MainWindow.BorderSizePixel = 0
    MainWindow.Active = true
    MainWindow.Visible = false 

    Instance.new("UICorner", MainWindow).CornerRadius = UDim.new(0, 15)
    
    local MainStroke = Instance.new("UIStroke", MainWindow)
    MainStroke.Color = Color3.fromRGB(46, 80, 144)
    MainStroke.Thickness = 1.5

    -- Họa tiết vải rồng chìm nền
    local DragonPattern = Instance.new("ImageLabel", MainWindow)
    DragonPattern.Size = UDim2.new(1, 0, 1, 0)
    DragonPattern.BackgroundTransparency = 1
    DragonPattern.Image = "rbxassetid://6071579801"
    DragonPattern.ImageTransparency = 0.92
    DragonPattern.ScaleType = Enum.ScaleType.Tile
    DragonPattern.TileSize = UDim2.new(0, 100, 0, 100)

    -- Header
    local Header = Instance.new("Frame", MainWindow)
    Header.Size = UDim2.new(1, 0, 0, 80)
    Header.BackgroundColor3 = Color3.fromRGB(46, 80, 144)
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
            -- Đồng bộ Aura theo vị trí Main Window
            local idx = 1
            for _, aura in ipairs(AuraHolder:GetChildren()) do
                aura.Position = UDim2.new(MainWindow.Position.X.Scale, MainWindow.Position.X.Offset - (idx * 12), MainWindow.Position.Y.Scale, MainWindow.Position.Y.Offset - (idx * 12))
                idx = idx + 1
            end
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

    -- Nút Home mới trên Header
    local HomeButton = Instance.new("TextButton", Header)
    HomeButton.Size = UDim2.new(0, 55, 0, 30)
    HomeButton.Position = UDim2.new(0.58, 0, 0.1, 0)
    HomeButton.Text = "Home"
    HomeButton.TextColor3 = Color3.new(1, 1, 1)
    HomeButton.Font = Enum.Font.GothamMedium
    HomeButton.TextSize = 12
    HomeButton.BackgroundColor3 = Color3.fromRGB(46, 80, 144)
    Instance.new("UICorner", HomeButton).CornerRadius = UDim.new(0, 8)

    -- Nút Stats (cập nhật hình chữ nhật góc tròn mềm mại)
    local StatsButton = Instance.new("TextButton", Header)
    StatsButton.Size = UDim2.new(0, 55, 0, 30)
    StatsButton.Position = UDim2.new(0.71, 0, 0.1, 0)
    StatsButton.Text = "Stats"
    StatsButton.TextColor3 = Color3.new(1, 1, 1)
    StatsButton.Font = Enum.Font.GothamMedium
    StatsButton.TextSize = 12
    StatsButton.BackgroundColor3 = Color3.fromRGB(46, 80, 144)
    Instance.new("UICorner", StatsButton).CornerRadius = UDim.new(0, 8)

    local Close = Instance.new("TextButton", Header)
    Close.Size = UDim2.new(0, 30, 0, 30)
    Close.Position = UDim2.new(0.91, 0, 0.1, 0)
    Close.Text = "×"
    Close.TextColor3 = Color3.new(1, 1, 1)
    Close.Font = Enum.Font.GothamBold
    Close.TextSize = 13
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
    Sidebar.BackgroundColor3 = Color3.fromRGB(36, 45, 53)
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

    -- ==========================================
    -- 3. BẢNG ĐIỀU KHIỂN HOME (ĐẶC QUYỀN COLOR PICKER TO GẤP 4 LẦN & RGB GRADIENT CHART)
    -- ==========================================
    HomePanel = Instance.new("ScrollingFrame", PageContainer)
    HomePanel.Size = UDim2.new(1, 0, 1, 0)
    HomePanel.BackgroundTransparency = 1
    HomePanel.ScrollBarThickness = 5
    HomePanel.Visible = false
    HomePanel.Active = true
    HomePanel.ScrollingDirection = Enum.ScrollingDirection.Y

    local homeLayout = Instance.new("UIListLayout", HomePanel)
    homeLayout.Padding = UDim.new(0, 15)
    homeLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local homePadding = Instance.new("UIPadding", HomePanel)
    homePadding.PaddingTop = UDim.new(0, 20)

    homeLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        HomePanel.CanvasSize = UDim2.new(0, 0, 0, homeLayout.AbsoluteContentSize.Y + 40)
    end)

    -- Hàm tạo ColorPicker đặc quyền cho Home Panel (To gấp 4 lần)
    local function createHomeColorPicker(labelTitle, defaultColor)
        local container = Instance.new("Frame", HomePanel)
        container.Size = UDim2.new(0.9, 0, 0, 180) -- To gấp 4 lần thông thường
        container.BackgroundColor3 = Color3.fromRGB(36, 45, 53)
        Instance.new("UICorner", container).CornerRadius = UDim.new(0, 12)
        Instance.new("UIStroke", container).Color = Color3.fromRGB(46, 80, 144)

        local title = Instance.new("TextLabel", container)
        title.Size = UDim2.new(1, -20, 0, 30)
        title.Position = UDim2.new(0, 15, 0, 10)
        title.Text = labelTitle
        title.TextColor3 = Color3.new(1, 1, 1)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 14
        title.BackgroundTransparency = 1
        title.TextXAlignment = Enum.TextXAlignment.Left

        -- Hộp hiển thị RGB Gradient Chart (ảnh mẫu 1793408044171.jpg)
        local chart = Instance.new("ImageLabel", container)
        chart.Size = UDim2.new(1, -30, 0, 110)
        chart.Position = UDim2.new(0, 15, 0, 45)
        chart.BackgroundColor3 = Color3.new(1, 1, 1)
        chart.Image = "rbxassetid://1793408044171" -- RGB Gradient Chart asset
        Instance.new("UICorner", chart).CornerRadius = UDim.new(0, 8)

        return container
    end

    createHomeColorPicker("RGB Color Gradient Picker (#2E5090)", Color3.fromRGB(46, 80, 144))
    createHomeColorPicker("RGB Color Gradient Picker (#36454F)", Color3.fromRGB(54, 69, 79))

    -- ==========================================
    -- 4. MINI MENU THU NHỎ (BẢO TOÀN NGUYÊN VẸN)
    -- ==========================================
    local MiniScreenGui = Instance.new("ScreenGui", TargetParent)
    MiniScreenGui.Name = "NemoZ_DeltaCustomMiniMenu"
    MiniScreenGui.IgnoreGuiInset = true

    local MiniMainFrame = Instance.new("Frame", MiniScreenGui)
    MiniMainFrame.Name = "MainFrame"
    MiniMainFrame.Size = UDim2.new(0, 135, 0, 40)
    MiniMainFrame.Position = UDim2.new(0.5, -67, 0, 0)
    MiniMainFrame.BackgroundColor3 = Color3.fromRGB(36, 45, 53)
    MiniMainFrame.BorderSizePixel = 0
    MiniMainFrame.Active = true
    MiniMainFrame.ZIndex = 2
    MiniMainFrame.Visible = false

    local MiniUICorner = Instance.new("UICorner", MiniMainFrame)
    MiniUICorner.CornerRadius = UDim.new(0, 12)

    local MiniUIStroke = Instance.new("UIStroke", MiniMainFrame)
    MiniUIStroke.Thickness = 1
    MiniUIStroke.Color = Color3.fromRGB(46, 80, 144)

    local MiniTopOverlay = Instance.new("Frame", MiniMainFrame)
    MiniTopOverlay.Name = "TopOverlay"
    MiniTopOverlay.Size = UDim2.new(1, 0, 0, 12)
    MiniTopOverlay.Position = UDim2.new(0, 0, 0, 0)
    MiniTopOverlay.BackgroundColor3 = Color3.fromRGB(36, 45, 53)
    MiniTopOverlay.BorderSizePixel = 0
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
        
        if endY <= 3 then
            MiniMainFrame.BackgroundColor3 = Color3.fromRGB(36, 45, 53)
            MiniTopOverlay.BackgroundColor3 = Color3.fromRGB(36, 45, 53)
            MiniUICorner.CornerRadius = UDim.new(0, 12)
            MiniTopOverlay.Visible = true
            MiniMainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, 0)
        else
            MiniMainFrame.BackgroundColor3 = Color3.fromRGB(46, 80, 144)
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
        AuraHolder.Parent = nil
        MiniMainFrame.Visible = true
    end)

    MiniOpenButton.MouseButton1Click:Connect(function()
        MainWindow.Visible = true
        AuraHolder.Parent = ScreenGui
        MiniMainFrame.Visible = false
    end)

    local isMini = false
    StatsButton.MouseButton1Click:Connect(function()
        isMini = not isMini
        MainWindow.Size = isMini and UDim2.new(0, 500, 0, 80) or UDim2.new(0, 500, 0, 300)
        Sidebar.Visible = not isMini
        PageContainer.Visible = not isMini
    end)

    HomeButton.MouseButton1Click:Connect(function()
        HomePanel.Visible = true
        for _, page in ipairs(Window.TabPages) do
            page.Visible = false
        end
        for _, btn in ipairs(Window.TabButtons) do
            btn.BackgroundColor3 = Color3.fromRGB(36, 45, 53)
            btn.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
    end)

    -- FPS & Ping Counter
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

    -- ==========================================
    -- 5. HỆ THỐNG TAB & CÁC NÚT CREATE THÀNH PHẦN
    -- ==========================================
    function Window:CreateTab(name, imageId)
        local TabData = {}
        
        local tabBtn = Instance.new("TextButton", Sidebar)
        tabBtn.Size = UDim2.new(0.9, 0, 0, 35)
        tabBtn.BackgroundColor3 = Color3.fromRGB(36, 45, 53)
        tabBtn.Text = "    " .. name
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
                btn.BackgroundColor3 = Color3.fromRGB(36, 45, 53)
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

        function TabData:CreateSection(sectionName)
            local sec = Instance.new("TextLabel", page)
            sec.Size = UDim2.new(0.9, 0, 0, 25)
            sec.BackgroundTransparency = 1
            sec.Text = "  " .. string.upper(sectionName)
            sec.TextColor3 = Color3.fromRGB(46, 80, 144)
            sec.Font = Enum.Font.GothamBold
            sec.TextSize = 12
            sec.TextXAlignment = Enum.TextXAlignment.Left
            return sec
        end

        function TabData:CreateParagraph(titleText, contentText)
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 70)
            container.BackgroundColor3 = Color3.fromRGB(36, 45, 53)
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
            Instance.new("UIStroke", container).Color = Color3.fromRGB(46, 80, 144)

            local title = Instance.new("TextLabel", container)
            title.Size = UDim2.new(1, -20, 0, 25)
            title.Position = UDim2.new(0, 10, 0, 8)
            title.Text = titleText
            title.TextColor3 = Color3.new(1, 1, 1)
            title.Font = Enum.Font.GothamBold
            title.TextSize = 13
            title.BackgroundTransparency = 1
            title.TextXAlignment = Enum.TextXAlignment.Left

            local desc = Instance.new("TextLabel", container)
            desc.Size = UDim2.new(1, -20, 0, 30)
            desc.Position = UDim2.new(0, 10, 0, 33)
            desc.Text = contentText
            desc.TextColor3 = Color3.fromRGB(180, 185, 195)
            desc.Font = Enum.Font.Gotham
            desc.TextSize = 12
            desc.BackgroundTransparency = 1
            desc.TextXAlignment = Enum.TextXAlignment.Left
            desc.TextWrapped = true
            return container
        end

        function TabData:CreateButton(btnName, callback)
            local btn = Instance.new("TextButton", page)
            btn.Size = UDim2.new(0.9, 0, 0, 45)
            btn.BackgroundColor3 = Color3.fromRGB(36, 45, 53)
            btn.Text = "  " .. btnName
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Font = Enum.Font.GothamMedium
            btn.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
            
            local stroke = Instance.new("UIStroke", btn)
            stroke.Color = Color3.fromRGB(46, 80, 144)
            stroke.Thickness = 1.5

            btn.MouseButton1Click:Connect(callback)
            return btn
        end

        function TabData:CreateToggle(toggleName, callback)
            local state = false
            local btn = Instance.new("TextButton", page)
            btn.Size = UDim2.new(0.9, 0, 0, 45)
            btn.BackgroundColor3 = Color3.fromRGB(36, 45, 53)
            btn.Text = "  " .. toggleName 
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Font = Enum.Font.GothamMedium
            btn.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
            
            local stroke = Instance.new("UIStroke", btn)
            stroke.Color = Color3.fromRGB(46, 80, 144)
            stroke.Thickness = 1.5
            
            local sliderBg = Instance.new("Frame", btn)
            sliderBg.Size = UDim2.new(0, 50, 0, 25)
            sliderBg.Position = UDim2.new(1, -60, 0.5, -12)
            sliderBg.BackgroundColor3 = Color3.fromRGB(54, 69, 79)
            Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)
            
            local sliderKnob = Instance.new("Frame", sliderBg)
            sliderKnob.Size = UDim2.new(0.5, 0, 1, 0)
            sliderKnob.BackgroundColor3 = Color3.new(1, 1, 1)
            Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)
            
            btn.MouseButton1Click:Connect(function()
                state = not state
                sliderBg.BackgroundColor3 = state and Color3.fromRGB(46, 80, 144) or Color3.fromRGB(54, 69, 79)
                sliderKnob.Position = state and UDim2.new(0.5, 0, 0, 0) or UDim2.new(0, 0, 0, 0)
                pcall(function() callback(state) end)
            end)
            return btn
        end

        function TabData:CreateDropdown(dropName, options, callback)
            local selectedItems = {}
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 45) 
            container.BackgroundColor3 = Color3.fromRGB(36, 45, 53)
            container.ClipsDescendants = true 
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
            Instance.new("UIStroke", container).Color = Color3.fromRGB(46, 80, 144)

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
            valueBox.BackgroundColor3 = Color3.fromRGB(54, 69, 79)
            Instance.new("UICorner", valueBox).CornerRadius = UDim.new(0, 5)

            local selectedText = Instance.new("TextLabel", valueBox)
            selectedText.Size = UDim2.new(1, -15, 1, 0)
            selectedText.Text = "Select..."
            selectedText.TextColor3 = Color3.fromRGB(150, 150, 150)
            selectedText.Font = Enum.Font.Gotham
            selectedText.TextSize = 12
            selectedText.BackgroundTransparency = 1
            selectedText.TextXAlignment = Enum.TextXAlignment.Right

            local listHeight = math.min(#options * 35, 140) 
            local listFrame = Instance.new("ScrollingFrame", container)
            listFrame.Size = UDim2.new(1, 0, 0, listHeight)
            listFrame.Position = UDim2.new(0, 0, 0, 45)
            listFrame.BackgroundTransparency = 1
            listFrame.ScrollBarThickness = 4
            listFrame.CanvasSize = UDim2.new(0, 0, 0, #options * 35)

            local isExpanded = false
            topBar.MouseButton1Click:Connect(function()
                isExpanded = not isExpanded
                local targetHeight = isExpanded and (45 + listHeight) or 45
                TweenService:Create(container, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Size = UDim2.new(0.9, 0, 0, targetHeight)}):Play()
            end)

            for i, opt in ipairs(options) do
                local itemBtn = Instance.new("TextButton", listFrame)
                itemBtn.Size = UDim2.new(1, 0, 0, 35)
                itemBtn.Position = UDim2.new(0, 0, 0, (i-1)*35)
                itemBtn.BackgroundColor3 = Color3.fromRGB(36, 45, 53)
                itemBtn.Text = opt
                itemBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
                itemBtn.Font = Enum.Font.Gotham
                itemBtn.TextSize = 13
                itemBtn.TextXAlignment = Enum.TextXAlignment.Left

                itemBtn.MouseButton1Click:Connect(function()
                    table.insert(selectedItems, opt)
                    selectedText.Text = opt
                    pcall(function() callback(selectedItems) end)
                end)
            end
            return container
        end

        function TabData:CreateDropdownTarget(dropName, options, callback)
            local selectedItem = nil
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 45) 
            container.BackgroundColor3 = Color3.fromRGB(36, 45, 53)
            container.ClipsDescendants = true 
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
            Instance.new("UIStroke", container).Color = Color3.fromRGB(46, 80, 144)

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
            valueBox.BackgroundColor3 = Color3.fromRGB(54, 69, 79)
            Instance.new("UICorner", valueBox).CornerRadius = UDim.new(0, 5)

            local selectedText = Instance.new("TextLabel", valueBox)
            selectedText.Size = UDim2.new(1, -15, 1, 0)
            selectedText.Text = "Select..."
            selectedText.TextColor3 = Color3.fromRGB(150, 150, 150)
            selectedText.Font = Enum.Font.Gotham
            selectedText.TextSize = 12
            selectedText.BackgroundTransparency = 1
            selectedText.TextXAlignment = Enum.TextXAlignment.Right

            local listHeight = math.min(#options * 35, 140) 
            local listFrame = Instance.new("ScrollingFrame", container)
            listFrame.Size = UDim2.new(1, 0, 0, listHeight)
            listFrame.Position = UDim2.new(0, 0, 0, 45)
            listFrame.BackgroundTransparency = 1
            listFrame.ScrollBarThickness = 4
            listFrame.CanvasSize = UDim2.new(0, 0, 0, #options * 35)

            local isExpanded = false
            topBar.MouseButton1Click:Connect(function()
                isExpanded = not isExpanded
                local targetHeight = isExpanded and (45 + listHeight) or 45
                TweenService:Create(container, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Size = UDim2.new(0.9, 0, 0, targetHeight)}):Play()
            end)

            for i, opt in ipairs(options) do
                local itemBtn = Instance.new("TextButton", listFrame)
                itemBtn.Size = UDim2.new(1, 0, 0, 35)
                itemBtn.Position = UDim2.new(0, 0, 0, (i-1)*35)
                itemBtn.BackgroundColor3 = Color3.fromRGB(36, 45, 53)
                itemBtn.Text = opt
                itemBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
                itemBtn.Font = Enum.Font.Gotham
                itemBtn.TextSize = 13
                itemBtn.TextXAlignment = Enum.TextXAlignment.Left

                itemBtn.MouseButton1Click:Connect(function()
                    selectedItem = opt
                    selectedText.Text = opt
                    isExpanded = false
                    TweenService:Create(container, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Size = UDim2.new(0.9, 0, 0, 45)}):Play()
                    pcall(function() callback(selectedItem) end)
                end)
            end
            return container
        end

        function TabData:CreateSlider(sliderName, min, max, callback)
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 60)
            container.BackgroundColor3 = Color3.fromRGB(36, 45, 53)
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
            Instance.new("UIStroke", container).Color = Color3.fromRGB(46, 80, 144)
            
            local title = Instance.new("TextLabel", container)
            title.Size = UDim2.new(0.3, 0, 1, 0)
            title.Position = UDim2.new(0, 15, 0, 0)
            title.Text = sliderName
            title.TextColor3 = Color3.new(1, 1, 1)
            title.Font = Enum.Font.GothamMedium
            title.BackgroundTransparency = 1
            title.TextXAlignment = Enum.TextXAlignment.Left

            local sliderBg = Instance.new("Frame", container)
            sliderBg.Size = UDim2.new(0.4, 0, 0, 6)
            sliderBg.Position = UDim2.new(0, 150, 0.5, -3) 
            sliderBg.BackgroundColor3 = Color3.fromRGB(54, 69, 79)
            Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

            local progress = Instance.new("Frame", sliderBg)
            progress.Size = UDim2.new(1, 0, 1, 0)
            progress.BackgroundColor3 = Color3.fromRGB(46, 80, 144)
            Instance.new("UICorner", progress).CornerRadius = UDim.new(1, 0)

            local sDragging = false
            sliderBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sDragging = true
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sDragging = false
                end
            end)
            return container
        end

        function TabData:CreateKeybind(keyName, defaultKey, callback)
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 45)
            container.BackgroundColor3 = Color3.fromRGB(36, 45, 53)
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
            Instance.new("UIStroke", container).Color = Color3.fromRGB(46, 80, 144)

            local title = Instance.new("TextLabel", container)
            title.Size = UDim2.new(0.5, 0, 1, 0)
            title.Position = UDim2.new(0, 15, 0, 0)
            title.Text = keyName
            title.TextColor3 = Color3.new(1, 1, 1)
            title.Font = Enum.Font.GothamMedium
            title.BackgroundTransparency = 1
            title.TextXAlignment = Enum.TextXAlignment.Left

            local bindBtn = Instance.new("TextButton", container)
            bindBtn.Size = UDim2.new(0, 80, 0, 25)
            bindBtn.Position = UDim2.new(1, -95, 0.5, -12)
            bindBtn.BackgroundColor3 = Color3.fromRGB(54, 69, 79)
            bindBtn.Text = tostring(defaultKey.Name)
            bindBtn.TextColor3 = Color3.new(1, 1, 1)
            bindBtn.Font = Enum.Font.GothamBold
            bindBtn.TextSize = 12
            Instance.new("UICorner", bindBtn).CornerRadius = UDim.new(0, 5)

            return container
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

        function TabData:CreateTextBox(boxName, placeholder, callback)
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 45)
            container.BackgroundColor3 = Color3.fromRGB(36, 45, 53)
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
            Instance.new("UIStroke", container).Color = Color3.fromRGB(46, 80, 144)

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
            inputBox.BackgroundColor3 = Color3.fromRGB(54, 69, 79)
            inputBox.Text = ""
            inputBox.PlaceholderText = placeholder or "Type..."
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