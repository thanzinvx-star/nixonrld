local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService      = game:GetService("TextService")
local Workspace        = game:GetService("Workspace")
local Lighting         = game:GetService("Lighting")
local CoreGui          = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- accounts that cannot use Auto-Open Doors, Modes and Auto-Hide
local BLOCKED_USERS = { ["shxdowlessxo"] = true }
local IS_BLOCKED = BLOCKED_USERS[string.lower(LocalPlayer.Name)] == true
local Blk = {} -- holds the blocked toggles so they can be reset

local GUI_NAME = "wtrald_ui"
local SCRIPT_NAME = "WTRALD v.1.5"

local SECTION_IDS = { "A", "B", "G", "MAZE", "T", "U", "Y", "Z", "?" }

local ESP_BLACKLIST = {}
for _, n in ipairs({
    "B-300Baby", "B300Explosion", "ABC", "ABA", "BBB", "M-222", "AMON", "AMON2",
    "M-120-B", "CMOB1", "CMOB2", "CMOB3", "XH1", "ZH2",
    "MOB1", "MOB2", "SN-1", "Glee", "WideGlee", "Glee?", "Bigman", "SB-1", "Happyman", "Sadman", "Angryman", "Mournfulman", "Smartman", "Nerdman", "Shortman", "Scaredman", "G-3", "G-300", "Man", "Joyfulman", "Tallman", "C-1", "1-A", "JB-1",
    "Mushman", "Microman", "Superman", "Sleepyman",
    "SA-150", "PXI-150", "SRG-150", "GCH-150", "THI-150",
    "CYK-150", "TLP-150", "ROT-150", "Glingo", "OMG",
    "CV-300", "FA-122", "GW-122", "UGF-122", "GB-122",
    "BG-122", "MS-122", "JE-122", "TE-222", "MAR-222",
    "SPI-222", "GL-1", "nibbleton", "Spookyman",
    "Pumpkin Tallman", "Ghostman", "Jollyman",
    "Widowed Sleeper", "CAT-120", "Gnarp",
}) do
    ESP_BLACKLIST[string.lower(n)] = true
end

local function normalizeName(name)
    return (string.gsub(string.lower(tostring(name)), "[%s%(%)%[%]]", ""))
end

local ALERT_IGNORE = {}
for _, n in ipairs({
    "Happyman", "Joyfulman", "Nerdman", "Mournfulman", "Shortman", "Tallman",
    "Angryman", "Sadman", "Bigman", "SB-1", "1-A", "1-B", "1-G", "A-1", "CB-1", "Glee", "A-120", "Hardcore-120", "AMON", "AMON2",
    "A-120 (V)", "A-120 (B)", "A-120 (G)", "A-120 (U)", "A-120 (E)", "C-1", "B-1", "G-1", "B-15", "G-3",
    "Widowed Sleeper", "SP-1",
    "E-1", "DG-1", "XE-1", "CHA-1", "BM-1", "V-5", "XV-5", "SN-1",
    "MOB1", "MOB2", "M-222", "B-300Baby", "B300Explosion", "ABC", "ABA", "BBB",
    "M-120-B", "CMOB1", "CMOB2", "CMOB3", "XH1", "ZH2",
    "WideGlee", "Glee?", "Man", "Scaredman",
    "Mushman", "Microman", "Superman", "Sleepyman",
    "SA-150", "PXI-150", "SRG-150", "GCH-150", "THI-150",
    "CYK-150", "TLP-150", "ROT-150", "Glingo", "OMG",
    "CV-300", "FA-122", "GW-122", "UGF-122", "GB-122",
    "BG-122", "MS-122", "JE-122", "TE-222", "MAR-222",
    "SPI-222", "GL-1", "nibbleton", "Spookyman",
    "Pumpkin Tallman", "Ghostman", "Jollyman", "CAT-120", "Gnarp",
}) do
    ALERT_IGNORE[normalizeName(n)] = true
end

local function isAlertIgnored(name)
    local n = normalizeName(name)
    if ALERT_IGNORE[n] == true then return true end
    local flat = string.gsub(n, "[^%w]", "")
    if string.find(flat, "^notreal") then return true end
    return string.find(flat, "a120", 1, true) ~= nil
end

local function isEspIgnored(name)
    local low = string.lower(name)
    if ESP_BLACKLIST[low] then return true end
    local norm = string.gsub(low, "[^%w]", "")
    if string.find(norm, "^notreal") then return true end
    if #norm >= 2 and string.match(norm, "^[xyz]+$") then return true end
    if string.find(norm, "a120", 1, true) then return true end
    if string.find(norm, "300minion", 1, true) or string.find(norm, "minion300", 1, true) then return true end
    return false
end

local function isSpecIgnored(name)
    local flat = string.gsub(string.lower(tostring(name)), "[^%w]", "")
    if string.find(flat, "^notreal") then return true end

    local ignored = {
        "1a", "1b", "1g", "mob1", "mob2",

        "happyman", "joyfulman", "nerdman", "mournfulman",
        "shortman", "tallman", "angryman", "sadman", "bigman",
        "sb1", "glee", "a120", "hardcore120", "amon", "amon2",
        "a120v", "a120b", "a120g", "a120u",
        "c1", "b1", "g1", "b15", "g3",
        "widowedsleeper", "sp1", "e1", "dg1", "xe1",
        "cha1", "bm1", "v5", "xv5", "sn1",
        "b300baby", "b300explosion", "abc", "aba", "bbb",
        "m222", "m120b", "cmob1", "cmob2", "cmob3",
        "xh1", "zh2", "mushman", "microman", "superman",
        "sleepyman", "sa150", "pxi150", "srg150", "gch150",
        "thi150", "cyk150", "tlp150", "rot150", "glingo",
        "omg", "cv300", "fa122", "gw122", "ugf122",
        "gb122", "bg122", "ms122", "je122", "te222",
        "mar222", "spi222", "gl1", "nibbleton",
        "spookyman", "pumpkintallman", "ghostman",
        "jollyman", "cat120", "gnarp"
    }

    for _, v in ipairs(ignored) do
        if flat == v then
            return true
        end
    end

    return false
end

local RETRY_AFTER = 0.3

local Theme = {
    bg      = Color3.fromRGB(10, 10, 15),
    header  = Color3.fromRGB(17, 17, 26),
    card    = Color3.fromRGB(26, 26, 39),
    cardHi  = Color3.fromRGB(38, 38, 58),
    stroke  = Color3.fromRGB(60, 60, 88),
    text    = Color3.fromRGB(242, 242, 252),
    sub     = Color3.fromRGB(150, 150, 178),
    accent  = Color3.fromRGB(139, 92, 246),
    accent2 = Color3.fromRGB(34, 211, 238),
    accentText = Color3.fromRGB(10, 10, 15),
    on      = Color3.fromRGB(82, 196, 128),
    off     = Color3.fromRGB(38, 38, 58),
    danger  = Color3.fromRGB(229, 77, 82),
    warn    = Color3.fromRGB(236, 196, 84),
}

do
local OLD_NAMES = { GUI_NAME, "wtrald_ui_beta" }
for _, getParent in ipairs({
    function() return (gethui and gethui()) or CoreGui end,
    function() return LocalPlayer:FindFirstChildOfClass("PlayerGui") end,
}) do
    pcall(function()
        local parent = getParent()
        for _, child in ipairs(parent:GetChildren()) do
            for _, oldName in ipairs(OLD_NAMES) do
                if child.Name == oldName or child.Name == oldName .. "_ESP" then
                    child:Destroy()
                    break
                end
            end
        end
    end)
end
end

local WHITE = Color3.new(1, 1, 1)
local conns = {}
local function bind(signal, fn)
    local c = signal:Connect(fn)
    table.insert(conns, c)
    return c
end

local function mount(obj)
    local ok = pcall(function() obj.Parent = (gethui and gethui()) or CoreGui end)
    if not ok or not obj.Parent then
        obj.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
end

local function create(class, props, children)
    local o = Instance.new(class)
    local parent
    for k, v in pairs(props or {}) do
        if k == "Parent" then parent = v else o[k] = v end
    end
    for _, c in ipairs(children or {}) do c.Parent = o end
    if parent then o.Parent = parent end
    return o
end

local function corner(r) return create("UICorner", { CornerRadius = UDim.new(0, r) }) end
local function pill() return create("UICorner", { CornerRadius = UDim.new(0.5, 0) }) end
local function stroke(color, thickness, transparency)
    return create("UIStroke", {
        Color = color, Thickness = thickness or 1, Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end
local function accentGrad(rot)
    return create("UIGradient", { Color = ColorSequence.new(Theme.accent, Theme.accent2), Rotation = rot or 0 })
end
local function tween(obj, t, props, style, dir)
    local tw = TweenService:Create(obj, TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
end

local FONT_MED   = Enum.Font.GothamMedium
local FONT_BOLD  = Enum.Font.GothamBold
local FONT_BLACK = Enum.Font.GothamBlack
local FONT_MONO  = Enum.Font.RobotoMono

local function label(props)
    props.BackgroundTransparency = 1
    props.Font = props.Font or FONT_MED
    props.TextColor3 = props.TextColor3 or Theme.text
    props.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
    return create("TextLabel", props)
end

-- vector icons drawn with frames (no text glyphs)
local function makeIcon(kind, parent, size, color)
    local box = create("Frame", {
        Name = "Icon", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(size, size), BackgroundTransparency = 1, Parent = parent,
    })
    local t = math.max(2, size * 0.12)
    local function bar(len, thick, rot, cx, cy)
        return create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(cx * size, cy * size),
            Size = UDim2.fromOffset(len * size, thick), Rotation = rot, BackgroundColor3 = color,
            BorderSizePixel = 0, Parent = box,
        }, { pill() })
    end
    if kind == "close" then
        bar(0.9, t, 45, 0.5, 0.5); bar(0.9, t, -45, 0.5, 0.5)
    elseif kind == "minus" then
        bar(0.75, t, 0, 0.5, 0.5)
    elseif kind == "chevronRight" then
        bar(0.5, t, 45, 0.5, 0.5 - 0.177); bar(0.5, t, -45, 0.5, 0.5 + 0.177)
    elseif kind == "chevronLeft" then
        bar(0.5, t, -45, 0.5, 0.5 - 0.177); bar(0.5, t, 45, 0.5, 0.5 + 0.177)
    elseif kind == "check" then
        bar(0.32, t, 45, 0.25, 0.61); bar(0.62, t, -45, 0.58, 0.50)
    elseif kind == "warn" then
        bar(0.5, t + 0.5, 90, 0.5, 0.36)
        local dot = bar(0.01, t + 1, 0, 0.5, 0.80); dot.Size = UDim2.fromOffset(t + 1, t + 1)
    else
        local dot = bar(0.01, t + 1, 0, 0.5, 0.22); dot.Size = UDim2.fromOffset(t + 1, t + 1)
        bar(0.42, t + 0.5, 90, 0.5, 0.60)
    end
    return box
end

local function tintIcon(icon, color)
    for _, c in ipairs(icon:GetChildren()) do
        if c:IsA("Frame") then c.BackgroundColor3 = color end
    end
end

local function getHRP()
    local c = LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHum()
    local c = LocalPlayer.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end
local function esc(s)
    return (tostring(s):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function tapFx(btn, base, hi)
    btn.MouseButton1Down:Connect(function() tween(btn, 0.08, { BackgroundColor3 = hi }) end)
    local function up() tween(btn, 0.22, { BackgroundColor3 = base }) end
    btn.MouseButton1Up:Connect(up)
    btn.MouseLeave:Connect(up)
    btn.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then up() end
    end)
end

local vp = (Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize) or Vector2.new(800, 400)

local ScreenGui = create("ScreenGui", {
    Name = GUI_NAME, ResetOnSpawn = false, IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999,
})
mount(ScreenGui)

local ESPFolder = create("Folder", { Name = GUI_NAME .. "_ESP" })
mount(ESPFolder)

local win = create("Frame", {
    Name = "Window", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(560, 360), BackgroundColor3 = WHITE, BorderSizePixel = 0, Active = true,
    Parent = ScreenGui,
}, {
    corner(20),
    create("UIGradient", { Color = ColorSequence.new(Color3.fromRGB(22, 17, 40), Color3.fromRGB(9, 9, 14)), Rotation = 125 }),
})
local winGrad = accentGrad()
winGrad.Parent = create("UIStroke", { Color = WHITE, Thickness = 2, Transparency = 0.1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = win })

local uiScale = create("UIScale", { Parent = win })
local function fitScale()
    local cam = Workspace.CurrentCamera
    if not cam then return 1 end
    local v = cam.ViewportSize
    return math.clamp(math.min(v.X / 610, v.Y / 410), 0.5, 1.15)
end
uiScale.Scale = fitScale()
if Workspace.CurrentCamera then
    bind(Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), function() uiScale.Scale = fitScale() end)
end

local top = create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 44), Parent = win })
accentGrad().Parent = label({
    Text = "RLD", Font = FONT_BLACK, TextSize = 20, TextColor3 = WHITE,
    Position = UDim2.new(0, 16, 0, 0), Size = UDim2.new(0, 90, 1, 0), Parent = top,
})

local function topBtn(kind, x, cb)
    local b = create("TextButton", {
        Text = "", BackgroundColor3 = Theme.card,
        AutoButtonColor = false, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, x, 0.5, 0),
        Size = UDim2.fromOffset(30, 26), BorderSizePixel = 0, Parent = top,
    }, { corner(8) })
    local ic = makeIcon(kind, b, 12, Theme.sub)
    b.MouseEnter:Connect(function()
        tween(b, 0.15, { BackgroundColor3 = Theme.cardHi }); tintIcon(ic, Theme.text)
    end)
    b.MouseLeave:Connect(function()
        tween(b, 0.15, { BackgroundColor3 = Theme.card }); tintIcon(ic, Theme.sub)
    end)
    b.MouseButton1Click:Connect(cb)
    return b
end

do
    local dragging, dragStart, startPos
    bind(top.InputBegan, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging, dragStart, startPos = true, i.Position, win.Position
        end
    end)
    bind(UserInputService.InputChanged, function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = (i.Position - dragStart) / uiScale.Scale
            win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    bind(UserInputService.InputEnded, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

local fab = create("TextButton", {
    Text = "",
    BackgroundColor3 = WHITE,
    AutoButtonColor = false,
    Position = UDim2.new(0, 12, 0.5, -24),
    Size = UDim2.fromOffset(48, 48),
    BorderSizePixel = 0,
    ZIndex = 5,
    Parent = ScreenGui,
}, {
    corner(24),
    stroke(WHITE, 2, 0.6)
})

accentGrad(45).Parent = fab

for i = 0, 2 do
    create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, (i - 1) * 7),
        Size = UDim2.fromOffset(20, 3), BackgroundColor3 = Theme.bg, BorderSizePixel = 0, ZIndex = 6, Parent = fab,
    }, { pill() })
end

local function setOpen(v)
    win.Visible = v
    if v then
        local s = fitScale()
        uiScale.Scale = s * 0.88
        tween(uiScale, 0.25, { Scale = s })
    end
end
fab.MouseButton1Click:Connect(function() setOpen(not win.Visible) end)
bind(UserInputService.InputBegan, function(i, gp)
    if not gp and i.KeyCode == Enum.KeyCode.R then setOpen(not win.Visible) end
end)

local pages, tabBtns = {}, {}
local orders = setmetatable({}, { __mode = "k" })
local function nextOrder(page)
    orders[page] = (orders[page] or 0) + 1
    return orders[page]
end

local function selectTab(name)
    for n, p in pairs(pages) do p.Visible = (n == name) end
    for n, t in pairs(tabBtns) do
        local on = n == name
        t.g.Enabled = on
        tween(t.b, 0.2, { BackgroundColor3 = on and WHITE or Theme.card, TextColor3 = on and Theme.bg or Theme.sub })
    end
