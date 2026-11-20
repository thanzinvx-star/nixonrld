--[[
    WTRALD v.1.4 — UI do RayBeats Ultra, tema Dark Red
    Abas: Doors | ESP | Tracker | Items | Player | Modes
    UI original: Fyan / FynLabs (RayBeats Ultra) — sem biblioteca externa.
    Abrir/fechar: botão 🚪 ou tecla R.
]]

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace        = game:GetService("Workspace")
local Lighting         = game:GetService("Lighting")
local CoreGui          = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local GUI_NAME = "wtrald_ui"
local SCRIPT_NAME = "WTRALD v.1.4"

----------------------------------------------------------------------
-- CONFIG
----------------------------------------------------------------------

-- Pastas: Workspace.CurrentRoomsA, CurrentRoomsB, ... CurrentRooms?
local SECTION_IDS = { "A", "B", "G", "MAZE", "T", "U", "Y", "Z", "?" }

-- Entidades que NUNCA recebem ESP (nome exato)
local ESP_BLACKLIST = {}
for _, n in ipairs({
    "B-300Baby", "B300Explosion", "ABC", "ABA", "BBB", "M-222", "AMON", "AMON2",
    "M-120-B", "CMOB1", "CMOB2", "CMOB3", "XH1", "ZH2",
    "MOB1", "MOB2", "SN-1",
}) do
    ESP_BLACKLIST[string.lower(n)] = true
end

-- Ignoradas no ALERTA, no AUTO-HIDE e no Tracker (continuam com ESP).
-- Comparacao ignora maiusculas, espacos e parenteses.
local function normalizeName(name)
    return (string.gsub(string.lower(tostring(name)), "[%s%(%)%[%]]", ""))
end

local ALERT_IGNORE = {}
for _, n in ipairs({
    "Happyman", "Joyfulman", "Nerdman", "Mournfulman", "Shortman", "Tallman",
    "Angryman", "Sadman", "Bigman", "SB-1", "1-A", "1-B", "1-G", "A-1", "CB-1", "Glee", "A-120", "Hardcore-120", "AMON", "AMON2",
    "A-120 (V)", "A-120 (B)", "A-120 (G)", "A-120 (U)",
    "C-1", "B-1", "G-1", "B-15", "G-3",
    "Widowed Sleeper", "SP-1",
    "E-1", "DG-1", "XE-1", "CHA-1", "BM-1", "V-5", "XV-5", "SN-1",
    "MOB1", "MOB2",
}) do
    ALERT_IGNORE[normalizeName(n)] = true
end

local function isAlertIgnored(name)
    local n = normalizeName(name)
    if ALERT_IGNORE[n] == true then return true end
    local flat = string.gsub(n, "[^%w]", "")
    return string.find(flat, "a120", 1, true) ~= nil
end

local function isEspIgnored(name)
    local low = string.lower(name)
    if ESP_BLACKLIST[low] then return true end
    local norm = string.gsub(low, "[^%w]", "")
    if #norm >= 2 and string.match(norm, "^[xyz]+$") then return true end
    if string.find(norm, "a120", 1, true) then return true end
    if string.find(norm, "300minion", 1, true) or string.find(norm, "minion300", 1, true) then return true end
    return false
end

-- Entidades que nao podem ser espectadas
local function isSpecIgnored(name)
    local flat = string.gsub(string.lower(tostring(name)), "[^%w]", "")
    return flat == "1a" or flat == "1b" or flat == "1g" or flat == "mob1" or flat == "mob2"
end

-- Variantes de alerta (texto depois do nome da entidade)
local ALERT_TIME = 2.5
local ALERT_VARIANT = {}
local function regVariant(list, text)
    for _, n in ipairs(list) do ALERT_VARIANT[normalizeName(n)] = text end
end

-- Variante 1: mesa
regVariant({
    "A-105", "C-105", "A-100", "X-100", "A-320", "B-170", "B-40", "G-55", "CG-55", "G-150",
    "G-122", "Cate-40", "Noonir-40", "Omg-40", "G-10", "CG-10", "T-110", "GodHasForsaken",
}, " spawned, hide in a table! (table must be color of lightwood)")

-- Variante 2: locker cinza ou azul
regVariant({
    "A-200", "B-120", "CV-300", "FO-300", "G-140", "MY_INNER_SKIN",
}, " spawned, hide on a grey locker (must be color RGB(163, 162, 165)) or blue locker! (must be RGB(13, 105, 172))")

-- A-185: aviso unico
regVariant({ "A-185" }, " spawned, hide on a GREY locker or a table!")

