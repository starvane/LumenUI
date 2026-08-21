--[[
    ════════════════════════════════════════════════════════════════
    [CORE] Violence District — Ultimate Hybrid Script
    ════════════════════════════════════════════════════════════════

    Foundation: CURE (architecture, event-driven, cleanup)
    UI Layer:   LumenUI (config persistence, icons, notifications)
    Features:   ESP | Auto Parry | Auto Generator | Crosshair
                + Hybrid components from other scripts

    Designed for: maintainability, extensibility, clean separation
    ════════════════════════════════════════════════════════════════
--]]

-- ─────────────────────────────────────────────────────────────────────
-- 1. GLOBAL CLEANUP SYSTEM (prevents duplicate runs & leaks)
-- ─────────────────────────────────────────────────────────────────────
if _G.UC_Cleanup then
    pcall(_G.UC_Cleanup)
end

local Connections = {}
local Cleanups = {}
local _G.UC_Cleanup = function()
    for _, conn in ipairs(Connections) do
        if conn and conn.Disconnect then
            pcall(function() conn:Disconnect() end)
        end
    end
    for _, cleanup in ipairs(Cleanups) do
        pcall(cleanup)
    end
    Connections = {}
    Cleanups = {}
    print("[UC] Cleanup complete.")
end

local function regConn(conn)
    table.insert(Connections, conn)
    return conn
end

local function regCleanup(fn)
    table.insert(Cleanups, fn)
    return fn
end

-- ─────────────────────────────────────────────────────────────────────
-- 2. SERVICES
-- ─────────────────────────────────────────────────────────────────────
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

-- ─────────────────────────────────────────────────────────────────────
-- 3. REMOTE ACQUISITION (generalized)
-- ─────────────────────────────────────────────────────────────────────
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)

local function waitRemote(parent, name, timeout)
    timeout = timeout or 5
    if not parent then return nil end
    local ok, obj = pcall(function() return parent:WaitForChild(name, timeout) end)
    return ok and obj or nil
end

-- Generator
local GenRemotes = waitRemote(Remotes, "Generator")
local SkillCheckEvent = GenRemotes and waitRemote(GenRemotes, "SkillCheckEvent")
local SkillCheckResult = GenRemotes and waitRemote(GenRemotes, "SkillCheckResultEvent")

-- KillerPerks (King's Scourge)
local KPRemotes = waitRemote(Remotes, "KillerPerks")
local KSRemotes = KPRemotes and waitRemote(KPRemotes, "kingscourge")
local KingScourgeStart = KSRemotes and waitRemote(KSRemotes, "KingScourgeStart")
local KingScourgeHit = KSRemotes and waitRemote(KSRemotes, "KingScourgeHit")

-- Items (Parrying Dagger)
local ItemRemotes = waitRemote(Remotes, "Items")
local DaggerFolder = ItemRemotes and waitRemote(ItemRemotes, "Parrying Dagger")
local ParryEvent = DaggerFolder and waitRemote(DaggerFolder, "parry")
local ParryResult = DaggerFolder and waitRemote(DaggerFolder, "parryResult")

-- Attacks (BasicAttack for hitbox detection)
local AttacksFolder = waitRemote(Remotes, "Attacks")
local BasicAttack = AttacksFolder and waitRemote(AttacksFolder, "BasicAttack")

-- ─────────────────────────────────────────────────────────────────────
-- 4. CONFIGURATION (extended Cfg table, will be synced with LumenUI)
-- ─────────────────────────────────────────────────────────────────────
local Cfg = {
    -- ESP
    ESP_Enabled    = true,
    ESP_Killer     = true,
    ESP_Survivor   = true,
    ESP_Spectator  = false,
    ESP_Generator  = true,
    ESP_Hook       = true,
    ESP_Pallet     = true,
    ESP_Names      = true,
    ESP_Distance   = true,
    ESP_Highlight  = true,
    ESP_FadeStart  = 50,
    ESP_FadeMax    = 200,
    -- Combat
    AutoParry      = false,
    ParryRange     = 18,
    AutoEquip      = true,
    ParryCooldown  = 1.0,
    -- Generator
    AutoGen        = true,
    GenMode        = "Instant",  -- "Instant", "Perfect", "Normal"
    GenDelayMin    = 0.15,
    GenDelayMax    = 0.35,
    -- Crosshair
    Crosshair      = true,
    CHColor        = Color3.fromRGB(0, 220, 255),
    CHSize         = 10,
    CHGap          = 5,
    CHThick        = 2,
    -- Visual
    Fullbright     = false,
    NoFog          = false,
}

-- ─────────────────────────────────────────────────────────────────────
-- 5. LUMENUI LOADER (dengan fallback)
-- ─────────────────────────────────────────────────────────────────────
local LumenUI
local function loadLumenUI()
    local url = "https://raw.githubusercontent.com/starvane/LumenUI/refs/heads/main/main.lua"
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if ok and result then
        LumenUI = result
        print("[UC] LumenUI loaded successfully.")
        return true
    else
        warn("[UC] LumenUI load failed, using fallback UI.")
        LumenUI = nil
        return false
    end
end
loadLumenUI()

-- Fallback UI jika LumenUI gagal (minimal, biar script tetap jalan)
local function createFallbackNotification(title, content)
    print(string.format("[UC] %s: %s", title, content))
    -- sederhana: pop up di CoreGui
    local gui = Instance.new("ScreenGui")
    gui.Name = "UCFallbackNotify"
    gui.Parent = CoreGui
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 60)
    frame.Position = UDim2.new(0.5, -150, 0.02, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,25)
    frame.BackgroundTransparency = 0.1
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,0.6,0)
    label.Position = UDim2.new(0,0,0,0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.Parent = frame
    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1,0,0.4,0)
    sub.Position = UDim2.new(0,0,0.6,0)
    sub.BackgroundTransparency = 1
    sub.Text = content or ""
    sub.TextColor3 = Color3.fromRGB(180,180,200)
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 11
    sub.Parent = frame
    task.delay(4, function() gui:Destroy() end)
