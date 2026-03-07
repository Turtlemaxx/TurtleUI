-- TurtleUI Library
-- Matte black, ultra-modern, custom Roblox GUI framework
-- Usage: local UI = loadstring(game:HttpGet("YOUR_RAW_LINK"))()

local TurtleUI = {}
TurtleUI.__index = TurtleUI

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")
local LocalPlayer      = Players.LocalPlayer

-- ─── THEME ───────────────────────────────────────────────────────────────────
local T = {
    BG          = Color3.fromRGB(9,  9,  10),
    BG2         = Color3.fromRGB(13, 13, 15),
    BG3         = Color3.fromRGB(18, 18, 21),
    Border      = Color3.fromRGB(30, 30, 36),
    BorderHover = Color3.fromRGB(60, 60, 72),
    Accent      = Color3.fromRGB(230, 230, 238),
    AccentDim   = Color3.fromRGB(100, 100, 118),
    Text        = Color3.fromRGB(220, 220, 228),
    TextDim     = Color3.fromRGB(90,  90, 108),
    TextMuted   = Color3.fromRGB(50,  50,  62),
    Green       = Color3.fromRGB(80, 220, 140),
    GreenDim    = Color3.fromRGB(30,  80,  55),
    Red         = Color3.fromRGB(220, 80,  80),
}

-- ─── HELPERS ─────────────────────────────────────────────────────────────────
local function tween(obj, props, t, style, dir)
    TweenService:Create(obj, TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out), props):Play()
end

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function stroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or T.Border
    s.Thickness = thickness or 1
    s.Parent = parent
    return s
end

local function newFrame(parent, size, pos, color, zindex)
    local f = Instance.new("Frame")
    f.Size = size or UDim2.new(1,0,1,0)
    f.Position = pos or UDim2.new(0,0,0,0)
    f.BackgroundColor3 = color or T.BG
    f.BorderSizePixel = 0
    f.ZIndex = zindex or 1
    f.Parent = parent
    return f
end

local function newLabel(parent, text, size, color, font, xalign, zindex)
    local l = Instance.new("TextLabel")
    l.Text = text or ""
    l.Size = size or UDim2.new(1,0,1,0)
    l.BackgroundTransparency = 1
    l.TextColor3 = color or T.Text
    l.Font = font or Enum.Font.GothamBold
    l.TextSize = 11
    l.TextXAlignment = xalign or Enum.TextXAlignment.Left
    l.BorderSizePixel = 0
    l.ZIndex = zindex or 2
    l.Parent = parent
    return l
end

