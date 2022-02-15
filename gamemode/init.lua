resource.AddFile( "resource/fonts/montserrat-bold.ttf" )
resource.AddFile( "resource/fonts/montserrat-medium.ttf" )

-- SHARED LOAD --
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

-- CLIENT LOAD --
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "client/cl_bshadows.lua" )
AddCSLuaFile( "client/cl_drawing.lua" )
AddCSLuaFile( "client/cl_fonts.lua" )
AddCSLuaFile( "client/cl_player.lua" )
AddCSLuaFile( "client/cl_hud.lua" )
AddCSLuaFile( "client/cl_equipment.lua" )
AddCSLuaFile( "client/cl_derma_popups.lua" )
AddCSLuaFile( "client/cl_admin.lua" )
AddCSLuaFile( "client/cl_monsters.lua" )
AddCSLuaFile( "client/cl_notifications.lua" )
AddCSLuaFile( "client/cl_resources.lua" )
AddCSLuaFile( "client/cl_gacha.lua" )
AddCSLuaFile( "client/cl_crafting.lua" )
AddCSLuaFile( "client/cl_quests.lua" )
AddCSLuaFile( "client/cl_panelmeta.lua" )
AddCSLuaFile( "client/cl_rewards.lua" )
AddCSLuaFile( "client/cl_map.lua" )
AddCSLuaFile( "client/cl_characters.lua" )
AddCSLuaFile( "client/cl_party_system.lua" )

-- SERVER LOAD --
include( "server/sv_sqllite.lua" )
include( "server/sv_player.lua" )
include( "server/sv_equipment.lua" )
include( "server/sv_models.lua" )
include( "server/sv_admin.lua" )
include( "server/sv_monsters.lua" )
include( "server/sv_resources.lua" )
include( "server/sv_gacha.lua" )
include( "server/sv_crafting.lua" )
include( "server/sv_quests.lua" )
include( "server/sv_rewards.lua" )
include( "server/sv_map.lua" )
include( "server/sv_characters.lua" )
include( "server/sv_party_system.lua" )

-- VGUI LOAD --
for k, v in pairs( file.Find( GM.FolderName .. "/gamemode/vgui/*.lua", "LUA" ) ) do
	AddCSLuaFile( "vgui/" .. v )
end

DEFINE_BASECLASS( "gamemode_base" )

