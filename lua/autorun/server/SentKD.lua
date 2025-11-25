sql.Query("CREATE TABLE IF NOT EXISTS kd_entities (name TEXT PRIMARY KEY, cooldown INTEGER)")
util.AddNetworkString("KD_AddEntity")
util.AddNetworkString("KD_RemoveEntity")
util.AddNetworkString("KD_RequestList")
util.AddNetworkString("KD_UpdateList")
util.AddNetworkString("SpawnSentKD_StartMessage")
util.AddNetworkString("SpawnSentKD_Message") 
util.AddNetworkString("SpawnSentKD_")
util.AddNetworkString("SpawnSentKD_Command")

local Entities = {}
local Cooldowns = {}

local function LoadEntities()
    local data = sql.Query("SELECT * FROM kd_entities") or {}
    for _, row in ipairs(data) do
        table.insert(Entities, {name = row.name, cooldown = tonumber(row.cooldown)})
    end
end

LoadEntities()

local function SaveEntity(name, cooldown)
    sql.Query("INSERT OR REPLACE INTO kd_entities (name, cooldown) VALUES (" .. sql.SQLStr(name) .. ", " .. cooldown .. ")")
end

local function RemoveEntity(name)
    sql.Query("DELETE FROM kd_entities WHERE name = " .. sql.SQLStr(name))
end

local function CheckCooldown(ply, model)
    for _, ent in pairs(Entities) do
        if string.match(model, ent.name) then
            local steamID = ply:SteamID64()
            local cooldown = Cooldowns[steamID] and Cooldowns[steamID][ent.name]

            if cooldown then
                ply:ChatPrint("Кулдаун: " .. cooldown .. " сек.")
                return false
            end

            Cooldowns[steamID] = Cooldowns[steamID] or {}
            Cooldowns[steamID][ent.name] = ent.cooldown

            ply:ChatPrint("Кулдаун начался: " .. ent.cooldown .. " сек.")

            timer.Create("Cooldown_" .. steamID .. "_" .. ent.name, 1, ent.cooldown, function()
                Cooldowns[steamID][ent.name] = Cooldowns[steamID][ent.name] - 1

                if Cooldowns[steamID][ent.name] <= 0 then
                    Cooldowns[steamID][ent.name] = nil
                    ply:ChatPrint("Кулдаун закончился!")
                end
            end)

            return true
        end
    end
end

net.Receive("KD_AddEntity", function(_, ply)
    if not ply:IsAdmin() then return end
    
    local name = net.ReadString()
    local cooldown = net.ReadUInt(16)
    
    table.insert(Entities, {name = name, cooldown = cooldown})
    SaveEntity(name, cooldown)
end)

net.Receive("KD_RemoveEntity", function(_, ply)
    if not ply:IsAdmin() then return end
    
    local name = net.ReadString()
    
    for i, ent in ipairs(Entities) do
        if ent.name == name then
            table.remove(Entities, i)
            RemoveEntity(name)
            break
        end
    end
end)

net.Receive("KD_RequestList", function(_, ply)
    if not ply:IsAdmin() then return end
    
    net.Start("KD_UpdateList")
    net.WriteTable(Entities)
    net.Send(ply)
end)


local function CheckCooldown(ply, model)
    for _, ent in pairs(Entities) do
        if string.match(model, ent.name) then
            local steamID = ply:SteamID64()
            local cooldown = Cooldowns[steamID] and Cooldowns[steamID][ent.name]

            if cooldown then
                net.Start("SpawnSentKD_Message")
                net.WriteString(cooldown)
                net.Send(ply)
                return false
            end

            Cooldowns[steamID] = Cooldowns[steamID] or {}
            Cooldowns[steamID][ent.name] = ent.cooldown

            net.Start("SpawnSentKD_StartMessage")
            net.WriteString(ent.cooldown)
            net.Send(ply)

            timer.Create("Cooldown_" .. steamID .. "_" .. ent.name, 1, ent.cooldown, function()
                Cooldowns[steamID][ent.name] = Cooldowns[steamID][ent.name] - 1

                if Cooldowns[steamID][ent.name] <= 0 then
                    Cooldowns[steamID][ent.name] = nil
                    net.Start("SpawnSentKD_")
                    net.Send(ply)
                end
            end)

            return true
        end
    end
end

local function UpdateDuplicatorRestrictions()
    for _, ent in pairs(Entities) do
        duplicator.Disallow(ent.name)
    end
end

UpdateDuplicatorRestrictions()

net.Receive("KD_AddEntity", function(_, ply)
    if not ply:IsAdmin() then return end
    
    local name = net.ReadString()
    local cooldown = net.ReadUInt(16)
    
    table.insert(Entities, {name = name, cooldown = cooldown})
    SaveEntity(name, cooldown)
    
    duplicator.Disallow(name)
end)

net.Receive("KD_RemoveEntity", function(_, ply)
    if not ply:IsAdmin() then return end
    
    local name = net.ReadString()
    
    for i, ent in ipairs(Entities) do
        if ent.name == name then
            table.remove(Entities, i)
            RemoveEntity(name)
            break
        end
    end
    
    UpdateDuplicatorRestrictions()
end)

hook.Add("PlayerDisconnected", "CleanupCooldowns", function(ply)
    local steamID = ply:SteamID64()
    if Cooldowns[steamID] then
        for name in pairs(Cooldowns[steamID]) do
            timer.Remove("Cooldown_" .. steamID .. "_" .. name)
        end
        Cooldowns[steamID] = nil
    end
end)

hook.Add( "PlayerSay", "CoinFlip", function( ply, text )
	if string.lower( text ) == "!kd" then
		net.Start("SpawnSentKD_Command")
        net.Send(ply)
		return ""
	end
end )
hook.Add("PlayerSpawnSENT", "SpawnCooldown", CheckCooldown)
hook.Add("PlayerSpawnProp", "SpawnCooldown", CheckCooldown)
hook.Add("PlayerSpawnRagdoll", "SpawnCooldown", CheckCooldown)
hook.Add("PlayerSpawnNPC", "SpawnCooldown", CheckCooldown)
hook.Add("PlayerSpawnSWEP", "SpawnCooldown", CheckCooldown)
hook.Add("PlayerGiveSWEP", "SpawnCooldown", CheckCooldown)

print("--- By Babai LOL ---")
print("--- By WasDiK Ebaniy ROT! ---")
print("--- Cooldown System Loaded ---")
