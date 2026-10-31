--// TSB ALT FARM | MAX UNC OPTIMIZATION
if not game:IsLoaded() then game.Loaded:Wait() end

--// 100 UNC LOADSTRING EXECUTION
local function SafeLoad(url)
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    if success then
        local fn, err = loadstring(result)
        if fn then pcall(fn) end
    end
end

pcall(SafeLoad, "https://raw.githubusercontent.com/SkibidiFart123patapim/tsblarp/refs/heads/main/NoRender.lua")
pcall(SafeLoad, "https://raw.githubusercontent.com/stormzdev/the-strongest-battlegrounds/refs/heads/main/fps-boost.lua")

--// SERVICES & UNC FUNCTIONS
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local MainName = tostring(getgenv().MainFarmer or getgenv().main or "")
if MainName == "" then
    warn("⚠️ SET getgenv().MainFarmer = 'Username' !!")
    return
end

local IsMain = LocalPlayer.Name == MainName
local FarmCFrame = CFrame.new(439, 440, -376)

print(string.format("🚀 %s | %s | UNC: %s", LocalPlayer.Name, IsMain and "MAIN" or "ALT", tostring(getgenv).len and "YES" or "PARTIAL"))

--// TSB REMOTE RESOLUTION (UNC OPTIMIZED)
local CombatFolder = ReplicatedStorage:WaitForChild("Remotes", 10):WaitForChild("Combat", 10)
local SkillRemote = CombatFolder:FindFirstChild("Skill") or CombatFolder:FindFirstChild("UseSkill")
local ServerRemote = ReplicatedStorage:FindFirstChild("Server") and ReplicatedStorage.Server:FindFirstChild("UseSkill")

--// GETGC SKILL SCANNER (UNC)
local function GetSkillFunction()
    for _, v in pairs(getgc(true)) do
        if type(v) == "function" then
            local info = debug.getinfo(v)
            if info and info.name and (info.name:lower():find("skill") or info.name:lower():find("ability")) then
                local consts = debug.getconstants(v)
                for _, c in pairs(consts) do
                    if c == 4 or c == "Ultimate" or c == "F" then
                        return v
                    end
                end
            end
        end
    end
    return nil
end

local SkillFunc = GetSkillFunction()

--// COMMUNICATION SYSTEM (ATTRIBUTES - UNC SAFE, NO INSTANCING LAG)
local Comms = ReplicatedStorage:FindFirstChild("__TSB_FARM__") or Instance.new("Configuration")
Comms.Name = "__TSB_FARM__"
Comms.Parent = ReplicatedStorage

-- Set/Get with validation
local function SetStatus(status)
    Comms:SetAttribute(LocalPlayer.Name, status)
    Comms:SetAttribute(LocalPlayer.Name.."_Time", tick())
end

local function GetStatus(playerName)
    return Comms:GetAttribute(playerName), Comms:GetAttribute(playerName.."_Time")
end

local function GetMainStatus()
    return GetStatus(MainName)
end

--// CHARACTER UTILS (UNC OPTIMIZED)
local function GetChar()
    return LocalPlayer.Character
end

local function WaitChar()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return LocalPlayer.Character
    end
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart").Parent
end

local function ForceTP(cf)
    local char = GetChar()
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- UNC TELEPORT METHOD (NETWORK OWNERSHIP BYPASS)
    hrp.CFrame = cf
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    
    -- Multiple attempts for anti-cheat bypass
    task.spawn(function()
        for i = 1, 5 do
            if hrp and hrp.Parent then
                hrp.CFrame = cf
                task.wait(0.03)
            end
        end
    end)
end

local function Reset()
    local char = GetChar()
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Health = 0
        end
    end
end

--// SKILL EXECUTION (MULTI-METHOD FALLBACK)
local function CastUltimate()
    print("⚔️ CASTING ULTIMATE")
    
    -- Method 1: Direct Remote
    if SkillRemote then
        pcall(function()
            SkillRemote:FireServer(4, "Ultimate")
            SkillRemote:FireServer("F")
        end)
    end
    
    -- Method 2: Server Remote
    if ServerRemote then
        pcall(function()
            ServerRemote:FireServer(4)
        end)
    end
    
    -- Method 3: Virtual Input (UNC)
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    end)
    
    -- Method 4: Hooked Function Call (UNC)
    if SkillFunc then
        pcall(function()
            -- Try to call with different signatures
            SkillFunc(4)
            SkillFunc("Ultimate")
            SkillFunc(LocalPlayer, 4)
        end)
    end
    
    -- Method 5: Namecall spoof (Advanced UNC)
    pcall(function()
        if getrawmetatable then
            local mt = getrawmetatable(game)
            local old = mt.__namecall
            setreadonly(mt, false)
            mt.__namecall = newcclosure(function(self, ...)
                if self == SkillRemote then
                    return old(self, 4, "Ultimate")
                end
                return old(self, ...)
            end)
            setreadonly(mt, true)
        end
    end)
    
    task.wait(0.5)
end

--// MAIN ACCOUNT LOGIC
if IsMain then
    print("👑 MAIN MODE ACTIVE")
    SetStatus("MainActive")
    
    -- TP Once on spawn
    WaitChar()
    ForceTP(FarmCFrame)
    
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.6)
        ForceTP(FarmCFrame)
        SetStatus("MainActive")
    end)
    
    -- ALT MONITORING LOOP (UNC OPTIMIZED)
    local LastSignal = {}
    
    task.spawn(function()
        while task.wait(0.05) do -- 20Hz check rate
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local status, time = GetStatus(player.Name)
                    
                    -- Valid "Ready" signal check (timeout after 10s)
                    if status == "Ready" and (not LastSignal[player.Name] or tick() - LastSignal[player.Name] > 2) then
                        if time and tick() - time < 10 then
                            print(string.format("📡 ALT SIGNAL: %s | PROCESSING", player.Name))
                            LastSignal[player.Name] = tick()
                            
                            -- EXECUTE SKILL
                            CastUltimate()
                            
                            -- COMMAND RESET
                            Comms:SetAttribute(player.Name.."_CMD", "RESET")
                            
                            -- SELF RESET
                            task.wait(0.3)
                            Reset()
                    end
                end
            end
        end
    end)

else
    --// ALT ACCOUNT LOGIC
    print("🤖 ALT MODE ACTIVE")
    
    -- INITIAL SETUP
    WaitChar()
    ForceTP(FarmCFrame)
    SetStatus("Ready")
    
    -- ON DEATH/RESPAWN
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.8) -- Wait for load
        ForceTP(FarmCFrame)
        SetStatus("Ready")
        print("🤖 ALT READY AGAIN")
    end)
    
    -- LISTEN FOR MAIN COMMANDS
    task.spawn(function()
        while task.wait(0.05) do
            local cmd = Comms:GetAttribute(LocalPlayer.Name.."_CMD")
            if cmd == "RESET" then
                Comms:SetAttribute(LocalPlayer.Name.."_CMD", "NONE") -- Clear command
                print("🤖 RECEIVED RESET COMMAND")
                task.wait(0.1)
                Reset()
            end
        end
    end)
end

--// ANTI AFK (UNC)
pcall(function()
    local VirtualUser = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

print("✅ SYSTEM ARMED | STATUS:", GetStatus(LocalPlayer.Name))
