--[[
    XENO PREMIUM V7 - GAKURAN EXPLOIT
    Author: ahmadtatatata57-coder
    Version: 7.2 (Refactored & Optimized)
    
    Features:
    - ESP + Radar System
    - Combat System (Damage, Knockback, Combo)
    - Parry/Block System
    - Teleport System (Safe)
    - Anti-Ragdoll Stagger
    - Auto Respawn
    - Self HUD Monitor
]]

--============================================
-- SERVICES & BASIC SETUP
--============================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local PlayerCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

--============================================
-- CONSTANTS & CONFIG
--============================================
local CONFIG = {
    -- UI
    UI_NAME = "XenoPremiumV7",
    UI_HIDE_KEY = Enum.KeyCode.RightShift,
    
    -- ESP
    ESP_MAX_DISTANCE = 350,
    ESP_UPDATE_RATE = 0.5,
    
    -- Combat
    LIGHT_DAMAGE = {min = 5, max = 19},
    HEAVY_DAMAGE = {min = 20, max = 50},
    LIGHT_KNOCKBACK = 0.3,
    HEAVY_KNOCKBACK = 0.8,
    HIT_DISTANCE = 18,
    
    -- Teleport
    TELEPORT_OFFSET = 3,
    MAX_TELEPORT_DISTANCE = 500,
    
    -- Colors
    COLOR_PRIMARY = Color3.fromRGB(15, 25, 45),
    COLOR_ACCENT = Color3.fromRGB(25, 50, 95),
    COLOR_BORDER = Color3.fromRGB(30, 80, 160),
    COLOR_TEXT = Color3.fromRGB(240, 245, 255),
    COLOR_GREEN = Color3.fromRGB(45, 185, 45),
    COLOR_RED = Color3.fromRGB(205, 45, 45),
    COLOR_BLUE = Color3.fromRGB(25, 100, 210),
    COLOR_DARK = Color3.fromRGB(45, 50, 60),
    COLOR_HP_GREEN = Color3.fromRGB(45, 185, 45),
    COLOR_STAMINA_ORANGE = Color3.fromRGB(230, 160, 35),
}

--============================================
-- CORE MODULE - XenoCore
--============================================
local XenoCore = {
    isActive = true,
    settings = {
        ESP = false,
        Respawn = false,
        Hitbox = false,
        ParrySystem = false,
        CombatSystem = false,
    },
    targetPlayer = {
        name = "",
        instance = nil,
    },
    connections = {},
    espCache = {},
    uiElements = {},
}

--[[
    Connect event with auto cleanup
]]
function XenoCore:connect(signal, callback)
    if not signal then return nil end
    local conn = signal:Connect(callback)
    table.insert(self.connections, conn)
    return conn
end

--[[
    Disconnect all events
]]
function XenoCore:disconnectAll()
    for _, conn in pairs(self.connections) do
        if conn then pcall(function() conn:Disconnect() end) end
    end
    self.connections = {}
end

--[[
    Safe character check
]]
function XenoCore:getCharacter(player)
    if not player or not player.Character then return nil end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return nil end
    return player.Character, hrp, humanoid
end

--[[
    Get stamina/posture value
]]
function XenoCore:getStamina(character)
    if not character then return 100 end
    
    local postureValue = character:FindFirstChild("Posture") 
        or character:FindFirstChild("Stamina") 
        or character:FindFirstChild("PostureValue")
    
    if postureValue and (postureValue:IsA("NumberValue") or postureValue:IsA("IntValue")) then
        return math.clamp(postureValue.Value, 0, 100)
    end
    
    local att = character:GetAttribute("Posture") or character:GetAttribute("Stamina")
    if att then return math.clamp(att, 0, 100) end
    
    return 100
end

--============================================
-- COMBAT MODULE
--============================================
local CombatSystem = {
    lightDamage = CONFIG.LIGHT_DAMAGE,
    heavyDamage = CONFIG.HEAVY_DAMAGE,
    lightKnockback = CONFIG.LIGHT_KNOCKBACK,
    heavyKnockback = CONFIG.HEAVY_KNOCKBACK,
    comboCount = 0,
    lastComboTime = 0,
    comboTimeout = 1.5,
}

