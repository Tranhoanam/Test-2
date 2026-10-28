-- =========================================================================
-- NEMOZ UI LIBRARY - ĐÃ CẬP NHẬT THEO YÊU CẦU (ĐÃ XÓA MINIMENU & THÊM DROPDOWN TARGET)
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

-- Hàm Khởi Tạo Window
function NemoZLibrary:CreateWindow(config)
    local Window = {
        TabButtons = {},
        TabPages = {}
    }
    
    local Name = config.Name or "NemoZ Menu"

    -- Dọn dẹp các GUI cũ tránh trùng lặp
    if TargetParent:FindFirstChild("NemoZ_MainOnlyMenu") then TargetParent["NemoZ_MainOnlyMenu"]:Destroy() end
    if TargetParent:FindFirstChild("NemoZ_IntroScreen") then TargetParent["NemoZ_IntroScreen"]:Destroy() end

    local MainWindow

    -- ==========================================
    -- 1. MÀN HÌNH MỞ ĐẦU (INTRO SCREEN)
    -- ==========================================
    local IntroGui = Instance.new("ScreenGui", TargetParent)
    IntroGui.Name = "NemoZ_IntroScreen"
    IntroGui.IgnoreGuiInset = true
    IntroGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local IntroBackground = Instance.new("Frame", IntroGui)
    IntroBackground.Size = UDim2.new(1, 0, 1, 0)
    IntroBackground.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    IntroBackground.BorderSizePixel = 0

    local IntroSound = Instance.new("Sound", IntroGui)
    IntroSound.SoundId = "rbxassetid://125090389445721"
    IntroSound.Volume = 1
    pcall(function() IntroSound:Play() end)

    local IntroTitle = Instance.new("TextLabel", IntroBackground)
    IntroTitle.Size = UDim2.new(1, 0, 0, 100)
    IntroTitle.Position = UDim2.new(0, 0, 0.5, -50)
    IntroTitle.BackgroundTransparency = 1
    IntroTitle.Text = Name
    IntroTitle.TextColor3 = Color3.fromRGB(80, 150, 255)
    IntroTitle.Font = Enum.Font.GothamBold
    IntroTitle.TextSize = 38
    IntroTitle.TextTransparency = 1 
    IntroTitle.TextXAlignment = Enum.TextXAlignment.Center

    task.delay(0.4, function()
        if IntroTitle and IntroTitle.Parent then
            TweenService:Create(IntroTitle, TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
        end
    end)

    task.delay(3.2, function()
        if IntroBackground and IntroGui then
            local fadeOutBg = TweenService:Create(IntroBackground, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {BackgroundTransparency = 1})
            local fadeOutText = TweenService:Create(IntroTitle, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {TextTransparency = 1})
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
    -- 2. MENU CHÍNH (MAIN WINDOW)
    -- ==========================================
    local ScreenGui = Instance.new("ScreenGui", TargetParent)
    ScreenGui.Name = "NemoZ_MainOnlyMenu"
    ScreenGui.IgnoreGuiInset = true

    MainWindow = Instance.new("Frame", ScreenGui)
    MainWindow.Size = UDim2.new(0, 520, 0, 320)
    MainWindow.Position = UDim2.new(0.5, -260, 0.5, -160)
    MainWindow.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    MainWindow.BorderSizePixel = 0
    MainWindow.Active = true
    MainWindow.Visible = false 
    
    local mainDragging, mainDragStart, mainStartPos

    Instance.new("UICorner", MainWindow).CornerRadius = UDim.new(0, 14)
    local MainStroke = Instance.new("UIStroke", MainWindow)
    MainStroke.Color = Color3.fromRGB(80, 150, 255)
    MainStroke.Thickness = 1.2

    -- Header & Stats
    local Header = Instance.new("Frame", MainWindow)
    Header.Size = UDim2.new(1, 0, 0, 75)
    Header.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 14)

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
    Title.Size = UDim2.new(0.4, 0, 0.45, 0)
    Title.Position = UDim2.new(0.04, 0, 0.12, 0)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local StatsButton = Instance.new("TextButton", Header)
    StatsButton.Size = UDim2.new(0, 70, 0, 28)
    StatsButton.Position = UDim2.new(0.66, 0, 0.2, 0)
    StatsButton.Text = "Stats"
    StatsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    StatsButton.Font = Enum.Font.GothamMedium
    StatsButton.TextSize = 12
    StatsButton.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
    Instance.new("UICorner", StatsButton).CornerRadius = UDim.new(0, 8)

    local Close = Instance.new("TextButton", Header)
    Close.Size = UDim2.new(0, 28, 0, 28)
    Close.Position = UDim2.new(0.90, 0, 0.2, 0)
    Close.Text = "✕"
    Close.TextColor3 = Color3.fromRGB(255, 255, 255)
    Close.Font = Enum.Font.GothamBold
    Close.TextSize = 13
    Close.BackgroundColor3 = Color3.fromRGB(45, 47, 56)
    Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 8)

    local StatsFrame = Instance.new("Frame", Header)
    StatsFrame.Size = UDim2.new(1, -30, 0.35, 0)
    StatsFrame.Position = UDim2.new(0, 15, 0.52, 0)
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

    local FpsLabel = createStatLabel(0)
    local PingLabel = createStatLabel(0.33)
    local LossLabel = createStatLabel(0.66)

    local Sidebar = Instance.new("ScrollingFrame", MainWindow)
    Sidebar.Size = UDim2.new(0, 140, 1, -75)
    Sidebar.Position = UDim2.new(0, 0, 0, 75)
    Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 2
    Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)

    local SidebarLayout = Instance.new("UIListLayout", Sidebar)
    SidebarLayout.Padding = UDim.new(0, 6)
    SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local SidebarPadding = Instance.new("UIPadding", Sidebar)
    SidebarPadding.PaddingTop = UDim.new(0, 12)

    SidebarLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Sidebar.CanvasSize = UDim2.new(0, 0, 0, SidebarLayout.AbsoluteContentSize.Y + 24)
    end)

    local PageContainer = Instance.new("Frame", MainWindow)
    PageContainer.Size = UDim2.new(1, -140, 1, -75)
    PageContainer.Position = UDim2.new(0, 140, 0, 75)
    PageContainer.BackgroundTransparency = 1

    Close.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    local isMini = false
    StatsButton.MouseButton1Click:Connect(function()
        isMini = not isMini
        MainWindow.Size = isMini and UDim2.new(0, 520, 0, 75) or UDim2.new(0, 520, 0, 320)
        Sidebar.Visible = not isMini
        PageContainer.Visible = not isMini
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
            FpsLabel.TextColor3 = (fps < 30) and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(80, 150, 255)
            
            PingLabel.Text = "PING: " .. ping .. "ms"
            PingLabel.TextColor3 = (ping > 150) and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(80, 150, 255)
            
            LossLabel.Text = "LOSS: 0%"
            LossLabel.TextColor3 = Color3.fromRGB(80, 150, 255)
            
            lastTick = tick()
            frames = 0
        end
    end)

    -- ==========================================
    -- 3. TẠO TAB & CÁC THÀNH PHẦN
    -- ==========================================
    function Window:CreateTab(name, imageId)
        local tabImageId = imageId or ""
        local TabData = {}
        
        local tabBtn = Instance.new("TextButton", Sidebar)
        tabBtn.Size = UDim2.new(0.9, 0, 0, 38)
        tabBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
        tabBtn.Text = name
        tabBtn.TextColor3 = Color3.fromRGB(180, 185, 200)
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.TextSize = 13
        tabBtn.TextXAlignment = Enum.TextXAlignment.Center
        Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 8)

        if tabImageId ~= "" then
            local icon = Instance.new("ImageLabel", tabBtn)
            icon.Size = UDim2.new(0, 16, 0, 16)
            icon.Position = UDim2.new(0, 8, 0.5, -8)
            icon.BackgroundTransparency = 1
            icon.Image = "rbxassetid://" .. tostring(tabImageId)
            icon.ImageColor3 = Color3.fromRGB(180, 185, 200)
        end

        local page = Instance.new("ScrollingFrame", PageContainer)
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.ScrollBarThickness = 3
        page.ScrollBarImageColor3 = Color3.fromRGB(80, 150, 255)
        page.Visible = false
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        
        local pagePadding = Instance.new("UIPadding", page)
        pagePadding.PaddingTop = UDim.new(0, 15)
        pagePadding.PaddingBottom = UDim.new(0, 15)
        
        local pageLayout = Instance.new("UIListLayout", page)
        pageLayout.Padding = UDim.new(0, 10)
        pageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        pageLayout.SortOrder = Enum.SortOrder.LayoutOrder

        pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 30)
        end)

        tabBtn.MouseButton1Click:Connect(function()
            for i, btn in ipairs(Window.TabButtons) do
                btn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
                btn.TextColor3 = Color3.fromRGB(180, 185, 200)
                if btn:FindFirstChildOfClass("ImageLabel") then
                    btn:FindFirstChildOfClass("ImageLabel").ImageColor3 = Color3.fromRGB(180, 185, 200)
                end
                Window.TabPages[i].Visible = false
            end
            tabBtn.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
            tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            if tabBtn:FindFirstChildOfClass("ImageLabel") then
                tabBtn:FindFirstChildOfClass("ImageLabel").ImageColor3 = Color3.fromRGB(255, 255, 255)
            end
            page.Visible = true
        end)

        table.insert(Window.TabButtons, tabBtn)
        table.insert(Window.TabPages, page)

        if #Window.TabButtons == 1 then
            tabBtn.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
            tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            if tabBtn:FindFirstChildOfClass("ImageLabel") then
                tabBtn:FindFirstChildOfClass("ImageLabel").ImageColor3 = Color3.fromRGB(255, 255, 255)
            end
            page.Visible = true
        end

        function TabData:CreateButton(btnName, callback)
            local btn = Instance.new("TextButton", page)
            btn.Size = UDim2.new(0.92, 0, 0, 44)
            btn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
            btn.Text = "  " .. btnName
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 13
            btn.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
            
            local stroke = Instance.new("UIStroke", btn)
            stroke.Color = Color3.fromRGB(80, 150, 255)
            stroke.Thickness = 1
            
            local btnIcon = Instance.new("ImageLabel", btn)
            btnIcon.Size = UDim2.new(0, 24, 0, 24) 
            btnIcon.Position = UDim2.new(1, -36, 0.5, -12) 
            btnIcon.BackgroundTransparency = 1
            btnIcon.Image = "rbxassetid://12333784627"

            btn.MouseButton1Click:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(80, 150, 255)}):Play()
                task.delay(0.1, function()
                    TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(28, 28, 28)}):Play()
                end)
                pcall(callback)
            end)
            return btn
        end

        function TabData:CreateToggle(toggleName, callback)
            local state = false
            local btn = Instance.new("TextButton", page)
            btn.Size = UDim2.new(0.92, 0, 0, 44)
            btn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
            btn.Text = "  " .. toggleName 
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 13
            btn.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
            
            local stroke = Instance.new("UIStroke", btn)
            stroke.Color = Color3.fromRGB(80, 150, 255)
            stroke.Thickness = 1
            
            local sliderBg = Instance.new("Frame", btn)
            sliderBg.Size = UDim2.new(0, 44, 0, 22)
            sliderBg.Position = UDim2.new(1, -54, 0.5, -11)
            sliderBg.BackgroundColor3 = Color3.fromRGB(45, 47, 56) 
            Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)
            
            local sliderKnob = Instance.new("Frame", sliderBg)
            sliderKnob.Size = UDim2.new(0, 16, 0, 16)
            sliderKnob.Position = UDim2.new(0, 3, 0.5, -8)
            sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)
            
            btn.MouseButton1Click:Connect(function()
                state = not state
                TweenService:Create(sliderBg, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(80, 150, 255) or Color3.fromRGB(45, 47, 56)}):Play()
                TweenService:Create(sliderKnob, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)}):Play()
                pcall(function() callback(state) end)
            end)
            return btn
        end

        function TabData:CreateDropdown(dropName, options, callback)
            local selectedItems = {}
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.92, 0, 0, 44) 
            container.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
            container.ClipsDescendants = true 
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
            Instance.new("UIStroke", container).Color = Color3.fromRGB(80, 150, 255)

            local topBar = Instance.new("TextButton", container)
            topBar.Size = UDim2.new(1, 0, 0, 44)
            topBar.BackgroundTransparency = 1
            topBar.Text = ""

            local title = Instance.new("TextLabel", topBar)
            title.Size = UDim2.new(0.4, 0, 1, 0)
            title.Position = UDim2.new(0, 12, 0, 0)
            title.Text = dropName
            title.TextColor3 = Color3.fromRGB(255, 255, 255)
            title.Font = Enum.Font.GothamBold
            title.TextSize = 13
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.BackgroundTransparency = 1

            local selectedText = Instance.new("TextLabel", topBar)
            selectedText.Size = UDim2.new(0, 130, 1, 0)
            selectedText.Position = UDim2.new(1, -160, 0, 0)
            selectedText.Text = "Chọn..."
            selectedText.TextColor3 = Color3.fromRGB(180, 185, 200)
            selectedText.Font = Enum.Font.GothamMedium
            selectedText.TextSize = 12
            selectedText.BackgroundTransparency = 1
            selectedText.TextTruncate = Enum.TextTruncate.AtEnd
            selectedText.TextXAlignment = Enum.TextXAlignment.Right

            local dropIcon = Instance.new("ImageLabel", topBar)
            dropIcon.Size = UDim2.new(0, 16, 0, 16)
            dropIcon.Position = UDim2.new(1, -26, 0.5, -8)
            dropIcon.Image = "rbxassetid://5279719038"
            dropIcon.BackgroundTransparency = 1

            local listHeight = math.min(#options * 32, 130) 
            local listFrame = Instance.new("ScrollingFrame", container)
            listFrame.Size = UDim2.new(1, 0, 0, listHeight)
            listFrame.Position = UDim2.new(0, 0, 0, 44)
            listFrame.BackgroundTransparency = 1
            listFrame.BorderSizePixel = 0
            listFrame.ScrollBarThickness = 3
            listFrame.CanvasSize = UDim2.new(0, 0, 0, #options * 32)

            local isExpanded = false
            topBar.MouseButton1Click:Connect(function()
                isExpanded = not isExpanded
                local targetHeight = isExpanded and (44 + listHeight + 8) or 44
                TweenService:Create(container, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Size = UDim2.new(0.92, 0, 0, targetHeight)}):Play()
                TweenService:Create(dropIcon, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Rotation = isExpanded and 180 or 0}):Play()
            end)

            for i, opt in ipairs(options) do
                local itemBtn = Instance.new("TextButton", listFrame)
                itemBtn.Size = UDim2.new(1, 0, 0, 32)
                itemBtn.Position = UDim2.new(0, 0, 0, (i-1)*32)
                itemBtn.BackgroundTransparency = 1
                itemBtn.Text = ""

                local checkBg = Instance.new("Frame", itemBtn)
                checkBg.Size = UDim2.new(0, 16, 0, 16)
                checkBg.Position = UDim2.new(0, 12, 0.5, -8)
                checkBg.BackgroundColor3 = Color3.fromRGB(45, 47, 56)
                Instance.new("UICorner", checkBg).CornerRadius = UDim.new(0, 4)

                local checkFill = Instance.new("Frame", checkBg)
                checkFill.Size = UDim2.new(1, -4, 1, -4)
                checkFill.Position = UDim2.new(0, 2, 0, 2)
                checkFill.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
                checkFill.Visible = false 
                Instance.new("UICorner", checkFill).CornerRadius = UDim.new(0, 2)

                local itemText = Instance.new("TextLabel", itemBtn)
                itemText.Size = UDim2.new(1, -40, 1, 0)
                itemText.Position = UDim2.new(0, 36, 0, 0)
                itemText.Text = opt
                itemText.TextColor3 = Color3.fromRGB(200, 205, 220)
                itemText.Font = Enum.Font.GothamMedium
                itemText.TextSize = 12
                itemText.TextXAlignment = Enum.TextXAlignment.Left
                itemText.BackgroundTransparency = 1

                itemBtn.MouseButton1Click:Connect(function()
                    local idx = table.find(selectedItems, opt)
                    if idx then
                        table.remove(selectedItems, idx)
                        checkFill.Visible = false
                        itemText.TextColor3 = Color3.fromRGB(200, 205, 220)
                    else
                        table.insert(selectedItems, opt)
                        checkFill.Visible = true
                        itemText.TextColor3 = Color3.fromRGB(255, 255, 255)
                    end
                    if #selectedItems > 0 then
                        selectedText.Text = table.concat(selectedItems, ", ")
                        selectedText.TextColor3 = Color3.fromRGB(255, 255, 255)
                    else
                        selectedText.Text = "Chọn..."
                        selectedText.TextColor3 = Color3.fromRGB(180, 185, 200)
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
            container.Size = UDim2.new(0.92, 0, 0, 44) 
            container.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
            container.ClipsDescendants = true 
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
            Instance.new("UIStroke", container).Color = Color3.fromRGB(80, 150, 255)

            local topBar = Instance.new("TextButton", container)
            topBar.Size = UDim2.new(1, 0, 0, 44)
            topBar.BackgroundTransparency = 1
            topBar.Text = ""

            local title = Instance.new("TextLabel", topBar)
            title.Size = UDim2.new(0.4, 0, 1, 0)
            title.Position = UDim2.new(0, 12, 0, 0)
            title.Text = dropName
            title.TextColor3 = Color3.fromRGB(255, 255, 255)
            title.Font = Enum.Font.GothamBold
            title.TextSize = 13
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.BackgroundTransparency = 1

            local selectedText = Instance.new("TextLabel", topBar)
            selectedText.Size = UDim2.new(0, 130, 1, 0)
            selectedText.Position = UDim2.new(1, -160, 0, 0)
            selectedText.Text = "Chọn..."
            selectedText.TextColor3 = Color3.fromRGB(180, 185, 200)
            selectedText.Font = Enum.Font.GothamMedium
            selectedText.TextSize = 12
            selectedText.BackgroundTransparency = 1
            selectedText.TextTruncate = Enum.TextTruncate.AtEnd
            selectedText.TextXAlignment = Enum.TextXAlignment.Right

            local dropIcon = Instance.new("ImageLabel", topBar)
            dropIcon.Size = UDim2.new(0, 16, 0, 16)
            dropIcon.Position = UDim2.new(1, -26, 0.5, -8)
            dropIcon.Image = "rbxassetid://5279719038"
            dropIcon.BackgroundTransparency = 1

            local listHeight = math.min(#options * 32, 130) 
            local listFrame = Instance.new("ScrollingFrame", container)
            listFrame.Size = UDim2.new(1, 0, 0, listHeight)
            listFrame.Position = UDim2.new(0, 0, 0, 44)
            listFrame.BackgroundTransparency = 1
            listFrame.BorderSizePixel = 0
            listFrame.ScrollBarThickness = 3
            listFrame.CanvasSize = UDim2.new(0, 0, 0, #options * 32)

            local isExpanded = false
            topBar.MouseButton1Click:Connect(function()
                isExpanded = not isExpanded
                local targetHeight = isExpanded and (44 + listHeight + 8) or 44
                TweenService:Create(container, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Size = UDim2.new(0.92, 0, 0, targetHeight)}):Play()
                TweenService:Create(dropIcon, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Rotation = isExpanded and 180 or 0}):Play()
            end)

            for i, opt in ipairs(options) do
                local itemBtn = Instance.new("TextButton", listFrame)
                itemBtn.Size = UDim2.new(1, 0, 0, 32)
                itemBtn.Position = UDim2.new(0, 0, 0, (i-1)*32)
                itemBtn.BackgroundTransparency = 1
                itemBtn.Text = ""

                local checkBg = Instance.new("Frame", itemBtn)
                checkBg.Size = UDim2.new(0, 16, 0, 16)
                checkBg.Position = UDim2.new(0, 12, 0.5, -8)
                checkBg.BackgroundColor3 = Color3.fromRGB(45, 47, 56)
                Instance.new("UICorner", checkBg).CornerRadius = UDim.new(1, 0)

                local checkFill = Instance.new("Frame", checkBg)
                checkFill.Size = UDim2.new(1, -6, 1, -6)
                checkFill.Position = UDim2.new(0, 3, 0, 3)
                checkFill.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
                checkFill.Visible = false 
                Instance.new("UICorner", checkFill).CornerRadius = UDim.new(1, 0)

                local itemText = Instance.new("TextLabel", itemBtn)
                itemText.Size = UDim2.new(1, -40, 1, 0)
                itemText.Position = UDim2.new(0, 36, 0, 0)
                itemText.Text = opt
                itemText.TextColor3 = Color3.fromRGB(200, 205, 220)
                itemText.Font = Enum.Font.GothamMedium
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
                    selectedText.TextColor3 = Color3.fromRGB(255, 255, 255)

                    for _, el in ipairs(itemElements) do
                        if el.Option == selectedItem then
                            el.Fill.Visible = true
                            el.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                        else
                            el.Fill.Visible = false
                            el.TextLabel.TextColor3 = Color3.fromRGB(200, 205, 220)
                        end
                    end

                    isExpanded = false
                    TweenService:Create(container, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Size = UDim2.new(0.92, 0, 0, 44)}):Play()
                    TweenService:Create(dropIcon, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Rotation = 0}):Play()

                    pcall(function() callback(selectedItem) end)
                end)
            end
            return container
        end

        function TabData:CreateSlider(sliderName, min, max, callback)
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.92, 0, 0, 56)
            container.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
            Instance.new("UIStroke", container).Color = Color3.fromRGB(80, 150, 255)

            local title = Instance.new("TextLabel", container)
            title.Size = UDim2.new(0.4, 0, 0.5, 0)
            title.Position = UDim2.new(0, 12, 0, 6)
            title.Text = sliderName
            title.TextColor3 = Color3.fromRGB(255, 255, 255)
            title.Font = Enum.Font.GothamBold
            title.TextSize = 13
            title.BackgroundTransparency = 1
            title.TextXAlignment = Enum.TextXAlignment.Left

            local valueBox = Instance.new("TextBox", container)
            valueBox.Size = UDim2.new(0, 50, 0, 24)
            valueBox.Position = UDim2.new(1, -60, 0, 6) 
            valueBox.BackgroundColor3 = Color3.fromRGB(45, 47, 56)
            valueBox.Text = tostring(max)
            valueBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            valueBox.Font = Enum.Font.GothamBold
            valueBox.TextSize = 12
            Instance.new("UICorner", valueBox).CornerRadius = UDim.new(0, 6)

            local sliderBg = Instance.new("Frame", container)
            sliderBg.Size = UDim2.new(1, -24, 0, 6)
            sliderBg.Position = UDim2.new(0, 12, 0, 40) 
            sliderBg.BackgroundColor3 = Color3.fromRGB(45, 47, 56)
            Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

            local progress = Instance.new("Frame", sliderBg)
            progress.Size = UDim2.new(1, 0, 1, 0)
            progress.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
            Instance.new("UICorner", progress).CornerRadius = UDim.new(1, 0)

            local knob = Instance.new("Frame", sliderBg)
            knob.AnchorPoint = Vector2.new(0.5, 0.5) 
            knob.Size = UDim2.new(0, 16, 0, 16)
            knob.Position = UDim2.new(1, 0, 0.5, 0)
            knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

            local hitbox = Instance.new("TextButton", sliderBg)
            hitbox.Size = UDim2.new(1, 20, 0, 28)
            hitbox.Position = UDim2.new(0, -10, 0.5, -14)
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
            label.Size = UDim2.new(0.92, 0, 0, 26)
            label.BackgroundTransparency = 1
            label.Text = "  " .. labelText
            label.TextColor3 = Color3.fromRGB(180, 185, 200)
            label.Font = Enum.Font.GothamBold
            label.TextSize = 12
            label.TextXAlignment = Enum.TextXAlignment.Left
            return label
        end

        function TabData:CreateTextBox(boxName, placeholder, callback)
            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(0.92, 0, 0, 44)
            container.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
            local stroke = Instance.new("UIStroke", container)
            stroke.Color = Color3.fromRGB(80, 150, 255)
            stroke.Thickness = 1

            local title = Instance.new("TextLabel", container)
            title.Size = UDim2.new(0.4, 0, 1, 0)
            title.Position = UDim2.new(0, 12, 0, 0)
            title.Text = boxName
            title.TextColor3 = Color3.fromRGB(255, 255, 255)
            title.Font = Enum.Font.GothamBold
            title.TextSize = 13
            title.BackgroundTransparency = 1
            title.TextXAlignment = Enum.TextXAlignment.Left

            local inputBox = Instance.new("TextBox", container)
            inputBox.Size = UDim2.new(0, 150, 0, 28)
            inputBox.Position = UDim2.new(1, -162, 0.5, -14)
            inputBox.BackgroundColor3 = Color3.fromRGB(45, 47, 56)
            inputBox.Text = ""
            inputBox.PlaceholderText = placeholder or "Nhập..."
            inputBox.PlaceholderColor3 = Color3.fromRGB(150, 155, 170)
            inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            inputBox.Font = Enum.Font.GothamMedium
            inputBox.TextSize = 12
            Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 6)

            inputBox.Focused:Connect(function()
                TweenService:Create(stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(255, 255, 255)}):Play()
            end)

            inputBox.FocusLost:Connect(function(enterPressed)
                TweenService:Create(stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(80, 150, 255)}):Play()
                pcall(function() callback(inputBox.Text, enterPressed) end)
            end)

            return container
        end

        return TabData
    end

    return Window
end

return NemoZLibrary