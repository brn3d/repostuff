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

getgenv().applyRapidFire = applyAll
print("Rapid fire active. Run getgenv().applyRapidFire() to reapply.")