end

local Notify = LumenUI and LumenUI.MakeNotify or createFallbackNotification

-- ─────────────────────────────────────────────────────────────────────
-- 6. HELPERS
-- ─────────────────────────────────────────────────────────────────────
local function getRoot()
    local char = LP.Character
    if char then return char:FindFirstChild("HumanoidRootPart") end
    return nil
end

local function getPlayerRole(player)
    if not player then return "Unknown" end
    if player.Team then
        local name = player.Team.Name
        if name == "Killer" then return "Killer"
        elseif name == "Survivors" then return "Survivors"
        elseif name == "Spectator" then return "Spectator" end
    end
    return "Unknown"
end

local function isKiller(player)
    return getPlayerRole(player) == "Killer"
end

local function isSurvivor(player)
    return getPlayerRole(player) == "Survivors"
end

local function getDistanceFromRoot(target)
    local root = getRoot()
    if not root then return math.huge end
    if type(target) == "Instance" then
        local pos
        if target:IsA("BasePart") then pos = target.Position
        elseif target:IsA("Model") then
            local p = target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart")
            if p then pos = p.Position end
        end
        if pos then return math.floor((root.Position - pos).Magnitude) end
    end
    return math.huge
end

local function getAttr(obj, key, default)
    if not obj then return default end
    local val = obj:GetAttribute(key)
    if val ~= nil then return val end
    local child = obj:FindFirstChild(key)
    if child and child:IsA("ValueBase") then return child.Value end
    return default
end

local function isGeneratorComplete(gen)
    return getAttr(gen, "Completed", false) == true
end

-- ─────────────────────────────────────────────────────────────────────
-- 7. ESP SYSTEM (dari CURE, diperluas)
-- ─────────────────────────────────────────────────────────────────────
local ESPObjects = {}  -- [model] = { highlight, billboard }

local RoleColors = {
    Killer    = Color3.fromRGB(255, 70, 70),
    Survivors = Color3.fromRGB(70, 160, 255),
    Spectator = Color3.fromRGB(180, 180, 180),
    Generator = Color3.fromRGB(255, 210, 50),
    GenDone   = Color3.fromRGB(50, 255, 100),
    Hook      = Color3.fromRGB(255, 150, 0),
    Pallet    = Color3.fromRGB(180, 130, 70),
}

local function cleanESP(model)
    if ESPObjects[model] then
        for _, v in ipairs(ESPObjects[model]) do
            pcall(function()
                if typeof(v) == "Instance" then v:Destroy()
                elseif type(v) == "userdata" and v.Disconnect then v:Disconnect() end
            end)
        end
        ESPObjects[model] = nil
    end
end