--[[
    Apply damage to target
]]
function CombatSystem:dealDamage(target, isHeavy)
    if not target or not target:IsDescendantOf(Workspace) then return false end
    
    local success, err = pcall(function()
        local humanoid = target:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then return end
        
        local config = isHeavy and self.heavyDamage or self.lightDamage
        local damage = math.random(config.min, config.max)
        
        humanoid:TakeDamage(damage)
        self:applyKnockback(target, isHeavy)
        self:executeCombo()
    end)
    
    if not success then
        warn("[CombatSystem] Damage Error: " .. tostring(err))
        return false
    end
    
    return true
end

--[[
    Apply knockback physics
]]
function CombatSystem:applyKnockback(target, isHeavy)
    local hrp = target:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local force = isHeavy and self.heavyKnockback or self.lightKnockback
    local knockbackVector = hrp.CFrame.LookVector * -force * 10
    
    hrp.Velocity = hrp.Velocity + knockbackVector
end

--[[
    Execute combo system
]]
function CombatSystem:executeCombo()
    if tick() - self.lastComboTime > self.comboTimeout then
        self.comboCount = 0
    end
    
    self.comboCount = self.comboCount + 1
    self.lastComboTime = tick()
    
    if self.comboCount >= 3 then
        self:triggerSpecialAttack()
        self.comboCount = 0
    end
end

--[[
    Trigger special attack (combo finisher)
]]
function CombatSystem:triggerSpecialAttack()
    local char = LocalPlayer.Character
    if not char then return end
    
    local targetChar = XenoCore.targetPlayer.instance
    if not targetChar then return end
    
    -- Deal heavy damage + extra knockback
    self:dealDamage(targetChar, true)
end

--============================================
-- PARRY SYSTEM MODULE
--============================================
local ParrySystem = {
    isBlocking = false,
    blockStartTime = 0,
    blockDuration = 0.8,
    blockCooldown = 1.5,
    lastBlockTime = 0,
    parrySuccessRange = 0.3, -- 300ms window
}

--[[
    Start blocking
]]
function ParrySystem:startBlock()
    if tick() - self.lastBlockTime < self.blockCooldown then return false end
    
    self.isBlocking = true
    self.blockStartTime = tick()
    return true
end

--[[
    End blocking
]]
function ParrySystem:endBlock()
    self.isBlocking = false
    self.lastBlockTime = tick()
end

--[[
    Check if parry is active
]]
function ParrySystem:isParryActive()
    if not self.isBlocking then return false end
    local duration = tick() - self.blockStartTime
    return duration <= self.parrySuccessRange
end

--============================================
-- ANTI-RAGDOLL MODULE
--============================================
local AntiRagdoll = {
    staggerDuration = 0.5,
    staggerCooldown = 2.0,
    lastStaggerTime = 0,
}

--[[
    Apply stagger effect
]]
function AntiRagdoll:applyStagger(character, isHeavy)
    if not character then return end
    
    if tick() - self.lastStaggerTime < self.staggerCooldown then
        return
    end
    
    local success, err = pcall(function()
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then return end
        
        humanoid:ChangeState(Enum.HumanoidStateType.Knockdown)
        self.lastStaggerTime = tick()
        
        task.wait(self.staggerDuration)
        
        if humanoid and humanoid.Health > 0 then
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end
    end)
    
    if not success then
        warn("[AntiRagdoll] Stagger Error: " .. tostring(err))
    end
end

--============================================
-- UI MODULE
--============================================
local UIManager = {}

--[[
    Create main UI
]]
function UIManager:createMainUI()
    if CoreGui:FindFirstChild(CONFIG.UI_NAME) then
        CoreGui[CONFIG.UI_NAME]:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = CONFIG.UI_NAME
    screenGui.ResetOnSpawn = false
    screenGui.Parent = CoreGui
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 240, 0, 450)
    mainFrame.Position = UDim2.new(0.02, 0, 0.25, 0)
    mainFrame.BackgroundColor3 = CONFIG.COLOR_PRIMARY
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    
    -- Border
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.5
    stroke.Color = CONFIG.COLOR_BORDER
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = mainFrame
    
    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = mainFrame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 38)
    title.Text = "  XENO V7.2 | GAKURAN"
    title.TextColor3 = CONFIG.COLOR_TEXT
    title.TextSize = 13
    title.Font = Enum.Font.RobotoMono
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundColor3 = CONFIG.COLOR_ACCENT
    title.BorderSizePixel = 0
    title.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = title
    
    local hideText = Instance.new("TextLabel")
    hideText.Size = UDim2.new(0, 100, 1, 0)
    hideText.Position = UDim2.new(1, -110, 0, 0)
    hideText.Text = "[ RightShift ]"
    hideText.TextColor3 = Color3.fromRGB(150, 180, 230)
    hideText.TextSize = 11
    hideText.Font = Enum.Font.SourceSans
    hideText.TextXAlignment = Enum.TextXAlignment.Right
    hideText.BackgroundTransparency = 1
    hideText.Parent = title
    
    XenoCore.uiElements.mainFrame = mainFrame
    XenoCore.uiElements.screenGui = screenGui
    
    return mainFrame
