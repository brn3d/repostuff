local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

getgenv().reloadBypass = true

local MainEvent = ReplicatedStorage:FindFirstChild("MainEvent")

if not MainEvent then
    error("MainEvent not found!")
end

-- Continuously fire reload events
local bypassConnection = RunService.Heartbeat:Connect(function()
    if not getgenv().reloadBypass then return end
    
    if not plr.Character then return end
    local tool = plr.Character:FindFirstChildOfClass("Tool")
    if not tool then return end
    
    local ammo = tool:FindFirstChild("Ammo")
    if not ammo or not ammo:IsA("IntValue") then return end
    
    -- Fire reload constantly to keep ammo flowing
    pcall(function()
        MainEvent:FireServer("Reload", tool)
    end)
end)

getgenv().toggleReloadBypass = function(state)
    getgenv().reloadBypass = state
    if state then
        print("Reload bypass enabled - firing reload events")
    else
        print("Reload bypass disabled")
    end
end

print("Reload bypass loaded!")
print("Firing reload events continuously")
print("Run getgenv().toggleReloadBypass(false) to disable")
