-- TurtleUI Library
-- Usage: local UI = loadstring(game:HttpGet("YOUR_RAW_LINK"))()

local TurtleUI = {}
TurtleUI.__index = TurtleUI

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")
local LocalPlayer      = Players.LocalPlayer

-- ─── THEME ───────────────────────────────────────────────────────────────────
local T = {
    BG          = Color3.fromRGB(10, 10, 12),
    BG2         = Color3.fromRGB(15, 15, 18),
    BG3         = Color3.fromRGB(22, 22, 26),
    BG4         = Color3.fromRGB(28, 28, 34),
    Border      = Color3.fromRGB(38, 38, 46),
    BorderHover = Color3.fromRGB(58, 58, 70),
    Accent      = Color3.fromRGB(138, 180, 248),
    AccentDim   = Color3.fromRGB(80, 110, 160),
    AccentGlow  = Color3.fromRGB(60, 80, 130),
    Text        = Color3.fromRGB(215, 215, 222),
    TextDim     = Color3.fromRGB(100, 100, 118),
    TextMuted   = Color3.fromRGB(52, 52, 64),
    Green       = Color3.fromRGB(72, 214, 128),
    GreenDim    = Color3.fromRGB(28, 72, 50),
    Red         = Color3.fromRGB(220, 80, 80),
}

-- ─── HELPERS ─────────────────────────────────────────────────────────────────
local function tween(obj, props, t, style, dir)
    TweenService:Create(obj, TweenInfo.new(t or 0.16, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out), props):Play()
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
    l.Font = font or Enum.Font.Gotham
    l.TextSize = 12
    l.TextXAlignment = xalign or Enum.TextXAlignment.Left
    l.BorderSizePixel = 0
    l.ZIndex = zindex or 2
    l.Parent = parent
    return l
end