-- Tema Dark Red (nomes mantidos para a logica)
local Theme = {
    bg      = Color3.fromRGB(10, 8, 9),
    header  = Color3.fromRGB(20, 14, 15),
    card    = Color3.fromRGB(26, 19, 20),
    cardHi  = Color3.fromRGB(44, 28, 30),
    stroke  = Color3.fromRGB(139, 0, 0),
    text    = Color3.fromRGB(255, 255, 255),
    sub     = Color3.fromRGB(255, 255, 255),
    accent  = Color3.fromRGB(139, 0, 0),
    accent2 = Color3.fromRGB(196, 30, 30),
    accentText = Color3.fromRGB(255, 255, 255),
    btn     = Color3.fromRGB(92, 6, 8),
    dangerBtn = Color3.fromRGB(170, 20, 24),
    on      = Color3.fromRGB(82, 196, 128),
    off     = Color3.fromRGB(44, 28, 30),
    danger  = Color3.fromRGB(229, 77, 82),
    warn    = Color3.fromRGB(236, 196, 84),
}

----------------------------------------------------------------------
-- CLEANUP DE EXECUCOES ANTERIORES
----------------------------------------------------------------------

local OLD_NAMES = { GUI_NAME, "nixon_rld_ui", "wtrald_ui_beta" }
for _, getParent in ipairs({
    function() return (gethui and gethui()) or CoreGui end,
    function() return LocalPlayer:FindFirstChildOfClass("PlayerGui") end,
}) do
    pcall(function()
        local parent = getParent()
        for _, c in ipairs(parent:GetChildren()) do
            for _, old in ipairs(OLD_NAMES) do
                if c.Name == old or c.Name == old .. "_ESP" then c:Destroy() break end
            end
        end
    end)
end

----------------------------------------------------------------------
-- HELPERS
----------------------------------------------------------------------

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

-- feedback de toque para botoes de cor solida
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

----------------------------------------------------------------------
-- UI: JANELA (RayBeats Ultra, vazia)
----------------------------------------------------------------------

local ScreenGui = create("ScreenGui", {
    Name = GUI_NAME, ResetOnSpawn = false, IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999,
})
mount(ScreenGui)

local ESPFolder = create("Folder", { Name = GUI_NAME .. "_ESP" })
mount(ESPFolder)

local win = create("Frame", {
    Name = "Window", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(480, 330), BackgroundColor3 = WHITE, BorderSizePixel = 0, Active = true,
    Parent = ScreenGui,
}, {
    corner(20),
    create("UIGradient", { Color = ColorSequence.new(Color3.fromRGB(34, 8, 10), Color3.fromRGB(9, 8, 9)), Rotation = 125 }),
})
local winStroke = create("UIStroke", { Color = WHITE, Thickness = 2, Transparency = 0.1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = win })
local winGrad = accentGrad()
winGrad.Parent = winStroke

local uiScale = create("UIScale", { Parent = win })
local function fitScale()
    local cam = Workspace.CurrentCamera
    if not cam then return 1 end
    local v = cam.ViewportSize
    return math.clamp(math.min(v.X / 530, v.Y / 380), 0.5, 1.15)
end
uiScale.Scale = fitScale()
if Workspace.CurrentCamera then
    bind(Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), function() uiScale.Scale = fitScale() end)
end

local top = create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 44), Parent = win })
label({
    Text = SCRIPT_NAME, Font = FONT_BLACK, TextSize = 18, TextColor3 = WHITE,
    Position = UDim2.new(0, 16, 0, 0), Size = UDim2.new(0, 160, 1, 0), Parent = top,
})

local function topBtn(txt, x, cb)
    local b = create("TextButton", {
        Text = txt, Font = FONT_BOLD, TextSize = 14, TextColor3 = Theme.sub, BackgroundColor3 = Theme.card,
        AutoButtonColor = false, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, x, 0.5, 0),
        Size = UDim2.fromOffset(30, 26), BorderSizePixel = 0, Parent = top,
    }, { corner(8) })
    b.MouseEnter:Connect(function() tween(b, 0.15, { BackgroundColor3 = Theme.cardHi, TextColor3 = Theme.text }) end)
    b.MouseLeave:Connect(function() tween(b, 0.15, { BackgroundColor3 = Theme.card, TextColor3 = Theme.sub }) end)
    b.MouseButton1Click:Connect(cb)
    return b
end

-- arrastar pela barra superior
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

-- botao flutuante + abrir/fechar
local fab = create("TextButton", {
    Text = "🚪", TextSize = 22, Font = FONT_BOLD, TextColor3 = WHITE, BackgroundColor3 = Theme.accent, AutoButtonColor = false,
    Position = UDim2.new(0, 12, 0.5, -24), Size = UDim2.fromOffset(48, 48), BorderSizePixel = 0, ZIndex = 5,
    Parent = ScreenGui,
}, { corner(24), stroke(Theme.accent2, 2, 0.2) })

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

local side = create("Frame", {
    BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 48), Size = UDim2.new(0, 104, 1, -58), Parent = win,
}, { create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }) })

local content = create("Frame", {
    BackgroundTransparency = 1, Position = UDim2.new(0, 122, 0, 48), Size = UDim2.new(1, -132, 1, -58),
    ClipsDescendants = true, Parent = win,
})

----------------------------------------------------------------------
-- UI: ABAS E COMPONENTES
----------------------------------------------------------------------