end

do
local side = create("Frame", {
    BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 48), Size = UDim2.new(0, 128, 1, -58), Parent = win,
}, { create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }) })

local content = create("Frame", {
    BackgroundTransparency = 1, Position = UDim2.new(0, 146, 0, 48), Size = UDim2.new(1, -156, 1, -58),
    ClipsDescendants = true, Parent = win,
})

local TAB_NAMES = { "Chat", "Doors", "ESP", "Tracker", "Items", "Player", "Modes" }
local TAB_ICONS = { Doors = "🚪", ESP = "👁", Tracker = "📡", Items = "🎒", Player = "👤", Modes = "🎮", Chat = "💬" }

for i, name in ipairs(TAB_NAMES) do
    local page = create("ScrollingFrame", {
        Name = name, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 3, ScrollBarImageColor3 = Theme.accent, CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false, Parent = content,
    }, {
        create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
        create("UIPadding", { PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }),
    })
    pages[name] = page
    local b = create("TextButton", {
        Text = TAB_ICONS[name] .. "  " .. name, Font = FONT_BOLD, TextSize = 12, TextColor3 = Theme.sub,
        BackgroundColor3 = Theme.card, AutoButtonColor = false, Size = UDim2.new(1, 0, 0, 34), BorderSizePixel = 0,
        LayoutOrder = i, TextXAlignment = Enum.TextXAlignment.Left, Parent = side,
    }, { corner(10), create("UIPadding", { PaddingLeft = UDim.new(0, 12) }) })
    local g = accentGrad()
    g.Enabled = false
    g.Parent = b
    tabBtns[name] = { b = b, g = g }
    b.MouseButton1Click:Connect(function() selectTab(name) end)
end

end

local function sectionLabel(page, text)
    local l = label({
        Text = string.upper(text), TextSize = 11, Font = FONT_BOLD, TextColor3 = Theme.accent2,
        Size = UDim2.new(1, 0, 0, 20), LayoutOrder = nextOrder(page), Parent = page,
    })
    return l
end

local function baseRow(page, h)
    local row = create("Frame", {
        Size = UDim2.new(1, 0, 0, h), BackgroundColor3 = Theme.card, BorderSizePixel = 0,
        LayoutOrder = nextOrder(page), Parent = page,
    }, { corner(12) })
    local st = create("UIStroke", { Color = Theme.stroke, Thickness = 1, Transparency = 0.55, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = row })
    return row, st
end

local function rowTexts(row, title, sub, rightW, danger, rich)
    local w = -(28 + rightW)
    label({
        Text = title, RichText = rich == true, TextSize = 13, Font = FONT_BOLD,
        TextColor3 = danger and Theme.danger or Theme.text,
        TextTruncate = Enum.TextTruncate.AtEnd, Position = UDim2.fromOffset(14, 8),
        Size = UDim2.new(1, w, 0, 18), Parent = row,
    })
    label({
        Text = sub or "", TextSize = 11, Font = FONT_MED, TextColor3 = Theme.sub,
        TextTruncate = Enum.TextTruncate.AtEnd, Position = UDim2.fromOffset(14, 28),
        Size = UDim2.new(1, w, 0, 14), Parent = row,
    })
end

local function overlayButton(row)
    return create("TextButton", {
        Text = "", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), AutoButtonColor = false,
        ZIndex = 5, Parent = row,
    })
end

local function pressFx(btn, onDown, onUp)
    btn.MouseButton1Down:Connect(onDown)
    btn.MouseButton1Up:Connect(onUp)
    btn.MouseLeave:Connect(onUp)
    btn.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then onUp() end
    end)
end

local function makeToggle(page, title, sub, onChange)
    local row, rowStroke = baseRow(page, 52)
    rowTexts(row, title, sub, 56)
    local sw = create("Frame", {
        Size = UDim2.fromOffset(42, 22), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0),
        BackgroundColor3 = Theme.cardHi, BorderSizePixel = 0, Parent = row,
    }, { corner(11) })
    local g = accentGrad()
    g.Enabled = false
    g.Parent = sw
    local knob = create("Frame", {
        Size = UDim2.fromOffset(16, 16), AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 3, 0.5, 0),
        BackgroundColor3 = WHITE, BorderSizePixel = 0, Parent = sw,
    }, { corner(8) })
    local btn = overlayButton(row)
    pressFx(btn,
        function() tween(row, 0.1, { BackgroundColor3 = Theme.cardHi }) end,
        function() tween(row, 0.25, { BackgroundColor3 = Theme.card }) end)

    local state = false
    local function set(v, silent)
        state = v
        g.Enabled = v
        tween(sw, 0.18, { BackgroundColor3 = v and WHITE or Theme.cardHi })
        tween(knob, 0.18, { Position = v and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0) })
        tween(rowStroke, 0.3, { Color = v and Theme.accent or Theme.stroke, Transparency = v and 0.35 or 0.55 })
        if not silent and onChange then task.spawn(onChange, v) end
    end
    btn.Activated:Connect(function() set(not state) end)
    return { Set = set, Get = function() return state end }
end

local function makeButton(page, title, sub, onClick, danger, rich)
    local row = baseRow(page, 52)
    rowTexts(row, title, sub, 30, danger, rich)
    local tint = danger and Theme.danger or Theme.accent2
    local chev = create("Frame", {
        BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0), Size = UDim2.fromOffset(16, 22), Parent = row,
    })
    local chevIcon = makeIcon("chevronRight", chev, 14, Theme.sub)
    local btn = overlayButton(row)
    pressFx(btn,
        function()
            tween(row, 0.1, { BackgroundColor3 = Theme.cardHi })
            tween(chev, 0.15, { Position = UDim2.new(1, -10, 0.5, 0) }, Enum.EasingStyle.Quint)
            tintIcon(chevIcon, tint)
        end,
        function()
            tween(row, 0.25, { BackgroundColor3 = Theme.card })
            tween(chev, 0.3, { Position = UDim2.new(1, -14, 0.5, 0) }, Enum.EasingStyle.Quint)
            tintIcon(chevIcon, Theme.sub)
        end)
    btn.Activated:Connect(function() task.spawn(onClick) end)
end

local function makeParagraph(page, text, h)
    local row = baseRow(page, h)
    local l = label({
        Text = text, RichText = true, TextSize = 12, TextColor3 = Theme.sub, TextWrapped = true,
        TextTruncate = Enum.TextTruncate.None, TextYAlignment = Enum.TextYAlignment.Top,
        Position = UDim2.fromOffset(12, 8), Size = UDim2.new(1, -24, 1, -16), Parent = row,
    })
    return l
end

local function makeStat(page, title)
    local row = baseRow(page, 50)
    label({
        Text = string.upper(title), TextSize = 10, Font = FONT_BOLD, TextColor3 = Theme.sub,
        Position = UDim2.fromOffset(14, 8), Size = UDim2.new(1, -28, 0, 13), Parent = row,
    })
    local value = label({
        Text = "...", TextSize = 12, Font = FONT_MONO, TextColor3 = Theme.text,
        TextTruncate = Enum.TextTruncate.AtEnd, Position = UDim2.fromOffset(14, 25),
        Size = UDim2.new(1, -28, 0, 18), Parent = row,
    })
    return function(text) value.Text = text end
end

local function makeStatus(page, title)
    local row = baseRow(page, 50)
    label({
        Text = string.upper(title), TextSize = 10, Font = FONT_BOLD, TextColor3 = Theme.sub,
        Position = UDim2.fromOffset(14, 8), Size = UDim2.new(1, -28, 0, 13), Parent = row,
    })
    local dot = create("Frame", {
        Size = UDim2.fromOffset(8, 8), Position = UDim2.fromOffset(14, 31), BackgroundColor3 = Theme.on,
        BorderSizePixel = 0, Parent = row,
    }, { pill() })
    local value = label({
        Text = "...", TextSize = 12, Font = FONT_MONO, TextColor3 = Theme.text,
        TextTruncate = Enum.TextTruncate.AtEnd, Position = UDim2.fromOffset(30, 25),
        Size = UDim2.new(1, -44, 0, 18), Parent = row,
    })
    return function(text, tone)
        value.Text = text
        if tone then tween(dot, 0.3, { BackgroundColor3 = tone }) end
    end
end

local function makeDualStat(page, titleA, titleB)
    local row = baseRow(page, 50)
    local function column(x, title)
        local px = (x == 0) and 14 or 10
        label({
            Text = string.upper(title), TextSize = 10, Font = FONT_BOLD, TextColor3 = Theme.sub,
            Position = UDim2.new(x, px, 0, 8), Size = UDim2.new(0.5, -20, 0, 13), Parent = row,
        })
        local v = label({
            Text = "-", TextSize = 12, Font = FONT_MONO, TextTruncate = Enum.TextTruncate.AtEnd,
            Position = UDim2.new(x, px, 0, 25), Size = UDim2.new(0.5, -20, 0, 18), Parent = row,
        })
        return function(text) v.Text = text end
    end
    create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(0, 1, 1, -22),
        BackgroundColor3 = Theme.stroke, BorderSizePixel = 0, Parent = row,
    })
    return column(0, titleA), column(0.5, titleB)
end

local TRACK_W = 368

local function isDark(c)
    return (c.R * 0.299 + c.G * 0.587 + c.B * 0.114) < 0.25
end

local findEntityImage

local function makeEntityBar(page, title)
    local row = baseRow(page, 100)
    label({
        Text = string.upper(title), TextSize = 10, Font = FONT_BOLD, TextColor3 = Theme.sub,
        Position = UDim2.fromOffset(14, 9), Size = UDim2.new(1, -28, 0, 13), Parent = row,
    })
    local info = label({
        Text = "", TextSize = 10, Font = FONT_MONO, TextColor3 = Theme.sub, TextXAlignment = Enum.TextXAlignment.Right,
        Position = UDim2.fromOffset(14, 9), Size = UDim2.new(1, -28, 0, 13), Parent = row,
    })
    local lane = create("Frame", {
        BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -28, 1, 0), Parent = row,
    })
    create("Frame", {
        Position = UDim2.fromOffset(0, 50), Size = UDim2.new(1, 0, 0, 8), BackgroundColor3 = Theme.bg,
        BorderSizePixel = 0, Parent = lane,
    }, { pill(), stroke(Theme.stroke, 1, 0) })
    local leftLbl = label({
        Text = "", TextSize = 10, Font = FONT_MONO, TextColor3 = Theme.sub,
        Position = UDim2.fromOffset(0, 82), Size = UDim2.new(0.5, 0, 0, 14), Parent = lane,
    })
    local rightLbl = label({
        Text = "", TextSize = 10, Font = FONT_MONO, TextColor3 = Theme.sub, TextXAlignment = Enum.TextXAlignment.Right,
        Position = UDim2.new(0.5, 0, 0, 82), Size = UDim2.new(0.5, 0, 0, 14), Parent = lane,
    })

    local pool, widths = {}, {}

    local function textW(name)
        local w = widths[name]
        if not w then
            local ok, size = pcall(function()
                return TextService:GetTextSize(name, 10, FONT_BOLD, Vector2.new(1000, 20))
            end)
            w = (ok and size.X or #name * 6) + 6
            widths[name] = w
        end
        return w
    end

    local function ensure(key)
        local e = pool[key]
        if e then return e end
        local ds = stroke(Theme.card, 2, 0)
        local dot = create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(0, 54), Size = UDim2.fromOffset(12, 12),
            BackgroundColor3 = WHITE, BorderSizePixel = 0, ZIndex = 3, Parent = lane,
        }, { pill(), ds })
        local img = create("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(0, 54), Size = UDim2.fromOffset(22, 22),
            BackgroundTransparency = 1, BorderSizePixel = 0, ScaleType = Enum.ScaleType.Fit,
            Visible = false, ZIndex = 3, Parent = lane,
        })
        local lbl = label({
            Text = "", TextSize = 10, Font = FONT_BOLD, TextXAlignment = Enum.TextXAlignment.Center,
            TextStrokeTransparency = 0.4, AnchorPoint = Vector2.new(0.5, 0), Size = UDim2.fromOffset(40, 14),
            Position = UDim2.fromOffset(0, 26), ZIndex = 4, Parent = lane,
        })
        e = { dot = dot, img = img, stroke = ds, label = lbl, init = false, hasImg = false, lastTry = 0 }
        pool[key] = e
        return e
    end

    return function(items, leftText, rightText)
        leftLbl.Text, rightLbl.Text = leftText or "", rightText or ""
        info.Text = string.format("%d entities", #items)
        table.sort(items, function(a, b) return a.frac < b.frac end)

        local seen = {}
        local lastA, lastB = -1e9, -1e9
        for _, it in ipairs(items) do
            seen[it.key] = true
            local e = ensure(it.key)
            local w = textW(it.name)
            local x = it.frac * TRACK_W
            local cx = math.clamp(x, w / 2 - 12, TRACK_W - w / 2 + 12)
            local l, r = cx - w / 2, cx + w / 2
            local y
            if l >= lastA + 3 then
                y, lastA = 26, r
            elseif l >= lastB + 3 then
                y, lastB = 68, r
            elseif lastA <= lastB then
                y, lastA = 26, math.max(lastA, r)
            else
                y, lastB = 68, math.max(lastB, r)
            end

            local dark = isDark(it.color)
            e.label.Text = it.name
            e.label.Size = UDim2.fromOffset(w, 14)
            e.label.TextColor3 = it.color
            e.label.TextStrokeColor3 = dark and WHITE or Color3.new(0, 0, 0)
            e.dot.BackgroundColor3 = it.color
            e.stroke.Color = dark and WHITE or Theme.card

            -- Entity image replaces the dot; the dot remains the fallback.
            if it.entity and not e.hasImg and os.clock() - e.lastTry > 1 then
                e.lastTry = os.clock()
                local okI, imageData = pcall(findEntityImage, it.entity)
                if okI and imageData then
                    e.img.Image = imageData.Image
                    e.img.ImageRectOffset = imageData.Offset
                    e.img.ImageRectSize = imageData.Size
                    e.hasImg = true
                end
            end
            e.img.Visible = e.hasImg
            e.dot.Visible = not e.hasImg

            local dp, lp = UDim2.fromOffset(x, 54), UDim2.fromOffset(cx, y)
            if e.init then
                tween(e.dot, 0.3, { Position = dp }, Enum.EasingStyle.Quint)
                tween(e.img, 0.3, { Position = dp }, Enum.EasingStyle.Quint)
                tween(e.label, 0.3, { Position = lp }, Enum.EasingStyle.Quint)
            else
                e.dot.Position, e.img.Position, e.label.Position = dp, dp, lp
                e.init = true
            end
        end

        for key, e in pairs(pool) do
            if not seen[key] then
                e.dot:Destroy()
                e.img:Destroy()
                e.label:Destroy()
                pool[key] = nil
            end
        end
    end
end

local function makeInput(page, title, placeholder, onSubmit)
    local row = baseRow(page, 84)
    label({
        Text = title, TextSize = 13, Font = FONT_BOLD,
        Position = UDim2.fromOffset(14, 8), Size = UDim2.new(1, -28, 0, 18), Parent = row,
    })
    local box = create("TextBox", {
        Text = "", PlaceholderText = placeholder, PlaceholderColor3 = Theme.sub, TextColor3 = Theme.text,
        TextSize = 13, Font = FONT_MONO, ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.fromOffset(14, 40), Size = UDim2.new(1, -92, 0, 32), BackgroundColor3 = Theme.cardHi,
        BorderSizePixel = 0, Parent = row,
    }, { corner(8), create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }) })
    local ok = create("TextButton", {
        Text = "OK", TextSize = 13, Font = FONT_BOLD, TextColor3 = Theme.accentText,
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 40), Size = UDim2.fromOffset(56, 32),
        BackgroundColor3 = WHITE, AutoButtonColor = false, BorderSizePixel = 0, Parent = row,
    }, { corner(8) })
    accentGrad(45).Parent = ok
    box.FocusLost:Connect(function(enter) if enter then onSubmit(box.Text) end end)
    ok.Activated:Connect(function() onSubmit(box.Text) end)