end

--[[
    Create button with styling
]]
function UIManager:createButton(parent, text, position, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 210, 0, 35)
    btn.Position = position
    btn.Text = text
    btn.TextColor3 = CONFIG.COLOR_TEXT
    btn.BackgroundColor3 = color
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.Parent = parent
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    if callback then
        btn.MouseButton1Click:Connect(callback)
    end
    
    return btn
end

--[[
    Setup all buttons
]]
function UIManager:setupButtons(mainFrame)
    -- ESP Button
    local b1 = self:createButton(mainFrame, "ESP + Bars Radar: OFF", UDim2.new(0, 15, 0, 50), CONFIG.COLOR_RED, function()
        if not XenoCore.isActive then return end
        XenoCore.settings.ESP = not XenoCore.settings.ESP
        b1.Text = XenoCore.settings.ESP and "ESP + Bars Radar: ON" or "ESP + Bars Radar: OFF"
        b1.BackgroundColor3 = XenoCore.settings.ESP and CONFIG.COLOR_GREEN or CONFIG.COLOR_RED
        if not XenoCore.settings.ESP then self:clearESP() end
    end)
    
    -- Respawn Button
    local b2 = self:createButton(mainFrame, "Same Server Rejoin: OFF", UDim2.new(0, 15, 0, 95), CONFIG.COLOR_RED, function()
        if not XenoCore.isActive then return end
        XenoCore.settings.Respawn = not XenoCore.settings.Respawn
        b2.Text = XenoCore.settings.Respawn and "Same Server Rejoin: ON" or "Same Server Rejoin: OFF"
        b2.BackgroundColor3 = XenoCore.settings.Respawn and CONFIG.COLOR_GREEN or CONFIG.COLOR_RED
    end)
    
    -- Combat Button
    local b4 = self:createButton(mainFrame, "Combat System: OFF", UDim2.new(0, 15, 0, 140), CONFIG.COLOR_RED, function()
        if not XenoCore.isActive then return end
        XenoCore.settings.Hitbox = not XenoCore.settings.Hitbox
        b4.Text = XenoCore.settings.Hitbox and "Combat System: ON" or "Combat System: OFF"
        b4.BackgroundColor3 = XenoCore.settings.Hitbox and CONFIG.COLOR_GREEN or CONFIG.COLOR_RED
    end)
    
    -- Parry Button
    local b5 = self:createButton(mainFrame, "Parry System: OFF", UDim2.new(0, 15, 0, 185), CONFIG.COLOR_RED, function()
        if not XenoCore.isActive then return end
        XenoCore.settings.ParrySystem = not XenoCore.settings.ParrySystem
        b5.Text = XenoCore.settings.ParrySystem and "Parry System: ON" or "Parry System: OFF"
        b5.BackgroundColor3 = XenoCore.settings.ParrySystem and CONFIG.COLOR_GREEN or CONFIG.COLOR_RED
    end)
    
    -- Teleport Button
    local b6 = self:createButton(mainFrame, "⚡ Teleport Behind Target", UDim2.new(0, 15, 0, 275), CONFIG.COLOR_BLUE, function()
        if not XenoCore.isActive or not LocalPlayer.Character then return end
        if XenoCore.targetPlayer.name ~= "" then
            self:teleportToTarget()
        end
    end)
    
    -- Unload Button
    local b7 = self:createButton(mainFrame, "⛔ Unload Script", UDim2.new(0, 15, 0, 360), CONFIG.COLOR_DARK, function()
        self:unloadScript()
    end)
    
    XenoCore.uiElements.buttons = {
        esp = b1,
        respawn = b2,
        combat = b4,
        parry = b5,
        teleport = b6,
        unload = b7,
    }
