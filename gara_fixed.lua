local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

if CoreGui:FindFirstChild("XenoPremiumV7") then 
    CoreGui.XenoPremiumV7:Destroy() 
end

_G.XBActive = true
Settings = {ESP = false, Respawn = false, Hitbox = false}
targetPlayerName = ""

local SG = Instance.new("ScreenGui")
SG.Name = "XenoPremiumV7"
SG.ResetOnSpawn = false
SG.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 240, 0, 410)
MainFrame.Position = UDim2.new(0.02, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 25, 45)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = SG

local MS = Instance.new("UIStroke")
MS.Thickness = 1.5
MS.Color = Color3.fromRGB(30, 80, 160)
MS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MS.Parent = MainFrame

local MC = Instance.new("UICorner")
MC.CornerRadius = UDim.new(0, 10)
MC.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 38)
Title.Text = "  XENO V7 | GAKURAN"
Title.TextColor3 = Color3.fromRGB(240, 245, 255)
Title.TextSize = 13
Title.Font = Enum.Font.RobotoMono
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundColor3 = Color3.fromRGB(25, 50, 95)
Title.BorderSizePixel = 0
Title.Parent = MainFrame

local TC = Instance.new("UICorner")
TC.CornerRadius = UDim.new(0, 10)
TC.Parent = Title

local HideText = Instance.new("TextLabel")
HideText.Size = UDim2.new(0, 100, 1, 0)
HideText.Position = UDim2.new(1, -110, 0, 0)
HideText.Text = "[ RightShift ]"
HideText.TextColor3 = Color3.fromRGB(150, 180, 230)
HideText.TextSize = 11
HideText.Font = Enum.Font.SourceSans
HideText.TextXAlignment = Enum.TextXAlignment.Right
HideText.BackgroundTransparency = 1
HideText.Parent = Title

local B1 = Instance.new("TextButton")
B1.Size = UDim2.new(0, 210, 0, 35)
B1.Position = UDim2.new(0, 15, 0, 50)
B1.Text = "ESP + Bars Radar: OFF"
B1.TextColor3 = Color3.fromRGB(255, 255, 255)
B1.BackgroundColor3 = Color3.fromRGB(205, 45, 45)
B1.Font = Enum.Font.SourceSansBold
B1.TextSize = 14
B1.Parent = MainFrame

local BC1 = Instance.new("UICorner")
BC1.CornerRadius = UDim.new(0, 6)
BC1.Parent = B1

local B2 = Instance.new("TextButton")
B2.Size = UDim2.new(0, 210, 0, 35)
B2.Position = UDim2.new(0, 15, 0, 95)
B2.Text = "Same Server Rejoin: OFF"
B2.TextColor3 = Color3.fromRGB(255, 255, 255)
B2.BackgroundColor3 = Color3.fromRGB(205, 45, 45)
B2.Font = Enum.Font.SourceSansBold
B2.TextSize = 14
B2.Parent = MainFrame

local BC2 = Instance.new("UICorner")
BC2.CornerRadius = UDim.new(0, 6)
BC2.Parent = B2

local B4 = Instance.new("TextButton")
B4.Size = UDim2.new(0, 210, 0, 35)
B4.Position = UDim2.new(0, 15, 0, 140)
B4.Text = "M1 Damage Assist: OFF"
B4.TextColor3 = Color3.fromRGB(255, 255, 255)
B4.BackgroundColor3 = Color3.fromRGB(205, 45, 45)
B4.Font = Enum.Font.SourceSansBold
B4.TextSize = 14
B4.Parent = MainFrame

local BC4 = Instance.new("UICorner")
BC4.CornerRadius = UDim.new(0, 6)
BC4.Parent = B4

DropContainer = Instance.new("ScrollingFrame")
DropContainer.Size = UDim2.new(0, 210, 0, 80)
DropContainer.Position = UDim2.new(0, 15, 0, 185)
DropContainer.BackgroundColor3 = Color3.fromRGB(25, 35, 60)
DropContainer.BorderSizePixel = 0
DropContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
DropContainer.ScrollBarThickness = 4
DropContainer.Parent = MainFrame

