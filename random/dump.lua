local Players = game:GetService("Players")
local plr = Players.LocalPlayer

local output = ""

local function addOutput(text)
    output = output .. text .. "\n"
    print(text)
end

local function dumpGunScript()
    output = ""
    addOutput("=== GUNSCRIPT DUMP ===\n")
    
    if not plr.Character then
        addOutput("No character found!")
        return
    end
    
    local tool = plr.Character:FindFirstChildOfClass("Tool")
    if not tool then
        addOutput("No equipped tool!")
        return
    end
    
    addOutput("Tool: " .. tool.Name .. "\n")
    
    local gunScript = tool:FindFirstChild("GunScript")
    if not gunScript then
        addOutput("GunScript not found!")
        return
    end
    
    addOutput("--- GunScript Source ---\n")
    
    if gunScript:IsA("LocalScript") then
        addOutput("Type: LocalScript")
    else
        addOutput("Type: Script")
    end
    
    addOutput("Disabled: " .. tostring(gunScript.Disabled))
    
    -- Try to get the source
    pcall(function()
        local source = gunScript.Source
        if source and #source > 0 then
            addOutput("\nSource code:")
            addOutput(source)
        else
            addOutput("Source is empty or protected")
        end
    end)
    
    -- Try to get environment functions
    addOutput("\n--- GunScript Environment ---")
    pcall(function()
        local env = debug.getfenv(gunScript)
        local functions = {}
        local variables = {}
        
        for k, v in pairs(env) do
            if type(v) == "function" then
                table.insert(functions, k)
            elseif type(v) ~= "userdata" and type(v) ~= "table" then
                table.insert(variables, k .. " = " .. tostring(v))
            end
        end
        
        table.sort(functions)
        table.sort(variables)
        
        addOutput("\nFunctions:")
        for _, fname in ipairs(functions) do
            addOutput("  " .. fname .. "()")
        end
        
        addOutput("\nVariables:")
        for _, vname in ipairs(variables) do
            addOutput("  " .. vname)
        end
    end)
    
    -- Try to get upvalues
    addOutput("\n--- GunScript Upvalues ---")
    pcall(function()
        local i = 1
        local found = false
        while i <= 100 do
            local name, value = debug.getupvalue(gunScript, i)
            if not name then break end
            
            if type(value) == "function" then
                addOutput(i .. ": " .. name .. " (function)")
            elseif type(value) == "table" then
                addOutput(i .. ": " .. name .. " (table)")
            elseif type(value) == "string" then
                addOutput(i .. ": " .. name .. " = \"" .. value .. "\"")
            elseif type(value) == "number" or type(value) == "boolean" then
                addOutput(i .. ": " .. name .. " = " .. tostring(value))
            else
                addOutput(i .. ": " .. name .. " (" .. type(value) .. ")")
            end
            found = true
            i = i + 1
        end
        if not found then
            addOutput("No upvalues found")
        end
    end)
    
    setclipboard(output)
    addOutput("\n[COPIED TO CLIPBOARD]")
end

local function dumpGunClient()
    output = ""
    addOutput("=== GUNCLIENT DUMP ===\n")
    
    if not plr.Character then
        addOutput("No character found!")
        return
    end
    
    local tool = plr.Character:FindFirstChildOfClass("Tool")
    if not tool then
        addOutput("No equipped tool!")
        return
    end
    
    addOutput("Tool: " .. tool.Name .. "\n")
    
    local gunClient = tool:FindFirstChild("GunClient") or tool:FindFirstChild("GunClientShotgun")
    if not gunClient then
        addOutput("GunClient not found!")
        return
    end
    
    addOutput("--- GunClient Source ---\n")
    
    if gunClient:IsA("LocalScript") then
        addOutput("Type: LocalScript")
    else
        addOutput("Type: Script")
    end
    
    addOutput("Disabled: " .. tostring(gunClient.Disabled))
    
    -- Try to get the source
    pcall(function()
        local source = gunClient.Source
        if source and #source > 0 then
            addOutput("\nSource code:")
            addOutput(source)
        else
            addOutput("Source is empty or protected")
        end
    end)
    
    setclipboard(output)
    addOutput("\n[COPIED TO CLIPBOARD]")
end

local function advancedDump()
    output = ""
    addOutput("=== ADVANCED TOOL DUMP ===\n")
    
    if not plr.Character then
        addOutput("No character found!")
        return
    end
    
    local tool = plr.Character:FindFirstChildOfClass("Tool")
    if not tool then
        addOutput("No equipped tool!")
        return
    end
    
    addOutput("Tool: " .. tool.Name .. " (PlaceId: " .. game.PlaceId .. ")\n")
    
    -- Dump all children
    addOutput("--- All Children ---")
    for _, child in ipairs(tool:GetChildren()) do
        addOutput(child.ClassName .. ": " .. child.Name)
        
        if child:IsA("LocalScript") or child:IsA("Script") then
            addOutput("  [Script] - Disabled: " .. tostring(child.Disabled) .. ", Source lines: " .. #child.Source)
        elseif child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
            addOutput("  [Remote] - Can use for server calls")
        elseif child:IsA("ValueBase") then
            addOutput("  [Value] - Current: " .. tostring(child.Value))
        end
    end
    
    -- Dump DataFolder
    addOutput("\n--- Player DataFolder ---")
    if plr:FindFirstChild("DataFolder") then
        local df = plr.DataFolder
        local inventory = df:FindFirstChild("Inventory")
        if inventory then
            addOutput("Inventory contents:")
            for _, item in ipairs(inventory:GetChildren()) do
                if item:IsA("StringValue") or item:IsA("IntValue") then
                    addOutput("  " .. item.Name .. ": " .. tostring(item.Value))
                end
            end
        end
    else
        addOutput("No DataFolder found")
    end
    
    -- Dump MainEvent details
    addOutput("\n--- MainEvent Details ---")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local mainEvent = ReplicatedStorage:FindFirstChild("MainEvent")
    if mainEvent then
        addOutput("MainEvent class: " .. mainEvent.ClassName)
        addOutput("MainEvent parent: " .. mainEvent.Parent.Name)
    end
    
    setclipboard(output)
    addOutput("\n[COPIED TO CLIPBOARD]")
end

getgenv().dumpGunScript = dumpGunScript
getgenv().dumpGunClient = dumpGunClient
getgenv().advancedDump = advancedDump

print("Run getgenv().dumpGunScript() to dump GunScript")
print("Run getgenv().dumpGunClient() to dump GunClient")
print("Run getgenv().advancedDump() for full analysis")
dumpGunScript()
