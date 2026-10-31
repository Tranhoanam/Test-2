local NemoZLibrary = {}

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local Player = Players.LocalPlayer

local TargetParent = nil
pcall(function() TargetParent = gethui() end)
if not TargetParent then
    pcall(function() TargetParent = CoreGui end)
end
if not TargetParent then TargetParent = Player:WaitForChild("PlayerGui") end

local DEFAULT_PRIMARY = Color3.fromRGB(46, 80, 144)
local DEFAULT_BACKGROUND = Color3.fromRGB(54, 69, 79)
local CONFIG_FILE = "NemoZ_Config.json"
local WHITE = Color3.new(1, 1, 1)
local BLACK = Color3.new(0, 0, 0)
local MUTED = Color3.fromRGB(170, 180, 190)
local COMPONENT_EXTRAS = {4, 8}
local COMPONENT_TRANSPARENCY = {0.62, 0.85}
local MAIN_EXTRAS = {8, 16, 24, 32}
local MAIN_TRANSPARENCY = {0.55, 0.72, 0.85, 0.94}

local HUE_SEQUENCE = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
    ColorSequenceKeypoint.new(1 / 6, Color3.fromHSV(1 / 6, 1, 1)),
    ColorSequenceKeypoint.new(2 / 6, Color3.fromHSV(2 / 6, 1, 1)),
    ColorSequenceKeypoint.new(3 / 6, Color3.fromHSV(3 / 6, 1, 1)),
    ColorSequenceKeypoint.new(4 / 6, Color3.fromHSV(4 / 6, 1, 1)),
    ColorSequenceKeypoint.new(5 / 6, Color3.fromHSV(5 / 6, 1, 1)),
    ColorSequenceKeypoint.new(1, Color3.fromHSV(0, 1, 1))
})

local WHITE_FADE = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.1),
    NumberSequenceKeypoint.new(0.5, 1),
    NumberSequenceKeypoint.new(1, 1)
})

local BLACK_FADE = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.5, 1),
    NumberSequenceKeypoint.new(1, 0)
})

local function mix(color, amount)
    if amount >= 0 then
        return color:Lerp(WHITE, amount)
    end
    return color:Lerp(BLACK, -amount)
end

local function new(className, parent, props)
    local obj = Instance.new(className)
    if props then
        for key, value in pairs(props) do
            obj[key] = value
        end
    end
    obj.Parent = parent
    return obj
end

local function tween(obj, duration, props, style, direction)
    local tw = TweenService:Create(
        obj,
        TweenInfo.new(duration, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out),
        props
    )
    tw:Play()
    return tw
end

local function round(parent, radius)
    return new("UICorner", parent, {CornerRadius = UDim.new(0, radius)})
end

local function roundFull(parent)
    return new("UICorner", parent, {CornerRadius = UDim.new(1, 0)})
end

local function toRGB(color)
    return {
        math.floor(color.R * 255 + 0.5),
        math.floor(color.G * 255 + 0.5),
        math.floor(color.B * 255 + 0.5)
    }
end

local function fromRGBTable(data)
    return Color3.fromRGB(data[1], data[2], data[3])
end

local function toHex(color)
    local rgb = toRGB(color)
    return string.format("#%02X%02X%02X", rgb[1], rgb[2], rgb[3])
end

local function isPointer(input)
    return input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch
end

local function isMove(input)
    return input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
end