DropListLayout = Instance.new("UIListLayout")
DropListLayout.Padding = UDim.new(0, 4)
DropListLayout.Parent = DropContainer

local DropCorner = Instance.new("UICorner")
DropCorner.CornerRadius = UDim.new(0, 6)
DropCorner.Parent = DropContainer

local B5 = Instance.new("TextButton")
B5.Size = UDim2.new(0, 210, 0, 35)
B5.Position = UDim2.new(0, 15, 0, 275)
B5.Text = "⚡ Teleport Behind Target"
B5.TextColor3 = Color3.fromRGB(255, 255, 255)
B5.BackgroundColor3 = Color3.fromRGB(25, 100, 210)
B5.Font = Enum.Font.SourceSansBold
B5.TextSize = 14
B5.Parent = MainFrame

local BC5 = Instance.new("UICorner")
BC5.CornerRadius = UDim.new(0, 6)
BC5.Parent = B5

local B3 = Instance.new("TextButton")
B3.Size = UDim2.new(0, 210, 0, 35)
B3.Position = UDim2.new(0, 15, 0, 360)
B3.Text = "⛔ Unload Script"
B3.TextColor3 = Color3.fromRGB(255, 255, 255)
B3.BackgroundColor3 = Color3.fromRGB(45, 50, 60)
B3.Font = Enum.Font.SourceSansBold
B3.TextSize = 14
B3.Parent = MainFrame

local BC3 = Instance.new("UICorner")
BC3.CornerRadius = UDim.new(0, 6)
BC3.Parent = B3