local function makeESP(model, role, extra)
    cleanESP(model)
    if not Cfg.ESP_Enabled then return end

    local color = RoleColors[role] or Color3.fromRGB(255,255,255)
    if role == "Generator" and extra and extra.progress then
        local p = math.clamp(extra.progress / 100, 0, 1)
        color = RoleColors.Generator:Lerp(RoleColors.GenDone, p)
    end

    local objs = {}
    ESPObjects[model] = objs

    -- Highlight
    if Cfg.ESP_Highlight then
        local hl = Instance.new("Highlight")
        hl.Adornee = model
        hl.FillColor = color
        hl.FillTransparency = 0.75
        hl.OutlineColor = color
        hl.OutlineTransparency = 0.0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = model
        table.insert(objs, hl)
    end

    -- Billboard
    local adornee = model:FindFirstChild("HumanoidRootPart")
                or model:FindFirstChild("RootPart")
                or model:FindFirstChild("HitBox")
                or model:FindFirstChildWhichIsA("BasePart")
    if not adornee then return end

    local bb = Instance.new("BillboardGui")
    bb.Name = "UC_ESP"
    bb.Adornee = adornee
    bb.AlwaysOnTop = true
    bb.Size = UDim2.new(0, 220, 0, 55)
    bb.StudsOffset = Vector3.new(0, 3.2, 0)
    bb.Parent = adornee
    table.insert(objs, bb)

    local bg = Instance.new("Frame", bb)
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(0,0,0)
    bg.BackgroundTransparency = 0.55
    bg.BorderSizePixel = 0
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 4)

    local lbl = Instance.new("TextLabel", bg)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = color
    lbl.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    lbl.TextStrokeTransparency = 0.2
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.Text = ""

    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not model or not model.Parent then
            cleanESP(model)
            conn:Disconnect()
            return
        end
        local root = getRoot()
        local txt = ""
        local roleLower = role
        if role == "Killer" or role == "Survivors" or role == "Spectator" then
            local player = Players:GetPlayerFromCharacter(model)
            local name = player and player.DisplayName or model.Name
            if Cfg.ESP_Names then
                txt = string.format("[%s] %s", role:upper(), name)
            end
            if Cfg.ESP_Distance and root and adornee then
                local d = math.floor((adornee.Position - root.Position).Magnitude)
                txt = txt .. string.format("\n📍 %d studs", d)
            end
            lbl.TextColor3 = color
        elseif role == "Generator" then
            local prog = getAttr(model, "RepairProgress", 0)
            local done = getAttr(model, "Completed", false)
            local reg = getAttr(model, "Regressing", false)
            local repairing = (getAttr(model, "PlayersRepairingCount", 0) > 0)
            local c = done and RoleColors.GenDone or RoleColors.Generator
            if done then
                txt = "⚙ Generator [✔ Done]"
            else
                txt = string.format("⚙ Generator [%d%%]%s%s", math.floor(prog),
                    reg and " ↘" or "", repairing and " 🔧" or "")
            end
            if Cfg.ESP_Distance and root and adornee then
                local d = math.floor((adornee.Position - root.Position).Magnitude)
                txt = txt .. string.format("\n📍 %d studs", d)
            end
            lbl.TextColor3 = c
            for _, o in ipairs(objs) do
                if typeof(o) == "Instance" and o:IsA("Highlight") then
                    o.FillColor = c
                    o.OutlineColor = c
                end
            end
        elseif role == "Hook" then
            txt = "Hook"
            if Cfg.ESP_Distance and root and adornee then
                local d = math.floor((adornee.Position - root.Position).Magnitude)
                txt = txt .. string.format("\n📍 %d studs", d)
            end
            lbl.TextColor3 = RoleColors.Hook
        elseif role == "Pallet" then
            txt = "Pallet"
            if Cfg.ESP_Distance and root and adornee then
                local d = math.floor((adornee.Position - root.Position).Magnitude)
                txt = txt .. string.format("\n📍 %d studs", d)
            end
            lbl.TextColor3 = RoleColors.Pallet
        end
        lbl.Text = txt
    end)
    table.insert(objs, conn)
end

local function refreshESP()
    for model in pairs(ESPObjects) do cleanESP(model) end
    if not Cfg.ESP_Enabled then return end

    -- Players
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LP then continue end
        local role = getPlayerRole(p)
        local ok = (role == "Killer" and Cfg.ESP_Killer)
                or (role == "Survivors" and Cfg.ESP_Survivor)
                or (role == "Spectator" and Cfg.ESP_Spectator)
        if ok and p.Character then
            makeESP(p.Character, role)
        end
    end

    -- Generators
    if Cfg.ESP_Generator then
        local map = Workspace:FindFirstChild("Map")
        if map then
            local gens = map:FindFirstChild("Generators")
            if gens then
                for _, g in ipairs(gens:GetChildren()) do
                    if g.Name == "Generator" then
                        local prog = getAttr(g, "RepairProgress", 0)
                        makeESP(g, "Generator", { progress = prog })
                    end
                end
            end
        end
    end

    -- Hooks
    if Cfg.ESP_Hook then
        local map = Workspace:FindFirstChild("Map")
        if map then
            for _, obj in ipairs(map:GetDescendants()) do
                if obj.Name == "Hook" or obj.Name == "HookPoint" then
                    makeESP(obj, "Hook")
                end
            end
        end
    end

    -- Pallets
    if Cfg.ESP_Pallet then
        local map = Workspace:FindFirstChild("Map")
        if map then
            for _, obj in ipairs(map:GetDescendants()) do
                if obj.Name == "Pallet" or obj.Name == "Palletwrong" then
                    makeESP(obj, "Pallet")
                end
            end
        end
    end