function NemoZLibrary:CreateWindow(config)
    config = config or {}

    local Window = {
        TabButtons = {},
        TabPages = {},
        TabSetters = {}
    }

    local Name = config.Name or "NemoZ Menu"

    local Theme = {
        Primary = DEFAULT_PRIMARY,
        Background = DEFAULT_BACKGROUND
    }
    Window.Theme = Theme

    local ThemeListeners = {}
    local IntroDone = false
    local MainWindow
    local HomePage
    local HomePickers = {}
    local Keybinds = {}
    local listeningBind = nil

    local function onTheme(callback)
        table.insert(ThemeListeners, callback)
        callback()
    end

    local function fireTheme()
        for _, callback in ipairs(ThemeListeners) do
            pcall(callback)
        end
    end

    local function bindBg(obj, prop, amount)
        onTheme(function()
            obj[prop] = mix(Theme.Background, amount)
        end)
    end

    local function bindPrimary(obj, prop, amount)
        onTheme(function()
            obj[prop] = mix(Theme.Primary, amount)
        end)
    end

    local function saveConfig()
        pcall(function()
            writefile(CONFIG_FILE, HttpService:JSONEncode({
                Primary = toRGB(Theme.Primary),
                Background = toRGB(Theme.Background)
            }))
        end)
    end

    local function loadConfig()
        local ok, data = pcall(function()
            if isfile and isfile(CONFIG_FILE) then
                return HttpService:JSONDecode(readfile(CONFIG_FILE))
            end
            return nil
        end)
        if ok and type(data) == "table" then
            if type(data.Primary) == "table" and #data.Primary == 3 then
                Theme.Primary = fromRGBTable(data.Primary)
            end
            if type(data.Background) == "table" and #data.Background == 3 then
                Theme.Background = fromRGBTable(data.Background)
            end
            return true
        end
        return false
    end

    local saveToken = 0
    local function scheduleSave()
        saveToken = saveToken + 1
        local token = saveToken
        task.delay(0.6, function()
            if token == saveToken then
                saveConfig()
            end
        end)
    end

    loadConfig()

    local function addAura(parent, radius, extras, transparencies)
        local gradients = {}
        for index = #extras, 1, -1 do
            local extra = extras[index]
            local layer = new("Frame", parent, {
                Name = "Aura" .. index,
                Size = UDim2.new(1, extra * 2, 1, extra * 2),
                Position = UDim2.new(0, -extra, 0, -extra),
                BackgroundColor3 = WHITE,
                BackgroundTransparency = transparencies[index],
                BorderSizePixel = 0,
                Active = false
            })
            round(layer, radius + extra)
            local gradient = new("UIGradient", layer, {Rotation = 45 + index * 20})
            onTheme(function()
                gradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, mix(Theme.Primary, 0.35)),
                    ColorSequenceKeypoint.new(0.5, Theme.Primary),
                    ColorSequenceKeypoint.new(1, mix(Theme.Primary, -0.35))
                })
            end)
            table.insert(gradients, gradient)
        end
        return gradients
    end

    local function addStroke(parent, thickness, amount)
        local stroke = new("UIStroke", parent, {
            Thickness = thickness or 1.5,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
        bindBg(stroke, "Color", amount or 0.18)
        return stroke
    end

    local function makeSection(parent, text)
        local section = new("Frame", parent, {
            Size = UDim2.new(0.9, 0, 0, 28),
            BackgroundTransparency = 1,
            BorderSizePixel = 0
        })
        local label = new("TextLabel", section, {
            Size = UDim2.new(1, 0, 0, 22),
            BackgroundTransparency = 1,
            Text = text,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        bindPrimary(label, "TextColor3", 0.5)
        local line = new("Frame", section, {
            Size = UDim2.new(1, 0, 0, 2),
            Position = UDim2.new(0, 0, 1, -3),
            BorderSizePixel = 0
        })
        round(line, 1)
        bindPrimary(line, "BackgroundColor3", 0)
        return section
    end

    local function createGradientPicker(parent, position, size, initialColor, onChange, scroller)
        local area = new("Frame", parent, {
            Position = position,
            Size = size,
            BackgroundColor3 = WHITE,
            BorderSizePixel = 0,
            Active = true
        })
        round(area, 10)
        new("UIGradient", area, {Color = HUE_SEQUENCE})

        local whiteOverlay = new("Frame", area, {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = WHITE,
            BorderSizePixel = 0,
            Active = false
        })
        round(whiteOverlay, 10)
        new("UIGradient", whiteOverlay, {Rotation = 90, Transparency = WHITE_FADE})

        local blackOverlay = new("Frame", area, {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = BLACK,
            BorderSizePixel = 0,
            Active = false
        })
        round(blackOverlay, 10)
        new("UIGradient", blackOverlay, {Rotation = 90, Transparency = BLACK_FADE})

        local cursor = new("Frame", area, {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.new(0, 16, 0, 16),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 5,
            Active = false
        })
        roundFull(cursor)
        new("UIStroke", cursor, {
            Color = WHITE,
            Thickness = 2,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })

        local function placeCursor(color)
            local h, s, v = color:ToHSV()
            local y
            if v >= 0.995 then
                y = 0.5 * math.clamp((s - 0.1) / 0.9, 0, 1)
            else
                y = 0.5 + 0.5 * (1 - v)
            end
            cursor.Position = UDim2.new(h, 0, y, 0)
        end

        local function pick(pos)
            local areaPos = area.AbsolutePosition
            local areaSize = area.AbsoluteSize
            local inset = GuiService:GetGuiInset()
            local x = math.clamp((pos.X - areaPos.X) / areaSize.X, 0, 1)
            local y = math.clamp((pos.Y + inset.Y - areaPos.Y) / areaSize.Y, 0, 1)
            local s, v
            if y < 0.5 then
                s = 0.1 + 0.9 * (y / 0.5)
                v = 1
            else
                s = 1
                v = 1 - ((y - 0.5) / 0.5)
            end
            cursor.Position = UDim2.new(x, 0, y, 0)
            onChange(Color3.fromHSV(math.min(x, 0.999), s, math.clamp(v, 0, 1)))
        end

        local picking = false
        area.InputBegan:Connect(function(input)
            if isPointer(input) then
                picking = true
                if scroller then scroller.ScrollingEnabled = false end
                pick(input.Position)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if picking and isMove(input) then
                pick(input.Position)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if picking and isPointer(input) then
                picking = false
                if scroller then scroller.ScrollingEnabled = true end
            end
        end)

        placeCursor(initialColor)
        return area, placeCursor
    end

    do
        local IntroGui = new("ScreenGui", TargetParent, {
            Name = "NemoZ_IntroScreen",
            IgnoreGuiInset = true,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            DisplayOrder = 100
        })

        local IntroBackground = new("Frame", IntroGui, {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Color3.new(0, 0, 0),
            BorderSizePixel = 0,
            BackgroundTransparency = 0,
            ZIndex = 1
        })

        local IntroSound = new("Sound", IntroGui, {
            SoundId = "rbxassetid://125090389445721",
            Volume = 1
        })
        pcall(function() IntroSound:Play() end)

        local rng = Random.new()
        local starTweens = {}
        for _ = 1, 60 do
            local starSize = rng:NextInteger(2, 4)
            local star = new("Frame", IntroBackground, {
                Size = UDim2.new(0, starSize, 0, starSize),
                Position = UDim2.new(rng:NextNumber(), 0, rng:NextNumber(), 0),
                BackgroundColor3 = WHITE,
                BackgroundTransparency = rng:NextNumber(0.6, 0.95),
                BorderSizePixel = 0,
                ZIndex = 2
            })
            roundFull(star)
            local twinkle = TweenService:Create(
                star,
                TweenInfo.new(rng:NextNumber(0.6, 1.8), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
                {BackgroundTransparency = rng:NextNumber(0, 0.25)}
            )
            twinkle:Play()
            table.insert(starTweens, twinkle)
        end

        local Spinner = new("Frame", IntroBackground, {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.new(0, 240, 0, 240),
            Position = UDim2.new(0.5, 0, 0.45, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 3
        })

        local squareCount = 24
        for i = 0, squareCount - 1 do
            local angle = (i / squareCount) * math.pi * 2
            local outer = (i % 2 == 0)
            local radius = outer and 98 or 80
            local size
            if outer then
                size = 10 + 8 * (0.5 + 0.5 * math.sin(angle))
            else
                size = 18 + 8 * (0.5 + 0.5 * math.cos(angle))
            end
            local square = new("Frame", Spinner, {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Size = UDim2.new(0, size, 0, size),
                Position = UDim2.new(0.5, math.cos(angle) * radius, 0.5, math.sin(angle) * radius),
                Rotation = math.deg(angle) + 25,
                BackgroundColor3 = Theme.Primary,
                BorderSizePixel = 0,
                ZIndex = 3
            })
            round(square, math.floor(size * 0.3))
            new("UIStroke", square, {
                Color = mix(Theme.Primary, 0.4),
                Thickness = 1.5,
                Transparency = 0.5,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            })
        end

        local spinConnection = RunService.RenderStepped:Connect(function(dt)
            Spinner.Rotation = (Spinner.Rotation + dt * 90) % 360
        end)

        local IntroTitle = new("TextLabel", IntroBackground, {
            AnchorPoint = Vector2.new(0.5, 0),
            Size = UDim2.new(0.8, 0, 0, 60),
            Position = UDim2.new(0.5, 0, 0.45, 150),
            BackgroundTransparency = 1,
            Text = "",
            TextColor3 = Color3.fromRGB(235, 240, 255),
            Font = Enum.Font.GothamBold,
            TextSize = 42,
            TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex = 4
        })

        task.spawn(function()
            local total = utf8.len(Name) or #Name
            if total == 0 then return end
            local step = math.min(3 / total, 0.25)
            task.wait(0.6)
            for i = 1, total do
                if not IntroTitle.Parent then return end
                local nextByte = utf8.offset(Name, i + 1)
                IntroTitle.Text = string.sub(Name, 1, (nextByte or (#Name + 1)) - 1)
                task.wait(step)
            end
        end)

        task.delay(4.2, function()
            if not IntroGui.Parent then return end
            for _, twinkle in ipairs(starTweens) do
                twinkle:Cancel()
            end
            for _, item in ipairs(IntroBackground:GetDescendants()) do
                if item:IsA("Frame") then
                    tween(item, 0.8, {BackgroundTransparency = 1}, Enum.EasingStyle.Sine)
                elseif item:IsA("TextLabel") then
                    tween(item, 0.8, {TextTransparency = 1}, Enum.EasingStyle.Sine)
                elseif item:IsA("UIStroke") then
                    tween(item, 0.8, {Transparency = 1}, Enum.EasingStyle.Sine)
                end
            end
            tween(IntroBackground, 0.8, {BackgroundTransparency = 1}, Enum.EasingStyle.Sine)
        end)

        task.delay(5, function()
            spinConnection:Disconnect()
            IntroSound:Stop()
            IntroGui:Destroy()
            IntroDone = true
            if MainWindow then
                MainWindow.Visible = true
            end
        end)
    end

    for _, guiName in ipairs({"NemoZ_MainOnlyMenu", "NemoZ_DeltaCustomMiniMenu"}) do
        local old = TargetParent:FindFirstChild(guiName)
        if old then old:Destroy() end
    end

    local ScreenGui = new("ScreenGui", TargetParent, {
        Name = "NemoZ_MainOnlyMenu",
        IgnoreGuiInset = true
    })

    MainWindow = new("Frame", ScreenGui, {
        Name = "MainWindow",
        Size = UDim2.new(0, 500, 0, 300),
        Position = UDim2.new(0.5, -250, 0.5, -150),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Visible = false
    })

    local MainAura = addAura(MainWindow, 15, MAIN_EXTRAS, MAIN_TRANSPARENCY)

    local Body = new("Frame", MainWindow, {
        Name = "Body",
        Size = UDim2.new(1, 0, 1, 0),
        BorderSizePixel = 0,
        Active = true,
        ClipsDescendants = true
    })
    bindBg(Body, "BackgroundColor3", 0)
    round(Body, 15)

    local MainStroke = new("UIStroke", Body, {
        Thickness = 1.5,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    })
    bindPrimary(MainStroke, "Color", 0)

    local auraAngle = 0
    RunService.Heartbeat:Connect(function(dt)
        if MainWindow.Visible then
            auraAngle = (auraAngle + dt * 25) % 360
            for index, gradient in ipairs(MainAura) do
                gradient.Rotation = auraAngle + index * 30
            end
        end
    end)

    local mainDragging, mainDragStart, mainStartPos

    do
        local Pattern = new("Frame", Body, {
            Name = "DragonPattern",
            Position = UDim2.new(0, 6, 0, 6),
            Size = UDim2.new(1, -12, 1, -12),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            Active = false
        })
        round(Pattern, 12)

        local scales = {}
        local strokes = {}
        local step = 64
        for row = 0, 10 do
            for col = 0, 8 do
                local scale = new("Frame", Pattern, {
                    Size = UDim2.new(0, step, 0, step),
                    Position = UDim2.new(
                        0, col * step + (row % 2) * (step / 2) - step / 2,
                        0, row * (step / 2) - step / 2
                    ),
                    BackgroundTransparency = 0.965,
                    BorderSizePixel = 0,
                    Active = false
                })
                round(scale, step / 2)
                local stroke = new("UIStroke", scale, {
                    Thickness = 1,
                    Transparency = 0.85,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                })
                table.insert(scales, scale)
                table.insert(strokes, stroke)
            end
        end

        onTheme(function()
            local fill = mix(Theme.Primary, 0.2)
            local line = mix(Theme.Primary, 0.3)
            for index, scale in ipairs(scales) do
                scale.BackgroundColor3 = fill
                strokes[index].Color = line
            end
        end)
    end

    local Header = new("Frame", Body, {
        Size = UDim2.new(1, 0, 0, 80),
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0
    })
    bindBg(Header, "BackgroundColor3", -0.35)
    round(Header, 15)

    Header.InputBegan:Connect(function(input)
        if isPointer(input) then
            mainDragging = true
            mainDragStart = input.Position
            mainStartPos = MainWindow.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if mainDragging and isMove(input) then
            local delta = input.Position - mainDragStart
            MainWindow.Position = UDim2.new(
                mainStartPos.X.Scale, mainStartPos.X.Offset + delta.X,
                mainStartPos.Y.Scale, mainStartPos.Y.Offset + delta.Y
            )
        end
    end)
    Header.InputEnded:Connect(function(input)
        if isPointer(input) then
            mainDragging = false
        end
    end)

    local Title = new("TextLabel", Header, {
        Text = Name,
        Size = UDim2.new(0.4, 0, 0.5, 0),
        Position = UDim2.new(0.04, 0, 0, 0),
        TextColor3 = WHITE,
        Font = Enum.Font.GothamBold,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local function styleHeaderButton(button)
        bindBg(button, "BackgroundColor3", -0.1)
        button.MouseEnter:Connect(function()
            tween(button, 0.15, {BackgroundColor3 = Theme.Primary})
        end)
        button.MouseLeave:Connect(function()
            tween(button, 0.15, {BackgroundColor3 = mix(Theme.Background, -0.1)})
        end)
    end

    local HomeButton = new("TextButton", Header, {
        Size = UDim2.new(0, 60, 0, 30),
        Position = UDim2.new(0.57, 0, 0.1, 0),
        Text = "Home",
        TextColor3 = WHITE,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        BorderSizePixel = 0,
        AutoButtonColor = false
    })
    round(HomeButton, 8)
    styleHeaderButton(HomeButton)

    local StatsButton = new("TextButton", Header, {
        Size = UDim2.new(0, 60, 0, 30),
        Position = UDim2.new(0.7, 0, 0.1, 0),
        Text = "Stats",
        TextColor3 = WHITE,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        BorderSizePixel = 0,
        AutoButtonColor = false
    })
    round(StatsButton, 8)
    styleHeaderButton(StatsButton)

    local Close = new("TextButton", Header, {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0.92, 0, 0.1, 0),
        Text = "×",
        TextColor3 = WHITE,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        BorderSizePixel = 0,
        AutoButtonColor = false
    })
    roundFull(Close)
    styleHeaderButton(Close)

    local StatsFrame = new("Frame", Header, {
        Size = UDim2.new(1, 0, 0.5, 0),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    })

    local function createStatLabel(posX)
        return new("TextLabel", StatsFrame, {
            Size = UDim2.new(0.33, 0, 1, 0),
            Position = UDim2.new(posX, 0, 0, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Center
        })
    end

    local PingLabel = createStatLabel(0)
    local FpsLabel = createStatLabel(0.33)
    local LossLabel = createStatLabel(0.66)

    local Sidebar = new("ScrollingFrame", Body, {
        Size = UDim2.new(0, 130, 1, -80),
        Position = UDim2.new(0, 0, 0, 80),
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        Active = true,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })
    bindBg(Sidebar, "BackgroundColor3", -0.3)
    round(Sidebar, 10)

    local SidebarLayout = new("UIListLayout", Sidebar, {
        Padding = UDim.new(0, 5),
        HorizontalAlignment = Enum.HorizontalAlignment.Center
    })
    new("UIPadding", Sidebar, {PaddingTop = UDim.new(0, 10)})

    SidebarLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Sidebar.CanvasSize = UDim2.new(0, 0, 0, SidebarLayout.AbsoluteContentSize.Y + 20)
    end)

    local PageContainer = new("Frame", Body, {
        Size = UDim2.new(1, -130, 1, -80),
        Position = UDim2.new(0, 130, 0, 80),
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    })

    HomePage = new("ScrollingFrame", PageContainer, {
        Name = "HomePage",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 5,
        Visible = false,
        Active = true,
        ScrollingDirection = Enum.ScrollingDirection.Y
    })
    bindPrimary(HomePage, "ScrollBarImageColor3", 0.4)
    new("UIPadding", HomePage, {PaddingTop = UDim.new(0, 20)})
    local HomeLayout = new("UIListLayout", HomePage, {
        Padding = UDim.new(0, 18),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    HomeLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        HomePage.CanvasSize = UDim2.new(0, 0, 0, HomeLayout.AbsoluteContentSize.Y + 40)
    end)

    do
        local function createHomePicker(pickerTitle, key)
            local holder = new("Frame", HomePage, {
                Size = UDim2.new(0.9, 0, 0, 180),
                BackgroundTransparency = 1,
                BorderSizePixel = 0
            })
            addAura(holder, 12, COMPONENT_EXTRAS, COMPONENT_TRANSPARENCY)

            local card = new("Frame", holder, {
                Size = UDim2.new(1, 0, 1, 0),
                BorderSizePixel = 0
            })
            bindBg(card, "BackgroundColor3", -0.2)
            round(card, 12)
            addStroke(card, 1.5)

            new("TextLabel", card, {
                Size = UDim2.new(0.5, 0, 0, 26),
                Position = UDim2.new(0, 15, 0, 6),
                BackgroundTransparency = 1,
                Text = pickerTitle,
                TextColor3 = WHITE,
                Font = Enum.Font.GothamBold,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local hexLabel = new("TextLabel", card, {
                Size = UDim2.new(0, 80, 0, 26),
                Position = UDim2.new(1, -135, 0, 6),
                BackgroundTransparency = 1,
                TextColor3 = MUTED,
                Font = Enum.Font.GothamMedium,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Right
            })

            local swatch = new("Frame", card, {
                Size = UDim2.new(0, 34, 0, 20),
                Position = UDim2.new(1, -49, 0, 9),
                BorderSizePixel = 0
            })
            round(swatch, 8)

            local function setLabels(color)
                swatch.BackgroundColor3 = color
                hexLabel.Text = toHex(color)
            end

            local _, place = createGradientPicker(
                card,
                UDim2.new(0, 12, 0, 38),
                UDim2.new(1, -24, 1, -50),
                Theme[key],
                function(color)
                    Theme[key] = color
                    setLabels(color)
                    fireTheme()
                    scheduleSave()
                end,
                HomePage
            )

            setLabels(Theme[key])
            table.insert(HomePickers, function()
                place(Theme[key])
                setLabels(Theme[key])
            end)
        end

        makeSection(HomePage, "Theme Colors")
        createHomePicker("Primary  " .. toHex(DEFAULT_PRIMARY), "Primary")
        createHomePicker("Background  " .. toHex(DEFAULT_BACKGROUND), "Background")
    end

    local function refreshHome()
        for _, refresh in ipairs(HomePickers) do
            refresh()
        end
    end

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
        MiniMainFrame.Visible = true
    end)

    MiniOpenButton.MouseButton1Click:Connect(function()
        MainWindow.Visible = true
        MiniMainFrame.Visible = false
    end)

    local isMini = false
    StatsButton.MouseButton1Click:Connect(function()
        isMini = not isMini
        Sidebar.Visible = not isMini
        PageContainer.Visible = not isMini
        tween(MainWindow, 0.25, {
            Size = isMini and UDim2.new(0, 500, 0, 80) or UDim2.new(0, 500, 0, 300)
        })
    end)

    HomeButton.MouseButton1Click:Connect(function()
        for _, setter in ipairs(Window.TabSetters) do
            setter(false)
        end
        for _, tabPage in ipairs(Window.TabPages) do
            tabPage.Visible = false
        end
        HomePage.Visible = true
    end)

    function Window:Toggle()
        if not IntroDone then return end
        local show = not MainWindow.Visible
        MainWindow.Visible = show
        MiniMainFrame.Visible = not show
    end

    function Window:SaveSettings()
        saveConfig()
    end

    function Window:LoadSettings()
        if loadConfig() then
            fireTheme()
            refreshHome()
        end
    end

    function Window:SetTheme(primary, background)
        if primary then Theme.Primary = primary end
        if background then Theme.Background = background end
        fireTheme()
        refreshHome()
        scheduleSave()
    end

    function Window:ResetTheme()
        Theme.Primary = DEFAULT_PRIMARY
        Theme.Background = DEFAULT_BACKGROUND
        fireTheme()
        refreshHome()
        scheduleSave()
    end

    UserInputService.InputBegan:Connect(function(input, processed)
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if listeningBind then
            local bind = listeningBind
            listeningBind = nil
            if input.KeyCode ~= Enum.KeyCode.Escape then
                bind.Key = input.KeyCode
            end
            bind.Refresh()
            return
        end
        if processed then return end
        for _, bind in ipairs(Keybinds) do
            if bind.Key ~= Enum.KeyCode.Unknown and bind.Key == input.KeyCode then
                bind.Callback()
            end
        end
    end)

    do
        local lastTick = tick()
        local frames = 0
        RunService.RenderStepped:Connect(function()
            frames = frames + 1
            if tick() - lastTick >= 0.5 then
                local fps = math.floor(frames / (tick() - lastTick))
                local success, pingVal = pcall(function() return Player:GetNetworkPing() end)
                local ping = success and math.floor(pingVal * 1000) or 0
                local normal = mix(Theme.Primary, 0.5)

                FpsLabel.Text = "FPS: " .. fps
                FpsLabel.TextColor3 = (fps < 30) and Color3.fromRGB(255, 50, 50) or normal

                PingLabel.Text = "PING: " .. ping
                PingLabel.TextColor3 = (ping > 100) and Color3.fromRGB(255, 50, 50) or normal

                LossLabel.Text = "LOSS: 0%"
                LossLabel.TextColor3 = normal

                lastTick = tick()
                frames = 0
            end
        end)
    end

    function Window:CreateTab(name, imageId)
        local TabData = {}
        local isActive = false

        local tabBtn = new("TextButton", Sidebar, {
            Size = UDim2.new(0.9, 0, 0, 35),
            Text = name,
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Center,
            BorderSizePixel = 0,
            AutoButtonColor = false
        })
        round(tabBtn, 8)

        local icon = new("ImageLabel", tabBtn, {
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0, 8, 0.5, -8),
            BackgroundTransparency = 1,
            Image = imageId and ("rbxassetid://" .. tostring(imageId)) or ""
        })

        local function styleTab()
            local textColor = isActive and WHITE or Color3.fromRGB(150, 150, 150)
            tween(tabBtn, 0.2, {
                BackgroundColor3 = isActive and Theme.Primary or mix(Theme.Background, -0.15),
                TextColor3 = textColor
            })
            tween(icon, 0.2, {ImageColor3 = textColor})
        end
        onTheme(styleTab)

        local page = new("ScrollingFrame", PageContainer, {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 5,
            Visible = false,
            Active = true,
            ScrollingDirection = Enum.ScrollingDirection.Y
        })
        bindPrimary(page, "ScrollBarImageColor3", 0.4)

        new("UIPadding", page, {PaddingTop = UDim.new(0, 20)})

        local pageLayout = new("UIListLayout", page, {
            Padding = UDim.new(0, 18),
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 40)
        end)

        table.insert(Window.TabSetters, function(active)
            isActive = active
            styleTab()
        end)

        tabBtn.MouseButton1Click:Connect(function()
            for _, setter in ipairs(Window.TabSetters) do
                setter(false)
            end
            for _, tabPage in ipairs(Window.TabPages) do
                tabPage.Visible = false
            end
            HomePage.Visible = false
            isActive = true
            styleTab()
            page.Visible = true
        end)

        table.insert(Window.TabButtons, tabBtn)
        table.insert(Window.TabPages, page)

        if #Window.TabButtons == 1 then
            isActive = true
            styleTab()
            page.Visible = true
        end

        local function createHolder(height, radius)
            local holder = new("Frame", page, {
                Size = UDim2.new(0.9, 0, 0, height),
                BackgroundTransparency = 1,
                BorderSizePixel = 0
            })
            addAura(holder, radius, COMPONENT_EXTRAS, COMPONENT_TRANSPARENCY)
            return holder
        end

        local function createSurface(holder, className, props)
            local base = {
                Size = UDim2.new(1, 0, 1, 0),
                BorderSizePixel = 0
            }
            if props then
                for key, value in pairs(props) do
                    base[key] = value
                end
            end
            local surface = new(className, holder, base)
            bindBg(surface, "BackgroundColor3", -0.2)
            round(surface, 8)
            addStroke(surface, 1.5)
            return surface
        end

        local function createTitle(parent, text, widthScale)
            return new("TextLabel", parent, {
                Size = UDim2.new(widthScale or 0.4, 0, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                Text = text,
                TextColor3 = WHITE,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1
            })
        end

        function TabData:CreateSection(sectionName)
            return makeSection(page, sectionName)
        end

        function TabData:CreateButton(btnName, callback)
            local holder = createHolder(45, 8)
            local btn = createSurface(holder, "TextButton", {
                Text = "  " .. btnName,
                TextColor3 = WHITE,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = false
            })

            new("ImageLabel", btn, {
                Size = UDim2.new(0, 30, 0, 30),
                Position = UDim2.new(1, -40, 0.5, -15),
                BackgroundTransparency = 1,
                Image = "rbxassetid://12333784627"
            })

            btn.MouseEnter:Connect(function()
                tween(btn, 0.15, {BackgroundColor3 = mix(Theme.Background, -0.1)})
            end)
            btn.MouseLeave:Connect(function()
                tween(btn, 0.15, {BackgroundColor3 = mix(Theme.Background, -0.2)})
            end)

            btn.MouseButton1Click:Connect(function()
                if callback then
                    pcall(callback)
                end
            end)
            return btn
        end

        function TabData:CreateToggle(toggleName, callback)
            local state = false
            local holder = createHolder(45, 8)
            local btn = createSurface(holder, "TextButton", {
                Text = "  " .. toggleName,
                TextColor3 = WHITE,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = false
            })

            local sliderBg = new("Frame", btn, {
                Size = UDim2.new(0, 50, 0, 25),
                Position = UDim2.new(1, -60, 0.5, -12),
                BorderSizePixel = 0
            })
            roundFull(sliderBg)

            local sliderKnob = new("Frame", sliderBg, {
                Size = UDim2.new(0.5, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundColor3 = WHITE,
                BorderSizePixel = 0
            })
            roundFull(sliderKnob)

            onTheme(function()
                sliderBg.BackgroundColor3 = state and Theme.Primary or mix(Theme.Background, -0.4)
            end)

            btn.MouseButton1Click:Connect(function()
                state = not state
                tween(sliderBg, 0.2, {
                    BackgroundColor3 = state and Theme.Primary or mix(Theme.Background, -0.4)
                })
                tween(sliderKnob, 0.2, {
                    Position = state and UDim2.new(0.5, 0, 0, 0) or UDim2.new(0, 0, 0, 0)
                }, Enum.EasingStyle.Sine)
                if callback then
                    pcall(function() callback(state) end)
                end
            end)
            return btn
        end

        local function buildDropdown(dropName, options, callback, single)
            local selectedItems = {}
            local selectedItem = nil
            local itemElements = {}
            local listHeight = math.min(#options * 35, 140)

            local holder = createHolder(45, 8)
            local container = createSurface(holder, "Frame", {ClipsDescendants = true})

            local topBar = new("TextButton", container, {
                Size = UDim2.new(1, 0, 0, 45),
                BackgroundTransparency = 1,
                Text = ""
            })

            createTitle(topBar, dropName, 0.4)

            local valueBox = new("Frame", topBar, {
                Size = UDim2.new(0, 100, 0, 25),
                Position = UDim2.new(1, -135, 0.5, -12),
                BorderSizePixel = 0
            })
            bindBg(valueBox, "BackgroundColor3", -0.4)
            round(valueBox, 8)

            local selectedText = new("TextLabel", valueBox, {
                Size = UDim2.new(1, -15, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                Text = "Select...",
                TextColor3 = Color3.fromRGB(150, 150, 150),
                Font = Enum.Font.Gotham,
                TextSize = 12,
                BackgroundTransparency = 1,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextXAlignment = Enum.TextXAlignment.Right
            })

            local dropIcon = new("ImageLabel", topBar, {
                Size = UDim2.new(0, 18, 0, 18),
                Position = UDim2.new(1, -25, 0.5, -9),
                Image = "rbxassetid://5279719038",
                BackgroundTransparency = 1
            })

            local listFrame = new("ScrollingFrame", container, {
                Size = UDim2.new(1, -12, 0, listHeight),
                Position = UDim2.new(0, 6, 0, 45),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ScrollBarThickness = 4,
                Active = true,
                ScrollingDirection = Enum.ScrollingDirection.Y,
                CanvasSize = UDim2.new(0, 0, 0, #options * 35)
            })

            local isExpanded = false
            local function setExpanded(value)
                isExpanded = value
                local targetHeight = value and (45 + listHeight + 6) or 45
                tween(holder, 0.25, {Size = UDim2.new(0.9, 0, 0, targetHeight)})
                tween(dropIcon, 0.25, {Rotation = value and 180 or 0})
            end

            topBar.MouseButton1Click:Connect(function()
                setExpanded(not isExpanded)
            end)

            for i, opt in ipairs(options) do
                local itemBtn = new("TextButton", listFrame, {
                    Size = UDim2.new(1, 0, 0, 32),
                    Position = UDim2.new(0, 0, 0, (i - 1) * 35 + 1),
                    Text = "",
                    BorderSizePixel = 0,
                    AutoButtonColor = false
                })
                bindBg(itemBtn, "BackgroundColor3", -0.28)
                round(itemBtn, 8)

                local checkBg = new("Frame", itemBtn, {
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(0, 15, 0.5, -8),
                    BorderSizePixel = 0
                })
                bindBg(checkBg, "BackgroundColor3", -0.45)
                if single then
                    roundFull(checkBg)
                else
                    round(checkBg, 6)
                end

                local fillInset = single and 6 or 4
                local checkFill = new("Frame", checkBg, {
                    Size = UDim2.new(1, -fillInset, 1, -fillInset),
                    Position = UDim2.new(0, fillInset / 2, 0, fillInset / 2),
                    BorderSizePixel = 0,
                    Visible = false
                })
                bindPrimary(checkFill, "BackgroundColor3", 0.2)
                if single then
                    roundFull(checkFill)
                else
                    round(checkFill, 4)
                end

                local itemText = new("TextLabel", itemBtn, {
                    Size = UDim2.new(1, -50, 1, 0),
                    Position = UDim2.new(0, 40, 0, 0),
                    Text = opt,
                    TextColor3 = Color3.fromRGB(200, 200, 200),
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1
                })

                table.insert(itemElements, {
                    Option = opt,
                    Fill = checkFill,
                    TextLabel = itemText
                })

                itemBtn.MouseButton1Click:Connect(function()
                    if single then
                        selectedItem = opt
                        selectedText.Text = opt
                        selectedText.TextColor3 = WHITE

                        for _, el in ipairs(itemElements) do
                            if el.Option == selectedItem then
                                el.Fill.Visible = true
                                el.TextLabel.TextColor3 = WHITE
                            else
                                el.Fill.Visible = false
                                el.TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                            end
                        end

                        setExpanded(false)
                        if callback then
                            pcall(function() callback(selectedItem) end)
                        end
                    else
                        local idx = table.find(selectedItems, opt)
                        if idx then
                            table.remove(selectedItems, idx)
                            checkFill.Visible = false
                            itemText.TextColor3 = Color3.fromRGB(200, 200, 200)
                        else
                            table.insert(selectedItems, opt)
                            checkFill.Visible = true
                            itemText.TextColor3 = WHITE
                        end
                        if #selectedItems > 0 then
                            selectedText.Text = table.concat(selectedItems, ", ")
                            selectedText.TextColor3 = WHITE
                        else
                            selectedText.Text = "Select..."
                            selectedText.TextColor3 = Color3.fromRGB(150, 150, 150)
                        end
                        if callback then
                            pcall(function() callback(selectedItems) end)
                        end
                    end
                end)
            end
            return container
        end

        function TabData:CreateDropdown(dropName, options, callback)
            return buildDropdown(dropName, options, callback, false)
        end

        function TabData:CreateDropdownTarget(dropName, options, callback)
            return buildDropdown(dropName, options, callback, true)
        end

        function TabData:CreateSlider(sliderName, min, max, callback)
            local holder = createHolder(60, 8)
            local container = createSurface(holder, "Frame")

            createTitle(container, sliderName, 0.3)

            local valueBox = new("TextBox", container, {
                Size = UDim2.new(0, 40, 0, 30),
                Position = UDim2.new(0, 100, 0.5, -15),
                Text = tostring(max),
                TextColor3 = WHITE,
                Font = Enum.Font.GothamBold,
                BorderSizePixel = 0
            })
            bindBg(valueBox, "BackgroundColor3", -0.4)
            round(valueBox, 8)

            local sliderBg = new("Frame", container, {
                Size = UDim2.new(0.4, 0, 0, 6),
                Position = UDim2.new(0, 150, 0.5, -3),
                BorderSizePixel = 0
            })
            bindBg(sliderBg, "BackgroundColor3", -0.45)
            roundFull(sliderBg)

            local progress = new("Frame", sliderBg, {
                Size = UDim2.new(1, 0, 1, 0),
                BorderSizePixel = 0
            })
            bindPrimary(progress, "BackgroundColor3", 0.2)
            roundFull(progress)

            local knob = new("ImageLabel", sliderBg, {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Size = UDim2.new(0, 22, 0, 22),
                Position = UDim2.new(1, 0, 0.5, 0),
                BackgroundTransparency = 1,
                Image = "rbxassetid://5639840603",
                ZIndex = 5
            })

            local hitbox = new("TextButton", sliderBg, {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Size = UDim2.new(1, 30, 0, 40),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 10
            })

            local sDragging = false
            local function updateSlider(inputX)
                local sliderX = sliderBg.AbsolutePosition.X
                local sliderWidth = sliderBg.AbsoluteSize.X
                local percent = math.clamp((inputX - sliderX) / sliderWidth, 0, 1)
                local val = math.floor(min + ((max - min) * percent))
                knob.Position = UDim2.new(percent, 0, 0.5, 0)
                progress.Size = UDim2.new(percent, 0, 1, 0)
                valueBox.Text = tostring(val)
                if callback then
                    pcall(function() callback(val) end)
                end
            end

            hitbox.InputBegan:Connect(function(input)
                if isPointer(input) then
                    sDragging = true
                    page.ScrollingEnabled = false
                    updateSlider(input.Position.X)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if sDragging and isMove(input) then
                    updateSlider(input.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if sDragging and isPointer(input) then
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
                    if callback then
                        pcall(function() callback(clamped) end)
                    end
                else
                    valueBox.Text = tostring(min)
                end
            end)
            return container
        end

        function TabData:CreateLabel(labelText)
            local label = new("TextLabel", page, {
                Size = UDim2.new(0.9, 0, 0, 30),
                BackgroundTransparency = 1,
                Text = "  " .. labelText,
                TextColor3 = Color3.fromRGB(180, 185, 195),
                Font = Enum.Font.GothamMedium,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            return label
        end

        function TabData:CreateTextBox(boxName, placeholder, callback)
            local holder = createHolder(45, 8)
            local container = createSurface(holder, "Frame")
            local stroke = container:FindFirstChildOfClass("UIStroke")

            createTitle(container, boxName, 0.4)

            local inputBox = new("TextBox", container, {
                Size = UDim2.new(0, 150, 0, 30),
                Position = UDim2.new(1, -165, 0.5, -15),
                Text = "",
                PlaceholderText = placeholder or "Type...",
                PlaceholderColor3 = Color3.fromRGB(120, 125, 135),
                TextColor3 = WHITE,
                Font = Enum.Font.Gotham,
                TextSize = 12,
                BorderSizePixel = 0,
                ClearTextOnFocus = false
            })
            bindBg(inputBox, "BackgroundColor3", -0.4)
            round(inputBox, 8)

            inputBox.Focused:Connect(function()
                tween(stroke, 0.2, {Color = mix(Theme.Primary, 0.3)})
            end)

            inputBox.FocusLost:Connect(function(enterPressed)
                tween(stroke, 0.2, {Color = mix(Theme.Background, 0.18)})
                if callback then
                    pcall(function() callback(inputBox.Text, enterPressed) end)
                end
            end)

            return container
        end

        function TabData:CreateParagraph(paragraphTitle, content)
            content = tostring(content or "")
            local textBounds = TextService:GetTextSize(content, 13, Enum.Font.Gotham, Vector2.new(300, 10000))
            local height = 36 + textBounds.Y + 14

            local holder = createHolder(height, 8)
            local container = createSurface(holder, "Frame")

            new("TextLabel", container, {
                Size = UDim2.new(1, -30, 0, 22),
                Position = UDim2.new(0, 15, 0, 8),
                BackgroundTransparency = 1,
                Text = paragraphTitle,
                TextColor3 = WHITE,
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            new("TextLabel", container, {
                Size = UDim2.new(1, -30, 0, textBounds.Y + 4),
                Position = UDim2.new(0, 15, 0, 34),
                BackgroundTransparency = 1,
                Text = content,
                TextColor3 = MUTED,
                Font = Enum.Font.Gotham,
                TextSize = 13,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top
            })

            return container
        end

        function TabData:CreateColorPicker(pickerName, defaultColor, callback)
            local currentColor = defaultColor or DEFAULT_PRIMARY
            local holder = createHolder(45, 8)
            local container = createSurface(holder, "Frame", {ClipsDescendants = true})

            local topBar = new("TextButton", container, {
                Size = UDim2.new(1, 0, 0, 45),
                BackgroundTransparency = 1,
                Text = ""
            })

            createTitle(topBar, pickerName, 0.4)

            local hexLabel = new("TextLabel", topBar, {
                Size = UDim2.new(0, 80, 1, 0),
                Position = UDim2.new(1, -145, 0, 0),
                BackgroundTransparency = 1,
                Text = toHex(currentColor),
                TextColor3 = MUTED,
                Font = Enum.Font.GothamMedium,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Right
            })

            local swatch = new("Frame", topBar, {
                Size = UDim2.new(0, 40, 0, 22),
                Position = UDim2.new(1, -55, 0.5, -11),
                BackgroundColor3 = currentColor,
                BorderSizePixel = 0
            })
            round(swatch, 8)

            createGradientPicker(
                container,
                UDim2.new(0, 15, 0, 55),
                UDim2.new(1, -30, 0, 125),
                currentColor,
                function(color)
                    currentColor = color
                    swatch.BackgroundColor3 = color
                    hexLabel.Text = toHex(color)
                    if callback then
                        pcall(function() callback(color) end)
                    end
                end,
                page
            )

            local isExpanded = false
            topBar.MouseButton1Click:Connect(function()
                isExpanded = not isExpanded
                tween(holder, 0.25, {
                    Size = UDim2.new(0.9, 0, 0, isExpanded and 192 or 45)
                })
            end)

            return container
        end

        function TabData:CreateKeybind(bindName, defaultKey, callback, isMenuKey)
            if type(defaultKey) == "string" then
                local ok, key = pcall(function() return Enum.KeyCode[defaultKey] end)
                defaultKey = ok and key or Enum.KeyCode.Unknown
            end

            local bind = {Key = defaultKey or Enum.KeyCode.Unknown}
            bind.Callback = function()
                if isMenuKey then
                    Window:Toggle()
                end
                if callback then
                    pcall(callback, bind.Key)
                end
            end

            local holder = createHolder(45, 8)
            local container = createSurface(holder, "Frame")

            createTitle(container, bindName, 0.4)

            local keyButton = new("TextButton", container, {
                Size = UDim2.new(0, 90, 0, 28),
                Position = UDim2.new(1, -105, 0.5, -14),
                Text = "",
                TextColor3 = WHITE,
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                BorderSizePixel = 0,
                AutoButtonColor = false
            })
            bindBg(keyButton, "BackgroundColor3", -0.4)
            round(keyButton, 8)
            local keyStroke = addStroke(keyButton, 1.2)

            bind.Refresh = function()
                if bind.Key == Enum.KeyCode.Unknown then
                    keyButton.Text = "None"
                else
                    keyButton.Text = bind.Key.Name
                end
                tween(keyStroke, 0.15, {Color = mix(Theme.Background, 0.18)})
            end

            keyButton.MouseButton1Click:Connect(function()
                if listeningBind and listeningBind ~= bind then
                    listeningBind.Refresh()
                end
                listeningBind = bind
                keyButton.Text = "..."
                tween(keyStroke, 0.15, {Color = Theme.Primary})
            end)

            table.insert(Keybinds, bind)
            bind.Refresh()
            return container
        end

        return TabData
    end

    return Window
end

return NemoZLibrary