end

--[[
    Create player dropdown
]]
function UIManager:createDropdown(mainFrame)
    local dropContainer = Instance.new("ScrollingFrame")
    dropContainer.Size = UDim2.new(0, 210, 0, 80)
    dropContainer.Position = UDim2.new(0, 15, 0, 230)
    dropContainer.BackgroundColor3 = CONFIG.COLOR_ACCENT
    dropContainer.BorderSizePixel = 0
    dropContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    dropContainer.ScrollBarThickness = 4
    dropContainer.Parent = mainFrame
    
    local dropLayout = Instance.new("UIListLayout")
    dropLayout.Padding = UDim.new(0, 4)
    dropLayout.Parent = dropContainer
    
    local dropCorner = Instance.new("UICorner")
    dropCorner.CornerRadius = UDim.new(0, 6)
    dropCorner.Parent = dropContainer
    
    XenoCore.uiElements.dropContainer = dropContainer
    XenoCore.uiElements.dropLayout = dropLayout
    
    self:updateDropdown()
end

--[[
    Update player dropdown
]]
function UIManager:updateDropdown()
    local container = XenoCore.uiElements.dropContainer
    if not container then return end
    
    for _, child in pairs(container:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -6, 0, 22)
            btn.Text = " " .. player.DisplayName .. " (@" .. player.Name .. ")"
            btn.TextColor3 = Color3.fromRGB(200, 220, 255)
            btn.BackgroundColor3 = Color3.fromRGB(35, 50, 85)
            btn.Font = Enum.Font.SourceSans
            btn.TextSize = 13
            btn.TextXAlignment = Enum.TextXAlignment.Left
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 4)
            btnCorner.Parent = btn
            
            if XenoCore.targetPlayer.name == player.Name then
                btn.BackgroundColor3 = Color3.fromRGB(45, 125, 230)
                btn.TextColor3 = CONFIG.COLOR_TEXT
            end
            
            btn.MouseButton1Click:Connect(function()
                XenoCore.targetPlayer.name = player.Name
                XenoCore.targetPlayer.instance = player.Character
                self:updateDropdown()
            end)
            
            btn.Parent = container
        end
    end
    
    container.CanvasSize = UDim2.new(0, 0, 0, XenoCore.uiElements.dropLayout.AbsoluteContentSize.Y)
end

--[[
    Create self HUD
]]
function UIManager:createSelfHUD()
    if CoreGui:FindFirstChild("XenoSelfHUD") then return end
    
    local hudSG = Instance.new("ScreenGui")
    hudSG.Name = "XenoSelfHUD"
    hudSG.ResetOnSpawn = false
    hudSG.Parent = CoreGui
    
    local hudFrame = Instance.new("Frame")
    hudFrame.Name = "HUDFrame"
    hudFrame.Size = UDim2.new(0, 220, 0, 85)
    hudFrame.Position = UDim2.new(1, -235, 1, -100)
    hudFrame.BackgroundColor3 = CONFIG.COLOR_PRIMARY
    hudFrame.BorderSizePixel = 0
    hudFrame.Parent = hudSG
    
    local hudCorner = Instance.new("UICorner")
    hudCorner.CornerRadius = UDim.new(0, 8)
    hudCorner.Parent = hudFrame
    
    local hudStroke = Instance.new("UIStroke")
    hudStroke.Thickness = 1.5
    hudStroke.Color = CONFIG.COLOR_BORDER
    hudStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    hudStroke.Parent = hudFrame
    
    local hudTitle = Instance.new("TextLabel")
    hudTitle.Name = "HUDTitle"
    hudTitle.Size = UDim2.new(1, -20, 0, 25)
    hudTitle.Position = UDim2.new(0, 10, 0, 5)
    hudTitle.Text = "MY STATUS (SELF MONITOR)"
    hudTitle.TextColor3 = CONFIG.COLOR_TEXT
    hudTitle.TextSize = 11
    hudTitle.Font = Enum.Font.RobotoMono
    hudTitle.TextXAlignment = Enum.TextXAlignment.Left
    hudTitle.BackgroundTransparency = 1
    hudTitle.Parent = hudFrame
    
    -- HP Bar
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
    hpBar.BackgroundColor3 = CONFIG.COLOR_HP_GREEN
    hpBar.BorderSizePixel = 0
    hpBar.Parent = hpBack
    
    local hpText = Instance.new("TextLabel")
    hpText.Name = "HPText"
    hpText.Size = UDim2.new(1, 0, 1, 0)
    hpText.Text = "HP: 0/0 (0%)"
    hpText.TextColor3 = CONFIG.COLOR_TEXT
    hpText.TextSize = 10
    hpText.Font = Enum.Font.SourceSansBold
    hpText.BackgroundTransparency = 1
    hpText.Parent = hpBack
    
    -- Stamina Bar
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
    stBar.BackgroundColor3 = CONFIG.COLOR_STAMINA_ORANGE
    stBar.BorderSizePixel = 0
    stBar.Parent = stBack
    
    local stText = Instance.new("TextLabel")
    stText.Name = "STText"
    stText.Size = UDim2.new(1, 0, 1, 0)
    stText.Text = "POSTURE: 0 (0%)"
    stText.TextColor3 = CONFIG.COLOR_TEXT
    stText.TextSize = 10
    stText.Font = Enum.Font.SourceSansBold
    stText.BackgroundTransparency = 1
    stText.Parent = stBack
    
    XenoCore.uiElements.selfHUD = hudFrame