local TAB_NAMES = { "Doors", "ESP", "Tracker", "Items", "Player", "Modes" }
local TAB_ICONS = { Doors = "🚪", ESP = "👁", Tracker = "📡", Items = "🎒", Player = "🏃", Modes = "🎮" }

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
        tween(t.b, 0.2, { BackgroundColor3 = on and Theme.accent or Theme.card })
    end
end

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
        Text = TAB_ICONS[name] .. " " .. name, Font = FONT_BOLD, TextSize = 12, TextColor3 = Theme.sub,
        BackgroundColor3 = Theme.card, AutoButtonColor = false, Size = UDim2.new(1, 0, 0, 34), BorderSizePixel = 0,
        LayoutOrder = i, TextXAlignment = Enum.TextXAlignment.Left, Parent = side,
    }, { corner(10), stroke(Theme.stroke, 1, 0.5), create("UIPadding", { PaddingLeft = UDim.new(0, 10) }) })
    tabBtns[name] = { b = b }
    b.MouseButton1Click:Connect(function() selectTab(name) end)
end

local function sectionLabel(page, text)
    local l = label({
        Text = string.upper(text), TextSize = 11, Font = FONT_BOLD, TextColor3 = Theme.text,
        Size = UDim2.new(1, 0, 0, 20), LayoutOrder = nextOrder(page), Parent = page,
    })
    return l
end

local function baseRow(page, h)
    local row = create("Frame", {
        Size = UDim2.new(1, 0, 0, h), BackgroundColor3 = Theme.card, BorderSizePixel = 0,
        LayoutOrder = nextOrder(page), Parent = page,
    }, { corner(12) })
    local st = create("UIStroke", { Color = Theme.stroke, Thickness = 1, Transparency = 0.4, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = row })
    return row, st
end

-- titulo + subtitulo, com largura reservada para o controle da direita
local function rowTexts(row, title, sub, rightW, danger, rich)
    local w = -(28 + rightW)
    label({
        Text = title, RichText = rich == true, TextSize = 13, Font = FONT_BOLD,
        TextColor3 = Theme.text,
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
    }, { corner(11), stroke(Theme.stroke, 1, 0.3) })
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
        tween(sw, 0.18, { BackgroundColor3 = v and Theme.accent2 or Theme.cardHi })
        tween(knob, 0.18, { Position = v and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0) })
        tween(rowStroke, 0.3, { Color = v and Theme.accent2 or Theme.stroke, Transparency = v and 0.05 or 0.4 })
        if not silent and onChange then task.spawn(onChange, v) end
    end
    btn.Activated:Connect(function() set(not state) end)
    return { Set = set, Get = function() return state end }
end

