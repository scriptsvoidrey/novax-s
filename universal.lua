-- ============================================================
--  SCRIPT UNIVERSAL v1.0  |  ESP + Velocidad + Fly + NoClip
--  Compatible con cualquier ejecutor (Delta, Solara, etc.)
--  Funciona en CUALQUIER juego de Roblox
-- ============================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
while not player do task.wait() player = Players.LocalPlayer end

-- ---------- estados ----------
local espEnabled = false
local speedEnabled = false
local speedValue = 32
local flyEnabled = false
local noclipEnabled = false
local espBoxes = {}

-- ---------- helpers ----------
local function getChar() return player.Character or player.CharacterAdded:Wait() end
local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

-- ---------- ESP ----------
local function clearEsp()
    for _, b in pairs(espBoxes) do pcall(function() b:Destroy() end) end
    espBoxes = {}
end
local function makeEspFor(p)
    if p == player then return end
    if espBoxes[p] then return end
    local char = p.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local bg = Instance.new("BillboardGui")
    bg.Adornee = hrp
    bg.Size = UDim2.new(0, 120, 0, 35)
    bg.AlwaysOnTop = true
    bg.StudsOffset = Vector3.new(0, 2.5, 0)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = p.Name
    lbl.TextColor3 = Color3.fromRGB(255, 50, 50)
    lbl.TextStrokeTransparency = 0.4
    lbl.TextSize = 14
    lbl.Font = Enum.Font.GothamBold
    lbl.Parent = bg
    local box = Instance.new("BoxHandleAdornment")
    box.Adornee = hrp
    box.Size = Vector3.new(4, 6, 4)
    box.Color3 = Color3.fromRGB(255, 50, 50)
    box.Transparency = 0.5
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Parent = hrp
    bg.Parent = hrp
    espBoxes[p] = {bg = bg, box = box}
end
RunService.RenderStepped:Connect(function()
    if not espEnabled then clearEsp() return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            makeEspFor(p)
        end
    end
    for p, objs in pairs(espBoxes) do
        if not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function() objs.bg:Destroy() objs.box:Destroy() end)
            espBoxes[p] = nil
        end
    end
end)

-- ---------- Velocidad ----------
RunService.Stepped:Connect(function()
    local hum = getHum()
    if hum then
        hum.WalkSpeed = speedEnabled and speedValue or 16
    end
end)

-- ---------- Fly + NoClip ----------
local flySpeed = 50
local bodyGyro, bodyVel = nil, nil
local function startFly()
    local c = getChar()
    local hrp = c:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.P = 9e4
    bodyGyro.MaxTorque = Vector3.new(9e4, 9e4, 9e4)
    bodyGyro.CFrame = hrp.CFrame
    bodyGyro.Parent = hrp
    bodyVel = Instance.new("BodyVelocity")
    bodyVel.Velocity = Vector3.new(0, 0, 0)
    bodyVel.MaxForce = Vector3.new(9e4, 9e4, 9e4)
    bodyVel.Parent = hrp
end
local function stopFly()
    if bodyGyro then pcall(function() bodyGyro:Destroy() end) bodyGyro = nil end
    if bodyVel then pcall(function() bodyVel:Destroy() end) bodyVel = nil end
end
RunService.RenderStepped:Connect(function()
    if flyEnabled then
        if not bodyGyro then startFly() end
        local c = getChar()
        local hrp = c:FindFirstChild("HumanoidRootPart")
        local cam = workspace.CurrentCamera
        if hrp and bodyGyro and bodyVel and cam then
            bodyGyro.CFrame = cam.CFrame
            local m = Vector3.new(
                (UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.A) and 1 or 0),
                (UserInputService:IsKeyDown(Enum.KeyCode.Space) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and 1 or 0),
                (UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0)
            )
            bodyVel.Velocity = (cam.CFrame.LookVector * -m.Z + cam.CFrame.RightVector * m.X + Vector3.new(0, m.Y, 0)) * flySpeed
        end
    else
        stopFly()
    end
end)
RunService.Stepped:Connect(function()
    if noclipEnabled then
        local c = getChar()
        if c then
            for _, p in pairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end
end)

-- ---------- UI simple ----------
local gui = Instance.new("ScreenGui")
gui.Name = "UniversalHub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = game:GetService("CoreGui") or player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 220, 0, 260)
main.Position = UDim2.new(0, 20, 0, 20)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui
local corner = Instance.new("UICorner", main)
corner.CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(0, 150, 255)
stroke.Thickness = 1

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -10, 0, 30)
title.Position = UDim2.new(0, 5, 0, 4)
title.BackgroundTransparency = 1
title.Text = "SCRIPT UNIVERSAL"
title.TextColor3 = Color3.fromRGB(0, 200, 255)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.Parent = main

local function makeBtn(name, y, onClick)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -20, 0, 32)
    b.Position = UDim2.new(0, 10, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    b.Text = name .. " : OFF"
    b.TextColor3 = Color3.fromRGB(255, 80, 80)
    b.TextSize = 13
    b.Font = Enum.Font.GothamBold
    b.Parent = main
    local c = Instance.new("UICorner", b)
    c.CornerRadius = UDim.new(0, 6)
    local state = false
    b.MouseButton1Click:Connect(function()
        state = not state
        b.Text = name .. " : " .. (state and "ON" or "OFF")
        b.TextColor3 = state and Color3.fromRGB(80, 255, 120) or Color3.fromRGB(255, 80, 80)
        onClick(state)
    end)
    return b
end

makeBtn("ESP Jugadores", 40, function(v) espEnabled = v end)
makeBtn("Velocidad (x2)", 78, function(v) speedEnabled = v end)
makeBtn("Fly (WASD+Espacio)", 116, function(v) flyEnabled = v end)
makeBtn("NoClip", 154, function(v) noclipEnabled = v end)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(1, -20, 0, 32)
closeBtn.Position = UDim2.new(0, 10, 0, 192)
closeBtn.BackgroundColor3 = Color3.fromRGB(120, 30, 30)
closeBtn.Text = "Cerrar Menu (Insert)"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 13
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = main
local cc = Instance.new("UICorner", closeBtn)
cc.CornerRadius = UDim.new(0, 6)
closeBtn.MouseButton1Click:Connect(function() main.Visible = not main.Visible end)
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        main.Visible = not main.Visible
    end
end)

print("[Universal] Cargado correctamente. Tecla Insert para ocultar/mostrar el menu.")
