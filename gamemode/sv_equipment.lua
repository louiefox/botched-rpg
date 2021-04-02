local weaponMeta = FindMetaTable( "Weapon" )

util.AddNetworkString( "Botched.SendWeaponVariable" )
function weaponMeta:SetWeaponVariable( variable, value, plyFallback )
	local owner = plyFallback or self.Owner
	if( not IsValid( owner ) ) then return end

	if( self.Primary and self.Primary[variable] ) then
		self.Primary[variable] = value
	else
		self[variable] = value
	end

	net.Start( "Botched.SendWeaponVariable" )
		net.WriteString( self:GetClass() )
		net.WriteString( variable )
		net.WriteFloat( value )
	net.Send( owner )
end

util.AddNetworkString( "Botched.RequestChooseEquipment" )
util.AddNetworkString( "Botched.SendChosenEquipmentPiece" )
net.Receive( "Botched.RequestChooseEquipment", function( len, ply )
    if( CurTime() < (ply.BOTCHED_LAST_EQUIP or 0)+1 ) then return end
    ply.BOTCHED_LAST_EQUIP = CurTime()
    
    local equipmentKey = net.ReadString()

    local equipmentConfig = BOTCHED.CONFIG.Equipment[equipmentKey or ""]
    if( not equipmentConfig ) then return end

    local equipment = ply:GetEquipment()
    if( not equipment[equipmentKey] ) then return end

    local chosenEquipment = ply:GetChosenEquipment()
    local type = equipmentConfig.Type
    if( chosenEquipment[type] and chosenEquipment[type] == equipmentKey ) then return end

    chosenEquipment[type] = equipmentKey
    ply.BOTCHED_CHOSEN_EQUIPMENT = chosenEquipment

    net.Start( "Botched.SendChosenEquipmentPiece" )
        net.WriteString( equipmentKey )
    net.Send( ply )

    BOTCHED.FUNC.SQLQuery( "SELECT * FROM botched_chosen_equipment WHERE userID = '" .. ply:GetUserID() .. "';", function( data )
        if( data ) then
            BOTCHED.FUNC.SQLQuery( "UPDATE botched_chosen_equipment SET " .. type .. " = '" .. equipmentKey .. "' WHERE userID = '" .. ply:GetUserID() .. "';" )
        else
            BOTCHED.FUNC.SQLQuery( "INSERT INTO botched_chosen_equipment( userID, " .. type .. " ) VALUES(" .. ply:GetUserID() .. ", '" .. equipmentKey .. "');" )
        end
    end, true )

    local weaponKeys = { "primaryWeapon", "secondaryWeapon", "pickaxe", "hatchet" }
    if( table.HasValue( weaponKeys, type ) ) then
        GAMEMODE:PlayerLoadout( ply )
    else
        GAMEMODE:PlayerGiveEquipmentStats( ply )
    end
end )

util.AddNetworkString( "Botched.RequestUnChooseEquipment" )
util.AddNetworkString( "Botched.SendUnChosenEquipmentPiece" )
net.Receive( "Botched.RequestUnChooseEquipment", function( len, ply )
    if( CurTime() < (ply.BOTCHED_LAST_EQUIP or 0)+1 ) then return end
    ply.BOTCHED_LAST_EQUIP = CurTime()

    local equipmentKey = net.ReadString()

    local equipmentConfig = BOTCHED.CONFIG.Equipment[equipmentKey or ""]
    if( not equipmentConfig ) then return end

    local equipment = ply:GetEquipment()
    if( not equipment[equipmentKey] ) then return end

    local chosenEquipment = ply:GetChosenEquipment()
    local type = equipmentConfig.Type
    if( not chosenEquipment[type] or chosenEquipment[type] != equipmentKey ) then return end

    chosenEquipment[type] = nil
    ply.BOTCHED_CHOSEN_EQUIPMENT = chosenEquipment

    net.Start( "Botched.SendUnChosenEquipmentPiece" )
        net.WriteString( equipmentKey )
    net.Send( ply )

    BOTCHED.FUNC.SQLQuery( "SELECT * FROM botched_chosen_equipment WHERE userID = '" .. ply:GetUserID() .. "';", function( data )
        if( data ) then
            BOTCHED.FUNC.SQLQuery( "UPDATE botched_chosen_equipment SET " .. type .. " = '' WHERE userID = '" .. ply:GetUserID() .. "';" )
        else
            BOTCHED.FUNC.SQLQuery( "INSERT INTO botched_chosen_equipment( userID, " .. type .. " ) VALUES(" .. ply:GetUserID() .. ", '');" )
        end
    end, true )

    local weaponKeys = { "primaryWeapon", "secondaryWeapon", "pickaxe", "hatchet" }
    if( table.HasValue( weaponKeys, type ) ) then
        GAMEMODE:PlayerLoadout( ply )
    else
        GAMEMODE:PlayerGiveEquipmentStats( ply )
    end
end )

