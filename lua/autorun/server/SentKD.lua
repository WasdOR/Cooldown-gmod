sql.Query("CREATE TABLE IF NOT EXISTS sentkd_cooldown_table (name TEXT PRIMARY KEY, cooldown INTEGER)")
sql.Query("INSERT OR IGNORE INTO sentkd_cooldown_table (name, cooldown) VALUES ('Не Удалять!Wаrning!', 'Не Удалять!')")  --DONT TOUCH!

local EntityTable = sql.Query("SELECT * FROM sentkd_cooldown_table ")
local playerCooldowns = {}
local nets = util.AddNetworkString

nets("SpawnSentKD_")
nets("SpawnSentKD_Message")
nets("SpawnSentKD_StartMessage")
nets("SpawnSentKD_MenuTrigger")
nets("SpawnSentKD_MenuTriggerTable")
nets("SpawnSentKD_MenuTriggerTableDel")
nets("SpawnSentKD_MenuTriggerReturMenu")

local function BlockEntitySpawn(ply, mdl) 
    for _, v in pairs(EntityTable) do 
        if string.match(mdl, v.name) then 

            if playerCooldowns[ply:SteamID64()] and playerCooldowns[ply:SteamID64()][v.name] then 

                net.Start("SpawnSentKD_Message") 
                net.WriteString( playerCooldowns[ply:SteamID64()][v.name] ) 
                net.Send(ply) 
                return false  

            else 

                playerCooldowns[ply:SteamID64()] = playerCooldowns[ply:SteamID64()] or {} 
                playerCooldowns[ply:SteamID64()][v.name] = v.cooldown  
                net.Start("SpawnSentKD_StartMessage") 
                net.WriteString( playerCooldowns[ply:SteamID64()][v.name] ) 
                net.Send(ply) 

                local playerTimer = timer.Create("spawnCooldown_" .. ply:SteamID64() .. "_" .. v.name, 1, 0, function() 
                    playerCooldowns[ply:SteamID64()][v.name] = playerCooldowns[ply:SteamID64()][v.name] - 1 

                    if playerCooldowns[ply:SteamID64()][v.name] <= 0 then 

                        timer.Remove("spawnCooldown_" .. ply:SteamID64() .. "_" .. v.name)
                        playerCooldowns[ply:SteamID64()][v.name] = nil
                        net.Start("SpawnSentKD_")  
                        net.Send(ply) 

                    end 
                    
                end) 

                return true 
            end 
        end 
    end 
end

net.Receive("SpawnSentKD_MenuTriggerTable", function()

    local NameEntryKD = net.ReadString()
    local cooldownKD = net.ReadFloat()

    table.insert(EntityTable, { name = NameEntryKD, cooldown = cooldownKD })
    sql.Query("INSERT INTO sentkd_cooldown_table (name, cooldown) VALUES ('" .. NameEntryKD .. "', " .. cooldownKD .. ")")

end)

net.Receive("SpawnSentKD_MenuTriggerTableDel", function(len, ply)

    local namedel = net.ReadString()
    local index = nil
    for i, v in ipairs(EntityTable) do
        if v.name == namedel then
            index = i
        end
    end

    
    if index then
       
        table.remove(EntityTable, index)
        sql.Query("DELETE FROM sentkd_cooldown_table WHERE name = '" .. namedel .. "'")

    end

end)

net.Receive("SpawnSentKD_MenuTriggerReturMenu", function()

    local plymenu = net.ReadPlayer()
    local Priva = plymenu:GetUserGroup()

    net.Start("SpawnSentKD_MenuTrigger")
    net.WriteString(Priva)
    net.WriteTable(EntityTable)
    net.WritePlayer(plymenu)
    net.Send(plymenu)

end)

hook.Add("PlayerDisconnected", "PlayerleaveKD", function(ply)
    if playerCooldowns[ply:SteamID64()] then
        for k, _ in pairs(playerCooldowns[ply:SteamID64()]) do
            timer.Remove("spawnCooldown_" .. ply:SteamID64() .. "_" .. k)
        end
        playerCooldowns[ply:SteamID64()] = nil
    end
end)

hook.Add( "PlayerInitialSpawn", "PlayerJoinKD", function(ply)
    
    if playerCooldowns[ply:SteamID64()] and playerCooldowns[ply:SteamID64()][v.name] then    

        timer.Remove("spawnCooldown_" .. ply:SteamID64())
        playerCooldowns[ply:SteamID64()] = nil
        playerCooldowns[ply:SteamID64()][v.name] = nil

    end

end )

hook.Add( "PlayerSay", "OpenMenuSay", function( ply, text )

    local Priva = ply:GetUserGroup()
    

	if ( string.lower( text ) == "!kd" ) then
		
        net.Start("SpawnSentKD_MenuTrigger")
        net.WriteString(Priva)
        net.WriteTable(EntityTable)
        net.WritePlayer(ply)
        net.Send(ply)
        
  
	end
end )

hook.Add("PlayerSpawnSENT", "SpawnSent_Kd_", BlockEntitySpawn)
hook.Add("PlayerSpawnProp", "SpawnProp_Kd_", BlockEntitySpawn)
hook.Add("PlayerSpawnRagdoll", "SpawnRag_Kd_", BlockEntitySpawn)
hook.Add("PlayerSpawnNPC", "SpawnNpc_Kd_", BlockEntitySpawn)
hook.Add("PlayerSpawnSWEP", "SpawnSwep_Kd_", BlockEntitySpawn)
hook.Add( "PlayerGiveSWEP", "BlockPlayerSWEPs_kd_", BlockEntitySpawn)




print("---Cooldown_Loaded!---")
print("---By WasDiK---")
