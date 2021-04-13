net.Receive( "Botched.SendOpenPartyMenu", function( len, ply )
    if( IsValid( BOTCHED_PARTYMENU ) ) then
        BOTCHED_PARTYMENU:Remove()
    end

    BOTCHED_PARTYMENU = vgui.Create( "botched_partymenu" )
end )

net.Receive( "Botched.SendPartyTable", function()
    local partyID = net.ReadUInt( 10 )

    local partyTable = {}
    partyTable.Leader = net.ReadEntity()
    partyTable.Members = {}

    for i = 1, net.ReadUInt( 3 ) do
        table.insert( partyTable.Members, net.ReadEntity() )
    end

    BOTCHED.TEMP.PartyTables[partyID] = partyTable

    hook.Run( "Botched.Hooks.PartyTableUpdated", partyID )
end )

net.Receive( "Botched.SendPartyInviteReceived", function()
    local inviter = net.ReadEntity()
    if( not IsValid( inviter ) ) then return end

    BOTCHED_PARTY_INVITES = BOTCHED_PARTY_INVITES or {}
    BOTCHED_PARTY_INVITES[inviter] = net.ReadUInt( 32 )

    hook.Run( "Botched.Hooks.PartyInvitesUpdated" )

    chat.AddText( Color( 52, 152, 219 ), "[PARTY] ", Color( 255, 255, 255 ), inviter:Nick() .. "  has invited you to their party, press F2 to check your invites." )
end )

net.Receive( "Botched.SendPartyInviteDeleted", function()
    local inviter = net.ReadEntity()
    if( not IsValid( inviter ) ) then return end

    BOTCHED_PARTY_INVITES = BOTCHED_PARTY_INVITES or {}
    BOTCHED_PARTY_INVITES[inviter] = nil

    hook.Run( "Botched.Hooks.PartyInvitesUpdated" )
end )