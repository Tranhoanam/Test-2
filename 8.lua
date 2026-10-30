-- =========================================================================
-- NEMOZ UI LIBRARY - NEXT UPDATE (HYPEROS 4 & DRAGON AURA SYSTEM)
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
if not TargetParent then pcall(function() TargetParent = CoreGui end) end
if not TargetParent then TargetParent = Player:WaitForChild("PlayerGui") end

-- Thiết lập màu sắc tiêu chuẩn theo yêu cầu (YInMn Blue #2E5090 & Charcoal Gray #36454F)
local PRIMARY_COLOR = Color3.fromRGB(46, 80, 144)   -- #2E5090
local BG_COLOR = Color3.fromRGB(54, 69, 79)          -- #36454F
local ACCENT_DARK = Color3.fromRGB(24, 26, 32)
local CURRENT_AURA_COLOR = PRIMARY_COLOR

function NemoZLibrary:CreateWindow(config)
    local Window = {
        TabButtons = {},
        TabPages = {},
        AuraElements = {}
    }
    
    local Name = config.Name or "NemoZ Menu"

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

    -- Bottom Layer: Absolute Pitch-Black Background
    local IntroBackground = Instance.new("Frame", IntroGui)
    IntroBackground.Size = UDim2.new(1, 0, 1, 0)
    IntroBackground.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    IntroBackground.BorderSizePixel = 0
    IntroBackground.BackgroundTransparency = 0

    local IntroSound = Instance.new("Sound", IntroGui)
    IntroSound.SoundId = "rbxassetid://125090389445721"
    IntroSound.Volume = 1
    pcall(function() IntroSound:Play() end)

    -- Star Dust Layer (Bụi thời gian nhấp nháy)
    for i = 1, 40 do
        local dust = Instance.new("Frame", IntroBackground)
        dust.Size = UDim2.new(0, math.random(2, 5), 0, math.random(2, 5))
        dust.Position = UDim2.new(math.random(), 0, math.random(), 0)
        dust.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        dust.BorderSizePixel = 0
        Instance.new("UICorner", dust).CornerRadius = UDim.new(1, 0)
        
        task.spawn(function()
            while dust and dust.Parent do
                TweenService:Create(dust, TweenInfo.new(math.random(1, 3), Enum.EasingStyle.Sine), {BackgroundTransparency = math.random(20, 80)/100}):Play()
                task.wait(math.random(1, 3))
            end
        end)
    end

    -- Center Layer: Vòng xoáy khối vuông bo góc màu #2E5090 (Lấy cảm hứng từ reference image)
    local CenterContainer = Instance.new("Frame", IntroBackground)
    CenterContainer.Size = UDim2.new(0, 160, 0, 160)
    CenterContainer.Position = UDim2.new(0.5, -80, 0.5, -110)
    CenterContainer.BackgroundTransparency = 1

    local rotatingSquares = {}
    for i = 1, 12 do
        local sq = Instance.new("Frame", CenterContainer)
        sq.Size = UDim2.new(0, 24, 0, 24)
        sq.AnchorPoint = Vector2.new(0.5, 0.5)
        sq.Position = UDim2.new(0.5, math.cos(i * (math.pi / 6)) * 50, 0.5, math.sin(i * (math.pi / 6)) * 50)
        sq.BackgroundColor3 = PRIMARY_COLOR
        sq.BorderSizePixel = 0
        Instance.new("UICorner", sq).CornerRadius = UDim.new(0, 6)
        table.insert(rotatingSquares, sq)
    end

    task.spawn(function()
        local rot = 0
        while CenterContainer and CenterContainer.Parent do
            rot = rot + 2
            CenterContainer.Rotation = rot
            task.wait(0.03)
        end
    end)

    -- Top Layer: Hiệu ứng gõ chữ tiến triển (N ➔ NE ➔ NEM ➔ NEMo ➔ NEMo-z)
    local IntroTitle = Instance.new("TextLabel", IntroBackground)
    IntroTitle.Size = UDim2.new(1, 0, 0, 80)
    IntroTitle.Position = UDim2.new(0, 0, 0.5, 30)
    IntroTitle.BackgroundTransparency = 1
    IntroTitle.TextColor3 = Color3.fromRGB(230, 240, 255)
    IntroTitle.Font = Enum.Font.GothamBold
    IntroTitle.TextSize = 42
    IntroTitle.TextXAlignment = Enum.TextXAlignment.Center

    task.spawn(function()
        local targetStr = Name ~= "NemoZ Menu" and Name or "NEMo-z"
        local steps = {"N", "NE", "NEM", "NEMo", "NEMo-z"}
        for _, s in ipairs(steps) do
            IntroTitle.Text = s
            task.wait(0.3)
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
                if IntroSound then IntroSound:Stop(); IntroSound:Destroy() end
                if MainWindow then MainWindow.Visible = true end
            end)
        end
    end)

    -- ==========================================
    -- 2. MENU CHÍNH (MAIN WINDOW & 4 GIANT AURA LAYERS)
    -- ==========================================
    local ScreenGui = Instance.new("ScreenGui", TargetParent)
    ScreenGui.Name = "NemoZ_MainOnlyMenu"
    ScreenGui.IgnoreGuiInset = true

    -- 4 Giant Aura Layers bao bọc Main Window (Hiệu ứng hào quang quyền uy)
    for i = 4, 1, -1 do
        local auraLayer = Instance.new("Frame", ScreenGui)
        auraLayer.Size = UDim2.new(0, 500 + (i * 14), 0, 300 + (i * 14))
        auraLayer.Position = UDim2.new(0.5, -250 - (i * 7), 0.5, -150 - (i * 7))
        auraLayer.BackgroundColor3 = PRIMARY_COLOR
        auraLayer.BackgroundTransparency = 0.75 + (i * 0.05)
        auraLayer.BorderSizePixel = 0
        auraLayer.ZIndex = 0
        Instance.new("UICorner", auraLayer).CornerRadius = UDim.new(0, 16 + i)
        table.insert(Window.AuraElements, auraLayer)
    end

    MainWindow = Instance.new("Frame", ScreenGui)
    MainWindow.Size = UDim2.new(0, 500, 0, 300)
    MainWindow.Position = UDim2.new(0.5, -250, 0.5, -150)
    MainWindow.BackgroundColor3 = BG_COLOR
    MainWindow.BorderSizePixel = 0
    MainWindow.Active = true
    MainWindow.Visible = false 
    MainWindow.ZIndex = 2

    Instance.new("UICorner", MainWindow).CornerRadius = UDim.new(0, 15)
    
    local MainStroke = Instance.new("UIStroke", MainWindow)
    MainStroke.Color = PRIMARY_COLOR
    MainStroke.Thickness = 1.5

    -- Dragon Texture / Pattern Overlay (Họa tiết Rồng ẩn tinh tế)
    local DragonOverlay = Instance.new("ImageLabel", MainWindow)
    DragonOverlay.Size = UDim2.new(1, 0, 1, 0)
    DragonOverlay.BackgroundTransparency = 1
    DragonOverlay.Image = "rbxassetid://6031094678"
    DragonOverlay.ImageTransparency = 0.92
    DragonOverlay.ScaleType = Enum.ScaleType.Tile
    DragonOverlay.TileSize = UDim2.new(0, 100, 0, 100)
    DragonOverlay.ZIndex = 1

    -- Header & Controls
    local Header = Instance.new("Frame", MainWindow)
    Header.Size = UDim2.new(1, 0, 0, 80)
    Header.BackgroundColor3 = ACCENT_DARK
    Header.ZIndex = 3
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
            local newPos = UDim2.new(mainStartPos.X.Scale, mainStartPos.X.Offset + delta.X, mainStartPos.Y.Scale, mainStartPos.Y.Offset + delta.Y)
            MainWindow.Position = newPos
            for idx, aura in ipairs(Window.AuraElements) do
                aura.Position = UDim2.new(newPos.X.Scale, newPos.X.Offset - (idx * 7), newPos.Y.Scale, newPos.Y.Offset - (idx * 7))
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
    Title.Size = UDim2.new(0.35, 0, 0.5, 0)
    Title.Position = UDim2.new(0.04, 0, 0, 0)
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.GothamBold
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 4

    -- Stats Button (Smooth Rounded Rectangle thay vì hình pill cũ)
    local StatsButton = Instance.new("TextButton", Header)
    StatsButton.Size = UDim2.new(0, 55, 0, 28)
    StatsButton.Position = UDim2.new(0.56, 0, 0.12, 0)
    StatsButton.Text = "Stats"
    StatsButton.TextColor3 = Color3.new(1, 1, 1)
    StatsButton.Font = Enum.Font.GothamMedium
    StatsButton.TextSize = 12
    StatsButton.BackgroundColor3 = PRIMARY_COLOR
    StatsButton.ZIndex = 4
    Instance.new("UICorner", StatsButton).CornerRadius = UDim.new(0, 8)

    -- Home Button (Nút Home chuyển đến Home Panel cấu hình)
    local HomeButton = Instance.new("TextButton", Header)
    HomeButton.Size = UDim2.new(0, 55, 0, 28)
    HomeButton.Position = UDim2.new(0.68, 0, 0.12, 0)
    HomeButton.Text = "Home"
    HomeButton.TextColor3 = Color3.new(1, 1, 1)
    HomeButton.Font = Enum.Font.GothamMedium
    HomeButton.TextSize = 12
    HomeButton.BackgroundColor3 = Color3.fromRGB(45, 47, 56)
    HomeButton.ZIndex = 4
    Instance.new("UICorner", HomeButton).CornerRadius = UDim.new(0, 8)

    local Close = Instance.new("TextButton", Header)
    Close.Size = UDim2.new(0, 28, 0, 28)
    Close.Position = UDim2.new(0.91, 0, 0.12, 0)
    Close.Text = "×"
    Close.TextColor3 = Color3.new(1, 1, 1)
    Close.Font = Enum.Font.GothamBold
    Close.TextSize = 14
    Close.BackgroundColor3 = Color3.fromRGB(45, 47, 56)
    Close.ZIndex = 4
    Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 8)

    local StatsFrame = Instance.new("Frame", Header)
    StatsFrame.Size = UDim2.new(1, 0, 0.5, 0)
    StatsFrame.Position = UDim2.new(0, 0, 0.5, 0)
    StatsFrame.BackgroundTransparency = 1
    StatsFrame.ZIndex = 4

    local function createStatLabel(posX)
        local lbl = Instance.new("TextLabel", StatsFrame)
        lbl.Size = UDim2.new(0.33, 0, 1, 0)
        lbl.Position = UDim2.new(posX, 0, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Center
        lbl.ZIndex = 4
        return lbl
    end

    local PingLabel = createStatLabel(0)
    local FpsLabel = createStatLabel(0.33)
    local LossLabel = createStatLabel(0.66)

    local Sidebar = Instance.new("ScrollingFrame", MainWindow)
    Sidebar.Size = UDim2.new(0, 130, 1, -80)
    Sidebar.Position = UDim2.new(0, 0, 0, 80)
    Sidebar.BackgroundColor3 = Color3.fromRGB(30, 34, 42)
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 2
    Sidebar.ZIndex = 2
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
    PageContainer.ZIndex = 2

    -- ==========================================
    -- 3. HOME PANEL (EXCLUSIVELY COLORPICKER & SAVE SETTINGS)
    -- ==========================================
    local HomePanel = Instance.new("ScrollingFrame", PageContainer)
    HomePanel.Size = UDim2.new(1, 0, 1, 0)
    HomePanel.BackgroundTransparency = 1
    HomePanel.ScrollBarThickness = 4
    HomePanel.Visible = false
    HomePanel.ZIndex = 3
    
    local hpPadding = Instance.new("UIPadding", HomePanel)
    hpPadding.PaddingTop = UDim.new(0, 20)
    local hpLayout = Instance.new("UIListLayout", HomePanel)
    hpLayout.Padding = UDim.new(0, 15)
    hpLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    hpLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        HomePanel.CanvasSize = UDim2.new(0, 0, 0, hpLayout.AbsoluteContentSize.Y + 40)
    end)

    -- Home Panel ColorPicker (Aura Color Customization)
    local cpContainer = Instance.new("Frame", HomePanel)
    cpContainer.Size = UDim2.new(0.9, 0, 0, 55)
    cpContainer.BackgroundColor3 = ACCENT_DARK
    Instance.new("UICorner", cpContainer).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", cpContainer).Color = PRIMARY_COLOR

    local cpTitle = Instance.new("TextLabel", cpContainer)
    cpTitle.Size = UDim2.new(0.5, 0, 1, 0)
    cpTitle.Position = UDim2.new(0, 15, 0, 0)
    cpTitle.Text = "Aura Color Customizer"
    cpTitle.TextColor3 = Color3.new(1, 1, 1)
    cpTitle.Font = Enum.Font.GothamMedium
    cpTitle.TextSize = 13
    cpTitle.BackgroundTransparency = 1
    cpTitle.TextXAlignment = Enum.TextXAlignment.Left

    local colorBtnBlue = Instance.new("TextButton", cpContainer)
    colorBtnBlue.Size = UDim2.new(0, 30, 0, 30)
    colorBtnBlue.Position = UDim2.new(1, -75, 0.5, -15)
    colorBtnBlue.BackgroundColor3 = Color3.fromRGB(46, 80, 144)
    colorBtnBlue.Text = ""
    Instance.new("UICorner", colorBtnBlue).CornerRadius = UDim.new(1, 0)

    local colorBtnPurple = Instance.new("TextButton", cpContainer)
    colorBtnPurple.Size = UDim2.new(0, 30, 0, 30)
    colorBtnPurple.Position = UDim2.new(1, -35, 0.5, -15)
    colorBtnPurple.BackgroundColor3 = Color3.fromRGB(120, 50, 200)
    colorBtnPurple.Text = ""
    Instance.new("UICorner", colorBtnPurple).CornerRadius = UDim.new(1, 0)

    local function updateAuraColor(newCol)
        CURRENT_AURA_COLOR = newCol
        MainStroke.Color = newCol
        for _, aura in ipairs(Window.AuraElements) do
            aura.BackgroundColor3 = newCol
        end
    end

    colorBtnBlue.MouseButton1Click:Connect(function() updateAuraColor(Color3.fromRGB(46, 80, 144)) end)
    colorBtnPurple.MouseButton1Click:Connect(function() updateAuraColor(Color3.fromRGB(120, 50, 200)) end)

    -- Home Panel Toggle (Save Settings)
    local saveContainer = Instance.new("Frame", HomePanel)
    saveContainer.Size = UDim2.new(0.9, 0, 0, 45)
    saveContainer.BackgroundColor3 = ACCENT_DARK
    Instance.new("UICorner", saveContainer).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", saveContainer).Color = PRIMARY_COLOR

    local saveTitle = Instance.new("TextLabel", saveContainer)
    saveTitle.Size = UDim2.new(0.6, 0, 1, 0)
    saveTitle.Position = UDim2.new(0, 15, 0, 0)
    saveTitle.Text = "Save Configuration State"
    saveTitle.TextColor3 = Color3.new(1, 1, 1)
    saveTitle.Font = Enum.Font.GothamMedium
    saveTitle.TextSize = 13
    saveTitle.BackgroundTransparency = 1
    saveTitle.TextXAlignment = Enum.TextXAlignment.Left

    local saveToggleBg = Instance.new("TextButton", saveContainer)
    saveToggleBg.Size = UDim2.new(0, 50, 0, 25)
    saveToggleBg.Position = UDim2.new(1, -60, 0.5, -12)
    saveToggleBg.BackgroundColor3 = Color3.fromRGB(45, 47, 56)
    saveToggleBg.Text = ""
    Instance.new("UICorner", saveToggleBg).CornerRadius = UDim.new(1, 0)

    local saveToggleKnob = Instance.new("Frame", saveToggleBg)
    saveToggleKnob.Size = UDim2.new(0.5, 0, 1, 0)
    saveToggleKnob.BackgroundColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", saveToggleKnob).CornerRadius = UDim.new(1, 0)

    local savedState = false
    saveToggleBg.MouseButton1Click:Connect(function()
        savedState = not savedState
        saveToggleBg.BackgroundColor3 = savedState and PRIMARY_COLOR or Color3.fromRGB(45, 47, 56)
        saveToggleKnob.Position = savedState and UDim2.new(0.5, 0, 0, 0) or UDim2.new(0, 0, 0, 0)
    end)

    -- ==========================================
    -- 4. MINI MENU THU NHỎ (BẢO TOÀN TUYỆT ĐỐI)
    -- ==========================================
    local MiniScreenGui = Instance.new("ScreenGui", TargetParent)
    MiniScreenGui.Name = "NemoZ_DeltaCustomMiniMenu"
    MiniScreenGui.IgnoreGuiInset = true

    local MiniMainFrame = Instance.new("Frame", MiniScreenGui)
    MiniMainFrame.Name = "MainFrame"
    MiniMainFrame.Size = UDim2.new(0, 135, 0, 40)
    MiniMainFrame.Position = UDim2.new(0.5, -67, 0, 0)
    MiniMainFrame.BackgroundColor3 = ACCENT_DARK
    MiniMainFrame.BorderSizePixel = 0
    MiniMainFrame.Active = true
    MiniMainFrame.ZIndex = 5
    MiniMainFrame.Visible = false

    Instance.new("UICorner", MiniMainFrame).CornerRadius = UDim.new(0, 12)
    local MiniUIStroke = Instance.new("UIStroke", MiniMainFrame)
    MiniUIStroke.Thickness = 1
    MiniUIStroke.Color = Color3.fromRGB(45, 47, 56)
    MiniUIStroke.Transparency = 1

    local MiniTopOverlay = Instance.new("Frame", MiniMainFrame)
    MiniTopOverlay.Size = UDim2.new(1, 0, 0, 12)
    MiniTopOverlay.BackgroundColor3 = ACCENT_DARK
    MiniTopOverlay.BorderSizePixel = 0
    MiniTopOverlay.ZIndex = 6

    local MiniDragButton = Instance.new("ImageButton", MiniMainFrame)
    MiniDragButton.Size = UDim2.new(0, 42, 0, 40)
    MiniDragButton.BackgroundTransparency = 1
    MiniDragButton.Image = "rbxassetid://94225529221725"
    MiniDragButton.ZIndex = 7

    local MiniDivider = Instance.new("Frame", MiniMainFrame)
    MiniDivider.Size = UDim2.new(0, 1, 0, 20)
    MiniDivider.Position = UDim2.new(0, 42, 0, 10)
    MiniDivider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MiniDivider.BackgroundTransparency = 0.8
    MiniDivider.ZIndex = 7

    local MiniOpenButton = Instance.new("TextButton", MiniMainFrame)
    MiniOpenButton.Size = UDim2.new(0, 85, 0, 40)
    MiniOpenButton.Position = UDim2.new(0, 46, 0, 0)
    MiniOpenButton.BackgroundTransparency = 1
    MiniOpenButton.Text = "open"
    MiniOpenButton.TextColor3 = Color3.fromRGB(230, 235, 245)
    MiniOpenButton.TextSize = 15
    MiniOpenButton.Font = Enum.Font.GothamBold
    MiniOpenButton.ZIndex = 7

    local mDragging, mDragStart, mStartPos
    MiniDragButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            mDragging = true; mDragStart = input.Position; mStartPos = MiniMainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if mDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - mDragStart
            MiniMainFrame.Position = UDim2.new(mStartPos.X.Scale, mStartPos.X.Offset + delta.X, mStartPos.Y.Scale, math.max(0, mStartPos.Y.Offset + delta.Y))
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then mDragging = false end
    end)

    Close.MouseButton1Click:Connect(function()
        MainWindow.Visible = false
        HomePanel.Visible = false
        MiniMainFrame.Visible = true
    end)

    MiniOpenButton.MouseButton1Click:Connect(function()
        MainWindow.Visible = true
        HomePanel.Visible = false
        MiniMainFrame.Visible = false
    end)

    HomeButton.MouseButton1Click:Connect(function()
        for _, p in ipairs(Window.TabPages) do p.Visible = false end
        HomePanel.Visible = true
    end)

    local isMini = false
    StatsButton.MouseButton1Click:Connect(function()
        isMini = not isMini
        MainWindow.Size = isMini and UDim2.new(0, 500, 0, 80) or UDim2.new(0, 500, 0, 300)
        Sidebar.Visible = not isMini
        PageContainer.Visible = not isMini
    end)

    -- FPS & Ping Monitoring
    local lastTick = tick()
    local frames = 0
    RunService.RenderStepped:Connect(function()
        frames += 1
        if tick() - lastTick >= 0.5 then
            local fps = math.floor(frames / (tick() - lastTick))
            local success, pingVal = pcall(function() return Player:GetNetworkPing() end)
            local ping = success and math.floor(pingVal * 1000) or 0
            
            FpsLabel.Text = "FPS: " .. fps
            FpsLabel.TextColor3 = (fps < 30) and Color3.fromRGB(255, 50, 50) or PRIMARY_COLOR
            PingLabel.Text = "PING: " .. ping
            PingLabel.TextColor3 = (ping > 100) and Color3.fromRGB(255, 50, 50) or PRIMARY_COLOR
            LossLabel.Text = "LOSS: 0%"
            LossLabel.TextColor3 = PRIMARY_COLOR
            
            lastTick = tick()
            frames = 0
        end
    end)

    -- ==========================================
    -- 5. TAB & COMPONENT SUITE (VỚI HÀO QUANG 3D 2 LỚP)
    -- ==========================================
    function Window:CreateTab(name, imageId)
        local TabData = {}
        
        local tabBtn = Instance.new("TextButton", Sidebar)
        tabBtn.Size = UDim2.new(0.9, 0, 0, 35)
        tabBtn.BackgroundColor3 = Color3.fromRGB(36, 40, 50)
        tabBtn.Text = name
        tabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        tabBtn.Font = Enum.Font.GothamMedium
        tabBtn.TextSize = 12
        Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 8)

        local icon = Instance.new("ImageLabel", tabBtn)
        icon.Size = UDim2.new(0, 16, 0, 16)
        icon.Position = UDim2.new(0, 8, 0.5, -8)
        icon.BackgroundTransparency = 1
        icon.Image = "rbxassetid://" .. tostring(imageId)
        icon.ImageColor3 = Color3.fromRGB(150, 150, 150)

        local page = Instance.new("ScrollingFrame", PageContainer)
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.ScrollBarThickness = 4
        page.Visible = false
        page.ZIndex = 3
        
        local pagePadding = Instance.new("UIPadding", page)
        pagePadding.PaddingTop = UDim.new(0, 20)
        local pageLayout = Instance.new("UIListLayout", page)
        pageLayout.Padding = UDim.new(0, 15)
        pageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

        pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 40)
        end)

        tabBtn.MouseButton1Click:Connect(function()
            HomePanel.Visible = false
            for i, btn in ipairs(Window.TabButtons) do
                btn.BackgroundColor3 = Color3.fromRGB(36, 40, 50)
                btn.TextColor3 = Color3.fromRGB(150, 150, 150)
                if btn:FindFirstChildOfClass("ImageLabel") then
                    btn:FindFirstChildOfClass("ImageLabel").ImageColor3 = Color3.fromRGB(150, 150, 150)
                end
                Window.TabPages[i].Visible = false
            end
            tabBtn.BackgroundColor3 = PRIMARY_COLOR
            tabBtn.TextColor3 = Color3.new(1, 1, 1)
            if icon then icon.ImageColor3 = Color3.new(1, 1, 1) end
            page.Visible = true
        end)

        table.insert(Window.TabButtons, tabBtn)
        table.insert(Window.TabPages, page)

        if #Window.TabButtons == 1 then
            tabBtn.BackgroundColor3 = PRIMARY_COLOR
            tabBtn.TextColor3 = Color3.new(1, 1, 1)
            if icon then icon.ImageColor3 = Color3.new(1, 1, 1) end
            page.Visible = true
        end

        local function applyAuraEffect(parentObj)
            local outerAura = Instance.new("UIStroke", parentObj)
            outerAura.Thickness = 2.5
            outerAura.Transparency = 0.4
            outerAura.Color = PRIMARY_COLOR
        end

        function TabData:CreateSection(sectionName)
            local sec = Instance.new("TextLabel", page)
            sec.Size = UDim2.new(0.9, 0, 0, 25)
            sec.BackgroundTransparency = 1
            sec.Text = "  " .. string.upper(sectionName)
            sec.TextColor3 = Color3.fromRGB(140, 150, 170)
            sec.Font = Enum.Font.GothamBold
            sec.TextSize = 11
            sec.TextXAlignment = Enum.TextXAlignment.Left
            return sec
        end

        function TabData:CreateParagraph(titleText, contentText)
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 65)
            container.BackgroundColor3 = ACCENT_DARK
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
            applyAuraEffect(container)

            local title = Instance.new("TextLabel", container)
            title.Size = UDim2.new(1, -20, 0, 22)
            title.Position = UDim2.new(0, 10, 0, 6)
            title.Text = titleText
            title.TextColor3 = Color3.new(1, 1, 1)
            title.Font = Enum.Font.GothamBold
            title.TextSize = 13
            title.BackgroundTransparency = 1
            title.TextXAlignment = Enum.TextXAlignment.Left

            local desc = Instance.new("TextLabel", container)
            desc.Size = UDim2.new(1, -20, 0, 30)
            desc.Position = UDim2.new(0, 10, 0, 28)
            desc.Text = contentText
            desc.TextColor3 = Color3.fromRGB(170, 175, 185)
            desc.Font = Enum.Font.Gotham
            desc.TextSize = 12
            desc.BackgroundTransparency = 1
            desc.TextWrapped = true
            desc.TextXAlignment = Enum.TextXAlignment.Left
            return container
        end

        function TabData:CreateButton(btnName, callback)
            local btn = Instance.new("TextButton", page)
            btn.Size = UDim2.new(0.9, 0, 0, 45)
            btn.BackgroundColor3 = ACCENT_DARK
            btn.Text = "  " .. btnName
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Font = Enum.Font.GothamMedium
            btn.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
            applyAuraEffect(btn)

            btn.MouseButton1Click:Connect(callback)
            return btn
        end

        function TabData:CreateToggle(toggleName, callback)
            local state = false
            local btn = Instance.new("TextButton", page)
            btn.Size = UDim2.new(0.9, 0, 0, 45)
            btn.BackgroundColor3 = ACCENT_DARK
            btn.Text = "  " .. toggleName 
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Font = Enum.Font.GothamMedium
            btn.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
            applyAuraEffect(btn)
            
            local sliderBg = Instance.new("Frame", btn)
            sliderBg.Size = UDim2.new(0, 45, 0, 24)
            sliderBg.Position = UDim2.new(1, -55, 0.5, -12)
            sliderBg.BackgroundColor3 = Color3.fromRGB(45, 47, 56) 
            Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)
            
            local sliderKnob = Instance.new("Frame", sliderBg)
            sliderKnob.Size = UDim2.new(0.5, 0, 1, 0)
            sliderKnob.BackgroundColor3 = Color3.new(1, 1, 1)
            Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)
            
            btn.MouseButton1Click:Connect(function()
                state = not state
                sliderBg.BackgroundColor3 = state and PRIMARY_COLOR or Color3.fromRGB(45, 47, 56)
                sliderKnob.Position = state and UDim2.new(0.5, 0, 0, 0) or UDim2.new(0, 0, 0, 0)
                pcall(function() callback(state) end)
            end)
            return btn
        end

        function TabData:CreateSlider(sliderName, min, max, callback)
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 55)
            container.BackgroundColor3 = ACCENT_DARK
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
            applyAuraEffect(container)
            
            local title = Instance.new("TextLabel", container)
            title.Size = UDim2.new(0.3, 0, 1, 0)
            title.Position = UDim2.new(0, 15, 0, 0)
            title.Text = sliderName
            title.TextColor3 = Color3.new(1, 1, 1)
            title.Font = Enum.Font.GothamMedium
            title.BackgroundTransparency = 1
            title.TextXAlignment = Enum.TextXAlignment.Left

            local valueBox = Instance.new("TextBox", container)
            valueBox.Size = UDim2.new(0, 40, 0, 26)
            valueBox.Position = UDim2.new(0, 110, 0.5, -13) 
            valueBox.BackgroundColor3 = Color3.fromRGB(35, 38, 48)
            valueBox.Text = tostring(max)
            valueBox.TextColor3 = Color3.new(1, 1, 1)
            valueBox.Font = Enum.Font.GothamBold
            Instance.new("UICorner", valueBox).CornerRadius = UDim.new(0, 6)

            local sliderBg = Instance.new("Frame", container)
            sliderBg.Size = UDim2.new(0.35, 0, 0, 6)
            sliderBg.Position = UDim2.new(0, 165, 0.5, -3) 
            sliderBg.BackgroundColor3 = Color3.fromRGB(45, 47, 56)
            Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

            local progress = Instance.new("Frame", sliderBg)
            progress.Size = UDim2.new(1, 0, 1, 0)
            progress.BackgroundColor3 = PRIMARY_COLOR
            Instance.new("UICorner", progress).CornerRadius = UDim.new(1, 0)

            local knob = Instance.new("Frame", sliderBg)
            knob.AnchorPoint = Vector2.new(0.5, 0.5) 
            knob.Size = UDim2.new(0, 14, 0, 14)
            knob.Position = UDim2.new(1, 0, 0.5, 0)
            knob.BackgroundColor3 = Color3.new(1, 1, 1)
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

            local hitbox = Instance.new("TextButton", sliderBg)
            hitbox.Size = UDim2.new(1, 20, 0, 36)
            hitbox.Position = UDim2.new(0, -10, 0.5, -18)
            hitbox.BackgroundTransparency = 1
            hitbox.Text = ""

            local sDragging = false
            local function updateSlider(inputX)
                local percent = math.clamp((inputX - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + ((max - min) * percent))
                knob.Position = UDim2.new(percent, 0, 0.5, 0)
                progress.Size = UDim2.new(percent, 0, 1, 0)
                valueBox.Text = tostring(val)
                pcall(function() callback(val) end)
            end

            hitbox.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sDragging = true; page.ScrollingEnabled = false; updateSlider(input.Position.X)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if sDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(input.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sDragging = false; page.ScrollingEnabled = true
                end
            end)
        end

        function TabData:CreateKeybind(keyName, defaultKey, callback)
            local boundKey = defaultKey or Enum.KeyCode.F
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 45)
            container.BackgroundColor3 = ACCENT_DARK
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
            applyAuraEffect(container)

            local title = Instance.new("TextLabel", container)
            title.Size = UDim2.new(0.5, 0, 1, 0)
            title.Position = UDim2.new(0, 15, 0, 0)
            title.Text = keyName
            title.TextColor3 = Color3.new(1, 1, 1)
            title.Font = Enum.Font.GothamMedium
            title.BackgroundTransparency = 1
            title.TextXAlignment = Enum.TextXAlignment.Left

            local keyBtn = Instance.new("TextButton", container)
            keyBtn.Size = UDim2.new(0, 75, 0, 26)
            keyBtn.Position = UDim2.new(1, -85, 0.5, -13)
            keyBtn.BackgroundColor3 = Color3.fromRGB(35, 38, 48)
            keyBtn.Text = boundKey.Name
            keyBtn.TextColor3 = PRIMARY_COLOR
            keyBtn.Font = Enum.Font.GothamBold
            keyBtn.TextSize = 12
            Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0, 6)

            local listening = false
            keyBtn.MouseButton1Click:Connect(function()
                listening = true
                keyBtn.Text = "..."
            end)

            UserInputService.InputBegan:Connect(function(input)
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    boundKey = input.KeyCode
                    keyBtn.Text = boundKey.Name
                    listening = false
                    pcall(function() callback(boundKey) end)
                end
            end)
            return container
        end

        function TabData:CreateTextBox(boxName, placeholder, callback)
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 45)
            container.BackgroundColor3 = ACCENT_DARK
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
            applyAuraEffect(container)

            local title = Instance.new("TextLabel", container)
            title.Size = UDim2.new(0.4, 0, 1, 0)
            title.Position = UDim2.new(0, 15, 0, 0)
            title.Text = boxName
            title.TextColor3 = Color3.new(1, 1, 1)
            title.Font = Enum.Font.GothamMedium
            title.BackgroundTransparency = 1
            title.TextXAlignment = Enum.TextXAlignment.Left

            local inputBox = Instance.new("TextBox", container)
            inputBox.Size = UDim2.new(0, 140, 0, 28)
            inputBox.Position = UDim2.new(1, -155, 0.5, -14)
            inputBox.BackgroundColor3 = Color3.fromRGB(35, 38, 48)
            inputBox.Text = ""
            inputBox.PlaceholderText = placeholder or "Type..."
            inputBox.TextColor3 = Color3.new(1, 1, 1)
            inputBox.Font = Enum.Font.Gotham
            inputBox.TextSize = 12
            Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 6)

            inputBox.FocusLost:Connect(function(enterPressed)
                pcall(function() callback(inputBox.Text, enterPressed) end)
            end)
            return container
        end

        function TabData:CreateDropdownTarget(dropName, options, callback)
            local selectedItem = nil
            local itemElements = {}

            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 45) 
            container.BackgroundColor3 = ACCENT_DARK
            container.ClipsDescendants = true 
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
            applyAuraEffect(container)

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
            title.BackgroundTransparency = 1
            title.TextXAlignment = Enum.TextXAlignment.Left

            local valueBox = Instance.new("Frame", topBar)
            valueBox.Size = UDim2.new(0, 110, 0, 26) 
            valueBox.Position = UDim2.new(1, -140, 0.5, -13)
            valueBox.BackgroundColor3 = Color3.fromRGB(35, 38, 48)
            Instance.new("UICorner", valueBox).CornerRadius = UDim.new(0, 6)

            local selectedText = Instance.new("TextLabel", valueBox)
            selectedText.Size = UDim2.new(1, -10, 1, 0)
            selectedText.Position = UDim2.new(0, 0, 0, 0)
            selectedText.Text = "Select..."
            selectedText.TextColor3 = Color3.fromRGB(150, 150, 150)
            selectedText.Font = Enum.Font.Gotham
            selectedText.TextSize = 12
            selectedText.BackgroundTransparency = 1
            selectedText.TextTruncate = Enum.TextTruncate.AtEnd
            selectedText.TextXAlignment = Enum.TextXAlignment.Center

            local listHeight = math.min(#options * 35, 140) 
            local listFrame = Instance.new("ScrollingFrame", container)
            listFrame.Size = UDim2.new(1, 0, 0, listHeight)
            listFrame.Position = UDim2.new(0, 0, 0, 45)
            listFrame.BackgroundTransparency = 1
            listFrame.BorderSizePixel = 0
            listFrame.ScrollBarThickness = 4
            listFrame.CanvasSize = UDim2.new(0, 0, 0, #options * 35)

            local isExpanded = false
            topBar.MouseButton1Click:Connect(function()
                isExpanded = not isExpanded
                TweenService:Create(container, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Size = UDim2.new(0.9, 0, 0, isExpanded and (45 + listHeight) or 45)}):Play()
            end)

            for i, opt in ipairs(options) do
                local itemBtn = Instance.new("TextButton", listFrame)
                itemBtn.Size = UDim2.new(1, 0, 0, 35)
                itemBtn.Position = UDim2.new(0, 0, 0, (i-1)*35)
                itemBtn.BackgroundColor3 = Color3.fromRGB(30, 34, 42)
                itemBtn.Text = opt
                itemBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
                itemBtn.Font = Enum.Font.Gotham
                itemBtn.TextSize = 13
                itemBtn.BorderSizePixel = 0

                itemBtn.MouseButton1Click:Connect(function()
                    selectedItem = opt
                    selectedText.Text = opt
                    selectedText.TextColor3 = Color3.new(1, 1, 1)
                    isExpanded = false
                    TweenService:Create(container, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Size = UDim2.new(0.9, 0, 0, 45)}):Play()
                    pcall(function() callback(selectedItem) end)
                end)
            end
            return container
        end

        return TabData
    end

    return Window
end

return NemoZLibrary