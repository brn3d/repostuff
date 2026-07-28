local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

getgenv().rapidFire = true

-- Apply rapid fire cooldown removal
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

-- Apply on startup
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

-- Auto-fire using tool:Activate() 
local firing = false
local AutoFireConnection = nil

local function autoFire()
    AutoFireConnection = RunService.Heartbeat:Connect(function()
        if not firing then return end
        
        local tool = plr.Character and plr.Character:FindFirstChildOfClass("Tool")
        if tool then
            -- Keep cooldown at 0 every frame
            local cooldown = tool:FindFirstChild("ShootingCooldown")
            if cooldown then cooldown.Value = 0 end
            
            -- Fire the gun
            pcall(function()
                tool:Activate()
            end)
        end
    end)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        firing = true
        if not AutoFireConnection then
            autoFire()
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        firing = false
        if AutoFireConnection then
            AutoFireConnection:Disconnect()
            AutoFireConnection = nil
        end
    end
end)

getgenv().applyRapidFire = applyAll
print("Auto-fire loaded!")
print("Hold mouse button to auto-fire rapidly")
print("Run getgenv().applyRapidFire() to reapply to new weapons")
