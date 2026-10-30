-- =========================================================================
-- NEMOZ UI LIBRARY - BẢN CẬP NHẬT TOÀN DIỆN (HYPEROS 4 & DRAGON TIME)
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

-- Global Theme Colors
local THEME_BLUE = Color3.fromRGB(46, 80, 144)    -- #2E5090 YInMn Blue
local THEME_CHARCOAL = Color3.fromRGB(54, 69, 79) -- #36454F Charcoal Gray
local THEME_DARK = Color3.fromRGB(18, 19, 23)

function NemoZLibrary:CreateWindow(config)
    local Window = {
        TabButtons = {},
        TabPages = {},
        CurrentAuraColor = THEME_BLUE
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

    -- Lớp sao trời (Time Dust Particles)
    local StarsContainer = Instance.new("Folder", IntroBackground)
    StarsContainer.Name = "StarsContainer"
    math.randomseed(tick())
    for i = 1, 40 do
        local star = Instance.new("Frame", StarsContainer)
        star.Size = UDim2.new(0, math.random(2, 4), 0, math.random(2, 4))
        star.Position = UDim2.new(math.random(), 0, math.random(), 0)
        star.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        star.BackgroundTransparency = math.random(20, 70) / 100
        Instance.new("UICorner", star).CornerRadius = UDim.new(1, 0)
    end

    -- Lớp trung tâm: Hình khối xoay vòng tròn chuẩn mẫu ảnh[span_1](start_span)[span_1](end_span)
    local CenterCluster = Instance.new("Frame", IntroBackground)
    CenterCluster.Size = UDim2.new(0, 120, 0, 120)
    CenterCluster.Position = UDim2.new(0.5, -60, 0.4, -60)
    CenterCluster.BackgroundTransparency = 1

    local squares = {}
    local numSquares = 12
    for i = 1, numSquares do
        local sq = Instance.new("Frame", CenterCluster)
        sq.Size = UDim2.new(0, 22, 0, 22)
        sq.AnchorPoint = Vector2.new(0.5, 0.5)
        local angle = (i / numSquares) * (math.pi * 2)
        local radius = 45
        sq.Position = UDim2.new(0.5, math.cos(angle) * radius, 0.5, math.sin(angle) * radius)
        sq.BackgroundColor3 = THEME_BLUE
        sq.BorderSizePixel = 0
        Instance.new("UICorner", sq).CornerRadius = UDim.new(0, 6)
        table.insert(squares, sq)
    end

    local rotConn
    local currentRotation = 0
    rotConn = RunService.RenderStepped:Connect(function(dt)
        if CenterCluster and CenterCluster.Parent then
            currentRotation = currentRotation + (dt * 60)
            CenterCluster.Rotation = currentRotation
        else
            if rotConn then rotConn:Disconnect() end
        end
    end)

    local IntroSound = Instance.new("Sound", IntroGui)
    IntroSound.SoundId = "rbxassetid://125090389445721"
    IntroSound.Volume = 1
    pcall(function() IntroSound:Play() end)

    -- Lớp trên cùng: Text Animation gõ phím ký tự chậm rãi
    local IntroTitle = Instance.new("TextLabel", IntroBackground)
    IntroTitle.Size = UDim2.new(1, 0, 0, 80)
    IntroTitle.Position = UDim2.new(0, 0, 0.62, 0)
    IntroTitle.BackgroundTransparency = 1
    IntroTitle.TextColor3 = THEME_BLUE
    IntroTitle.Font = Enum.Font.GothamBold
    IntroTitle.TextSize = 42
    IntroTitle.TextXAlignment = Enum.TextXAlignment.Center
    IntroTitle.Text = ""

    task.spawn(function()
        task.wait(0.5)
        local targetStr = Name
        for i = 1, #targetStr do
            IntroTitle.Text = string.sub(targetStr, 1, i)
            task.wait(0.12)
        end
    end)

    task.delay(5, function()
        if rotConn then rotConn:Disconnect() end
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
    -- 2 & 10. MENU CHÍNH (MAIN WINDOW) & 4 LỚP AURA KHỔNG LỒ & HỌA TIẾT RỒNG
    -- ==========================================
    local ScreenGui = Instance.new("ScreenGui", TargetParent)
    ScreenGui.Name = "NemoZ_MainOnlyMenu"
    ScreenGui.IgnoreGuiInset = true

    local AuraLayers = {}
    for i = 4, 1, -1 do
        local aura = Instance.new("Frame", ScreenGui)
        aura.Name = "AuraLayer_" .. i
        aura.Size = UDim2.new(0, 500 + (i * 18), 0, 320 + (i * 18))
        aura.Position = UDim2.new(0.5, -250 - (i * 9), 0.5, -160 - (i * 9))
        aura.BackgroundColor3 = THEME_BLUE
        aura.BackgroundTransparency = 0.75 + (i * 0.05)
        aura.BorderSizePixel = 0
        Instance.new("UICorner", aura).CornerRadius = UDim.new(0, 18 + i)
        table.insert(AuraLayers, aura)
    end

    MainWindow = Instance.new("Frame", ScreenGui)
    MainWindow.Size = UDim2.new(0, 500, 0, 320)
    MainWindow.Position = UDim2.new(0.5, -250, 0.5, -160)
    MainWindow.BackgroundColor3 = THEME_CHARCOAL
    MainWindow.BorderSizePixel = 0
    MainWindow.Active = true
    MainWindow.Visible = false 
    
    Instance.new("UICorner", MainWindow).CornerRadius = UDim.new(0, 16)
    
    local MainStroke = Instance.new("UIStroke", MainWindow)
    MainStroke.Color = THEME_BLUE
    MainStroke.Thickness = 1.5
    MainStroke.Transparency = 0.3

    local DragonPattern = Instance.new("ImageLabel", MainWindow)
    DragonPattern.Name = "DragonPattern"
    DragonPattern.Size = UDim2.new(1, 0, 1, 0)
    DragonPattern.BackgroundTransparency = 1
    DragonPattern.Image = "rbxassetid://6071579801"
    DragonPattern.ImageTransparency = 0.88
    DragonPattern.ScaleType = Enum.ScaleType.Tile
    DragonPattern.TileSize = UDim2.new(0, 100, 0, 100)
    DragonPattern.ZIndex = 1

    local Header = Instance.new("Frame", MainWindow)
    Header.Size = UDim2.new(1, 0, 0, 75)
    Header.BackgroundColor3 = Color3.fromRGB(30, 40, 48)
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
            local newPos = UDim2.new(mainStartPos.X.Scale, mainStartPos.X.Offset + delta.X, mainStartPos.Y.Scale, mainStartPos.Y.Offset + delta.Y)
            MainWindow.Position = newPos
            for idx, aura in ipairs(AuraLayers) do
                aura.Position = UDim2.new(newPos.X.Scale, newPos.X.Offset - (idx * 9), newPos.Y.Scale, newPos.Y.Offset - (idx * 9))
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
    Title.ZIndex = 3

    local HomeButton = Instance.new("TextButton", Header)
    HomeButton.Size = UDim2.new(0, 55, 0, 28)
    HomeButton.Position = UDim2.new(0.58, 0, 0.12, 0)
    HomeButton.Text = "Home"
    HomeButton.TextColor3 = Color3.new(1, 1, 1)
    HomeButton.Font = Enum.Font.GothamMedium
    HomeButton.TextSize = 12
    HomeButton.BackgroundColor3 = THEME_BLUE
    HomeButton.ZIndex = 3
    Instance.new("UICorner", HomeButton).CornerRadius = UDim.new(0, 8)

    local StatsButton = Instance.new("TextButton", Header)
    StatsButton.Size = UDim2.new(0, 55, 0, 28)
    StatsButton.Position = UDim2.new(0.72, 0, 0.12, 0)
    StatsButton.Text = "Stats"
    StatsButton.TextColor3 = Color3.new(1, 1, 1)
    StatsButton.Font = Enum.Font.GothamMedium
    StatsButton.TextSize = 12
    StatsButton.BackgroundColor3 = Color3.fromRGB(60, 75, 90)
    StatsButton.ZIndex = 3
    Instance.new("UICorner", StatsButton).CornerRadius = UDim.new(0, 8)

    local Close = Instance.new("TextButton", Header)
    Close.Size = UDim2.new(0, 28, 0, 28)
    Close.Position = UDim2.new(0.89, 0, 0.12, 0)
    Close.Text = "×"
    Close.TextColor3 = Color3.new(1, 1, 1)
    Close.Font = Enum.Font.GothamBold
    Close.TextSize = 14
    Close.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    Close.ZIndex = 3
    Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 8)

    local StatsFrame = Instance.new("Frame", Header)
    StatsFrame.Size = UDim2.new(1, 0, 0.45, 0)
    StatsFrame.Position = UDim2.new(0, 0, 0.52, 0)
    StatsFrame.BackgroundTransparency = 1
    StatsFrame.ZIndex = 3

    local function createStatLabel(posX)
        local lbl = Instance.new("TextLabel", StatsFrame)
        lbl.Size = UDim2.new(0.33, 0, 1, 0)
        lbl.Position = UDim2.new(posX, 0, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Center
        lbl.ZIndex = 3
        return lbl
    end

    local PingLabel = createStatLabel(0)
    local FpsLabel = createStatLabel(0.33)
    local LossLabel = createStatLabel(0.66)

    local Sidebar = Instance.new("ScrollingFrame", MainWindow)
    Sidebar.Size = UDim2.new(0, 130, 1, -75)
    Sidebar.Position = UDim2.new(0, 0, 0, 75)
    Sidebar.BackgroundColor3 = Color3.fromRGB(25, 34, 42)
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 2
    Sidebar.Active = true
    Sidebar.ZIndex = 2
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
    PageContainer.ZIndex = 2

    -- Khu vực Home đặc quyền
    local HomePage = Instance.new("ScrollingFrame", PageContainer)
    HomePage.Size = UDim2.new(1, 0, 1, 0)
    HomePage.BackgroundTransparency = 1
    HomePage.ScrollBarThickness = 4
    HomePage.ScrollBarImageColor3 = THEME_BLUE
    HomePage.Visible = true
    HomePage.Active = true
    HomePage.ScrollingDirection = Enum.ScrollingDirection.Y
    
    local homePadding = Instance.new("UIPadding", HomePage)
    homePadding.PaddingTop = UDim.new(0, 15)
    local homeLayout = Instance.new("UIListLayout", HomePage)
    homeLayout.Padding = UDim.new(0, 12)
    homeLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    homeLayout.SortOrder = Enum.SortOrder.LayoutOrder

    homeLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        HomePage.CanvasSize = UDim2.new(0, 0, 0, homeLayout.AbsoluteContentSize.Y + 30)
    end)

    local function setupHomeExclusivePanel()
        local welcomeLbl = Instance.new("TextLabel", HomePage)
        welcomeLbl.Size = UDim2.new(0.9, 0, 0, 35)
        welcomeLbl.BackgroundTransparency = 1
        welcomeLbl.Text = "  Cài Đặt Giao Diện & Hệ Thống (Home)"
        welcomeLbl.TextColor3 = Color3.new(1, 1, 1)
        welcomeLbl.Font = Enum.Font.GothamBold
        welcomeLbl.TextSize = 13
        welcomeLbl.TextXAlignment = Enum.TextXAlignment.Left

        local cpContainer = Instance.new("Frame", HomePage)
        cpContainer.Size = UDim2.new(0.9, 0, 0, 50)
        cpContainer.BackgroundColor3 = Color3.fromRGB(30, 40, 48)
        Instance.new("UICorner", cpContainer).CornerRadius = UDim.new(0, 10)
        local cpStroke = Instance.new("UIStroke", cpContainer)
        cpStroke.Color = THEME_BLUE
        cpStroke.Thickness = 1.2

        local cpTitle = Instance.new("TextLabel", cpContainer)
        cpTitle.Size = UDim2.new(0.5, 0, 1, 0)
        cpTitle.Position = UDim2.new(0, 15, 0, 0)
        cpTitle.Text = "Aura Theme Color"
        cpTitle.TextColor3 = Color3.new(1, 1, 1)
        cpTitle.Font = Enum.Font.GothamMedium
        cpTitle.BackgroundTransparency = 1
        cpTitle.TextXAlignment = Enum.TextXAlignment.Left

        local colorBox = Instance.new("TextButton", cpContainer)
        colorBox.Size = UDim2.new(0, 70, 0, 28)
        colorBox.Position = UDim2.new(1, -85, 0.5, -14)
        colorBox.BackgroundColor3 = THEME_BLUE
        colorBox.Text = "Change"
        colorBox.TextColor3 = Color3.new(1, 1, 1)
        colorBox.Font = Enum.Font.GothamBold
        colorBox.TextSize = 11
        Instance.new("UICorner", colorBox).CornerRadius = UDim.new(0, 6)

        local colorsList = {Color3.fromRGB(46, 80, 144), Color3.fromRGB(144, 46, 80), Color3.fromRGB(46, 144, 80), Color3.fromRGB(144, 120, 46), Color3.fromRGB(120, 46, 144)}
        local colorIdx = 1
        colorBox.MouseButton1Click:Connect(function()
            colorIdx = colorIdx % #colorsList + 1
            local selectedColor = colorsList[colorIdx]
            Window.CurrentAuraColor = selectedColor
            colorBox.BackgroundColor3 = selectedColor
            MainStroke.Color = selectedColor
            cpStroke.Color = selectedColor
            for _, aura in ipairs(AuraLayers) do
                aura.BackgroundColor3 = selectedColor
            end
        end)

        local toggleContainer = Instance.new("Frame", HomePage)
        toggleContainer.Size = UDim2.new(0.9, 0, 0, 50)
        toggleContainer.BackgroundColor3 = Color3.fromRGB(30, 40, 48)
        Instance.new("UICorner", toggleContainer).CornerRadius = UDim.new(0, 10)
        Instance.new("UIStroke", toggleContainer).Color = THEME_BLUE

        local tTitle = Instance.new("TextLabel", toggleContainer)
        tTitle.Size = UDim2.new(0.6, 0, 1, 0)
        tTitle.Position = UDim2.new(0, 15, 0, 0)
        tTitle.Text = "Auto Save Settings"
        tTitle.TextColor3 = Color3.new(1, 1, 1)
        tTitle.Font = Enum.Font.GothamMedium
        tTitle.BackgroundTransparency = 1
        tTitle.TextXAlignment = Enum.TextXAlignment.Left

        local saveState = true
        local sToggleBtn = Instance.new("TextButton", toggleContainer)
        sToggleBtn.Size = UDim2.new(0, 48, 0, 24)
        sToggleBtn.Position = UDim2.new(1, -60, 0.5, -12)
        sToggleBtn.BackgroundColor3 = THEME_BLUE
        sToggleBtn.Text = ""
        Instance.new("UICorner", sToggleBtn).CornerRadius = UDim.new(1, 0)

        local sKnob = Instance.new("Frame", sToggleBtn)
        sKnob.Size = UDim2.new(0.5, 0, 1, 0)
        sKnob.Position = UDim2.new(0.5, 0, 0, 0)
        sKnob.BackgroundColor3 = Color3.new(1, 1, 1)
        Instance.new("UICorner", sKnob).CornerRadius = UDim.new(1, 0)

        sToggleBtn.MouseButton1Click:Connect(function()
            saveState = not saveState
            sToggleBtn.BackgroundColor3 = saveState and Window.CurrentAuraColor or Color3.fromRGB(60, 60, 60)
            sKnob.Position = saveState and UDim2.new(0.5, 0, 0, 0) or UDim2.new(0, 0, 0, 0)
        end)
    end
    setupHomeExclusivePanel()

    -- ==========================================
    -- 3. MINI MENU THU NHỎ (BẢO TOÀN TUYỆT ĐỐI)
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
    MiniMainFrame.ZIndex = 10
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
    MiniTopOverlay.ZIndex = 11

    local MiniDragButton = Instance.new("ImageButton", MiniMainFrame)
    MiniDragButton.Name = "DragButton"
    MiniDragButton.Size = UDim2.new(0, 42, 0, 40)
    MiniDragButton.Position = UDim2.new(0, 0, 0, 0)
    MiniDragButton.BackgroundTransparency = 1
    MiniDragButton.Image = "rbxassetid://94225529221725"
    MiniDragButton.ZIndex = 12

    local MiniDivider = Instance.new("Frame", MiniMainFrame)
    MiniDivider.Name = "Divider"
    MiniDivider.Size = UDim2.new(0, 1, 0, 20)
    MiniDivider.Position = UDim2.new(0, 42, 0, 10)
    MiniDivider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MiniDivider.BackgroundTransparency = 0.8
    MiniDivider.BorderSizePixel = 0
    MiniDivider.ZIndex = 12

    local MiniOpenButton = Instance.new("TextButton", MiniMainFrame)
    MiniOpenButton.Name = "OpenButton"
    MiniOpenButton.Size = UDim2.new(0, 85, 0, 40)
    MiniOpenButton.Position = UDim2.new(0, 46, 0, 0)
    MiniOpenButton.BackgroundTransparency = 1
    MiniOpenButton.Text = "open"
    MiniOpenButton.TextColor3 = Color3.fromRGB(230, 235, 245)
    MiniOpenButton.TextSize = 15
    MiniOpenButton.Font = Enum.Font.GothamBold
    MiniOpenButton.ZIndex = 12

    local dragging, dragInput, dragStart, startPos
    local function updateMini(input)
        local delta = input.Position - dragStart
        local endY = startPos.Y.Offset + delta.Y
        if endY < 0 then endY = 0 end
        MiniUIStroke.Transparency = 1 
        
        if endY <= 3 then
            MiniMainFrame.BackgroundColor3 = Color3.fromRGB(18, 19, 23)
            MiniTopOverlay.BackgroundColor3 = Color3.fromRGB(18, 19, 23)
            MiniUICorner.CornerRadius = UDim.new(0, 12)
            MiniTopOverlay.Visible = true
            MiniMainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, 0)
        else
            MiniMainFrame.BackgroundColor3 = Color3.fromRGB(24, 26, 32)
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
        for _, aura in ipairs(AuraLayers) do aura.Visible = false end
        MiniMainFrame.Visible = true
    end)

    MiniOpenButton.MouseButton1Click:Connect(function()
        MainWindow.Visible = true
        for _, aura in ipairs(AuraLayers) do aura.Visible = true end
        MiniMainFrame.Visible = false
    end)

    local isMini = false
    StatsButton.MouseButton1Click:Connect(function()
        isMini = not isMini
        MainWindow.Size = isMini and UDim2.new(0, 500, 0, 75) or UDim2.new(0, 500, 0, 320)
        Sidebar.Visible = not isMini
        PageContainer.Visible = not isMini
        for i, aura in ipairs(AuraLayers) do
            aura.Size = isMini and UDim2.new(0, 500 + (i * 18), 0, 75 + (i * 18)) or UDim2.new(0, 500 + (i * 18), 0, 320 + (i * 18))
        end
    end)

    HomeButton.MouseButton1Click:Connect(function()
        for i, btn in ipairs(Window.TabButtons) do
            btn.BackgroundColor3 = Color3.fromRGB(30, 42, 52)
            btn.TextColor3 = Color3.fromRGB(150, 150, 150)
            Window.TabPages[i].Visible = false
        end
        HomePage.Visible = true
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
            FpsLabel.TextColor3 = (fps < 30) and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(80, 180, 255)
            
            PingLabel.Text = "PING: " .. ping
            PingLabel.TextColor3 = (ping > 100) and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(80, 180, 255)
            
            LossLabel.Text = "LOSS: 0%"
            LossLabel.TextColor3 = Color3.fromRGB(80, 180, 255)
            
            lastTick = tick()
            frames = 0
        end
    end)

    -- ==========================================
    -- 4. TẠO TAB & CÁC THÀNH PHẦN (BỔ SUNG ĐẦY ĐỦ CREATE MỚI)
    -- ==========================================
    function Window:CreateTab(name, imageId)
        local TabData = {}
        
        local tabBtn = Instance.new("TextButton", Sidebar)
        tabBtn.Size = UDim2.new(0.9, 0, 0, 35)
        tabBtn.BackgroundColor3 = Color3.fromRGB(30, 42, 52)
        tabBtn.Text = "   " .. name
        tabBtn.TextColor3 = Color3.fromRGB(160, 170, 185)
        tabBtn.Font = Enum.Font.GothamMedium
        tabBtn.TextSize = 12
        tabBtn.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 8)

        if imageId then
            local icon = Instance.new("ImageLabel", tabBtn)
            icon.Size = UDim2.new(0, 16, 0, 16)
            icon.Position = UDim2.new(0, 8, 0.5, -8)
            icon.BackgroundTransparency = 1
            icon.Image = "rbxassetid://" .. tostring(imageId)
            icon.ImageColor3 = Color3.fromRGB(160, 170, 185)
        end

        local page = Instance.new("ScrollingFrame", PageContainer)
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.ScrollBarThickness = 4
        page.ScrollBarImageColor3 = THEME_BLUE
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
                btn.BackgroundColor3 = Color3.fromRGB(30, 42, 52)
                btn.TextColor3 = Color3.fromRGB(160, 170, 185)
                if btn:FindFirstChildOfClass("ImageLabel") then
                    btn:FindFirstChildOfClass("ImageLabel").ImageColor3 = Color3.fromRGB(160, 170, 185)
                end
                Window.TabPages[i].Visible = false
            end
            tabBtn.BackgroundColor3 = Window.CurrentAuraColor
            tabBtn.TextColor3 = Color3.new(1, 1, 1)
            if tabBtn:FindFirstChildOfClass("ImageLabel") then
                tabBtn:FindFirstChildOfClass("ImageLabel").ImageColor3 = Color3.new(1, 1, 1)
            end
            page.Visible = true
        end)

        table.insert(Window.TabButtons, tabBtn)
        table.insert(Window.TabPages, page)

        function TabData:CreateSection(secName)
            local sec = Instance.new("TextLabel", page)
            sec.Size = UDim2.new(0.9, 0, 0, 25)
            sec.BackgroundTransparency = 1
            sec.Text = "  " .. string.upper(secName)
            sec.TextColor3 = Color3.fromRGB(120, 140, 170)
            sec.Font = Enum.Font.GothamBold
            sec.TextSize = 11
            sec.TextXAlignment = Enum.TextXAlignment.Left
            return sec
        end

        function TabData:CreateParagraph(paraConfig)
            local title = paraConfig.Title or "Paragraph"
            local content = paraConfig.Content or ""

            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 65)
            container.BackgroundColor3 = Color3.fromRGB(24, 32, 40)
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
            Instance.new("UIStroke", container).Color = Color3.fromRGB(50, 65, 80)

            local tLbl = Instance.new("TextLabel", container)
            tLbl.Size = UDim2.new(1, -20, 0, 22)
            tLbl.Position = UDim2.new(0, 10, 0, 6)
            tLbl.BackgroundTransparency = 1
            tLbl.Text = title
            tLbl.TextColor3 = Color3.new(1, 1, 1)
            tLbl.Font = Enum.Font.GothamBold
            tLbl.TextSize = 12
            tLbl.TextXAlignment = Enum.TextXAlignment.Left

            local cLbl = Instance.new("TextLabel", container)
            cLbl.Size = UDim2.new(1, -20, 0, 32)
            cLbl.Position = UDim2.new(0, 10, 0, 26)
            cLbl.BackgroundTransparency = 1
            cLbl.Text = content
            cLbl.TextColor3 = Color3.fromRGB(170, 180, 195)
            cLbl.Font = Enum.Font.Gotham
            cLbl.TextSize = 11
            cLbl.TextWrapped = true
            cLbl.TextXAlignment = Enum.TextXAlignment.Left
            cLbl.TextYAlignment = Enum.TextYAlignment.Top

            return container
        end

        function TabData:CreateButton(btnName, callback)
            local btn = Instance.new("TextButton", page)
            btn.Size = UDim2.new(0.9, 0, 0, 42)
            btn.BackgroundColor3 = Color3.fromRGB(24, 32, 40)
            btn.Text = "  " .. btnName
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Font = Enum.Font.GothamMedium
            btn.TextSize = 12
            btn.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
            
            local stroke = Instance.new("UIStroke", btn)
            stroke.Color = Color3.fromRGB(50, 65, 80)
            stroke.Thickness = 1.2

            btn.MouseButton1Click:Connect(callback)
            return btn
        end

        function TabData:CreateToggle(toggleName, callback)
            local state = false
            local btn = Instance.new("TextButton", page)
            btn.Size = UDim2.new(0.9, 0, 0, 42)
            btn.BackgroundColor3 = Color3.fromRGB(24, 32, 40)
            btn.Text = "  " .. toggleName 
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Font = Enum.Font.GothamMedium
            btn.TextSize = 12
            btn.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
            
            local stroke = Instance.new("UIStroke", btn)
            stroke.Color = Color3.fromRGB(50, 65, 80)
            stroke.Thickness = 1.2
            
            local sliderBg = Instance.new("Frame", btn)
            sliderBg.Size = UDim2.new(0, 44, 0, 22)
            sliderBg.Position = UDim2.new(1, -54, 0.5, -11)
            sliderBg.BackgroundColor3 = Color3.fromRGB(50, 65, 80) 
            Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)
            
            local sliderKnob = Instance.new("Frame", sliderBg)
            sliderKnob.Size = UDim2.new(0.5, 0, 1, 0)
            sliderKnob.BackgroundColor3 = Color3.new(1, 1, 1)
            Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)
            
            btn.MouseButton1Click:Connect(function()
                state = not state
                sliderBg.BackgroundColor3 = state and Window.CurrentAuraColor or Color3.fromRGB(50, 65, 80)
                sliderKnob.Position = state and UDim2.new(0.5, 0, 0, 0) or UDim2.new(0, 0, 0, 0)
                pcall(function() callback(state) end)
            end)
            return btn
        end

        function TabData:CreateDropdown(dropName, options, callback)
            local selectedItems = {}
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 42) 
            container.BackgroundColor3 = Color3.fromRGB(24, 32, 40)
            container.ClipsDescendants = true 
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
            Instance.new("UIStroke", container).Color = Color3.fromRGB(50, 65, 80)

            local topBar = Instance.new("TextButton", container)
            topBar.Size = UDim2.new(1, 0, 0, 42)
            topBar.BackgroundTransparency = 1
            topBar.Text = ""

            local title = Instance.new("TextLabel", topBar)
            title.Size = UDim2.new(0.4, 0, 1, 0)
            title.Position = UDim2.new(0, 12, 0, 0)
            title.Text = dropName
            title.TextColor3 = Color3.new(1, 1, 1)
            title.Font = Enum.Font.GothamMedium
            title.TextSize = 12
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.BackgroundTransparency = 1

            local valueBox = Instance.new("Frame", topBar)
            valueBox.Size = UDim2.new(0, 100, 0, 24) 
            valueBox.Position = UDim2.new(1, -130, 0.5, -12)
            valueBox.BackgroundColor3 = Color3.fromRGB(35, 45, 55)
            Instance.new("UICorner", valueBox).CornerRadius = UDim.new(0, 6)

            local selectedText = Instance.new("TextLabel", valueBox)
            selectedText.Size = UDim2.new(1, -12, 1, 0)
            selectedText.Position = UDim2.new(0, 0, 0, 0)
            selectedText.Text = "Select..."
            selectedText.TextColor3 = Color3.fromRGB(150, 160, 175)
            selectedText.Font = Enum.Font.Gotham
            selectedText.TextSize = 11
            selectedText.BackgroundTransparency = 1
            selectedText.TextTruncate = Enum.TextTruncate.AtEnd
            selectedText.TextXAlignment = Enum.TextXAlignment.Right

            local dropIcon = Instance.new("ImageLabel", topBar)
            dropIcon.Size = UDim2.new(0, 16, 0, 16)
            dropIcon.Position = UDim2.new(1, -22, 0.5, -8)
            dropIcon.Image = "rbxassetid://5279719038"
            dropIcon.BackgroundTransparency = 1

            local listHeight = math.min(#options * 32, 130) 
            local listFrame = Instance.new("ScrollingFrame", container)
            listFrame.Size = UDim2.new(1, 0, 0, listHeight)
            listFrame.Position = UDim2.new(0, 0, 0, 42)
            listFrame.BackgroundTransparency = 1
            listFrame.BorderSizePixel = 0
            listFrame.ScrollBarThickness = 3
            listFrame.Active = true
            listFrame.ScrollingDirection = Enum.ScrollingDirection.Y
            listFrame.CanvasSize = UDim2.new(0, 0, 0, #options * 32)

            local isExpanded = false
            topBar.MouseButton1Click:Connect(function()
                isExpanded = not isExpanded
                local targetHeight = isExpanded and (42 + listHeight) or 42
                TweenService:Create(container, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Size = UDim2.new(0.9, 0, 0, targetHeight)}):Play()
                TweenService:Create(dropIcon, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Rotation = isExpanded and 180 or 0}):Play()
            end)

            for i, opt in ipairs(options) do
                local itemBtn = Instance.new("TextButton", listFrame)
                itemBtn.Size = UDim2.new(1, 0, 0, 32)
                itemBtn.Position = UDim2.new(0, 0, 0, (i-1)*32)
                itemBtn.BackgroundColor3 = Color3.fromRGB(28, 36, 46)
                itemBtn.Text = ""
                itemBtn.BorderSizePixel = 0

                local checkBg = Instance.new("Frame", itemBtn)
                checkBg.Size = UDim2.new(0, 14, 0, 14)
                checkBg.Position = UDim2.new(0, 12, 0.5, -7)
                checkBg.BackgroundColor3 = Color3.fromRGB(50, 65, 80)
                Instance.new("UICorner", checkBg).CornerRadius = UDim.new(0, 4)

                local checkFill = Instance.new("Frame", checkBg)
                checkFill.Size = UDim2.new(1, -4, 1, -4)
                checkFill.Position = UDim2.new(0, 2, 0, 2)
                checkFill.BackgroundColor3 = Window.CurrentAuraColor
                checkFill.Visible = false 
                Instance.new("UICorner", checkFill).CornerRadius = UDim.new(0, 2)

                local itemText = Instance.new("TextLabel", itemBtn)
                itemText.Size = UDim2.new(1, -40, 1, 0)
                itemText.Position = UDim2.new(0, 36, 0, 0)
                itemText.Text = opt
                itemText.TextColor3 = Color3.fromRGB(190, 200, 215)
                itemText.Font = Enum.Font.Gotham
                itemText.TextSize = 12
                itemText.TextXAlignment = Enum.TextXAlignment.Left
                itemText.BackgroundTransparency = 1

                itemBtn.MouseButton1Click:Connect(function()
                    local idx = table.find(selectedItems, opt)
                    if idx then
                        table.remove(selectedItems, idx)
                        checkFill.Visible = false
                        itemText.TextColor3 = Color3.fromRGB(190, 200, 215)
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
                        selectedText.TextColor3 = Color3.fromRGB(150, 160, 175)
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
            container.Size = UDim2.new(0.9, 0, 0, 42) 
            container.BackgroundColor3 = Color3.fromRGB(24, 32, 40)
            container.ClipsDescendants = true 
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
            Instance.new("UIStroke", container).Color = Color3.fromRGB(50, 65, 80)

            local topBar = Instance.new("TextButton", container)
            topBar.Size = UDim2.new(1, 0, 0, 42)
            topBar.BackgroundTransparency = 1
            topBar.Text = ""

            local title = Instance.new("TextLabel", topBar)
            title.Size = UDim2.new(0.4, 0, 1, 0)
            title.Position = UDim2.new(0, 12, 0, 0)
            title.Text = dropName
            title.TextColor3 = Color3.new(1, 1, 1)
            title.Font = Enum.Font.GothamMedium
            title.TextSize = 12
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.BackgroundTransparency = 1

            local valueBox = Instance.new("Frame", topBar)
            valueBox.Size = UDim2.new(0, 100, 0, 24) 
            valueBox.Position = UDim2.new(1, -130, 0.5, -12)
            valueBox.BackgroundColor3 = Color3.fromRGB(35, 45, 55)
            Instance.new("UICorner", valueBox).CornerRadius = UDim.new(0, 6)

            local selectedText = Instance.new("TextLabel", valueBox)
            selectedText.Size = UDim2.new(1, -12, 1, 0)
            selectedText.Position = UDim2.new(0, 0, 0, 0)
            selectedText.Text = "Select..."
            selectedText.TextColor3 = Color3.fromRGB(150, 160, 175)
            selectedText.Font = Enum.Font.Gotham
            selectedText.TextSize = 11
            selectedText.BackgroundTransparency = 1
            selectedText.TextTruncate = Enum.TextTruncate.AtEnd
            selectedText.TextXAlignment = Enum.TextXAlignment.Right

            local dropIcon = Instance.new("ImageLabel", topBar)
            dropIcon.Size = UDim2.new(0, 16, 0, 16)
            dropIcon.Position = UDim2.new(1, -22, 0.5, -8)
            dropIcon.Image = "rbxassetid://5279719038"
            dropIcon.BackgroundTransparency = 1

            local listHeight = math.min(#options * 32, 130) 
            local listFrame = Instance.new("ScrollingFrame", container)
            listFrame.Size = UDim2.new(1, 0, 0, listHeight)
            listFrame.Position = UDim2.new(0, 0, 0, 42)
            listFrame.BackgroundTransparency = 1
            listFrame.BorderSizePixel = 0
            listFrame.ScrollBarThickness = 3
            listFrame.Active = true
            listFrame.ScrollingDirection = Enum.ScrollingDirection.Y
            listFrame.CanvasSize = UDim2.new(0, 0, 0, #options * 32)

            local isExpanded = false
            topBar.MouseButton1Click:Connect(function()
                isExpanded = not isExpanded
                local targetHeight = isExpanded and (42 + listHeight) or 42
                TweenService:Create(container, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Size = UDim2.new(0.9, 0, 0, targetHeight)}):Play()
                TweenService:Create(dropIcon, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Rotation = isExpanded and 180 or 0}):Play()
            end)

            for i, opt in ipairs(options) do
                local itemBtn = Instance.new("TextButton", listFrame)
                itemBtn.Size = UDim2.new(1, 0, 0, 32)
                itemBtn.Position = UDim2.new(0, 0, 0, (i-1)*32)
                itemBtn.BackgroundColor3 = Color3.fromRGB(28, 36, 46)
                itemBtn.Text = ""
                itemBtn.BorderSizePixel = 0

                local checkBg = Instance.new("Frame", itemBtn)
                checkBg.Size = UDim2.new(0, 14, 0, 14)
                checkBg.Position = UDim2.new(0, 12, 0.5, -7)
                checkBg.BackgroundColor3 = Color3.fromRGB(50, 65, 80)
                Instance.new("UICorner", checkBg).CornerRadius = UDim.new(1, 0)

                local checkFill = Instance.new("Frame", checkBg)
                checkFill.Size = UDim2.new(1, -4, 1, -4)
                checkFill.Position = UDim2.new(0, 2, 0, 2)
                checkFill.BackgroundColor3 = Window.CurrentAuraColor
                checkFill.Visible = false 
                Instance.new("UICorner", checkFill).CornerRadius = UDim.new(1, 0)

                local itemText = Instance.new("TextLabel", itemBtn)
                itemText.Size = UDim2.new(1, -40, 1, 0)
                itemText.Position = UDim2.new(0, 36, 0, 0)
                itemText.Text = opt
                itemText.TextColor3 = Color3.fromRGB(190, 200, 215)
                itemText.Font = Enum.Font.Gotham
                itemText.TextSize = 12
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
                            el.TextLabel.TextColor3 = Color3.fromRGB(190, 200, 215)
                        end
                    end

                    isExpanded = false
                    TweenService:Create(container, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Size = UDim2.new(0.9, 0, 0, 42)}):Play()
                    TweenService:Create(dropIcon, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Rotation = 0}):Play()

                    pcall(function() callback(selectedItem) end)
                end)
            end
            return container
        end

        function TabData:CreateSlider(sliderName, min, max, callback)
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 55)
            container.BackgroundColor3 = Color3.fromRGB(24, 32, 40)
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
            Instance.new("UIStroke", container).Color = Color3.fromRGB(50, 65, 80)
            
            local title = Instance.new("TextLabel", container)
            title.Size = UDim2.new(0.35, 0, 1, 0)
            title.Position = UDim2.new(0, 12, 0, 0)
            title.Text = sliderName
            title.TextColor3 = Color3.new(1, 1, 1)
            title.Font = Enum.Font.GothamMedium
            title.TextSize = 12
            title.BackgroundTransparency = 1
            title.TextXAlignment = Enum.TextXAlignment.Left

            local valueBox = Instance.new("TextBox", container)
            valueBox.Size = UDim2.new(0, 38, 0, 26)
            valueBox.Position = UDim2.new(0, 100, 0.5, -13) 
            valueBox.BackgroundColor3 = Color3.fromRGB(35, 45, 55)
            valueBox.Text = tostring(max)
            valueBox.TextColor3 = Color3.new(1, 1, 1)
            valueBox.Font = Enum.Font.GothamBold
            valueBox.TextSize = 11
            Instance.new("UICorner", valueBox).CornerRadius = UDim.new(0, 5)

            local sliderBg = Instance.new("Frame", container)
            sliderBg.Size = UDim2.new(0.38, 0, 0, 5)
            sliderBg.Position = UDim2.new(0, 148, 0.5, -2) 
            sliderBg.BackgroundColor3 = Color3.fromRGB(50, 65, 80)
            Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

            local progress = Instance.new("Frame", sliderBg)
            progress.Size = UDim2.new(1, 0, 1, 0)
            progress.BackgroundColor3 = Window.CurrentAuraColor
            Instance.new("UICorner", progress).CornerRadius = UDim.new(1, 0)

            local knob = Instance.new("ImageLabel", sliderBg)
            knob.AnchorPoint = Vector2.new(0.5, 0.5) 
            knob.Size = UDim2.new(0, 18, 0, 18)
            knob.Position = UDim2.new(1, 0, 0.5, 0)
            knob.BackgroundTransparency = 1
            knob.Image = "rbxassetid://5639840603"
            knob.ZIndex = 5

            local hitbox = Instance.new("TextButton", sliderBg)
            hitbox.AnchorPoint = Vector2.new(0.5, 0.5)
            hitbox.Size = UDim2.new(1, 20, 0, 35) 
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

        function TabData:CreateKeybind(keyName, defaultKey, callback)
            local currentKey = defaultKey or Enum.KeyCode.RightShift
            local binding = false

            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 42)
            container.BackgroundColor3 = Color3.fromRGB(24, 32, 40)
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
            Instance.new("UIStroke", container).Color = Color3.fromRGB(50, 65, 80)

            local title = Instance.new("TextLabel", container)
            title.Size = UDim2.new(0.5, 0, 1, 0)
            title.Position = UDim2.new(0, 12, 0, 0)
            title.Text = keyName
            title.TextColor3 = Color3.new(1, 1, 1)
            title.Font = Enum.Font.GothamMedium
            title.TextSize = 12
            title.BackgroundTransparency = 1
            title.TextXAlignment = Enum.TextXAlignment.Left

            local keyBtn = Instance.new("TextButton", container)
            keyBtn.Size = UDim2.new(0, 90, 0, 24)
            keyBtn.Position = UDim2.new(1, -102, 0.5, -12)
            keyBtn.BackgroundColor3 = Color3.fromRGB(35, 45, 55)
            keyBtn.Text = tostring(currentKey.Name)
            keyBtn.TextColor3 = Color3.fromRGB(200, 210, 225)
            keyBtn.Font = Enum.Font.GothamBold
            keyBtn.TextSize = 11
            Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0, 5)

            keyBtn.MouseButton1Click:Connect(function()
                binding = true
                keyBtn.Text = "..."
                keyBtn.TextColor3 = Window.CurrentAuraColor
            end)

            UserInputService.InputBegan:Connect(function(input)
                if binding and input.UserInputType == Enum.UserInputType.Keyboard then
                    currentKey = input.KeyCode
                    binding = false
                    keyBtn.Text = tostring(currentKey.Name)
                    keyBtn.TextColor3 = Color3.fromRGB(200, 210, 225)
                    pcall(function() callback(currentKey) end)
                end
            end)

            return container
        end

        function TabData:CreateLabel(labelText)
            local label = Instance.new("TextLabel", page)
            label.Size = UDim2.new(0.9, 0, 0, 28)
            label.BackgroundTransparency = 1
            label.Text = "  " .. labelText
            label.TextColor3 = Color3.fromRGB(170, 180, 195)
            label.Font = Enum.Font.GothamMedium
            label.TextSize = 12
            label.TextXAlignment = Enum.TextXAlignment.Left
            return label
        end

        function TabData:CreateTextBox(boxName, placeholder, callback)
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 42)
            container.BackgroundColor3 = Color3.fromRGB(24, 32, 40)
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
            local stroke = Instance.new("UIStroke", container)
            stroke.Color = Color3.fromRGB(50, 65, 80)
            stroke.Thickness = 1.2

            local title = Instance.new("TextLabel", container)
            title.Size = UDim2.new(0.4, 0, 1, 0)
            title.Position = UDim2.new(0, 12, 0, 0)
            title.Text = boxName
            title.TextColor3 = Color3.new(1, 1, 1)
            title.Font = Enum.Font.GothamMedium
            title.TextSize = 12
            title.BackgroundTransparency = 1
            title.TextXAlignment = Enum.TextXAlignment.Left

            local inputBox = Instance.new("TextBox", container)
            inputBox.Size = UDim2.new(0, 140, 0, 26)
            inputBox.Position = UDim2.new(1, -152, 0.5, -13)
            inputBox.BackgroundColor3 = Color3.fromRGB(35, 45, 55)
            inputBox.Text = ""
            inputBox.PlaceholderText = placeholder or "Type..."
            inputBox.PlaceholderColor3 = Color3.fromRGB(110, 120, 135)
            inputBox.TextColor3 = Color3.new(1, 1, 1)
            inputBox.Font = Enum.Font.Gotham
            inputBox.TextSize = 11
            Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 5)

            inputBox.Focused:Connect(function()
                TweenService:Create(stroke, TweenInfo.new(0.2), {Color = Window.CurrentAuraColor}):Play()
            end)

            inputBox.FocusLost:Connect(function(enterPressed)
                TweenService:Create(stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(50, 65, 80)}):Play()
                pcall(function() callback(inputBox.Text, enterPressed) end)
            end)

            return container
        end

        return TabData
    end

    return Window
end

return NemoZLibrary