util.AddNetworkString( "Botched.SendFirstSpawn" )
function GM:PlayerInitialSpawn( ply )
    BOTCHED.FUNC.SQLQuery( "SELECT * FROM botched_players WHERE steamID64 = '" .. ply:SteamID64() .. "';", function( data )
        if( data ) then
            local userID = tonumber( data.userID or "" ) or 1 
            ply:SetUserID( userID )
            ply:SetStamina( tonumber( data.stamina or "" ) or 0, true )
            ply:SetGems( tonumber( data.gems or "" ) or 0, true )
            ply:SetMana( tonumber( data.mana or "" ) or 0, true )
            ply:SetMagicCoins( tonumber( data.magicCoins or "" ) or 0, true )
            ply:SetLevel( tonumber( data.level or "" ) or 1, true )
            ply:SetExperience( tonumber( data.experience or "" ) or 0, true )
            ply:SetPreviousTimePlayed( tonumber( data.timePlayed or "" ) or 0 )

            timer.Simple( 0, function() 
                if( data.character and BOTCHED.CONFIG.Characters[data.character] ) then
                    ply:SetChosenCharacter( data.character, true )
                else
                    ply:SetChosenCharacter( "default" ) 
                end
            end )

            if( ply:Stamina() < ply:GetMaxStamina() ) then
                local lastPlayed = tonumber( data.lastPlayed or "" ) or 0

                if( lastPlayed > 0 ) then 
                    local timeSince = os.time()-lastPlayed
                    local staminaToGive = math.floor( timeSince/60 )
                    
                    if( staminaToGive > 0 ) then
                        ply:SetStamina( math.min( ply:Stamina()+staminaToGive, ply:GetMaxStamina() ) ) 
                    end
                end
            end

            BOTCHED.FUNC.SQLQuery( "SELECT * FROM botched_owned_characters WHERE userID = '" .. userID .. "';", function( data )
                if( not data ) then return end

                local ownedCharacters = {}
                for k, v in pairs( data or {} ) do
                    if( not v.characterKey ) then continue end
                    ownedCharacters[v.characterKey] = {}
                end

                ply:SetCharacters( ownedCharacters )
            end )

            BOTCHED.FUNC.SQLQuery( "SELECT * FROM botched_owned_equipment WHERE userID = '" .. userID .. "';", function( data )
                if( not data ) then return end
                
                local ownedEquipment = {}
                for k, v in pairs( data or {} ) do
                    if( not v.equipmentKey ) then continue end
                    ownedEquipment[v.equipmentKey] = {
                        Rank = tonumber( v.rank or "" ),
                        Stars = tonumber( v.stars or "" )
                    }
                end

                ply:SetEquipment( ownedEquipment )
            end )

            BOTCHED.FUNC.SQLQuery( "SELECT * FROM botched_chosen_equipment WHERE userID = '" .. userID .. "';", function( data )
                if( not data ) then return end

                local chosenEquipment = {
                    primaryWeapon = data.primaryWeapon != "NULL" and data.primaryWeapon,
                    secondaryWeapon = data.secondaryWeapon != "NULL" and data.secondaryWeapon,
                    pickaxe = data.pickaxe != "NULL" and data.pickaxe,
                    hatchet = data.hatchet != "NULL" and data.hatchet,
                    armour = data.armour != "NULL" and data.armour,
                    trinket1 = data.trinket1 != "NULL" and data.trinket1,
                    trinket2 = data.trinket2 != "NULL" and data.trinket2
                }

                ply:SetChosenEquipment( chosenEquipment )
            end, true )

            BOTCHED.FUNC.SQLQuery( "SELECT * FROM botched_inventory WHERE userID = '" .. userID .. "';", function( data )
                if( not data ) then return end
                
                local inventory = {}
                for k, v in pairs( data or {} ) do
                    if( not v.itemKey ) then continue end
                    inventory[v.itemKey] = tonumber( v.amount or "" ) or 1
                end

                ply:SetInventory( inventory )
            end )

            BOTCHED.FUNC.SQLQuery( "SELECT * FROM botched_completed_quests WHERE userID = '" .. userID .. "';", function( data )
                if( not data ) then return end
                
                local completedQuests = {}
                for k, v in pairs( data or {} ) do
                    local questLineKey, questKey = tonumber( v.questLineKey or "" ), tonumber( v.questKey or "" )
                    if( not questLineKey or not questKey ) then continue end

                    completedQuests[questLineKey] = completedQuests[questLineKey] or {}
                    completedQuests[questLineKey][questKey] = tonumber( v.completionStars or 0 )
                end

                ply:SetCompletedQuests( completedQuests )
            end )

            BOTCHED.FUNC.SQLQuery( "SELECT * FROM botched_claimed_timerewards WHERE userID = '" .. userID .. "';", function( data )
                if( not data ) then return end
                
                local claimedRewards = {}
                for k, v in pairs( data or {} ) do
                    local rewardKey = tonumber( v.rewardKey or "" )
                    if( not rewardKey ) then continue end

                    claimedRewards[rewardKey] = tonumber( v.claimTime or "" ) or 0
                end

                ply:SetClaimedTimeRewards( claimedRewards )
            end )

            BOTCHED.FUNC.SQLQuery( "SELECT * FROM botched_claimed_loginrewards WHERE userID = '" .. userID .. "';", function( data )
                if( not data ) then return end
                
                ply:SetLoginRewardInfo( (tonumber( data.daysClaimed or "" ) or 0), (tonumber( data.claimTime or "" ) or 0) )
            end, true )
        else
            BOTCHED.FUNC.SQLQuery( "INSERT INTO botched_players( steamID64 ) VALUES(" .. ply:SteamID64() .. ");", function()
                BOTCHED.FUNC.SQLQuery( "SELECT * FROM botched_players WHERE steamID64 = '" .. ply:SteamID64() .. "';", function( data )
                    if( data ) then
                        local userID = tonumber( data.userID or "" ) or 1 
                        ply:SetUserID( userID )
                        ply:SetGems( 500 )
                        ply:SetStamina( 100 )
                        ply:GiveCharacters( "default" )
                        ply:GiveEquipment( "basic_pick", "basic_hatchet", "sword_nail_bat" )
                        timer.Simple( 0, function() ply:SetChosenCharacter( "default" ) end )
                    else
                        ply:Kick( "ERROR: Could not create unique UserID, try rejoining!\n\nReport your error here: discord.gg/NAaTvpK8vQ" )
                    end
                end, true )
            end )
        end
    end, true )

    net.Start( "Botched.SendFirstSpawn" )
    net.Send( ply )

    net.Start( "Botched.SendToggleQuestHUD" )
    net.Send( ply )

    ply:SetJoinTime( CurTime() )