end

local notify

do
local ToastHolder = create("Frame", {
    Name = "Toasts", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 56),
    Size = UDim2.fromOffset(math.clamp(vp.X - 90, 230, 320), 0), AutomaticSize = Enum.AutomaticSize.Y,
    BackgroundTransparency = 1, Parent = ScreenGui,
}, {
    create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
})

local CornerHolder = create("Frame", {
    Name = "CornerToasts", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -16, 0, 56),
    Size = UDim2.fromOffset(math.clamp(vp.X - 90, 200, 260), 0), AutomaticSize = Enum.AutomaticSize.Y,
    BackgroundTransparency = 1, Parent = ScreenGui,
}, {
    create("UIListLayout", {
        Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
    }),
})

local activeToasts = {}
local activeCorner = {}
local MAX_TOASTS = 3
local TOAST_H = 52
local toastN = 0

local function removeActive(entry)
    local list = entry.list or activeToasts
    local i = table.find(list, entry)
    if i then table.remove(list, i) end
end

local function dismissToast(entry, fast)
    if entry.dismissed then return end
    entry.dismissed = true
    local t = fast and 0.15 or 0.28
    tween(entry.card, t, { GroupTransparency = 1 })
    if entry.ringStroke then tween(entry.ringStroke, t, { Transparency = 1 }) end
    tween(entry.wrap, t + 0.06, { Size = UDim2.new(1, 0, 0, 0) })
    task.delay(t + 0.12, function()
        if entry.wrap and entry.wrap.Parent then entry.wrap:Destroy() end
    end)
end

function notify(text, color, duration, glyph, toCorner)
    local list = toCorner and activeCorner or activeToasts
    local holder = toCorner and CornerHolder or ToastHolder
    color = color or Theme.accent
    duration = duration or 3.5
    glyph = glyph or (color == Theme.on and "✓") or ((color == Theme.warn or color == Theme.danger) and "!") or "i"

    for _, e in ipairs(list) do
        if e.text == text and not e.dismissed then e.restart(duration) return end
    end
    while #list >= MAX_TOASTS do
        local old = table.remove(list, 1)
        if old then dismissToast(old, true) end
    end

    toastN += 1
    local wrap = create("Frame", {
        Size = UDim2.new(1, 0, 0, TOAST_H), BackgroundTransparency = 1,
        LayoutOrder = toastN, Parent = holder,
    })
    local card = create("CanvasGroup", {
        Size = UDim2.new(1, 0, 0, TOAST_H), BackgroundColor3 = Theme.header, GroupTransparency = 1, Parent = wrap,
    }, { corner(12) })
    -- border lives on its own frame (outside the CanvasGroup) so the corners stay clean
    local ring = create("Frame", {
        Size = UDim2.new(1, 0, 0, TOAST_H), BackgroundTransparency = 1, BorderSizePixel = 0,
        ZIndex = 5, Parent = wrap,
    }, { corner(12) })
    local ringStroke = create("UIStroke", {
        Color = WHITE, Thickness = 1.5, Transparency = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = ring,
    })
    create("UIGradient", {
        Color = ColorSequence.new(color, isDark(color) and Theme.accent2 or color:Lerp(WHITE, 0.5)),
        Rotation = 35, Parent = ringStroke,
    })
    local badge = create("TextLabel", {
        Text = "", TextSize = 14, Font = FONT_BLACK, TextColor3 = color, BackgroundColor3 = color,
        BackgroundTransparency = 0.84, Size = UDim2.fromOffset(26, 26), Position = UDim2.fromOffset(10, 11),
        BorderSizePixel = 0, Parent = card,
    }, { corner(8) })
    makeIcon((color == Theme.on) and "check" or ((color == Theme.warn or color == Theme.danger) and "warn" or "info"), badge, 16, color)
    label({
        Text = text, RichText = true, TextSize = 12, Font = FONT_MED, TextWrapped = true,
        TextTruncate = Enum.TextTruncate.None, TextYAlignment = Enum.TextYAlignment.Center,
        Position = UDim2.fromOffset(44, 2), Size = UDim2.new(1, -54, 1, -10), Parent = card,
    })
    local barTrack = create("Frame", {
        Position = UDim2.new(0, 10, 1, -7), Size = UDim2.new(1, -20, 0, 2), BackgroundColor3 = Theme.stroke,
        BackgroundTransparency = 0.4, BorderSizePixel = 0, Parent = card,
    }, { pill() })
    local bar = create("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = color, BorderSizePixel = 0, Parent = barTrack }, { pill() })

    local entry = { text = text, wrap = wrap, card = card, ringStroke = ringStroke, list = list, dismissed = false, token = 0 }
    local barTween
    local function start(dur)
        entry.token += 1
        local token = entry.token
        if barTween then barTween:Cancel() end
        bar.Size = UDim2.fromScale(1, 1)
        barTween = tween(bar, dur, { Size = UDim2.fromScale(0, 1) }, Enum.EasingStyle.Linear)
        task.delay(dur, function()
            if entry.token == token and not entry.dismissed then
                removeActive(entry)
                dismissToast(entry, false)
            end
        end)
    end
    entry.restart = function(dur) start(dur) end
    table.insert(list, entry)
    tween(card, 0.3, { GroupTransparency = 0 })
    tween(ringStroke, 0.3, { Transparency = 0.1 })
    start(duration)
end

end

local Dialog = { onConfirm = nil, base = Theme.accent, hi = Theme.accent }

do
local DialogOverlay = create("Frame", {
    Name = "Dialog", Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0),
    BackgroundTransparency = 1, BorderSizePixel = 0, Active = true, Visible = false, ZIndex = 50, Parent = ScreenGui,
})
local DialogCard = create("CanvasGroup", {
    AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(math.clamp(vp.X - 48, 250, 330), 184), BackgroundColor3 = Theme.card,
    GroupTransparency = 1, ZIndex = 51, Parent = DialogOverlay,
}, { corner(14), stroke(Theme.stroke, 1, 0) })
local DialogBar = create("Frame", {
    Size = UDim2.new(1, 0, 0, 3), BackgroundColor3 = Theme.danger, BorderSizePixel = 0, Parent = DialogCard,
})
local DialogTitle = label({
    Text = "", RichText = true, TextSize = 17, Font = FONT_BOLD, TextColor3 = Color3.new(1, 1, 1),
    Position = UDim2.fromOffset(18, 18), Size = UDim2.new(1, -36, 0, 22), Parent = DialogCard,
})
local DialogBody = label({
    Text = "", RichText = true, TextWrapped = true, TextSize = 13, Font = FONT_MED, TextColor3 = Theme.sub,
    TextYAlignment = Enum.TextYAlignment.Top, Position = UDim2.fromOffset(18, 48), Size = UDim2.new(1, -36, 0, 62),
    Parent = DialogCard,
})

local function dialogButton(text, bg, fg, anchorX)
    return create("TextButton", {
        Text = text, TextSize = 14, Font = FONT_BOLD, TextColor3 = fg, AutoButtonColor = false,
        AnchorPoint = Vector2.new(anchorX, 0), Position = UDim2.new(anchorX, anchorX == 0 and 16 or -16, 1, -58),
        Size = UDim2.new(0.5, -22, 0, 42), BackgroundColor3 = bg, BorderSizePixel = 0, Parent = DialogCard,
    }, { corner(10) })
end
local ConfirmBtn = dialogButton("Confirm", Theme.danger, Color3.new(1, 1, 1), 0)
local CancelBtn = dialogButton("Cancel", Theme.cardHi, Theme.text, 1)
tapFx(CancelBtn, Theme.cardHi, Theme.stroke)
do
    ConfirmBtn.MouseButton1Down:Connect(function() tween(ConfirmBtn, 0.08, { BackgroundColor3 = Dialog.hi }) end)
    local function up() tween(ConfirmBtn, 0.22, { BackgroundColor3 = Dialog.base }) end
    ConfirmBtn.MouseButton1Up:Connect(up)
    ConfirmBtn.MouseLeave:Connect(up)
    ConfirmBtn.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then up() end
    end)
end

function Dialog.hide()
    DialogOverlay.Visible = false
    DialogOverlay.Active = false

    DialogOverlay.BackgroundTransparency = 1
    DialogCard.GroupTransparency = 1

    Dialog.onConfirm = nil
end

function Dialog.show(opts)
    Dialog.onConfirm = opts.onConfirm
    Dialog.base = opts.confirmBg or Theme.accent
    Dialog.hi = Dialog.base:Lerp(Color3.new(0, 0, 0), 0.2)
    DialogTitle.Text = opts.title or ""
    DialogBody.Text = opts.body or ""
    DialogBar.BackgroundColor3 = opts.bar or Theme.accent
    ConfirmBtn.Text = opts.confirmText or "Confirm"
    ConfirmBtn.BackgroundColor3 = Dialog.base
    ConfirmBtn.TextColor3 = opts.confirmFg or Theme.accentText
    CancelBtn.Text = opts.cancelText or "Cancel"
    DialogOverlay.Active = true
    DialogOverlay.BackgroundTransparency = 1
    DialogCard.GroupTransparency = 1
    DialogOverlay.Visible = true
    tween(DialogOverlay, 0.2, { BackgroundTransparency = 0.45 })
    DialogCard.Position = UDim2.new(0.5, 0, 0.5, 16)
    tween(DialogCard, 0.3, { GroupTransparency = 0, Position = UDim2.fromScale(0.5, 0.5) }, Enum.EasingStyle.Back)
end

CancelBtn.Activated:Connect(function()
    Dialog.onConfirm = nil
    Dialog.hide()
end)
ConfirmBtn.Activated:Connect(function()
    local fn = Dialog.onConfirm
    Dialog.onConfirm = nil
    Dialog.hide()
    if fn then task.spawn(fn) end
end)
end

bind(RunService.Heartbeat, function(dt)
    winGrad.Rotation = (winGrad.Rotation + dt * 50) % 360
end)

