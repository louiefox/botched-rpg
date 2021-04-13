BOTCHED.TEMP.PartyTables = BOTCHED.TEMP.PartyTables or {}
function BOTCHED.FUNC.GetPartyTable( partyID )
    if( BOTCHED.TEMP.PartyTables[partyID] ) then
        return BOTCHED.TEMP.PartyTables[partyID]
    end

    return false
end