end

local function cleanAllESP()
    for model in pairs(ESPObjects) do cleanESP(model) end
end
regCleanup(cleanAllESP)

-- Hook player events
regConn(Players.PlayerAdded:Connect(function(p)
    regConn(p.CharacterAdded:Connect(function()
        task.wait(1)
        refreshESP()
    end))
end))
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LP then
        regConn(p.CharacterAdded:Connect(function()
            task.wait(1)
            refreshESP()
        end))
    end
end
regConn(Players.PlayerRemoving:Connect(function(p)
    if p.Character then cleanESP(p.Character) end
end))

-- Periodic generator refresh (new generators may appear)
task.spawn(function()
    while true do
        task.wait(5)
        if not Cfg.ESP_Generator or not Cfg.ESP_Enabled then continue end
        local map = Workspace:FindFirstChild("Map")
        if map then
            local gens = map:FindFirstChild("Generators")
            if gens then
                for _, g in ipairs(gens:GetChildren()) do
                    if g.Name == "Generator" and not ESPObjects[g] then
                        local prog = getAttr(g, "RepairProgress", 0)
                        makeESP(g, "Generator", { progress = prog })
                    end
                end
            end
        end
    end
end)

-- ─────────────────────────────────────────────────────────────────────
-- 8. AUTO PARRY (multi-layer: animation + hitbox)
-- ─────────────────────────────────────────────────────────────────────
local parryCD = false
local parryKillerBlacklist = {}  -- [killerChar] = timestamp

-- Known attack animation IDs (from 6LOC + BOLONGHUB)
local ATTACK_ANIM_IDS = {
    ["105374834496520"] = true, ["113255068724446"] = true,
    ["118907603246885"] = true, ["129784271201071"] = true,
    ["117042998468241"] = true, ["122812055447896"] = true,
    ["78935059863801"]  = true, ["74968262036854"]  = true,
    ["78432063483146"]  = true, ["132817836308238"] = true,
    ["133963973694098"] = true, ["111920872708571"] = true,
    ["80411309607666"]  = true, ["98163597193511"]  = true,
    ["82666958311998"]  = true, ["110355011987939"] = true,
    ["139369275981139"] = true, ["135002183282873"] = true,
    ["121216847022485"] = true, ["130593238885843"] = true,
    ["117070354890871"] = true, ["106871536134254"] = true,
    ["138720291317243"] = true,
}

local function getAnimId(anim)
    if not anim then return "" end
    local id = tostring(anim.AnimationId):match("%d+")
    return id or ""
end

local function isAttackAnimation(track)
    if not track or not track.Animation then return false end
    local id = getAnimId(track.Animation)
    if id and ATTACK_ANIM_IDS[id] then return true end
    -- also check animation name
    local name = (track.Animation.Name or ""):lower()
    if name:find("attack") or name:find("lunge") or name:find("slash") then return true end
    return false
end

local function tryParry()
    if not Cfg.AutoParry then return end
    if parryCD then return end
    if not LP.Character then return end

    local dagger = LP.Character:FindFirstChild("Parrying Dagger")
                or LP.Backpack:FindFirstChild("Parrying Dagger")
    if not dagger then return end

    if Cfg.AutoEquip and dagger.Parent == LP.Backpack then
        local hum = LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:EquipTool(dagger)
            task.wait(0.1)
        end
    end

    if not LP.Character:FindFirstChild("Parrying Dagger") then return end

    if ParryEvent then
        parryCD = true
        ParryEvent:FireServer()
        task.delay(Cfg.ParryCooldown, function() parryCD = false end)
    end
end