end

function GM:PlayerGiveEquipmentStats( ply )
    local equipment = ply:GetEquipment()
    local chosenEquipment = ply:GetChosenEquipment()
    local statsToGive = {}
    for k, v in pairs( { "armour", "trinket1", "trinket2" } ) do
        local equipmentKey = chosenEquipment[v]

        if( not equipmentKey or not BOTCHED.CONFIG.Equipment[equipmentKey] or not equipment[equipmentKey] ) then continue end

        local equipmentConfig = BOTCHED.CONFIG.Equipment[equipmentKey]
        if( equipmentConfig and equipmentConfig.Stats ) then
            local equipmentRank = BOTCHED.CONFIG.EquipmentRanks[equipment[equipmentKey].Rank or 1] or {}
            local equipmentStar = BOTCHED.CONFIG.EquipmentStars[equipment[equipmentKey].Stars or equipmentConfig.Stars] or {}
            for k, v in pairs( equipmentConfig.Stats ) do
                if( not BOTCHED.DEVCONFIG.EquipmentStats[k] ) then return end

                statsToGive[k] = (statsToGive[k] or 0)+v+((v*(equipmentRank.StatMultiplier or 0))+(v*(equipmentStar.StatMultiplier or 0)))
            end
        end
    end

    if( table.Count( statsToGive ) > 0 ) then
        for k, v in pairs( statsToGive ) do
            if( not BOTCHED.DEVCONFIG.EquipmentStats[k].SetFunc ) then return end

            BOTCHED.DEVCONFIG.EquipmentStats[k].SetFunc( ply, v )
        end
    end
end

function GM:PlayerSpawn( ply, transiton )
    BaseClass.PlayerSpawn( self, ply, transiton )

    GAMEMODE:PlayerGiveEquipmentStats( ply )

    ply:SetHealth( ply:GetMaxHealth() )
    ply:SetSpeedMultiplier( 1 )
    ply:SetCollisionGroup( 11 )
end

