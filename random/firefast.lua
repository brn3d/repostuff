local Players = game:GetService("Players")
local plr = Players.LocalPlayer

getgenv().rapidFire = true

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
end

-- Apply to equipped tool and backpack on startup
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

-- Watch for new tools
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

-- Mouse hold to keep firing (cooldown stays at 0)
local mouse = plr:GetMouse()
local firing = false

mouse.Button1Down:Connect(function()
    firing = true
    while firing do
        local tool = plr.Character and plr.Character:FindFirstChildOfClass("Tool")
        if tool then
            local cooldown = tool:FindFirstChild("ShootingCooldown")
            if cooldown then
                cooldown.Value = 0
            end
        end
        task.wait(0.01)  -- 100 times per second cooldown resets
    end
end)

mouse.Button1Up:Connect(function()
    firing = false
end)

getgenv().applyRapidFire = applyAll
print("Rapid fire active. Hold mouse button to fire!")
print("Run getgenv().applyRapidFire() to reapply to new weapons.")
