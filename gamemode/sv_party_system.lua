util.AddNetworkString( "Botched.SendCreateParty" )
net.Receive( "Botched.SendCreateParty", function( len, ply )
    local partyID = ply:GetPartyID()

    if( partyID != 0 ) then 
        ply:SendNotification( 1, 3, "You are already in a party!" )
        return 
    end

	if( CurTime() < (ply.BOTCHED_PARTYCREATE_COOLDOWN or 0) ) then 
        ply:SendNotification( 1, 3, "Please wait " .. math.ceil( ply.BOTCHED_PARTYCREATE_COOLDOWN-CurTime() ) .. " seconds before making a new party!" )
        return 
    end

	ply.BOTCHED_PARTYCREATE_COOLDOWN = CurTime()+60

    local newPartyID = table.insert( BOTCHED.TEMP.PartyTables, {
        Leader = ply,
        Members = { ply }
    } )

    ply:SetPartyID( newPartyID )
    ply:SendPartyTable( newPartyID )

    ply:SendNotification( 0, 3, "You have successfully created a new party!" )
end )

function BOTCHED.FUNC.UpdatePartyTable( partyID, partyTable )
    BOTCHED.TEMP.PartyTables[partyID] = partyTable

    for k, v in ipairs( partyTable.Members ) do
        if( not IsValid( v ) ) then continue end
        v:SendPartyTable( partyID )
    end
end

