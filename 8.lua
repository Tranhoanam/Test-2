-- =========================================================================
-- NEMOZ UI LIBRARY - BẢN CẬP NHẬT KẾ TIẾP (HYPEROS 4 & DRAGON & TIME)
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

    -- ==========================================
    -- 1 & 3 & 4. MÀN HÌNH MỞ ĐẦU (INTRO SCREEN - 5 GIÂY)
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

    -- Lớp sao trời / hạt bụi thời gian
    for i = 1, 35 do
        local star = Instance.new("Frame", IntroBackground)
        star.Size = UDim2.new(0, math.random(2, 4), 0, math.random(2, 4))
        star.Position = UDim2.new(math.random(), 0, math.random(), 0)
        star.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        star.BackgroundTransparency = math.random(3, 8) / 10
        star.BorderSizePixel = 0
        Instance.new("UICorner", star).CornerRadius = UDim.new(1, 0)
    end

    -- Lớp trung tâm: Hình khối vuông góc tròn xoay vòng (Mô phỏng chuẩn ảnh mẫu)
    local CenterHolder = Instance.new("Frame", IntroBackground)
    CenterHolder.Size = UDim2.new(0, 120, 0, 120)
    CenterHolder.Position = UDim2.new(0.5, -60, 0.4, -60)
    CenterHolder.BackgroundTransparency = 1
    CenterHolder.ZIndex = 2

    local rotatingSquares = {}
    for i = 1, 12 do
        local sq = Instance.new("Frame", CenterHolder)
        sq.Size = UDim2.new(0, 22, 0, 22)
        sq.AnchorPoint = Vector2.new(0.5, 0.5)
        sq.Position = UDim2.new(0.5, 0, 0.5, 0)
        sq.BackgroundColor3 = Color3.fromRGB(46, 80, 144) -- #2E5090 YInMn Blue
        sq.BorderSizePixel = 0
        Instance.new("UICorner", sq).CornerRadius = UDim.new(0, 6)
        table.insert(rotatingSquares, sq)
    end

    -- Hiệu ứng xoay vòng liên tục cho các khối
    task.spawn(function()
        local angle = 0
        while IntroGui and IntroGui.Parent do
            angle = angle + 2
            for index, sq in ipairs(rotatingSquares) do
                local rad = math.rad(angle + (index * 30))
                local radiusDist = 42 + (index % 2 * 6)
                local x = math.cos(rad) * radiusDist
                local y = math.sin(rad) * radiusDist
                sq.Position = UDim2.new(0.5, x, 0.5, y)
                sq.Rotation = angle * 1.5
            end
            RunService.RenderStepped:Wait()
        end
    end)

    local IntroSound = Instance.new("Sound", IntroGui)
    IntroSound.SoundId = "rbxassetid://125090389445721"
    IntroSound.Volume = 1
    pcall(function() IntroSound:Play() end)

    local IntroTitle = Instance.new("TextLabel", IntroBackground)
    IntroTitle.Size = UDim2.new(1, 0, 0, 80)
    IntroTitle.Position = UDim2.new(0, 0, 0.65, 0)
    IntroTitle.BackgroundTransparency = 1
    IntroTitle.TextColor3 = Color3.fromRGB(46, 80, 144)
    IntroTitle.Font = Enum.Font.GothamBold
    IntroTitle.TextSize = 32
    IntroTitle.ZIndex = 3
    IntroTitle.TextXAlignment = Enum.TextXAlignment.Center

    -- Hiệu ứng gõ phím / hiển thị từng ký tự chậm rãi (Text Animation)
    task.spawn(function()
        task.wait(0.5)
        local fullName = Name
        for i = 1, #fullName do
            if not IntroTitle or not IntroTitle.Parent then break end
            IntroTitle.Text = string.sub(fullName, 1, i)
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
    -- 2, 5, 6, 7, 10. MENU CHÍNH (MAIN WINDOW) & HỆ THỐNG AURA 4 LỚP
    -- ==========================================
    local ScreenGui = Instance.new("ScreenGui", TargetParent)
    ScreenGui.Name = "NemoZ_MainOnlyMenu"
    ScreenGui.IgnoreGuiInset = true

    -- Hệ thống đa lớp Aura bọc ngoài Menu chính (4 lớp lan rộng mờ dần)
    local AuraLayer4 = Instance.new("Frame", ScreenGui)
    AuraLayer4.Size = UDim2.new(0, 560, 0, 360)
    AuraLayer4.Position = UDim2.new(0.5, -280, 0.5, -180)
    AuraLayer4.BackgroundColor3 = Color3.fromRGB(46, 80, 144)
    AuraLayer4.BackgroundTransparency = 0.92
    AuraLayer4.BorderSizePixel = 0
    Instance.new("UICorner", AuraLayer4).CornerRadius = UDim.new(0, 24)

    local AuraLayer3 = Instance.new("Frame", ScreenGui)
    AuraLayer3.Size = UDim2.new(0, 540, 0, 340)
    AuraLayer3.Position = UDim2.new(0.5, -270, 0.5, -170)
    AuraLayer3.BackgroundColor3 = Color3.fromRGB(46, 80, 144)
    AuraLayer3.BackgroundTransparency = 0.85
    AuraLayer3.BorderSizePixel = 0
    Instance.new("UICorner", AuraLayer3).CornerRadius = UDim.new(0, 20)

    local AuraLayer2 = Instance.new("Frame", ScreenGui)
    AuraLayer2.Size = UDim2.new(0, 520, 0, 320)
    AuraLayer2.Position = UDim2.new(0.5, -260, 0.5, -160)
    AuraLayer2.BackgroundColor3 = Color3.fromRGB(46, 80, 144)
    AuraLayer2.BackgroundTransparency = 0.75
    AuraLayer2.BorderSizePixel = 0
    Instance.new("UICorner", AuraLayer2).CornerRadius = UDim.new(0, 18)

    local AuraLayer1 = Instance.new("Frame", ScreenGui)
    AuraLayer1.Size = UDim2.new(0, 508, 0, 308)
    AuraLayer1.Position = UDim2.new(0.5, -254, 0.5, -154)
    AuraLayer1.BackgroundColor3 = Color3.fromRGB(46, 80, 144)
    AuraLayer1.BackgroundTransparency = 0.6
    AuraLayer1.BorderSizePixel = 0
    Instance.new("UICorner", AuraLayer1).CornerRadius = UDim.new(0, 16)

    MainWindow = Instance.new("Frame", ScreenGui)
    MainWindow.Size = UDim2.new(0, 500, 0, 300)
    MainWindow.Position = UDim2.new(0.5, -250, 0.5, -150)
    MainWindow.BackgroundColor3 = Color3.fromRGB(54, 69, 79) -- #36454F Charcoal Gray
    MainWindow.BorderSizePixel = 0
    MainWindow.Active = true
    MainWindow.Visible = false 

    Instance.new("UICorner", MainWindow).CornerRadius = UDim.new(0, 14)
    
    local MainStroke = Instance.new("UIStroke", MainWindow)
    MainStroke.Color = Color3.fromRGB(46, 80, 144)
    MainStroke.Thickness = 1.5

    -- Họa tiết chìm "vải rồng" (Dragon Pattern Texture mô phỏng bằng các đường nét hoa văn chìm tinh tế)
    local DragonPattern = Instance.new("ImageLabel", MainWindow)
    DragonPattern.Size = UDim2.new(1, 0, 1, 0)
    DragonPattern.BackgroundTransparency = 1
    DragonPattern.Image = "rbxassetid://6071575925"
    DragonPattern.ImageColor3 = Color3.fromRGB(46, 80, 144)
    DragonPattern.ImageTransparency = 0.88
    DragonPattern.ScaleType = Enum.ScaleType.Tile
    DragonPattern.TileSize = UDim2.new(0, 100, 0, 100)

    -- Đồng bộ vị trí cho các lớp Aura theo cửa sổ chính
    RunService.RenderStepped:Connect(function()
        if MainWindow and MainWindow.Parent then
            local absPos = MainWindow.AbsolutePosition
            local absSize = MainWindow.AbsoluteSize
            AuraLayer1.Position = UDim2.new(0, absPos.X - 4, 0, absPos.Y - 4)
            AuraLayer2.Position = UDim2.new(0, absPos.X - 10, 0, absPos.Y - 10)
            AuraLayer3.Position = UDim2.new(0, absPos.X - 20, 0, absPos.Y - 20)
            AuraLayer4.Position = UDim2.new(0, absPos.X - 30, 0, absPos.Y - 30)
        end
    end)

    -- Header & Quản lý Thao tác Kéo thả (Dragging)
    local Header = Instance.new("Frame", MainWindow)
    Header.Size = UDim2.new(1, 0, 0, 75)
    Header.BackgroundColor3 = Color3.fromRGB(46, 80, 144)
    Header.BorderSizePixel = 0
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 14)

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
    Title.Size = UDim2.new(0.35, 0, 0.45, 0)
    Title.Position = UDim2.new(0.04, 0, 0.05, 0)
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.GothamBold
    Title.BackgroundTransparency = 1
    Title.TextSize = 15
    Title.TextXAlignment = Enum.TextXAlignment.Left

    -- 12 & 13. Tái Cấu Trúc Header: Thêm Nút "Home" & Quản Lý Cấu Hình
    local HomeButton = Instance.new("TextButton", Header)
    HomeButton.Size = UDim2.new(0, 55, 0, 26)
    HomeButton.Position = UDim2.new(0.55, 0, 0.12, 0)
    HomeButton.Text = "Home"
    HomeButton.TextColor3 = Color3.new(1, 1, 1)
    HomeButton.Font = Enum.Font.GothamMedium
    HomeButton.TextSize = 11
    HomeButton.BackgroundColor3 = Color3.fromRGB(54, 69, 79)
    Instance.new("UICorner", HomeButton).CornerRadius = UDim.new(0, 6)

    -- Nút Stats mới: Hình chữ nhật góc tròn mềm mại (UICorner 6px) thay vì pill-shaped
    local StatsButton = Instance.new("TextButton", Header)
    StatsButton.Size = UDim2.new(0, 55, 0, 26)
    StatsButton.Position = UDim2.new(0.69, 0, 0.12, 0)
    StatsButton.Text = "Stats"
    StatsButton.TextColor3 = Color3.new(1, 1, 1)
    StatsButton.Font = Enum.Font.GothamMedium
    StatsButton.TextSize = 11
    StatsButton.BackgroundColor3 = Color3.fromRGB(54, 69, 79)
    Instance.new("UICorner", StatsButton).CornerRadius = UDim.new(0, 6)

    local Close = Instance.new("TextButton", Header)
    Close.Size = UDim2.new(0, 26, 0, 26)
    Close.Position = UDim2.new(0.89, 0, 0.12, 0)
    Close.Text = "×"
    Close.TextColor3 = Color3.new(1, 1, 1)
    Close.Font = Enum.Font.GothamBold
    Close.TextSize = 14
    Close.BackgroundColor3 = Color3.fromRGB(54, 69, 79)
    Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 6)

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
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Center
        return lbl
    end

    local PingLabel = createStatLabel(0)
    local FpsLabel = createStatLabel(0.33)
    local LossLabel = createStatLabel(0.66)

    local Sidebar = Instance.new("ScrollingFrame", MainWindow)
    Sidebar.Size = UDim2.new(0, 130, 1, -75)
    Sidebar.Position = UDim2.new(0, 0, 0, 75)
    Sidebar.BackgroundColor3 = Color3.fromRGB(42, 53, 62)
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 2
    Sidebar.Active = true
    Sidebar.ScrollingDirection = Enum.ScrollingDirection.Y
    Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)

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

    -- Khu vực đặc quyền bảng điều khiển Home (Tích hợp RGB Color Gradient Picker chart & tùy chỉnh màu sắc chủ đạo)
    local HomePage = Instance.new("ScrollingFrame", PageContainer)
    HomePage.Size = UDim2.new(1, 0, 1, 0)
    HomePage.BackgroundTransparency = 1
    HomePage.ScrollBarThickness = 4
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

    -- Tạo bảng điều khiển Home độc quyền chứa ColorPicker RGB gradient tùy chỉnh màu sắc #2E5090 và #36454F
    local function setupHomeExclusivePanel()
        local homeLabel = Instance.new("TextLabel", HomePage)
        homeLabel.Size = UDim2.new(0.9, 0, 0, 35)
        homeLabel.BackgroundTransparency = 1
        homeLabel.Text = "  Nemo-Z Theme & Color Control Center"
        homeLabel.TextColor3 = Color3.fromRGB(220, 225, 235)
        homeLabel.Font = Enum.Font.GothamBold
        homeLabel.TextSize = 13
        homeLabel.TextXAlignment = Enum.TextXAlignment.Left

        -- CreateColorPicker to gấp bốn lần (Đặc quyền khu vực Home cho PC & Điện thoại)
        local cpContainer = Instance.new("Frame", HomePage)
        cpContainer.Size = UDim2.new(0.9, 0, 0, 160) -- Kích thước phóng lớn gấp 4 lần tiêu chuẩn thông thường
        cpContainer.BackgroundColor3 = Color3.fromRGB(42, 53, 62)
        Instance.new("UICorner", cpContainer).CornerRadius = UDim.new(0, 12)
        Instance.new("UIStroke", cpContainer).Color = Color3.fromRGB(46, 80, 144)

        local cpTitle = Instance.new("TextLabel", cpContainer)
        cpTitle.Size = UDim2.new(1, -20, 0, 30)
        cpTitle.Position = UDim2.new(0, 10, 0, 8)
        cpTitle.BackgroundTransparency = 1
        cpTitle.Text = "RGB Color Gradient Picker (Chart - HyperOS 4 Theme)"
        cpTitle.TextColor3 = Color3.new(1, 1, 1)
        cpTitle.Font = Enum.Font.GothamBold
        cpTitle.TextSize = 12
        cpTitle.TextXAlignment = Enum.TextXAlignment.Left

        -- Biểu đồ màu RGB Gradient (mô phỏng chart hình ảnh hướng dẫn)
        local chartBar = Instance.new("Frame", cpContainer)
        chartBar.Size = UDim2.new(1, -30, 0, 75)
        chartBar.Position = UDim2.new(0, 15, 0, 42)
        chartBar.BackgroundColor3 = Color3.new(1, 1, 1)
        Instance.new("UICorner", chartBar).CornerRadius = UDim.new(0, 8)

        local uigradient = Instance.new("UIGradient", chartBar)
        uigradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
        })

        -- Vòng tròn nhỏ điều chuyển màu sắc cho điện thoại và PC
        local colorKnob = Instance.new("Frame", chartBar)
        colorKnob.Size = UDim2.new(0, 18, 0, 18)
        colorKnob.AnchorPoint = Vector2.new(0.5, 0.5)
        colorKnob.Position = UDim2.new(0.35, 0, 0.5, 0)
        colorKnob.BackgroundColor3 = Color3.fromRGB(46, 80, 144)
        Instance.new("UICorner", colorKnob).CornerRadius = UDim.new(1, 0)
        local knobStroke = Instance.new("UIStroke", colorKnob)
        knobStroke.Color = Color3.new(1, 1, 1)
        knobStroke.Thickness = 2

        local colorInfo = Instance.new("TextLabel", cpContainer)
        colorInfo.Size = UDim2.new(1, -30, 0, 25)
        colorInfo.Position = UDim2.new(0, 15, 0, 125)
        colorInfo.BackgroundTransparency = 1
        colorInfo.Text = "Active Color Target: #2E5090 & #36454F (HyperOS 4 Dragon Mode)"
        colorInfo.TextColor3 = Color3.fromRGB(180, 190, 205)
        colorInfo.Font = Enum.Font.GothamMedium
        colorInfo.TextSize = 11
        colorInfo.TextXAlignment = Enum.TextXAlignment.Center

        local cpHitbox = Instance.new("TextButton", chartBar)
        cpHitbox.Size = UDim2.new(1, 0, 1, 0)
        cpHitbox.BackgroundTransparency = 1
        cpHitbox.Text = ""

        local isPicking = false
        cpHitbox.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isPicking = true
                local relX = math.clamp((input.Position.X - chartBar.AbsolutePosition.X) / chartBar.AbsoluteSize.X, 0, 1)
                colorKnob.Position = UDim2.new(relX, 0, 0.5, 0)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if isPicking and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local relX = math.clamp((input.Position.X - chartBar.AbsolutePosition.X) / chartBar.AbsoluteSize.X, 0, 1)
                colorKnob.Position = UDim2.new(relX, 0, 0.5, 0)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isPicking = false
            end
        end)
    end
    setupHomeExclusivePanel()

    HomeButton.MouseButton1Click:Connect(function()
        for i, btn in ipairs(Window.TabButtons) do
            btn.BackgroundColor3 = Color3.fromRGB(42, 53, 62)
            btn.TextColor3 = Color3.fromRGB(150, 150, 150)
            Window.TabPages[i].Visible = false
        end
        HomePage.Visible = true
        HomeButton.BackgroundColor3 = Color3.fromRGB(46, 80, 144)
    end)

    -- ==========================================
    -- 15. CỐ ĐỊNH TUYỆT ĐỐI MINI MENU (NemoZ_DeltaCustomMiniMenu)
    -- ==========================================
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
    MiniUIStroke.Transparency = 0.5

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
        
        if endY <= 3 then
            MiniMainFrame.BackgroundColor3 = Color3.fromRGB(54, 69, 79)
            MiniTopOverlay.BackgroundColor3 = Color3.fromRGB(54, 69, 79)
            MiniUICorner.CornerRadius = UDim.new(0, 12)
            MiniTopOverlay.Visible = true
            MiniMainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, 0)
        else
            MiniMainFrame.BackgroundColor3 = Color3.fromRGB(42, 53, 62)
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
        AuraLayer1.Visible = false
        AuraLayer2.Visible = false
        AuraLayer3.Visible = false
        AuraLayer4.Visible = false
        MiniMainFrame.Visible = true
    end)

    MiniOpenButton.MouseButton1Click:Connect(function()
        MainWindow.Visible = true
        AuraLayer1.Visible = true
        AuraLayer2.Visible = true
        AuraLayer3.Visible = true
        AuraLayer4.Visible = true
        MiniMainFrame.Visible = false
    end)

    local isMini = false
    StatsButton.MouseButton1Click:Connect(function()
        isMini = not isMini
        MainWindow.Size = isMini and UDim2.new(0, 500, 0, 75) or UDim2.new(0, 500, 0, 300)
        Sidebar.Visible = not isMini
        PageContainer.Visible = not isMini
    end)

    -- FPS, Ping & Loss Counter
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
    -- 11 & 17. TẠO TAB & HỆ THỐNG CÁC NÚT CREATE ĐẦY ĐỦ (CHUẨN RAYFIELD / REDZ)
    -- ==========================================
    function Window:CreateTab(name, imageId)
        local TabData = {}
        
        local tabBtn = Instance.new("TextButton", Sidebar)
        tabBtn.Size = UDim2.new(0.9, 0, 0, 35)
        tabBtn.BackgroundColor3 = Color3.fromRGB(54, 69, 79)
        tabBtn.Text = "  " .. name
        tabBtn.TextColor3 = Color3.fromRGB(160, 170, 185)
        tabBtn.Font = Enum.Font.GothamMedium
        tabBtn.TextSize = 12
        tabBtn.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 8)

        local icon = Instance.new("ImageLabel", tabBtn)
        icon.Size = UDim2.new(0, 16, 0, 16)
        icon.Position = UDim2.new(1, -24, 0.5, -8)
        icon.BackgroundTransparency = 1
        icon.Image = "rbxassetid://" .. tostring(imageId)
        icon.ImageColor3 = Color3.fromRGB(160, 170, 185)

        local page = Instance.new("ScrollingFrame", PageContainer)
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.ScrollBarThickness = 4
        page.Visible = false
        page.Active = true
        page.ScrollingDirection = Enum.ScrollingDirection.Y
        
        local pagePadding = Instance.new("UIPadding", page)
        pagePadding.PaddingTop = UDim.new(0, 15)
        
        local pageLayout = Instance.new("UIListLayout", page)
        pageLayout.Padding = UDim.new(0, 12)
        pageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

        pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 30)
        end)

        tabBtn.MouseButton1Click:Connect(function()
            for i, btn in ipairs(Window.TabButtons) do
                btn.BackgroundColor3 = Color3.fromRGB(54, 69, 79)
                btn.TextColor3 = Color3.fromRGB(160, 170, 185)
                if btn:FindFirstChildOfClass("ImageLabel") then
                    btn:FindFirstChildOfClass("ImageLabel").ImageColor3 = Color3.fromRGB(160, 170, 185)
                end
                Window.TabPages[i].Visible = false
            end
            HomePage.Visible = false
            HomeButton.BackgroundColor3 = Color3.fromRGB(54, 69, 79)

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

        -- 9. Hàm CreateButton với 2 lớp aura bọc ngoài nổi khối
        function TabData:CreateButton(btnName, callback)
            local outerAura2 = Instance.new("Frame", page)
            outerAura2.Size = UDim2.new(0.9, 8, 0, 49)
            outerAura2.BackgroundColor3 = Color3.fromRGB(46, 80, 144)
            outerAura2.BackgroundTransparency = 0.8
            outerAura2.BorderSizePixel = 0
            Instance.new("UICorner", outerAura2).CornerRadius = UDim.new(0, 12)

            local outerAura1 = Instance.new("Frame", outerAura2)
            outerAura1.Size = UDim2.new(1, -4, 1, -4)
            outerAura1.Position = UDim2.new(0, 2, 0, 2)
            outerAura1.BackgroundColor3 = Color3.fromRGB(46, 80, 144)
            outerAura1.BackgroundTransparency = 0.5
            outerAura1.BorderSizePixel = 0
            Instance.new("UICorner", outerAura1).CornerRadius = UDim.new(0, 10)

            local btn = Instance.new("TextButton", outerAura1)
            btn.Size = UDim2.new(1, -4, 1, -4)
            btn.Position = UDim2.new(0, 2, 0, 2)
            btn.BackgroundColor3 = Color3.fromRGB(54, 69, 79)
            btn.Text = "  " .. btnName
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Font = Enum.Font.GothamMedium
            btn.TextSize = 13
            btn.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
            
            local stroke = Instance.new("UIStroke", btn)
            stroke.Color = Color3.fromRGB(46, 80, 144)
            stroke.Thickness = 1.2

            btn.MouseButton1Click:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(46, 80, 144)}):Play()
                task.delay(0.1, function()
                    TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(54, 69, 79)}):Play()
                end)
                pcall(callback)
            end)
            return outerAura2
        end

        function TabData:CreateToggle(toggleName, callback)
            local state = false
            local btn = Instance.new("TextButton", page)
            btn.Size = UDim2.new(0.9, 0, 0, 45)
            btn.BackgroundColor3 = Color3.fromRGB(54, 69, 79)
            btn.Text = "  " .. toggleName 
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Font = Enum.Font.GothamMedium
            btn.TextSize = 13
            btn.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
            
            local stroke = Instance.new("UIStroke", btn)
            stroke.Color = Color3.fromRGB(46, 80, 144)
            stroke.Thickness = 1.2
            
            local sliderBg = Instance.new("Frame", btn)
            sliderBg.Size = UDim2.new(0, 46, 0, 24)
            sliderBg.Position = UDim2.new(1, -56, 0.5, -12)
            sliderBg.BackgroundColor3 = Color3.fromRGB(42, 53, 62) 
            Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)
            
            local sliderKnob = Instance.new("Frame", sliderBg)
            sliderKnob.Size = UDim2.new(0, 20, 0, 20)
            sliderKnob.Position = UDim2.new(0, 2, 0.5, -10)
            sliderKnob.BackgroundColor3 = Color3.new(1, 1, 1)
            Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)
            
            btn.MouseButton1Click:Connect(function()
                state = not state
                sliderBg.BackgroundColor3 = state and Color3.fromRGB(46, 80, 144) or Color3.fromRGB(42, 53, 62)
                TweenService:Create(sliderKnob, TweenInfo.new(0.15), {Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)}):Play()
                pcall(function() callback(state) end)
            end)
            return btn
        end

        function TabData:CreateSlider(sliderName, min, max, callback)
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 55)
            container.BackgroundColor3 = Color3.fromRGB(54, 69, 79)
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
            Instance.new("UIStroke", container).Color = Color3.fromRGB(46, 80, 144)
            
            local title = Instance.new("TextLabel", container)
            title.Size = UDim2.new(0.35, 0, 1, 0)
            title.Position = UDim2.new(0, 15, 0, 0)
            title.Text = sliderName
            title.TextColor3 = Color3.new(1, 1, 1)
            title.Font = Enum.Font.GothamMedium
            title.BackgroundTransparency = 1
            title.TextSize = 13
            title.TextXAlignment = Enum.TextXAlignment.Left

            local valueBox = Instance.new("TextBox", container)
            valueBox.Size = UDim2.new(0, 45, 0, 26)
            valueBox.Position = UDim2.new(1, -60, 0.5, -13) 
            valueBox.BackgroundColor3 = Color3.fromRGB(42, 53, 62)
            valueBox.Text = tostring(max)
            valueBox.TextColor3 = Color3.new(1, 1, 1)
            valueBox.Font = Enum.Font.GothamBold
            valueBox.TextSize = 12
            Instance.new("UICorner", valueBox).CornerRadius = UDim.new(0, 5)

            local sliderBg = Instance.new("Frame", container)
            sliderBg.Size = UDim2.new(0.38, 0, 0, 5)
            sliderBg.Position = UDim2.new(0.38, 0, 0.5, -2) 
            sliderBg.BackgroundColor3 = Color3.fromRGB(42, 53, 62)
            Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

            local progress = Instance.new("Frame", sliderBg)
            progress.Size = UDim2.new(1, 0, 1, 0)
            progress.BackgroundColor3 = Color3.fromRGB(46, 80, 144)
            Instance.new("UICorner", progress).CornerRadius = UDim.new(1, 0)

            local knob = Instance.new("Frame", sliderBg)
            knob.AnchorPoint = Vector2.new(0.5, 0.5) 
            knob.Size = UDim2.new(0, 14, 0, 14)
            knob.Position = UDim2.new(1, 0, 0.5, 0)
            knob.BackgroundColor3 = Color3.new(1, 1, 1)
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

            local hitbox = Instance.new("TextButton", sliderBg)
            hitbox.AnchorPoint = Vector2.new(0.5, 0.5)
            hitbox.Size = UDim2.new(1, 20, 0, 30) 
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
            return container
        end

        function TabData:CreateDropdown(dropName, options, callback)
            local selectedItems = {}
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 45) 
            container.BackgroundColor3 = Color3.fromRGB(54, 69, 79)
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
            title.TextSize = 13
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.BackgroundTransparency = 1

            local valueBox = Instance.new("Frame", topBar)
            valueBox.Size = UDim2.new(0, 100, 0, 25) 
            valueBox.Position = UDim2.new(1, -135, 0.5, -12)
            valueBox.BackgroundColor3 = Color3.fromRGB(42, 53, 62)
            Instance.new("UICorner", valueBox).CornerRadius = UDim.new(0, 5)

            local selectedText = Instance.new("TextLabel", valueBox)
            selectedText.Size = UDim2.new(1, -10, 1, 0)
            selectedText.Position = UDim2.new(0, 5, 0, 0)
            selectedText.Text = "Select..."
            selectedText.TextColor3 = Color3.fromRGB(160, 170, 185)
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

            local listHeight = math.min(#options * 32, 130) 
            local listFrame = Instance.new("ScrollingFrame", container)
            listFrame.Size = UDim2.new(1, 0, 0, listHeight)
            listFrame.Position = UDim2.new(0, 0, 0, 45)
            listFrame.BackgroundTransparency = 1
            listFrame.BorderSizePixel = 0
            listFrame.ScrollBarThickness = 4
            listFrame.Active = true
            listFrame.ScrollingDirection = Enum.ScrollingDirection.Y
            listFrame.CanvasSize = UDim2.new(0, 0, 0, #options * 32)

            local isExpanded = false
            topBar.MouseButton1Click:Connect(function()
                isExpanded = not isExpanded
                local targetHeight = isExpanded and (45 + listHeight) or 45
                TweenService:Create(container, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(0.9, 0, 0, targetHeight)}):Play()
                TweenService:Create(dropIcon, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Rotation = isExpanded and 180 or 0}):Play()
            end)

            for i, opt in ipairs(options) do
                local itemBtn = Instance.new("TextButton", listFrame)
                itemBtn.Size = UDim2.new(1, 0, 0, 32)
                itemBtn.Position = UDim2.new(0, 0, 0, (i-1)*32)
                itemBtn.BackgroundColor3 = Color3.fromRGB(48, 60, 70)
                itemBtn.Text = ""
                itemBtn.BorderSizePixel = 0

                local checkBg = Instance.new("Frame", itemBtn)
                checkBg.Size = UDim2.new(0, 14, 0, 14)
                checkBg.Position = UDim2.new(0, 15, 0.5, -7)
                checkBg.BackgroundColor3 = Color3.fromRGB(42, 53, 62)
                Instance.new("UICorner", checkBg).CornerRadius = UDim.new(0, 4)

                local checkFill = Instance.new("Frame", checkBg)
                checkFill.Size = UDim2.new(1, -4, 1, -4)
                checkFill.Position = UDim2.new(0, 2, 0, 2)
                checkFill.BackgroundColor3 = Color3.fromRGB(46, 80, 144)
                checkFill.Visible = false 
                Instance.new("UICorner", checkFill).CornerRadius = UDim.new(0, 2)

                local itemText = Instance.new("TextLabel", itemBtn)
                itemText.Size = UDim2.new(1, -45, 1, 0)
                itemText.Position = UDim2.new(0, 38, 0, 0)
                itemText.Text = opt
                itemText.TextColor3 = Color3.fromRGB(200, 210, 220)
                itemText.Font = Enum.Font.Gotham
                itemText.TextSize = 12
                itemText.TextXAlignment = Enum.TextXAlignment.Left
                itemText.BackgroundTransparency = 1

                itemBtn.MouseButton1Click:Connect(function()
                    local idx = table.find(selectedItems, opt)
                    if idx then
                        table.remove(selectedItems, idx)
                        checkFill.Visible = false
                        itemText.TextColor3 = Color3.fromRGB(200, 210, 220)
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
                        selectedText.TextColor3 = Color3.fromRGB(160, 170, 185)
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
            title.TextSize = 13
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.BackgroundTransparency = 1

            local valueBox = Instance.new("Frame", topBar)
            valueBox.Size = UDim2.new(0, 100, 0, 25) 
            valueBox.Position = UDim2.new(1, -135, 0.5, -12)
            valueBox.BackgroundColor3 = Color3.fromRGB(42, 53, 62)
            Instance.new("UICorner", valueBox).CornerRadius = UDim.new(0, 5)

            local selectedText = Instance.new("TextLabel", valueBox)
            selectedText.Size = UDim2.new(1, -10, 1, 0)
            selectedText.Position = UDim2.new(0, 5, 0, 0)
            selectedText.Text = "Select..."
            selectedText.TextColor3 = Color3.fromRGB(160, 170, 185)
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

            local listHeight = math.min(#options * 32, 130) 
            local listFrame = Instance.new("ScrollingFrame", container)
            listFrame.Size = UDim2.new(1, 0, 0, listHeight)
            listFrame.Position = UDim2.new(0, 0, 0, 45)
            listFrame.BackgroundTransparency = 1
            listFrame.BorderSizePixel = 0
            listFrame.ScrollBarThickness = 4
            listFrame.Active = true
            listFrame.ScrollingDirection = Enum.ScrollingDirection.Y
            listFrame.CanvasSize = UDim2.new(0, 0, 0, #options * 32)

            local isExpanded = false
            topBar.MouseButton1Click:Connect(function()
                isExpanded = not isExpanded
                local targetHeight = isExpanded and (45 + listHeight) or 45
                TweenService:Create(container, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(0.9, 0, 0, targetHeight)}):Play()
                TweenService:Create(dropIcon, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Rotation = isExpanded and 180 or 0}):Play()
            end)

            for i, opt in ipairs(options) do
                local itemBtn = Instance.new("TextButton", listFrame)
                itemBtn.Size = UDim2.new(1, 0, 0, 32)
                itemBtn.Position = UDim2.new(0, 0, 0, (i-1)*32)
                itemBtn.BackgroundColor3 = Color3.fromRGB(48, 60, 70)
                itemBtn.Text = ""
                itemBtn.BorderSizePixel = 0

                local checkBg = Instance.new("Frame", itemBtn)
                checkBg.Size = UDim2.new(0, 14, 0, 14)
                checkBg.Position = UDim2.new(0, 15, 0.5, -7)
                checkBg.BackgroundColor3 = Color3.fromRGB(42, 53, 62)
                Instance.new("UICorner", checkBg).CornerRadius = UDim.new(1, 0)

                local checkFill = Instance.new("Frame", checkBg)
                checkFill.Size = UDim2.new(1, -4, 1, -4)
                checkFill.Position = UDim2.new(0, 2, 0, 2)
                checkFill.BackgroundColor3 = Color3.fromRGB(46, 80, 144)
                checkFill.Visible = false 
                Instance.new("UICorner", checkFill).CornerRadius = UDim.new(1, 0)

                local itemText = Instance.new("TextLabel", itemBtn)
                itemText.Size = UDim2.new(1, -45, 1, 0)
                itemText.Position = UDim2.new(0, 38, 0, 0)
                itemText.Text = opt
                itemText.TextColor3 = Color3.fromRGB(200, 210, 220)
                itemText.Font = Enum.Font.Gotham
                itemText.TextSize = 12
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
                            el.TextLabel.TextColor3 = Color3.fromRGB(200, 210, 220)
                        end
                    end

                    isExpanded = false
                    TweenService:Create(container, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(0.9, 0, 0, 45)}):Play()
                    TweenService:Create(dropIcon, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Rotation = 0}):Play()

                    pcall(function() callback(selectedItem) end)
                end)
            end
            return container
        end

        function TabData:CreateTextBox(boxName, placeholder, callback)
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 45)
            container.BackgroundColor3 = Color3.fromRGB(54, 69, 79)
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
            local stroke = Instance.new("UIStroke", container)
            stroke.Color = Color3.fromRGB(46, 80, 144)
            stroke.Thickness = 1.2

            local title = Instance.new("TextLabel", container)
            title.Size = UDim2.new(0.35, 0, 1, 0)
            title.Position = UDim2.new(0, 15, 0, 0)
            title.Text = boxName
            title.TextColor3 = Color3.new(1, 1, 1)
            title.Font = Enum.Font.GothamMedium
            title.BackgroundTransparency = 1
            title.TextSize = 13
            title.TextXAlignment = Enum.TextXAlignment.Left

            local inputBox = Instance.new("TextBox", container)
            inputBox.Size = UDim2.new(0, 140, 0, 26)
            inputBox.Position = UDim2.new(1, -155, 0.5, -13)
            inputBox.BackgroundColor3 = Color3.fromRGB(42, 53, 62)
            inputBox.Text = ""
            inputBox.PlaceholderText = placeholder or "Type..."
            inputBox.PlaceholderColor3 = Color3.fromRGB(130, 140, 155)
            inputBox.TextColor3 = Color3.new(1, 1, 1)
            inputBox.Font = Enum.Font.Gotham
            inputBox.TextSize = 12
            Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 5)

            inputBox.Focused:Connect(function()
                TweenService:Create(stroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(80, 150, 255)}):Play()
            end)

            inputBox.FocusLost:Connect(function(enterPressed)
                TweenService:Create(stroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(46, 80, 144)}):Play()
                pcall(function() callback(inputBox.Text, enterPressed) end)
            end)
            return container
        end

        function TabData:CreateLabel(labelText)
            local label = Instance.new("TextLabel", page)
            label.Size = UDim2.new(0.9, 0, 0, 28)
            label.BackgroundTransparency = 1
            label.Text = "  " .. labelText
            label.TextColor3 = Color3.fromRGB(190, 200, 215)
            label.Font = Enum.Font.GothamMedium
            label.TextSize = 12
            label.TextXAlignment = Enum.TextXAlignment.Left
            return label
        end

        -- Bổ sung hàm CreateParagraph chuẩn Rayfield
        function TabData:CreateParagraph(paraTitle, paraContent)
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 75)
            container.BackgroundColor3 = Color3.fromRGB(54, 69, 79)
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
            Instance.new("UIStroke", container).Color = Color3.fromRGB(46, 80, 144)

            local title = Instance.new("TextLabel", container)
            title.Size = UDim2.new(1, -20, 0, 25)
            title.Position = UDim2.new(0, 12, 0, 6)
            title.BackgroundTransparency = 1
            title.Text = paraTitle
            title.TextColor3 = Color3.new(1, 1, 1)
            title.Font = Enum.Font.GothamBold
            title.TextSize = 13
            title.TextXAlignment = Enum.TextXAlignment.Left

            local content = Instance.new("TextLabel", container)
            content.Size = UDim2.new(1, -20, 0, 40)
            content.Position = UDim2.new(0, 12, 0, 28)
            content.BackgroundTransparency = 1
            content.Text = paraContent
            content.TextColor3 = Color3.fromRGB(180, 190, 205)
            content.Font = Enum.Font.Gotham
            content.TextSize = 11
            content.TextWrapped = true
            content.TextXAlignment = Enum.TextXAlignment.Left
            content.TextYAlignment = Enum.TextYAlignment.Top
            return container
        end

        -- Bổ sung hàm CreateSection phân chia nhóm chức năng
        function TabData:CreateSection(secName)
            local sec = Instance.new("TextLabel", page)
            sec.Size = UDim2.new(0.9, 0, 0, 32)
            sec.BackgroundTransparency = 1
            sec.Text = "--- " .. secName .. " ---"
            sec.TextColor3 = Color3.fromRGB(46, 80, 144)
            sec.Font = Enum.Font.GothamBold
            sec.TextSize = 12
            sec.TextXAlignment = Enum.TextXAlignment.Left
            return sec
        end

        -- Bổ sung hàm CreateKeybind cài đặt phím tắt ẩn hiện menu
        function TabData:CreateKeybind(keyName, defaultKey, callback)
            local currentKey = defaultKey
            local listening = false

            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 45)
            container.BackgroundColor3 = Color3.fromRGB(54, 69, 79)
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
            Instance.new("UIStroke", container).Color = Color3.fromRGB(46, 80, 144)

            local title = Instance.new("TextLabel", container)
            title.Size = UDim2.new(0.5, 0, 1, 0)
            title.Position = UDim2.new(0, 15, 0, 0)
            title.BackgroundTransparency = 1
            title.Text = keyName
            title.TextColor3 = Color3.new(1, 1, 1)
            title.Font = Enum.Font.GothamMedium
            title.TextSize = 13
            title.TextXAlignment = Enum.TextXAlignment.Left

            local bindBtn = Instance.new("TextButton", container)
            bindBtn.Size = UDim2.new(0, 90, 0, 26)
            bindBtn.Position = UDim2.new(1, -105, 0.5, -13)
            bindBtn.BackgroundColor3 = Color3.fromRGB(42, 53, 62)
            bindBtn.Text = tostring(defaultKey.Name)
            bindBtn.TextColor3 = Color3.fromRGB(200, 210, 220)
            bindBtn.Font = Enum.Font.GothamBold
            bindBtn.TextSize = 11
            Instance.new("UICorner", bindBtn).CornerRadius = UDim.new(0, 5)

            bindBtn.MouseButton1Click:Connect(function()
                listening = true
                bindBtn.Text = "..."
                bindBtn.TextColor3 = Color3.fromRGB(80, 150, 255)
            end)

            UserInputService.InputBegan:Connect(function(input, gp)
                if listening then
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        currentKey = input.KeyCode
                        bindBtn.Text = tostring(currentKey.Name)
                        bindBtn.TextColor3 = Color3.fromRGB(200, 210, 220)
                        listening = false
                        pcall(function() callback(currentKey) end)
                    end
                elseif not gp and input.KeyCode == currentKey then
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