function GM:PlayerLoadout( ply )
    ply:StripWeapons()
    ply:Give( "weapon_hands" )

    local equipment = ply:GetEquipment()
    local chosenEquipment = ply:GetChosenEquipment()
    for k, v in pairs( { "primaryWeapon", "secondaryWeapon", "pickaxe", "hatchet" } ) do
        local equipmentKey = chosenEquipment[v]

        if( not equipmentKey or not BOTCHED.CONFIG.Equipment[equipmentKey] or not equipment[equipmentKey] ) then continue end

        local equipmentConfig = BOTCHED.CONFIG.Equipment[equipmentKey]
        if( equipmentConfig ) then
            local weaponEnt = ply:Give( equipmentConfig.Class )

            if( IsValid( weaponEnt ) ) then
                if( equipmentConfig.RankColors and equipmentConfig.RankColors[equipment[equipmentKey].Rank or 1] ) then
                    weaponEnt:SetRankColor( equipmentConfig.RankColors[equipment[equipmentKey].Rank or 1]:ToVector() )
                end

                if( equipmentConfig.Stats ) then
                    local equipmentRank = BOTCHED.CONFIG.EquipmentRanks[equipment[equipmentKey].Rank or 1] or {}
                    local equipmentStar = BOTCHED.CONFIG.EquipmentStars[equipment[equipmentKey].Stars or equipmentConfig.Stars] or {}
                    for k, v in pairs( equipmentConfig.Stats ) do
                        if( not BOTCHED.DEVCONFIG.EquipmentStats[k] or not BOTCHED.DEVCONFIG.EquipmentStats[k].SetFunc ) then return end

                        timer.Simple( 0.5, function() 
                            if( not IsValid( weaponEnt ) ) then return end
                            BOTCHED.DEVCONFIG.EquipmentStats[k].SetFunc( weaponEnt, v+((v*(equipmentRank.StatMultiplier or 0))+(v*(equipmentStar.StatMultiplier or 0))) ) 
                        end )
                    end
                end
            end
        end
    end

    if( ply:HasAdminPrivilege() ) then
        ply:Give( "weapon_admin_toolgun" )
    end

    ply:SelectPrimaryWeapon()

	return true
end

util.AddNetworkString( "Botched.SendOpenMainMenu" )
function GM:ShowSpare2( ply )
    net.Start( "Botched.SendOpenMainMenu" )
    net.Send( ply )
end

util.AddNetworkString( "Botched.SendToggleQuestHUD" )
function GM:ShowSpare1( ply )
    net.Start( "Botched.SendToggleQuestHUD" )
    net.Send( ply )
end

util.AddNetworkString( "Botched.SendOpenPartyMenu" )
function GM:ShowTeam( ply )
    net.Start( "Botched.SendOpenPartyMenu" )
    net.Send( ply )
end

function GM:ShowHelp( ply )
    if( ply:HasAdminPrivilege() ) then
        if( ply:GetActiveWeapon():GetClass() != "weapon_admin_toolgun" ) then
            ply:SelectWeapon( "weapon_admin_toolgun" )
        else
            ply:SelectPrimaryWeapon()
        end
    end
end

local menuKeys = {
    [KEY_B] = "",
    [KEY_I] = "inventory",
    [KEY_C] = "character"
}

hook.Add( "PlayerButtonDown", "Botched.PlayerButtonDown.MainMenu", function( ply, button ) 
    if( menuKeys[button] ) then
        net.Start( "Botched.SendOpenMainMenu" )
            net.WriteString( menuKeys[button] )
        net.Send( ply )
    end
end )

hook.Add( "PlayerDisconnected", "Botched.PlayerDisconnected.TimePlayed", function( ply ) 
    BOTCHED.FUNC.SQLQuery( "UPDATE botched_players SET timePlayed = " .. ply:GetTimePlayed() .. ", lastPlayed = " .. os.time() .. " WHERE userID = '" .. ply:GetUserID() .. "';" )
end )

function BOTCHED.FUNC.RegenPlayersHealth()
    for k, v in ipairs( player.GetAll() ) do
        if( v:Health() >= v:GetMaxHealth() ) then continue end

        v:SetHealth( math.min( v:Health()+v:GetHealthRegenAmount(), v:GetMaxHealth() ) )
    end
end

timer.Create( "BOTCHED.Timer.PlayerHealthRegen", 5, 0, function()
    BOTCHED.FUNC.RegenPlayersHealth()
end )

function BOTCHED.FUNC.RegenPlayersStamina()
    for k, v in ipairs( player.GetAll() ) do
        if( v:Stamina() >= v:GetMaxStamina() ) then continue end

        v:SetStamina( math.min( v:Stamina()+1, v:GetMaxStamina() ) )
    end
