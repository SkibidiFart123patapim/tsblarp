-- TSB Alt Farm Script - Complete Implementation
-- Load visual optimizations first
pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/SkibidiFart123patapim/tsblarp/refs/heads/main/NoRender.lua"))()
end)

pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/stormzdev/the-strongest-battlegrounds/refs/heads/main/fps-boost.lua"))()
end)

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

-- Config check
local MainFarmer = getgenv().MainFarmer

if not MainFarmer then
    warn("Warning: Main Acc not found maybe u misspelled it?")
    return
end

-- Determine if this is main or alt
local IsMain = (LocalPlayer.Name == MainFarmer)

-- Teleport position
local FARM_POS = CFrame.new(439, 440, -376)

-- State tracking
local IsDead = false
local FarmLoopRunning = false

-- Function to teleport character
local function TeleportToFarm()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = FARM_POS
    end
end

-- Input simulation function
local function PressKey(key)
    VirtualInputManager:SendKeyEvent(true, key, false, game)
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(false, key, false, game)
end

-- Reset function
local function ResetCharacter()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.Health = 0
    end
end

-- Handle character added (spawn/respawn)
local function OnCharacterAdded(newChar)
    local humanoid = newChar:WaitForChild("Humanoid")
    
    -- Immediate teleport on spawn
    task.wait(0.3)
    TeleportToFarm()
    
    -- Watch for death to set flag
    humanoid.Died:Connect(function()
        IsDead = true
    end)
end

-- Connect spawn handler
LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)

-- Death monitor thread - TP back when respawned
task.spawn(function()
    while true do
        if IsDead and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            IsDead = false
            task.wait(0.5) -- Small buffer after respawn
            TeleportToFarm()
        end
        task.wait(0.5)
    end
end)

-- Initial TP if already spawned
if LocalPlayer.Character then
    OnCharacterAdded(LocalPlayer.Character)
end

-- Main farm logic
if IsMain then
    -- Main account: wait for alts, use 4th skill, reset, repeat
    task.spawn(function()
        FarmLoopRunning = true
        task.wait(2) -- Initial buffer
        
        while FarmLoopRunning do
            -- Ensure we're alive before using skill
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                if LocalPlayer.Character.Humanoid.Health > 0 then
                    -- Use 4th skill (Key 4)
                    PressKey(Enum.KeyCode.Four)
                    task.wait(0.8)
                    
                    -- Reset after using skill
                    ResetCharacter()
                    
                    -- Wait for full respawn cycle
                    task.wait(5)
                else
                    task.wait(1)
                end
            else
                task.wait(1)
            end
        end
    end)
else
    -- Alt account: reset continuously to feed main
    task.spawn(function()
        FarmLoopRunning = true
        task.wait(1) -- Initial buffer
        
        while FarmLoopRunning do
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                if LocalPlayer.Character.Humanoid.Health > 0 then
                    ResetCharacter()
                end
            end
            -- Match timing with main account cycle
            task.wait(6)
        end
    end)
end

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

print(string.format("[TSB Farm] %s initialized as %s", LocalPlayer.Name, IsMain and "MAIN" or "ALT"))
print("[TSB Farm] Farm position: 439, 440, -376")
if IsMain then
    print("[TSB Farm] Mode: Using 4th skill then resetting")
else
    print("[TSB Farm] Mode: Resetting to feed main")
end