-- [FIX #1] Helper function untuk mendapatkan Posture/Stamina value
local function getPostureValue(character)
    if not character then return 100 end
    
    local postureValue = character:FindFirstChild("Posture") or character:FindFirstChild("Stamina") or character:FindFirstChild("PostureValue")
    if postureValue and (postureValue:IsA("NumberValue") or postureValue:IsA("IntValue")) then
        return math.clamp(postureValue.Value, 0, 100)
    end
    
    local att = character:GetAttribute("Posture") or character:GetAttribute("Stamina")
    if att then return math.clamp(tonumber(att) or 100, 0, 100) end
    
    return 100
end

local function clear()
    for _, v in pairs(Workspace:GetChildren()) do
        if v:FindFirstChild("XESP") then v.XESP:Destroy() end
    end
    for _, v in pairs(Players:GetPlayers()) do
        if v.Character and v.Character:FindFirstChild("XESP") then v.Character.XESP:Destroy() end
    end
end

local function buatSelfHUD()
    if CoreGui:FindFirstChild("XenoSelfHUD") then return end
    local hudSG = Instance.new("ScreenGui")
    hudSG.Name = "XenoSelfHUD"
    hudSG.ResetOnSpawn = false
    hudSG.Parent = CoreGui

    local hudFrame = Instance.new("Frame")
    hudFrame.Name = "HUDFrame"
    hudFrame.Size = UDim2.new(0, 220, 0, 85)
    hudFrame.Position = UDim2.new(1, -235, 1, -100)
    hudFrame.BackgroundColor3 = Color3.fromRGB(15, 25, 45)
    hudFrame.BorderSizePixel = 0
    hudFrame.Parent = hudSG

    local hudCorner = Instance.new("UICorner")
    hudCorner.CornerRadius = UDim.new(0, 8)
    hudCorner.Parent = hudFrame

    local hudStroke = Instance.new("UIStroke")
    hudStroke.Thickness = 1.5
    hudStroke.Color = Color3.fromRGB(30, 80, 160)
    hudStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    hudStroke.Parent = hudFrame

    local hudTitle = Instance.new("TextLabel")
    hudTitle.Name = "HUDTitle"
    hudTitle.Size = UDim2.new(1, -20, 0, 25)
    hudTitle.Position = UDim2.new(0, 10, 0, 5)
    hudTitle.Text = "MY STATUS (SELF MONITOR)"
    hudTitle.TextColor3 = Color3.fromRGB(240, 245, 255)
    hudTitle.TextSize = 11
    hudTitle.Font = Enum.Font.RobotoMono
    hudTitle.TextXAlignment = Enum.TextXAlignment.Left
    hudTitle.BackgroundTransparency = 1
    hudTitle.Parent = hudFrame

    local hpBack = Instance.new("Frame")
    hpBack.Name = "HPBack"
    hpBack.Size = UDim2.new(1, -20, 0, 15)
    hpBack.Position = UDim2.new(0, 10, 0, 35)
    hpBack.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
    hpBack.BorderSizePixel = 0
    hpBack.Parent = hudFrame

    local hpBar = Instance.new("Frame")
    hpBar.Name = "HPBar"
    hpBar.Size = UDim2.new(0, 0, 1, 0)
    hpBar.BackgroundColor3 = Color3.fromRGB(45, 185, 45)
    hpBar.BorderSizePixel = 0
    hpBar.Parent = hpBack

    local hpText = Instance.new("TextLabel")
    hpText.Name = "HPText"
    hpText.Size = UDim2.new(1, 0, 1, 0)
    hpText.Text = "HP: 0/0 (0%)"
    hpText.TextColor3 = Color3.fromRGB(255, 255, 255)
    hpText.TextSize = 10
    hpText.Font = Enum.Font.SourceSansBold
    hpText.BackgroundTransparency = 1
    hpText.Parent = hpBack

    local stBack = Instance.new("Frame")
    stBack.Name = "STBack"
    stBack.Size = UDim2.new(1, -20, 0, 15)
    stBack.Position = UDim2.new(0, 10, 0, 55)
    stBack.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
    stBack.BorderSizePixel = 0
    stBack.Parent = hudFrame

    local stBar = Instance.new("Frame")
    stBar.Name = "STBar"
    stBar.Size = UDim2.new(0, 0, 1, 0)
    stBar.BackgroundColor3 = Color3.fromRGB(230, 160, 35)
    stBar.BorderSizePixel = 0
    stBar.Parent = stBack

    local stText = Instance.new("TextLabel")
    stText.Name = "STText"
    stText.Size = UDim2.new(1, 0, 1, 0)
    stText.Text = "POSTURE: 0 (0%)"
    stText.TextColor3 = Color3.fromRGB(255, 255, 255)
    stText.TextSize = 10
    stText.Font = Enum.Font.SourceSansBold
    stText.BackgroundTransparency = 1
    stText.Parent = stBack
end

local function updateSelfHUD()
    if not CoreGui:FindFirstChild("XenoSelfHUD") then return end
    local f = CoreGui.XenoSelfHUD:FindFirstChild("HUDFrame")
    if not f or not LocalPlayer.Character then return end
    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    local currentHP = math.clamp(hum.Health, 0, hum.MaxHealth)
    local maxHP = hum.MaxHealth
    local pctHP = maxHP > 0 and (currentHP / maxHP) or 0
    local hpPercent = math.floor(pctHP * 100)

    -- [FIX #1] Gunakan helper function
    local currentStamina = getPostureValue(LocalPlayer.Character)
    local pctST = currentStamina / 100
    local stPercent = math.floor(pctST * 100)

    f.HPBack.HPBar.Size = UDim2.new(pctHP, 0, 1, 0)
    f.HPBack.HPText.Text = "HP: " .. math.floor(currentHP) .. " / " .. math.floor(maxHP) .. " (" .. hpPercent .. "%)"
    f.STBack.STBar.Size = UDim2.new(pctST, 0, 1, 0)
    f.STBack.STText.Text = "POSTURE/STM: " .. math.floor(currentStamina) .. " (" .. stPercent .. "%)"
end

local function updateDropdown()
    for _, child in pairs(DropContainer:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -6, 0, 22)
            btn.Text = " " .. p.DisplayName .. " (@" .. p.Name .. ")"
            btn.TextColor3 = Color3.fromRGB(200, 220, 255)
            btn.BackgroundColor3 = Color3.fromRGB(35, 50, 85)
            btn.Font = Enum.Font.SourceSans
            btn.TextSize = 13
            btn.TextXAlignment = Enum.TextXAlignment.Left
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 4)
            btnCorner.Parent = btn
            
            if targetPlayerName == p.Name then
                btn.BackgroundColor3 = Color3.fromRGB(45, 125, 230)
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            end
            
            btn.MouseButton1Click:Connect(function()
                targetPlayerName = p.Name
                updateDropdown()
            end)
            btn.Parent = DropContainer
        end
    end
    DropContainer.CanvasSize = UDim2.new(0, 0, 0, DropListLayout.AbsoluteContentSize.Y)
end

B1.MouseButton1Click:Connect(function()
    if not _G.XBActive then return end
    Settings.ESP = not Settings.ESP
    B1.Text = Settings.ESP and "ESP + Bars Radar: ON" or "ESP + Bars Radar: OFF"
    B1.BackgroundColor3 = Settings.ESP and Color3.fromRGB(45, 185, 45) or Color3.fromRGB(205, 45, 45)
    if not Settings.ESP then clear() end
end)

local function rejoinSama()
    pcall(function()
        local ts = game:GetService("TeleportService")
        if #Players:GetPlayers() <= 1 then
            ts:Teleport(game.PlaceId, LocalPlayer)
        else
            ts:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end
    end)
end

B2.MouseButton1Click:Connect(function()
    if not _G.XBActive then return end
    Settings.Respawn = not Settings.Respawn
    B2.Text = Settings.Respawn and "Same Server Rejoin: ON" or "Same Server Rejoin: OFF"
    B2.BackgroundColor3 = Settings.Respawn and Color3.fromRGB(45, 185, 45) or Color3.fromRGB(205, 45, 45)
    if Settings.Respawn then rejoinSama() end
end)

B4.MouseButton1Click:Connect(function()
    if not _G.XBActive then return end
    Settings.Hitbox = not Settings.Hitbox
    B4.Text = Settings.Hitbox and "M1 Damage Assist: ON" or "M1 Damage Assist: OFF"
    B4.BackgroundColor3 = Settings.Hitbox and Color3.fromRGB(45, 185, 45) or Color3.fromRGB(205, 45, 45)
end)

B5.MouseButton1Click:Connect(function()
    if not _G.XBActive or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    if targetPlayerName ~= "" then
        local tPlr = Players:FindFirstChild(targetPlayerName)
        if tPlr and tPlr.Character and tPlr.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = tPlr.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
        end
    end
end)

UserInputService.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
        if CoreGui:FindFirstChild("XenoSelfHUD") and CoreGui.XenoSelfHUD:FindFirstChild("HUDFrame") then
            CoreGui.XenoSelfHUD.HUDFrame.Visible = MainFrame.Visible
        end
    end
end)