-- ─── WINDOW ──────────────────────────────────────────────────────────────────
function TurtleUI:CreateWindow(config)
    local W = setmetatable({}, TurtleUI)
    W.Tabs      = {}
    W.ActiveTab = nil
    W.Toggles   = {}
    W.Options   = {}
    W.Dragging  = false

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "TurtleUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    W.ScreenGui = ScreenGui

    -- Main window
    local Win = newFrame(ScreenGui, UDim2.fromOffset(560, 400), UDim2.new(0.5,-280,0.5,-200), T.BG, 1)
    corner(Win, 10)
    stroke(Win, T.Border, 1)
    W.Win = Win

    -- ── HEADER ───────────────────────────────────────────────────────────────
    local Header = newFrame(Win, UDim2.new(1,0,0,46), UDim2.new(0,0,0,0), T.BG2, 2)
    corner(Header, 10)
    newFrame(Win, UDim2.new(1,0,0,10), UDim2.new(0,0,0,36), T.BG2, 2)  -- square off bottom of header

    -- Left accent stripe
    local Stripe = newFrame(Header, UDim2.fromOffset(3, 20), UDim2.fromOffset(14, 13), T.Accent, 3)
    corner(Stripe, 2)

    -- Title
    local TitleLabel = newLabel(Header, config.Title or "TurtleUI", UDim2.new(1,-60,1,0), T.Text, Enum.Font.GothamBold, Enum.TextXAlignment.Left, 3)
    TitleLabel.Position = UDim2.fromOffset(24, 0)
    TitleLabel.TextSize = 13

    -- Close button (only header button now — no minimize)
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.fromOffset(28, 28)
    CloseBtn.Position = UDim2.new(1,-38,0,9)
    CloseBtn.BackgroundColor3 = T.BG4
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = T.TextDim
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 11
    CloseBtn.BorderSizePixel = 0
    CloseBtn.ZIndex = 4
    CloseBtn.Parent = Header
    corner(CloseBtn, 6)
    stroke(CloseBtn, T.Border, 1)

    CloseBtn.MouseEnter:Connect(function()
        tween(CloseBtn, {TextColor3=T.Red, BackgroundColor3=T.BG4})
    end)
    CloseBtn.MouseLeave:Connect(function()
        tween(CloseBtn, {TextColor3=T.TextDim, BackgroundColor3=T.BG4})
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        tween(Win, {Size=UDim2.fromOffset(560,0), Position=UDim2.new(0.5,-280,0.5,0)}, 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        task.wait(0.28)
        ScreenGui:Destroy()
    end)

    -- Drag
    local dragStart, startPos
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            W.Dragging = true
            dragStart  = input.Position
            startPos   = Win.Position
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

    -- Divider under header
    newFrame(Win, UDim2.new(1,-24,0,1), UDim2.fromOffset(12,46), T.Border, 2)

    -- ── TAB BAR ──────────────────────────────────────────────────────────────
    local TabBar = newFrame(Win, UDim2.new(1,0,0,34), UDim2.new(0,0,0,47), T.BG, 2)
    local TabList = Instance.new("UIListLayout")
    TabList.FillDirection = Enum.FillDirection.Horizontal
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0,4)
    TabList.Parent = TabBar
    local TabPad = Instance.new("UIPadding")
    TabPad.PaddingLeft = UDim.new(0,12)
    TabPad.PaddingTop  = UDim.new(0,6)
    TabPad.Parent = TabBar
    W.TabBar = TabBar

    -- Divider under tab bar
    newFrame(Win, UDim2.new(1,-24,0,1), UDim2.fromOffset(12,81), T.Border, 2)

    -- Content area
    local Content = newFrame(Win, UDim2.new(1,-16,1,-94), UDim2.fromOffset(8,86), T.BG, 2)
    Content.ClipsDescendants = false
    W.Content = Content

    -- Open animation
    Win.Size = UDim2.fromOffset(560, 0)
    Win.Position = UDim2.new(0.5,-280,0.5,0)
    tween(Win, {Size=UDim2.fromOffset(560,400), Position=UDim2.new(0.5,-280,0.5,-200)}, 0.35, Enum.EasingStyle.Quint)

    -- RightShift toggles the GUI
    UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == Enum.KeyCode.RightShift then
            Win.Visible = not Win.Visible
        end
    end)

    -- ── NOTIFY ───────────────────────────────────────────────────────────────
    function W:Notify(text, duration)
        local notif = newFrame(ScreenGui, UDim2.fromOffset(240, 36), UDim2.new(1,-252,1,-48), T.BG2, 20)
        corner(notif, 7)
        stroke(notif, T.Border, 1)
        local bar = newFrame(notif, UDim2.fromOffset(3,16), UDim2.fromOffset(0,10), T.Accent, 21)
        corner(bar, 2)
        local nl = newLabel(notif, text, UDim2.new(1,-14,1,0), T.Text, Enum.Font.Gotham, Enum.TextXAlignment.Left, 21)
        nl.Position = UDim2.fromOffset(10,0)
        nl.TextSize = 11
        notif.Position = UDim2.new(1,-252,1,-10)
        tween(notif, {Position=UDim2.new(1,-252,1,-48)}, 0.28, Enum.EasingStyle.Quint)
        task.delay(duration or 3, function()
            tween(notif, {Position=UDim2.new(1,-252,1,-10)}, 0.22)
            task.wait(0.28)
            notif:Destroy()
        end)
    end

    -- ── TABS ─────────────────────────────────────────────────────────────────
    function W:AddTab(name)
        local Tab = {}
        Tab.Name = name

        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.fromOffset(0, 22)
        TabBtn.AutomaticSize = Enum.AutomaticSize.X
        TabBtn.BackgroundColor3 = T.BG3
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = name
        TabBtn.TextColor3 = T.TextMuted
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.TextSize = 11
        TabBtn.BorderSizePixel = 0
        TabBtn.ZIndex = 3
        TabBtn.LayoutOrder = #W.Tabs + 1
        TabBtn.Parent = W.TabBar
        corner(TabBtn, 5)

        local TBPad = Instance.new("UIPadding")
        TBPad.PaddingLeft  = UDim.new(0,10)
        TBPad.PaddingRight = UDim.new(0,10)
        TBPad.Parent = TabBtn

        -- Bottom underline for active tab
        local TabLine = newFrame(TabBtn, UDim2.new(1,-12,0,2), UDim2.fromOffset(6,19), T.Accent, 4)
        TabLine.BackgroundTransparency = 1
        corner(TabLine, 1)

        Tab.TabBtn  = TabBtn
        Tab.TabLine = TabLine

        -- Page
        local Page = newFrame(W.Content, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), T.BG, 3)
        Page.Visible = false
        Page.ClipsDescendants = false
        Tab.Page = Page

        -- Two scrolling columns
        local function makeCol(xpos)
            local Col = newFrame(Page, UDim2.new(0.5,-4,1,0), xpos, T.BG, 3)
            local Scroll = Instance.new("ScrollingFrame")
            Scroll.Size = UDim2.new(1,0,1,0)
            Scroll.BackgroundTransparency = 1
            Scroll.BorderSizePixel = 0
            Scroll.ScrollBarThickness = 2
            Scroll.ScrollBarImageColor3 = T.Border
            Scroll.CanvasSize = UDim2.new(0,0,0,0)
            Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
            Scroll.ZIndex = 3
            Scroll.Parent = Col
            local SList = Instance.new("UIListLayout")
            SList.SortOrder = Enum.SortOrder.LayoutOrder
            SList.Padding = UDim.new(0,6)
            SList.Parent = Scroll
            local SPad = Instance.new("UIPadding")
            SPad.PaddingTop    = UDim.new(0,6)
            SPad.PaddingBottom = UDim.new(0,6)
            SPad.Parent = Scroll
            return Scroll
        end

        Tab.LeftScroll  = makeCol(UDim2.new(0,0,0,0))
        Tab.RightScroll = makeCol(UDim2.new(0.5,4,0,0))

        local function SelectTab()
            for _, t in pairs(W.Tabs) do
                t.Page.Visible = false
                tween(t.TabBtn,  {TextColor3=T.TextMuted, BackgroundTransparency=1})
                tween(t.TabLine, {BackgroundTransparency=1})
            end
            Page.Visible = true
            tween(TabBtn,  {TextColor3=T.Accent, BackgroundTransparency=0, BackgroundColor3=T.BG3})
            tween(TabLine, {BackgroundTransparency=0})
            W.ActiveTab = Tab
        end

        TabBtn.MouseButton1Click:Connect(SelectTab)
        TabBtn.MouseEnter:Connect(function()
            if W.ActiveTab ~= Tab then tween(TabBtn, {TextColor3=T.TextDim}) end
        end)
        TabBtn.MouseLeave:Connect(function()
            if W.ActiveTab ~= Tab then tween(TabBtn, {TextColor3=T.TextMuted}) end
        end)

        table.insert(W.Tabs, Tab)
        if #W.Tabs == 1 then SelectTab() end

        -- ── GROUP BUILDER ────────────────────────────────────────────────────
        local function MakeGroup(name, scroll)
            local Group = {}

            local GroupFrame = newFrame(scroll, UDim2.new(1,-4,0,0), UDim2.new(0,0,0,0), T.BG2, 4)
            GroupFrame.AutomaticSize = Enum.AutomaticSize.Y
            corner(GroupFrame, 8)
            stroke(GroupFrame, T.Border, 1)

            local GPad = Instance.new("UIPadding")
            GPad.PaddingLeft  = UDim.new(0,1)
            GPad.PaddingRight = UDim.new(0,1)
            GPad.Parent = GroupFrame

            -- Group header row
            local GHeader = newFrame(GroupFrame, UDim2.new(1,0,0,30), UDim2.new(0,0,0,0), T.BG2, 4)
            corner(GHeader, 8)
            newFrame(GroupFrame, UDim2.new(1,0,0,8), UDim2.new(0,0,0,22), T.BG2, 4)

            local GDot = newFrame(GHeader, UDim2.fromOffset(4,4), UDim2.fromOffset(10,13), T.AccentGlow, 5)
            corner(GDot, 2)

            local GTitle = newLabel(GHeader, name, UDim2.new(1,-16,1,0), T.TextDim, Enum.Font.GothamBold, Enum.TextXAlignment.Left, 5)
            GTitle.Position = UDim2.fromOffset(20,0)
            GTitle.TextSize = 10

            newFrame(GroupFrame, UDim2.new(1,-16,0,1), UDim2.fromOffset(8,30), T.Border, 5)

            -- Items container
            local Items = newFrame(GroupFrame, UDim2.new(1,0,0,0), UDim2.new(0,0,0,31), T.BG2, 4)
            Items.AutomaticSize   = Enum.AutomaticSize.Y
            Items.ClipsDescendants = false

            local ItemList = Instance.new("UIListLayout")
            ItemList.SortOrder = Enum.SortOrder.LayoutOrder
            ItemList.Padding = UDim.new(0,1)
            ItemList.Parent = Items

            local ItemPad = Instance.new("UIPadding")
            ItemPad.PaddingBottom = UDim.new(0,6)
            ItemPad.PaddingLeft   = UDim.new(0,6)
            ItemPad.PaddingRight  = UDim.new(0,6)
            ItemPad.Parent = Items

            Group.Items      = Items
            Group.GroupFrame = GroupFrame

            -- ── TOGGLE ───────────────────────────────────────────────────────
            function Group:AddToggle(id, cfg)
                local val = cfg.Default or false
                local cb  = cfg.Callback or function() end

                local Row = Instance.new("TextButton")
                Row.Size = UDim2.new(1,0,0,34)
                Row.BackgroundColor3 = T.BG2
                Row.BackgroundTransparency = 1
                Row.Text = ""
                Row.BorderSizePixel = 0
                Row.ZIndex = 5
                Row.AutoButtonColor = false
                Row.Parent = Items
                corner(Row, 6)

                local RowLabel = newLabel(Row, cfg.Text or id, UDim2.new(1,-54,1,0), T.Text, Enum.Font.Gotham, Enum.TextXAlignment.Left, 6)
                RowLabel.Position = UDim2.fromOffset(10,0)
                RowLabel.TextSize = 11

                local Pill = newFrame(Row, UDim2.fromOffset(34,18), UDim2.new(1,-44,0.5,-9), T.BG4, 6)
                corner(Pill, 9)
                stroke(Pill, T.Border, 1)
                local Knob = newFrame(Pill, UDim2.fromOffset(12,12), UDim2.fromOffset(3,3), T.TextMuted, 7)
                corner(Knob, 6)
                local togStroke = Pill:FindFirstChildOfClass("UIStroke")

                local function SetToggle(v, silent)
                    val = v
                    if v then
                        tween(Pill,      {BackgroundColor3=T.GreenDim})
                        tween(togStroke, {Color=T.Green})
                        tween(Knob,      {Position=UDim2.fromOffset(17,3), BackgroundColor3=T.Green})
                    else
                        tween(Pill,      {BackgroundColor3=T.BG4})
                        tween(togStroke, {Color=T.Border})
                        tween(Knob,      {Position=UDim2.fromOffset(3,3),  BackgroundColor3=T.TextMuted})
                    end
                    if not silent then cb(v) end
                end

                SetToggle(val, true)

                local TogObj = {}
                function TogObj:SetValue(v) SetToggle(v) end
                function TogObj:GetValue() return val end
                W.Toggles[id] = TogObj

                Row.MouseButton1Click:Connect(function() SetToggle(not val) end)
                Row.MouseEnter:Connect(function() tween(Row, {BackgroundTransparency=0, BackgroundColor3=T.BG3}) end)
                Row.MouseLeave:Connect(function() tween(Row, {BackgroundTransparency=1}) end)

                return TogObj
            end

            -- ── SLIDER ───────────────────────────────────────────────────────
            function Group:AddSlider(id, cfg)
                local val      = cfg.Default or cfg.Min or 0
                local min      = cfg.Min or 0
                local max      = cfg.Max or 100
                local rounding = cfg.Rounding or 0
                local cb       = cfg.Callback or function() end

                local Row = Instance.new("TextButton")
                Row.Size = UDim2.new(1,0,0,46)
                Row.BackgroundColor3 = T.BG2
                Row.BackgroundTransparency = 1
                Row.Text = ""
                Row.BorderSizePixel = 0
                Row.ZIndex = 5
                Row.AutoButtonColor = false
                Row.Parent = Items
                corner(Row, 6)

                local RowLabel = newLabel(Row, cfg.Text or id, UDim2.new(0.65,0,0,16), T.Text, Enum.Font.Gotham, Enum.TextXAlignment.Left, 6)
                RowLabel.Position = UDim2.fromOffset(10,5)
                RowLabel.TextSize = 11

                local ValLabel = newLabel(Row, tostring(val), UDim2.new(0.35,-10,0,16), T.Accent, Enum.Font.GothamBold, Enum.TextXAlignment.Right, 6)
                ValLabel.Position = UDim2.new(0.65,0,0,5)
                ValLabel.TextSize = 10

                local Track = newFrame(Row, UDim2.new(1,-20,0,3), UDim2.fromOffset(10,31), T.BG4, 6)
                corner(Track, 2)
                local Fill = newFrame(Track, UDim2.new(0,0,1,0), UDim2.new(0,0,0,0), T.Accent, 7)
                corner(Fill, 2)
                local Knob = newFrame(Track, UDim2.fromOffset(10,10), UDim2.new(0,-5,0.5,-5), T.Accent, 8)
                corner(Knob, 5)

                local function SetVal(v, silent)
                    v = math.clamp(v, min, max)
                    v = rounding > 0 and (math.round(v*(1/rounding))*rounding) or math.round(v)
                    val = v
                    local pct = (v-min)/(max-min)
                    tween(Fill, {Size=UDim2.new(pct,0,1,0)})
                    tween(Knob, {Position=UDim2.new(pct,-5,0.5,-5)})
                    ValLabel.Text = tostring(v)
                    if not silent then cb(v) end
                end

                SetVal(val, true)

                local SliderObj = {}
                function SliderObj:SetValue(v) SetVal(v) end
                function SliderObj:GetValue() return val end
                W.Options[id] = SliderObj

                local sliderDragging = false
                Track.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliderDragging = true
                        W.Dragging = false
                    end
                end)
                UserInputService.InputChanged:Connect(function(inp)
                    if sliderDragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                        local abs  = Track.AbsolutePosition
                        local size = Track.AbsoluteSize
                        SetVal(min + (max-min)*math.clamp((inp.Position.X-abs.X)/size.X, 0, 1))
                    end
                end)
                UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 and sliderDragging then
                        sliderDragging = false
                    end
                end)

                Row.MouseEnter:Connect(function() tween(Row, {BackgroundTransparency=0, BackgroundColor3=T.BG3}) end)
                Row.MouseLeave:Connect(function() tween(Row, {BackgroundTransparency=1}) end)

                return SliderObj
            end

            -- ── BUTTON ───────────────────────────────────────────────────────
            function Group:AddButton(cfg)
                local Row = Instance.new("TextButton")
                Row.Size = UDim2.new(1,0,0,32)
                Row.BackgroundColor3 = T.BG3
                Row.Text = ""
                Row.BorderSizePixel = 0
                Row.ZIndex = 5
                Row.Parent = Items
                corner(Row, 6)
                stroke(Row, T.Border, 1)

                local BLabel = newLabel(Row, cfg.Text or "Button", UDim2.new(1,-24,1,0), T.Text, Enum.Font.Gotham, Enum.TextXAlignment.Left, 6)
                BLabel.Position = UDim2.fromOffset(12,0)
                BLabel.TextSize = 11

                local Chev = newLabel(Row, "›", UDim2.fromOffset(14,32), UDim2.new(1,-16,0,0), T.TextMuted, Enum.Font.GothamBold, Enum.TextXAlignment.Right, 6)
                Chev.TextSize = 14

                Row.MouseEnter:Connect(function()
                    tween(Row,  {BackgroundColor3=T.BG4})
                    tween(Chev, {TextColor3=T.Accent})
                end)
                Row.MouseLeave:Connect(function()
                    tween(Row,  {BackgroundColor3=T.BG3})
                    tween(Chev, {TextColor3=T.TextMuted})
                end)
                Row.MouseButton1Down:Connect(function()  tween(Row, {BackgroundColor3=T.BG2}) end)
                Row.MouseButton1Up:Connect(function()    tween(Row, {BackgroundColor3=T.BG4}) end)
                Row.MouseButton1Click:Connect(function()
                    if cfg.Func then cfg.Func() end
                end)

                return Row
            end

            -- ── INPUT ────────────────────────────────────────────────────────
            function Group:AddInput(id, cfg)
                local val = cfg.Default or ""
                local cb  = cfg.Callback or function() end

                local Row = Instance.new("TextButton")
                Row.Size = UDim2.new(1,0,0,50)
                Row.BackgroundColor3 = T.BG2
                Row.BackgroundTransparency = 1
                Row.Text = ""
                Row.BorderSizePixel = 0
                Row.ZIndex = 5
                Row.AutoButtonColor = false
                Row.Parent = Items
                corner(Row, 6)

                local RowLabel = newLabel(Row, cfg.Text or id, UDim2.new(1,0,0,15), T.TextDim, Enum.Font.GothamBold, Enum.TextXAlignment.Left, 6)
                RowLabel.Position = UDim2.fromOffset(10,5)
                RowLabel.TextSize = 9

                local InputWrap = newFrame(Row, UDim2.new(1,-20,0,24), UDim2.fromOffset(10,23), T.BG4, 6)
                corner(InputWrap, 5)
                local InpStroke = stroke(InputWrap, T.Border, 1)

                local Box = Instance.new("TextBox")
                Box.Size = UDim2.new(1,-16,1,0)
                Box.Position = UDim2.fromOffset(8,0)
                Box.BackgroundTransparency = 1
                Box.TextColor3 = T.Text
                Box.PlaceholderText = cfg.Placeholder or "..."
                Box.PlaceholderColor3 = T.TextMuted
                Box.Font = Enum.Font.Gotham
                Box.TextSize = 11
                Box.ClearTextOnFocus = false
                Box.BorderSizePixel = 0
                Box.TextXAlignment = Enum.TextXAlignment.Left
                Box.ZIndex = 7
                Box.Text = val
                Box.Parent = InputWrap

                Box.Focused:Connect(function()  tween(InpStroke, {Color=T.AccentDim}) end)
                Box.FocusLost:Connect(function(enter)
                    tween(InpStroke, {Color=T.Border})
                    val = Box.Text
                    if not cfg.Finished or enter then cb(val) end
                end)
                Box:GetPropertyChangedSignal("Text"):Connect(function()
                    if not cfg.Finished then val = Box.Text cb(val) end
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
            function Group:AddDropdown(id, cfg)
                local selected = cfg.Default or nil
                local cb       = cfg.Callback or function() end
                local open     = false

                local Wrapper = Instance.new("TextButton")
                Wrapper.Size = UDim2.new(1,0,0,50)
                Wrapper.AutomaticSize = Enum.AutomaticSize.Y
                Wrapper.BackgroundColor3 = T.BG2
                Wrapper.BackgroundTransparency = 1
                Wrapper.Text = ""
                Wrapper.BorderSizePixel = 0
                Wrapper.ZIndex = 5
                Wrapper.AutoButtonColor = false
                Wrapper.Parent = Items
                corner(Wrapper, 6)

                local RowLabel = newLabel(Wrapper, cfg.Text or id, UDim2.new(1,0,0,15), T.TextDim, Enum.Font.GothamBold, Enum.TextXAlignment.Left, 6)
                RowLabel.Position = UDim2.fromOffset(10,5)
                RowLabel.TextSize = 9

                local DropBtn = Instance.new("TextButton")
                DropBtn.Size = UDim2.new(1,-20,0,26)
                DropBtn.Position = UDim2.fromOffset(10,22)
                DropBtn.BackgroundColor3 = T.BG4
                DropBtn.Text = ""
                DropBtn.BorderSizePixel = 0
                DropBtn.ZIndex = 6
                DropBtn.Parent = Wrapper
                corner(DropBtn, 5)
                local DropStroke = stroke(DropBtn, T.Border, 1)

                local SelLabel = newLabel(DropBtn, selected or cfg.Placeholder or "Select...", UDim2.new(1,-30,1,0), selected and T.Text or T.TextMuted, Enum.Font.Gotham, Enum.TextXAlignment.Left, 7)
                SelLabel.Position = UDim2.fromOffset(10,0)
                SelLabel.TextSize = 11

                local Chevron = newLabel(DropBtn, "▾", UDim2.fromOffset(20,26), UDim2.new(1,-22,0,0), T.TextMuted, Enum.Font.GothamBold, Enum.TextXAlignment.Right, 7)
                Chevron.TextSize = 10

                local List = newFrame(Wrapper, UDim2.new(1,-20,0,0), UDim2.fromOffset(10,50), T.BG4, 20)
                List.AutomaticSize   = Enum.AutomaticSize.Y
                List.Visible         = false
                List.ClipsDescendants = false
                corner(List, 6)
                stroke(List, T.Border, 1)

                local ListLayout = Instance.new("UIListLayout")
                ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                ListLayout.Padding   = UDim.new(0,1)
                ListLayout.Parent    = List

                local ListPad = Instance.new("UIPadding")
                ListPad.PaddingTop    = UDim.new(0,4)
                ListPad.PaddingBottom = UDim.new(0,4)
                ListPad.Parent        = List

                local function PopulateList(options)
                    for _, child in pairs(List:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end
                    for _, opt in ipairs(options or {}) do
                        local Item = Instance.new("TextButton")
                        Item.Size = UDim2.new(1,-8,0,24)
                        Item.Position = UDim2.fromOffset(4,0)
                        Item.BackgroundTransparency = 1
                        Item.BackgroundColor3 = T.Border
                        Item.Text = tostring(opt)
                        Item.TextColor3 = opt == selected and T.Accent or T.TextDim
                        Item.Font = Enum.Font.Gotham
                        Item.TextSize = 11
                        Item.TextXAlignment = Enum.TextXAlignment.Left
                        Item.BorderSizePixel = 0
                        Item.ZIndex = 21
                        Item.Parent = List
                        corner(Item, 4)
                        local ip = Instance.new("UIPadding")
                        ip.PaddingLeft = UDim.new(0,8)
                        ip.Parent = Item
                        Item.MouseEnter:Connect(function() tween(Item,{BackgroundTransparency=0}) end)
                        Item.MouseLeave:Connect(function() tween(Item,{BackgroundTransparency=1}) end)
                        Item.MouseButton1Click:Connect(function()
                            selected = opt
                            SelLabel.Text = tostring(opt)
                            SelLabel.TextColor3 = T.Text
                            List.Visible = false
                            open = false
                            tween(Chevron,    {Rotation=0})
                            tween(DropStroke, {Color=T.Border})
                            cb(opt)
                            PopulateList(cfg.Values)
                        end)
                    end
                end

                PopulateList(cfg.Values or {})

                DropBtn.MouseButton1Click:Connect(function()
                    open = not open
                    List.Visible = open
                    tween(Chevron,    {Rotation = open and 180 or 0})
                    tween(DropStroke, {Color = open and T.AccentDim or T.Border})
                end)
                DropBtn.MouseEnter:Connect(function() tween(DropBtn,{BackgroundColor3=T.Border}) end)
                DropBtn.MouseLeave:Connect(function() tween(DropBtn,{BackgroundColor3=T.BG4}) end)

                local DropObj = {}
                function DropObj:GetValue() return selected end
                function DropObj:SetValue(v)
                    selected = v
                    SelLabel.Text = v
                    SelLabel.TextColor3 = T.Text
                    cb(v)
                end
                function DropObj:Refresh(vals)
                    cfg.Values = vals
                    PopulateList(vals)
                end
                W.Options[id] = DropObj

                Wrapper.MouseEnter:Connect(function() tween(Wrapper, {BackgroundTransparency=0, BackgroundColor3=T.BG3}) end)
                Wrapper.MouseLeave:Connect(function() tween(Wrapper, {BackgroundTransparency=1}) end)

                return DropObj
            end

            -- ── KEYBIND ──────────────────────────────────────────────────────
            function Group:AddKeyPicker(id, cfg)
                local key       = Enum.KeyCode[cfg.Default] or Enum.KeyCode.Unknown
                local cb        = cfg.Callback or function() end
                local listening = false

                local Row = Instance.new("TextButton")
                Row.Size = UDim2.new(1,0,0,34)
                Row.BackgroundColor3 = T.BG2
                Row.BackgroundTransparency = 1
                Row.Text = ""
                Row.BorderSizePixel = 0
                Row.ZIndex = 5
                Row.AutoButtonColor = false
                Row.Parent = Items
                corner(Row, 6)

                local RowLabel = newLabel(Row, cfg.Text or id, UDim2.new(1,-84,1,0), T.Text, Enum.Font.Gotham, Enum.TextXAlignment.Left, 6)
                RowLabel.Position = UDim2.fromOffset(10,0)
                RowLabel.TextSize = 11

                local KeyBtn = Instance.new("TextButton")
                KeyBtn.Size = UDim2.fromOffset(70,20)
                KeyBtn.Position = UDim2.new(1,-78,0.5,-10)
                KeyBtn.BackgroundColor3 = T.BG4
                KeyBtn.Text = key.Name
                KeyBtn.TextColor3 = T.Accent
                KeyBtn.Font = Enum.Font.GothamBold
                KeyBtn.TextSize = 9
                KeyBtn.BorderSizePixel = 0
                KeyBtn.ZIndex = 6
                KeyBtn.Parent = Row
                corner(KeyBtn, 4)
                stroke(KeyBtn, T.Border, 1)

                KeyBtn.MouseButton1Click:Connect(function()
                    if listening then return end
                    listening = true
                    KeyBtn.Text = "..."
                    KeyBtn.TextColor3 = T.Text
                    local conn
                    conn = UserInputService.InputBegan:Connect(function(inp, gp)
                        if inp.UserInputType == Enum.UserInputType.Keyboard then
                            key = inp.KeyCode
                            KeyBtn.Text = key.Name
                            KeyBtn.TextColor3 = T.Accent
                            listening = false
                            conn:Disconnect()
                            cb(key)
                        end
                    end)
                end)

                local KeyObj = {}
                function KeyObj:GetValue() return key end
                function KeyObj:SetValue(k) key = k KeyBtn.Text = k.Name end
                W.Options[id] = KeyObj

                if cfg.Text and cfg.Text:lower():find("menu") then
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
                local Row = newFrame(Items, UDim2.new(1,0,0,26), nil, T.BG2, 5)
                corner(Row, 6)
                Row.BackgroundTransparency = 1
                local L = newLabel(Row, text, UDim2.new(1,-20,1,0), T.TextDim, Enum.Font.Gotham, Enum.TextXAlignment.Left, 6)
                L.Position = UDim2.fromOffset(10,0)
                L.TextSize = 10
                return Row
            end

            return Group
        end

        function Tab:AddLeftGroupbox(name)  return MakeGroup(name, Tab.LeftScroll) end
        function Tab:AddRightGroupbox(name) return MakeGroup(name, Tab.RightScroll) end
        function Tab:AddGroupbox(name)      return MakeGroup(name, Tab.LeftScroll) end

        return Tab
    end

    return W
end

return TurtleUI