-- ─── WINDOW ──────────────────────────────────────────────────────────────────
function TurtleUI:CreateWindow(config)
    local W = setmetatable({}, TurtleUI)
    W.Tabs = {}
    W.ActiveTab = nil
    W.Toggles = {}
    W.Options = {}
    W.Dragging = false

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "TurtleUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    W.ScreenGui = ScreenGui

    -- Main window frame
    local Win = newFrame(ScreenGui, UDim2.fromOffset(560, 400), UDim2.new(0.5,-280,0.5,-200), T.BG, 1)
    corner(Win, 12)
    stroke(Win, T.Border, 1)
    W.Win = Win

    -- Top accent line
    local AccentBar = newFrame(Win, UDim2.new(1,0,0,2), UDim2.new(0,0,0,0), T.Accent, 3)
    corner(AccentBar, 12)
    local AccentCover = newFrame(Win, UDim2.new(1,0,0,8), UDim2.new(0,0,0,2), T.BG, 3)

    -- Header
    local Header = newFrame(Win, UDim2.new(1,0,0,44), UDim2.new(0,0,0,0), T.BG2, 2)
    corner(Header, 12)
    local HeaderCover = newFrame(Win, UDim2.new(1,0,0,12), UDim2.new(0,0,0,32), T.BG2, 2)

    -- Title dot
    local TitleDot = newFrame(Header, UDim2.fromOffset(5,5), UDim2.fromOffset(14,20), T.Accent, 3)
    corner(TitleDot, 4)

    -- Title
    local TitleLabel = newLabel(Header, config.Title or "TurtleUI", UDim2.new(1,-100,1,0), T.Text, Enum.Font.GothamBold, Enum.TextXAlignment.Left, 3)
    TitleLabel.Position = UDim2.fromOffset(26, 0)
    TitleLabel.TextSize = 12

    -- Close button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.fromOffset(28, 28)
    CloseBtn.Position = UDim2.new(1,-38,0,8)
    CloseBtn.BackgroundColor3 = T.BG3
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = T.TextDim
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 11
    CloseBtn.BorderSizePixel = 0
    CloseBtn.ZIndex = 4
    CloseBtn.Parent = Header
    corner(CloseBtn, 6)
    CloseBtn.MouseEnter:Connect(function() tween(CloseBtn, {TextColor3=T.Text, BackgroundColor3=T.Border}) end)
    CloseBtn.MouseLeave:Connect(function() tween(CloseBtn, {TextColor3=T.TextDim, BackgroundColor3=T.BG3}) end)
    CloseBtn.MouseButton1Click:Connect(function()
        tween(Win, {Size=UDim2.fromOffset(560,0), Position=UDim2.new(0.5,-280,0.5,0)}, 0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        task.wait(0.3)
        ScreenGui:Destroy()
    end)

    -- Minimize button
    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.fromOffset(28, 28)
    MinBtn.Position = UDim2.new(1,-70,0,8)
    MinBtn.BackgroundColor3 = T.BG3
    MinBtn.Text = "─"
    MinBtn.TextColor3 = T.TextDim
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 11
    MinBtn.BorderSizePixel = 0
    MinBtn.ZIndex = 4
    MinBtn.Parent = Header
    corner(MinBtn, 6)
    local minimized = false
    MinBtn.MouseEnter:Connect(function() tween(MinBtn, {TextColor3=T.Text, BackgroundColor3=T.Border}) end)
    MinBtn.MouseLeave:Connect(function() tween(MinBtn, {TextColor3=T.TextDim, BackgroundColor3=T.BG3}) end)
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            tween(Win, {Size=UDim2.fromOffset(560,44)}, 0.25, Enum.EasingStyle.Quint)
        else
            tween(Win, {Size=UDim2.fromOffset(560,400)}, 0.25, Enum.EasingStyle.Quint)
        end
    end)

    -- Drag logic
    local dragStart, startPos
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            W.Dragging = true
            dragStart = input.Position
            startPos = Win.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if W.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+delta.X, startPos.Y.Scale, startPos.Y.Offset+delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then W.Dragging = false end
    end)

    -- Header divider
    local HDivider = newFrame(Win, UDim2.new(1,0,0,1), UDim2.new(0,0,0,44), T.Border, 2)

    -- Tab bar
    local TabBar = newFrame(Win, UDim2.new(1,0,0,36), UDim2.new(0,0,0,45), T.BG2, 2)
    local TabList = Instance.new("UIListLayout")
    TabList.FillDirection = Enum.FillDirection.Horizontal
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0,2)
    TabList.Parent = TabBar
    local TabPad = Instance.new("UIPadding")
    TabPad.PaddingLeft = UDim.new(0,8)
    TabPad.PaddingTop = UDim.new(0,6)
    TabPad.Parent = TabBar
    W.TabBar = TabBar

    -- Tab bar divider
    local TBDivider = newFrame(Win, UDim2.new(1,0,0,1), UDim2.new(0,0,0,81), T.Border, 2)

    -- Content area
    local Content = newFrame(Win, UDim2.new(1,-16,1,-94), UDim2.fromOffset(8,86), T.BG, 2)
    Content.ClipsDescendants = true
    W.Content = Content

    -- Animate open
    Win.Size = UDim2.fromOffset(560, 0)
    Win.Position = UDim2.new(0.5,-280,0.5,0)
    tween(Win, {Size=UDim2.fromOffset(560,400), Position=UDim2.new(0.5,-280,0.5,-200)}, 0.4, Enum.EasingStyle.Quint)

    -- Keybind toggle (RightShift default)
    local toggleKey = Enum.KeyCode.RightShift
    UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == toggleKey then
            Win.Visible = not Win.Visible
        end
    end)

    -- Notify function
    function W:Notify(text, duration)
        local notif = newFrame(ScreenGui, UDim2.fromOffset(260,40), UDim2.new(1,-270,1,-50), T.BG2, 20)
        corner(notif, 8)
        stroke(notif, T.Border, 1)
        local nl = newLabel(notif, text, UDim2.new(1,-16,1,0), T.Text, Enum.Font.Gotham, Enum.TextXAlignment.Left, 21)
        nl.Position = UDim2.fromOffset(12,0)
        nl.TextSize = 11
        local bar = newFrame(notif, UDim2.new(0,2,0,20), UDim2.fromOffset(0,10), T.Accent, 21)
        corner(bar, 2)
        notif.Position = UDim2.new(1,-270,1,-10)
        tween(notif, {Position=UDim2.new(1,-270,1,-50)}, 0.3, Enum.EasingStyle.Quint)
        task.delay(duration or 3, function()
            tween(notif, {Position=UDim2.new(1,-270,1,-10), BackgroundTransparency=1}, 0.3)
            task.wait(0.35)
            notif:Destroy()
        end)
    end

    function W:AddTab(name)
        local Tab = {}
        Tab.Name = name
        Tab.Groups = {}

        -- Tab button
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.fromOffset(0, 24)
        TabBtn.AutomaticSize = Enum.AutomaticSize.X
        TabBtn.BackgroundColor3 = T.BG3
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = name:upper()
        TabBtn.TextColor3 = T.TextMuted
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.TextSize = 10
        TabBtn.BorderSizePixel = 0
        TabBtn.ZIndex = 3
        TabBtn.LayoutOrder = #W.Tabs + 1
        TabBtn.Parent = W.TabBar
        corner(TabBtn, 6)
        local TabBtnPad = Instance.new("UIPadding")
        TabBtnPad.PaddingLeft = UDim.new(0,10)
        TabBtnPad.PaddingRight = UDim.new(0,10)
        TabBtnPad.Parent = TabBtn

        -- Tab indicator
        local TabInd = newFrame(TabBtn, UDim2.new(1,-8,0,1), UDim2.new(0,4,1,-1), T.Accent, 4)
        TabInd.BackgroundTransparency = 1
        corner(TabInd, 1)

        -- Tab content page
        local Page = newFrame(W.Content, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), T.BG, 3)
        Page.Visible = false
        Page.ClipsDescendants = true

        -- Two-column layout
        local LeftCol = newFrame(Page, UDim2.new(0.5,-4,1,0), UDim2.new(0,0,0,0), T.BG, 3)
        local LeftScroll = Instance.new("ScrollingFrame")
        LeftScroll.Size = UDim2.new(1,0,1,0)
        LeftScroll.BackgroundTransparency = 1
        LeftScroll.BorderSizePixel = 0
        LeftScroll.ScrollBarThickness = 2
        LeftScroll.ScrollBarImageColor3 = T.Border
        LeftScroll.CanvasSize = UDim2.new(0,0,0,0)
        LeftScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        LeftScroll.ZIndex = 3
        LeftScroll.Parent = LeftCol
        local LeftList = Instance.new("UIListLayout")
        LeftList.SortOrder = Enum.SortOrder.LayoutOrder
        LeftList.Padding = UDim.new(0,6)
        LeftList.Parent = LeftScroll
        local LeftPad = Instance.new("UIPadding")
        LeftPad.PaddingTop = UDim.new(0,6)
        LeftPad.PaddingBottom = UDim.new(0,6)
        LeftPad.Parent = LeftScroll

        local RightCol = newFrame(Page, UDim2.new(0.5,-4,1,0), UDim2.new(0.5,4,0,0), T.BG, 3)
        local RightScroll = Instance.new("ScrollingFrame")
        RightScroll.Size = UDim2.new(1,0,1,0)
        RightScroll.BackgroundTransparency = 1
        RightScroll.BorderSizePixel = 0
        RightScroll.ScrollBarThickness = 2
        RightScroll.ScrollBarImageColor3 = T.Border
        RightScroll.CanvasSize = UDim2.new(0,0,0,0)
        RightScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        RightScroll.ZIndex = 3
        RightScroll.Parent = RightCol
        local RightList = Instance.new("UIListLayout")
        RightList.SortOrder = Enum.SortOrder.LayoutOrder
        RightList.Padding = UDim.new(0,6)
        RightList.Parent = RightScroll
        local RightPad = Instance.new("UIPadding")
        RightPad.PaddingTop = UDim.new(0,6)
        RightPad.PaddingBottom = UDim.new(0,6)
        RightPad.Parent = RightScroll

        Tab.Page = Page
        Tab.LeftScroll = LeftScroll
        Tab.RightScroll = RightScroll

        -- Switch tab
        local function SelectTab()
            for _, t in pairs(W.Tabs) do
                t.Page.Visible = false
                tween(t.TabBtn, {TextColor3=T.TextMuted, BackgroundTransparency=1})
                tween(t.TabInd, {BackgroundTransparency=1})
            end
            Page.Visible = true
            tween(TabBtn, {TextColor3=T.Text, BackgroundTransparency=0})
            tween(TabInd, {BackgroundTransparency=0})
            W.ActiveTab = Tab
        end

        Tab.TabBtn = TabBtn
        Tab.TabInd = TabInd
        TabBtn.MouseButton1Click:Connect(SelectTab)
        TabBtn.MouseEnter:Connect(function()
            if W.ActiveTab ~= Tab then
                tween(TabBtn, {TextColor3=T.TextDim})
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if W.ActiveTab ~= Tab then
                tween(TabBtn, {TextColor3=T.TextMuted})
            end
        end)

        table.insert(W.Tabs, Tab)
        if #W.Tabs == 1 then SelectTab() end

        -- ── GROUP BUILDER ────────────────────────────────────────────────────
        local function MakeGroup(name, scroll)
            local Group = {}

            local GroupFrame = newFrame(scroll, UDim2.new(1,-4,0,0), UDim2.new(0,0,0,0), T.BG2, 4)
            GroupFrame.AutomaticSize = Enum.AutomaticSize.Y
            corner(GroupFrame, 10)
            stroke(GroupFrame, T.Border, 1)
            local GroupPad = Instance.new("UIPadding")
            GroupPad.PaddingLeft = UDim.new(0,1)
            GroupPad.PaddingRight = UDim.new(0,1)
            GroupPad.Parent = GroupFrame

            -- Group header
            local GHeader = newFrame(GroupFrame, UDim2.new(1,0,0,32), UDim2.new(0,0,0,0), T.BG3, 4)
            corner(GHeader, 10)
            local GHCover = newFrame(GroupFrame, UDim2.new(1,0,0,10), UDim2.new(0,0,0,22), T.BG3, 4)

            local GDot = newFrame(GHeader, UDim2.fromOffset(3,14), UDim2.fromOffset(12,9), T.AccentDim, 5)
            corner(GDot, 2)

            local GTitle = newLabel(GHeader, name:upper(), UDim2.new(1,-16,1,0), T.TextDim, Enum.Font.GothamBold, Enum.TextXAlignment.Left, 5)
            GTitle.Position = UDim2.fromOffset(22,0)
            GTitle.TextSize = 9

            -- Items container
            local Items = newFrame(GroupFrame, UDim2.new(1,0,0,0), UDim2.new(0,0,0,32), T.BG2, 4)
            Items.AutomaticSize = Enum.AutomaticSize.Y
            local ItemList = Instance.new("UIListLayout")
            ItemList.SortOrder = Enum.SortOrder.LayoutOrder
            ItemList.Padding = UDim.new(0,1)
            ItemList.Parent = Items
            local ItemPad = Instance.new("UIPadding")
            ItemPad.PaddingBottom = UDim.new(0,6)
            ItemPad.PaddingLeft = UDim.new(0,6)
            ItemPad.PaddingRight = UDim.new(0,6)
            ItemPad.Parent = Items

            Group.Items = Items
            Group.GroupFrame = GroupFrame

            -- ── TOGGLE ───────────────────────────────────────────────────────
            function Group:AddToggle(id, config)
                local val = config.Default or false
                local cb = config.Callback or function() end

                local Row = newFrame(Items, UDim2.new(1,0,0,34), nil, T.BG2, 5)
                corner(Row, 7)
                Row.BackgroundTransparency = 1

                local RowLabel = newLabel(Row, config.Text or id, UDim2.new(1,-52,1,0), T.Text, Enum.Font.Gotham, Enum.TextXAlignment.Left, 6)
                RowLabel.Position = UDim2.fromOffset(10,0)
                RowLabel.TextSize = 11

                if config.Tooltip then
                    local tip = newLabel(Row, "?", UDim2.fromOffset(14,14), T.TextMuted, Enum.Font.GothamBold, Enum.TextXAlignment.Center, 6)
                    tip.Position = UDim2.new(1,-52,0.5,-7)
                    tip.TextSize = 9
                end

                -- Toggle pill
                local Pill = newFrame(Row, UDim2.fromOffset(36,20), UDim2.new(1,-46,0.5,-10), T.BG3, 6)
                corner(Pill, 10)
                stroke(Pill, T.Border, 1)
                local Knob = newFrame(Pill, UDim2.fromOffset(14,14), UDim2.fromOffset(3,3), T.TextMuted, 7)
                corner(Knob, 7)

                local togStroke = Pill:FindFirstChildOfClass("UIStroke")

                local function SetToggle(v, silent)
                    val = v
                    if v then
                        tween(Pill, {BackgroundColor3=T.GreenDim})
                        tween(togStroke, {Color=T.Green})
                        tween(Knob, {Position=UDim2.fromOffset(19,3), BackgroundColor3=T.Green})
                    else
                        tween(Pill, {BackgroundColor3=T.BG3})
                        tween(togStroke, {Color=T.Border})
                        tween(Knob, {Position=UDim2.fromOffset(3,3), BackgroundColor3=T.TextMuted})
                    end
                    if not silent then cb(v) end
                end

                SetToggle(val, true)

                local TogObj = {}
                function TogObj:SetValue(v) SetToggle(v) end
                function TogObj:GetValue() return val end
                W.Toggles[id] = TogObj

                Pill.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        SetToggle(not val)
                    end
                end)
                Row.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        SetToggle(not val)
                    end
                end)
                Row.MouseEnter:Connect(function() tween(Row, {BackgroundTransparency=0, BackgroundColor3=T.BG3}) end)
                Row.MouseLeave:Connect(function() tween(Row, {BackgroundTransparency=1}) end)

                return TogObj
            end

            -- ── SLIDER ───────────────────────────────────────────────────────
            function Group:AddSlider(id, config)
                local val = config.Default or config.Min or 0
                local min = config.Min or 0
                local max = config.Max or 100
                local rounding = config.Rounding or 0
                local cb = config.Callback or function() end

                local Row = newFrame(Items, UDim2.new(1,0,0,48), nil, T.BG2, 5)
                corner(Row, 7)
                Row.BackgroundTransparency = 1

                local RowLabel = newLabel(Row, config.Text or id, UDim2.new(0.6,0,0,18), T.Text, Enum.Font.Gotham, Enum.TextXAlignment.Left, 6)
                RowLabel.Position = UDim2.fromOffset(10,6)
                RowLabel.TextSize = 11

                local ValLabel = newLabel(Row, tostring(val), UDim2.new(0.4,-10,0,18), T.AccentDim, Enum.Font.GothamBold, Enum.TextXAlignment.Right, 6)
                ValLabel.Position = UDim2.new(0.6,0,0,6)
                ValLabel.TextSize = 10

                local Track = newFrame(Row, UDim2.new(1,-20,0,4), UDim2.fromOffset(10,32), T.BG3, 6)
                corner(Track, 2)
                stroke(Track, T.Border, 1)

                local Fill = newFrame(Track, UDim2.new(0,0,1,0), UDim2.new(0,0,0,0), T.Accent, 7)
                corner(Fill, 2)

                local Knob = newFrame(Track, UDim2.fromOffset(12,12), UDim2.new(0,-6,0.5,-6), T.Accent, 8)
                corner(Knob, 6)

                local function SetVal(v, silent)
                    v = math.clamp(v, min, max)
                    if rounding > 0 then
                        v = math.round(v * (1/rounding)) * rounding
                    else
                        v = math.round(v)
                    end
                    val = v
                    local pct = (v - min)/(max - min)
                    tween(Fill, {Size=UDim2.new(pct,0,1,0)})
                    tween(Knob, {Position=UDim2.new(pct,-6,0.5,-6)})
                    ValLabel.Text = tostring(v)
                    if not silent then cb(v) end
                end

                SetVal(val, true)

                local SliderObj = {}
                function SliderObj:SetValue(v) SetVal(v) end
                function SliderObj:GetValue() return val end
                W.Options[id] = SliderObj

                local dragging = false
                Track.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        tween(Knob, {Size=UDim2.fromOffset(14,14), Position=UDim2.new((val-min)/(max-min),-7,0.5,-7)})
                    end
                end)
                UserInputService.InputChanged:Connect(function(inp)
                    if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                        local trackAbs = Track.AbsolutePosition
                        local trackSize = Track.AbsoluteSize
                        local pct = math.clamp((inp.Position.X - trackAbs.X)/trackSize.X, 0, 1)
                        SetVal(min + (max-min)*pct)
                    end
                end)
                UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
                        dragging = false
                        tween(Knob, {Size=UDim2.fromOffset(12,12)})
                    end
                end)

                Row.MouseEnter:Connect(function() tween(Row, {BackgroundTransparency=0, BackgroundColor3=T.BG3}) end)
                Row.MouseLeave:Connect(function() tween(Row, {BackgroundTransparency=1}) end)

                return SliderObj
            end

            -- ── BUTTON ───────────────────────────────────────────────────────
            function Group:AddButton(config)
                local Row = Instance.new("TextButton")
                Row.Size = UDim2.new(1,0,0,34)
                Row.BackgroundColor3 = T.BG3
                Row.Text = ""
                Row.BorderSizePixel = 0
                Row.ZIndex = 5
                Row.Parent = Items
                corner(Row, 7)
                stroke(Row, T.Border, 1)

                local BLabel = newLabel(Row, config.Text or "Button", UDim2.new(1,-20,1,0), T.Text, Enum.Font.GothamBold, Enum.TextXAlignment.Left, 6)
                BLabel.Position = UDim2.fromOffset(12,0)
                BLabel.TextSize = 11

                local Arrow = newLabel(Row, "→", UDim2.fromOffset(16,34), UDim2.new(1,-20,0,0), T.TextMuted, Enum.Font.GothamBold, Enum.TextXAlignment.Right, 6)
                Arrow.TextSize = 12

                Row.MouseEnter:Connect(function()
                    tween(Row, {BackgroundColor3=T.Border})
                    tween(Arrow, {TextColor3=T.Text})
                end)
                Row.MouseLeave:Connect(function()
                    tween(Row, {BackgroundColor3=T.BG3})
                    tween(Arrow, {TextColor3=T.TextMuted})
                end)
                Row.MouseButton1Down:Connect(function()
                    tween(Row, {BackgroundColor3=T.BG2})
                end)
                Row.MouseButton1Up:Connect(function()
                    tween(Row, {BackgroundColor3=T.Border})
                end)
                Row.MouseButton1Click:Connect(function()
                    if config.Func then config.Func() end
                end)

                return Row
            end

            -- ── INPUT ────────────────────────────────────────────────────────
            function Group:AddInput(id, config)
                local val = config.Default or ""
                local cb = config.Callback or function() end

                local Row = newFrame(Items, UDim2.new(1,0,0,52), nil, T.BG2, 5)
                corner(Row, 7)
                Row.BackgroundTransparency = 1

                local RowLabel = newLabel(Row, config.Text or id, UDim2.new(1,0,0,16), T.TextDim, Enum.Font.GothamBold, Enum.TextXAlignment.Left, 6)
                RowLabel.Position = UDim2.fromOffset(10,6)
                RowLabel.TextSize = 9

                local InputWrap = newFrame(Row, UDim2.new(1,-20,0,26), UDim2.fromOffset(10,24), T.BG3, 6)
                corner(InputWrap, 6)
                local InpStroke = stroke(InputWrap, T.Border, 1)

                local Box = Instance.new("TextBox")
                Box.Size = UDim2.new(1,-16,1,0)
                Box.Position = UDim2.fromOffset(8,0)
                Box.BackgroundTransparency = 1
                Box.TextColor3 = T.Text
                Box.PlaceholderText = config.Placeholder or "..."
                Box.PlaceholderColor3 = T.TextMuted
                Box.Font = Enum.Font.Gotham
                Box.TextSize = 11
                Box.ClearTextOnFocus = false
                Box.BorderSizePixel = 0
                Box.TextXAlignment = Enum.TextXAlignment.Left
                Box.ZIndex = 7
                Box.Parent = InputWrap
                Box.Text = val

                Box.Focused:Connect(function() tween(InpStroke, {Color=T.AccentDim}) end)
                Box.FocusLost:Connect(function(enter)
                    tween(InpStroke, {Color=T.Border})
                    val = Box.Text
                    if not config.Finished or enter then cb(val) end
                end)
                Box:GetPropertyChangedSignal("Text"):Connect(function()
                    if not config.Finished then
                        val = Box.Text
                        cb(val)
                    end
                end)

                local InputObj = {}
                function InputObj:GetValue() return val end
                function InputObj:SetValue(v) Box.Text = v val = v end
                W.Options[id] = InputObj

                Row.MouseEnter:Connect(function() tween(Row, {BackgroundTransparency=0, BackgroundColor3=T.BG3}) end)
                Row.MouseLeave:Connect(function() tween(Row, {BackgroundTransparency=1}) end)

                return InputObj
            end

            -- ── DROPDOWN ─────────────────────────────────────────────────────
            function Group:AddDropdown(id, config)
                local selected = config.Default or nil
                local cb = config.Callback or function() end
                local open = false

                local Wrapper = newFrame(Items, UDim2.new(1,0,0,52), nil, T.BG2, 5)
                Wrapper.AutomaticSize = Enum.AutomaticSize.Y
                corner(Wrapper, 7)
                Wrapper.BackgroundTransparency = 1

                local RowLabel = newLabel(Wrapper, config.Text or id, UDim2.new(1,0,0,16), T.TextDim, Enum.Font.GothamBold, Enum.TextXAlignment.Left, 6)
                RowLabel.Position = UDim2.fromOffset(10,6)
                RowLabel.TextSize = 9

                local DropBtn = Instance.new("TextButton")
                DropBtn.Size = UDim2.new(1,-20,0,28)
                DropBtn.Position = UDim2.fromOffset(10,24)
                DropBtn.BackgroundColor3 = T.BG3
                DropBtn.Text = ""
                DropBtn.BorderSizePixel = 0
                DropBtn.ZIndex = 6
                DropBtn.Parent = Wrapper
                corner(DropBtn, 6)
                local DropStroke = stroke(DropBtn, T.Border, 1)

                local SelLabel = newLabel(DropBtn, selected or config.Placeholder or "Select...", UDim2.new(1,-30,1,0), selected and T.Text or T.TextMuted, Enum.Font.Gotham, Enum.TextXAlignment.Left, 7)
                SelLabel.Position = UDim2.fromOffset(10,0)
                SelLabel.TextSize = 11

                local Chevron = newLabel(DropBtn, "▾", UDim2.fromOffset(20,28), UDim2.new(1,-22,0,0), T.TextMuted, Enum.Font.GothamBold, Enum.TextXAlignment.Right, 7)
                Chevron.TextSize = 10

                -- Dropdown list
                local List = newFrame(Wrapper, UDim2.new(1,-20,0,0), UDim2.fromOffset(10,54), T.BG3, 8)
                List.AutomaticSize = Enum.AutomaticSize.Y
                List.Visible = false
                corner(List, 6)
                stroke(List, T.Border, 1)
                local ListLayout = Instance.new("UIListLayout")
                ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                ListLayout.Padding = UDim.new(0,1)
                ListLayout.Parent = List
                local ListPad = Instance.new("UIPadding")
                ListPad.PaddingTop = UDim.new(0,4)
                ListPad.PaddingBottom = UDim.new(0,4)
                ListPad.Parent = List

                local function PopulateList(options)
                    for _, child in pairs(List:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end
                    for _, opt in ipairs(options or {}) do
                        local Item = Instance.new("TextButton")
                        Item.Size = UDim2.new(1,-8,0,26)
                        Item.Position = UDim2.fromOffset(4,0)
                        Item.BackgroundTransparency = 1
                        Item.BackgroundColor3 = T.Border
                        Item.Text = tostring(opt)
                        Item.TextColor3 = opt == selected and T.Text or T.TextDim
                        Item.Font = Enum.Font.Gotham
                        Item.TextSize = 11
                        Item.TextXAlignment = Enum.TextXAlignment.Left
                        Item.BorderSizePixel = 0
                        Item.ZIndex = 9
                        Item.Parent = List
                        corner(Item, 4)
                        local ItemPad2 = Instance.new("UIPadding")
                        ItemPad2.PaddingLeft = UDim.new(0,8)
                        ItemPad2.Parent = Item
                        Item.MouseEnter:Connect(function() tween(Item,{BackgroundTransparency=0}) end)
                        Item.MouseLeave:Connect(function() tween(Item,{BackgroundTransparency=1}) end)
                        Item.MouseButton1Click:Connect(function()
                            selected = opt
                            SelLabel.Text = tostring(opt)
                            SelLabel.TextColor3 = T.Text
                            List.Visible = false
                            open = false
                            tween(Chevron, {Rotation=0})
                            tween(DropStroke, {Color=T.Border})
                            cb(opt)
                            PopulateList(config.Values)
                        end)
                    end
                end

                PopulateList(config.Values or {})

                DropBtn.MouseButton1Click:Connect(function()
                    open = not open
                    List.Visible = open
                    tween(Chevron, {Rotation = open and 180 or 0})
                    tween(DropStroke, {Color = open and T.AccentDim or T.Border})
                end)

                DropBtn.MouseEnter:Connect(function() tween(DropBtn,{BackgroundColor3=T.Border}) end)
                DropBtn.MouseLeave:Connect(function() tween(DropBtn,{BackgroundColor3=T.BG3}) end)

                local DropObj = {}
                function DropObj:GetValue() return selected end
                function DropObj:SetValue(v)
                    selected = v
                    SelLabel.Text = v
                    SelLabel.TextColor3 = T.Text
                    cb(v)
                end
                function DropObj:Refresh(vals)
                    config.Values = vals
                    PopulateList(vals)
                end
                W.Options[id] = DropObj

                Wrapper.MouseEnter:Connect(function() tween(Wrapper, {BackgroundTransparency=0, BackgroundColor3=T.BG3}) end)
                Wrapper.MouseLeave:Connect(function() tween(Wrapper, {BackgroundTransparency=1}) end)

                return DropObj
            end

            -- ── KEYBIND ──────────────────────────────────────────────────────
            function Group:AddKeyPicker(id, config)
                local key = Enum.KeyCode[config.Default] or Enum.KeyCode.Unknown
                local cb = config.Callback or function() end
                local listening = false

                local Row = newFrame(Items, UDim2.new(1,0,0,34), nil, T.BG2, 5)
                corner(Row, 7)
                Row.BackgroundTransparency = 1

                local RowLabel = newLabel(Row, config.Text or id, UDim2.new(1,-80,1,0), T.Text, Enum.Font.Gotham, Enum.TextXAlignment.Left, 6)
                RowLabel.Position = UDim2.fromOffset(10,0)
                RowLabel.TextSize = 11

                local KeyBtn = Instance.new("TextButton")
                KeyBtn.Size = UDim2.fromOffset(68,22)
                KeyBtn.Position = UDim2.new(1,-76,0.5,-11)
                KeyBtn.BackgroundColor3 = T.BG3
                KeyBtn.Text = key.Name
                KeyBtn.TextColor3 = T.AccentDim
                KeyBtn.Font = Enum.Font.GothamBold
                KeyBtn.TextSize = 9
                KeyBtn.BorderSizePixel = 0
                KeyBtn.ZIndex = 6
                KeyBtn.Parent = Row
                corner(KeyBtn, 5)
                stroke(KeyBtn, T.Border, 1)

                KeyBtn.MouseButton1Click:Connect(function()
                    if listening then return end
                    listening = true
                    KeyBtn.Text = "..."
                    KeyBtn.TextColor3 = T.Accent
                    local conn
                    conn = UserInputService.InputBegan:Connect(function(inp, gp)
                        if inp.UserInputType == Enum.UserInputType.Keyboard then
                            key = inp.KeyCode
                            KeyBtn.Text = key.Name
                            KeyBtn.TextColor3 = T.AccentDim
                            listening = false
                            conn:Disconnect()
                            cb(key)
                        end
                    end)
                end)

                local KeyObj = {}
                function KeyObj:GetValue() return key end
                function KeyObj:SetValue(k)
                    key = k
                    KeyBtn.Text = k.Name
                end
                W.Options[id] = KeyObj

                -- If this is the menu keybind
                if config.Text and config.Text:lower():find("menu") then
                    UserInputService.InputBegan:Connect(function(inp, gp)
                        if not gp and not listening and inp.KeyCode == key then
                            Win.Visible = not Win.Visible
                        end
                    end)
                end

                Row.MouseEnter:Connect(function() tween(Row, {BackgroundTransparency=0, BackgroundColor3=T.BG3}) end)
                Row.MouseLeave:Connect(function() tween(Row, {BackgroundTransparency=1}) end)

                return KeyObj
            end

            -- ── LABEL ────────────────────────────────────────────────────────
            function Group:AddLabel(text)
                local Row = newFrame(Items, UDim2.new(1,0,0,28), nil, T.BG2, 5)
                corner(Row, 7)
                Row.BackgroundTransparency = 1
                local L = newLabel(Row, text, UDim2.new(1,-20,1,0), T.TextDim, Enum.Font.Gotham, Enum.TextXAlignment.Left, 6)
                L.Position = UDim2.fromOffset(10,0)
                L.TextSize = 10
                return Row
            end

            return Group
        end

        function Tab:AddLeftGroupbox(name)
            return MakeGroup(name, Tab.LeftScroll)
        end

        function Tab:AddRightGroupbox(name)
            return MakeGroup(name, Tab.RightScroll)
        end

        -- Single column full-width group
        function Tab:AddGroupbox(name)
            return MakeGroup(name, Tab.LeftScroll)
        end

        return Tab
    end

    -- Expose toggles and options at window level
    W.Toggles = W.Toggles
    W.Options = W.Options

    return W
end

return TurtleUI