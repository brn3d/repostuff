local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local RunService = game:GetService("RunService")

getgenv().autoReload = true

local lastReloadTime = {}
local RELOAD_COOLDOWN = 0.1

local function getMainRemote()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    
    if ReplicatedStorage:FindFirstChild('MainEvent') then
        return ReplicatedStorage.MainEvent
    end
    if ReplicatedStorage:FindFirstChild('MAINEVENT') then
        return ReplicatedStorage.MAINEVENT
    end
    if ReplicatedStorage:FindFirstChild('Remote') then
        return ReplicatedStorage.Remote
    end
    if ReplicatedStorage:FindFirstChild('Bullets') then
        return ReplicatedStorage.Bullets
    end

    local mainRemotes = ReplicatedStorage:FindFirstChild('MainRemotes')
    if mainRemotes and mainRemotes:FindFirstChild('MainRemoteEvent') then
        return mainRemotes.MainRemoteEvent
    end

    return nil
end

local MainEvent = getMainRemote()

-- Auto reload when ammo runs out
local reloadConnection = RunService.Heartbeat:Connect(function()
    if not getgenv().autoReload then return end
    if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local tool = plr.Character:FindFirstChildOfClass("Tool")
    if not tool then return end
    
    local ammo = tool:FindFirstChild("Ammo")
    if not ammo or not ammo:IsA("IntValue") then return end
    
    -- Check if out of ammo
    if ammo.Value <= 0 then
        local currentTime = tick()
        if not lastReloadTime[tool] or (currentTime - lastReloadTime[tool]) > RELOAD_COOLDOWN then
            lastReloadTime[tool] = currentTime
            
            -- Try to reload via MainEvent
            if MainEvent then
                pcall(function()
                    MainEvent:FireServer('Reload', tool)
                end)
            end
            
            -- Also try direct reload
            pcall(function()
                tool:FindFirstChild("Reload"):FireServer()
            end)
        end
    end
end)

plr.CharacterAdded:Connect(function(char)
    lastReloadTime = {}
end)

getgenv().toggleAutoReload = function(state)
    getgenv().autoReload = state
end

print("Auto reload loaded!")
print("Will automatically reload when ammo runs out")
print("Run getgenv().toggleAutoReload(false) to disable")
