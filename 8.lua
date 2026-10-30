-- =========================================================================
-- NEMOZ UI LIBRARY - BẢN CẬP NHẬT TOÀN DIỆN (HYPEROS 4 & DRAGON STYLE)
-- =========================================================================

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

-- Màu cốt lõi theo tiêu chuẩn (YInMn Blue #2E5090 & Charcoal Gray #36454F)
local COLOR_PRIMARY = Color3.fromRGB(46, 80, 144)
local COLOR_BACKGROUND = Color3.fromRGB(54, 69, 79)
local COLOR_DARK = Color3.fromRGB(18, 19, 23)
local COLOR_CARD = Color3.fromRGB(24, 26, 32)

function NemoZLibrary:CreateWindow(config)
    local Window = {
        TabButtons = {},
        TabPages = {},
        AuraInstances = {},
        CurrentAuraColor = COLOR_PRIMARY
    }
    
    local Name = config.Name or "Nemo-z Menu"

    if TargetParent:FindFirstChild("NemoZ_MainOnlyMenu") then TargetParent["NemoZ_MainOnlyMenu"]:Destroy() end
    if TargetParent:FindFirstChild("NemoZ_DeltaCustomMiniMenu") then TargetParent["NemoZ_DeltaCustomMiniMenu"]:Destroy() end
    if TargetParent:FindFirstChild("NemoZ_IntroScreen") then TargetParent["NemoZ_IntroScreen"]:Destroy() end

    local MainWindow

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

    -- Lớp sao trời (Hạt bụi thời gian)
    for i = 1, 35 do
        local star = Instance.new("Frame", IntroBackground)
        star.Size = UDim2.new(0, math.random(2, 4), 0, math.random(2, 4))
        star.Position = UDim2.new(math.random(), 0, math.random(), 0)
        star.BackgroundColor3 = Color3.new(1, 1, 1)
        star.BackgroundTransparency = math.random(20, 80) / 100
        Instance.new("UICorner", star).CornerRadius = UDim.new(1, 0)
        
        task.spawn(function()
            while star and star.Parent do
                TweenService:Create(star, TweenInfo.new(math.random(10, 20)/10), {BackgroundTransparency = math.random(10, 90)/100}):Play()
                task.Wait(1)
            end
        end)
    end

    -- Lớp trung tâm: Khối vuông góc tròn xoay vòng theo mẫu hình ảnh đính kèm
    local CenterHolder = Instance.new("Frame", IntroBackground)
    CenterHolder.Size = UDim2.new(0, 120, 0, 120)
    CenterHolder.Position = UDim2.new(0.5, -60, 0.35, -60)
    CenterHolder.BackgroundTransparency = 1

    local rotatingSquares = {}
    local numSquares = 12
    for i = 1, numSquares do
        local sq = Instance.new("Frame", CenterHolder)
        sq.Size = UDim2.new(0, 22, 0, 22)
        sq.AnchorPoint = Vector2.new(0.5, 0.5)
        sq.Position = UDim2.new(0.5, 0, 0.5, 0)
        sq.BackgroundColor3 = COLOR_PRIMARY
        Instance.new("UICorner", sq).CornerRadius = UDim.new(0, 6)
        table.insert(rotatingSquares, sq)
    end

    local rotConn
    local angle = 0
    rotConn = RunService.RenderStepped:Connect(function(dt)
        angle = angle + dt * 1.5
        for i, sq in ipairs(rotatingSquares) do
            local rad = angle + (i * (math.pi * 2 / numSquares))
            local dist = 40 + math.sin(angle * 2 + i) * 5
            sq.Position = UDim2.new(0.5, math.cos(rad) * dist, 0.5, math.sin(rad) * dist)
            sq.Rotation = rad * (180 / math.pi)
        end
    end)

    local IntroSound = Instance.new("Sound", IntroGui)
    IntroSound.SoundId = "rbxassetid://125090389445721"
    IntroSound.Volume = 1
    pcall(function() IntroSound:Play() end)

    -- Lớp trên cùng: Text Animation gõ phím (N -> NE -> NEM -> NEMo -> NEMo-z)
    local IntroTitle = Instance.new("TextLabel", IntroBackground)
    IntroTitle.Size = UDim2.new(1, 0, 0, 80)
    IntroTitle.Position = UDim2.new(0, 0, 0.65, 0)
    IntroTitle.BackgroundTransparency = 1
    IntroTitle.TextColor3 = Color3.fromRGB(230, 235, 245)
    IntroTitle.Font = Enum.Font.GothamBold
    IntroTitle.TextSize = 42
    IntroTitle.Text = ""
    IntroTitle.TextXAlignment = Enum.TextXAlignment.Center

    task.spawn(function()
        task.wait(0.8)
        local targetText = "NEMo-z"
        for i = 1, #targetText do
            IntroTitle.Text = string.sub(targetText, 1, i)
            task.wait(0.15)
        end
    end)

    task.delay(5, function()
        if rotConn then rotConn:Disconnect() end
        if IntroBackground and IntroGui then
            local fadeOutBg = TweenService:Create(IntroBackground, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1})
            fadeOutBg:Play()
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
    -- 2. HỆ THỐNG ĐA LỚP AURA HỖ TRỢ
    -- ==========================================
    local function createAuraLayers(parent, count, maxScale, color)
        local layers = {}
        for i = 1, count do
            local aura = Instance.new("Frame", parent.Parent)
            aura.Name = "AuraLayer_" .. i
            aura.AnchorPoint = Vector2.new(0.5, 0.5)
            aura.Position = parent.Position
            aura.Size = parent.Size + UDim2.new(0, i * (maxScale / count) * 8, 0, i * (maxScale / count) * 8)
            aura.BackgroundColor3 = color
            aura.BackgroundTransparency = 0.7 + (i * 0.07)
            aura.ZIndex = parent.ZIndex - 1
            Instance.new("UICorner", aura).CornerRadius = parent:FindFirstChildOfClass("UICorner") and parent:FindFirstChildOfClass("UICorner").CornerRadius or UDim.new(0, 16)
            table.insert(layers, {Instance = aura, BaseTransparency = 0.7 + (i * 0.07)})
        end
        return layers
    end

    -- ==========================================
    -- 3. MENU CHÍNH (MAIN WINDOW)
    -- ==========================================
    local ScreenGui = Instance.new("ScreenGui", TargetParent)
    ScreenGui.Name = "NemoZ_MainOnlyMenu"
    ScreenGui.IgnoreGuiInset = true

    MainWindow = Instance.new("Frame", ScreenGui)
    MainWindow.Size = UDim2.new(0, 540, 0, 340)
    MainWindow.Position = UDim2.new(0.5, -270, 0.5, -170)
    MainWindow.BackgroundColor3 = COLOR_BACKGROUND
    MainWindow.BorderSizePixel = 0
    MainWindow.Active = true
    MainWindow.Visible = false 

    Instance.new("UICorner", MainWindow).CornerRadius = UDim.new(0, 16)
    
    local MainStroke = Instance.new("UIStroke", MainWindow)
    MainStroke.Color = COLOR_PRIMARY
    MainStroke.Thickness = 1.5

    -- 4 lớp aura khổng lồ cho Main Window
    local mainAuras = createAuraLayers(MainWindow, 4, 30, COLOR_PRIMARY)
    table.insert(Window.AuraInstances, {Auras = mainAuras, Type = "Main"})

    -- Họa tiết vải rồng chìm mờ ảo (Dragon Texture Pattern)
    local DragonPattern = Instance.new("ImageLabel", MainWindow)
    DragonPattern.Size = UDim2.new(1, 0, 1, 0)
    DragonPattern.BackgroundTransparency = 1
    DragonPattern.Image = "rbxassetid://6071575925"
    DragonPattern.ImageTransparency = 0.92
    DragonPattern.ScaleType = Enum.ScaleType.Tile
    DragonPattern.TileSize = UDim2.new(0, 100, 0, 100)
    DragonPattern.ZIndex = 1

    -- Header & Quản lý Header (Nút Home, Stats hình chữ nhật góc tròn)
    local Header = Instance.new("Frame", MainWindow)
    Header.Size = UDim2.new(1, 0, 0, 65)
    Header.BackgroundColor3 = COLOR_DARK
    Header.ZIndex = 2
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 16)

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
    Title.Size = UDim2.new(0.3, 0, 1, 0)
    Title.Position = UDim2.new(0.04, 0, 0, 0)
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 3

    -- Nút Home cạnh nút Stats trên Header
    local HomeButton = Instance.new("TextButton", Header)
    HomeButton.Size = UDim2.new(0, 60, 0, 28)
    HomeButton.Position = UDim2.new(0.58, 0, 0.5, -14)
    HomeButton.Text = "Home"
    HomeButton.TextColor3 = Color3.new(1, 1, 1)
    HomeButton.Font = Enum.Font.GothamMedium
    HomeButton.TextSize = 12
    HomeButton.BackgroundColor3 = COLOR_PRIMARY
    HomeButton.ZIndex = 3
    Instance.new("UICorner", HomeButton).CornerRadius = UDim.new(0, 8)

    -- Nút Stats (Hình chữ nhật góc tròn mềm mại)
    local StatsButton = Instance.new("TextButton", Header)
    StatsButton.Size = UDim2.new(0, 60, 0, 28)
    StatsButton.Position = UDim2.new(0.73, 0, 0.5, -14)
    StatsButton.Text = "Stats"
    StatsButton.TextColor3 = Color3.new(1, 1, 1)
    StatsButton.Font = Enum.Font.GothamMedium
    StatsButton.TextSize = 12
    StatsButton.BackgroundColor3 = Color3.fromRGB(45, 47, 56)
    StatsButton.ZIndex = 3
    Instance.new("UICorner", StatsButton).CornerRadius = UDim.new(0, 8)

    local Close = Instance.new("TextButton", Header)
    Close.Size = UDim2.new(0, 28, 0, 28)
    Close.Position = UDim2.new(0.89, 0, 0.5, -14)
    Close.Text = "×"
    Close.TextColor3 = Color3.new(1, 1, 1)
    Close.Font = Enum.Font.GothamBold
    Close.TextSize = 14
    Close.BackgroundColor3 = Color3.fromRGB(45, 47, 56)
    Close.ZIndex = 3
    Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 8)

    local StatsFrame = Instance.new("Frame", Header)
    StatsFrame.Size = UDim2.new(1, 0, 0.5, 0)
    StatsFrame.Position = UDim2.new(0, 0, 0.5, 0)
    StatsFrame.BackgroundTransparency = 1
    StatsFrame.Visible = false
    StatsFrame.ZIndex = 3

    local function createStatLabel(posX)
        local lbl = Instance.new("TextLabel", StatsFrame)
        lbl.Size = UDim2.new(0.33, 0, 1, 0)
        lbl.Position = UDim2.new(posX, 0, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 11
        lbl.TextColor3 = COLOR_PRIMARY
        lbl.TextXAlignment = Enum.TextXAlignment.Center
        lbl.ZIndex = 3
        return lbl
    end

    local PingLabel = createStatLabel(0)
    local FpsLabel = createStatLabel(0.33)
    local LossLabel = createStatLabel(0.66)

    local Sidebar = Instance.new("ScrollingFrame", MainWindow)
    Sidebar.Size = UDim2.new(0, 140, 1, -65)
    Sidebar.Position = UDim2.new(0, 0, 0, 65)
    Sidebar.BackgroundColor3 = COLOR_DARK
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 2
    Sidebar.Active = true
    Sidebar.ZIndex = 2
    Sidebar.ScrollingDirection = Enum.ScrollingDirection.Y
    Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 16)

    local SidebarLayout = Instance.new("UIListLayout", Sidebar)
    SidebarLayout.Padding = UDim.new(0, 6)
    SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local SidebarPadding = Instance.new("UIPadding", Sidebar)
    SidebarPadding.PaddingTop = UDim.new(0, 12)

    local PageContainer = Instance.new("Frame", MainWindow)
    PageContainer.Size = UDim2.new(1, -140, 1, -65)
    PageContainer.Position = UDim2.new(0, 140, 0, 65)
    PageContainer.BackgroundTransparency = 1
    PageContainer.ZIndex = 2

    -- ==========================================
    -- 4. TAB HOME ĐẶC QUYỀN (MÀU SẮC AURA & SAVE SETTINGS)
    -- ==========================================
    local HomeContainer = Instance.new("ScrollingFrame", PageContainer)
    HomeContainer.Size = UDim2.new(1, 0, 1, 0)
    HomeContainer.BackgroundTransparency = 1
    HomeContainer.ScrollBarThickness = 4
    HomeContainer.Visible = false
    HomeContainer.ZIndex = 2
    HomeContainer.CanvasSize = UDim2.new(0, 0, 0, 200)

    local homeLayout = Instance.new("UIListLayout", HomeContainer)
    homeLayout.Padding = UDim.new(0, 15)
    homeLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local homePadding = Instance.new("UIPadding", HomeContainer)
    homePadding.PaddingTop = UDim.new(0, 20)

    local function setupHomeTab()
        local cpContainer = Instance.new("Frame", HomeContainer)
        cpContainer.Size = UDim2.new(0.9, 0, 0, 50)
        cpContainer.BackgroundColor3 = COLOR_CARD
        cpContainer.ZIndex = 3
        Instance.new("UICorner", cpContainer).CornerRadius = UDim.new(0, 10)
        Instance.new("UIStroke", cpContainer).Color = COLOR_PRIMARY

        local cpTitle = Instance.new("TextLabel", cpContainer)
        cpTitle.Size = UDim2.new(0.6, 0, 1, 0)
        cpTitle.Position = UDim2.new(0, 15, 0, 0)
        cpTitle.Text = "Aura Theme Color"
        cpTitle.TextColor3 = Color3.new(1, 1, 1)
        cpTitle.Font = Enum.Font.GothamMedium
        cpTitle.TextSize = 13
        cpTitle.BackgroundTransparency = 1
        cpTitle.TextXAlignment = Enum.TextXAlignment.Left
        cpTitle.ZIndex = 3

        local cpPreview = Instance.new("Frame", cpContainer)
        cpPreview.Size = UDim2.new(0, 35, 0, 25)
        cpPreview.Position = UDim2.new(1, -50, 0.5, -12.5)
        cpPreview.BackgroundColor3 = COLOR_PRIMARY
        cpPreview.ZIndex = 3
        Instance.new("UICorner", cpPreview).CornerRadius = UDim.new(0, 6)

        local tgContainer = Instance.new("Frame", HomeContainer)
        tgContainer.Size = UDim2.new(0.9, 0, 0, 50)
        tgContainer.BackgroundColor3 = COLOR_CARD
        tgContainer.ZIndex = 3
        Instance.new("UICorner", tgContainer).CornerRadius = UDim.new(0, 10)
        Instance.new("UIStroke", tgContainer).Color = COLOR_PRIMARY

        local tgTitle = Instance.new("TextLabel", tgContainer)
        tgTitle.Size = UDim2.new(0.6, 0, 1, 0)
        tgTitle.Position = UDim2.new(0, 15, 0, 0)
        tgTitle.Text = "Auto Save Settings"
        tgTitle.TextColor3 = Color3.new(1, 1, 1)
        tgTitle.Font = Enum.Font.GothamMedium
        tgTitle.TextSize = 13
        tgTitle.BackgroundTransparency = 1
        tgTitle.TextXAlignment = Enum.TextXAlignment.Left
        tgTitle.ZIndex = 3

        local sliderBg = Instance.new("Frame", tgContainer)
        sliderBg.Size = UDim2.new(0, 45, 0, 22)
        sliderBg.Position = UDim2.new(1, -60, 0.5, -11)
        sliderBg.BackgroundColor3 = COLOR_PRIMARY
        sliderBg.ZIndex = 3
        Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

        local sliderKnob = Instance.new("Frame", sliderBg)
        sliderKnob.Size = UDim2.new(0.5, 0, 1, 0)
        sliderKnob.Position = UDim2.new(0.5, 0, 0, 0)
        sliderKnob.BackgroundColor3 = Color3.new(1, 1, 1)
        sliderKnob.ZIndex = 3
        Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)
    end
    setupHomeTab()

    HomeButton.MouseButton1Click:Connect(function()
        for _, page in ipairs(Window.TabPages) do page.Visible = false end
        for _, btn in ipairs(Window.TabButtons) do btn.BackgroundColor3 = COLOR_CARD end
        HomeContainer.Visible = true
        HomeButton.BackgroundColor3 = COLOR_PRIMARY
    end)

    -- ==========================================
    -- 5. MINI MENU CỐ ĐỊNH (NEMOZ_DELTACUSTOMMINIMENU)
    -- ==========================================
    local MiniScreenGui = Instance.new("ScreenGui", TargetParent)
    MiniScreenGui.Name = "NemoZ_DeltaCustomMiniMenu"
    MiniScreenGui.IgnoreGuiInset = true

    local MiniMainFrame = Instance.new("Frame", MiniScreenGui)
    MiniMainFrame.Name = "MainFrame"
    MiniMainFrame.Size = UDim2.new(0, 135, 0, 40)
    MiniMainFrame.Position = UDim2.new(0.5, -67, 0, 0)
    MiniMainFrame.BackgroundColor3 = COLOR_DARK
    MiniMainFrame.BorderSizePixel = 0
    MiniMainFrame.Active = true
    MiniMainFrame.ZIndex = 5
    MiniMainFrame.Visible = false

    local MiniUICorner = Instance.new("UICorner", MiniMainFrame)
    MiniUICorner.CornerRadius = UDim.new(0, 12)

    local MiniUIStroke = Instance.new("UIStroke", MiniMainFrame)
    MiniUIStroke.Thickness = 1
    MiniUIStroke.Color = COLOR_PRIMARY
    MiniUIStroke.Transparency = 0.5

    local MiniTopOverlay = Instance.new("Frame", MiniMainFrame)
    MiniTopOverlay.Name = "TopOverlay"
    MiniTopOverlay.Size = UDim2.new(1, 0, 0, 12)
    MiniTopOverlay.Position = UDim2.new(0, 0, 0, 0)
    MiniTopOverlay.BackgroundColor3 = COLOR_DARK
    MiniTopOverlay.BorderSizePixel = 0
    MiniTopOverlay.ZIndex = 6

    local MiniDragButton = Instance.new("ImageButton", MiniMainFrame)
    MiniDragButton.Name = "DragButton"
    MiniDragButton.Size = UDim2.new(0, 42, 0, 40)
    MiniDragButton.BackgroundTransparency = 1
    MiniDragButton.Image = "rbxassetid://94225529221725"
    MiniDragButton.ZIndex = 7

    local MiniDivider = Instance.new("Frame", MiniMainFrame)
    MiniDivider.Name = "Divider"
    MiniDivider.Size = UDim2.new(0, 1, 0, 20)
    MiniDivider.Position = UDim2.new(0, 42, 0, 10)
    MiniDivider.BackgroundColor3 = Color3.new(1, 1, 1)
    MiniDivider.BackgroundTransparency = 0.8
    MiniDivider.ZIndex = 7

    local MiniOpenButton = Instance.new("TextButton", MiniMainFrame)
    MiniOpenButton.Name = "OpenButton"
    MiniOpenButton.Size = UDim2.new(0, 85, 0, 40)
    MiniOpenButton.Position = UDim2.new(0, 46, 0, 0)
    MiniOpenButton.BackgroundTransparency = 1
    MiniOpenButton.Text = "open"
    MiniOpenButton.TextColor3 = Color3.fromRGB(230, 235, 245)
    MiniOpenButton.TextSize = 14
    MiniOpenButton.Font = Enum.Font.GothamBold
    MiniOpenButton.ZIndex = 7

    local draggingMini, dragInputMini, dragStartMini, startPosMini
    MiniDragButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingMini = true
            dragStartMini = input.Position
            startPosMini = MiniMainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if draggingMini and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStartMini
            MiniMainFrame.Position = UDim2.new(startPosMini.X.Scale, startPosMini.X.Offset + delta.X, startPosMini.Y.Scale, startPosMini.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingMini = false
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

    local isMiniStats = false
    StatsButton.MouseButton1Click:Connect(function()
        isMiniStats = not isMiniStats
        StatsFrame.Visible = isMiniStats
        MainWindow.Size = isMiniStats and UDim2.new(0, 540, 0, 95) or UDim2.new(0, 540, 0, 340)
        Sidebar.Visible = not isMiniStats
        PageContainer.Visible = not isMiniStats
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
            PingLabel.Text = "PING: " .. ping
            LossLabel.Text = "LOSS: 0%"
            lastTick = tick()
            frames = 0
        end
    end)

    -- ==========================================
    -- 6. TẠO TAB & CÁC THÀNH PHẦN CREATE CHUẨN
    -- ==========================================
    function Window:CreateTab(name, imageId)
        local TabData = {}
        
        local tabBtn = Instance.new("TextButton", Sidebar)
        tabBtn.Size = UDim2.new(0.9, 0, 0, 35)
        tabBtn.BackgroundColor3 = COLOR_CARD
        tabBtn.Text = "    " .. name
        tabBtn.TextColor3 = Color3.fromRGB(160, 165, 175)
        tabBtn.Font = Enum.Font.GothamMedium
        tabBtn.TextSize = 12
        tabBtn.ZIndex = 2
        tabBtn.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 8)

        if imageId then
            local icon = Instance.new("ImageLabel", tabBtn)
            icon.Size = UDim2.new(0, 16, 0, 16)
            icon.Position = UDim2.new(0, 10, 0.5, -8)
            icon.BackgroundTransparency = 1
            icon.Image = "rbxassetid://" .. tostring(imageId)
            icon.ImageColor3 = Color3.fromRGB(160, 165, 175)
            icon.ZIndex = 2
        end

        local page = Instance.new("ScrollingFrame", PageContainer)
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.ScrollBarThickness = 4
        page.Visible = false
        page.ZIndex = 2
        page.ScrollingDirection = Enum.ScrollingDirection.Y
        
        local pagePadding = Instance.new("UIPadding", page)
        pagePadding.PaddingTop = UDim.new(0, 15)
        
        local pageLayout = Instance.new("UIListLayout", page)
        pageLayout.Padding = UDim.new(0, 12)
        pageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        pageLayout.SortOrder = Enum.SortOrder.LayoutOrder

        pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 30)
        end)

        tabBtn.MouseButton1Click:Connect(function()
            for i, btn in ipairs(Window.TabButtons) do
                btn.BackgroundColor3 = COLOR_CARD
                btn.TextColor3 = Color3.fromRGB(160, 165, 175)
                Window.TabPages[i].Visible = false
            end
            HomeContainer.Visible = false
            HomeButton.BackgroundColor3 = COLOR_CARD
            tabBtn.BackgroundColor3 = COLOR_PRIMARY
            tabBtn.TextColor3 = Color3.new(1, 1, 1)
            page.Visible = true
        end)

        table.insert(Window.TabButtons, tabBtn)
        table.insert(Window.TabPages, page)

        if #Window.TabButtons == 1 then
            tabBtn.BackgroundColor3 = COLOR_PRIMARY
            tabBtn.TextColor3 = Color3.new(1, 1, 1)
            page.Visible = true
        end

        local function addAuraToElement(element)
            local auras = createAuraLayers(element, 2, 12, COLOR_PRIMARY)
            table.insert(Window.AuraInstances, {Auras = auras, Type = "Element"})
        end

        function TabData:CreateSection(secName)
            local sec = Instance.new("TextLabel", page)
            sec.Size = UDim2.new(0.9, 0, 0, 25)
            sec.BackgroundTransparency = 1
            sec.Text = secName
            sec.TextColor3 = COLOR_PRIMARY
            sec.Font = Enum.Font.GothamBold
            sec.TextSize = 13
            sec.ZIndex = 2
            sec.TextXAlignment = Enum.TextXAlignment.Left
            return sec
        end

        function TabData:CreateParagraph(paraTitle, paraContent)
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 60)
            container.BackgroundColor3 = COLOR_CARD
            container.ZIndex = 2
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
            Instance.new("UIStroke", container).Color = COLOR_PRIMARY
            addAuraToElement(container)

            local title = Instance.new("TextLabel", container)
            title.Size = UDim2.new(1, -20, 0, 20)
            title.Position = UDim2.new(0, 10, 0, 8)
            title.Text = paraTitle
            title.TextColor3 = Color3.new(1, 1, 1)
            title.Font = Enum.Font.GothamBold
            title.TextSize = 13
            title.ZIndex = 2
            title.BackgroundTransparency = 1
            title.TextXAlignment = Enum.TextXAlignment.Left

            local content = Instance.new("TextLabel", container)
            content.Size = UDim2.new(1, -20, 0, 25)
            content.Position = UDim2.new(0, 10, 0, 28)
            content.Text = paraContent
            content.TextColor3 = Color3.fromRGB(180, 185, 195)
            content.Font = Enum.Font.Gotham
            content.TextSize = 12
            content.ZIndex = 2
            content.BackgroundTransparency = 1
            content.TextXAlignment = Enum.TextXAlignment.Left
            content.TextWrapped = true
            return container
        end

        function TabData:CreateButton(btnName, callback)
            local btn = Instance.new("TextButton", page)
            btn.Size = UDim2.new(0.9, 0, 0, 45)
            btn.BackgroundColor3 = COLOR_CARD
            btn.Text = "  " .. btnName
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Font = Enum.Font.GothamMedium
            btn.ZIndex = 2
            btn.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
            Instance.new("UIStroke", btn).Color = COLOR_PRIMARY
            addAuraToElement(btn)

            btn.MouseButton1Click:Connect(callback)
            return btn
        end

        function TabData:CreateToggle(toggleName, callback)
            local state = false
            local btn = Instance.new("TextButton", page)
            btn.Size = UDim2.new(0.9, 0, 0, 45)
            btn.BackgroundColor3 = COLOR_CARD
            btn.Text = "  " .. toggleName 
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Font = Enum.Font.GothamMedium
            btn.ZIndex = 2
            btn.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
            Instance.new("UIStroke", btn).Color = COLOR_PRIMARY
            addAuraToElement(btn)
            
            local sliderBg = Instance.new("Frame", btn)
            sliderBg.Size = UDim2.new(0, 45, 0, 22)
            sliderBg.Position = UDim2.new(1, -55, 0.5, -11)
            sliderBg.BackgroundColor3 = COLOR_BACKGROUND
            sliderBg.ZIndex = 2
            Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)
            
            local sliderKnob = Instance.new("Frame", sliderBg)
            sliderKnob.Size = UDim2.new(0.5, 0, 1, 0)
            sliderKnob.BackgroundColor3 = Color3.new(1, 1, 1)
            sliderKnob.ZIndex = 2
            Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)
            
            btn.MouseButton1Click:Connect(function()
                state = not state
                sliderBg.BackgroundColor3 = state and COLOR_PRIMARY or COLOR_BACKGROUND
                sliderKnob.Position = state and UDim2.new(0.5, 0, 0, 0) or UDim2.new(0, 0, 0, 0)
                pcall(function() callback(state) end)
            end)
            return btn
        end

        function TabData:CreateSlider(sliderName, min, max, callback)
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 55)
            container.BackgroundColor3 = COLOR_CARD
            container.ZIndex = 2
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
            Instance.new("UIStroke", container).Color = COLOR_PRIMARY
            addAuraToElement(container)
            
            local title = Instance.new("TextLabel", container)
            title.Size = UDim2.new(0.4, 0, 1, 0)
            title.Position = UDim2.new(0, 15, 0, 0)
            title.Text = sliderName
            title.TextColor3 = Color3.new(1, 1, 1)
            title.Font = Enum.Font.GothamMedium
            title.ZIndex = 2
            title.BackgroundTransparency = 1
            title.TextXAlignment = Enum.TextXAlignment.Left

            local valueBox = Instance.new("TextBox", container)
            valueBox.Size = UDim2.new(0, 45, 0, 26)
            valueBox.Position = UDim2.new(0, 120, 0.5, -13) 
            valueBox.BackgroundColor3 = COLOR_BACKGROUND
            valueBox.Text = tostring(max)
            valueBox.TextColor3 = Color3.new(1, 1, 1)
            valueBox.Font = Enum.Font.GothamBold
            valueBox.ZIndex = 2
            Instance.new("UICorner", valueBox).CornerRadius = UDim.new(0, 6)

            local sliderBg = Instance.new("Frame", container)
            sliderBg.Size = UDim2.new(0.35, 0, 0, 6)
            sliderBg.Position = UDim2.new(0, 180, 0.5, -3) 
            sliderBg.BackgroundColor3 = COLOR_BACKGROUND
            sliderBg.ZIndex = 2
            Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

            local progress = Instance.new("Frame", sliderBg)
            progress.Size = UDim2.new(1, 0, 1, 0)
            progress.BackgroundColor3 = COLOR_PRIMARY
            progress.ZIndex = 2
            Instance.new("UICorner", progress).CornerRadius = UDim.new(1, 0)

            local knob = Instance.new("Frame", sliderBg)
            knob.AnchorPoint = Vector2.new(0.5, 0.5) 
            knob.Size = UDim2.new(0, 16, 0, 16)
            knob.Position = UDim2.new(1, 0, 0.5, 0)
            knob.BackgroundColor3 = Color3.new(1, 1, 1)
            knob.ZIndex = 3
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

            local hitbox = Instance.new("TextButton", sliderBg)
            hitbox.AnchorPoint = Vector2.new(0.5, 0.5)
            hitbox.Size = UDim2.new(1, 20, 0, 30) 
            hitbox.Position = UDim2.new(0.5, 0, 0.5, 0)
            hitbox.BackgroundTransparency = 1
            hitbox.Text = ""
            hitbox.ZIndex = 4

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
            return container
        end

        function TabData:CreateColorPicker(colorName, defaultColor, callback)
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 45)
            container.BackgroundColor3 = COLOR_CARD
            container.ZIndex = 2
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
            Instance.new("UIStroke", container).Color = COLOR_PRIMARY
            addAuraToElement(container)

            local title = Instance.new("TextLabel", container)
            title.Size = UDim2.new(0.6, 0, 1, 0)
            title.Position = UDim2.new(0, 15, 0, 0)
            title.Text = colorName
            title.TextColor3 = Color3.new(1, 1, 1)
            title.Font = Enum.Font.GothamMedium
            title.TextSize = 13
            title.ZIndex = 2
            title.BackgroundTransparency = 1
            title.TextXAlignment = Enum.TextXAlignment.Left

            local preview = Instance.new("Frame", container)
            preview.Size = UDim2.new(0, 35, 0, 25)
            preview.Position = UDim2.new(1, -50, 0.5, -12.5)
            preview.BackgroundColor3 = defaultColor or COLOR_PRIMARY
            preview.ZIndex = 2
            Instance.new("UICorner", preview).CornerRadius = UDim.new(0, 6)
            return container
        end

        function TabData:CreateKeybind(keybindName, defaultKey, callback)
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 45)
            container.BackgroundColor3 = COLOR_CARD
            container.ZIndex = 2
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
            Instance.new("UIStroke", container).Color = COLOR_PRIMARY
            addAuraToElement(container)

            local title = Instance.new("TextLabel", container)
            title.Size = UDim2.new(0.6, 0, 1, 0)
            title.Position = UDim2.new(0, 15, 0, 0)
            title.Text = keybindName
            title.TextColor3 = Color3.new(1, 1, 1)
            title.Font = Enum.Font.GothamMedium
            title.TextSize = 13
            title.ZIndex = 2
            title.BackgroundTransparency = 1
            title.TextXAlignment = Enum.TextXAlignment.Left

            local keyButton = Instance.new("TextButton", container)
            keyButton.Size = UDim2.new(0, 70, 0, 26)
            keyButton.Position = UDim2.new(1, -85, 0.5, -13)
            keyButton.BackgroundColor3 = COLOR_BACKGROUND
            keyButton.Text = tostring(defaultKey or Enum.KeyCode.F):match(".+%.(.+)")
            keyButton.TextColor3 = Color3.new(1, 1, 1)
            keyButton.Font = Enum.Font.GothamBold
            keyButton.TextSize = 12
            keyButton.ZIndex = 2
            Instance.new("UICorner", keyButton).CornerRadius = UDim.new(0, 6)
            return container
        end

        function TabData:CreateDropdown(dropName, options, callback)
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 45) 
            container.BackgroundColor3 = COLOR_CARD
            container.ClipsDescendants = true 
            container.ZIndex = 2
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
            Instance.new("UIStroke", container).Color = COLOR_PRIMARY
            addAuraToElement(container)

            local topBar = Instance.new("TextButton", container)
            topBar.Size = UDim2.new(1, 0, 0, 45)
            topBar.BackgroundTransparency = 1
            topBar.Text = ""
            topBar.ZIndex = 2

            local title = Instance.new("TextLabel", topBar)
            title.Size = UDim2.new(0.4, 0, 1, 0)
            title.Position = UDim2.new(0, 15, 0, 0)
            title.Text = dropName
            title.TextColor3 = Color3.new(1, 1, 1)
            title.Font = Enum.Font.GothamMedium
            title.ZIndex = 2
            title.BackgroundTransparency = 1
            title.TextXAlignment = Enum.TextXAlignment.Left

            local isExpanded = false
            topBar.MouseButton1Click:Connect(function()
                isExpanded = not isExpanded
                local targetHeight = isExpanded and (45 + math.min(#options * 32, 130)) or 45
                TweenService:Create(container, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Size = UDim2.new(0.9, 0, 0, targetHeight)}):Play()
            end)
            return container
        end

        function TabData:CreateDropdownTarget(dropName, options, callback)
            return TabData:CreateDropdown(dropName, options, callback)
        end

        function TabData:CreateTextBox(boxName, placeholder, callback)
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 45)
            container.BackgroundColor3 = COLOR_CARD
            container.ZIndex = 2
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
            Instance.new("UIStroke", container).Color = COLOR_PRIMARY
            addAuraToElement(container)

            local title = Instance.new("TextLabel", container)
            title.Size = UDim2.new(0.4, 0, 1, 0)
            title.Position = UDim2.new(0, 15, 0, 0)
            title.Text = boxName
            title.TextColor3 = Color3.new(1, 1, 1)
            title.Font = Enum.Font.GothamMedium
            title.ZIndex = 2
            title.BackgroundTransparency = 1
            title.TextXAlignment = Enum.TextXAlignment.Left

            local inputBox = Instance.new("TextBox", container)
            inputBox.Size = UDim2.new(0, 140, 0, 28)
            inputBox.Position = UDim2.new(1, -155, 0.5, -14)
            inputBox.BackgroundColor3 = COLOR_BACKGROUND
            inputBox.PlaceholderText = placeholder or "Type..."
            inputBox.TextColor3 = Color3.new(1, 1, 1)
            inputBox.Font = Enum.Font.Gotham
            inputBox.TextSize = 12
            inputBox.ZIndex = 2
            Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 6)

            inputBox.FocusLost:Connect(function(enter)
                pcall(function() callback(inputBox.Text, enter) end)
            end)
            return container
        end

        return TabData
    end

    return Window
end

return NemoZLibrary