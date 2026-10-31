-- TSB ALT FARM - UNIVERSAL COMPATIBLE
wait(1)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VIM = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local MainName = getgenv().MainFarmer

if not MainName then
    warn("SET getgenv().MainFarmer = 'Username'")
    return
end

local IsMain = (LocalPlayer.Name == MainName)
print(LocalPlayer.Name .. " | " .. (IsMain and "MAIN" or "ALT"))

-- LOAD VISUALS
pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/SkibidiFart123patapim/tsblarp/refs/heads/main/NoRender.lua"))()
end)
pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/stormzdev/the-strongest-battlegrounds/refs/heads/main/fps-boost.lua"))()
end)

-- COMMS FOLDER
local Comms = ReplicatedStorage:FindFirstChild("TSBFarm") or Instance.new("Folder")
Comms.Name = "TSBFarm"
Comms.Parent = ReplicatedStorage

-- STATUS OBJECT
local MyVal = Comms:FindFirstChild(LocalPlayer.Name) or Instance.new("StringValue")
MyVal.Name = LocalPlayer.Name
MyVal.Parent = Comms
MyVal.Value = "Idle"

-- CODES: Idle, Ready, SkillNow, ResetNow

-- UTILS
function WaitChar()
    local char = LocalPlayer.Character
    while not char or not char:FindFirstChild("HumanoidRootPart") do
        char = LocalPlayer.CharacterAdded:wait()
        wait(0.5)
    end
    return char
end

function TP(cf)
    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = cf
    end
end

function Reset()
    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.Health = 0 end
end

function CastSkill()
    print("SKILL")
    -- Try remotes
    pcall(function()
        ReplicatedStorage.Remotes.Combat.Skill:FireServer(4)
    end)
    -- Try keys
    pcall(function()
        VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        wait(0.1)
        VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    end)
    wait(0.5)
end

-- MAIN LOGIC
local FarmPos = CFrame.new(439, 440, -376)

if IsMain then
    print("MAIN")
    MyVal.Value = "Main"
    
    WaitChar()
    TP(FarmPos)
    
    LocalPlayer.CharacterAdded:connect(function()
        wait(0.5)
        TP(FarmPos)
        MyVal.Value = "Main"
    end)
    
    -- MONITOR LOOP
    local lastAlt = {}
    
    while wait(0.1) do
        for _, v in pairs(Comms:GetChildren()) do
            if v:IsA("StringValue") and v.Name ~= LocalPlayer.Name then
                if v.Value == "Ready" and (not lastAlt[v.Name] or tick() - lastAlt[v.Name] > 2) then
                    lastAlt[v.Name] = tick()
                    print("ALT: " .. v.Name)
                    
                    CastSkill()
                    v.Value = "ResetNow"
                    
                    wait(0.3)
                    Reset()
                end
            end
        end
    end

else
    print("ALT")
    
    WaitChar()
    TP(FarmPos)
    MyVal.Value = "Ready"
    
    LocalPlayer.CharacterAdded:connect(function()
        wait(0.5)
        TP(FarmPos)
        MyVal.Value = "Ready"
    end)
    
    while wait(0.1) do
        if MyVal.Value == "ResetNow" then
            MyVal.Value = "Idle"
            wait(0.1)
            Reset()
        end
    end
end
