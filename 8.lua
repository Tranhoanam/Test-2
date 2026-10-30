-- =========================================================================
-- NEMOZ UI LIBRARY - HYPEROS 4 & DRAGON TIME EDITION (VERSION 2.0)
-- TỐI ƯU HÓA ĐỒ HỌA 60 FPS, ĐA LỚP AURA, HOME PANEL & FULL CREATE FUNCTIONS
-- =========================================================================

local NemoZLibrary = {}

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer

-- Xác định vị trí lưu trữ GUI an toàn (Hỗ trợ gethui() cho các executor phổ biến như Delta)
local TargetParent = nil
pcall(function() TargetParent = gethui() end)
if not TargetParent then
    pcall(function() TargetParent = CoreGui end)
end
if not TargetParent then TargetParent = Player:WaitForChild("PlayerGui") end

-- Hàm hỗ trợ tạo Bo Góc (UICorner) mượt mà (12px đến 22px theo tiêu chuẩn)
local function applyCorner(parent, radius)
    local corner = Instance.new("UICorner", parent)
    corner.CornerRadius = UDim.new(0, radius or 14)
    return corner
end

-- Hàm hỗ trợ tạo hệ thống đa lớp Aura (Nhiều lớp bọc lót, lớp ngoài mờ dần)
local function applyMultiLayerAura(parent, baseColor, layersCount)
    layersCount = layersCount or 3
    local auras = {}
    for i = 1, layersCount do
        local auraStroke = Instance.new("UIStroke", parent)
        auraStroke.Color = baseColor or Color3.fromRGB(46, 80, 144) -- #2E5090
        auraStroke.Thickness = 1.5 + (i * 1.2)
        auraStroke.Transparency = 0.3 + (i * 0.2)
        table.insert(auras, auraStroke)
    end
    return auras
end