local function watchKillerAnimations(killerChar)
    if not killerChar then return end
    local hum = killerChar:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then return end

    regConn(animator.AnimationPlayed:Connect(function(track)
        if not Cfg.AutoParry then return end
        if not LP.Character then return end
        if not isAttackAnimation(track) then return end

        local root = getRoot()
        local kroot = killerChar:FindFirstChild("HumanoidRootPart")
        if not root or not kroot then return end
        local dist = (root.Position - kroot.Position).Magnitude
        if dist > Cfg.ParryRange then return end

        -- Blacklist: avoid spam
        local last = parryKillerBlacklist[killerChar]
        if last and tick() - last < 0.5 then return end
        parryKillerBlacklist[killerChar] = tick()

        tryParry()
    end))
end

local function setupAutoParry()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then
            local role = getPlayerRole(p)
            if role == "Killer" and p.Character then
                watchKillerAnimations(p.Character)
            end
            regConn(p.CharacterAdded:Connect(function(char)
                task.wait(0.5)
                if getPlayerRole(p) == "Killer" then watchKillerAnimations(char) end
            end))
        end
    end
    regConn(Players.PlayerAdded:Connect(function(p)
        regConn(p.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            if getPlayerRole(p) == "Killer" then watchKillerAnimations(char) end
        end))
    end))
end

-- Hitbox-based detection (additional layer)
local function onHitboxAdded(part)
    if not Cfg.AutoParry then return end
    if not part:IsA("BasePart") then return end
    local name = part.Name:lower()
    if not (name:find("hitbox") or name:find("collider") or name:find("attack")) then return end
    -- find killer parent
    local killer = nil
    local p = part.Parent
    while p and p ~= Workspace do
        if p:IsA("Model") and Players:GetPlayerFromCharacter(p) then
            killer = p
            break
        end
        p = p.Parent
    end
    if not killer then return end
    if killer == LP.Character then return end
    if getPlayerRole(Players:GetPlayerFromCharacter(killer)) ~= "Killer" then return end

    local root = getRoot()
    local kroot = killer:FindFirstChild("HumanoidRootPart")
    if not root or not kroot then return end
    if (root.Position - kroot.Position).Magnitude > Cfg.ParryRange then return end

    local last = parryKillerBlacklist[killer]
    if last and tick() - last < 0.5 then return end
    parryKillerBlacklist[killer] = tick()
    tryParry()
end

regConn(Workspace.DescendantAdded:Connect(onHitboxAdded))

-- ─────────────────────────────────────────────────────────────────────
-- 9. AUTO GENERATOR (dual-layer: UI manipulation + remote hook)
-- ─────────────────────────────────────────────────────────────────────
do
    local genArg1, genArg2 = nil, nil
    local genWaiting = false
    local ksArg2 = nil
    local ksWaiting = false

    if SkillCheckEvent then
        regConn(SkillCheckEvent.OnClientEvent:Connect(function(p1, p2)
            genArg1 = p1
            genArg2 = p2
            genWaiting = true
        end))
    end
    if KingScourgeStart then
        regConn(KingScourgeStart.OnClientEvent:Connect(function(p1, p2, p3)
            ksArg2 = p2
            ksWaiting = true
        end))
    end

    local skillGui = PG:FindFirstChild("SkillCheckPromptGui")
    if not skillGui then
        -- wait for it
        skillGui = PG:WaitForChild("SkillCheckPromptGui", 10)
    end
    local Check = skillGui and skillGui:FindFirstChild("Check")
    local Line = Check and Check:FindFirstChild("Line")
    local Goal = Check and Check:FindFirstChild("Goal")
    local lastVis = false
    local ksLastVis = false

    local function handleQTE(waitingFlag, arg)
        if not Cfg.AutoGen then return end
        if not Check or not Line or not Goal then return end
        if Check.Visible and not lastVis and waitingFlag then
            waitingFlag = false
            local delay = Cfg.GenDelayMin + math.random() * (Cfg.GenDelayMax - Cfg.GenDelayMin)
            task.delay(delay, function()
                if not Cfg.AutoGen then return end
                if not LP.Character then return end
                local ci = LP.Character:FindFirstChild("CheckInterractable")
                if not ci or not ci:GetAttribute("isRepairing") then return end

                if Cfg.GenMode == "Instant" then
                    Line.Rotation = 109 + Goal.Rotation
                elseif Cfg.GenMode == "Perfect" then
                    Line.Rotation = 102 + Goal.Rotation
                elseif Cfg.GenMode == "Normal" then
                    -- do nothing, let user press manually
                end

                pcall(function()
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                    task.wait(0.05)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                end)
            end)
        end
        lastVis = Check.Visible
    end

    if Check and Line and Goal then
        regConn(RunService.Heartbeat:Connect(function()
            if not Cfg.AutoGen then
                lastVis = Check.Visible
                ksLastVis = Check.Visible
                return
            end
            handleQTE(genWaiting, genArg1)
            -- King's Scourge
            if Check.Visible and not ksLastVis and ksWaiting then
                ksWaiting = false
                local delay = Cfg.GenDelayMin + math.random() * (Cfg.GenDelayMax - Cfg.GenDelayMin)
                task.delay(delay, function()
                    if not Cfg.AutoGen then return end
                    if not LP.Character then return end
                    local ci = LP.Character:FindFirstChild("CheckInterractable")
                    if not ci or not ci:GetAttribute("isRepairing") then return end
                    if Cfg.GenMode == "Instant" or Cfg.GenMode == "Perfect" then
                        Line.Rotation = 109 + Goal.Rotation
                    end
                    pcall(function()
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                        task.wait(0.05)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                    end)
                end)
            end
            ksLastVis = Check.Visible
        end))
    end

    -- Layer 2: Remote hook failsafe
    pcall(function()
        local oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            if method == "FireServer" and not checkcaller() then
                if self == SkillCheckResult and Cfg.AutoGen then
                    args[1] = "success"
                    args[2] = 1
                    return oldNamecall(self, table.unpack(args))
                elseif self == KingScourgeHit and Cfg.AutoGen then
                    args[2] = "success"
                    return oldNamecall(self, table.unpack(args))
                end
            end
            return oldNamecall(self, ...)
        end)
    end)