-- [FIX #4] Track ESP instances to avoid recreating every frame
local espCache = {}

local function esp(ch, npc)
    if not ch:FindFirstChild("HumanoidRootPart") or ch:FindFirstChild("XESP") then return end
    
    local f = Instance.new("Folder")
    f.Name = "XESP"
    f.Parent = ch
    
    local b = Instance.new("BillboardGui")
    b.AlwaysOnTop = true
    b.Size = UDim2.new(0, 140, 0, 55)
    b.MaxDistance = 350
    b.Adornee = ch:FindFirstChild("Head") or ch.HumanoidRootPart
    
    local titleL = Instance.new("TextLabel")
    titleL.Size = UDim2.new(1, 0, 0, 15)
    titleL.BackgroundTransparency = 1
    titleL.TextSize = 10
    titleL.Font = Enum.Font.RobotoMono
    titleL.TextColor3 = npc and Color3.fromRGB(255, 140, 140) or Color3.fromRGB(220, 235, 255)
    titleL.TextStrokeTransparency = 0.5
    titleL.Text = (npc and "[NPC] " or "") .. ch.Name
    titleL.Parent = b

    local hum = ch:FindFirstChildOfClass("Humanoid")
    local curHP = hum and hum.Health or 0
    local maxHP = hum and hum.MaxHealth or 100
    local pctHP = math.clamp(curHP / maxHP, 0, 1)
    local hpPercent = math.floor(pctHP * 100)

    local hpB = Instance.new("Frame")
    hpB.Name = "HPB"
    hpB.Size = UDim2.new(1, 0, 0, 10)
    hpB.Position = UDim2.new(0, 0, 0, 18)
    hpB.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
    hpB.BorderSizePixel = 0
    hpB.Parent = b

    local hpF = Instance.new("Frame")
    hpF.Size = UDim2.new(pctHP, 0, 1, 0)
    hpF.BackgroundColor3 = Color3.fromRGB(45, 185, 45)
    hpF.BorderSizePixel = 0
    hpF.Parent = hpB

    -- [FIX #2] Fixed: Use calculated hpPercent, not undefined variable
    local hpT = Instance.new("TextLabel")
    hpT.Size = UDim2.new(1, 0, 1, 0)
    hpT.BackgroundTransparency = 1
    hpT.TextSize = 9
    hpT.Font = Enum.Font.SourceSansBold
    hpT.TextColor3 = Color3.fromRGB(255, 255, 255)
    hpT.Text = "HP: " .. hpPercent .. "%"
    hpT.Parent = hpB

    -- [FIX #1] Use helper function for Posture
    local curST = getPostureValue(ch)
    local pctST = math.clamp(curST / 100, 0, 1)

    local stB = Instance.new("Frame")
    stB.Name = "STB"
    stB.Size = UDim2.new(1, 0, 0, 10)
    stB.Position = UDim2.new(0, 0, 0, 32)
    stB.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
    stB.BorderSizePixel = 0
    stB.Parent = b

    local stF = Instance.new("Frame")
    stF.Size = UDim2.new(pctST, 0, 1, 0)
    stF.BackgroundColor3 = Color3.fromRGB(230, 160, 35)
    stF.BorderSizePixel = 0
    stF.Parent = stB

    local stT = Instance.new("TextLabel")
    stT.Size = UDim2.new(1, 0, 1, 0)
    stT.BackgroundTransparency = 1
    stT.TextSize = 9
    stT.Font = Enum.Font.SourceSansBold
    stT.TextColor3 = Color3.fromRGB(255, 255, 255)
    stT.Text = "STM: " .. math.floor(pctST * 100) .. "%"
    stT.Parent = stB

    b.Parent = f
end

RunService.RenderStepped:Connect(function()
    if _G.XBActive and Settings.Hitbox and targetPlayerName ~= "" then
        local tPlr = Players:FindFirstChild(targetPlayerName)
        if tPlr and tPlr.Character and tPlr.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local myHRP = LocalPlayer.Character.HumanoidRootPart
            local tHRP = tPlr.Character.HumanoidRootPart
            local distance = (myHRP.Position - tHRP.Position).Magnitude
            if distance <= 18 then
                if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                    tHRP.CFrame = myHRP.CFrame * CFrame.new(0, 0, -2.5)
                end
            end
        end
    end
end)

task.spawn(function()
    buatSelfHUD()
    while task.wait(0.5) do
        if not _G.XBActive then break end
        updateDropdown()
        updateSelfHUD()
        if Settings.ESP and LocalPlayer.Character then
            clear()
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= LocalPlayer and v.Character then esp(v.Character, false) end
            end
            for _, v in pairs(Workspace:GetChildren()) do
                if v:IsA("Model") and v ~= LocalPlayer.Character and v:FindFirstChildOfClass("Humanoid") then esp(v, true) end
            end
        end
    end
end)

local function watch(ch)
    local hum = ch:WaitForChild("Humanoid", 10)
    if hum then
        hum.Died:Connect(function()
            if _G.XBActive and Settings.Respawn then
                task.wait(0.1)
                rejoinSama()
            end
        end)
    end
end

LocalPlayer.CharacterAdded:Connect(watch)
if LocalPlayer.Character then watch(LocalPlayer.Character) end

B3.MouseButton1Click:Connect(function()
    _G.XBActive = false
    clear()
    if CoreGui:FindFirstChild("XenoSelfHUD") then CoreGui.XenoSelfHUD:Destroy() end
    if SG then SG:Destroy() end
end)

updateDropdown()