end

--[[
    Update self HUD
]]
function UIManager:updateSelfHUD()
    local hudFrame = XenoCore.uiElements.selfHUD
    if not hudFrame or not LocalPlayer.Character then return end
    
    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    local currentHP = math.clamp(hum.Health, 0, hum.MaxHealth)
    local maxHP = hum.MaxHealth
    local pctHP = maxHP > 0 and (currentHP / maxHP) or 0
    local hpPercent = math.floor(pctHP * 100)
    
    local currentStamina = XenoCore:getStamina(LocalPlayer.Character)
    local pctST = currentStamina / 100
    local stPercent = math.floor(pctST * 100)
    
    hudFrame.HPBack.HPBar.Size = UDim2.new(pctHP, 0, 1, 0)
    hudFrame.HPBack.HPText.Text = "HP: " .. math.floor(currentHP) .. " / " .. math.floor(maxHP) .. " (" .. hpPercent .. "%)"
    hudFrame.STBack.STBar.Size = UDim2.new(pctST, 0, 1, 0)
    hudFrame.STBack.STText.Text = "POSTURE/STM: " .. math.floor(currentStamina) .. " (" .. stPercent .. "%)"
end

--[[
    Clear ESP
]]
function UIManager:clearESP()
    for _, v in pairs(Workspace:GetChildren()) do
        local esp = v:FindFirstChild("XESP")
        if esp then pcall(function() esp:Destroy() end) end
    end
    
    for _, v in pairs(Players:GetPlayers()) do
        if v.Character then
            local esp = v.Character:FindFirstChild("XESP")
            if esp then pcall(function() esp:Destroy() end) end
        end
    end
    
    XenoCore.espCache = {}
end

--[[
    Teleport to target
]]
function UIManager:teleportToTarget()
    local char, hrp = LocalPlayer.Character
    if not hrp then hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart") end
    if not hrp or not XenoCore.targetPlayer.instance then return end
    
    local targetChar = XenoCore.targetPlayer.instance
    local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetHRP then return end
    
    -- Safety check: distance validation
    local distance = (hrp.Position - targetHRP.Position).Magnitude
    if distance > CONFIG.MAX_TELEPORT_DISTANCE then
        warn("Target terlalu jauh! Jarak: " .. math.floor(distance) .. " stud")
        return
    end
    
    -- Safe teleport
    local success, err = pcall(function()
        hrp.CFrame = targetHRP.CFrame * CFrame.new(0, 0, CONFIG.TELEPORT_OFFSET)
    end)
    
    if not success then
        warn("[Teleport] Error: " .. tostring(err))
    end
end

--[[
    Unload script
]]
function UIManager:unloadScript()
    XenoCore.isActive = false
    self:clearESP()
    XenoCore:disconnectAll()
    
    if CoreGui:FindFirstChild("XenoSelfHUD") then
        CoreGui.XenoSelfHUD:Destroy()
    end
    
    if XenoCore.uiElements.screenGui then
        XenoCore.uiElements.screenGui:Destroy()
    end