end

-- ─────────────────────────────────────────────────────────────────────
-- 10. CROSSHAIR (dari CURE)
-- ─────────────────────────────────────────────────────────────────────
local CrosshairGui = nil

local function destroyCrosshair()
    if CrosshairGui and CrosshairGui.Parent then
        CrosshairGui:Destroy()
        CrosshairGui = nil
    end
end
regCleanup(destroyCrosshair)

local function buildCrosshair()
    destroyCrosshair()
    if not Cfg.Crosshair then return end

    local gui = Instance.new("ScreenGui")
    gui.Name = "UC_Crosshair"
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 999
    gui.IgnoreGuiInset = true
    pcall(function() gui.Parent = CoreGui end)
    if not gui.Parent then gui.Parent = PG end
    CrosshairGui = gui

    local function bar(sx, sy, px, py)
        local f = Instance.new("Frame", gui)
        f.Size = UDim2.new(0, sx, 0, sy)
        f.Position = UDim2.new(0.5, px, 0.5, py)
        f.BackgroundColor3 = Cfg.CHColor
        f.BorderSizePixel = 0
        f.ZIndex = 10
        local shadow = Instance.new("Frame", f)
        shadow.Size = UDim2.new(1, 2, 1, 2)
        shadow.Position = UDim2.new(0, -1, 0, 1)
        shadow.BackgroundColor3 = Color3.fromRGB(0,0,0)
        shadow.BorderSizePixel = 0
        shadow.BackgroundTransparency = 0.7
        shadow.ZIndex = 9
        return f
    end

    local sz, gap, th = Cfg.CHSize, Cfg.CHGap, Cfg.CHThick
    bar(sz, th, -sz - gap, -th/2)
    bar(sz, th,  gap,       -th/2)
    bar(th, sz, -th/2, -sz - gap)
    bar(th, sz, -th/2,  gap)
    bar(th, th, -th/2, -th/2)
end