local function getAllEntities()
    local list = {}
    local folder = Workspace:FindFirstChild("Entities")
    if not folder then return list end
    for _, obj in ipairs(folder:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            if obj.Name == "B-65" then pcall(function() obj.Name = "B-67" end) end -- B-65 is really B-67
            local ancestor = obj.Parent
            local insideModel = false
            while ancestor and ancestor ~= folder do
                if ancestor:IsA("Model") then insideModel = true break end
                ancestor = ancestor.Parent
            end
            if not insideModel then table.insert(list, obj) end
        end
    end
    return list
end

local naturalLess
do
local naturalKeys = {}
local function naturalKey(name)
    local k = naturalKeys[name]
    if k then return k end
    k = {}
    local s, i = string.lower(name), 1
    while i <= #s do
        local d = string.match(s, "^%d+", i)
        if d then
            k[#k + 1] = tonumber(d)
            i += #d
        else
            local x = string.match(s, "^%D+", i)
            k[#k + 1] = x
            i += #x
        end
    end
    naturalKeys[name] = k
    return k
end
naturalLess = function(a, b)
    local ka, kb = naturalKey(a.Name), naturalKey(b.Name)
    for i = 1, math.min(#ka, #kb) do
        local x, y = ka[i], kb[i]
        if x ~= y then
            local tx, ty = type(x), type(y)
            if tx ~= ty then return tx == "number" end
            return x < y
        end
    end
    if #ka ~= #kb then return #ka < #kb end
    return a.Name < b.Name
end
end

local function getEntities()
    local list = {}
    for _, c in ipairs(getAllEntities()) do
        if not isEspIgnored(c.Name) then table.insert(list, c) end
    end
    table.sort(list, naturalLess)
    return list
end

local function getSpectables()
    local list = {}
    for _, c in ipairs(getEntities()) do
        if not isSpecIgnored(c.Name) then table.insert(list, c) end
    end
    return list
end

local function getRoot(entity)
    if entity:IsA("BasePart") then return entity end
    return entity.PrimaryPart
        or entity:FindFirstChild("HumanoidRootPart")
        or entity:FindFirstChildWhichIsA("BasePart", true)
end

local function entityPos(entity)
    if entity:IsA("Model") then return entity:GetPivot().Position end
    return entity.Position
end

local entityColor
do
local lightCache = setmetatable({}, { __mode = "k" })

local function findLight(entity)
    local rush = (entity.Name == "RushNew") and entity or entity:FindFirstChild("RushNew", true)
    if rush then
        if rush:IsA("PointLight") then return rush end
        local l = rush:FindFirstChild("PointLight", true)
        if l and l:IsA("Light") then return l end
    end
    local l2 = entity:FindFirstChild("PointLight2", true)
    if l2 and l2:IsA("Light") then return l2 end
    local l3 = entity:FindFirstChild("PointLight", true)
    if l3 and l3:IsA("Light") then return l3 end
    return entity:FindFirstChildWhichIsA("PointLight", true)
end

local function findMockLight(entity)
    local fallback
    for _, d in ipairs(entity:GetDescendants()) do
        if string.lower(d.Name) == "mock" then
            local l = d:IsA("Light") and d or d:FindFirstChildWhichIsA("Light", true)
            if l then
                if l.Enabled then return l end
                fallback = fallback or l
            end
        end
    end
    return fallback
end

local G88_COLORS = {
    orange = Color3.fromRGB(255, 128, 0),
    pink   = Color3.fromRGB(255, 105, 180),
    red    = Color3.fromRGB(255, 0, 0),
    yellow = Color3.fromRGB(255, 230, 0),
}
local g88Last = setmetatable({}, { __mode = "k" })

local function g88Color(entity)
    local anyLight
    for _, d in ipairs(entity:GetDescendants()) do
        if d:IsA("Light") then
            local col = G88_COLORS[string.lower(d.Name)]
            if col then
                anyLight = anyLight or d
                if d.Enabled and d.Brightness > 0 then
                    g88Last[entity] = col
                    return col
                end
            end
        end
    end
    if g88Last[entity] then return g88Last[entity] end
    if anyLight then return G88_COLORS[string.lower(anyLight.Name)] end
    return nil
end

entityColor = function(entity)
    local lowName = string.lower(entity.Name)
    if lowName == "cb-60" or lowName == "b-60" then
        local want = (lowName == "cb-60") and "PointLight2" or "PointLight"
        local l = entity:FindFirstChild(want, true)
        if l and l:IsA("Light") then return l.Color end
    end
    if lowName == "g-177" then
        local mock = findMockLight(entity)
        if mock then return mock.Color end
    end
    if lowName == "g-88" then
        local col = g88Color(entity)
        if col then return col end
    end

    local c = lightCache[entity]
    if not c or (c.light and not c.light.Parent) or (not c.light and os.clock() - c.t > 1) then
        c = { light = findLight(entity), t = os.clock() }
        lightCache[entity] = c
    end
    if c.light then return c.light.Color end
    return Color3.new(1, 1, 1)
end
end

local function richName(name, color)
    local text = string.format('<font color="#%s">%s</font>', color:ToHex(), esc(name))
    if isDark(color) then
        text = '<stroke color="#FFFFFF" thickness="1">' .. text .. '</stroke>'
    end
    return text
end

local setESP

do
local ESP = { on = false, items = {} }

local function espRemove(entity)
    local item = ESP.items[entity]
    if item then
        item.gui:Destroy()
        item.hl:Destroy()
        ESP.items[entity] = nil
    end
end

local function espAdd(entity)
    if ESP.items[entity] then return end
    local root = getRoot(entity)
    if not root then return end
    local color = entityColor(entity)

    local gui = create("BillboardGui", {
        Name = "EntityESP", Adornee = root, AlwaysOnTop = true, Size = UDim2.fromOffset(220, 24),
        StudsOffset = Vector3.new(0, 3, 0), ResetOnSpawn = false, Parent = ESPFolder,
    })
    local lbl = label({
        Text = entity.Name, TextSize = 15, Font = FONT_BOLD, TextColor3 = color,
        TextStrokeTransparency = 0.25, TextXAlignment = Enum.TextXAlignment.Center,
        Size = UDim2.fromScale(1, 1), Parent = gui,
    })
    local hl = create("Highlight", {
        Adornee = entity, FillColor = color, OutlineColor = color, FillTransparency = 0.78,
        OutlineTransparency = 0, DepthMode = Enum.HighlightDepthMode.AlwaysOnTop, Parent = ESPFolder,
    })
    ESP.items[entity] = { gui = gui, label = lbl, hl = hl }
end

function setESP(v)
    ESP.on = v
    if v then
        for _, e in ipairs(getEntities()) do espAdd(e) end
    else
        for e in pairs(ESP.items) do espRemove(e) end
    end
end

task.spawn(function()
    while ScreenGui.Parent do
        if ESP.on then
            pcall(function()
                local current = {}
                for _, e in ipairs(getEntities()) do
                    current[e] = true
                    espAdd(e)
                end
                local myRoot = getHRP()
                for entity, item in pairs(ESP.items) do
                    if not entity.Parent or not current[entity] then
                        espRemove(entity)
                    else
                        local root = getRoot(entity)
                        if root then item.gui.Adornee = root end
                        local dist = myRoot and math.floor((entityPos(entity) - myRoot.Position).Magnitude + 0.5) or 0
                        item.label.Text = string.format("%s | %dm", entity.Name, dist)
                        local c = entityColor(entity)
                        local dark = isDark(c)
                        item.label.TextColor3 = c
                        item.label.TextStrokeColor3 = dark and Color3.new(1, 1, 1) or Color3.new(0, 0, 0)
                        item.hl.FillColor = c
                        item.hl.OutlineColor = dark and Color3.new(1, 1, 1) or c
                    end
                end
            end)
        end
        task.wait(0.1)
    end
end)

end

local Spec = { active = false, entity = nil }
local specOpen, specClose, specStep

do
local SpecAudio = { originals = setmetatable({}, { __mode = "k" }) }

local function restoreSpectateAudio()
    for sound, original in pairs(SpecAudio.originals) do
        if sound and sound.Parent then pcall(function() sound.Volume = original end) end
    end
    table.clear(SpecAudio.originals)
end

local function updateSpectateAudio()
    if not Spec.active or not Spec.entity then return end
    local selected = Spec.entity
    for _, entity in ipairs(getAllEntities()) do
        for _, obj in ipairs(entity:GetDescendants()) do
            if obj:IsA("Sound") then
                if SpecAudio.originals[obj] == nil then SpecAudio.originals[obj] = obj.Volume end
                pcall(function() obj.Volume = (entity == selected) and 1.5 or 0 end)
            end
        end
    end
end

local SpectateBar = create("Frame", {
    Name = "Spectate", AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -24),
    Size = UDim2.fromOffset(280, 92), BackgroundTransparency = 1, Visible = false, Parent = ScreenGui,
})
local CloseBtn = create("TextButton", {
    Text = "Close Spectate", TextSize = 13, Font = FONT_BOLD, TextColor3 = Color3.new(1, 1, 1),
    AutoButtonColor = false, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 0),
    Size = UDim2.fromOffset(140, 28), BackgroundColor3 = Theme.danger, BorderSizePixel = 0, Parent = SpectateBar,
}, { pill() })
tapFx(CloseBtn, Theme.danger, Color3.fromRGB(190, 58, 63))
local NavRow = create("Frame", {
    Position = UDim2.fromOffset(0, 38), Size = UDim2.new(1, 0, 0, 52), BackgroundColor3 = Theme.card,
    BorderSizePixel = 0, Parent = SpectateBar,
}, { corner(12), stroke(Theme.stroke, 1, 0) })

local function navBtn(kind, anchorX)
    local b = create("TextButton", {
        Text = "", TextSize = 20, Font = FONT_BOLD, TextColor3 = Theme.text, AutoButtonColor = false,
        AnchorPoint = Vector2.new(anchorX, 0.5), Position = UDim2.new(anchorX, anchorX == 0 and 7 or -7, 0.5, 0),
        Size = UDim2.fromOffset(44, 38), BackgroundColor3 = Theme.cardHi, BorderSizePixel = 0, Parent = NavRow,
    }, { corner(9) })
    makeIcon(kind, b, 18, Theme.text)
    tapFx(b, Theme.cardHi, Theme.stroke)
    return b
end
local PrevBtn, NextBtn = navBtn("chevronLeft", 0), navBtn("chevronRight", 1)
local NameLabel = label({
    Text = "", RichText = true, TextSize = 15, Font = FONT_BOLD, TextTruncate = Enum.TextTruncate.AtEnd,
    TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(58, 0), Size = UDim2.new(1, -116, 1, 0),
    Parent = NavRow,
})

local function updateSpecLabel()
    local e = Spec.entity
    if not e then return end
    NameLabel.Text = "<b>" .. richName(e.Name, entityColor(e)) .. "</b>"
end

do
    local acc = 0
    bind(RunService.Heartbeat, function(dt)
        if not Spec.active then return end
        acc += dt
        if acc < 0.1 then return end
        acc = 0
        updateSpecLabel()
        updateSpectateAudio()
    end)
end

local function specSet(entity)
    Spec.entity = entity
    updateSpectateAudio()
    local cam = Workspace.CurrentCamera
    local hum = entity:FindFirstChildWhichIsA("Humanoid", true)
    cam.CameraType = Enum.CameraType.Custom
    cam.CameraSubject = hum or getRoot(entity)
    updateSpecLabel()
end

function specClose()
    Spec.active, Spec.entity = false, nil
    restoreSpectateAudio()
    SpectateBar.Visible = false
    local cam = Workspace.CurrentCamera
    local hum = getHum()
    if cam and hum then cam.CameraSubject = hum end
end

function specStep(dir)
    local list = getSpectables()
    if #list == 0 then
        specClose()
        notify("No entities left to spectate, returning your camera...", Theme.warn)
        return
    end
    local idx = table.find(list, Spec.entity) or 0
    idx = ((idx - 1 + dir) % #list) + 1
    specSet(list[idx])
end

function specOpen()
    local list = getSpectables()
    if #list == 0 then
        notify("No entities found in <b>Workspace.Entities</b>.", Theme.warn)
        return
    end
    Spec.active = true
    SpectateBar.Visible = true
    specSet(list[1])
end

PrevBtn.Activated:Connect(function() specStep(-1) end)
NextBtn.Activated:Connect(function() specStep(1) end)
CloseBtn.Activated:Connect(specClose)
end

local AlertOn = false
local ALERT_VARIANT = {}
do
local function regVariant(list, suffix)
    for _, name in ipairs(list) do ALERT_VARIANT[normalizeName(name)] = suffix end
end

regVariant({
    "A-105", "C-105", "A-100", "X-100", "A-320", "B-170", "B-40",
    "G-55", "CG-55", "G-150", "G-122", "Cate-40", "Noonir-40",
    "Omg-40", "G-10", "CG-10", "T-110", "GodHasForsaken",
}, " spawned, hide in a table! (table must be color of lightwood)")

regVariant({
    "A-200", "B-120", "CV-300", "FO-300", "G-140", "MY_INNER_SKIN",
}, " spawned, hide on a grey locker (must be color RGB(163, 162, 165)) or blue locker! (must be RGB(13, 105, 172))")

regVariant({ "A-185" }, " spawned, hide on a GREY locker or a table!")
end

local TrackerEvents = { spawned = "—", despawned = "—" }

-- Centered alert card with the entity picture (RushNew.MonsterGui)
local alertNotify
do
local AlertHolder = create("Frame", {
    Name = "Alerts", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0.32),
    Size = UDim2.fromOffset(math.clamp(vp.X - 60, 240, 360), 0), AutomaticSize = Enum.AutomaticSize.Y,
    BackgroundTransparency = 1, ZIndex = 30, Parent = ScreenGui,
}, {
    create("UIListLayout", {
        Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
    }),
})

-- Finds the entity picture: RushNew.MonsterGui, or any MonsterGui / BillboardGui variant
local function imageFrom(gui)
    if gui:IsA("StringValue") and gui.Value ~= "" then
        return { Image = gui.Value, Offset = Vector2.zero, Size = Vector2.zero }
    end
    local src
    if gui:IsA("ImageLabel") or gui:IsA("ImageButton") then
        src = gui
    else
        src = gui:FindFirstChildWhichIsA("ImageLabel", true) or gui:FindFirstChildWhichIsA("ImageButton", true)
    end
    if src and src.Image ~= "" then
        return { Image = src.Image, Offset = src.ImageRectOffset, Size = src.ImageRectSize }
    end
    local decal = gui:FindFirstChildWhichIsA("Decal", true) or gui:FindFirstChildWhichIsA("Texture", true)
    if decal and decal.Texture ~= "" then
        return { Image = decal.Texture, Offset = Vector2.zero, Size = Vector2.zero }
    end
    return nil
end

local IMAGE_GUI_NAMES = { "MonsterGui", "BillboardGui" }

findEntityImage = function(entity)
    local roots = {}
    local rush = (entity.Name == "RushNew") and entity or entity:FindFirstChild("RushNew", true)
    if rush then table.insert(roots, rush) end
    table.insert(roots, entity)

    for _, root in ipairs(roots) do
        for _, nm in ipairs(IMAGE_GUI_NAMES) do
            local gui = (root.Name == nm) and root or root:FindFirstChild(nm, true)
            if gui then
                local r = imageFrom(gui)
                if r then return r end
            end
        end
    end
    -- last resort: any BillboardGui object inside the entity
    for _, d in ipairs(entity:GetDescendants()) do
        if d:IsA("BillboardGui") then
            local r = imageFrom(d)
            if r then return r end
        end
    end
    return nil
end

local activeAlerts, alertN = {}, 0
local ALERT_SHOW = 4

local function dismissAlert(a, instant)
    if a.dead then return end
    a.dead = true
    local i = table.find(activeAlerts, a)
    if i then table.remove(activeAlerts, i) end
    if instant then
        if a.wrap.Parent then a.wrap:Destroy() end
        return
    end
    tween(a.card, 0.25, { GroupTransparency = 1 })
    if a.ringStroke then tween(a.ringStroke, 0.25, { Transparency = 1 }) end
    tween(a.wrap, 0.3, { Size = UDim2.new(1, 0, 0, 0) })
    task.delay(0.35, function() if a.wrap.Parent then a.wrap:Destroy() end end)
end

alertNotify = function(entity, suffix)
    local color = entityColor(entity)
    local accent = isDark(color) and WHITE or color

    -- One alert at a time: replace the current alert immediately.
    while #activeAlerts >= 1 do dismissAlert(activeAlerts[1], true) end

    alertN += 1
    local wrap = create("Frame", {
        Size = UDim2.new(1, 0, 0, 84), BackgroundTransparency = 1,
        LayoutOrder = alertN, ZIndex = 30, Parent = AlertHolder,
    })
    local card = create("CanvasGroup", {
        Size = UDim2.new(1, 0, 0, 84), BackgroundColor3 = Theme.header, GroupTransparency = 1,
        ZIndex = 31, Parent = wrap,
    }, { corner(14) })
    -- border on its own frame (outside the CanvasGroup) so the corners stay clean
    local ring = create("Frame", {
        Size = UDim2.new(1, 0, 0, 84), BackgroundTransparency = 1, BorderSizePixel = 0,
        ZIndex = 33, Parent = wrap,
    }, { corner(14) })
    local ringStroke = create("UIStroke", {
        Color = WHITE, Thickness = 2, Transparency = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = ring,
    })
    create("UIGradient", {
        Color = ColorSequence.new(accent, isDark(color) and Theme.accent2 or color:Lerp(WHITE, 0.5)),
        Rotation = 35, Parent = ringStroke,
    })

    -- picture only: no frame, no background, no rounded corners
    local img = create("ImageLabel", {
        BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false,
        Size = UDim2.fromOffset(64, 64), Position = UDim2.fromOffset(10, 10),
        ScaleType = Enum.ScaleType.Fit, ZIndex = 32, Parent = card,
    })

    local nameLbl = label({
        Text = "<b>" .. richName(entity.Name, color) .. "</b>", RichText = true, TextSize = 16,
        Font = FONT_BOLD, TextTruncate = Enum.TextTruncate.AtEnd,
        Position = UDim2.fromOffset(12, 10), Size = UDim2.new(1, -24, 0, 20), Parent = card,
    })
    local descLbl = label({
        Text = "The entity" .. suffix, TextSize = 12, Font = FONT_MED, TextColor3 = Theme.text,
        TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top,
        Position = UDim2.fromOffset(12, 32), Size = UDim2.new(1, -24, 0, 44), Parent = card,
    })
    local track = create("Frame", {
        Position = UDim2.new(0, 10, 1, -6), Size = UDim2.new(1, -20, 0, 2),
        BackgroundColor3 = Theme.stroke, BackgroundTransparency = 0.4, BorderSizePixel = 0, Parent = card,
    }, { pill() })
    local bar = create("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = accent, BorderSizePixel = 0, Parent = track }, { pill() })

    local a = { wrap = wrap, card = card, ringStroke = ringStroke, dead = false }
    table.insert(activeAlerts, a)

    -- the picture may load a moment after the entity spawns: retry for a bit
    task.spawn(function()
        local t0 = os.clock()
        while not a.dead and os.clock() - t0 < 2 do
            local ok, src = pcall(findEntityImage, entity)
            if ok and src then
                img.Image = src.Image
                img.ImageRectOffset = src.Offset
                img.ImageRectSize = src.Size
                img.Visible = true
                nameLbl.Position = UDim2.fromOffset(86, 10)
                nameLbl.Size = UDim2.new(1, -96, 0, 20)
                descLbl.Position = UDim2.fromOffset(86, 32)
                descLbl.Size = UDim2.new(1, -96, 0, 44)
                return
            end
            task.wait(0.1)
        end
    end)
    tween(card, 0.25, { GroupTransparency = 0 })
    tween(ringStroke, 0.25, { Transparency = 0.1 })
    tween(bar, ALERT_SHOW, { Size = UDim2.fromScale(0, 1) }, Enum.EasingStyle.Linear)
    task.delay(ALERT_SHOW, function() dismissAlert(a) end)
end
end

local function watchG100(entity)
    local prevSpawn, prevTrans = false, false
    while entity.Parent and ScreenGui.Parent do
        local moving = entity:FindFirstChild("Moving")
        local spawnSound = moving and moving:FindFirstChild("Spawn")
        local transitionSound = moving and moving:FindFirstChild("Transition")
        local playingSpawn = spawnSound and spawnSound:IsA("Sound") and spawnSound.Playing or false
        local playingTransition = transitionSound and transitionSound:IsA("Sound") and transitionSound.Playing or false

        if AlertOn then
            if playingSpawn and not prevSpawn then
                alertNotify(entity, " spawned, hide on a grey or blue locker!")
            end
            if playingTransition and not prevTrans then
                alertNotify(entity, " will check gray lockers now, hide in a blue locker or table!")
            end
        end
        prevSpawn, prevTrans = playingSpawn, playingTransition
        task.wait(0.1)
    end
end

local function onEntitySpawned(entity)
    if isAlertIgnored(entity.Name) then return end
    TrackerEvents.spawned = entity.Name

    local key = normalizeName(entity.Name)
    if key == "g-100" then
        task.spawn(watchG100, entity)
        return
    end
    if not AlertOn then return end

    task.spawn(function()
        task.wait(0.15)
        if not entity.Parent then return end
        alertNotify(entity, ALERT_VARIANT[key] or " appeared. Hide!")
    end)
end

local function onEntityRemoved(entity)
    if not isAlertIgnored(entity.Name) then TrackerEvents.despawned = entity.Name end
    if Spec.active and Spec.entity == entity then specStep(1) end
end

do
    local known, firstPass = {}, true
    task.spawn(function()
        while ScreenGui.Parent do
            pcall(function()
                local current = {}
                for _, entity in ipairs(getEntities()) do
                    current[entity] = true
                    if not known[entity] then
                        known[entity] = true
                        if not firstPass then onEntitySpawned(entity) end
                    end
                end
                for entity in pairs(known) do
                    if not current[entity] then
                        known[entity] = nil
                        onEntityRemoved(entity)
                    end
                end
                firstPass = false
            end)
            task.wait(0.2)
        end
    end)
end

local function setAlert(value)
    AlertOn = value
end

local Speed = { value = nil, default = 16 }

local function applySpeed(text)
    local hum = getHum()
    local n = tonumber(text)
    if n and n >= 0 then
        if Speed.value == nil and hum then Speed.default = hum.WalkSpeed end
        Speed.value = math.clamp(n, 0, 1000)
        if hum then hum.WalkSpeed = Speed.value end
        notify("Speed set to <b>" .. Speed.value .. "</b>", Theme.on)
    else
        Speed.value = nil
        if hum then hum.WalkSpeed = Speed.default end
        notify("Speed reset to <b>" .. Speed.default .. "</b>", Theme.accent2)
    end
end

bind(RunService.Heartbeat, function()
    if Speed.value then
        local h = getHum()
        if h and h.WalkSpeed ~= Speed.value then h.WalkSpeed = Speed.value end
    end
end)

local setNoclip
do
local noclipConn
function setNoclip(v)
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    if v then
        noclipConn = bind(RunService.Stepped, function()
            local c = LocalPlayer.Character
            if not c then return end
            for _, part in ipairs(c:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
            end
        end)
    end
end
end

local setFullbright
do
local FB = { conn = nil, saved = {}, atm = {} }
local FB_PROPS = { "Brightness", "ClockTime", "FogEnd", "GlobalShadows", "Ambient", "OutdoorAmbient" }

local function fbApply()
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.FogEnd = 1e6
    Lighting.GlobalShadows = false
    Lighting.Ambient = Color3.new(1, 1, 1)
    Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    for _, a in ipairs(Lighting:GetChildren()) do
        if a:IsA("Atmosphere") then
            if not FB.atm[a] then FB.atm[a] = { Density = a.Density, Haze = a.Haze } end
            a.Density, a.Haze = 0, 0
        end
    end
end

function setFullbright(v)
    if FB.conn then FB.conn:Disconnect() FB.conn = nil end
    if v then
        for _, prop in ipairs(FB_PROPS) do FB.saved[prop] = Lighting[prop] end
        FB.conn = bind(RunService.RenderStepped, fbApply)
        fbApply()
    else
        for prop, val in pairs(FB.saved) do pcall(function() Lighting[prop] = val end) end
        for a, vals in pairs(FB.atm) do
            if a.Parent then a.Density, a.Haze = vals.Density, vals.Haze end
        end
        FB.saved, FB.atm = {}, {}
    end
end
end

local setAntiVoid
do
local AV = { conn = nil, floor = nil, floorY = nil, lastGround = nil }
local AV_FALL_DROP  = 60
local AV_RAY_LENGTH = 250
local AV_MARGIN     = 120
local AV_MIN_FALL   = -20

local function avRemoveFloor()
    if AV.floor then AV.floor:Destroy() end
    AV.floor, AV.floorY = nil, nil
end

function setAntiVoid(v)
    if AV.conn then AV.conn:Disconnect() AV.conn = nil end
    avRemoveFloor()
    if not v then return end
    AV.lastGround = nil

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude

    AV.conn = bind(RunService.Heartbeat, function()
        local char = LocalPlayer.Character
        local hrp, hum = getHRP(), getHum()
        if not hrp or not hum or hum.Health <= 0 then
            avRemoveFloor()
            return
        end
        local pos = hrp.Position

        if AV.floor then
            AV.floor.Position = Vector3.new(pos.X, AV.floorY - 3, pos.Z)
            if pos.Y > AV.floorY + 25 then avRemoveFloor() end
            return
        end

        if hum.FloorMaterial ~= Enum.Material.Air then
            AV.lastGround = pos.Y
            return
        end

        local vel = hrp.AssemblyLinearVelocity
        if vel.Y > AV_MIN_FALL then return end

        local reason
        if AV.lastGround and pos.Y < AV.lastGround - AV_FALL_DROP then
            reason = "long fall"
        else
            local destroyY = Workspace.FallenPartsDestroyHeight
            if destroyY ~= destroyY or destroyY < -1e5 then destroyY = -500 end
            if pos.Y < destroyY + AV_MARGIN then
                reason = "near kill height"
            else
                rayParams.FilterDescendantsInstances = { char }
                local hit = Workspace:Raycast(pos, Vector3.new(0, -AV_RAY_LENGTH, 0), rayParams)
                if not hit then reason = "no ground below" end
            end
        end
        if not reason then return end

        local off = (hum.RigType == Enum.HumanoidRigType.R6) and 3 or (hrp.Size.Y / 2 + hum.HipHeight)
        local feet = pos.Y - off
        AV.floorY = feet
        local floor = create("Part", {
            Name = "WTRALD_AntiVoid", Anchored = true, CanCollide = true, CastShadow = false,
            Transparency = 1, Size = Vector3.new(80, 6, 80),
            Position = Vector3.new(pos.X, feet - 3, pos.Z),
        })
        pcall(function() floor.CollisionGroup = hrp.CollisionGroup end)
        floor.Parent = Workspace
        AV.floor = floor

        hrp.AssemblyLinearVelocity = Vector3.new(vel.X, 0, vel.Z)
        hrp.CFrame = hrp.CFrame + Vector3.new(0, 1.5, 0)
        notify("<b>Anti-Void</b>: floor created (" .. reason .. ").", Theme.warn, 2.5)
    end)
end
end

local showShakerDialog

do
local ShakerState = { conn = nil }

local function isShaker(o)
    return o:IsA("LuaSourceContainer") and string.lower(o.Name) == "shaker"
end

local function killShaker(o)
    pcall(function() if o:IsA("BaseScript") then o.Disabled = true end end)
    pcall(function() o:Destroy() end)
end

local function deleteAllShakers()
    local n = 0
    local function sweep(list)
        for _, o in ipairs(list) do
            if isShaker(o) then
                killShaker(o)
                n += 1
            end
        end
    end
    local ok, all = pcall(function() return game:GetDescendants() end)
    if ok then sweep(all) end
    if getnilinstances then
        local ok2, nils = pcall(getnilinstances)
        if ok2 and nils then sweep(nils) end
    end
    return n
end

local function activateShakerDelete()
    local n = deleteAllShakers()
    if not ShakerState.conn then
        ShakerState.conn = bind(game.DescendantAdded, function(o)
            task.defer(function()
                if isShaker(o) then killShaker(o) end
            end)
        end)
    end
    notify(string.format("<b>Shaker</b> deleted (%d found). New ones are deleted too.", n), Theme.on, 4)
end

function showShakerDialog()
    Dialog.show({
        title = "Delete Shaker",
        body = 'This deletes every "Shaker" script, so there will be <b>no more screen shake</b>. It <b>cannot be undone</b>.',
        bar = Theme.danger, confirmText = "Delete", confirmBg = Theme.danger, confirmFg = Color3.new(1, 1, 1),
        onConfirm = activateShakerDelete,
    })
end

end

local function getSections()
    local out = {}
    for _, id in ipairs(SECTION_IDS) do
        local f = Workspace:FindFirstChild("CurrentRooms" .. id)
        if f then table.insert(out, { id = id, folder = f }) end
    end
    return out
end

local function getNumberedRooms(folder)
    local out = {}
    for _, c in ipairs(folder:GetChildren()) do
        local n = tonumber(c.Name)
        if n then table.insert(out, { num = n, inst = c }) end
    end
    table.sort(out, function(a, b) return a.num < b.num end)
    return out
end

local function findDoor(room)
    for _, c in ipairs(room:GetChildren()) do
        if string.lower(c.Name) == "door" then return c end
    end
    return nil
end

local promptCache = setmetatable({}, { __mode = "k" })
local function getDoorPrompts(room)
    local now = os.clock()
    local c = promptCache[room]
    if c then
        local alive = #c.list > 0
        for _, p in ipairs(c.list) do
            if not p.Parent then alive = false break end
        end
        if alive then return c.list end
    end
    local list = {}
    local door = findDoor(room)
    if door then
        if door:IsA("ProximityPrompt") then table.insert(list, door) end
        for _, d in ipairs(door:GetDescendants()) do
            if d:IsA("ProximityPrompt") then table.insert(list, d) end
        end
    end
    promptCache[room] = { list = list, t = now }
    return list
end

local Auto = { doors = false }
local Stats = { sections = 0, rooms = 0, fired = 0 }

do
local lastFire = setmetatable({}, { __mode = "k" })

local function triggerPrompt(prompt)
    local oldDist = prompt.MaxActivationDistance
    pcall(function()
        prompt.HoldDuration = 0
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = math.max(oldDist, 1000)
    end)
    local ok = false
    if fireproximityprompt then
        ok = pcall(fireproximityprompt, prompt)
    end
    if not ok then
        task.spawn(function()
            pcall(function()
                prompt:InputHoldBegin()
                task.wait(0.05)
                prompt:InputHoldEnd()
            end)
        end)
    end
    task.delay(0.4, function()
        pcall(function() prompt.MaxActivationDistance = oldDist end)
    end)
end

local function firePrompt(prompt)
    local now = os.clock()
    local last = lastFire[prompt]
    if not last or (prompt.Enabled and now - last >= RETRY_AFTER) then
        lastFire[prompt] = now
        triggerPrompt(prompt)
        return true
    end
    return false
end

task.spawn(function()
    while ScreenGui.Parent do
        pcall(function()
            local sections = getSections()
            local rooms = 0
            for _, s in ipairs(sections) do
                local list = getNumberedRooms(s.folder)
                rooms += #list
                if Auto.doors and not IS_BLOCKED then
                    for _, r in ipairs(list) do
                        for _, p in ipairs(getDoorPrompts(r.inst)) do
                            if p.Parent and firePrompt(p) then Stats.fired += 1 end
                        end
                    end
                end
            end
            Stats.sections, Stats.rooms = #sections, rooms
        end)
        task.wait(0.25)
    end
end)
end

local function doorFrame(door)
    if door:IsA("BasePart") then return door.CFrame, door.Size end
    if door:IsA("Model") then return door:GetBoundingBox() end
    local part = door:FindFirstChildWhichIsA("BasePart", true)
    if part then return part.CFrame, part.Size end
    return nil
end

local function getPendingRoom()
    local best, fallback
    for _, s in ipairs(getSections()) do
        for _, r in ipairs(getNumberedRooms(s.folder)) do
            local door = findDoor(r.inst)
            if door then
                if not fallback or r.num > fallback.num then
                    fallback = { room = r.inst, num = r.num, id = s.id, door = door }
                end
                local pending = false
                for _, p in ipairs(getDoorPrompts(r.inst)) do
                    if p.Parent and p.Enabled then pending = true break end
                end
                if pending and (not best or r.num > best.num) then
                    best = { room = r.inst, num = r.num, id = s.id, door = door }
                end
            end
        end
    end
    if best then return best, true end
    return fallback, false
end

local function getFirstRoom()
    local first
    for _, s in ipairs(getSections()) do
        for _, r in ipairs(getNumberedRooms(s.folder)) do
            local door = findDoor(r.inst)
            if door and (not first or r.num < first.num) then
                first = { num = r.num, door = door }
            end
        end
    end
    return first
end

local function isSpotFree(pos, char)
    local params = OverlapParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { char }
    for _, part in ipairs(Workspace:GetPartBoundsInBox(CFrame.new(pos), Vector3.new(3, 4.5, 3), params)) do
        if part.CanCollide then return false end
    end
    return true
end

local function teleportToLastRoom()
    local hrp = getHRP()
    if not hrp then
        notify("Character not loaded or currently dead.", Theme.warn)
        return
    end
    local t, pending = getPendingRoom()
    if not t then
        notify("No doors found in <b>Workspace.CurrentRooms*</b>.", Theme.warn)
        return
    end
    local cf, size = doorFrame(t.door)
    if not cf then
        notify("Door of room <b>" .. t.num .. "</b> has no usable position.", Theme.warn)
        return
    end

    local axes = { cf.RightVector, cf.UpVector, cf.LookVector }
    local dims = { size.X, size.Y, size.Z }
    local thin = 1
    for i = 2, 3 do
        if dims[i] < dims[thin] then thin = i end
    end

    local target
    if thin == 2 then
        target = cf.Position + Vector3.new(0, 4, 0)
    else
        local n = Vector3.new(axes[thin].X, 0, axes[thin].Z)
        n = n.Magnitude > 0.01 and n.Unit or Vector3.new(0, 0, 1)
        local y = cf.Position.Y - size.Y / 2 + 3.2
        local base = Vector3.new(cf.Position.X, y, cf.Position.Z)
        local options = { base + n * 4.5, base - n * 4.5 }
        table.sort(options, function(a, b)
            return (a - hrp.Position).Magnitude < (b - hrp.Position).Magnitude
        end)
        target = options[1]
        for _, o in ipairs(options) do
            if isSpotFree(o, LocalPlayer.Character) then target = o break end
        end
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = CFrame.lookAt(target, Vector3.new(cf.Position.X, target.Y, cf.Position.Z))
        notify(string.format(pending and "At the door of room <b>%d</b> (section <b>%s</b>)."
            or "All doors already open - at the last door, room <b>%d</b> (section <b>%s</b>).", t.num, t.id),
            pending and Theme.on or Theme.warn)
        return
    end

    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    hrp.CFrame = CFrame.new(target)
    notify(string.format("At the door of room <b>%d</b> (section <b>%s</b>).", t.num, t.id), Theme.on)
end

local ITEM_POS = {
    medicine   = Vector3.new(-47.579, 3.500, -51.043),
    blacklight = Vector3.new(-39.167, 3.500, 26.813),
    powerful   = Vector3.new(-182.429, 3.500, -27.810),
    delux      = Vector3.new(-248.202, 3.500, -33.477),
}

local function teleportToPos(pos, name)
    local hrp = getHRP()
    if not hrp then
        notify("Character not loaded or currently dead.", Theme.warn)
        return
    end
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    local cur = hrp.CFrame
    hrp.CFrame = CFrame.new(pos) * (cur - cur.Position)
    notify("Teleported to <b>" .. name .. "</b>.", Theme.on, 2.5)
end

local function colored(text, color, outline, bold)
    local t = string.format('<font color="#%s">%s</font>', color:ToHex(), text)
    if bold then t = "<b>" .. t .. "</b>" end
    if outline then t = '<stroke color="#FFFFFF" thickness="1" transparency="0.35">' .. t .. "</stroke>" end
    return t
end

local IC = {
    white      = Color3.fromRGB(255, 255, 255),
    blacklight = Color3.fromRGB(98, 37, 209),
    powerful   = Color3.fromRGB(255, 0, 0),
    delux      = Color3.fromRGB(0, 0, 255),
    sectionB   = Color3.fromRGB(86, 66, 54),
    sectionG   = Color3.fromRGB(255, 0, 0),
}

local function itemWarning(titleRich, sectionName, sectionColor, outline, bar, pos, itemName)
    Dialog.show({
        title = titleRich,
        body = colored("You must reach ", IC.white) .. colored(sectionName, sectionColor, outline, true)
            .. colored(" to get this flashlight", IC.white),
        bar = bar, confirmText = "Teleport", confirmBg = Theme.accent, confirmFg = WHITE,
        cancelText = "Cancel",
        onConfirm = function() teleportToPos(pos, itemName) end,
    })
end

local AutoHide, isThreatEntity

do
AutoHide = {
    on = false, side = -1, origin = nil, moved = false,
    handled = setmetatable({}, { __mode = "k" }),
    track   = setmetatable({}, { __mode = "k" }),
    sizes   = setmetatable({}, { __mode = "k" }),
    list = {}, listT = 0,
    clearSince = nil, hold = nil,
    CLEAR_RADIUS = 1000,
    CLEAR_TIME = 8,
    PROMPT_TIME = 30,
    asked = false, prompt = nil,
    REACT_TIME = 0.9,
    SPEED_CAP = 4000,
    FAST_SPEED = 150,
    HOLD_TIME = 0.6,
}

local STRONG_AIM_ENTITIES = { ["b-85"] = true, ["a-75"] = true }
local LIGHT_AIM_ENTITIES = {
    ["b-200"] = true, ["a-200"] = true, ["g-26"] = true,
    ["jack-o-26"] = true, ["cg-26"] = true,
}
local G159_NAME, G159_OFFSET = "g-159", 350

function isThreatEntity(entity)
    return not isAlertIgnored(entity.Name) and not isEspIgnored(entity.Name)
end

local function getAutoHideProfile(entity)
    local low = string.lower(entity.Name)
    if low == G159_NAME then
        return G159_OFFSET, math.huge, "G-159 appeared, throwing you away from him.", true
    elseif low == "a-332" then
        return 6000, 450, "A-332 has a very powerful aimscript, throwing you 6,000 meters...", false
    elseif STRONG_AIM_ENTITIES[low] then
        return 5000, 250, string.format("%s has a strong aimscript, we put you at 5000 meters.", entity.Name), false
    elseif LIGHT_AIM_ENTITIES[low] then
        return 1000, 250, string.format("%s has a light aimscript, stay within 1000 meters.", entity.Name), false
    end
    return 300, 140, string.format("%s does not have an aimscript, stay around up to 140 meters, as some entity can kill you in its hitbox.", entity.Name), false
end

function AutoHide.isLongRange(entity)
    local low = string.lower(entity.Name)
    return low == "a-332" or STRONG_AIM_ENTITIES[low] == true or LIGHT_AIM_ENTITIES[low] == true
end

function AutoHide.hideOffsetFor(entity, speed)
    local offset, trigger, message, always = getAutoHideProfile(entity)
    if not always and speed >= AutoHide.FAST_SPEED and AutoHide.isLongRange(entity) then
        local needed = math.min(8000, speed * 1.5 + 200)
        if needed > offset then
            offset = math.floor(needed)
            message = string.format("%s is massively fast (~%d studs/s), throwing you %d meters away.",
                entity.Name, math.floor(speed), offset)
        end
    end
    return offset, trigger, message, always
end

function AutoHide.sampleEntity(entity, now)
    local ok, pos = pcall(entityPos, entity)
    if not ok or typeof(pos) ~= "Vector3" then return end
    local t = AutoHide.track[entity]
    if not t then
        AutoHide.track[entity] = { pos = pos, t = now, speed = 0, prev = 0 }
        return
    end
    local dt = now - t.t
    if dt <= 0.001 then return end
    local inst = (dt > 0.5) and 0 or math.min((pos - t.pos).Magnitude / dt, AutoHide.SPEED_CAP)
    local eff = math.min(inst, t.prev)
    t.prev = inst
    t.speed = (eff > t.speed) and eff or (t.speed * 0.92 + eff * 0.08)
    t.pos, t.t = pos, now
end

function AutoHide.entityRadius(entity, now)
    local c = AutoHide.sizes[entity]
    if not c or now - c.t > 1 then
        local r = 0
        pcall(function()
            if entity:IsA("Model") then r = entity:GetExtentsSize().Magnitude / 2
            elseif entity:IsA("BasePart") then r = entity.Size.Magnitude / 2 end
        end)
        c = { r = math.min(r, 400), t = now }
        AutoHide.sizes[entity] = c
    end
    return c.r
end

function AutoHide.refreshHideEntities(now)
    if now - AutoHide.listT >= 0.1 then
        AutoHide.list, AutoHide.listT = getAllEntities(), now
    end
    for _, e in ipairs(AutoHide.list) do
        if e.Parent then AutoHide.sampleEntity(e, now) end
    end
end

local function findThreatNear(position, radius, enforceProfileRadius, now)
    local bestEntity, bestDist, bestOffset
    for _, entity in ipairs(AutoHide.list) do
        pcall(function()
            if entity.Parent and isThreatEntity(entity) then
                local ok, pos = pcall(entityPos, entity)
                if not ok or typeof(pos) ~= "Vector3" then
                    local rootOk, root = pcall(getRoot, entity)
                    pos = (rootOk and root) and root.Position or nil
                end
                if pos then
                    local long = AutoHide.isLongRange(entity)
                    local tr = AutoHide.track[entity]
                    local speed = (long and tr) and tr.speed or 0
                    local dist = (pos - position).Magnitude
                    if long then dist = math.max(0, dist - AutoHide.entityRadius(entity, now)) end
                    local offset, trigger, _, always = AutoHide.hideOffsetFor(entity, speed)
                    local eligible
                    if always then
                        eligible = (not enforceProfileRadius) or not AutoHide.handled[entity]
                    elseif enforceProfileRadius then
                        eligible = dist <= trigger + speed * AutoHide.REACT_TIME
                    else
                        eligible = dist <= radius
                    end
                    if eligible and (not bestEntity or offset > bestOffset or (offset == bestOffset and dist < bestDist)) then
                        bestEntity, bestDist, bestOffset = entity, dist, offset
                    end
                end
            end
        end)
    end
    return bestEntity, bestDist
end

function AutoHide.anyThreatWithin(position, radius)
    for _, entity in ipairs(AutoHide.list) do
        if entity.Parent and isThreatEntity(entity) then
            local ok, pos = pcall(entityPos, entity)
            if ok and typeof(pos) == "Vector3" and (pos - position).Magnitude <= radius then
                return true
            end
        end
    end
    return false
end

function AutoHide.closePrompt()
    local p = AutoHide.prompt
    if not p then return end
    AutoHide.prompt = nil
    tween(p.card, 0.25, { GroupTransparency = 1, Position = UDim2.new(0.5, 0, 0, 186) })
    task.delay(0.3, function() if p.card.Parent then p.card:Destroy() end end)
end

function AutoHide.showPrompt(onYes, onNo)
    if AutoHide.prompt then return end
    local w = math.clamp(vp.X - 40, 240, 330)
    local card = create("CanvasGroup", {
        Name = "TeleportPrompt", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 206),
        Size = UDim2.fromOffset(w, 128), BackgroundColor3 = Theme.card, GroupTransparency = 1,
        ZIndex = 20, Parent = ScreenGui,
    }, { corner(12), stroke(Theme.stroke, 1, 0) })
    label({
        Text = "No entity was found within 1000 meters, do you want to teleport to current room?",
        TextSize = 12, Font = FONT_MED, TextWrapped = true, TextTruncate = Enum.TextTruncate.None,
        TextYAlignment = Enum.TextYAlignment.Top,
        Position = UDim2.fromOffset(14, 10), Size = UDim2.new(1, -28, 0, 40), Parent = card,
    })
    local function btn(text, bg, fg, right)
        return create("TextButton", {
            Text = text, TextSize = 14, Font = FONT_BOLD, TextColor3 = fg, AutoButtonColor = false,
            AnchorPoint = Vector2.new(right and 1 or 0, 0),
            Position = UDim2.new(right and 1 or 0, right and -14 or 14, 0, 66),
            Size = UDim2.new(0.5, -21, 0, 34), BackgroundColor3 = bg, BorderSizePixel = 0, Parent = card,
        }, { corner(9) })
    end
    local yes = btn("Yes", Theme.accent, WHITE, false)
    local nah = btn("Nah", Theme.cardHi, Theme.text, true)
    tapFx(yes, Theme.accent, Color3.fromRGB(110, 70, 210))
    tapFx(nah, Theme.cardHi, Theme.stroke)
    local track = create("Frame", {
        Position = UDim2.new(0, 14, 1, -10), Size = UDim2.new(1, -28, 0, 2), BackgroundColor3 = Theme.stroke,
        BackgroundTransparency = 0.4, BorderSizePixel = 0, Parent = card,
    }, { pill() })
    local bar = create("Frame", {
        Size = UDim2.fromScale(1, 1), BackgroundColor3 = Theme.accent, BorderSizePixel = 0, Parent = track,
    }, { pill() })

    local p = { card = card }
    AutoHide.prompt = p
    tween(card, 0.4, { GroupTransparency = 0, Position = UDim2.new(0.5, 0, 0, 196) }, Enum.EasingStyle.Back)
    tween(bar, AutoHide.PROMPT_TIME, { Size = UDim2.fromScale(0, 1) }, Enum.EasingStyle.Linear)

    yes.Activated:Connect(function()
        if AutoHide.prompt ~= p then return end
        AutoHide.closePrompt()
        task.spawn(onYes)
    end)
    nah.Activated:Connect(function()
        if AutoHide.prompt == p then
            AutoHide.closePrompt()
            if onNo then onNo() end
        end
    end)
    task.delay(AutoHide.PROMPT_TIME, function()
        if AutoHide.prompt == p then
            AutoHide.closePrompt()
            if onNo then onNo() end
        end
    end)
end

function AutoHide.autoHideStep()
    if not AutoHide.on or IS_BLOCKED then
        AutoHide.clearSince, AutoHide.asked = nil, false
        AutoHide.closePrompt()
        return
    end
    local hrp = getHRP()
    if not hrp then return end
    local now = os.clock()
    AutoHide.refreshHideEntities(now)

    local hold = AutoHide.hold
    if hold then
        if now >= hold.untilT then
            AutoHide.hold = nil
        elseif (hrp.Position - hold.cf.Position).Magnitude > 20 then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            hrp.CFrame = hold.cf
        end
    end

    local threat = findThreatNear(hrp.Position, 0, true, now)
    if threat then
        AutoHide.clearSince, AutoHide.asked = nil, false
        AutoHide.closePrompt()
        local tr = AutoHide.track[threat]
        local offset, _, message, always = AutoHide.hideOffsetFor(threat, tr and tr.speed or 0)
        if not AutoHide.moved or not AutoHide.origin then
            AutoHide.origin = hrp.CFrame
        end

        local dir = AutoHide.side
        if always then
            AutoHide.handled[threat] = true
            local okPos, epos = pcall(entityPos, threat)
            if okPos and typeof(epos) == "Vector3" then
                local dx = hrp.Position.X - epos.X
                if math.abs(dx) > 1 then dir = dx > 0 and 1 or -1 end
            end
        end

        local cur = hrp.CFrame
        local newCF = CFrame.new(hrp.Position + Vector3.new(dir * offset, 0, 0)) * (cur - cur.Position)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = newCF
        AutoHide.hold = AutoHide.isLongRange(threat) and { cf = newCF, untilT = now + AutoHide.HOLD_TIME } or nil
        AutoHide.moved = true
        notify(esc(message), Theme.warn, 4)
        return
    end

    local near = AutoHide.anyThreatWithin(hrp.Position, AutoHide.CLEAR_RADIUS)
    if not near and AutoHide.moved and AutoHide.origin then
        near = AutoHide.anyThreatWithin(AutoHide.origin.Position, AutoHide.CLEAR_RADIUS)
    end
    if near then
        AutoHide.clearSince, AutoHide.asked = nil, false
        AutoHide.closePrompt()
    else
        AutoHide.clearSince = AutoHide.clearSince or now
        if not AutoHide.asked and not AutoHide.prompt and now - AutoHide.clearSince >= AutoHide.CLEAR_TIME then
            AutoHide.asked = true
            AutoHide.showPrompt(function()
                AutoHide.origin, AutoHide.moved, AutoHide.hold = nil, false, nil
                task.spawn(teleportToLastRoom)
            end, function()
                AutoHide.origin, AutoHide.moved, AutoHide.hold = nil, false, nil
            end)
        end
    end
end

bind(RunService.Heartbeat, function()
    local ok, err = pcall(AutoHide.autoHideStep)
    if not ok then warn("[WTRALD AutoHide] " .. tostring(err)) end
end)
end

local MODES = { "BRAZIL", "burbur", "fish", "hard", "insane", "lobotomy", "thecantloupe" }

local function getGamemodes()
    local a = Workspace:FindFirstChild("CurrentRoomsA")
    local r1 = a and a:FindFirstChild("1")
    local cp = r1 and r1:FindFirstChild("NewestCheckpoint")
    return cp and cp:FindFirstChild("gamemodes")
end

local function findMode(name)
    local gm = getGamemodes()
    if not gm then return nil end
    local exact = gm:FindFirstChild(name)
    if exact then return exact end
    local low = string.lower(name)
    for _, c in ipairs(gm:GetChildren()) do
        if string.lower(c.Name) == low then return c end
    end
    return nil
end

local confirmMode

do
local function modeText(inst)
    local t = inst:FindFirstChild("txt", true)
    if not t then return nil end
    local ok, s = pcall(function()
        if t:IsA("TextLabel") or t:IsA("TextBox") or t:IsA("TextButton") then return t.Text end
        local x = t:FindFirstChildWhichIsA("TextLabel", true) or t:FindFirstChildWhichIsA("TextBox", true)
        return x and x.Text or nil
    end)
    if ok and type(s) == "string" and s ~= "" then return s end
    return nil
end

local function modePivot(inst)
    if inst:IsA("Model") then return inst:GetPivot().Position end
    if inst:IsA("BasePart") then return inst.Position end
    local p = inst:FindFirstChildWhichIsA("BasePart", true)
    return p and p.Position or nil
end

local function activateMode(name)
    if IS_BLOCKED then
        notify("<b>Modes</b> are blocked for your account.", Theme.danger, 3)
        return
    end
    local inst = findMode(name)
    if not inst then
        notify("Mode <b>" .. esc(name) .. "</b> not found (is the checkpoint loaded?).", Theme.warn)
        return
    end
    local hrp = getHRP()
    local fired = 0
    local all = inst:GetDescendants()
    table.insert(all, 1, inst)
    for _, d in ipairs(all) do
        if d:IsA("ProximityPrompt") and fireproximityprompt then
            pcall(function()
                d.HoldDuration = 0
                d.RequiresLineOfSight = false
                fireproximityprompt(d)
            end)
            fired += 1
        elseif d:IsA("ClickDetector") and fireclickdetector then
            if pcall(fireclickdetector, d) then fired += 1 end
        elseif d:IsA("BasePart") and hrp and firetouchinterest and d:FindFirstChildOfClass("TouchInterest") then
            pcall(function()
                firetouchinterest(hrp, d, 0)
                firetouchinterest(hrp, d, 1)
            end)
            fired += 1
        end
    end
    if fired > 0 then
        notify("Mode <b>" .. esc(name) .. "</b> activated (" .. fired .. " trigger" .. (fired > 1 and "s" or "") .. ").", Theme.on)
        return
    end
    local pos = modePivot(inst)
    if hrp and pos then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.CFrame = CFrame.new(pos + Vector3.new(0, 4, 0))
        notify("No trigger found in <b>" .. esc(name) .. "</b> — teleported next to it.", Theme.warn)
    else
        notify("Nothing to trigger in <b>" .. esc(name) .. "</b>.", Theme.warn)
    end
end

function confirmMode(name)
    if IS_BLOCKED then
        notify("<b>Modes</b> are blocked for your account.", Theme.danger, 3)
        return
    end
    local inst = findMode(name)
    local txt = inst and modeText(inst)
    Dialog.show({
        title = "Activate <b>" .. esc(name) .. "</b>",
        body = "Fires the mode's prompt / click / touch (or teleports next to it if there is none)."
            .. (txt and ('\nSign says: <b>' .. esc(txt) .. '</b>') or ""),
        bar = Theme.accent, confirmText = "Activate", confirmBg = Theme.accent, confirmFg = WHITE,
        onConfirm = function() activateMode(name) end,
    })
end

end

local Kill = { on = false, saved = setmetatable({}, { __mode = "k" }), count = 0 }

local setKillOff

do
local function findKillParts()
    local out = {}
    for _, f in ipairs(Workspace:GetChildren()) do
        if string.sub(f.Name, 1, 12) == "CurrentRooms" then
            for _, room in ipairs(f:GetChildren()) do
                local k = room:FindFirstChild("the part that kills")
                if k then table.insert(out, k) end
            end
        end
    end
    return out
end

local function applyKill(inst)
    local parts = {}
    if inst:IsA("BasePart") then table.insert(parts, inst) end
    for _, d in ipairs(inst:GetDescendants()) do
        if d:IsA("BasePart") then table.insert(parts, d) end
    end
    for _, p in ipairs(parts) do
        if Kill.saved[p] == nil then Kill.saved[p] = p.CanTouch end
        pcall(function() p.CanTouch = false end)
        local ti = p:FindFirstChildOfClass("TouchInterest")
        if ti then pcall(function() ti:Destroy() end) end
    end
end

function setKillOff(v)
    Kill.on = v
    if not v then
        for p, orig in pairs(Kill.saved) do
            pcall(function() p.CanTouch = orig end)
        end
        Kill.saved = setmetatable({}, { __mode = "k" })
    end
end

task.spawn(function()
    while ScreenGui.Parent do
        pcall(function()
            local list = findKillParts()
            Kill.count = #list
            if Kill.on then
                for _, k in ipairs(list) do applyKill(k) end
            end
        end)
        task.wait(0.25)
    end
end)

end

local setJumpBlock

do
local Jump = { on = false, saved = setmetatable({}, { __mode = "k" }), conn = nil }

local function jumpGui()
    local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    return pg and pg:FindFirstChild("Jumpscares")
end

local function jumpApply()
    local g = jumpGui()
    if not g then return end
    if g:IsA("ScreenGui") then
        if Jump.saved[g] == nil then Jump.saved[g] = g.Enabled end
        g.Enabled = false
    end
    for _, d in ipairs(g:GetDescendants()) do
        if d:IsA("GuiObject") then
            if Jump.saved[d] == nil then Jump.saved[d] = d.Visible end
            if d.Visible then d.Visible = false end
        elseif d:IsA("Sound") then
            if Jump.saved[d] == nil then Jump.saved[d] = d.Volume end
            d.Volume = 0
            if d.Playing then pcall(function() d:Stop() end) end
        end
    end
end

function setJumpBlock(v)
    Jump.on = v
    if Jump.conn then Jump.conn:Disconnect() Jump.conn = nil end
    if v then
        local acc = 0
        Jump.conn = bind(RunService.RenderStepped, function(dt)
            acc += dt
            if acc < 0.05 then return end
            acc = 0
            pcall(jumpApply)
        end)
        pcall(jumpApply)
    else
        for obj, orig in pairs(Jump.saved) do
            pcall(function()
                if obj:IsA("ScreenGui") then obj.Enabled = orig
                elseif obj:IsA("GuiObject") then obj.Visible = orig
                elseif obj:IsA("Sound") then obj.Volume = orig end
            end)
        end
        Jump.saved = setmetatable({}, { __mode = "k" })
    end
end

end

-- Auto Pick Freddies Plush
local Plush = { on = false, found = 0 }
do
local last = setmetatable({}, { __mode = "k" })

local function plushMatch(cd)
    local inst, depth = cd, 0
    while inst and inst ~= Workspace and depth < 6 do
        local low = string.lower(inst.Name)
        if low == "boundingbox" or string.find(low, "freddy", 1, true) then return true end
        inst, depth = inst.Parent, depth + 1
    end
    return false
end

task.spawn(function()
    while ScreenGui.Parent do
        if Plush.on and fireclickdetector then
            pcall(function()
                local found, n = 0, 0
                for _, d in ipairs(Workspace:GetDescendants()) do
                    n += 1
                    if n % 3000 == 0 then task.wait() end
                    if not Plush.on then break end
                    if d:IsA("ClickDetector") and plushMatch(d) then
                        found += 1
                        local t = last[d]
                        if not t or os.clock() - t > 2 then
                            last[d] = os.clock()
                            pcall(function() d.MaxActivationDistance = 1e6 end)
                            pcall(fireclickdetector, d)
                        end
                    end
                end
                Plush.found = found
            end)
        end
        task.wait(1)
    end
end)
end


-- Player ESP: "Display (@Name) | 626m | 100hp"
local setPlayerESP, teleportToRandomPlayer

do
local PlayerESP = { on = false, items = {} }

local function pespRemove(plr)
    local it = PlayerESP.items[plr]
    if it then
        it.gui:Destroy()
        PlayerESP.items[plr] = nil
    end
end

local function pespAdd(plr, head)
    local gui = create("BillboardGui", {
        Name = "PlayerESP", Adornee = head, AlwaysOnTop = true, Size = UDim2.fromOffset(300, 22),
        StudsOffset = Vector3.new(0, 3, 0), ResetOnSpawn = false, Parent = ESPFolder,
    })
    local lbl = label({
        Text = "", TextSize = 14, Font = FONT_BOLD, TextStrokeTransparency = 0.25,
        TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), Parent = gui,
    })
    PlayerESP.items[plr] = { gui = gui, label = lbl, head = head }
end

function setPlayerESP(v)
    PlayerESP.on = v
    if not v then
        for plr in pairs(PlayerESP.items) do pespRemove(plr) end
    end
end

task.spawn(function()
    while ScreenGui.Parent do
        if PlayerESP.on then
            pcall(function()
                local myRoot = getHRP()
                local seen = {}
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer then
                        local char = plr.Character
                        local head = char and char:FindFirstChild("Head")
                        local hum = char and char:FindFirstChildOfClass("Humanoid")
                        if head and hum then
                            seen[plr] = true
                            local it = PlayerESP.items[plr]
                            if it and it.head ~= head then
                                pespRemove(plr)
                                it = nil
                            end
                            if not it then
                                pespAdd(plr, head)
                                it = PlayerESP.items[plr]
                            end
                            local root = char:FindFirstChild("HumanoidRootPart") or head
                            local dist = myRoot and math.floor((root.Position - myRoot.Position).Magnitude + 0.5) or 0
                            local hp = math.max(0, math.floor(hum.Health + 0.5))
                            local frac = hum.MaxHealth > 0 and math.clamp(hum.Health / hum.MaxHealth, 0, 1) or 1
                            it.label.Text = string.format("%s (@%s) | %dm | %dhp", plr.DisplayName, plr.Name, dist, hp)
                            it.label.TextColor3 = Color3.fromHSV(frac * 0.33, 0.55, 1)
                        end
                    end
                end
                for plr in pairs(PlayerESP.items) do
                    if not seen[plr] then pespRemove(plr) end
                end
            end)
        end
        task.wait(0.1)
    end
end)

function teleportToRandomPlayer()
    local hrp = getHRP()
    if not hrp then
        notify("Character not loaded or currently dead.", Theme.warn)
        return
    end
    local options = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            if root then table.insert(options, { plr = plr, root = root }) end
        end
    end
    if #options == 0 then
        notify("No other players with a character to teleport to.", Theme.warn)
        return
    end
    local pick = options[math.random(1, #options)]
    local pos = pick.root.Position - pick.root.CFrame.LookVector * 4 + Vector3.new(0, 1, 0)
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    local cur = hrp.CFrame
    hrp.CFrame = CFrame.new(pos) * (cur - cur.Position)
    notify(string.format("Teleported to <b>%s (@%s)</b>.", esc(pick.plr.DisplayName), esc(pick.plr.Name)), Theme.on, 2.5)
end
end
local P = pages.Doors
sectionLabel(P, "Doors")
Blk.doors = makeToggle(P, "Auto-Open Doors", "Opens doors in room order", function(v)
    if v and IS_BLOCKED then
        Blk.doors.Set(false, true)
        notify("<b>Auto-Open Doors</b> is blocked for your account.", Theme.danger, 3)
        return
    end
    Auto.doors = v
    if v then
        if not fireproximityprompt then
            notify("Executor without <b>fireproximityprompt</b> - using fallback.", Theme.warn, 5)
        end
        notify("Auto-Open Doors <b>enabled</b>.", Theme.on, 2.5)
    end
end)
makeButton(P, "Teleport to current room", "Move to the room currently being opened", teleportToLastRoom)
local setDoorStat = makeStat(P, "Status")

P = pages.ESP
sectionLabel(P, "Entities")
makeToggle(P, "ESP Entities", "Name, distance and light color", setESP)
makeButton(P, "Spectate Entities", "Camera follows the entity; others muted", specOpen)
local setEspStat = makeStat(P, "Tracking")

sectionLabel(P, "Alerts")
makeToggle(P, "Alert Entities", "Notify when an entity spawns", setAlert)

sectionLabel(P, "Auto Hide")
Blk.hide = makeToggle(P, "Auto-Hide from entity", "Sidesteps lethal entities, G-159 on spawn", function(v)
    if v and IS_BLOCKED then
        Blk.hide.Set(false, true)
        notify("<b>Auto-Hide</b> is blocked for your account.", Theme.danger, 3)
        return
    end
    AutoHide.on = v
    if not v then AutoHide.origin, AutoHide.moved, AutoHide.hold = nil, false, nil end
end)
makeButton(P, "Switch hide side", "Choose left or right (never forward/back)", function()
    AutoHide.side = -AutoHide.side
    notify("Auto hide side: <b>" .. (AutoHide.side < 0 and "Left" or "Right") .. "</b>.", Theme.accent)
end)

P = pages.Tracker
local TRACKER_RANGE = 1000
sectionLabel(P, "Threat radar")
local setTrackerStatus = makeStatus(P, "Detection status")
local setTrackerBar = makeEntityBar(P, "Entity map")
sectionLabel(P, "Activity")
local setTrackerSpawn, setTrackerDespawn = makeDualStat(P, "Last spawned", "Last despawned")

P = pages.Items
local function posText(v)
    return string.format("%.1f, %.1f, %.1f", v.X, v.Y, v.Z)
end
sectionLabel(P, "Teleports")
makeButton(P,
    colored("Teleport to Medicine", IC.white),
    posText(ITEM_POS.medicine),
    function() teleportToPos(ITEM_POS.medicine, "Medicine") end,
    false, true)
makeButton(P,
    colored("Teleport to ", IC.white) .. colored("Blacklight", IC.blacklight) .. colored(" Dispenser", IC.white),
    posText(ITEM_POS.blacklight),
    function()
        itemWarning(
            colored("Blacklight", IC.blacklight, false, true) .. colored(" Dispenser", IC.white, false, true),
            "Section B", IC.sectionB, true, IC.blacklight,
            ITEM_POS.blacklight, "Blacklight Dispenser")
    end,
    false, true)
makeButton(P,
    colored("Teleport to ", IC.white) .. colored("Powerful Flashlight", IC.powerful),
    posText(ITEM_POS.powerful),
    function()
        itemWarning(
            colored("Powerful Flashlight", IC.powerful, false, true),
            "Section G", IC.sectionG, false, IC.powerful,
            ITEM_POS.powerful, "Powerful Flashlight")
    end,
    false, true)
makeButton(P,
    colored("Teleport to ", IC.white) .. colored("Delux Flashlight", IC.delux, true),
    posText(ITEM_POS.delux),
    function() teleportToPos(ITEM_POS.delux, "Delux Flashlight") end,
    false, true)

sectionLabel(P, "Auto")
makeToggle(P, "Auto Pick Freddies Plush", "ClickDetectors: Freddy / BOUNDINGBOX", function(v)
    Plush.on = v
    if v and not fireclickdetector then
        notify("Executor without <b>fireclickdetector</b>.", Theme.warn, 4)
    elseif v then
        notify("Auto Pick Freddies Plush <b>enabled</b>.", Theme.on, 2.5)
    end
end)

P = pages.Player
sectionLabel(P, "Movement")
makeInput(P, "Change Speed", "Number (empty = reset)", applySpeed)
makeToggle(P, "Noclip", "Walk through walls", setNoclip)
makeToggle(P, "Anti-Void", "Invisible floor if you fall", setAntiVoid)

sectionLabel(P, "Players")
makeToggle(P, "Enable ESP Players", "Name (@user) | distance | health", setPlayerESP)
makeButton(P, "Teleport to Random Player", "Teleports next to a random player", teleportToRandomPlayer)

sectionLabel(P, "World")
makeToggle(P, "Fullbright", "Bright map, no fog", setFullbright)
makeButton(P, "Delete Shaker", "Deletes the screen shake scripts", showShakerDialog, true)

sectionLabel(P, "Hazards")
makeToggle(P, "Disable kill part", "\"the part that kills\" (client-side)", setKillOff)
local setKillStat = makeStat(P, "Kill parts found")
makeToggle(P, "Block Jumpscares", "Hides PlayerGui.Jumpscares + sounds", setJumpBlock)

P = pages.Modes
sectionLabel(P, "Checkpoint gamemodes")
local setModesStatus = makeStatus(P, "Gamemodes folder")
for _, m in ipairs(MODES) do
    makeButton(P, "Activate " .. m, "Checkpoint game mode", function() confirmMode(m) end)
end
makeParagraph(P, "Entities <b>1-A</b>, <b>1-B</b> and <b>1-G</b> are ignored by alerts, auto-hide, tracker and spectate.", 54)

-- Chat tab: Firebase Realtime Database (REST). Never touches the Roblox chat.
local Chat = {
    DB = "https://rld-chat-8b60b-default-rtdb.firebaseio.com/",
    HOST = "Web_Julio9",
    BAD_WORDS = { "porra", "caralho", "puta", "fdp", "merda", "fuck", "shit", "bitch" },
    running = false, msgs = {}, order = {}, dbIds = {}, seq = 0, users = {},
    activeUntil = 0, errShown = false, loaded = false,
    MAX_STRIKES = 20,      -- bad words OR rapid-fire messages before the kick
    SPAM_GAP = 1,          -- messages closer than this (seconds) count as spam
    KICK_MSG = "You have been kicked from this script, try not to swear again.",
    strikes = 0, spam = 0, lastAttempt = 0,
}
Chat.isHost = (LocalPlayer.Name == Chat.HOST)
Chat.http = (syn and syn.request) or http_request or request
    or (http and http.request) or (fluxus and fluxus.request)

do
local HttpService = game:GetService("HttpService")

P = pages.Chat
sectionLabel(P, "Chat")
local setChatUsers = makeStatus(P, "Chat status")

local chatRow = baseRow(P, 190)
local chatScroll = create("ScrollingFrame", {
    Position = UDim2.fromOffset(8, 8), Size = UDim2.new(1, -16, 1, -16), BackgroundTransparency = 1,
    BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = Theme.accent,
    CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = chatRow,
}, {
    create("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }),
    create("UIPadding", { PaddingRight = UDim.new(0, 6) }),
})

local inRow = baseRow(P, 52)
local chatBox = create("TextBox", {
    Text = "", PlaceholderText = "Message...", PlaceholderColor3 = Theme.sub, TextColor3 = Theme.text,
    TextSize = 13, Font = FONT_MED, ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left,
    Position = UDim2.fromOffset(12, 10), Size = UDim2.new(1, -86, 0, 32), BackgroundColor3 = Theme.cardHi,
    BorderSizePixel = 0, Parent = inRow,
}, { corner(8), create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }) })
local sendBtn = create("TextButton", {
    Text = "Send", TextSize = 13, Font = FONT_BOLD, TextColor3 = Theme.accentText,
    AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 10), Size = UDim2.fromOffset(56, 32),
    BackgroundColor3 = WHITE, AutoButtonColor = false, BorderSizePixel = 0, Parent = inRow,
}, { corner(8) })
accentGrad(45).Parent = sendBtn

-- one channel per server, so people only talk to those in the same server
do
    local jid = (game.JobId ~= "" and game.JobId) or tostring(game.PlaceId)
    Chat.base = Chat.DB .. "chat/" .. (string.gsub(jid, "[^%w]", ""))
end

local function scrollDown()
    task.defer(function()
        task.wait()
        chatScroll.CanvasPosition = Vector2.new(0, chatScroll.AbsoluteCanvasSize.Y)
    end)
end

function Chat.isBad(text)
    local low = string.lower(tostring(text or ""))
    for _, w in ipairs(Chat.BAD_WORDS) do
        if string.find(low, w, 1, true) then return true end
    end
    return false
end

-- speech bubble above a player's head, drawn by the script (script users see it)
Chat.bubbles = {}
function Chat.bubble(plr, text)
    local char = plr and plr.Character
    local head = char and char:FindFirstChild("Head")
    if not head then return end
    local old = Chat.bubbles[plr]
    if old then pcall(function() old:Destroy() end) end

    text = tostring(text)
    local ok, size = pcall(function()
        return TextService:GetTextSize(text, 14, FONT_MED, Vector2.new(200, 1000))
    end)
    local w = ok and math.clamp(size.X, 24, 200) or 160
    local h = ok and size.Y or 18

    local gui = create("BillboardGui", {
        Name = "ScriptBubble", Adornee = head, AlwaysOnTop = true,
        Size = UDim2.fromOffset(w + 22, h + 14), StudsOffset = Vector3.new(0, 4.4, 0),
        MaxDistance = 150, ResetOnSpawn = false, Parent = ESPFolder,
    })
    local frame = create("Frame", {
        Size = UDim2.fromScale(1, 1), BackgroundColor3 = WHITE, BackgroundTransparency = 0.08,
        BorderSizePixel = 0, Parent = gui,
    }, { corner(10) })
    local lbl = label({
        Text = text, TextSize = 14, Font = FONT_MED, TextColor3 = Color3.fromRGB(25, 25, 30),
        TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Center,
        Size = UDim2.new(1, -12, 1, -8), Position = UDim2.fromOffset(6, 4), Parent = frame,
    })
    Chat.bubbles[plr] = gui

    task.delay(math.clamp(3 + #text / 12, 4, 10), function()
        if Chat.bubbles[plr] == gui then Chat.bubbles[plr] = nil end
        if not gui.Parent then return end
        tween(frame, 0.3, { BackgroundTransparency = 1 })
        tween(lbl, 0.3, { TextTransparency = 1 })
        task.delay(0.35, function() if gui.Parent then gui:Destroy() end end)
    end)
end

-- Firebase REST helper: returns decoded JSON (or nil), HTTP status
function Chat.req(method, path, body, query)
    if not Chat.http then return nil, 0 end
    local ok, res = pcall(Chat.http, {
        Url = Chat.base .. path .. ".json" .. (query or ""),
        Method = method,
        Headers = { ["Content-Type"] = "application/json" },
        Body = body ~= nil and HttpService:JSONEncode(body) or nil,
    })
    if not ok or type(res) ~= "table" then return nil, 0 end
    local data
    if type(res.Body) == "string" and res.Body ~= "" then
        local ok2, d = pcall(function() return HttpService:JSONDecode(res.Body) end)
        if ok2 then data = d end
    end
    return data, tonumber(res.StatusCode) or 0
end

-- messages ------------------------------------------------------------
function Chat.removeMessage(id)
    local m = Chat.msgs[id]
    Chat.dbIds[id] = nil
    if not m then return end
    Chat.msgs[id] = nil
    local i = table.find(Chat.order, id)
    if i then table.remove(Chat.order, i) end
    if m.frame.Parent then m.frame:Destroy() end
end

function Chat.addRow(id, richText, deletable)
    Chat.seq += 1
    local frame = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
        LayoutOrder = Chat.seq, Parent = chatScroll,
    })
    label({
        Text = richText, RichText = true, TextSize = 12, TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Top,
        Size = UDim2.new(1, deletable and -28 or 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = frame,
    })
    if deletable then
        local del = create("TextButton", {
            Text = "", TextSize = 12, Font = FONT_BOLD, TextColor3 = Theme.danger,
            AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.fromOffset(22, 20),
            BackgroundColor3 = Theme.cardHi, AutoButtonColor = false, BorderSizePixel = 0, Parent = frame,
        }, { corner(6) })
        makeIcon("close", del, 10, Theme.danger)
        del.Activated:Connect(function()
            Chat.removeMessage(id)
            task.spawn(Chat.req, "DELETE", "/messages/" .. id)
        end)
    end
    table.insert(Chat.order, id)
    Chat.msgs[id] = { frame = frame }
    while #Chat.order > 150 do
        local old = table.remove(Chat.order, 1)
        local m = Chat.msgs[old]
        Chat.msgs[old] = nil
        Chat.dbIds[old] = nil
        if m and m.frame.Parent then m.frame:Destroy() end
    end
    scrollDown()
end

function Chat.upsert(id, rec)
    if Chat.msgs[id] or type(rec) ~= "table" then return end
    local text = tostring(rec.m or "")
    local uid = tonumber(rec.i)
    if text == "" or not uid then return end

    -- host removes bad words for everyone
    if Chat.isHost and Chat.isBad(text) then
        task.spawn(Chat.req, "DELETE", "/messages/" .. id)
        return
    end
    if Chat.isBad(text) then return end

    -- the name comes from the real player in the server, not from what the record claims
    local plr = Players:GetPlayerByUserId(uid)
    local name = plr and plr.Name or tostring(rec.u or "?")
    local display = plr and plr.DisplayName or tostring(rec.d or "")
    local who = (display ~= "" and display ~= name) and (display .. " (@" .. name .. ")") or name

    Chat.dbIds[id] = true
    local own = uid == LocalPlayer.UserId
    -- Owner only for the configured host account; everyone else is a member.
    local isOwner = plr ~= nil and plr.Name == Chat.HOST
    local tag = isOwner and '<font color="#FFD966"><b>👑 Owner</b></font>  ' or '<font color="#9EA3B8">👤 Member</font>  '
    Chat.addRow(id, tag .. "<b>" .. esc(who) .. "</b>: " .. esc(text), own or Chat.isHost)
    if Chat.loaded then
        notify("New message!", Theme.accent2, 2.5, nil, true)
        if plr then pcall(Chat.bubble, plr, text) end
    end
end

-- polling -------------------------------------------------------------
function Chat.fail(status)
    if status == 401 or status == 403 then
        setChatUsers("Firebase: access denied (check rules)", Theme.danger)
    else
        setChatUsers("Connection problem (" .. tostring(status) .. ")", Theme.warn)
    end
end

function Chat.poll()
    local data, status = Chat.req("GET", "/messages", nil, '?orderBy=%22%24key%22&limitToLast=40')
    if status ~= 200 then Chat.fail(status) return false end
    local keys, set = {}, {}
    if type(data) == "table" then
        for k in pairs(data) do table.insert(keys, k) end
        table.sort(keys)
    end
    for _, k in ipairs(keys) do
        set[k] = true
        local before = Chat.msgs[k] == nil
        Chat.upsert(k, data[k])
        if before and Chat.msgs[k] then Chat.activeUntil = os.clock() + 30 end
    end
    -- messages deleted on the database disappear here too
    local minKey = keys[1]
    for id in pairs(Chat.dbIds) do
        if not set[id] and (not minKey or id >= minKey) then Chat.removeMessage(id) end
    end
    Chat.loaded = true
    return true
end

function Chat.presence()
    Chat.req("PUT", "/users/" .. LocalPlayer.UserId, { n = LocalPlayer.Name, t = os.time() })
    local data, status = Chat.req("GET", "/users")
    if status ~= 200 then return end
    local now, names, n = os.time(), {}, 0
    if type(data) == "table" then
        for uid, info in pairs(data) do
            if type(info) == "table" and now - (tonumber(info.t) or 0) <= 90 then
                local plr = Players:GetPlayerByUserId(tonumber(uid) or 0)
                if plr then
                    n += 1
                    table.insert(names, plr.Name)
                end
            end
        end
    end
    table.sort(names)
    if n == 0 then n, names = 1, { LocalPlayer.Name } end
    local shown = {}
    for i = 1, math.min(#names, 5) do shown[i] = names[i] end
    setChatUsers(string.format("%d online · %s%s", n, table.concat(shown, ", "), #names > 5 and "..." or ""),
        n > 1 and Theme.on or Theme.warn)
end

-- sending -------------------------------------------------------------
function Chat.kickSelf()
    Chat.running = false
    pcall(function() LocalPlayer:Kick(Chat.KICK_MSG) end)
end

function Chat.send(text)
    text = string.gsub(tostring(text or ""), "^%s+", "")
    text = string.gsub(text, "%s+$", "")
    if text == "" then return end

    -- spam guard: too many messages in a row, too fast
    local now = os.clock()
    local gap = now - Chat.lastAttempt
    Chat.lastAttempt = now
    if gap < Chat.SPAM_GAP then
        Chat.spam += 1
        if Chat.spam >= Chat.MAX_STRIKES then Chat.kickSelf() return end
        notify(string.format("Slow down (%d/%d).", Chat.spam, Chat.MAX_STRIKES), Theme.warn, 2)
        return
    end
    Chat.spam = 0

    local cut = utf8.offset(text, 201)
    if cut then text = string.sub(text, 1, cut - 1) end

    -- bad word guard
    if Chat.isBad(text) then
        Chat.strikes += 1
        if Chat.strikes >= Chat.MAX_STRIKES then Chat.kickSelf() return end
        notify(string.format("Message blocked (bad word) %d/%d.", Chat.strikes, Chat.MAX_STRIKES), Theme.warn, 2.5)
        return
    end
    if not Chat.http then
        notify("Executor without <b>request</b>.", Theme.danger, 3)
        return
    end
    chatBox.Text = ""
    Chat.activeUntil = os.clock() + 30
    task.spawn(function()
        local rec = { u = LocalPlayer.Name, i = LocalPlayer.UserId, d = LocalPlayer.DisplayName, m = text, t = os.time() }
        local data, status = Chat.req("POST", "/messages", rec)
        if status == 200 and type(data) == "table" and data.name then
            Chat.upsert(data.name, rec)
        else
            chatBox.Text = text
            notify("Failed to send (" .. tostring(status) .. ").", Theme.danger, 3)
        end
    end)
end
chatBox.FocusLost:Connect(function(enter) if enter then Chat.send(chatBox.Text) end end)
sendBtn.Activated:Connect(function() Chat.send(chatBox.Text) end)

function Chat.start()
    if not Chat.http then
        setChatUsers("Executor without HTTP request", Theme.danger)
        notify("Chat needs an executor with <b>request</b> / <b>http_request</b>.", Theme.danger, 5)
        return
    end
    Chat.running = true
    setChatUsers("Connecting...", Theme.warn)
    bind(Players.PlayerRemoving, function(p)
        if p == LocalPlayer then return end
        task.spawn(Chat.req, "DELETE", "/users/" .. p.UserId)
    end)
    task.spawn(function()
        local lastPresence = 0
        while ScreenGui.Parent and Chat.running do
            pcall(Chat.poll)
            if os.clock() - lastPresence >= 15 then
                lastPresence = os.clock()
                pcall(Chat.presence)
            end
            task.wait(os.clock() < Chat.activeUntil and 1.5 or 3)
        end
    end)
end

function Chat.stop()
    if not Chat.running then return end
    Chat.running = false
    task.spawn(Chat.req, "DELETE", "/users/" .. LocalPlayer.UserId)
end

Chat.start()
end

P = pages.Player
sectionLabel(P, "Script")
local function disableUI()
    Auto.doors = false
    AutoHide.on = false
    AutoHide.origin, AutoHide.moved, AutoHide.hold = nil, false, nil
    AlertOn = false
    Plush.on = false
    pcall(Chat.stop)
    pcall(setESP, false)
    pcall(specClose)
    pcall(setNoclip, false)
    pcall(setFullbright, false)
    pcall(setAntiVoid, false)
    pcall(setPlayerESP, false)
    pcall(setKillOff, false)
    pcall(setJumpBlock, false)
    if Speed.value then
        Speed.value = nil
        local h = getHum()
        if h then h.WalkSpeed = Speed.default end
    end
    ScreenGui:Destroy()
end

local disableArmed = 0
makeButton(P, "Disable UI", "Unloads the script", function()
    if os.clock() - disableArmed < 3 then
        disableUI()
    else
        disableArmed = os.clock()
        notify("Tap <b>Disable UI</b> again to confirm.", Theme.danger, 3)
    end
end, true)

topBtn("close", -10, disableUI)
topBtn("minus", -46, function() setOpen(false) end)

task.spawn(function()
    while ScreenGui.Parent do
        pcall(function()
        setDoorStat(string.format("%d sections · %d rooms · %d fired", Stats.sections, Stats.rooms, Stats.fired))
        setEspStat(string.format("%d entities in Workspace.Entities", #getEntities()))

        local first = getFirstRoom()
        local room, pending = getPendingRoom()
        local startPos, endPos
        if first then
            local cf = doorFrame(first.door)
            if cf then startPos = cf.Position end
        end
        if room then
            local cf = doorFrame(room.door)
            if cf then endPos = cf.Position end
        end

        local reference = endPos or (getHRP() and getHRP().Position)
        local nearby = {}
        if reference then
            for _, entity in ipairs(getEntities()) do
                if isThreatEntity(entity) then
                    local ok, pos = pcall(entityPos, entity)
                    if ok then
                        local dist = (pos - reference).Magnitude
                        if dist <= TRACKER_RANGE then table.insert(nearby, { entity = entity, dist = dist }) end
                    end
                end
            end
        end
        table.sort(nearby, function(a, b) return a.dist < b.dist end)
        local nearest = nearby[1]
        local tone = Theme.on
        if nearest then tone = nearest.dist < 250 and Theme.danger or (nearest.dist < 500 and Theme.warn or Theme.on) end
        setTrackerStatus(string.format("%s · %d lethal in range",
            room and (pending and "Door pending" or "At last door") or "Player area", #nearby), tone)

        local barItems = {}
        if startPos and endPos then
            local axis = endPos - startPos
            local len2 = math.max(axis:Dot(axis), 1)
            for _, entity in ipairs(getEntities()) do
                if isThreatEntity(entity) then
                    local ok, pos = pcall(entityPos, entity)
                    if ok and typeof(pos) == "Vector3" then
                        local f = math.clamp((pos - startPos):Dot(axis) / len2, 0, 1)
                        table.insert(barItems, { key = entity, entity = entity, name = entity.Name, frac = f, color = entityColor(entity) })
                    end
                end
            end
        end
        setTrackerBar(barItems, first and ("Door " .. first.num) or "", room and ("Door " .. room.num) or "")

        setTrackerSpawn(TrackerEvents.spawned)
        setTrackerDespawn(TrackerEvents.despawned)

        local gm = getGamemodes()
        if gm then
            local n = 0
            for _, m in ipairs(MODES) do if findMode(m) then n += 1 end end
            setModesStatus(string.format("Found · %d/%d modes", n, #MODES), n == #MODES and Theme.on or Theme.warn)
        else
            setModesStatus("Not loaded (CurrentRoomsA.1.NewestCheckpoint)", Theme.danger)
        end
        setKillStat(string.format("%d%s", Kill.count, Kill.on and " · disabled" or ""))
        end)
        task.wait(0.5)
    end
end)

selectTab("Chat")
setOpen(true)

ScreenGui.Destroying:Connect(function()
    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    pcall(function() ESPFolder:Destroy() end)
end)

notify("<b>" .. SCRIPT_NAME .. "</b> loaded.", Theme.on, 2.5)