end

--============================================
-- ESP MODULE
--============================================
local ESPSystem = {}

--[[
    Create ESP for character
]]
function ESPSystem:createESP(character, isNPC)
    if not character or not character:IsDescendantOf(Workspace) then return end
    if character:FindFirstChild("XESP") then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local success, err = pcall(function()
        local espFolder = Instance.new("Folder")
        espFolder.Name = "XESP"
        espFolder.Parent = character
        
        local billboard = Instance.new("BillboardGui")
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(0, 140, 0, 55)
        billboard.MaxDistance = CONFIG.ESP_MAX_DISTANCE
        billboard.Adornee = character:FindFirstChild("Head") or hrp
        
        -- Name Label
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, 0, 0, 15)
        titleLabel.BackgroundTransparency = 1
        titleLabel.TextSize = 10
        titleLabel.Font = Enum.Font.RobotoMono
        titleLabel.TextColor3 = isNPC and Color3.fromRGB(255, 140, 140) or Color3.fromRGB(220, 235, 255)
        titleLabel.TextStrokeTransparency = 0.5
        titleLabel.Text = (isNPC and "[NPC] " or "") .. character.Name
        titleLabel.Parent = billboard
        
        -- HP Bar Background
        local hpBack = Instance.new("Frame")
        hpBack.Name = "HPB"
        hpBack.Size = UDim2.new(1, 0, 0, 10)
        hpBack.Position = UDim2.new(0, 0, 0, 18)
        hpBack.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
        hpBack.BorderSizePixel = 0
        hpBack.Parent = billboard
        
        -- HP Bar Fill
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local curHP = humanoid and humanoid.Health or 0
        local maxHP = humanoid and humanoid.MaxHealth or 100
        local pctHP = math.clamp(curHP / maxHP, 0, 1)
        
        local hpFill = Instance.new("Frame")
        hpFill.Size = UDim2.new(pctHP, 0, 1, 0)
        hpFill.BackgroundColor3 = CONFIG.COLOR_HP_GREEN
        hpFill.BorderSizePixel = 0
        hpFill.Parent = hpBack
        
        -- HP Text
        local hpText = Instance.new("TextLabel")
        hpText.Size = UDim2.new(1, 0, 1, 0)
        hpText.BackgroundTransparency = 1
        hpText.TextSize = 9
        hpText.Font = Enum.Font.SourceSansBold
        hpText.TextColor3 = CONFIG.COLOR_TEXT
        hpText.Text = "HP: " .. math.floor(pctHP * 100) .. "%"
        hpText.Parent = hpBack
        
        -- Stamina Bar Background
        local stBack = Instance.new("Frame")
        stBack.Name = "STB"
        stBack.Size = UDim2.new(1, 0, 0, 10)
        stBack.Position = UDim2.new(0, 0, 0, 32)
        stBack.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
        stBack.BorderSizePixel = 0
        stBack.Parent = billboard
        
        -- Stamina Bar Fill
        local curST = XenoCore:getStamina(character)
        local pctST = math.clamp(curST / 100, 0, 1)
        
        local stFill = Instance.new("Frame")
        stFill.Size = UDim2.new(pctST, 0, 1, 0)
        stFill.BackgroundColor3 = CONFIG.COLOR_STAMINA_ORANGE
        stFill.BorderSizePixel = 0
        stFill.Parent = stBack
        
        -- Stamina Text
        local stText = Instance.new("TextLabel")
        stText.Size = UDim2.new(1, 0, 1, 0)
        stText.BackgroundTransparency = 1
        stText.TextSize = 9
        stText.Font = Enum.Font.SourceSansBold
        stText.TextColor3 = CONFIG.COLOR_TEXT
        stText.Text = "STM: " .. math.floor(pctST * 100) .. "%"
        stText.Parent = stBack
        
        billboard.Parent = espFolder
        XenoCore.espCache[character] = true
    end)
    
    if not success then
        warn("[ESP] Error creating ESP for " .. character.Name .. ": " .. tostring(err))
    end
end