-- rich = true => o titulo aceita RichText (mantem fundo escuro para as cores ficarem legiveis)
local function makeButton(page, title, sub, onClick, danger, rich)
    local row = baseRow(page, 52)
    local base = rich and Theme.card or (danger and Theme.dangerBtn or Theme.btn)
    local hover = rich and Theme.cardHi or (danger and Theme.accent2 or Theme.accent)
    row.BackgroundColor3 = base
    rowTexts(row, title, sub, 30, danger, rich)
    local chev = label({
        Text = ">", TextSize = 18, Font = FONT_BOLD, TextColor3 = Theme.text,
        TextXAlignment = Enum.TextXAlignment.Center, AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0), Size = UDim2.fromOffset(16, 22), Parent = row,
    })
    local btn = overlayButton(row)
    pressFx(btn,
        function()
            tween(row, 0.1, { BackgroundColor3 = hover })
            tween(chev, 0.15, { Position = UDim2.new(1, -10, 0.5, 0) }, Enum.EasingStyle.Quint)
        end,
        function()
            tween(row, 0.25, { BackgroundColor3 = base })
            tween(chev, 0.3, { Position = UDim2.new(1, -14, 0.5, 0) }, Enum.EasingStyle.Quint)
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

-- cartao de status (valor atualizado em tempo real)
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

-- status com indicador colorido
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

local function makeRangeBar(page, title, maxRange)
    local row = baseRow(page, 106)
    label({
        Text = string.upper(title), TextSize = 10, Font = FONT_BOLD, TextColor3 = Theme.sub,
        Position = UDim2.fromOffset(14, 9), Size = UDim2.new(1, -28, 0, 13), Parent = row,
    })
    local scale = label({
        Text = "", TextSize = 10, Font = FONT_MONO, TextColor3 = Theme.sub, TextXAlignment = Enum.TextXAlignment.Right,
        Position = UDim2.fromOffset(14, 9), Size = UDim2.new(1, -28, 0, 13), Parent = row,
    })
    local track = create("Frame", {
        Position = UDim2.fromOffset(14, 33), Size = UDim2.new(1, -28, 0, 8), BackgroundColor3 = Theme.bg,
        BorderSizePixel = 0, Parent = row,
    }, { pill(), stroke(Theme.stroke, 1, 0) })
    local span = create("Frame", {
        Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Theme.accent, BackgroundTransparency = 0.5,
        BorderSizePixel = 0, Visible = false, Parent = track,
    }, { pill() })
    local function marker(color)
        return create("Frame", {
            Size = UDim2.fromOffset(14, 14), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
            BackgroundColor3 = color, BorderSizePixel = 0, Visible = false, ZIndex = 3, Parent = track,
        }, { pill(), stroke(Theme.card, 2, 0) })
    end
    local nearMarker, farMarker = marker(Theme.on), marker(Theme.text)
    local function infoRow(y, dotColor, tag)
        local dot = create("Frame", {
            Size = UDim2.fromOffset(8, 8), Position = UDim2.fromOffset(14, y + 4), BackgroundColor3 = dotColor,
            BorderSizePixel = 0, Parent = row,
        }, { pill() })
        label({ Text = tag, TextSize = 10, Font = FONT_BOLD, TextColor3 = Theme.sub,
            Position = UDim2.fromOffset(28, y), Size = UDim2.fromOffset(60, 16), Parent = row })
        local nameLbl = label({ Text = "None", TextSize = 12, Font = FONT_BOLD, TextTruncate = Enum.TextTruncate.AtEnd,
            Position = UDim2.fromOffset(90, y), Size = UDim2.new(1, -(90 + 88), 0, 16), Parent = row })
        local distLbl = label({ Text = "--", TextSize = 12, Font = FONT_MONO, TextXAlignment = Enum.TextXAlignment.Right,
            Position = UDim2.new(1, -84, 0, y), Size = UDim2.fromOffset(70, 16), Parent = row })
        return dot, nameLbl, distLbl
    end
    local nearDot, nearName, nearDist = infoRow(54, Theme.on, "NEAREST")
    local farDot, farName, farDistLbl = infoRow(78, Theme.text, "FARTHEST")
    local function place(m, f)
        local target = UDim2.new(f, 0, 0.5, 0)
        if m.Visible then tween(m, 0.35, { Position = target }, Enum.EasingStyle.Quint)
        else m.Position = target; m.Visible = true end
    end
    return function(near, far, refText)
        scale.Text = string.format("from %s · 0-%dm", refText or "you", maxRange)
        local fNear, fFar
        if near then
            fNear = math.clamp(near.dist / maxRange, 0, 1)
            local tone = near.dist < 250 and Theme.danger or (near.dist < 500 and Theme.warn or Theme.on)
            place(nearMarker, fNear)
            tween(nearMarker, 0.3, { BackgroundColor3 = tone })
            tween(nearDot, 0.3, { BackgroundColor3 = tone })
            nearName.Text, nearDist.Text = near.name, string.format("%dm", near.dist)
        else
            nearMarker.Visible = false; nearName.Text = "None"; nearDist.Text = "--"
        end
        if far then
            fFar = math.clamp(far.dist / maxRange, 0, 1)
            place(farMarker, fFar)
            farName.Text, farDistLbl.Text = far.name, string.format("%dm", far.dist)
        else
            farMarker.Visible = false; farName.Text = "None"; farDistLbl.Text = "--"
        end
        if fNear and fFar then
            local a, b = math.min(fNear, fFar), math.max(fNear, fFar)
            if not span.Visible then
                span.Position = UDim2.new(a, 0, 0, 0); span.Size = UDim2.new(b - a, 0, 1, 0); span.Visible = true
            else
                tween(span, 0.35, { Position = UDim2.new(a, 0, 0, 0), Size = UDim2.new(b - a, 0, 1, 0) }, Enum.EasingStyle.Quint)
            end
        else span.Visible = false end
    end
end

local function makeInput(page, title, placeholder, onSubmit)
    local row = baseRow(page, 84)
    label({
        Text = title, TextSize = 13, Font = FONT_BOLD,
        Position = UDim2.fromOffset(14, 8), Size = UDim2.new(1, -28, 0, 18), Parent = row,
    })
    local box = create("TextBox", {
        Text = "", PlaceholderText = placeholder, PlaceholderColor3 = Color3.fromRGB(190, 190, 190), TextColor3 = Theme.text,
        TextSize = 13, Font = FONT_MONO, ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.fromOffset(14, 40), Size = UDim2.new(1, -92, 0, 32), BackgroundColor3 = Theme.cardHi,
        BorderSizePixel = 0, Parent = row,
    }, { corner(8), create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }) })
    local ok = create("TextButton", {
        Text = "OK", TextSize = 13, Font = FONT_BOLD, TextColor3 = WHITE,
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 40), Size = UDim2.fromOffset(56, 32),
        BackgroundColor3 = Theme.accent, AutoButtonColor = false, BorderSizePixel = 0, Parent = row,
    }, { corner(8) })
    tapFx(ok, Theme.accent, Theme.accent2)
    box.FocusLost:Connect(function(enter) if enter then onSubmit(box.Text) end end)
    ok.Activated:Connect(function() onSubmit(box.Text) end)
end

----------------------------------------------------------------------
-- UI: NOTIFICACOES (toasts) — topo central
----------------------------------------------------------------------

local ToastHolder = create("Frame", {
    Name = "Toasts", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 12),
    Size = UDim2.fromOffset(math.clamp(vp.X - 90, 230, 320), 0), AutomaticSize = Enum.AutomaticSize.Y,
    BackgroundTransparency = 1, Parent = ScreenGui,
}, {
    create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
})

