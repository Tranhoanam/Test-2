local NemoZLibrary = {}

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer

-- Xác định vị trí lưu trữ GUI an toàn (Hỗ trợ gethui() cho các executor phổ biến)
local TargetParent = nil
pcall(function() TargetParent = gethui() end)
if not TargetParent then
    pcall(function() TargetParent = CoreGui end)
end
if not TargetParent then TargetParent = Player:WaitForChild("PlayerGui") end

-- Hàm Khởi Tạo Window
function NemoZLibrary:CreateWindow(config)
    local Window = {
        TabButtons = {},
        TabPages = {}
    }
    
    local Name = config.Name or "Menu Name"

    -- Dọn dẹp các GUI cũ tránh trùng lặp
    if TargetParent:FindFirstChild("NemoZ_MainOnlyMenu") then TargetParent["NemoZ_MainOnlyMenu"]:Destroy() end
    if TargetParent:FindFirstChild("NemoZ_DeltaCustomMiniMenu") then TargetParent["NemoZ_DeltaCustomMiniMenu"]:Destroy() end
    if TargetParent:FindFirstChild("NemoZ_IntroScreen") then TargetParent["NemoZ_IntroScreen"]:Destroy() end

    -- ==========================================
    -- 2. TẠO HIỆU ỨNG MÀN HÌNH MỞ ĐẦU (INTRO SCREEN)
    -- ==========================================
    local IntroGui = Instance.new("ScreenGui", TargetParent)
    IntroGui.Name = "NemoZ_IntroScreen"
    IntroGui.IgnoreGuiInset = true
    IntroGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local IntroBackground = Instance.new("Frame", IntroGui)
    IntroBackground.Size = UDim2.new(1, 0, 1, 0)
    IntroBackground.BackgroundColor3 = Color3.fromRGB(15, 22, 36) -- Nền tối xanh (blue)
    IntroBackground.BorderSizePixel = 0
    IntroBackground.BackgroundTransparency = 0

    local IntroSound = Instance.new("Sound", IntroGui)
    IntroSound.SoundId = "rbxassetid://125090389445721"
    IntroSound.Volume = 1
    IntroSound:Play()

    local IntroTitle = Instance.new("TextLabel", IntroBackground)
    IntroTitle.Size = UDim2.new(1, 0, 0, 100)
    IntroTitle.Position = UDim2.new(0, 0, 0.5, -50)
    IntroTitle.BackgroundTransparency = 1
    IntroTitle.Text = Name
    IntroTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    IntroTitle.Font = Enum.Font.GothamBold
    IntroTitle.TextSize = 40
    IntroTitle.TextTransparency = 1 -- Ẩn ban đầu để làm hiệu ứng Fade-in
    IntroTitle.TextXAlignment = Enum.TextXAlignment.Center

    -- Sau 2 giây: Hiển thị chữ to với hiệu ứng Fade-in
    task.delay(2, function()
        if IntroTitle and IntroTitle.Parent then
            TweenService:Create(IntroTitle, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
        end
    end)

    -- Sau 5 giây: Fade-out toàn bộ màn hình Intro, hủy đối tượng và bật MainWindow
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
    -- MENU CHÍNH
    -- ==========================================
    local ScreenGui = Instance.new("ScreenGui", TargetParent)
    ScreenGui.Name = "NemoZ_MainOnlyMenu"
    ScreenGui.IgnoreGuiInset = true

    local MainWindow = Instance.new("Frame", ScreenGui)
    MainWindow.Size = UDim2.new(0, 500, 0, 300)
    MainWindow.Position = UDim2.new(0.5, -250, 0.5, -150)
    MainWindow.BackgroundColor3 = Color3.fromRGB(18, 19, 23)
    MainWindow.BorderSizePixel = 0
    MainWindow.Active = true
    MainWindow.Draggable = false
    MainWindow.Visible = false -- Ban đầu ẩn để chờ Intro chạy xong
    
    local mainDragging, mainDragStart, mainStartPos

    Instance.new("UICorner", MainWindow).CornerRadius = UDim.new(0, 15)
    Instance.new("UIStroke", MainWindow).Color = Color3.fromRGB(45, 47, 56)

    -- Header & Stats
    local Header = Instance.new("Frame", MainWindow)
    Header.Size = UDim2.new(1, 0, 0, 80)
    Header.BackgroundColor3 = Color3.fromRGB(24, 26, 32)
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 15)

    -- Hệ thống kéo thả trên Header (Tương thích tốt Touch & Mouse qua UserInputService)
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
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            mainDragging = false
        end
    end)

    local Title = Instance.new("TextLabel", Header)
    Title.Text = Name
    Title.Size = UDim2.new(0.4, 0, 0.5, 0)
    Title.Position = UDim2.new(0.04, 0, 0, 0)
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.GothamBold
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local StatsButton = Instance.new("TextButton", Header)
    StatsButton.Size = UDim2.new(0, 60, 0, 30)
    StatsButton.Position = UDim2.new(0.7, 0, 0.1, 0)
    StatsButton.Text = "Stats"
    StatsButton.TextColor3 = Color3.new(1, 1, 1)
    StatsButton.BackgroundColor3 = Color3.fromRGB(45, 47, 56)
    Instance.new("UICorner", StatsButton).CornerRadius = UDim.new(1, 0)

    local Close = Instance.new("TextButton", Header)
    Close.Size = UDim2.new(0, 30, 0, 30)
    Close.Position = UDim2.new(0.92, 0, 0.1, 0)
    Close.Text = "X"
    Close.TextColor3 = Color3.new(1, 1, 1)
    Close.BackgroundColor3 = Color3.fromRGB(45, 47, 56)
    Instance.new("UICorner", Close).CornerRadius = UDim.new(1, 0)

    local StatsFrame = Instance.new("Frame", Header)
    StatsFrame.Size = UDim2.new(1, 0, 0.5, 0)
    StatsFrame.Position = UDim2.new(0, 0, 0.5, 0)
    StatsFrame.BackgroundTransparency = 1

    local PingLabel = Instance.new("TextLabel", StatsFrame)
    PingLabel.Size = UDim2.new(0.33, 0, 1, 0)
    PingLabel.BackgroundTransparency = 1
    PingLabel.Font = Enum.Font.GothamBold
    PingLabel.Parent = StatsFrame

    local FpsLabel = Instance.new("TextLabel", StatsFrame)
    FpsLabel.Position = UDim2.new(0.33, 0, 0, 0)
    FpsLabel.Size = UDim2.new(0.33, 0, 1, 0)
    FpsLabel.BackgroundTransparency = 1
    FpsLabel.Font = Enum.Font.GothamBold
    FpsLabel.Parent = StatsFrame

    local LossLabel = Instance.new("TextLabel", StatsFrame)
    LossLabel.Position = UDim2.new(0.66, 0, 0, 0)
    LossLabel.Size = UDim2.new(0.33, 0, 1, 0)
    LossLabel.BackgroundTransparency = 1
    LossLabel.Font = Enum.Font.GothamBold
    LossLabel.Parent = StatsFrame

    local Sidebar = Instance.new("ScrollingFrame", MainWindow)
    Sidebar.Size = UDim2.new(0, 130, 1, -80)
    Sidebar.Position = UDim2.new(0, 0, 0, 80)
    Sidebar.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 2
    Sidebar.Active = true
    Sidebar.ScrollingDirection = Enum.ScrollingDirection.Y
    Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    Sidebar.ElasticBehavior = Enum.ElasticBehavior.Always
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)

    local SidebarLayout = Instance.new("UIListLayout", Sidebar)
    SidebarLayout.Padding = UDim.new(0, 5)
    SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local SidebarPadding = Instance.new("UIPadding", Sidebar)
    SidebarPadding.PaddingTop = UDim.new(0, 10)

    local PageContainer = Instance.new("Frame", MainWindow)
    PageContainer.Size = UDim2.new(1, -130, 1, -80)
    PageContainer.Position = UDim2.new(0, 130, 0, 80)
    PageContainer.BackgroundTransparency = 1

    -- ==========================================
    -- MINI MENU
    -- ==========================================
    local MiniScreenGui = Instance.new("ScreenGui", TargetParent)
    MiniScreenGui.Name = "NemoZ_DeltaCustomMiniMenu"
    MiniScreenGui.IgnoreGuiInset = true

    local MiniMainFrame = Instance.new("Frame")
    MiniMainFrame.Name = "MainFrame"
    MiniMainFrame.Size = UDim2.new(0, 135, 0, 40)
    MiniMainFrame.Position = UDim2.new(0.5, -67, 0, 0)
    MiniMainFrame.BackgroundColor3 = Color3.fromRGB(18, 19, 23)
    MiniMainFrame.BorderSizePixel = 0
    MiniMainFrame.Active = true
    MiniMainFrame.ZIndex = 2
    MiniMainFrame.Parent = MiniScreenGui

    local MiniUICorner = Instance.new("UICorner")
    MiniUICorner.CornerRadius = UDim.new(0, 12)
    MiniUICorner.Parent = MiniMainFrame

    local MiniUIStroke = Instance.new("UIStroke")
    MiniUIStroke.Thickness = 1
    MiniUIStroke.Color = Color3.fromRGB(45, 47, 56)
    MiniUIStroke.Transparency = 1
    MiniUIStroke.Parent = MiniMainFrame

    local MiniTopOverlay = Instance.new("Frame")
    MiniTopOverlay.Name = "TopOverlay"
    MiniTopOverlay.Size = UDim2.new(1, 0, 0, 12)
    MiniTopOverlay.Position = UDim2.new(0, 0, 0, 0)
    MiniTopOverlay.BackgroundColor3 = Color3.fromRGB(18, 19, 23)
    MiniTopOverlay.BorderSizePixel = 0
    MiniTopOverlay.Visible = true
    MiniTopOverlay.ZIndex = 1
    MiniTopOverlay.Parent = MiniMainFrame

    local MiniDragButton = Instance.new("ImageButton")
    MiniDragButton.Name = "DragButton"
    MiniDragButton.Size = UDim2.new(0, 42, 0, 40)
    MiniDragButton.Position = UDim2.new(0, 0, 0, 0)
    MiniDragButton.BackgroundTransparency = 1
    MiniDragButton.Image = "rbxassetid://94225529221725"
    MiniDragButton.ZIndex = 3
    MiniDragButton.Parent = MiniMainFrame

    local MiniDivider = Instance.new("Frame")
    MiniDivider.Name = "Divider"
    MiniDivider.Size = UDim2.new(0, 1, 0, 20)
    MiniDivider.Position = UDim2.new(0, 42, 0, 10)
    MiniDivider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MiniDivider.BackgroundTransparency = 0.8
    MiniDivider.BorderSizePixel = 0
    MiniDivider.ZIndex = 3
    MiniDivider.Parent = MiniMainFrame

    local MiniOpenButton = Instance.new("TextButton")
    MiniOpenButton.Name = "OpenButton"
    MiniOpenButton.Size = UDim2.new(0, 85, 0, 40)
    MiniOpenButton.Position = UDim2.new(0, 46, 0, 0)
    MiniOpenButton.BackgroundTransparency = 1
    MiniOpenButton.Text = "open"
    MiniOpenButton.TextColor3 = Color3.fromRGB(230, 235, 245)
    MiniOpenButton.TextSize = 15
    MiniOpenButton.Font = Enum.Font.GothamBold
    MiniOpenButton.ZIndex = 3
    MiniOpenButton.Parent = MiniMainFrame

    --- LOGIC MENU MINI ---
    local dragging, dragInput, dragStart, startPos

    local function update(input)
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
            if dragging then update(input) end
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- LOGIC ẨN/HIỆN CHUNG
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
    end)

    -- LOGIC THÔNG SỐ STATS (CỐ ĐỊNH CHUỖI ĐỂ TRÁNH DỊCH THUẬT LỖI)
    local lastTick = tick()
    local frames = 0
    RunService.RenderStepped:Connect(function(dt)
        frames += 1
        if tick() - lastTick >= 0.5 then
            local fps = math.floor(frames / (tick() - lastTick))
            local ping = math.floor(Player:GetNetworkPing() * 1000)
            
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
    -- ĐỐI TƯỢNG TAB & CHỨC NĂNG
    -- ==========================================
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
        Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)

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
        page.ElasticBehavior = Enum.ElasticBehavior.Always
        
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
            for i, btn in ipairs(Window.TabButtons) do
                btn.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
                btn.TextColor3 = Color3.fromRGB(150, 150, 150)
                btn:FindFirstChildOfClass("ImageLabel").ImageColor3 = Color3.fromRGB(150, 150, 150)
                Window.TabPages[i].Visible = false
            end
            tabBtn.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
            tabBtn.TextColor3 = Color3.new(1, 1, 1)
            icon.ImageColor3 = Color3.new(1, 1, 1)
            page.Visible = true
        end)

        table.insert(Window.TabButtons, tabBtn)
        table.insert(Window.TabPages, page)

        if #Window.TabButtons == 1 then
            tabBtn.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
            tabBtn.TextColor3 = Color3.new(1, 1, 1)
            icon.ImageColor3 = Color3.new(1, 1, 1)
            page.Visible = true
        end

        function TabData:CreateButton(btnName, callback)
            local btn = Instance.new("TextButton", page)
            btn.Size = UDim2.new(0.9, 0, 0, 45)
            btn.BackgroundColor3 = Color3.fromRGB(24, 26, 32)
            btn.Text = "  " .. btnName
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Font = Enum.Font.GothamMedium
            btn.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
            local stroke = Instance.new("UIStroke", btn)
            stroke.Color = Color3.fromRGB(45, 47, 56)
            stroke.Thickness = 1.5
            local btnIcon = Instance.new("ImageLabel", btn)
            btnIcon.Size = UDim2.new(0, 30, 0, 30) 
            btnIcon.Position = UDim2.new(1, -40, 0.5, -15) 
            btnIcon.BackgroundTransparency = 1
            btnIcon.Image = "rbxassetid://12333784627" 
            btn.MouseButton1Click:Connect(callback)
            return btn
        end

        function TabData:CreateToggle(toggleName, callback)
            local state = false
            local btn = Instance.new("TextButton", page)
            btn.Size = UDim2.new(0.9, 0, 0, 45)
            btn.BackgroundColor3 = Color3.fromRGB(24, 26, 32)
            btn.Text = "  " .. toggleName 
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Font = Enum.Font.GothamMedium
            btn.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
            local stroke = Instance.new("UIStroke", btn)
            stroke.Color = Color3.fromRGB(45, 47, 56)
            stroke.Thickness = 1.5
            local sliderBg = Instance.new("Frame", btn)
            sliderBg.Size = UDim2.new(0, 50, 0, 25)
            sliderBg.Position = UDim2.new(1, -60, 0.5, -12)
            sliderBg.BackgroundColor3 = Color3.fromRGB(45, 47, 56) 
            Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)
            local sliderKnob = Instance.new("Frame", sliderBg)
            sliderKnob.Size = UDim2.new(0.5, 0, 1, 0)
            sliderKnob.BackgroundColor3 = Color3.new(1, 1, 1)
            Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)
            
            btn.MouseButton1Click:Connect(function()
                state = not state
                sliderBg.BackgroundColor3 = state and Color3.fromRGB(80, 150, 255) or Color3.fromRGB(45, 47, 56)
                sliderKnob.Position = state and UDim2.new(0.5, 0, 0, 0) or UDim2.new(0, 0, 0, 0)
                callback(state)
            end)
            return btn
        end

        function TabData:CreateDropdown(dropName, options, callback)
            local selectedItems = {}
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 45) 
            container.BackgroundColor3 = Color3.fromRGB(24, 26, 32)
            container.ClipsDescendants = true 
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
            Instance.new("UIStroke", container).Color = Color3.fromRGB(45, 47, 56)
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
            Instance.new("UICorner", valueBox).CornerRadius = UDim.new(0, 5)
            local selectedText = Instance.new("TextLabel", valueBox)
            selectedText.Size = UDim2.new(1, -15, 1, 0)
            selectedText.Position = UDim2.new(0, 0, 0, 0)
            selectedText.Text = "Chọn..."
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
            listFrame.ElasticBehavior = Enum.ElasticBehavior.Always
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
                Instance.new("UICorner", checkBg).CornerRadius = UDim.new(0, 4)
                local checkFill = Instance.new("Frame", checkBg)
                checkFill.Size = UDim2.new(1, -4, 1, -4)
                checkFill.Position = UDim2.new(0, 2, 0, 2)
                checkFill.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
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
                        itemText.TextColor3 = Color3.fromRGB(255, 255, 255)
                    end
                    if #selectedItems > 0 then
                        selectedText.Text = table.concat(selectedItems, ", ")
                        selectedText.TextColor3 = Color3.new(1, 1, 1)
                    else
                        selectedText.Text = "Chọn..."
                        selectedText.TextColor3 = Color3.fromRGB(150, 150, 150)
                    end
                    callback(selectedItems)
                end)
            end
            return container
        end

        function TabData:CreateSlider(sliderName, min, max, callback)
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.9, 0, 0, 60)
            container.BackgroundColor3 = Color3.fromRGB(24, 26, 32)
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
            Instance.new("UIStroke", container).Color = Color3.fromRGB(45, 47, 56)
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
            Instance.new("UICorner", valueBox).CornerRadius = UDim.new(0, 4)
            local sliderBg = Instance.new("Frame", container)
            sliderBg.Size = UDim2.new(0.4, 0, 0, 6)
            sliderBg.Position = UDim2.new(0, 150, 0.5, -3) 
            sliderBg.BackgroundColor3 = Color3.fromRGB(45, 47, 56)
            Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)
            local progress = Instance.new("Frame", sliderBg)
            progress.Size = UDim2.new(1, 0, 1, 0)
            progress.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
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
                callback(val)
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
                    callback(clamped)
                else
                    valueBox.Text = tostring(min)
                end
            end)
        end

        return TabData
    end

    return Window
end

return NemoZLibrary