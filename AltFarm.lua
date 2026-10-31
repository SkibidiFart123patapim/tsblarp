--// TSB Alt Farm Script - Fixed Communication System
pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/SkibidiFart123patapim/tsblarp/refs/heads/main/NoRender.lua"))()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/stormzdev/the-strongest-battlegrounds/refs/heads/main/fps-boost.lua"))()
end)

--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

--// Config
getgenv().FarmConfig = getgenv().FarmConfig or {
    MainFarmer = getgenv().MainFarmer or nil,
    FarmPos = CFrame.new(439, 440, -376),
    SkillDelay = 0.5,
    ResetDelay = 0.3
}

if not getgenv().FarmConfig.MainFarmer then
    warn("⚠️ Warning: Main Acc not found maybe u misspelled it?")
    warn("Set getgenv().MainFarmer = 'YourMainUsername' before running!")
    return
end

local LocalPlayer = Players.LocalPlayer
local MainName = tostring(getgenv().FarmConfig.MainFarmer)
local IsMain = (LocalPlayer.Name == MainName or LocalPlayer.DisplayName == MainName)
local IsAlt = not IsMain

print("🚀 Loaded | " .. LocalPlayer.Name .. " | " .. (IsMain and "MAIN" or "ALT"))

--// Communication System (Folder in ReplicatedStorage for cross-player visibility)
local Comms = ReplicatedStorage:FindFirstChild("TSBFarmComms") or Instance.new("Folder")
Comms.Name = "TSBFarmComms"
Comms.Parent = ReplicatedStorage

-- Signal values: "Idle", "Ready", "SkillUsed", "ResetNow"
local MySignal = Comms:FindFirstChild(LocalPlayer.Name) or Instance.new("StringValue")
MySignal.Name = LocalPlayer.Name
MySignal.Parent = Comms
MySignal.Value = "Idle"

function GetSignal(playerName)
    return Comms:FindFirstChild(playerName)
end

function GetMainSignal()
    return GetSignal(MainName)
end

--// Character Utils
function GetChar()
    return LocalPlayer.Character
end

function WaitChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

function GetHum()
    local char = GetChar()
    if char then
        return char:FindFirstChild("Humanoid"), char:FindFirstChild("HumanoidRootPart")
    end
    return nil, nil
end

--// Teleport Function (One-time on spawn)
function TPToFarm()
    pcall(function()
        local char = WaitChar()
        local hrp = char:WaitForChild("HumanoidRootPart", 3)
        if hrp then
            hrp.CFrame = getgenv().FarmConfig.FarmPos
            print("📍 TP to farm pos")
        end
    end)
end

--// Skill Function (Main Only)
function UseFourthSkill()
    pcall(function()
        print("⚔️ Using 4th Skill...")
        
        -- Try common TSB inputs
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
        
        -- Try remotes
        local combat = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Combat")
        if combat then
            for _, remote in pairs(combat:GetDescendants()) do
                if remote:IsA("RemoteEvent") and (remote.Name:lower():find("skill") or remote.Name:lower():find("ability")) then
                    remote:FireServer(4)
                end
            end
        end
        
        -- Alternative remote path
        local serverEvents = ReplicatedStorage:FindFirstChild("Server")
        if serverEvents and serverEvents:FindFirstChild("UseSkill") then
            serverEvents.UseSkill:FireServer(4)
        end
        
        task.wait(getgenv().FarmConfig.SkillDelay)
    end)
end

--// Reset Function
function ResetChar()
    pcall(function()
        local hum = GetHum()
        if hum then
            hum.Health = 0
            print("💀 Reset character")
        end
    end)
end

--// Main Account Logic
if IsMain then
    print("👑 MAIN ACTIVE - Monitoring alts...")
    
    -- Initial TP
    TPToFarm()
    LocalPlayer.CharacterAdded:Connect(TPToFarm)
    
    -- Monitor all alt signals
    task.spawn(function()
        while task.wait(0.1) do
            -- Check all players that aren't main
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local signal = GetSignal(player.Name)
                    if signal and signal.Value == "Ready" then
                        print("📡 Signal from " .. player.Name .. ": READY")
                        
                        -- Use skill
                        UseFourthSkill()
                        
                        -- Tell alt to reset
                        signal.Value = "ResetNow"
                        print("📡 Sent to " .. player.Name .. ": RESETNOW")
                        
                        -- Reset self after skill
                        task.wait(getgenv().FarmConfig.ResetDelay)
                        ResetChar()
                    end
                end
            end
        end
    end)

else
    --// Alt Account Logic
    print("🤖 ALT ACTIVE - Waiting for main...")
    
    -- Initial setup
    TPToFarm()
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5) -- Brief wait after respawn
        TPToFarm()
        MySignal.Value = "Ready"
        print("🤖 Alt ready at farm pos")
    end)
    
    -- Signal ready initially
    task.spawn(function()
        task.wait(2) -- Wait for load
        TPToFarm()
        MySignal.Value = "Ready"
        print("🤖 Initial ready signal sent")
    end)
    
    -- Listen for main command
    task.spawn(function()
        while task.wait(0.1) do
            if MySignal.Value == "ResetNow" then
                print("🤖 Received ResetNow command")
                MySignal.Value = "Idle"
                ResetChar()
                -- Will auto signal Ready on respawn via CharacterAdded
            end
        end
    end)
end

--// Anti AFK
local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

print("✅ System Active - " .. (IsMain and "Waiting for alt signals" or "Signal sent to main"))