local activeToasts = {}
local MAX_TOASTS = 3
local TOAST_H = 52
local toastN = 0

local function removeActive(entry)
    local i = table.find(activeToasts, entry)
    if i then table.remove(activeToasts, i) end
end

local function dismissToast(entry, fast)
    if entry.dismissed then return end
    entry.dismissed = true
    local t = fast and 0.15 or 0.28
    tween(entry.card, t, { GroupTransparency = 1 })
    tween(entry.wrap, t + 0.06, { Size = UDim2.new(1, 0, 0, 0) })
    task.delay(t + 0.12, function()
        if entry.wrap and entry.wrap.Parent then entry.wrap:Destroy() end
    end)
end

local function notify(text, color, duration, glyph)
    color = color or Theme.accent
    duration = duration or 3.5
    glyph = glyph or (color == Theme.on and "✓") or ((color == Theme.warn or color == Theme.danger) and "!") or "i"

    for _, e in ipairs(activeToasts) do
        if e.text == text and not e.dismissed then e.restart(duration) return end
    end
    while #activeToasts >= MAX_TOASTS do
        local old = table.remove(activeToasts, 1)
        if old then dismissToast(old, true) end
    end

    toastN += 1
    local wrap = create("Frame", {
        Size = UDim2.new(1, 0, 0, TOAST_H), BackgroundTransparency = 1, ClipsDescendants = true,
        LayoutOrder = toastN, Parent = ToastHolder,
    })
    local card = create("CanvasGroup", {
        Size = UDim2.new(1, 0, 0, TOAST_H), BackgroundColor3 = Theme.header, GroupTransparency = 1, Parent = wrap,
    }, { corner(12), stroke(color, 1.5, 0.35) })
    create("TextLabel", {
        Text = glyph, TextSize = 14, Font = FONT_BLACK, TextColor3 = color, BackgroundColor3 = color,
        BackgroundTransparency = 0.84, Size = UDim2.fromOffset(26, 26), Position = UDim2.fromOffset(10, 11),
        BorderSizePixel = 0, Parent = card,
    }, { corner(8) })
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

    local entry = { text = text, wrap = wrap, card = card, dismissed = false, token = 0 }
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
    table.insert(activeToasts, entry)
    tween(card, 0.3, { GroupTransparency = 0 })
    start(duration)
end

----------------------------------------------------------------------
-- UI: JANELA DE CONFIRMACAO GENERICA
----------------------------------------------------------------------

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

-- opts: title (rich), body (rich), bar, confirmText, confirmBg, confirmFg, onConfirm
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

-- animacao da borda da janela
bind(RunService.Heartbeat, function(dt)
    winGrad.Rotation = (winGrad.Rotation + dt * 50) % 360
end)

----------------------------------------------------------------------
-- LOGICA: ENTIDADES + ESP (cor vem do PointLight da entidade)
----------------------------------------------------------------------