util.AddNetworkString( "Botched.RequestEquipmentRankUp" )
net.Receive( "Botched.RequestEquipmentRankUp", function( len, ply )
    local equipmentKey = net.ReadString()

    local equipmentConfig = BOTCHED.CONFIG.Equipment[equipmentKey or ""]
    if( not equipmentConfig ) then return end

    local equipment = ply:GetEquipment()
    if( not equipment[equipmentKey] ) then return end

    local currentRank = equipment[equipmentKey].Rank or 1
    local nextRank = currentRank+1
    local nextRankConfig = BOTCHED.CONFIG.EquipmentRanks[nextRank]
    if( not nextRankConfig ) then return end

    if( nextRankConfig.Cost and not ply:CanAffordCost( nextRankConfig.Cost ) ) then
        ply:SendNotification( 1, 5, "You cannot afford this!" )
        return
    end

    ply:TakeCost( nextRankConfig.Cost )

    equipment[equipmentKey].Rank = nextRank
    ply.BOTCHED_EQUIPMENT = equipment

    net.Start( "Botched.SendEquipmentPiece" )
        net.WriteUInt( 1, 10 )

        net.WriteString( equipmentKey )
        net.WriteBool( true )
        net.WriteUInt( nextRank, 5 )

        net.WriteBool( equipment[equipmentKey].Stars != nil )
        if( equipment[equipmentKey].Stars ) then
            net.WriteUInt( equipment[equipmentKey].Stars, 5 )
        end
    net.Send( ply )

    BOTCHED.FUNC.SQLQuery( "UPDATE botched_owned_equipment SET rank = " .. nextRank .. " WHERE userID = '" .. ply:GetUserID() .. "' AND equipmentKey = '" .. equipmentKey .. "';" )

    local weaponKeys = { "primaryWeapon", "secondaryWeapon", "pickaxe", "hatchet" }
    if( table.HasValue( weaponKeys, equipmentConfig.Type ) ) then
        GAMEMODE:PlayerLoadout( ply )
    else
        GAMEMODE:PlayerGiveEquipmentStats( ply )
    end

    ply:SendNotification( 1, 5, "Equipment rank increased from " .. currentRank .. " to " .. nextRank .. "!" )
end )

util.AddNetworkString( "Botched.RequestEquipmentRefinement" )
net.Receive( "Botched.RequestEquipmentRefinement", function( len, ply )
    local equipmentKey = net.ReadString()

    local equipmentConfig = BOTCHED.CONFIG.Equipment[equipmentKey or ""]
    if( not equipmentConfig ) then return end

    local equipment = ply:GetEquipment()
    if( not equipment[equipmentKey] ) then return end

    local currentStar = equipment[equipmentKey].Stars or equipmentConfig.Stars
    local nextStar = currentStar+1
    local nextStarConfig = BOTCHED.CONFIG.EquipmentStars[nextStar]
    if( not nextStarConfig ) then return end

	local refinementMaterials = {}
	for i = 1, (net.ReadUInt( 3 ) or 0) do
		local itemKey, amount = net.ReadString(), net.ReadUInt( 20 )
		if( not itemKey or not BOTCHED.CONFIG.Items[itemKey] or not amount ) then return end

		refinementMaterials[itemKey] = amount
	end

	local totalPoints = 0
	for k, v in pairs( refinementMaterials ) do
		totalPoints = totalPoints+(((BOTCHED.CONFIG.Items[k] or {}).Points or 0)*v)
	end

	if( totalPoints < nextStarConfig.PointsRequired ) then
        ply:SendNotification( 1, 5, "You don't have enough refinement materials!" )
        return
	end

	local newCost = table.Copy( nextStarConfig.Cost )
	newCost.Items = refinementMaterials

    if( (newCost and not ply:CanAffordCost( newCost )) ) then
        ply:SendNotification( 1, 5, "You cannot afford this!" )
        return
    end

    ply:TakeCost( newCost )

    equipment[equipmentKey].Stars = nextStar
    ply.BOTCHED_EQUIPMENT = equipment

    net.Start( "Botched.SendEquipmentPiece" )
        net.WriteUInt( 1, 10 )

        net.WriteString( equipmentKey )

        net.WriteBool( equipment[equipmentKey].Rank != nil )
        if( equipment[equipmentKey].Rank ) then
            net.WriteUInt( equipment[equipmentKey].Rank, 5 )
        end

        net.WriteBool( true )
        net.WriteUInt( nextStar, 5 )
    net.Send( ply )

    BOTCHED.FUNC.SQLQuery( "UPDATE botched_owned_equipment SET stars = " .. nextStar .. " WHERE userID = '" .. ply:GetUserID() .. "' AND equipmentKey = '" .. equipmentKey .. "';" )

    local weaponKeys = { "primaryWeapon", "secondaryWeapon", "pickaxe", "hatchet" }
    if( table.HasValue( weaponKeys, equipmentConfig.Type ) ) then
        GAMEMODE:PlayerLoadout( ply )
    else
        GAMEMODE:PlayerGiveEquipmentStats( ply )
    end

    ply:SendNotification( 1, 5, "Equipment stars increased from " .. currentStar .. " to " .. nextStar .. "!" )
end )