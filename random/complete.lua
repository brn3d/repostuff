local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

getgenv().rapidFire = true
getgenv().autoFiring = false

-- Step 1: Apply rapid fire cooldown removal (from rapid.lua - known to work)
local function zeroAndReinit(tool)
    if not tool or not tool.Parent then return end
    
    local gunClient = tool:FindFirstChild("GunClient") or tool:FindFirstChild("GunClientShotgun")
    if not gunClient then return end
    
    local cooldown = tool:FindFirstChild("ShootingCooldown")
    if cooldown then cooldown.Value = 0 end
    
    local clone = gunClient:Clone()
    gunClient.Disabled = true
    clone.Disabled = false
    clone.Parent = tool
    gunClient:Destroy()
    
    print("Rapid fire applied to: " .. tool.Name)
end

local function applyAll()
    if not plr.Character then return end
    local tool = plr.Character:FindFirstChildOfClass("Tool")
    if tool and (tool:FindFirstChild("GunClient") or tool:FindFirstChild("GunClientShotgun")) then
        zeroAndReinit(tool)
    end
    for _, t in ipairs(plr.Backpack:GetChildren()) do
        if t:IsA("Tool") then
            local c = t:FindFirstChild("ShootingCooldown")
            if c then c.Value = 0 end
        end
    end
end

applyAll()

local function watchChar(char)
    char.ChildAdded:Connect(function(child)
        if not getgenv().rapidFire then return end
        if child:IsA("Tool") then
            task.wait(0.1)
            zeroAndReinit(child)
        end
    end)
end

if plr.Character then watchChar(plr.Character) end
plr.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    applyAll()
    watchChar(char)
end)
plr.Backpack.ChildAdded:Connect(function(t)
    if t:IsA("Tool") then
        local c = t:FindFirstChild("ShootingCooldown")
        if c then c.Value = 0 end
    end
end)

-- Step 2: Auto-fire on mouse hold using tool:Activate()
local mouse = plr:GetMouse()
local firing = false
local fireThread = nil

local function fireLoop()
    while firing do
        if plr.Character then
            local tool = plr.Character:FindFirstChildOfClass("Tool")
            if tool then
                -- Keep resetting cooldown
                local cooldown = tool:FindFirstChild("ShootingCooldown")
                if cooldown then cooldown.Value = 0 end
                
                -- Fire the gun
                pcall(function()
                    tool:Activate()
                end)
            end
        end
        task.wait(0.001)  -- Fire as fast as possible
    end
end

mouse.Button1Down:Connect(function()
    firing = true
    fireThread = task.spawn(fireLoop)
end)

mouse.Button1Up:Connect(function()
    firing = false
end)

-- Step 3: Keep cooldown at 0 every frame
RunService.Heartbeat:Connect(function()
    if plr.Character then
        local tool = plr.Character:FindFirstChildOfClass("Tool")
        if tool then
            local cooldown = tool:FindFirstChild("ShootingCooldown")
            if cooldown then 
                cooldown.Value = 0 
            end
        end
    end
end)

getgenv().applyRapidFire = applyAll
print("Complete rapid fire system loaded!")
print("1. Rapid fire applied on startup")
print("2. Hold mouse button to fire rapidly")
print("3. Cooldown kept at 0 every frame")
print("Run getgenv().applyRapidFire() to reapply to new weapons")