-- =========================================================================
-- HÀM KHỞI TẠO WINDOW CHÍNH
-- =========================================================================
function NemoZLibrary:CreateWindow(config)
    local Window = {
        TabButtons = {},
        TabPages = {},
        CurrentAuraColor = Color3.fromRGB(46, 80, 144) -- #2E5090 YInMn Blue
    }
    
    local Name = config.Name or "NemoZ Menu"

    -- Dọn dẹp các GUI cũ tránh trùng lặp
    if TargetParent:FindFirstChild("NemoZ_MainOnlyMenu") then TargetParent["NemoZ_MainOnlyMenu"]:Destroy() end
    if TargetParent:FindFirstChild("NemoZ_DeltaCustomMiniMenu") then TargetParent["NemoZ_DeltaCustomMiniMenu"]:Destroy() end
    if TargetParent:FindFirstChild("NemoZ_IntroScreen") then TargetParent["NemoZ_IntroScreen"]:Destroy() end

    local MainWindow
    local HomePanelFrame

    -- =====================================================================
    -- 1. MÀN HÌNH MỞ ĐẦU (INTRO SCREEN - 5 GIÂY & VÒNG XOÁY RỒNG THỜI GIAN)
    -- =====================================================================
    local IntroGui = Instance.new("ScreenGui", TargetParent)
    IntroGui.Name = "NemoZ_IntroScreen"
    IntroGui.IgnoreGuiInset = true
    IntroGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local IntroBackground = Instance.new("Frame", IntroGui)
    IntroBackground.Size = UDim2.new(1, 0, 1, 0)
    IntroBackground.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    IntroBackground.BorderSizePixel = 0
    IntroBackground.BackgroundTransparency = 0

    -- Hiệu ứng lớp sao trời / hạt bụi thời gian
    for i = 1, 35 do
        local star = Instance.new("Frame", IntroBackground)
        star.Size = UDim2.new(0, math.random(2, 4), 0, math.random(2, 4))
        star.Position = UDim2.new(math.random(), 0, math.random(), 0)
        star.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        star.BackgroundTransparency = math.random(3, 8) / 10
        applyCorner(star, 2)
    end

    local IntroSound = Instance.new("Sound", IntroGui)
    IntroSound.SoundId = "rbxassetid://125090389445721"
    IntroSound.Volume = 1
    pcall(function() IntroSound:Play() end)

    -- Khối trung tâm: Vòng xoáy các ô vuông bo tròn mô phỏng chuẩn mẫu ảnh
    local VortexContainer = Instance.new("Frame", IntroBackground)
    VortexContainer.Size = UDim2.new(0, 160, 0, 160)
    VortexContainer.Position = UDim2.new(0.5, -80, 0.5, -95)
    VortexContainer.BackgroundTransparency = 1

    local vortexParts = {}
    local totalVortexBlocks = 16
    for i = 1, totalVortexBlocks do
        local block = Instance.new("Frame", VortexContainer)
        block.Size = UDim2.new(0, 22, 0, 22)
        block.AnchorPoint = Vector2.new(0.5, 0.5)
        block.Position = UDim2.new(0.5, 0, 0.5, 0)
        block.BackgroundColor3 = Color3.fromRGB(46, 80, 144) -- #2E5090
        block.BorderSizePixel = 0
        applyCorner(block, 6)
        table.insert(vortexParts, block)
    end

    -- Animation xoay vòng vòng xoáy 60 FPS mượt mà
    local vortexConnection
    local angleVal = 0
    vortexConnection = RunService.RenderStepped:Connect(function(dt)
        angleVal = angleVal + (dt * 2.5)
        local radius = 45
        for index, block in ipairs(vortexParts) do
            local rad = angleVal + ((index / totalVortexBlocks) * (math.pi * 2))
            local x = math.cos(rad) * (radius + (index * 0.8))
            local y = math.sin(rad) * (radius + (index * 0.8))
            block.Position = UDim2.new(0.5, x, 0.5, y)
            block.Rotation = angleVal * 50 + (index * 15)
        end
    end)

    -- Tiêu đề hiệu ứng gõ phím / hiển thị ký tự chậm rãi
    local IntroTitle = Instance.new("TextLabel", IntroBackground)
    IntroTitle.Size = UDim2.new(1, 0, 0, 60)
    IntroTitle.Position = UDim2.new(0, 0, 0.5, 45)
    IntroTitle.BackgroundTransparency = 1
    IntroTitle.Text = ""
    IntroTitle.TextColor3 = Color3.fromRGB(80, 150, 255)
    IntroTitle.Font = Enum.Font.GothamBold
    IntroTitle.TextSize = 32
    IntroTitle.TextXAlignment = Enum.TextXAlignment.Center

    -- Chuỗi gõ phím ký tự thời gian
    task.spawn(function()
        task.wait(0.8)
        local textSequence = {"N", "NE", "NEM", "NEMo", "NEMo-z", "NEMo-z UI", "NEMo-z UI Library"}
        for _, txt in ipairs(textSequence) do
            if IntroTitle and IntroTitle.Parent then
                IntroTitle.Text = txt
                task.wait(0.2)
            end
        end
    end)

    task.delay(5, function()
        if vortexConnection then vortexConnection:Disconnect() end
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

    -- =====================================================================
    -- 2. MENU CHÍNH (MAIN WINDOW) & ĐA TẦNG AURA KHỔNG LỒ
    -- =====================================================================
    local ScreenGui = Instance.new("ScreenGui", TargetParent)
    ScreenGui.Name = "NemoZ_MainOnlyMenu"
    ScreenGui.IgnoreGuiInset = true

    MainWindow = Instance.new("Frame", ScreenGui)
    MainWindow.Size = UDim2.new(0, 520, 0, 320)
    MainWindow.Position = UDim2.new(0.5, -260, 0.5, -160)
    MainWindow.BackgroundColor3 = Color3.fromRGB(54, 69, 79) -- #36454F Charcoal Gray
    MainWindow.BorderSizePixel = 0
    MainWindow.Active = true
    MainWindow.Draggable = false
    MainWindow.Visible = false 

    applyCorner(MainWindow, 18)
    
    -- Hệ thống đa lớp aura khổng lồ bọc lót xung quanh khung chính
    local mainAuras = applyMultiLayerAura(MainWindow, Color3.fromRGB(46, 80, 144), 4)

    -- Họa tiết chìm mờ ảo phong cách vải rồng (Dragon Texture Pattern mô phỏng bằng các đường line ẩn)
    local DragonPatternOverlay = Instance.new("Frame", MainWindow)
    DragonPatternOverlay.Size = UDim2.new(1, 0, 1, 0)
    DragonPatternOverlay.BackgroundTransparency = 0.95
    DragonPatternOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    DragonPatternOverlay.BorderSizePixel = 0
    applyCorner(DragonPatternOverlay, 18)

    local mainDragging, mainDragStart, mainStartPos

    -- Header & Stats & Home Button
    local Header = Instance.new("Frame", MainWindow)
    Header.Size = UDim2.new(1, 0, 0, 75)
    Header.BackgroundColor3 = Color3.fromRGB(24, 26, 32)
    applyCorner(Header, 16)

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
    Title.Size = UDim2.new(0.35, 0, 0.5, 0)
    Title.Position = UDim2.new(0.04, 0, 0, 0)
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.GothamBold
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left

    -- Nút Home mới đặt ngay bên cạnh nút Stats trên Header
    local HomeButton = Instance.new("TextButton", Header)
    HomeButton.Size = UDim2.new(0, 55, 0, 28)
    HomeButton.Position = UDim2.new(0.58, 0, 0.12, 0)
    HomeButton.Text = "Home"
    HomeButton.TextColor3 = Color3.new(1, 1, 1)
    HomeButton.Font = Enum.Font.GothamMedium
    HomeButton.TextSize = 12
    HomeButton.BackgroundColor3 = Color3.fromRGB(46, 80, 144) -- #2E5090
    applyCorner(HomeButton, 8)

    -- Nút Stats hình chữ nhật góc tròn mềm mại
    local StatsButton = Instance.new("TextButton", Header)
    StatsButton.Size = UDim2.new(0, 55, 0, 28)
    StatsButton.Position = UDim2.new(0.72, 0, 0.12, 0)
    StatsButton.Text = "Stats"
    StatsButton.TextColor3 = Color3.new(1, 1, 1)
    StatsButton.Font = Enum.Font.GothamMedium
    StatsButton.TextSize = 12
    StatsButton.BackgroundColor3 = Color3.fromRGB(45, 47, 56)
    applyCorner(StatsButton, 8)

    local Close = Instance.new("TextButton", Header)
    Close.Size = UDim2.new(0, 28, 0, 28)
    Close.Position = UDim2.new(0.89, 0, 0.12, 0)
    Close.Text = "×"
    Close.TextColor3 = Color3.new(1, 1, 1)
    Close.Font = Enum.Font.GothamBold
    Close.TextSize = 14
    Close.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    applyCorner(Close, 8)

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
    Sidebar.Size = UDim2.new(0, 130, 1, -75)
    Sidebar.Position = UDim2.new(0, 0, 0, 75)
    Sidebar.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 2
    Sidebar.Active = true
    Sidebar.ScrollingDirection = Enum.ScrollingDirection.Y
    Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    applyCorner(Sidebar, 12)

    local SidebarLayout = Instance.new("UIListLayout", Sidebar)
    SidebarLayout.Padding = UDim.new(0, 5)
    SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local SidebarPadding = Instance.new("UIPadding", Sidebar)
    SidebarPadding.PaddingTop = UDim.new(0, 10)

    SidebarLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Sidebar.CanvasSize = UDim2.new(0, 0, 0, SidebarLayout.AbsoluteContentSize.Y + 20)
    end)

    local PageContainer = Instance.new("Frame", MainWindow)
    PageContainer.Size = UDim2.new(1, -130, 1, -75)
    PageContainer.Position = UDim2.new(0, 130, 0, 75)
    PageContainer.BackgroundTransparency = 1

    -- =====================================================================
    -- 3. KHU VỰC ĐẶC QUYỀN HOME PANEL (CreateColorPicker & Save Settings Toggle)
    -- =====================================================================
    HomePanelFrame = Instance.new("ScrollingFrame", PageContainer)
    HomePanelFrame.Size = UDim2.new(1, 0, 1, 0)
    HomePanelFrame.BackgroundTransparency = 1
    HomePanelFrame.ScrollBarThickness = 4
    HomePanelFrame.Visible = false
    HomePanelFrame.Active = true

    local homePadding = Instance.new("UIPadding", HomePanelFrame)
    homePadding.PaddingTop = UDim.new(0, 20)
    local homeLayout = Instance.new("UIListLayout", HomePanelFrame)
    homeLayout.Padding = UDim.new(0, 15)
    homeLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    homeLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        HomePanelFrame.CanvasSize = UDim2.new(0, 0, 0, homeLayout.AbsoluteContentSize.Y + 40)
    end)

    -- Hàm xử lý chuyển đổi hiển thị Home Panel
    local function showHomePanel(show)
        HomePanelFrame.Visible = show
        for _, page in ipairs(Window.TabPages) do
            page.Visible = false
        end
    end

    HomeButton.MouseButton1Click:Connect(function()
        showHomePanel(true)
    end)

    -- =====================================================================
    -- 4. MINI MENU THU NHỎ (BẢO TOÀN TUYỆT ĐỐI KHÔNG THAY ĐỔI)
    -- =====================================================================
    local MiniScreenGui = Instance.new("ScreenGui", TargetParent)
    MiniScreenGui.Name = "NemoZ_DeltaCustomMiniMenu"
    MiniScreenGui.IgnoreGuiInset = true

    local MiniMainFrame = Instance.new("Frame", MiniScreenGui)
    MiniMainFrame.Name = "MainFrame"
    MiniMainFrame.Size = UDim2.new(0, 135, 0, 40)
    MiniMainFrame.Position = UDim2.new(0.5, -67, 0, 0)
    MiniMainFrame.BackgroundColor3 = Color3.fromRGB(18, 19, 23)
    MiniMainFrame.BorderSizePixel = 0
    MiniMainFrame.Active = true
    MiniMainFrame.ZIndex = 2
    MiniMainFrame.Visible = false

    local MiniUICorner = Instance.new("UICorner", MiniMainFrame)
    MiniUICorner.CornerRadius = UDim.new(0, 12)

    local MiniUIStroke = Instance.new("UIStroke", MiniMainFrame)
    MiniUIStroke.Thickness = 1
    MiniUIStroke.Color = Color3.fromRGB(45, 47, 56)
    MiniUIStroke.Transparency = 1

    local MiniTopOverlay = Instance.new("Frame", MiniMainFrame)
    MiniTopOverlay.Name = "TopOverlay"
    MiniTopOverlay.Size = UDim2.new(1, 0, 0, 12)
    MiniTopOverlay.Position = UDim2.new(0, 0, 0, 0)
    MiniTopOverlay.BackgroundColor3 = Color3.fromRGB(18, 19, 23)
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

    local draggingMini, dragInputMini, dragStartMini, startPosMini

    local function updateMini(input)
        local delta = input.Position - dragStartMini
        local endY = startPosMini.Y.Offset + delta.Y
        if endY < 0 then endY = 0 end
        MiniUIStroke.Transparency = 1 
        
        if endY <= 3 then
            MiniMainFrame.BackgroundColor3 = Color3.fromRGB(18, 19, 23)
            MiniTopOverlay.BackgroundColor3 = Color3.fromRGB(18, 19, 23)
            MiniUICorner.CornerRadius = UDim.new(0, 12)
            MiniTopOverlay.Visible = true
            MiniMainFrame.Position = UDim2.new(startPosMini.X.Scale, startPosMini.X.Offset + delta.X, startPosMini.Y.Scale, 0)
        else
            MiniMainFrame.BackgroundColor3 = Color3.fromRGB(24, 26, 32)
            MiniUICorner.CornerRadius = UDim.new(0, 8)
            MiniTopOverlay.Visible = false
            TweenService:Create(MiniMainFrame, TweenInfo.new(0.08), {Position = UDim2.new(startPosMini.X.Scale, startPosMini.X.Offset + delta.X, startPosMini.Y.Scale, endY)}):Play()
        end
    end

    MiniDragButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingMini = true
            dragStartMini = input.Position
            startPosMini = MiniMainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInputMini or (draggingMini and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch)) then
            dragInputMini = input
            if draggingMini then updateMini(input) end
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

    local isMini = false
    StatsButton.MouseButton1Click:Connect(function()
        isMini = not isMini
        MainWindow.Size = isMini and UDim2.new(0, 520, 0, 75) or UDim2.new(0, 520, 0, 320)
        Sidebar.Visible = not isMini
        PageContainer.Visible = not isMini
    end)

    -- FPS, Ping & Loss Counter thời gian thực
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

    -- =====================================================================
    -- 5. ĐẶC QUYỀN HOME PANEL: COLORPICKER & SAVE SETTINGS TOGGLE
    -- =====================================================================
    local function createHomePanelElements()
        -- 1. CreateColorPicker cho phép đổi màu Aura toàn giao diện
        local cpContainer = Instance.new("Frame", HomePanelFrame)
        cpContainer.Size = UDim2.new(0.9, 0, 0, 55)
        cpContainer.BackgroundColor3 = Color3.fromRGB(24, 26, 32)
        applyCorner(cpContainer, 10)
        applyMultiLayerAura(cpContainer, Color3.fromRGB(46, 80, 144), 2)

        local cpTitle = Instance.new("TextLabel", cpContainer)
        cpTitle.Size = UDim2.new(0.6, 0, 1, 0)
        cpTitle.Position = UDim2.new(0, 15, 0, 0)
        cpTitle.Text = "Aura Theme Color"
        cpTitle.TextColor3 = Color3.new(1, 1, 1)
        cpTitle.Font = Enum.Font.GothamMedium
        cpTitle.BackgroundTransparency = 1
        cpTitle.TextXAlignment = Enum.TextXAlignment.Left

        local cpBtn = Instance.new("TextButton", cpContainer)
        cpBtn.Size = UDim2.new(0, 35, 0, 35)
        cpBtn.Position = UDim2.new(1, -45, 0.5, -17.5)
        cpBtn.BackgroundColor3 = Color3.fromRGB(46, 80, 144)
        cpBtn.Text = ""
        applyCorner(cpBtn, 8)

        cpBtn.MouseButton1Click:Connect(function()
            -- Chuyển đổi qua lại màu chủ đạo Aura
            if cpBtn.BackgroundColor3 == Color3.fromRGB(46, 80, 144) then
                cpBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
                Window.CurrentAuraColor = Color3.fromRGB(255, 100, 100)
            elseif cpBtn.BackgroundColor3 == Color3.fromRGB(255, 100, 100) then
                cpBtn.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
                Window.CurrentAuraColor = Color3.fromRGB(100, 255, 100)
            else
                cpBtn.BackgroundColor3 = Color3.fromRGB(46, 80, 144)
                Window.CurrentAuraColor = Color3.fromRGB(46, 80, 144)
            end
        end)

        -- 2. CreateToggle đóng vai trò Save Settings (Lưu thiết lập tự động)
        local svContainer = Instance.new("Frame", HomePanelFrame)
        svContainer.Size = UDim2.new(0.9, 0, 0, 55)
        svContainer.BackgroundColor3 = Color3.fromRGB(24, 26, 32)
        applyCorner(svContainer, 10)
        applyMultiLayerAura(svContainer, Color3.fromRGB(46, 80, 144), 2)

        local svTitle = Instance.new("TextLabel", svContainer)
        svTitle.Size = UDim2.new(0.6, 0, 1, 0)
        svTitle.Position = UDim2.new(0, 15, 0, 0)
        svTitle.Text = "Save Settings (Auto-Remember)"
        svTitle.TextColor3 = Color3.new(1, 1, 1)
        svTitle.Font = Enum.Font.GothamMedium
        svTitle.BackgroundTransparency = 1
        svTitle.TextXAlignment = Enum.TextXAlignment.Left

        local saveState = false
        local svToggleBtn = Instance.new("TextButton", svContainer)
        svToggleBtn.Size = UDim2.new(0, 50, 0, 25)
        svToggleBtn.Position = UDim2.new(1, -60, 0.5, -12.5)
        svToggleBtn.BackgroundColor3 = Color3.fromRGB(45, 47, 56)
        svToggleBtn.Text = ""
        applyCorner(svToggleBtn, 12)

        local svKnob = Instance.new("Frame", svToggleBtn)
        svKnob.Size = UDim2.new(0.5, 0, 1, 0)
        svKnob.BackgroundColor3 = Color3.new(1, 1, 1)
        applyCorner(svKnob, 12)

        svToggleBtn.MouseButton1Click:Connect(function()
            saveState = not saveState
            svToggleBtn.BackgroundColor3 = saveState and Color3.fromRGB(46, 80, 144) or Color3.fromRGB(45, 47, 56)
            svKnob.Position = saveState and UDim2.new(0.5, 0, 0, 0) or UDim2.new(0, 0, 0, 0)
        end)
    end

    createHomePanelElements()

    -- =====================================================================
    -- 6. TẠO TAB & HỆ THỐNG CÁC HÀM CREATE ĐẦY ĐỦ (17+ HÀM)
    -- =====================================================================
    function Window:CreateTab(name, imageId)
        local TabData = {}
        
        local tabBtn = Instance.new("TextButton", Sidebar)
        tabBtn.Size = UDim2.new(0.9, 0, 0, 35)
        tabBtn.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
        tabBtn.Text = name
        tabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        tabBtn.Font = Enum.Font.GothamMedium
        tabBtn.TextSize = 12
        tabBtn.TextXAlignment = Enum.TextXAlignment.Center
        applyCorner(tabBtn, 8)

        local icon = Instance.new("ImageLabel", tabBtn)
        icon.Size = UDim2.new(0, 16, 0, 16)
        icon.Position = UDim2.new(0, 8, 0.5, -8)
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
            HomePanelFrame.Visible = false
            for i, btn in ipairs(Window.TabButtons) do
                btn.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
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

        -- 1. CreateSection: Phân chia nhóm chức năng
        function TabData:CreateSection(secName)
            local secLabel = Instance.new("TextLabel", page)
            secLabel.Size = UDim2.new(0.9, 0, 0, 25)
            secLabel.BackgroundTransparency = 1
            secLabel.Text = "  " .. string.upper(secName)
            secLabel.TextColor3 = Color3.fromRGB(80, 150, 255)
            secLabel.Font = Enum.Font.GothamBold
            secLabel.TextSize = 12
            secLabel.TextXAlignment = Enum.TextXAlignment.Left
            return secLabel
        end

        -- 2. CreateParagraph: Khung hiển thị thông tin, mô tả, hướng dẫn
        function TabData:CreateParagraph(titleText, descText)
            local pContainer = Instance.new("Frame", page)
            pContainer.Size = UDim2.new(0.9, 0, 0, 65)
            pContainer.BackgroundColor3 = Color3.fromRGB(24, 26, 32)
            applyCorner(pContainer, 10)
            applyMultiLayerAura(pContainer, Color3.fromRGB(46, 80, 144), 2)

            local pTitle = Instance.new("TextLabel", pContainer)
            pTitle.Size = UDim2.new(1, -20, 0, 25)
            pTitle.Position = UDim2.new(0, 10, 0, 5)
            pTitle.BackgroundTransparency = 1
            pTitle.Text = titleText
            pTitle.TextColor3 = Color3.new(1, 1, 1)
            pTitle.Font = Enum.Font.GothamBold
            pTitle.TextSize = 13
            pTitle.TextXAlignment = Enum.TextXAlignment.Left

            local pDesc = Instance.new("TextLabel", pContainer)
            pDesc.Size = UDim2.new(1, -20, 0, 30)
            pDesc.Position = UDim2.new(0, 10, 0, 28)
            pDesc.BackgroundTransparency = 1
            pDesc.Text = descText
            pDesc.TextColor3 = Color3.fromRGB(160, 165, 175)
            pDesc.Font = Enum.Font.Gotham
            pDesc.TextSize = 11
            pDesc.TextWrapped = true
            pDesc.TextXAlignment = Enum.TextXAlignment.Left
            return pContainer
        end

        -- 3. CreateButton: Nút bấm tương tác thông thường với đa lớp aura
        function TabData:CreateButton(btnName, callback)
            local btn = Instance.new("TextButton", page)
            btn.Size = UDim2.new(0.9, 0, 0, 45)
            btn.BackgroundColor3 = Color3.fromRGB(24, 26, 32)
            btn.Text = "  " .. btnName
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Font = Enum.Font.GothamMedium
            btn.TextXAlignment = Enum.TextXAlignment.Left
            applyCorner(btn, 10)
            applyMultiLayerAura(btn, Color3.fromRGB(46, 80, 144), 2)
            
            local btnIcon = Instance.new("ImageLabel", btn)
            btnIcon.Size = UDim2.new(0, 24, 0, 24) 
            btnIcon.Position = UDim2.new(1, -35, 0.5, -12) 
            btnIcon.BackgroundTransparency = 1
            btnIcon.Image = "rbxassetid://12333784627" 

            btn.MouseButton1Click:Connect(callback)
            return btn
        end

        -- 4. CreateToggle: Công tắc bật/tắt
        function TabData:CreateToggle(toggleName, callback)
            local state = false
            local btn = Instance.new("TextButton", page)
            btn.Size = UDim2.new(0.9, 0, 0, 45)
            btn.BackgroundColor3 = Color3.fromRGB(24, 26, 32)
            btn.Text = "  " .. toggleName 
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Font = Enum.Font.GothamMedium
            btn.TextXAlignment = Enum.TextXAlignment.Left
            applyCorner(btn, 10)
            applyMultiLayerAura(btn, Color3.fromRGB(46, 80, 144), 2)
            
            local sliderBg = Instance.new("Frame", btn)
            sliderBg.Size = UDim2.new(0, 50, 0, 24)
            sliderBg.Position = UDim2.new(1, -60, 0.5, -12)
            sliderBg.BackgroundColor3 = Color3.fromRGB(45, 47, 56) 
            applyCorner(sliderBg, 12)
            
            local sliderKnob = Instance.new("Frame", sliderBg)
            sliderKnob.Size = UDim2.new(0.5, 0, 1, 0)
            sliderKnob.BackgroundColor3 = Color3.new(1, 1, 1)
            applyCorner(sliderKnob, 12)
            
            btn.MouseButton1Click:Connect(function()
                state = not state
                sliderBg.BackgroundColor3 = state and Color3.fromRGB(46, 80, 144) or Color3.fromRGB(45, 47, 56)
                sliderKnob.Position = state and UDim2.new(0.5, 0, 0, 0) or UDim2.new(0, 0, 0, 0)
                pcall(function() callback(state) end)
            end)
            return btn
        end

        -- 5. CreateDropdown: Danh sách thả xuống chọn nhiều mục
        function TabData:CreateDropdown(dropName, options, callback)
            local selectedItems = {}
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 45) 
            container.BackgroundColor3 = Color3.fromRGB(24, 26, 32)
            container.ClipsDescendants = true 
            applyCorner(container, 10)
            applyMultiLayerAura(container, Color3.fromRGB(46, 80, 144), 2)

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
            valueBox.BackgroundColor3 = Color3.fromRGB(35, 38, 48)
            applyCorner(valueBox, 6)

            local selectedText = Instance.new("TextLabel", valueBox)
            selectedText.Size = UDim2.new(1, -15, 1, 0)
            selectedText.Position = UDim2.new(0, 0, 0, 0)
            selectedText.Text = "Select..."
            selectedText.TextColor3 = Color3.fromRGB(150, 150, 150)
            selectedText.Font = Enum.Font.Gotham
            selectedText.TextSize = 12
            selectedText.BackgroundTransparency = 1
            selectedText.TextTruncate = Enum.TextTruncate.AtEnd
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
                itemBtn.BackgroundColor3 = Color3.fromRGB(28, 30, 36)
                itemBtn.Text = ""
                itemBtn.BorderSizePixel = 0

                local checkBg = Instance.new("Frame", itemBtn)
                checkBg.Size = UDim2.new(0, 16, 0, 16)
                checkBg.Position = UDim2.new(0, 15, 0.5, -8)
                checkBg.BackgroundColor3 = Color3.fromRGB(45, 47, 56)
                applyCorner(checkBg, 4)

                local checkFill = Instance.new("Frame", checkBg)
                checkFill.Size = UDim2.new(1, -4, 1, -4)
                checkFill.Position = UDim2.new(0, 2, 0, 2)
                checkFill.BackgroundColor3 = Color3.fromRGB(46, 80, 144)
                checkFill.Visible = false 
                applyCorner(checkFill, 2)

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

        -- 6. CreateDropdownTarget: Chọn mục tiêu đơn lẻ
        function TabData:CreateDropdownTarget(dropName, options, callback)
            local selectedItem = nil
            local itemElements = {}

            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 45) 
            container.BackgroundColor3 = Color3.fromRGB(24, 26, 32)
            container.ClipsDescendants = true 
            applyCorner(container, 10)
            applyMultiLayerAura(container, Color3.fromRGB(46, 80, 144), 2)

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
            valueBox.BackgroundColor3 = Color3.fromRGB(35, 38, 48)
            applyCorner(valueBox, 6)

            local selectedText = Instance.new("TextLabel", valueBox)
            selectedText.Size = UDim2.new(1, -15, 1, 0)
            selectedText.Position = UDim2.new(0, 0, 0, 0)
            selectedText.Text = "Select..."
            selectedText.TextColor3 = Color3.fromRGB(150, 150, 150)
            selectedText.Font = Enum.Font.Gotham
            selectedText.TextSize = 12
            selectedText.BackgroundTransparency = 1
            selectedText.TextTruncate = Enum.TextTruncate.AtEnd
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
                itemBtn.BackgroundColor3 = Color3.fromRGB(28, 30, 36)
                itemBtn.Text = ""
                itemBtn.BorderSizePixel = 0

                local checkBg = Instance.new("Frame", itemBtn)
                checkBg.Size = UDim2.new(0, 16, 0, 16)
                checkBg.Position = UDim2.new(0, 15, 0.5, -8)
                checkBg.BackgroundColor3 = Color3.fromRGB(45, 47, 56)
                applyCorner(checkBg, 8)

                local checkFill = Instance.new("Frame", checkBg)
                checkFill.Size = UDim2.new(1, -6, 1, -6)
                checkFill.Position = UDim2.new(0, 3, 0, 3)
                checkFill.BackgroundColor3 = Color3.fromRGB(46, 80, 144)
                checkFill.Visible = false 
                applyCorner(checkFill, 8)

                local itemText = Instance.new("TextLabel", itemBtn)
                itemText.Size = UDim2.new(1, -50, 1, 0)
                itemText.Position = UDim2.new(0, 40, 0, 0)
                itemText.Text = opt
                itemText.TextColor3 = Color3.fromRGB(200, 200, 200)
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

        -- 7. CreateSlider: Thanh trượt chỉnh giá trị số
        function TabData:CreateSlider(sliderName, min, max, callback)
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 60)
            container.BackgroundColor3 = Color3.fromRGB(24, 26, 32)
            applyCorner(container, 10)
            applyMultiLayerAura(container, Color3.fromRGB(46, 80, 144), 2)
            
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
            valueBox.BackgroundColor3 = Color3.fromRGB(35, 38, 48)
            valueBox.Text = tostring(max)
            valueBox.TextColor3 = Color3.new(1, 1, 1)
            valueBox.Font = Enum.Font.GothamBold
            applyCorner(valueBox, 6)

            local sliderBg = Instance.new("Frame", container)
            sliderBg.Size = UDim2.new(0.4, 0, 0, 6)
            sliderBg.Position = UDim2.new(0, 150, 0.5, -3) 
            sliderBg.BackgroundColor3 = Color3.fromRGB(45, 47, 56)
            applyCorner(sliderBg, 3)

            local progress = Instance.new("Frame", sliderBg)
            progress.Size = UDim2.new(1, 0, 1, 0)
            progress.BackgroundColor3 = Color3.fromRGB(46, 80, 144)
            applyCorner(progress, 3)

            local knob = Instance.new("ImageLabel", sliderBg)
            knob.AnchorPoint = Vector2.new(0.5, 0.5) 
            knob.Size = UDim2.new(0, 20, 0, 20)
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

        -- 8. CreateLabel: Nhãn chữ hiển thị thông tin
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

        -- 9. CreateTextBox: Ô nhập văn bản
        function TabData:CreateTextBox(boxName, placeholder, callback)
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 45)
            container.BackgroundColor3 = Color3.fromRGB(24, 26, 32)
            applyCorner(container, 10)
            applyMultiLayerAura(container, Color3.fromRGB(46, 80, 144), 2)

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
            inputBox.BackgroundColor3 = Color3.fromRGB(35, 38, 48)
            inputBox.Text = ""
            inputBox.PlaceholderText = placeholder or "Type..."
            inputBox.PlaceholderColor3 = Color3.fromRGB(120, 125, 135)
            inputBox.TextColor3 = Color3.new(1, 1, 1)
            inputBox.Font = Enum.Font.Gotham
            inputBox.TextSize = 12
            applyCorner(inputBox, 6)

            inputBox.FocusLost:Connect(function(enterPressed)
                pcall(function() callback(inputBox.Text, enterPressed) end)
            end)

            return container
        end

        -- 10. CreateKeybind: Cài đặt phím tắt bàn phím
        function TabData:CreateKeybind(keyName, defaultKey, callback)
            local currentKey = defaultKey or Enum.KeyCode.F
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 45)
            container.BackgroundColor3 = Color3.fromRGB(24, 26, 32)
            applyCorner(container, 10)
            applyMultiLayerAura(container, Color3.fromRGB(46, 80, 144), 2)

            local title = Instance.new("TextLabel", container)
            title.Size = UDim2.new(0.5, 0, 1, 0)
            title.Position = UDim2.new(0, 15, 0, 0)
            title.Text = keyName
            title.TextColor3 = Color3.new(1, 1, 1)
            title.Font = Enum.Font.GothamMedium
            title.BackgroundTransparency = 1
            title.TextXAlignment = Enum.TextXAlignment.Left

            local keyBtn = Instance.new("TextButton", container)
            keyBtn.Size = UDim2.new(0, 90, 0, 28)
            keyBtn.Position = UDim2.new(1, -100, 0.5, -14)
            keyBtn.BackgroundColor3 = Color3.fromRGB(35, 38, 48)
            keyBtn.Text = tostring(currentKey.Name)
            keyBtn.TextColor3 = Color3.fromRGB(80, 150, 255)
            keyBtn.Font = Enum.Font.GothamBold
            keyBtn.TextSize = 12
            applyCorner(keyBtn, 6)

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

        return TabData
    end

    return Window
end

return NemoZLibrary