end

timer.Create( "BOTCHED.Timer.PlayerStaminaRegen", 60, 0, function()
    BOTCHED.FUNC.RegenPlayersStamina()
end )

hook.Add( "PlayerSpray", "Botched.PlayerSpray.Disable", function( ply )
	return true
end )

hook.Add( "PlayerCanSeePlayersChat", "Botched.PlayerCanSeePlayersChat.Proximity", function( text, teamOnly, listener, speaker )
	if( string.StartWith( text, "//" ) ) then 
        if( string.len( string.Trim( text ) ) <= 2 ) then return false end
        return 
    end
    
    if( listener:GetPos():DistToSqr( speaker:GetPos() ) > 100000 ) then 
        return false 
    end
end )

hook.Add( "PlayerCanHearPlayersVoice", "Botched.PlayerCanHearPlayersVoice.Proximity", function( listener, talker )
    if( listener:GetPos():DistToSqr( talker:GetPos() ) > 250000 ) then
		return false
	end
end )

hook.Add( "InitPostEntity", "Botched.InitPostEntity.Spawns", function( ply )
    for k, v in ipairs( BOTCHED.CONFIG.SpawnPoints ) do
        local ent = ents.Create( "info_player_start" )
        ent:SetPos( v )
        ent:Spawn()
        ent.ExtraSpawn = true
    end
end )

hook.Add( "PlayerSelectSpawn", "Botched.PlayerSelectSpawn.Spawns", function( ply )
    local closestSpawn, closestSpawnDist
    for k, v in ipairs( ents.FindByClass( "info_player_start" ) ) do
        if( not ply.HadFirstSpawn and v.ExtraSpawn ) then continue end

        local distance = ply:GetPos():DistToSqr( v:GetPos() )
        if( not closestSpawn ) then 
            closestSpawn = v
            closestSpawnDist = distance
            continue 
        end

        if( distance < closestSpawnDist ) then
            closestSpawn = v
            closestSpawnDist = distance
        end
    end

    ply.HadFirstSpawn = true
	return closestSpawn
end )

util.AddNetworkString( "Botched.SendPlayerConnected" )

gameevent.Listen( "player_connect" )
hook.Add( "player_connect", "Botched.player_connect.Connect", function( data )
	net.Start( "Botched.SendPlayerConnected" )
        net.WriteString( data.name )
        net.WriteString( data.networkid )
    net.Broadcast()
end )

util.AddNetworkString( "Botched.SendPlayerDisconnected" )

gameevent.Listen( "player_disconnect" )
hook.Add( "player_disconnect", "Botched.player_disconnect.Disconnect", function( data )
	net.Start( "Botched.SendPlayerDisconnected" )
        net.WriteString( data.name )
        net.WriteString( data.networkid )
        net.WriteString( data.reason )
    net.Broadcast()
end )

concommand.Add( "restart_alert", function()
    local timeIntervals = { 300, 240, 180, 120, 60, 45, 30, 15, 10, 5, 4, 3, 2, 1 }

    local function SendAlert( timeLeft )
        local message = "The server is restarting in " .. timeLeft/60 .. " minute" .. (timeLeft/60 != 1 and "s" or "") .. "!"
        if( timeLeft < 60 ) then
            message = "The server is restarting in " .. timeLeft .. " second" .. (timeLeft != 1 and "s" or "") .. "!"
        end

        print( "[RESTART] " .. message )

        for k, v in ipairs( player.GetAll() ) do
            v:SendNotification( 1, 5, message )
        end
    end

    for k, v in ipairs( timeIntervals ) do
        timer.Simple( timeIntervals[1]-v, function()
            SendAlert( v )

            if( k == #timeIntervals ) then
                for k, v in ipairs( player.GetAll() ) do
                    v:Kick( "Server restarting.\n\nYou can see update notes here: discord.gg/NAaTvpK8vQ" )
                end
            end
        end )
    end
end )