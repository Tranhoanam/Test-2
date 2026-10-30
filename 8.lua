-- =========================================================================
-- NEMOZ UI LIBRARY - BẢN CẬP NHẬT HOÀN CHỈNH (HYPEROS 4 & DRAGON & TIME)
-- =========================================================================

local NemoZLibrary = {}

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer

-- Xác định vị trí lưu trữ GUI an toàn
local TargetParent = nil
pcall(function() TargetParent = gethui() end)
if not TargetParent then
    pcall(function() TargetParent = CoreGui end)
end
if not TargetParent then TargetParent = Player:WaitForChild("PlayerGui") end

-- Màu cốt lõi
local THEME_BLUE = Color3.fromRGB(46, 80, 144) -- #2E5090 YInMn Blue
local THEME_GRAY = Color3.fromRGB(54, 69, 79) -- #36454F Charcoal Gray
local CURRENT_AURA_COLOR = THEME_BLUE

function NemoZLibrary:CreateWindow(config)
    local Window = {
        TabButtons = {},
        TabPages = {},
        AuraElements = {}
    }
    
    local Name = config.Name or "NemoZ Menu"

    -- Dọn dẹp GUI cũ tránh trùng lặp
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
    IntroBackground.ZIndex = 1

    -- Lớp sao trời (Starry layer)
    local StarsFolder = Instance.new("Folder", IntroBackground)
    StarsFolder.Name = "Stars"
    for i = 1, 35 do
        local star = Instance.new("Frame", StarsFolder)
        star.Size = UDim2.new(0, math.random(2, 4), 0, math.random(2, 4))
        star.Position = UDim2.new(math.random(), 0, math.random(), 0)
        star.BackgroundColor3 = Color3.new(1, 1, 1)
        star.BackgroundTransparency = math.random(20, 80) / 100
        star.BorderSizePixel = 0
        Instance.new("UICorner", star).CornerRadius = UDim.new(1, 0)
    end

    -- Lớp trung tâm: Hình khối vuông góc tròn xoay vòng
    local CenterContainer = Instance.new("Frame", IntroBackground)
    CenterContainer.Size = UDim2.new(0, 80, 0, 80)
    CenterContainer.Position = UDim2.new(0.5, -40, 0.5, -70)
    CenterContainer.BackgroundTransparency = 1
    CenterContainer.ZIndex = 2

    local CenterShape = Instance.new("Frame", CenterContainer)
    CenterShape.Size = UDim2.new(1, 0, 1, 0)
    CenterShape.BackgroundColor3 = THEME_BLUE
    CenterShape.BorderSizePixel = 0
    Instance.new("UICorner", CenterShape).CornerRadius = UDim.new(0, 16)

    -- Hiệu ứng xoay vòng liên tục cho CenterShape
    local spinConn
    spinConn = RunService.RenderStepped:Connect(function(dt)
        if CenterShape and CenterShape.Parent then
            CenterShape.Rotation = CenterShape.Rotation + (dt * 60)
        else
            if spinConn then spinConn:Disconnect() end
        end
    end)

    -- Lớp trên cùng: Text Animation gõ phím từ từ
    local IntroTitle = Instance.new("TextLabel", IntroBackground)
    IntroTitle.Size = UDim2.new(1, 0, 0, 80)
    IntroTitle.Position = UDim2.new(0, 0, 0.5, 20)
    IntroTitle.BackgroundTransparency = 1
    IntroTitle.Text = ""
    IntroTitle.TextColor3 = Color3.fromRGB(230, 235, 245)
    IntroTitle.Font = Enum.Font.GothamBold
    IntroTitle.TextSize = 40
    IntroTitle.ZIndex = 3
    IntroTitle.TextXAlignment = Enum.TextXAlignment.Center

    local IntroSound = Instance.new("Sound", IntroGui)
    IntroSound.SoundId = "rbxassetid://125090389445721"
    IntroSound.Volume = 1
    pcall(function() IntroSound:Play() end)

    -- Hiệu ứng gõ phím
    task.spawn(function()
        task.wait(0.5)
        local targetText = Name ~= "" and Name or "NEMo-z"
        for i = 1, #targetText do
            IntroTitle.Text = string.sub(targetText, 1, i)
            task.wait(0.1)
        end
    end)

    -- Sau 5 giây, ẩn Intro và hiện Menu chính
    task.delay(5, function()
        if spinConn then spinConn:Disconnect() end
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
    -- 2. HỆ THỐNG AURA ĐA LỚP & MENU CHÍNH
    -- ==========================================
    local ScreenGui = Instance.new("ScreenGui", TargetParent)
    ScreenGui.Name = "NemoZ_MainOnlyMenu"
    ScreenGui.IgnoreGuiInset = true

    -- Thêm 4 lớp aura khổng lồ bao bọc Main Window
    local AuraLayers = {}
    for i = 4, 1, -1 do
        local auraLayer = Instance.new("Frame", ScreenGui)
        auraLayer.Name = "AuraLayer_" .. i
        auraLayer.Size = UDim2.new(0, 500 + (i * 16), 0, 320 + (i * 16))
        auraLayer.Position = UDim2.new(0.5, -250 - (i * 8), 0.5, -160 - (i * 8))
        auraLayer.BackgroundColor3 = THEME_BLUE
        auraLayer.BackgroundTransparency = 0.75 + (i * 0.05)
        auraLayer.BorderSizePixel = 0
        Instance.new("UICorner", auraLayer).CornerRadius = UDim.new(0, 18 + i)
        table.insert(AuraLayers, auraLayer)
    end

    MainWindow = Instance.new("Frame", ScreenGui)
    MainWindow.Size = UDim2.new(0, 500, 0, 320)
    MainWindow.Position = UDim2.new(0.5, -250, 0.5, -160)
    MainWindow.BackgroundColor3 = THEME_GRAY
    MainWindow.BorderSizePixel = 0
    MainWindow.Active = true
    MainWindow.Visible = false 

    Instance.new("UICorner", MainWindow).CornerRadius = UDim.new(0, 14)
    
    local MainStroke = Instance.new("UIStroke", MainWindow)
    MainStroke.Color = THEME_BLUE
    MainStroke.Thickness = 1.5

    -- Họa tiết vải rồng chìm (Dragon Pattern)
    local DragonPattern = Instance.new("Frame", MainWindow)
    DragonPattern.Size = UDim2.new(1, 0, 1, 0)
    DragonPattern.BackgroundTransparency = 0.92
    DragonPattern.BackgroundColor3 = THEME_BLUE
    DragonPattern.BorderSizePixel = 0
    Instance.new("UICorner", DragonPattern).CornerRadius = UDim.new(0, 14)

    -- ==========================================
    -- 3. HEADER & ĐIỀU HƯỚNG (STATS, HOME, CLOSE)
    -- ==========================================
    local Header = Instance.new("Frame", MainWindow)
    Header.Size = UDim2.new(1, 0, 0, 75)
    Header.BackgroundColor3 = Color3.fromRGB(30, 38, 48)
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 14)

    -- Kéo thả cửa sổ chính
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
            for idx, aura in ipairs(AuraLayers) do
                aura.Position = UDim2.new(newPos.X.Scale, newPos.X.Offset - (idx * 8), newPos.Y.Scale, newPos.Y.Offset - (idx * 8))
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
    Title.Size = UDim2.new(0.35, 0, 0.45, 0)
    Title.Position = UDim2.new(0.04, 0, 0.05, 0)
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 15
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left

    -- Nút Stats (Chữ nhật góc tròn mềm mại)
    local StatsButton = Instance.new("TextButton", Header)
    StatsButton.Size = UDim2.new(0, 55, 0, 26)
    StatsButton.Position = UDim2.new(0.58, 0, 0.08, 0)
    StatsButton.Text = "Stats"
    StatsButton.TextColor3 = Color3.new(1, 1, 1)
    StatsButton.Font = Enum.Font.GothamMedium
    StatsButton.TextSize = 11
    StatsButton.BackgroundColor3 = Color3.fromRGB(45, 55, 68)
    Instance.new("UICorner", StatsButton).CornerRadius = UDim.new(0, 8)

    -- Nút Home (ĐẶT BÊN CẠNH NÚT STATS)
    local HomeButton = Instance.new("TextButton", Header)
    HomeButton.Size = UDim2.new(0, 55, 0, 26)
    HomeButton.Position = UDim2.new(0.74, 0, 0.08, 0)
    HomeButton.Text = "Home"
    HomeButton.TextColor3 = Color3.new(1, 1, 1)
    HomeButton.Font = Enum.Font.GothamMedium
    HomeButton.TextSize = 11
    HomeButton.BackgroundColor3 = Color3.fromRGB(45, 55, 68)
    Instance.new("UICorner", HomeButton).CornerRadius = UDim.new(0, 8)

    local Close = Instance.new("TextButton", Header)
    Close.Size = UDim2.new(0, 26, 0, 26)
    Close.Position = UDim2.new(0.90, 0, 0.08, 0)
    Close.Text = "×"
    Close.TextColor3 = Color3.new(1, 1, 1)
    Close.Font = Enum.Font.GothamBold
    Close.TextSize = 14
    Close.BackgroundColor3 = Color3.fromRGB(45, 55, 68)
    Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 8)

    -- Stats Frame hiển thị FPS / Ping / Loss
    local StatsFrame = Instance.new("Frame", Header)
    StatsFrame.Size = UDim2.new(1, 0, 0.45, 0)
    StatsFrame.Position = UDim2.new(0, 0, 0.5, 0)
    StatsFrame.BackgroundTransparency = 1

    local function createStatLabel(posX)
        local lbl = Instance.new("TextLabel", StatsFrame)
        lbl.Size = UDim2.new(0.33, 0, 1, 0)
        lbl.Position = UDim2.new(posX, 0, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Center
        return lbl
    end

    local PingLabel = createStatLabel(0)
    local FpsLabel = createStatLabel(0.33)
    local LossLabel = createStatLabel(0.66)

    -- Sidebar & Page Container
    local Sidebar = Instance.new("ScrollingFrame", MainWindow)
    Sidebar.Size = UDim2.new(0, 135, 1, -75)
    Sidebar.Position = UDim2.new(0, 0, 0, 75)
    Sidebar.BackgroundColor3 = Color3.fromRGB(24, 30, 38)
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
    PageContainer.Size = UDim2.new(1, -135, 1, -75)
    PageContainer.Position = UDim2.new(0, 135, 0, 75)
    PageContainer.BackgroundTransparency = 1

    -- ==========================================
    -- 4. KHU VỰC HOME ĐẶC QUYỀN
    -- ==========================================
    local HomePage = Instance.new("ScrollingFrame", PageContainer)
    HomePage.Size = UDim2.new(1, 0, 1, 0)
    HomePage.BackgroundTransparency = 1
    HomePage.ScrollBarThickness = 4
    HomePage.ScrollBarImageColor3 = Color3.new(1, 1, 1)
    HomePage.Visible = false
    HomePage.Active = true
    HomePage.ScrollingDirection = Enum.ScrollingDirection.Y

    local homePadding = Instance.new("UIPadding", HomePage)
    homePadding.PaddingTop = UDim.new(0, 15)
    local homeLayout = Instance.new("UIListLayout", HomePage)
    homeLayout.Padding = UDim.new(0, 12)
    homeLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    homeLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        HomePage.CanvasSize = UDim2.new(0, 0, 0, homeLayout.AbsoluteContentSize.Y + 30)
    end)

    local function updateGlobalAuraColor(newColor)
        CURRENT_AURA_COLOR = newColor
        for _, aura in ipairs(AuraLayers) do
            aura.BackgroundColor3 = newColor
        end
        MainStroke.Color = newColor
    end

    do
        local homeSec = Instance.new("TextLabel", HomePage)
        homeSec.Size = UDim2.new(0.9, 0, 0, 25)
        homeSec.BackgroundTransparency = 1
        homeSec.Text = "  SETTINGS & SYSTEM CONFIG"
        homeSec.TextColor3 = Color3.fromRGB(150, 165, 185)
        homeSec.Font = Enum.Font.GothamBold
        homeSec.TextSize = 11
        homeSec.TextXAlignment = Enum.TextXAlignment.Left

        -- CreateColorPicker cho Home
        local cpContainer = Instance.new("Frame", HomePage)
        cpContainer.Size = UDim2.new(0.9, 0, 0, 45)
        cpContainer.BackgroundColor3 = Color3.fromRGB(24, 28, 36)
        Instance.new("UICorner", cpContainer).CornerRadius = UDim.new(0, 10)
        Instance.new("UIStroke", cpContainer).Color = Color3.fromRGB(50, 60, 75)

        local cpTitle = Instance.new("TextLabel", cpContainer)
        cpTitle.Size = UDim2.new(0.6, 0, 1, 0)
        cpTitle.Position = UDim2.new(0, 15, 0, 0)
        cpTitle.Text = "Aura Theme Color"
        cpTitle.TextColor3 = Color3.new(1, 1, 1)
        cpTitle.Font = Enum.Font.GothamMedium
        cpTitle.TextSize = 12
        cpTitle.BackgroundTransparency = 1
        cpTitle.TextXAlignment = Enum.TextXAlignment.Left

        local colorPreview = Instance.new("TextButton", cpContainer)
        colorPreview.Size = UDim2.new(0, 35, 0, 24)
        colorPreview.Position = UDim2.new(1, -45, 0.5, -12)
        colorPreview.BackgroundColor3 = THEME_BLUE
        colorPreview.Text = ""
        Instance.new("UICorner", colorPreview).CornerRadius = UDim.new(0, 6)

        colorPreview.MouseButton1Click:Connect(function()
            if CURRENT_AURA_COLOR == THEME_BLUE then
                updateGlobalAuraColor(Color3.fromRGB(140, 50, 200))
                colorPreview.BackgroundColor3 = Color3.fromRGB(140, 50, 200)
            elseif CURRENT_AURA_COLOR == Color3.fromRGB(140, 50, 200) then
                updateGlobalAuraColor(Color3.fromRGB(50, 180, 100))
                colorPreview.BackgroundColor3 = Color3.fromRGB(50, 180, 100)
            else
                updateGlobalAuraColor(THEME_BLUE)
                colorPreview.BackgroundColor3 = THEME_BLUE
            end
        end)

        -- CreateToggle cho Home (Save Settings)
        local saveToggleContainer = Instance.new("Frame", HomePage)
        saveToggleContainer.Size = UDim2.new(0.9, 0, 0, 45)
        saveToggleContainer.BackgroundColor3 = Color3.fromRGB(24, 28, 36)
        Instance.new("UICorner", saveToggleContainer).CornerRadius = UDim.new(0, 10)
        Instance.new("UIStroke", saveToggleContainer).Color = Color3.fromRGB(50, 60, 75)

        local stTitle = Instance.new("TextLabel", saveToggleContainer)
        stTitle.Size = UDim2.new(0.6, 0, 1, 0)
        stTitle.Position = UDim2.new(0, 15, 0, 0)
        stTitle.Text = "Auto Save Settings"
        stTitle.TextColor3 = Color3.new(1, 1, 1)
        stTitle.Font = Enum.Font.GothamMedium
        stTitle.TextSize = 12
        stTitle.BackgroundTransparency = 1
        stTitle.TextXAlignment = Enum.TextXAlignment.Left

        local saveState = true
        local stSliderBg = Instance.new("TextButton", saveToggleContainer)
        stSliderBg.Size = UDim2.new(0, 46, 0, 24)
        stSliderBg.Position = UDim2.new(1, -56, 0.5, -12)
        stSliderBg.BackgroundColor3 = THEME_BLUE
        stSliderBg.Text = ""
        Instance.new("UICorner", stSliderBg).CornerRadius = UDim.new(1, 0)

        local stKnob = Instance.new("Frame", stSliderBg)
        stSliderBg.Size = UDim2.new(0, 46, 0, 24)
        stKnob.Size = UDim2.new(0, 20, 0, 20)
        stKnob.Position = UDim2.new(1, -22, 0.5, -10)
        stKnob.BackgroundColor3 = Color3.new(1, 1, 1)
        Instance.new("UICorner", stKnob).CornerRadius = UDim.new(1, 0)

        stSliderBg.MouseButton1Click:Connect(function()
            saveState = not saveState
            stSliderBg.BackgroundColor3 = saveState and THEME_BLUE or Color3.fromRGB(50, 60, 75)
            stKnob.Position = saveState and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
        end)
    end

    HomeButton.MouseButton1Click:Connect(function()
        for _, p in ipairs(Window.TabPages) do p.Visible = false end
        for _, b in ipairs(Window.TabButtons) do 
            b.BackgroundColor3 = Color3.fromRGB(30, 38, 48)
            b.TextColor3 = Color3.fromRGB(150, 165, 185)
        end
        HomePage.Visible = true
    end)

    -- ==========================================
    -- 5. MINI MENU THU NHỎ (BẢO TOÀN TUYỆT ĐỐI)
    -- ==========================================
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

    local mDragging, mDragInput, mDragStart, mStartPos
    local function updateMini(input)
        local delta = input.Position - mDragStart
        local endY = mStartPos.Y.Offset + delta.Y
        if endY < 0 then endY = 0 end
        MiniUIStroke.Transparency = 1 
        if endY <= 3 then
            MiniMainFrame.BackgroundColor3 = Color3.fromRGB(18, 19, 23)
            MiniTopOverlay.BackgroundColor3 = Color3.fromRGB(18, 19, 23)
            MiniUICorner.CornerRadius = UDim.new(0, 12)
            MiniTopOverlay.Visible = true
            MiniMainFrame.Position = UDim2.new(mStartPos.X.Scale, mStartPos.X.Offset + delta.X, mStartPos.Y.Scale, 0)
        else
            MiniMainFrame.BackgroundColor3 = Color3.fromRGB(24, 26, 32)
            MiniUICorner.CornerRadius = UDim.new(0, 8)
            MiniTopOverlay.Visible = false
            TweenService:Create(MiniMainFrame, TweenInfo.new(0.08), {Position = UDim2.new(mStartPos.X.Scale, mStartPos.X.Offset + delta.X, mStartPos.Y.Scale, endY)}):Play()
        end
    end

    MiniDragButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            mDragging = true
            mDragStart = input.Position
            mStartPos = MiniMainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == mDragInput or (mDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch)) then
            mDragInput = input
            if mDragging then updateMini(input) end
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            mDragging = false
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

    local isStatsMini = false
    StatsButton.MouseButton1Click:Connect(function()
        isStatsMini = not isStatsMini
        MainWindow.Size = isStatsMini and UDim2.new(0, 500, 0, 75) or UDim2.new(0, 500, 0, 320)
        Sidebar.Visible = not isStatsMini
        PageContainer.Visible = not isStatsMini
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
            FpsLabel.TextColor3 = (fps < 30) and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(50, 150, 255)
            
            PingLabel.Text = "PING: " .. ping
            PingLabel.TextColor3 = (ping > 100) and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(50, 150, 255)
            
            LossLabel.Text = "LOSS: 0%"
            LossLabel.TextColor3 = Color3.fromRGB(50, 150, 255)
            
            lastTick = tick()
            frames = 0
        end
    end)

    -- ==========================================
    -- 6. HỆ THỐNG TẠO TAB & CÁC THÀNH PHẦN (CREATE...)
    -- ==========================================
    function Window:CreateTab(name, imageId)
        local TabData = {}
        
        local tabBtn = Instance.new("TextButton", Sidebar)
        tabBtn.Size = UDim2.new(0.9, 0, 0, 35)
        tabBtn.BackgroundColor3 = Color3.fromRGB(30, 38, 48)
        tabBtn.Text = "   " .. name
        tabBtn.TextColor3 = Color3.fromRGB(150, 165, 185)
        tabBtn.Font = Enum.Font.GothamMedium
        tabBtn.TextSize = 12
        tabBtn.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 8)

        if imageId then
            local icon = Instance.new("ImageLabel", tabBtn)
            icon.Size = UDim2.new(0, 16, 0, 16)
            icon.Position = UDim2.new(0, 10, 0.5, -8)
            icon.BackgroundTransparency = 1
            icon.Image = "rbxassetid://" .. tostring(imageId)
            icon.ImageColor3 = Color3.fromRGB(150, 165, 185)
        end

        local page = Instance.new("ScrollingFrame", PageContainer)
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.ScrollBarThickness = 4
        page.ScrollBarImageColor3 = Color3.new(1, 1, 1)
        page.Visible = false
        page.Active = true
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
            HomePage.Visible = false
            for i, btn in ipairs(Window.TabButtons) do
                btn.BackgroundColor3 = Color3.fromRGB(30, 38, 48)
                btn.TextColor3 = Color3.fromRGB(150, 165, 185)
                Window.TabPages[i].Visible = false
            end
            tabBtn.BackgroundColor3 = THEME_BLUE
            tabBtn.TextColor3 = Color3.new(1, 1, 1)
            page.Visible = true
        end)

        table.insert(Window.TabButtons, tabBtn)
        table.insert(Window.TabPages, page)

        if #Window.TabButtons == 1 then
            tabBtn.BackgroundColor3 = THEME_BLUE
            tabBtn.TextColor3 = Color3.new(1, 1, 1)
            page.Visible = true
        end

        -- 1. CreateSection
        function TabData:CreateSection(secName)
            local lbl = Instance.new("TextLabel", page)
            lbl.Size = UDim2.new(0.9, 0, 0, 25)
            lbl.BackgroundTransparency = 1
            lbl.Text = "  " .. string.upper(secName)
            lbl.TextColor3 = Color3.fromRGB(150, 165, 185)
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 11
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            return lbl
        end

        -- 2. CreateParagraph
        function TabData:CreateParagraph(paraConfig)
            local title = paraConfig.Title or "Paragraph"
            local content = paraConfig.Content or "Description content..."

            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 65)
            container.BackgroundColor3 = Color3.fromRGB(24, 28, 36)
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
            Instance.new("UIStroke", container).Color = Color3.fromRGB(50, 60, 75)

            local tLbl = Instance.new("TextLabel", container)
            tLbl.Size = UDim2.new(1, -30, 0, 22)
            tLbl.Position = UDim2.new(0, 15, 0, 8)
            tLbl.BackgroundTransparency = 1
            tLbl.Text = title
            tLbl.TextColor3 = Color3.new(1, 1, 1)
            tLbl.Font = Enum.Font.GothamBold
            tLbl.TextSize = 12
            tLbl.TextXAlignment = Enum.TextXAlignment.Left

            local cLbl = Instance.new("TextLabel", container)
            cLbl.Size = UDim2.new(1, -30, 0, 25)
            cLbl.Position = UDim2.new(0, 15, 0, 30)
            cLbl.BackgroundTransparency = 1
            cLbl.Text = content
            cLbl.TextColor3 = Color3.fromRGB(170, 180, 195)
            cLbl.Font = Enum.Font.Gotham
            cLbl.TextSize = 11
            cLbl.TextWrapped = true
            cLbl.TextXAlignment = Enum.TextXAlignment.Left

            return container
        end

        -- 3. CreateButton
        function TabData:CreateButton(btnName, callback)
            local btn = Instance.new("TextButton", page)
            btn.Size = UDim2.new(0.9, 0, 0, 42)
            btn.BackgroundColor3 = Color3.fromRGB(24, 28, 36)
            btn.Text = "  " .. btnName
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Font = Enum.Font.GothamMedium
            btn.TextSize = 12
            btn.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
            
            local stroke = Instance.new("UIStroke", btn)
            stroke.Color = Color3.fromRGB(50, 60, 75)
            stroke.Thickness = 1.2

            btn.MouseButton1Click:Connect(function()
                pcall(callback)
            end)
            return btn
        end

        -- 4. CreateToggle
        function TabData:CreateToggle(toggleName, defaultState, callback)
            local state = defaultState or false
            local btn = Instance.new("TextButton", page)
            btn.Size = UDim2.new(0.9, 0, 0, 42)
            btn.BackgroundColor3 = Color3.fromRGB(24, 28, 36)
            btn.Text = "  " .. toggleName 
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Font = Enum.Font.GothamMedium
            btn.TextSize = 12
            btn.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
            Instance.new("UIStroke", btn).Color = Color3.fromRGB(50, 60, 75)
            
            local sliderBg = Instance.new("Frame", btn)
            sliderBg.Size = UDim2.new(0, 46, 0, 24)
            sliderBg.Position = UDim2.new(1, -56, 0.5, -12)
            sliderBg.BackgroundColor3 = state and THEME_BLUE or Color3.fromRGB(50, 60, 75)
            Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)
            
            local sliderKnob = Instance.new("Frame", sliderBg)
            sliderKnob.Size = UDim2.new(0, 20, 0, 20)
            sliderKnob.Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
            sliderKnob.BackgroundColor3 = Color3.new(1, 1, 1)
            Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)
            
            btn.MouseButton1Click:Connect(function()
                state = not state
                sliderBg.BackgroundColor3 = state and THEME_BLUE or Color3.fromRGB(50, 60, 75)
                sliderKnob.Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
                pcall(function() callback(state) end)
            end)
            return btn
        end

        -- 5. CreateSlider
        function TabData:CreateSlider(sliderName, min, max, default, callback)
            local currentVal = default or min
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 55)
            container.BackgroundColor3 = Color3.fromRGB(24, 28, 36)
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
            Instance.new("UIStroke", container).Color = Color3.fromRGB(50, 60, 75)
            
            local title = Instance.new("TextLabel", container)
            title.Size = UDim2.new(0.4, 0, 1, 0)
            title.Position = UDim2.new(0, 15, 0, 0)
            title.Text = sliderName
            title.TextColor3 = Color3.new(1, 1, 1)
            title.Font = Enum.Font.GothamMedium
            title.TextSize = 12
            title.BackgroundTransparency = 1
            title.TextXAlignment = Enum.TextXAlignment.Left

            local valueBox = Instance.new("TextBox", container)
            valueBox.Size = UDim2.new(0, 45, 0, 26)
            valueBox.Position = UDim2.new(0, 130, 0.5, -13)
            valueBox.BackgroundColor3 = Color3.fromRGB(35, 42, 52)
            valueBox.Text = tostring(currentVal)
            valueBox.TextColor3 = Color3.new(1, 1, 1)
            valueBox.Font = Enum.Font.GothamBold
            valueBox.TextSize = 11
            Instance.new("UICorner", valueBox).CornerRadius = UDim.new(0, 6)

            local sliderBg = Instance.new("Frame", container)
            sliderBg.Size = UDim2.new(0.35, 0, 0, 6)
            sliderBg.Position = UDim2.new(0, 185, 0.5, -3)
            sliderBg.BackgroundColor3 = Color3.fromRGB(50, 60, 75)
            Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

            local progress = Instance.new("Frame", sliderBg)
            progress.Size = UDim2.new((currentVal - min)/(max - min), 0, 1, 0)
            progress.BackgroundColor3 = THEME_BLUE
            Instance.new("UICorner", progress).CornerRadius = UDim.new(1, 0)

            local knob = Instance.new("Frame", sliderBg)
            knob.AnchorPoint = Vector2.new(0.5, 0.5)
            knob.Size = UDim2.new(0, 14, 0, 14)
            knob.Position = UDim2.new((currentVal - min)/(max - min), 0, 0.5, 0)
            knob.BackgroundColor3 = Color3.new(1, 1, 1)
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

            local hitbox = Instance.new("TextButton", sliderBg)
            hitbox.Size = UDim2.new(1, 20, 0, 30)
            hitbox.Position = UDim2.new(0.5, 0, 0.5, 0)
            hitbox.AnchorPoint = Vector2.new(0.5, 0.5)
            hitbox.BackgroundTransparency = 1
            hitbox.Text = ""

            local sDragging = false
            local function updateSlider(inputX)
                local sX = sliderBg.AbsolutePosition.X
                local sW = sliderBg.AbsoluteSize.X
                local percent = math.clamp((inputX - sX) / sW, 0, 1)
                local val = math.floor(min + ((max - min) * percent))
                progress.Size = UDim2.new(percent, 0, 1, 0)
                knob.Position = UDim2.new(percent, 0, 0.5, 0)
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
                    progress.Size = UDim2.new(percent, 0, 1, 0)
                    knob.Position = UDim2.new(percent, 0, 0.5, 0)
                    valueBox.Text = tostring(clamped)
                    pcall(function() callback(clamped) end)
                else
                    valueBox.Text = tostring(min)
                end
            end)
        end

        -- 6. CreateTextBox
        function TabData:CreateTextBox(boxName, placeholder, callback)
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 45)
            container.BackgroundColor3 = Color3.fromRGB(24, 28, 36)
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
            local stroke = Instance.new("UIStroke", container)
            stroke.Color = Color3.fromRGB(50, 60, 75)
            stroke.Thickness = 1.2

            local title = Instance.new("TextLabel", container)
            title.Size = UDim2.new(0.4, 0, 1, 0)
            title.Position = UDim2.new(0, 15, 0, 0)
            title.Text = boxName
            title.TextColor3 = Color3.new(1, 1, 1)
            title.Font = Enum.Font.GothamMedium
            title.TextSize = 12
            title.BackgroundTransparency = 1
            title.TextXAlignment = Enum.TextXAlignment.Left

            local inputBox = Instance.new("TextBox", container)
            inputBox.Size = UDim2.new(0, 150, 0, 28)
            inputBox.Position = UDim2.new(1, -165, 0.5, -14)
            inputBox.BackgroundColor3 = Color3.fromRGB(35, 42, 52)
            inputBox.Text = ""
            inputBox.PlaceholderText = placeholder or "Type..."
            inputBox.PlaceholderColor3 = Color3.fromRGB(120, 130, 145)
            inputBox.TextColor3 = Color3.new(1, 1, 1)
            inputBox.Font = Enum.Font.Gotham
            inputBox.TextSize = 11
            Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 6)

            inputBox.FocusLost:Connect(function(enterPressed)
                pcall(function() callback(inputBox.Text, enterPressed) end)
            end)
            return container
        end

        -- 7. CreateDropdown
        function TabData:CreateDropdown(dropName, options, callback)
            local selectedItems = {}
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 45) 
            container.BackgroundColor3 = Color3.fromRGB(24, 28, 36)
            container.ClipsDescendants = true 
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
            Instance.new("UIStroke", container).Color = Color3.fromRGB(50, 60, 75)

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
            title.TextSize = 12
            title.BackgroundTransparency = 1
            title.TextXAlignment = Enum.TextXAlignment.Left

            local valueBox = Instance.new("Frame", topBar)
            valueBox.Size = UDim2.new(0, 110, 0, 26) 
            valueBox.Position = UDim2.new(1, -145, 0.5, -13)
            valueBox.BackgroundColor3 = Color3.fromRGB(35, 42, 52)
            Instance.new("UICorner", valueBox).CornerRadius = UDim.new(0, 6)

            local selectedText = Instance.new("TextLabel", valueBox)
            selectedText.Size = UDim2.new(1, -15, 1, 0)
            selectedText.Position = UDim2.new(0, 0, 0, 0)
            selectedText.Text = "Select..."
            selectedText.TextColor3 = Color3.fromRGB(150, 165, 185)
            selectedText.Font = Enum.Font.Gotham
            selectedText.TextSize = 11
            selectedText.BackgroundTransparency = 1
            selectedText.TextTruncate = Enum.TextTruncate.AtEnd
            selectedText.TextXAlignment = Enum.TextXAlignment.Right

            local listHeight = math.min(#options * 32, 130) 
            local listFrame = Instance.new("ScrollingFrame", container)
            listFrame.Size = UDim2.new(1, 0, 0, listHeight)
            listFrame.Position = UDim2.new(0, 0, 0, 45)
            listFrame.BackgroundTransparency = 1
            listFrame.BorderSizePixel = 0
            listFrame.ScrollBarThickness = 3
            listFrame.Active = true
            listFrame.ScrollingDirection = Enum.ScrollingDirection.Y
            listFrame.CanvasSize = UDim2.new(0, 0, 0, #options * 32)

            local isExpanded = false
            topBar.MouseButton1Click:Connect(function()
                isExpanded = not isExpanded
                local targetHeight = isExpanded and (45 + listHeight) or 45
                TweenService:Create(container, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(0.9, 0, 0, targetHeight)}):Play()
            end)

            for i, opt in ipairs(options) do
                local itemBtn = Instance.new("TextButton", listFrame)
                itemBtn.Size = UDim2.new(1, 0, 0, 32)
                itemBtn.Position = UDim2.new(0, 0, 0, (i-1)*32)
                itemBtn.BackgroundColor3 = Color3.fromRGB(28, 33, 42)
                itemBtn.Text = ""
                itemBtn.BorderSizePixel = 0

                local checkBg = Instance.new("Frame", itemBtn)
                checkBg.Size = UDim2.new(0, 14, 0, 14)
                checkBg.Position = UDim2.new(0, 15, 0.5, -7)
                checkBg.BackgroundColor3 = Color3.fromRGB(50, 60, 75)
                Instance.new("UICorner", checkBg).CornerRadius = UDim.new(0, 3)

                local checkFill = Instance.new("Frame", checkBg)
                checkFill.Size = UDim2.new(1, -4, 1, -4)
                checkFill.Position = UDim2.new(0, 2, 0, 2)
                checkFill.BackgroundColor3 = THEME_BLUE
                checkFill.Visible = false 
                Instance.new("UICorner", checkFill).CornerRadius = UDim.new(0, 2)

                local itemText = Instance.new("TextLabel", itemBtn)
                itemText.Size = UDim2.new(1, -45, 1, 0)
                itemText.Position = UDim2.new(0, 38, 0, 0)
                itemText.Text = opt
                itemText.TextColor3 = Color3.fromRGB(190, 200, 215)
                itemText.Font = Enum.Font.Gotham
                itemText.TextSize = 11
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
                        selectedText.TextColor3 = Color3.fromRGB(150, 165, 185)
                    end
                    pcall(function() callback(selectedItems) end)
                end)
            end
            return container
        end

        -- 8. CreateDropdownTarget
        function TabData:CreateDropdownTarget(dropName, options, callback)
            local selectedItem = nil
            local itemElements = {}

            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 45) 
            container.BackgroundColor3 = Color3.fromRGB(24, 28, 36)
            container.ClipsDescendants = true 
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
            Instance.new("UIStroke", container).Color = Color3.fromRGB(50, 60, 75)

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
            title.TextSize = 12
            title.BackgroundTransparency = 1
            title.TextXAlignment = Enum.TextXAlignment.Left

            local valueBox = Instance.new("Frame", topBar)
            valueBox.Size = UDim2.new(0, 110, 0, 26) 
            valueBox.Position = UDim2.new(1, -145, 0.5, -13)
            valueBox.BackgroundColor3 = Color3.fromRGB(35, 42, 52)
            Instance.new("UICorner", valueBox).CornerRadius = UDim.new(0, 6)

            local selectedText = Instance.new("TextLabel", valueBox)
            selectedText.Size = UDim2.new(1, -15, 1, 0)
            selectedText.Position = UDim2.new(0, 0, 0, 0)
            selectedText.Text = "Select..."
            selectedText.TextColor3 = Color3.fromRGB(150, 165, 185)
            selectedText.Font = Enum.Font.Gotham
            selectedText.TextSize = 11
            selectedText.BackgroundTransparency = 1
            selectedText.TextTruncate = Enum.TextTruncate.AtEnd
            selectedText.TextXAlignment = Enum.TextXAlignment.Right

            local listHeight = math.min(#options * 32, 130) 
            local listFrame = Instance.new("ScrollingFrame", container)
            listFrame.Size = UDim2.new(1, 0, 0, listHeight)
            listFrame.Position = UDim2.new(0, 0, 0, 45)
            listFrame.BackgroundTransparency = 1
            listFrame.BorderSizePixel = 0
            listFrame.ScrollBarThickness = 3
            listFrame.Active = true
            listFrame.ScrollingDirection = Enum.ScrollingDirection.Y
            listFrame.CanvasSize = UDim2.new(0, 0, 0, #options * 32)

            local isExpanded = false
            topBar.MouseButton1Click:Connect(function()
                isExpanded = not isExpanded
                local targetHeight = isExpanded and (45 + listHeight) or 45
                TweenService:Create(container, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(0.9, 0, 0, targetHeight)}):Play()
            end)

            for i, opt in ipairs(options) do
                local itemBtn = Instance.new("TextButton", listFrame)
                itemBtn.Size = UDim2.new(1, 0, 0, 32)
                itemBtn.Position = UDim2.new(0, 0, 0, (i-1)*32)
                itemBtn.BackgroundColor3 = Color3.fromRGB(28, 33, 42)
                itemBtn.Text = ""
                itemBtn.BorderSizePixel = 0

                local checkBg = Instance.new("Frame", itemBtn)
                checkBg.Size = UDim2.new(0, 14, 0, 14)
                checkBg.Position = UDim2.new(0, 15, 0.5, -7)
                checkBg.BackgroundColor3 = Color3.fromRGB(50, 60, 75)
                Instance.new("UICorner", checkBg).CornerRadius = UDim.new(1, 0)

                local checkFill = Instance.new("Frame", checkBg)
                checkFill.Size = UDim2.new(1, -4, 1, -4)
                checkFill.Position = UDim2.new(0, 2, 0, 2)
                checkFill.BackgroundColor3 = THEME_BLUE
                checkFill.Visible = false 
                Instance.new("UICorner", checkFill).CornerRadius = UDim.new(1, 0)

                local itemText = Instance.new("TextLabel", itemBtn)
                itemText.Size = UDim2.new(1, -45, 1, 0)
                itemText.Position = UDim2.new(0, 38, 0, 0)
                itemText.Text = opt
                itemText.TextColor3 = Color3.fromRGB(190, 200, 215)
                itemText.Font = Enum.Font.Gotham
                itemText.TextSize = 11
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
                        el.Fill.Visible = (el.Option == selectedItem)
                    end

                    isExpanded = false
                    TweenService:Create(container, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(0.9, 0, 0, 45)}):Play()
                    pcall(function() callback(selectedItem) end)
                end)
            end
            return container
        end

        -- 9. CreateColorPicker
        function TabData:CreateColorPicker(cpName, defaultColor, callback)
            local currentColor = defaultColor or Color3.fromRGB(255, 255, 255)
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 45)
            container.BackgroundColor3 = Color3.fromRGB(24, 28, 36)
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
            Instance.new("UIStroke", container).Color = Color3.fromRGB(50, 60, 75)

            local title = Instance.new("TextLabel", container)
            title.Size = UDim2.new(0.6, 0, 1, 0)
            title.Position = UDim2.new(0, 15, 0, 0)
            title.Text = cpName
            title.TextColor3 = Color3.new(1, 1, 1)
            title.Font = Enum.Font.GothamMedium
            title.TextSize = 12
            title.BackgroundTransparency = 1
            title.TextXAlignment = Enum.TextXAlignment.Left

            local preview = Instance.new("TextButton", container)
            preview.Size = UDim2.new(0, 35, 0, 24)
            preview.Position = UDim2.new(1, -45, 0.5, -12)
            preview.BackgroundColor3 = currentColor
            preview.Text = ""
            Instance.new("UICorner", preview).CornerRadius = UDim.new(0, 6)

            local colors = {
                Color3.fromRGB(255, 255, 255),
                Color3.fromRGB(255, 50, 50),
                Color3.fromRGB(50, 150, 255),
                Color3.fromRGB(50, 220, 100),
                Color3.fromRGB(255, 200, 50)
            }
            local colorIndex = 1

            preview.MouseButton1Click:Connect(function()
                colorIndex = colorIndex % #colors + 1
                currentColor = colors[colorIndex]
                preview.BackgroundColor3 = currentColor
                pcall(function() callback(currentColor) end)
            end)

            return container
        end

        -- 10. CreateKeybind
        function TabData:CreateKeybind(kbName, defaultKey, callback)
            local currentKey = defaultKey or Enum.KeyCode.RightShift
            local bound = false

            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 45)
            container.BackgroundColor3 = Color3.fromRGB(24, 28, 36)
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
            Instance.new("UIStroke", container).Color = Color3.fromRGB(50, 60, 75)

            local title = Instance.new("TextLabel", container)
            title.Size = UDim2.new(0.5, 0, 1, 0)
            title.Position = UDim2.new(0, 15, 0, 0)
            title.Text = kbName
            title.TextColor3 = Color3.new(1, 1, 1)
            title.Font = Enum.Font.GothamMedium
            title.TextSize = 12
            title.BackgroundTransparency = 1
            title.TextXAlignment = Enum.TextXAlignment.Left

            local keyBtn = Instance.new("TextButton", container)
            keyBtn.Size = UDim2.new(0, 80, 0, 26)
            keyBtn.Position = UDim2.new(1, -95, 0.5, -13)
            keyBtn.BackgroundColor3 = Color3.fromRGB(35, 42, 52)
            keyBtn.Text = tostring(currentKey.Name)
            keyBtn.TextColor3 = Color3.new(1, 1, 1)
            keyBtn.Font = Enum.Font.GothamBold
            keyBtn.TextSize = 11
            Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0, 6)

            keyBtn.MouseButton1Click:Connect(function()
                bound = true
                keyBtn.Text = "..."
            end)

            UserInputService.InputBegan:Connect(function(input)
                if bound and input.UserInputType == Enum.UserInputType.Keyboard then
                    currentKey = input.KeyCode
                    keyBtn.Text = tostring(currentKey.Name)
                    bound = false
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