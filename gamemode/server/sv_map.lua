local function CalculateSize(na, size, nb, x, y, z, try)
    local res
    local End = 0

    for i = na, size, nb do
        if util.IsInWorld(Vector(x or i, y or i, z or i)) and End < try then
            res = i

            if End > 0 then
                End = 0
            end
        else
            End = End + 1

            if End >= try then
                break
            end
        end
    end
    return res
end

local function GenerateMapSize()
    local nb = 45
    local try = 3
    local size = 99999999

    local mapTable = {}
    for k, v in pairs(ents.GetAll()) do
        if string.find(v:GetClass(), "info_player_") then
            local startVector = v:GetPos()

            mapTable.SizeHeight = CalculateSize(startVector.z, size, nb, startVector.x, startVector.y, nil, try)

            mapTable.SizeN = CalculateSize(startVector.y, size, nb, startVector.x, nil, mapTable.SizeHeight, try)
            mapTable.SizeW = CalculateSize(startVector.x, -size, -nb, nil, startVector.y, mapTable.SizeHeight, try)
            mapTable.SizeS = CalculateSize(startVector.y, -size, -nb, startVector.x, nil, mapTable.SizeHeight, try)
            mapTable.SizeE = CalculateSize(startVector.x, size, nb, nil, startVector.y, mapTable.SizeHeight, try)
            
            mapTable.SizeHeight = math.Round(mapTable.SizeHeight)
            mapTable.SizeN = math.Round(mapTable.SizeN)
            mapTable.SizeW = math.Round(mapTable.SizeW)
            mapTable.SizeS = math.Round(mapTable.SizeS)
            mapTable.SizeE = math.Round(mapTable.SizeE)

            mapTable.SizeX = mapTable.SizeE + math.abs(mapTable.SizeW)
            mapTable.SizeY = mapTable.SizeN + math.abs(mapTable.SizeS)

            mapTable.SizeX = math.abs(mapTable.SizeX)
            mapTable.SizeY = math.abs(mapTable.SizeY)
            break
        end
    end

    if( not mapTable.SizeHeight or not mapTable.SizeW or not mapTable.SizeE or not mapTable.SizeS or not mapTable.SizeN ) then return end

    BOTCHED.TEMP.Map = mapTable
end
GenerateMapSize()

util.AddNetworkString( "Botched.RequestMapSize" )
util.AddNetworkString( "Botched.SendMapSize" )
net.Receive( "Botched.RequestMapSize", function( len, ply )
    if( not BOTCHED.TEMP.Map ) then GenerateMapSize() end
    local shouldOpenMap = net.ReadBool()

    net.Start( "Botched.SendMapSize" )
        net.WriteBool( shouldOpenMap )
        net.WriteTable( BOTCHED.TEMP.Map )
    net.Send( ply )
end )

util.AddNetworkString( "Botched.SendOpenMap" )
hook.Add( "PlayerButtonDown", "Botched.PlayerButtonDown.OpenMap", function( ply, key )
    if( key == KEY_M ) then
        net.Start( "Botched.SendOpenMap" )
        net.Send( ply )
    end
end )

util.AddNetworkString( "Botched.RequestMapTeleport" )
util.AddNetworkString( "Botched.SendMapTeleport" )
net.Receive( "Botched.RequestMapTeleport", function( len, ply )
    if( CurTime() < (ply.BOTCHED_TELEPORT_COOLDOWN or 0) ) then 
        ply:SendNotification( 1, 3, "You need to wait " .. math.Round( ply.BOTCHED_TELEPORT_COOLDOWN-CurTime() ) .. " seconds before teleporting again!" )
        return 
    end

    local teleportKey = net.ReadUInt( 4 )
    if( not teleportKey ) then return end

    local teleportConfig = BOTCHED.CONFIG.Map.Teleports[teleportKey]
    if( not teleportConfig ) then return end

	ply.BOTCHED_TELEPORT_COOLDOWN = CurTime()+30

    local timerID = "BOTCHED.Timer.MapTeleport." .. ply:SteamID64()
    timer.Create( timerID, teleportConfig.Duration, 1, function()
        if( not IsValid( ply ) ) then return end

        ply:SetPos( teleportConfig.Pos )
    end )

    net.Start( "Botched.SendMapTeleport" )
        net.WriteUInt( teleportKey, 4 )
        net.WriteUInt( CurTime()+timer.TimeLeft( timerID ), 22 )
    net.Send( ply )
end )