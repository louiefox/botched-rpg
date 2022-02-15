function BOTCHED.FUNC.LoadResourceSpawns()
	if( not file.IsDir( "botched/resource_spawns", "DATA" ) ) then
		file.CreateDir( "botched/resource_spawns", "DATA" )
	end
	
	BOTCHED.ResourceSpawns = {}
	if( file.Exists( "botched/resource_spawns/".. string.lower( game.GetMap() ) ..".txt", "DATA" ) ) then
		BOTCHED.ResourceSpawns = util.JSONToTable( file.Read( "botched/resource_spawns/".. string.lower( game.GetMap() ) ..".txt", "DATA" ) )
	end
end
BOTCHED.FUNC.LoadResourceSpawns()

function BOTCHED.FUNC.SaveResourceSpawns()
    if( not file.IsDir( "botched/resource_spawns", "DATA" ) ) then
        file.CreateDir( "botched/resource_spawns", "DATA" )
    end

    file.Write( "botched/resource_spawns/".. string.lower( game.GetMap() ) ..".txt", util.TableToJSON( BOTCHED.ResourceSpawns or {} ), "DATA" )
end

function BOTCHED.FUNC.SendAdminsResourceSpawns()
    for k, v in ipairs( player.GetAll() ) do
        if( v:HasAdminPrivilege() ) then
            v:SendResourceSpawns()
        end
    end
end

hook.Add( "InitPostEntity", "Botched.InitPostEntity.Resources", function()
    for k, v in pairs( BOTCHED.DEVCONFIG.ResourceTypes ) do
        timer.Create( "BOTCHED.Timer.ResourceTimer_" .. k, v.RespawnTime, 0, function()
            for key, val in pairs( BOTCHED.ResourceSpawns ) do
                if( val.Type != k ) then continue end

                local dontSpawn = false
                for key2, val2 in ipairs( ents.FindInSphere( val.Pos, 1 ) ) do
                    if( val2:GetClass() == v.EntityClass ) then
                        dontSpawn = true
                        break
                    end
                end

                if( dontSpawn ) then continue end

                local resourceEnt = ents.Create( v.EntityClass )
                resourceEnt:SetPos( val.Pos )
                resourceEnt:SetAngles( val.Angles )
                resourceEnt:Spawn()
            end
        end )
    end
end )

-- PLAYER FUNCTIONS --
local playerMeta = FindMetaTable( "Player" )

util.AddNetworkString( "Botched.SendAdminResourceSpawns" )
function playerMeta:SendResourceSpawns()
    net.Start( "Botched.SendAdminResourceSpawns" )
        net.WriteTable( BOTCHED.ResourceSpawns )
    net.Send( self )
end