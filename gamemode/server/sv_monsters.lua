function BOTCHED.FUNC.LoadMonsterSpawns()
	if( not file.IsDir( "botched/monster_spawns", "DATA" ) ) then
		file.CreateDir( "botched/monster_spawns", "DATA" )
	end
	
	BOTCHED.MonsterSpawns = {}
	if( file.Exists( "botched/monster_spawns/".. string.lower( game.GetMap() ) ..".txt", "DATA" ) ) then
		BOTCHED.MonsterSpawns = util.JSONToTable( file.Read( "botched/monster_spawns/".. string.lower( game.GetMap() ) ..".txt", "DATA" ) )
	end
end
BOTCHED.FUNC.LoadMonsterSpawns()

function BOTCHED.FUNC.SaveMonsterSpawns()
    if( not file.IsDir( "botched/monster_spawns", "DATA" ) ) then
        file.CreateDir( "botched/monster_spawns", "DATA" )
    end

    file.Write( "botched/monster_spawns/".. string.lower( game.GetMap() ) ..".txt", util.TableToJSON( BOTCHED.MonsterSpawns or {} ), "DATA" )
end

function BOTCHED.FUNC.SendAdminsMonsterSpawns()
    for k, v in ipairs( player.GetAll() ) do
        if( v:HasAdminPrivilege() ) then
            v:SendMonsterSpawns()
        end
    end
end

BOTCHED.TEMP.SpawnedMonsters = BOTCHED.TEMP.SpawnedMonsters or {}
function BOTCHED.FUNC.SpawnMonster( key )
    local monsterTable = BOTCHED.MonsterSpawns[key]
    if( not monsterTable ) then return end

    local monsterConfig = BOTCHED.CONFIG.Monsters[monsterTable.MonsterClass]
    if( not monsterConfig ) then return end

    if( BOTCHED.TEMP.SpawnedMonsters[key] and IsValid( BOTCHED.TEMP.SpawnedMonsters[key] ) ) then
        BOTCHED.TEMP.SpawnedMonsters[key]:Remove()
    end

    local monsterEnt = ents.Create( monsterConfig.Class )
    monsterEnt:SetPos( monsterTable.Pos+Vector( 0, 0, 15 ) )
    monsterEnt:SetAngles( monsterTable.Angles )
    monsterEnt:SetInitMonsterClass( monsterTable.MonsterClass )
    monsterEnt.SpawnKey = key
    monsterEnt:Spawn()

    BOTCHED.TEMP.SpawnedMonsters[key] = monsterEnt
end

hook.Add( "InitPostEntity", "Botched.InitPostEntity.Monsters", function()
    for k, v in pairs( BOTCHED.MonsterSpawns ) do
        BOTCHED.FUNC.SpawnMonster( k )
    end
end )

hook.Add( "EntityRemoved", "Botched.EntityRemoved.Monsters", function( ent )
    local key = ent.SpawnKey
    if( key and BOTCHED.MonsterSpawns[key] ) then
        timer.Create( "BOTCHED.Timer.MonsterSpawn_" .. key, BOTCHED.MonsterSpawns[key].RespawnTime or 60, 1, function()
            if( not BOTCHED.MonsterSpawns[key] ) then return end

            BOTCHED.FUNC.SpawnMonster( key )
        end )
    end
end )

hook.Add( "OnNPCKilled", "Botched.OnNPCKilled.Monsters", function( npc, attacker, inflictor )
    if( not attacker:IsPlayer() or not npc.IsMonster ) then return end

    local monsterClass = ""
    if( npc.GetMonsterClass ) then
        monsterClass = npc:GetMonsterClass()
    end

    local monsterConfig = BOTCHED.CONFIG.Monsters[monsterClass or ""] or {}
    if( not monsterClass ) then return end

    local rewardPlayers = { attacker }

    local partyID = attacker:GetPartyID()
    if( partyID != 0 ) then
        local partyTable = BOTCHED.FUNC.GetPartyTable( partyID )
        if( partyTable ) then
            for k, v in ipairs( partyTable.Members ) do
                if( not IsValid( v ) or v == attacker ) then continue end
                table.insert( rewardPlayers, v )
            end
        end
    end

    for k, v in ipairs( rewardPlayers ) do
        hook.Run( "Botched.Hooks.MonsterKilled", v, monsterClass, attacker == v )
    end
end )

hook.Add( "Botched.Hooks.MonsterKilled", "Botched.MonsterKilled.Experience", function( ply, monsterClass, isAttacker )
    local monsterConfig = BOTCHED.CONFIG.Monsters[monsterClass]

    ply:AddExperience( monsterConfig.PlayerEXP )

    local expText = (monsterConfig.Name or "Monster") .. " Killed"
    if( not isAttacker ) then
        expText = "Party Member Killed " .. (monsterConfig.Name or "Monster")
    end

    ply:SendExpNotification( monsterConfig.PlayerEXP, expText )
end )

-- PLAYER FUNCTIONS --
local playerMeta = FindMetaTable( "Player" )

util.AddNetworkString( "Botched.SendAdminMonsterSpawns" )
function playerMeta:SendMonsterSpawns()
    net.Start( "Botched.SendAdminMonsterSpawns" )
        net.WriteTable( BOTCHED.MonsterSpawns )
    net.Send( self )
end