-- ─────────────────────────────────────────────────────────────────────
-- 11. LUMENUI INTEGRATION
-- ─────────────────────────────────────────────────────────────────────
local UI = nil
local function setupUI()
    if not LumenUI then
        Notify("UI Error", "LumenUI not loaded. Using fallback mode.")
        return
    end

    UI = LumenUI:Window({
        Title = "Ultimate Core",
        Author = "Hybrid Script",
        Icon = "zap",
        Size = UDim2.fromOffset(620, 450),
        MinSize = Vector2.new(500, 350),
        Resizable = true,
        ToggleKey = Enum.KeyCode.RightShift,
        Topbar = { Height = 44 },
        Acrylic = true,
        Transparent = false,
    })

    -- Tabs
    local tabs = {
        Main = UI:Tab({ Title = "Main", Icon = "home" }),
        ESP = UI:Tab({ Title = "ESP", Icon = "eye" }),
        Combat = UI:Tab({ Title = "Combat", Icon = "swords" }),
        Generator = UI:Tab({ Title = "Generator", Icon = "cpu" }),
        Crosshair = UI:Tab({ Title = "Crosshair", Icon = "crosshair" }),
        Visual = UI:Tab({ Title = "Visual", Icon = "sun" }),
    }

    -- MAIN
    local mainSec = tabs.Main:Section({ Title = "Dashboard", Opened = true })
    mainSec:Paragraph({ Title = "Ultimate Core Hybrid", Content = "Built on CURE architecture + LumenUI." })
    mainSec:Button({ Title = "Refresh ESP", Callback = refreshESP })
    mainSec:Button({ Title = "Rebuild Crosshair", Callback = buildCrosshair })
    mainSec:Divider()
    mainSec:Paragraph({ Title = "Status", Content = "All features are configured in their tabs." })

    -- ESP
    local espSec = tabs.ESP:Section({ Title = "ESP Settings", Opened = true })
    local espToggles = {}
    espToggles.Enabled = espSec:Toggle({ Title = "Enable ESP", Default = Cfg.ESP_Enabled, Callback = function(v)
        Cfg.ESP_Enabled = v
        refreshESP()
        if UI then UI:SaveConfig() end
    end})
    espToggles.Killer = espSec:Toggle({ Title = "Show Killers", Default = Cfg.ESP_Killer, Callback = function(v)
        Cfg.ESP_Killer = v
        refreshESP()
        if UI then UI:SaveConfig() end
    end})
    espToggles.Survivor = espSec:Toggle({ Title = "Show Survivors", Default = Cfg.ESP_Survivor, Callback = function(v)
        Cfg.ESP_Survivor = v
        refreshESP()
        if UI then UI:SaveConfig() end
    end})
    espToggles.Generator = espSec:Toggle({ Title = "Show Generators", Default = Cfg.ESP_Generator, Callback = function(v)
        Cfg.ESP_Generator = v
        refreshESP()
        if UI then UI:SaveConfig() end
    end})
    espToggles.Hook = espSec:Toggle({ Title = "Show Hooks", Default = Cfg.ESP_Hook, Callback = function(v)
        Cfg.ESP_Hook = v
        refreshESP()
        if UI then UI:SaveConfig() end
    end})
    espToggles.Pallet = espSec:Toggle({ Title = "Show Pallets", Default = Cfg.ESP_Pallet, Callback = function(v)
        Cfg.ESP_Pallet = v
        refreshESP()
        if UI then UI:SaveConfig() end
    end})
    espToggles.Names = espSec:Toggle({ Title = "Show Names", Default = Cfg.ESP_Names, Callback = function(v)
        Cfg.ESP_Names = v
        if UI then UI:SaveConfig() end
    end})
    espToggles.Distance = espSec:Toggle({ Title = "Show Distance", Default = Cfg.ESP_Distance, Callback = function(v)
        Cfg.ESP_Distance = v
        if UI then UI:SaveConfig() end
    end})
    espToggles.Highlight = espSec:Toggle({ Title = "Highlight (Chams)", Default = Cfg.ESP_Highlight, Callback = function(v)
        Cfg.ESP_Highlight = v
        refreshESP()
        if UI then UI:SaveConfig() end
    end})

    -- Combat
    local combatSec = tabs.Combat:Section({ Title = "Auto Parry", Opened = true })
    combatSec:Paragraph({ Title = "Auto Parry", Content = "Automatically parries killer attacks in range." })
    local parryToggle = combatSec:Toggle({ Title = "Enable Auto Parry", Default = Cfg.AutoParry, Callback = function(v)
        Cfg.AutoParry = v
        if UI then UI:SaveConfig() end
    end})
    local equipToggle = combatSec:Toggle({ Title = "Auto Equip Dagger", Default = Cfg.AutoEquip, Callback = function(v)
        Cfg.AutoEquip = v
        if UI then UI:SaveConfig() end
    end})
    combatSec:Slider({ Title = "Parry Range (studs)", Min = 5, Max = 40, Default = Cfg.ParryRange, Step = 1, Callback = function(v)
        Cfg.ParryRange = v
        if UI then UI:SaveConfig() end
    end})
    combatSec:Slider({ Title = "Parry Cooldown (s)", Min = 0.5, Max = 5, Default = Cfg.ParryCooldown, Step = 0.1, Callback = function(v)
        Cfg.ParryCooldown = v
        if UI then UI:SaveConfig() end
    end})
    combatSec:Button({ Title = "Manual Parry", Callback = function()
        tryParry()
    end})

    -- Generator
    local genSec = tabs.Generator:Section({ Title = "Auto Generator", Opened = true })
    genSec:Paragraph({ Title = "Auto Generator", Content = "Automatically hits skill checks." })
    local genToggle = genSec:Toggle({ Title = "Enable Auto Generator", Default = Cfg.AutoGen, Callback = function(v)
        Cfg.AutoGen = v
        if UI then UI:SaveConfig() end
    end})
    genSec:Dropdown({ Title = "Mode", Values = { "Instant", "Perfect", "Normal" }, Default = Cfg.GenMode, Callback = function(v)
        Cfg.GenMode = v
        if UI then UI:SaveConfig() end
    end})
    genSec:Slider({ Title = "Delay Min (s)", Min = 0.05, Max = 1.0, Default = Cfg.GenDelayMin, Step = 0.01, Callback = function(v)
        Cfg.GenDelayMin = v
        if UI then UI:SaveConfig() end
    end})
    genSec:Slider({ Title = "Delay Max (s)", Min = 0.1, Max = 1.5, Default = Cfg.GenDelayMax, Step = 0.01, Callback = function(v)
        Cfg.GenDelayMax = v
        if UI then UI:SaveConfig() end
    end})

    -- Crosshair
    local chSec = tabs.Crosshair:Section({ Title = "Crosshair", Opened = true })
    local chToggle = chSec:Toggle({ Title = "Enable Crosshair", Default = Cfg.Crosshair, Callback = function(v)
        Cfg.Crosshair = v
        buildCrosshair()
        if UI then UI:SaveConfig() end
    end})
    chSec:Slider({ Title = "Size (px)", Min = 4, Max = 30, Default = Cfg.CHSize, Step = 1, Callback = function(v)
        Cfg.CHSize = v
        buildCrosshair()
        if UI then UI:SaveConfig() end
    end})
    chSec:Slider({ Title = "Gap (px)", Min = 0, Max = 20, Default = Cfg.CHGap, Step = 1, Callback = function(v)
        Cfg.CHGap = v
        buildCrosshair()
        if UI then UI:SaveConfig() end
    end})
    chSec:Slider({ Title = "Thickness (px)", Min = 1, Max = 6, Default = Cfg.CHThick, Step = 1, Callback = function(v)
        Cfg.CHThick = v
        buildCrosshair()
        if UI then UI:SaveConfig() end
    end})
    chSec:ColorPicker({ Title = "Crosshair Color", Default = Cfg.CHColor, Callback = function(v)
        Cfg.CHColor = v
        buildCrosshair()
        if UI then UI:SaveConfig() end
    end})

    -- Visual
    local visSec = tabs.Visual:Section({ Title = "Visual Settings", Opened = true })
    visSec:Toggle({ Title = "Fullbright", Default = Cfg.Fullbright, Callback = function(v)
        Cfg.Fullbright = v
        if v then
            Lighting.Ambient = Color3.fromRGB(255,255,255)
            Lighting.Brightness = 2
            Lighting.GlobalShadows = false
        else
            Lighting.Ambient = Color3.fromRGB(128,128,128)
            Lighting.Brightness = 1
            Lighting.GlobalShadows = true
        end
        if UI then UI:SaveConfig() end
    end})
    visSec:Toggle({ Title = "No Fog", Default = Cfg.NoFog, Callback = function(v)
        Cfg.NoFog = v
        if v then
            Lighting.FogStart = 999999
            Lighting.FogEnd = 999999
        else
            Lighting.FogStart = 0
            Lighting.FogEnd = 1000
        end
        if UI then UI:SaveConfig() end
    end})

    -- Notification
    if UI and UI:Notify then
        UI:Notify({ Title = "Ultimate Core", Content = "Script loaded successfully!", Duration = 3 })
    end
    Notify("Ultimate Core", "Script loaded! Press RightShift to toggle menu.")
end

-- ─────────────────────────────────────────────────────────────────────
-- 12. STARTUP
-- ─────────────────────────────────────────────────────────────────────
buildCrosshair()
setupAutoParry()
refreshESP()

regConn(LP.CharacterAdded:Connect(function()
    task.wait(2)
    refreshESP()
end))

-- Fallback notification if LumenUI fails
task.spawn(function()
    task.wait(2)
    if not LumenUI then
        Notify("Ultimate Core", "Running in fallback mode. Some UI features may be limited.")
    end
end)

-- Build UI after a short delay to ensure everything is loaded
task.spawn(function()
    task.wait(1)
    setupUI()
end)

-- ─────────────────────────────────────────────────────────────────────
-- 13. EXPOSE GLOBALS (for debugging / external control)
-- ─────────────────────────────────────────────────────────────────────
_G.UC = {
    Version = "1.0.0",
    Cfg = Cfg,
    RefreshESP = refreshESP,
    BuildCrosshair = buildCrosshair,
    TryParry = tryParry,
    Cleanup = _G.UC_Cleanup,
}

print("[UC] Ultimate Core loaded. Version 1.0.0")
print("[UC] Press RightShift to toggle UI.")
