--// TSB ALT FARM | MAXIMUM UNC COMPATIBLE
repeat task.wait() until game:GetService("Players").LocalPlayer
task.wait(0.5)

--// SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

local MainName = tostring(getgenv().MainFarmer or "")
if MainName == "" then
    warn("SET getgenv().MainFarmer = 'Username'")
    return
end

local IsMain = (LocalPlayer.Name == MainName)
local FarmPos = CFrame.new(439, 440, -376)

print(LocalPlayer.Name .. " | " .. (IsMain and "MAIN" or "ALT"))

--// LOAD VISUALS
pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/SkibidiFart123patapim/tsblarp/refs/heads/main/NoRender.lua"))()
end)
pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/stormzdev/the-strongest-battlegrounds/refs/heads/main/fps-boost.lua"))()
end)

--// FIND TSB REMOTES
local CombatFolder = nil
local SkillRemote = nil

pcall(function()
    CombatFolder = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Combat")
    SkillRemote = CombatFolder:WaitForChild("Skill")
end)

--// COMMUNICATION (CONFIGURATION OBJECT - REPLICATED)
local Comms = ReplicatedStorage:FindFirstChild("TSBFarmV2")
if not Comms then
    Comms = Instance.new("Configuration")
    Comms.Name = "TSBFarmV2"
    Comms.Parent = ReplicatedStorage
end

-- Status functions using NumberValues for reliability
local MyStatus = Comms:FindFirstChild(LocalPlayer.Name)
if not MyStatus then
    MyStatus = Instance.new("IntValue")
    MyStatus.Name = LocalPlayer.Name
    MyStatus.Parent = Comms
end
MyStatus.Value = 0

-- Status codes: 0=Idle, 1=Ready, 2=SkillUsed, 3=NeedsReset

--// UTILS
local function GetChar()
    return LocalPlayer.Character
end

local function WaitChar()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        return char
    end
    char = LocalPlayer.CharacterAdded:Wait()
    repeat task.wait() until char:FindFirstChild("HumanoidRootPart")
    return char
end

local function TP(cf)
    local char = GetChar()
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    hrp.CFrame = cf
    hrp.Velocity = Vector3.new(0, 0, 0)
    hrp.RotVelocity = Vector3.new(0, 0, 0)
    
    -- Double tap for AC
    task.spawn(function()
        task.wait(0.1)
        if hrp and hrp.Parent then
            hrp.CFrame = cf
        end
    end)
end

local function Reset()
    pcall(function()
        local hum = GetChar():FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
    end)
end

local function UseSkill()
    print("CASTING SKILL")
    
    -- Remote method
    if SkillRemote then
        pcall(function()
            SkillRemote:FireServer(4)
        end)
    end
    
    -- Keyboard method
    pcall(function()
        keypress(0x46) -- F key
        task.wait(0.1)
        keyrelease(0x46)
    end)
    
    -- Alternative key method
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, nil)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, nil)
    end)
    
    task.wait(0.5)
end

--// MAIN LOGIC
if IsMain then
    print("MAIN ACTIVE")
    MyStatus.Value = 99 -- Main marker
    
    WaitChar()
    TP(FarmPos)
    
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        TP(FarmPos)
        MyStatus.Value = 99
    end)
    
    -- Monitor alts
    local processed = {}
    
    while task.wait(0.1) do
        for _, obj in pairs(Comms:GetChildren()) do
            if obj:IsA("IntValue") and obj.Name ~= LocalPlayer.Name then
                local altName = obj.Name
                local status = obj.Value
                
                -- Alt signaled ready (1) and we haven't processed recently
                if status == 1 and (not processed[altName] or tick() - processed[altName] > 3) then
                    print("SIGNAL FROM " .. altName)
                    processed[altName] = tick()
                    
                    -- Use skill
                    UseSkill()
                    
                    -- Tell alt to reset
                    obj.Value = 3
                    
                    -- Self reset
                    task.wait(0.3)
                    Reset()
                end
            end
        end
    end

else
    --// ALT LOGIC
    print("ALT ACTIVE")
    
    WaitChar()
    TP(FarmPos)
    MyStatus.Value = 1 -- Signal ready
    
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        TP(FarmPos)
        MyStatus.Value = 1
        print("ALT READY")
    end)
    
    -- Listen for commands
    while task.wait(0.1) do
        if MyStatus.Value == 3 then -- Main commanded reset
            MyStatus.Value = 0 -- Acknowledge
            task.wait(0.1)
            Reset()
        end
    end
end