local function getAllEntities()
    local list = {}
    local folder = Workspace:FindFirstChild("Entities")
    if not folder then return list end
    -- Entidades podem estar em subpastas; evita contar partes internas de um Model
    for _, obj in ipairs(folder:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
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

-- lista do Spectate: igual ao ESP, menos 1-A / 1-B / 1-G (e MOB1/MOB2)
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

-- G-88: o PointLight ativo se chama Orange, Pink, Red ou Yellow
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

local function isDark(c)
    return (c.R * 0.299 + c.G * 0.587 + c.B * 0.114) < 0.25
end

local function richName(name, color)
    local text = string.format('<font color="#%s">%s</font>', color:ToHex(), esc(name))
    if isDark(color) then
        text = '<stroke color="#FFFFFF" thickness="1">' .. text .. '</stroke>'
    end
    return text
end

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

local function setESP(v)
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

----------------------------------------------------------------------
-- LOGICA: SPECTATE ENTITIES
----------------------------------------------------------------------

local Spec = { active = false, entity = nil }
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

local function navBtn(text, anchorX)
    local b = create("TextButton", {
        Text = text, TextSize = 20, Font = FONT_BOLD, TextColor3 = Theme.text, AutoButtonColor = false,
        AnchorPoint = Vector2.new(anchorX, 0.5), Position = UDim2.new(anchorX, anchorX == 0 and 7 or -7, 0.5, 0),
        Size = UDim2.fromOffset(44, 38), BackgroundColor3 = Theme.cardHi, BorderSizePixel = 0, Parent = NavRow,
    }, { corner(9) })
    tapFx(b, Theme.cardHi, Theme.stroke)
    return b
end
local PrevBtn, NextBtn = navBtn("<", 0), navBtn(">", 1)
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

local function specClose()
    Spec.active, Spec.entity = false, nil
    restoreSpectateAudio()
    SpectateBar.Visible = false
    local cam = Workspace.CurrentCamera
    local hum = getHum()
    if cam and hum then cam.CameraSubject = hum end
end

local function specStep(dir)
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

local function specOpen()
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

----------------------------------------------------------------------
-- LOGICA: ALERTA DE ENTIDADES (variantes)
----------------------------------------------------------------------

local AlertOn = false
local TrackerEvents = { spawned = "—", despawned = "—" }

local function alertNotify(entity, suffix)
    local c = entityColor(entity)
    notify("<b>" .. richName(entity.Name, c) .. "</b>" .. suffix,
        isDark(c) and Color3.new(1, 1, 1) or c, ALERT_TIME, "!")
end

-- G-100: avisos pelos sons Moving.Spawn e Moving.Transition
local function watchG100(entity)
    local prevSpawn, prevTrans = false, false
    while entity.Parent and ScreenGui.Parent do
        local mv = entity:FindFirstChild("Moving")
        local sp = mv and mv:FindFirstChild("Spawn")
        local tr = mv and mv:FindFirstChild("Transition")
        local ps = (sp and sp:IsA("Sound") and sp.Playing) or false
        local pt = (tr and tr:IsA("Sound") and tr.Playing) or false
        if AlertOn then
            if ps and not prevSpawn then
                alertNotify(entity, " spawned, hide on a grey or blue locker!")
            end
            if pt and not prevTrans then
                alertNotify(entity, " will check gray lockers now, hide in a blue locker or table!")
            end
        end
        prevSpawn, prevTrans = ps, pt
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
    local known = {}
    local firstPass = true
    task.spawn(function()
        while ScreenGui.Parent do
            pcall(function()
                local current = {}
                for _, e in ipairs(getEntities()) do
                    current[e] = true
                    if not known[e] then
                        known[e] = true
                        if not firstPass then onEntitySpawned(e) end
                    end
                end
                for e in pairs(known) do
                    if not current[e] then
                        known[e] = nil
                        onEntityRemoved(e)
                    end
                end
                firstPass = false
            end)
            task.wait(0.2)
        end
    end)
end

local function setAlert(v) AlertOn = v end

----------------------------------------------------------------------
-- LOGICA: SPEED + NOCLIP
----------------------------------------------------------------------

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

local noclipConn
local function setNoclip(v)
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

----------------------------------------------------------------------
-- LOGICA: FULLBRIGHT
----------------------------------------------------------------------

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

----------------------------------------------------------------------
-- LOGICA: ANTI-VOID (chao invisivel no seu pe)
----------------------------------------------------------------------

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

----------------------------------------------------------------------
-- LOGICA: DELETE SHAKER
----------------------------------------------------------------------

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
    notify(string.format("<b>Shaker</b> removed (%d found). Screen shake is gone for good.", n), Theme.on, 4)
end

local function showShakerDialog()
    Dialog.show({
        title = "Delete Shaker",
        body = 'This removes every "Shaker" script, so there will be <b>no more screen shake</b>. It <b>cannot be undone</b>.',
        bar = Theme.danger, confirmText = "Activate", confirmBg = Theme.danger, confirmFg = Color3.new(1, 1, 1),
        onConfirm = activateShakerDelete,
    })
end

----------------------------------------------------------------------
-- LOGICA: CAMERA (MAX ZOOM, NOCLIP CAMERA) + X-RAY
----------------------------------------------------------------------

local Extra = {
    zoom = nil, zoomDefault = nil, occSaved = nil, camConn = nil, zoomConn = nil,
    xray = { on = false, level = 0.65, parts = {}, conn = nil, rconn = nil, token = 0 },
}

function Extra.applyZoom(text)
    local n = tonumber(text)
    if n and n > 0 then
        if Extra.zoomDefault == nil then Extra.zoomDefault = LocalPlayer.CameraMaxZoomDistance end
        Extra.zoom = math.clamp(n, 0.5, 100000)
        pcall(function()
            LocalPlayer.CameraMaxZoomDistance = Extra.zoom
            if LocalPlayer.CameraMinZoomDistance > Extra.zoom then LocalPlayer.CameraMinZoomDistance = Extra.zoom end
        end)
        if not Extra.zoomConn then
            Extra.zoomConn = bind(RunService.RenderStepped, function()
                if Extra.zoom and LocalPlayer.CameraMaxZoomDistance ~= Extra.zoom then
                    pcall(function() LocalPlayer.CameraMaxZoomDistance = Extra.zoom end)
                end
            end)
        end
        notify("Max zoom set to <b>" .. Extra.zoom .. "</b>", Theme.on)
    else
        Extra.zoom = nil
        if Extra.zoomConn then Extra.zoomConn:Disconnect() Extra.zoomConn = nil end
        if Extra.zoomDefault then
            pcall(function() LocalPlayer.CameraMaxZoomDistance = Extra.zoomDefault end)
            notify("Max zoom reset to <b>" .. Extra.zoomDefault .. "</b>", Theme.accent2)
            Extra.zoomDefault = nil
        end
    end
end

-- Noclip Camera: Invisicam desliga o Popper (camera atravessa paredes)
function Extra.setCamNoclip(v)
    if Extra.camConn then Extra.camConn:Disconnect() Extra.camConn = nil end
    if v then
        if Extra.occSaved == nil then Extra.occSaved = LocalPlayer.DevCameraOcclusionMode end
        local function apply()
            if LocalPlayer.DevCameraOcclusionMode ~= Enum.DevCameraOcclusionMode.Invisicam then
                pcall(function() LocalPlayer.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam end)
            end
        end
        Extra.camConn = bind(RunService.RenderStepped, apply)
        apply()
    elseif Extra.occSaved ~= nil then
        local saved = Extra.occSaved
        Extra.occSaved = nil
        pcall(function() LocalPlayer.DevCameraOcclusionMode = saved end)
    end
end

function Extra.xrayTarget(d)
    if not d:IsA("BasePart") or d:IsA("Terrain") then return false end
    if d.Transparency >= 0.95 then return false end
    local char = LocalPlayer.Character
    if char and d:IsDescendantOf(char) then return false end
    local ent = Workspace:FindFirstChild("Entities")
    if ent and d:IsDescendantOf(ent) then return false end
    local m = d:FindFirstAncestorOfClass("Model")
    if m and m:FindFirstChildOfClass("Humanoid") then return false end
    return true
end

function Extra.setXray(v)
    local x = Extra.xray
    x.token += 1
    local token = x.token
    x.on = v
    if x.conn then x.conn:Disconnect() x.conn = nil end
    if x.rconn then x.rconn:Disconnect() x.rconn = nil end

    if v then
        local parts = {}
        x.parts = parts
        local function apply(d)
            if parts[d] == nil then
                local ok, orig = pcall(function() return d.LocalTransparencyModifier end)
                parts[d] = (ok and orig) or 0
            end
            pcall(function() d.LocalTransparencyModifier = x.level end)
        end
        x.conn = bind(Workspace.DescendantAdded, function(d)
            task.defer(function()
                if x.token == token and d.Parent and Extra.xrayTarget(d) then apply(d) end
            end)
        end)
        x.rconn = bind(Workspace.DescendantRemoving, function(d)
            local orig = parts[d]
            if orig ~= nil then
                parts[d] = nil
                pcall(function() d.LocalTransparencyModifier = orig end)
            end
        end)
        task.spawn(function()
            local n = 0
            for _, d in ipairs(Workspace:GetDescendants()) do
                if x.token ~= token then return end
                if Extra.xrayTarget(d) then apply(d) end
                n += 1
                if n % 1500 == 0 then task.wait() end
            end
        end)
    else
        local parts = x.parts
        x.parts = {}
        for part, orig in pairs(parts) do
            pcall(function() part.LocalTransparencyModifier = orig end)
        end
    end
end

----------------------------------------------------------------------
-- LOGICA: PORTAS (Workspace.CurrentRoomsX.<numero>.door)
----------------------------------------------------------------------

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

local Stats = { sections = 0, rooms = 0 }

task.spawn(function()
    while ScreenGui.Parent do
        pcall(function()
            local sections = getSections()
            local rooms = 0
            for _, s in ipairs(sections) do rooms += #getNumberedRooms(s.folder) end
            Stats.sections, Stats.rooms = #sections, rooms
        end)
        task.wait(0.5)
    end
end)

----------------------------------------------------------------------
-- LOGICA: TELEPORT PARA A SALA ATUAL
----------------------------------------------------------------------

local function doorFrame(door)
    if door:IsA("BasePart") then return door.CFrame, door.Size end
    if door:IsA("Model") then return door:GetBoundingBox() end
    local part = door:FindFirstChildWhichIsA("BasePart", true)
    if part then return part.CFrame, part.Size end
    return nil
end

-- sala cuja porta o script esta abrindo agora: a de MAIOR numero com prompt ativo
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

----------------------------------------------------------------------
-- LOGICA: ITEMS (teleports fixos)
----------------------------------------------------------------------

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

local function isThreatEntity(entity)
    return not isAlertIgnored(entity.Name) and not isEspIgnored(entity.Name)
end

----------------------------------------------------------------------
-- LOGICA: MODES (checkpoint gamemodes + kill part + jumpscares)
----------------------------------------------------------------------

local MODES = { "BRAZIL", "burbur", "fish", "hard", "insane", "lobotomy", "thecantloupe" }

-- workspace.CurrentRoomsA["1"].NewestCheckpoint.gamemodes
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

-- the part that kills: workspace["CurrentRooms?"]["10"]["the part that kills"] (e equivalentes)
local Kill = { on = false, saved = setmetatable({}, { __mode = "k" }), count = 0 }

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

local function setKillOff(v)
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

-- Jumpscares: LocalPlayer.PlayerGui.Jumpscares
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

local function setJumpBlock(v)
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

----------------------------------------------------------------------
-- UI: CONTEUDO DAS ABAS
----------------------------------------------------------------------

-- Doors
local P = pages.Doors
sectionLabel(P, "Doors")
makeButton(P, "Teleport to current room", "Move to the room currently being opened", teleportToLastRoom)
local setDoorStat = makeStat(P, "Status")

-- ESP
P = pages.ESP
sectionLabel(P, "Entities")
makeToggle(P, "ESP Entities", "Name, distance and light color", setESP)
makeButton(P, "Spectate Entities", "Camera follows the entity; others muted", specOpen)
local setEspStat = makeStat(P, "Tracking")

sectionLabel(P, "Alerts")
makeToggle(P, "Alert Entities", "Notify when an entity spawns", setAlert)

-- Tracker
P = pages.Tracker
local TRACKER_RANGE = 1000
sectionLabel(P, "Threat radar")
local setTrackerStatus = makeStatus(P, "Detection status")
local setTrackerRange = makeRangeBar(P, "Entity range", TRACKER_RANGE)
sectionLabel(P, "Activity")
local setTrackerSpawn, setTrackerDespawn = makeDualStat(P, "Last spawned", "Last despawned")

-- Items
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

-- Player
P = pages.Player
sectionLabel(P, "Movement")
makeInput(P, "Change Speed", "Number (empty = reset)", applySpeed)
makeToggle(P, "Noclip", "Walk through walls", setNoclip)
makeToggle(P, "Anti-Void", "Invisible floor if you fall", setAntiVoid)

sectionLabel(P, "World")
makeToggle(P, "Fullbright", "Bright map, no fog", setFullbright)
makeButton(P, "Delete Shaker", "Removes screen shake for good", showShakerDialog, true)

sectionLabel(P, "Camera")
makeInput(P, "Max Zoom", "Number (empty = reset)", Extra.applyZoom)
makeToggle(P, "Noclip Camera", "Camera passes through walls (Popper off)", Extra.setCamNoclip)
makeToggle(P, "X-Ray", "See through walls and doors", Extra.setXray)

-- Modes
P = pages.Modes
sectionLabel(P, "Checkpoint gamemodes")
local setModesStatus = makeStatus(P, "Gamemodes folder")

sectionLabel(P, "Hazards")
makeToggle(P, "Disable kill part", "\"the part that kills\" (client-side)", setKillOff)
local setKillStat = makeStat(P, "Kill parts found")
makeToggle(P, "Block Jumpscares", "Hides PlayerGui.Jumpscares + sounds", setJumpBlock)
makeParagraph(P, "Entities <b>1-A</b>, <b>1-B</b> and <b>1-G</b> are ignored by alerts, tracker and spectate. The kill-part toggle only works if the game checks the touch on your client.", 74)

-- Script
P = pages.Player
sectionLabel(P, "Script")
local function disableUI()
    AlertOn = false
    pcall(setESP, false)
    pcall(specClose)
    pcall(setNoclip, false)
    pcall(setFullbright, false)
    pcall(setAntiVoid, false)
    pcall(Extra.setCamNoclip, false)
    pcall(Extra.setXray, false)
    pcall(Extra.applyZoom, "")
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

topBtn("✕", -10, disableUI)
topBtn("—", -46, function() setOpen(false) end)

-- atualiza cartoes de status
task.spawn(function()
    while ScreenGui.Parent do
        setDoorStat(string.format("%d sections · %d rooms", Stats.sections, Stats.rooms))
        setEspStat(string.format("%d entities in Workspace.Entities", #getEntities()))

        local reference = getHRP() and getHRP().Position
        local room, pending = getPendingRoom()
        if room then
            local doorCF = doorFrame(room.door)
            if doorCF then reference = doorCF.Position end
        end
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
        local nearest, farthest = nearby[1], nearby[#nearby]
        local tone = Theme.on
        if nearest then tone = nearest.dist < 250 and Theme.danger or (nearest.dist < 500 and Theme.warn or Theme.on) end
        setTrackerStatus(string.format("%s · %d lethal in range",
            room and (pending and "Door pending" or "At last door") or "Player area", #nearby), tone)
        setTrackerRange(
            nearest and { name = nearest.entity.Name, dist = math.floor(nearest.dist + 0.5) } or nil,
            farthest and { name = farthest.entity.Name, dist = math.floor(farthest.dist + 0.5) } or nil,
            room and "door" or "you")
        setTrackerSpawn(TrackerEvents.spawned)
        setTrackerDespawn(TrackerEvents.despawned)

        -- Modes
        local gm = getGamemodes()
        if gm then
            local n = 0
            for _, m in ipairs(MODES) do if findMode(m) then n += 1 end end
            setModesStatus(string.format("Found · %d/%d modes", n, #MODES), n == #MODES and Theme.on or Theme.warn)
        else
            setModesStatus("Not loaded (CurrentRoomsA.1.NewestCheckpoint)", Theme.danger)
        end
        setKillStat(string.format("%d%s", Kill.count, Kill.on and " · disabled" or ""))
        task.wait(0.5)
    end
end);

selectTab("Doors")
setOpen(true)

ScreenGui.Destroying:Connect(function()
    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    pcall(function() ESPFolder:Destroy() end)
end)

notify("<b>" .. SCRIPT_NAME .. "</b> loaded.", Theme.on, 2.5)