--[[
    Update all ESP
]]
function ESPSystem:updateESP()
    if not XenoCore.isActive or not XenoCore.settings.ESP or not LocalPlayer.Character then
        return
    end
    
    self:clearESP()
    
    -- Player ESP
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            self:createESP(player.Character, false)
        end
    end
    
    -- NPC ESP
    for _, model in pairs(Workspace:GetChildren()) do
        if model:IsA("Model") and model ~= LocalPlayer.Character and model:FindFirstChildOfClass("Humanoid") then
            self:createESP(model, true)
        end
    end
end

function ESPSystem:clearESP()
    for _, v in pairs(Workspace:GetChildren()) do
        local esp = v:FindFirstChild("XESP")
        if esp then pcall(function() esp:Destroy() end) end
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local esp = player.Character:FindFirstChild("XESP")
            if esp then pcall(function() esp:Destroy() end) end
        end
    end
    
    XenoCore.espCache = {}
end

--============================================
-- RESPAWN MODULE
--============================================
local RespawnSystem = {}

--[[
    Rejoin same server
]]
function RespawnSystem:rejoinSameServer()
    local success, err = pcall(function()
        if #Players:GetPlayers() <= 1 then
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        else
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end
    end)
    
    if not success then
        warn("[RespawnSystem] Rejoin Error: " .. tostring(err))
    end
end

--[[
    Watch character death
]]
function RespawnSystem:watchCharacter(character)
    local humanoid = character:WaitForChild("Humanoid", 10)
    if not humanoid then return end
    
    XenoCore:connect(humanoid.Died, function()
        if XenoCore.isActive and XenoCore.settings.Respawn then
            task.wait(0.1)
            self:rejoinSameServer()
        end
    end)
end

--============================================
-- INPUT HANDLER
--============================================
local InputHandler = {}

--[[
    Setup keyboard shortcuts
]]
function InputHandler:setup()
    -- Hide/Show UI
    XenoCore:connect(UserInputService.InputBegan, function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == CONFIG.UI_HIDE_KEY then
            local mainFrame = XenoCore.uiElements.mainFrame
            if mainFrame then
                mainFrame.Visible = not mainFrame.Visible
                if CoreGui:FindFirstChild("XenoSelfHUD") and CoreGui.XenoSelfHUD:FindFirstChild("HUDFrame") then
                    CoreGui.XenoSelfHUD.HUDFrame.Visible = mainFrame.Visible
                end
            end
        end
    end)
    
    -- Combat hitbox system
    XenoCore:connect(RunService.RenderStepped, function()
        if not XenoCore.isActive or not XenoCore.settings.Hitbox then return end
        if not LocalPlayer.Character then return end
        
        local targetChar = XenoCore.targetPlayer.instance
        if not targetChar or not targetChar:IsDescendantOf(Workspace) then return end
        
        local char, myHRP, myHum = XenoCore:getCharacter(LocalPlayer)
        if not char or not myHRP or not myHum then return end
        
        local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
        if not targetHRP then return end
        
        local distance = (myHRP.Position - targetHRP.Position).Magnitude
        
        if distance <= CONFIG.HIT_DISTANCE then
            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                local isHeavy = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
                CombatSystem:dealDamage(targetChar, isHeavy)
                AntiRagdoll:applyStagger(targetChar, isHeavy)
            end
        end
    end)
end

--============================================
-- MAIN LOOP
--============================================
local MainLoop = {}

--[[
    Start main update loop
]]
function MainLoop:start()
    task.spawn(function()
        UIManager:createSelfHUD()
        
        while task.wait(CONFIG.ESP_UPDATE_RATE) do
            if not XenoCore.isActive then break end
            
            pcall(function()
                UIManager:updateDropdown()
                UIManager:updateSelfHUD()
                ESPSystem:updateESP()
            end)
        end
    end)
end

--============================================
-- INITIALIZATION
--============================================
local function initialize()
    -- Create UI
    local mainFrame = UIManager:createMainUI()
    UIManager:setupButtons(mainFrame)
    UIManager:createDropdown(mainFrame)
    
    -- Setup input
    InputHandler:setup()
    
    -- Setup respawn watching
    RespawnSystem:watchCharacter(LocalPlayer.Character)
    XenoCore:connect(LocalPlayer.CharacterAdded, function(character)
        RespawnSystem:watchCharacter(character)
    end)
    
    -- Start main loop
    MainLoop:start()
end

-- Run initialization
pcall(initialize)

print("[XENO V7.2] Script loaded successfully! Press RightShift to toggle UI")