function BOTCHED.FUNC.RemovePlayerFromParty( ply )
    local partyID = ply:GetPartyID()
    
    local partyTable = BOTCHED.FUNC.GetPartyTable( partyID )
    if( not partyTable ) then return end

    if( #partyTable.Members > 1 ) then
        table.RemoveByValue( partyTable.Members, ply )

        if( partyTable.Leader == ply ) then
            partyTable.Leader = partyTable.Members[1]
        end

        BOTCHED.FUNC.UpdatePartyTable( partyID, partyTable )
    else
        BOTCHED.TEMP.PartyTables[partyID] = nil
    end
end

util.AddNetworkString( "Botched.SendLeaveParty" )
net.Receive( "Botched.SendLeaveParty", function( len, ply )
    local partyID = ply:GetPartyID()

    if( partyID == 0 ) then 
        ply:SendNotification( 1, 3, "You are not in a party!" )
        return 
    end

    BOTCHED.FUNC.RemovePlayerFromParty( ply )

    ply:SetPartyID( 0 )
    ply:SendNotification( 0, 3, "You have left your current party!" )
end )

hook.Add( "PlayerDisconnected", "Botched.PlayerDisconnected.Party", function( ply ) 
    if( ply:GetPartyID() == 0 ) then return end
    BOTCHED.FUNC.RemovePlayerFromParty( ply )
end )

util.AddNetworkString( "Botched.SendInviteToParty" )
util.AddNetworkString( "Botched.SendPartyInviteReceived" )
net.Receive( "Botched.SendInviteToParty", function( len, ply )
    local victim = net.ReadEntity()
    if( not IsValid( victim ) or not victim:IsPlayer() ) then return end
    
    local partyID = ply:GetPartyID()
    if( partyID == 0 ) then return end

    local partyTable = BOTCHED.FUNC.GetPartyTable( partyID )
    if( partyTable.Leader != ply or table.HasValue( partyTable.Members, victim ) ) then return end

    if( CurTime() < (ply.BOTCHED_PARTYINVITE_COOLDOWN or 0) ) then 
        ply:SendNotification( 1, 3, "Please wait " .. math.ceil( ply.BOTCHED_PARTYINVITE_COOLDOWN-CurTime() ) .. " seconds before inviting another player." )
        return 
    end

	ply.BOTCHED_PARTYINVITE_COOLDOWN = CurTime()+5

    if( (victim.BOTCHED_PARTY_INVITES or {})[ply] and CurTime() < (victim.BOTCHED_PARTY_INVITES or {})[ply]+60 ) then
        ply:SendNotification( 1, 3, "You need to wait " .. math.ceil( (victim.BOTCHED_PARTY_INVITES or {})[ply]+60-CurTime() ) .. " seconds before inviting this player again." )
        return
    end

    victim.BOTCHED_PARTY_INVITES = victim.BOTCHED_PARTY_INVITES or {}
    victim.BOTCHED_PARTY_INVITES[ply] = CurTime()

    net.Start( "Botched.SendPartyInviteReceived" )
        net.WriteEntity( ply )
        net.WriteUInt( victim.BOTCHED_PARTY_INVITES[ply], 32 )
    net.Send( victim )

    ply:SendNotification( 0, 3, "You have invited " .. victim:Nick() .. " to your party." )
end )

util.AddNetworkString( "Botched.SendAcceptPartyInvite" )
util.AddNetworkString( "Botched.SendPartyInviteDeleted" )
net.Receive( "Botched.SendAcceptPartyInvite", function( len, ply )
    local partyID = ply:GetPartyID()
    if( partyID != 0 ) then return end

	local inviter = net.ReadEntity()
    if( not IsValid( inviter ) or not inviter:IsPlayer() ) then return end

    local newPartyID = inviter:GetPartyID()
    local partyTable = BOTCHED.FUNC.GetPartyTable( newPartyID )

    if( not partyTable or partyTable.Leader != inviter or not (ply.BOTCHED_PARTY_INVITES or {})[inviter] or CurTime() >= (ply.BOTCHED_PARTY_INVITES or {})[inviter]+60 or #partyTable.Members >= 5 ) then
        ply:SendNotification( 1, 3, "This party invite has expired." )
        return
    end

    ply.BOTCHED_PARTY_INVITES[inviter] = nil

    net.Start( "Botched.SendPartyInviteDeleted" )
        net.WriteEntity( inviter )
    net.Send( ply )

    if( table.HasValue( partyTable.Members, ply ) ) then return end
    
    ply:SetPartyID( newPartyID )

    table.insert( partyTable.Members, ply )
    BOTCHED.FUNC.UpdatePartyTable( newPartyID, partyTable )

    ply:SendNotification( 0, 3, "You have successfully joined " .. inviter:Nick() .. "'s party." )
end )

util.AddNetworkString( "Botched.SendKickFromParty" )
net.Receive( "Botched.SendKickFromParty", function( len, ply )
    local partyID = ply:GetPartyID()
    if( partyID == 0 ) then return end

	local victim = net.ReadEntity()
    if( not IsValid( victim ) or not victim:IsPlayer() ) then return end

    local partyTable = BOTCHED.FUNC.GetPartyTable( partyID )
    if( not partyTable or partyTable.Leader != ply or not table.HasValue( partyTable.Members, victim ) ) then return end

    victim:SetPartyID( 0 )

    table.RemoveByValue( partyTable.Members, victim )
    BOTCHED.FUNC.UpdatePartyTable( partyID, partyTable )

    ply:SendNotification( 0, 3, "You have successfully kicked " .. victim:Nick() .. " from your party." )
end )

util.AddNetworkString( "Botched.SendTransferPartyOwnership" )
net.Receive( "Botched.SendTransferPartyOwnership", function( len, ply )
    local partyID = ply:GetPartyID()
    if( partyID == 0 ) then return end

	local victim = net.ReadEntity()
    if( not IsValid( victim ) or not victim:IsPlayer() ) then return end

    local partyTable = BOTCHED.FUNC.GetPartyTable( partyID )
    if( not partyTable or partyTable.Leader != ply or not table.HasValue( partyTable.Members, victim ) ) then return end

    partyTable.Leader = victim
    BOTCHED.FUNC.UpdatePartyTable( partyID, partyTable )

    ply:SendNotification( 0, 3, "You have successfully transfered ownership to " .. victim:Nick() .. "." )
    victim:SendNotification( 0, 3, ply:Nick() .. " has transfered ownership of the party to you." )
end )