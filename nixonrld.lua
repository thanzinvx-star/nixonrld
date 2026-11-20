--[[
    WTRALD — Announcement
    Mesma UI (RayBeats Ultra, Dark Red). Mostra apenas um aviso com o botão Ok.
]]

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local Workspace        = game:GetService("Workspace")
local CoreGui          = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local GUI_NAME = "wtrald_announcement"

local Theme = {
    card    = Color3.fromRGB(26, 19, 20),
    stroke  = Color3.fromRGB(139, 0, 0),
    text    = Color3.fromRGB(255, 255, 255),
    accent  = Color3.fromRGB(139, 0, 0),
    accent2 = Color3.fromRGB(196, 30, 30),
}
local WHITE = Color3.new(1, 1, 1)

-- cleanup de execuções anteriores
for _, getParent in ipairs({
    function() return (gethui and gethui()) or CoreGui end,
    function() return LocalPlayer:FindFirstChildOfClass("PlayerGui") end,
}) do
    pcall(function()
        for _, c in ipairs(getParent():GetChildren()) do
            if c.Name == GUI_NAME then c:Destroy() end
        end
    end)
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
local function tween(obj, t, props, style, dir)
    local tw = TweenService:Create(obj, TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
end

local ScreenGui = create("ScreenGui", {
    Name = GUI_NAME, ResetOnSpawn = false, IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 1000,
})
do
    local ok = pcall(function() ScreenGui.Parent = (gethui and gethui()) or CoreGui end)
    if not ok or not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
end

-- fundo escurecido (bloqueia cliques atrás)
local overlay = create("Frame", {
    Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.45,
    BorderSizePixel = 0, Active = true, Parent = ScreenGui,
})

local win = create("Frame", {
    Name = "Window", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(400, 230), BackgroundColor3 = WHITE, BorderSizePixel = 0, Active = true,
    Parent = overlay,
}, {
    corner(20),
    create("UIGradient", { Color = ColorSequence.new(Color3.fromRGB(34, 8, 10), Color3.fromRGB(9, 8, 9)), Rotation = 125 }),
})
local winStroke = create("UIStroke", {
    Color = WHITE, Thickness = 2, Transparency = 0.1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = win,
})
local winGrad = create("UIGradient", { Color = ColorSequence.new(Theme.accent, Theme.accent2), Parent = winStroke })

local uiScale = create("UIScale", { Parent = win })
local function fitScale()
    local cam = Workspace.CurrentCamera
    if not cam then return 1 end
    local v = cam.ViewportSize
    return math.clamp(math.min(v.X / 440, v.Y / 280), 0.5, 1.15)
end
local function open()
    local s = fitScale()
    uiScale.Scale = s * 0.88
    tween(uiScale, 0.25, { Scale = s })
end
open()
if Workspace.CurrentCamera then
    Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        uiScale.Scale = fitScale()
    end)
end

-- título (centro)
create("TextLabel", {
    Text = "Announcement", Font = Enum.Font.GothamBlack, TextSize = 22, TextColor3 = WHITE,
    BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Center,
    Position = UDim2.fromOffset(0, 14), Size = UDim2.new(1, 0, 0, 30), Parent = win,
})

-- texto
local function col(text, c)
    return string.format('<font color="#%s">%s</font>', c:ToHex(), text)
end
local GREEN = Color3.fromRGB(82, 196, 128)
local BLUE  = Color3.fromRGB(60, 140, 255)
local GRAY  = Color3.fromRGB(150, 150, 150)

local body = col("This script no longer exists because ", WHITE)
    .. col("<b>Freeman</b>", GREEN)
    .. col(" deleted it from ", WHITE)
    .. col("<b>Roblox</b>", BLUE)
    .. col(". How about in the future? ", WHITE)
    .. col("(There won't be)", GRAY)
    .. col(".", WHITE)

local card = create("Frame", {
    Position = UDim2.fromOffset(16, 54), Size = UDim2.new(1, -32, 0, 106), BackgroundColor3 = Theme.card,
    BorderSizePixel = 0, Parent = win,
}, { corner(12), create("UIStroke", {
    Color = Theme.stroke, Thickness = 1, Transparency = 0.4, ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
}) })
create("TextLabel", {
    Text = body, RichText = true, TextWrapped = true, Font = Enum.Font.GothamMedium, TextSize = 15,
    TextColor3 = WHITE, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Center,
    TextYAlignment = Enum.TextYAlignment.Center, Position = UDim2.fromOffset(12, 8),
    Size = UDim2.new(1, -24, 1, -16), Parent = card,
})

-- botão Ok
local ok = create("TextButton", {
    Text = "OK", Font = Enum.Font.GothamBold, TextSize = 15, TextColor3 = WHITE,
    AutoButtonColor = false, AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -14),
    Size = UDim2.new(1, -32, 0, 40), BackgroundColor3 = Theme.accent, BorderSizePixel = 0, Parent = win,
}, { corner(10) })
ok.MouseButton1Down:Connect(function() tween(ok, 0.08, { BackgroundColor3 = Theme.accent2 }) end)
ok.MouseButton1Up:Connect(function() tween(ok, 0.22, { BackgroundColor3 = Theme.accent }) end)
ok.MouseLeave:Connect(function() tween(ok, 0.22, { BackgroundColor3 = Theme.accent }) end)

local kicked = false
ok.Activated:Connect(function()
    if kicked then return end
    kicked = true
    LocalPlayer:Kick("And don't come back here, dumbass.")
end)

-- borda animada
RunService.Heartbeat:Connect(function(dt)
    winGrad.Rotation = (winGrad.Rotation + dt * 50) % 360
end)
