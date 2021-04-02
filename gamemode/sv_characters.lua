util.AddNetworkString( "Botched.RequestUseAbility" )
util.AddNetworkString( "Botched.SendUseAbility" )
net.Receive( "Botched.RequestUseAbility", function( len, ply )
    local abilityNum = net.ReadUInt( 4 )
    if( not abilityNum ) then return end

    local abilities = ply:GetAbilities()
    local abilityKey = abilities[abilityNum]
    if( not abilityKey ) then return end

    local abilityConfig = BOTCHED.DEVCONFIG.CharacterAbilities[abilityKey]

    local abilityCooldowns = ply:GetAbilityCooldowns()
    if( CurTime() < (abilityCooldowns[abilityKey] or 0)+abilityConfig.Cooldown ) then return end

    local useFailed = abilityConfig.UseFunc( ply )
    if( useFailed ) then return end

    abilityCooldowns[abilityKey] = CurTime()
    ply.BOTCHED_ABILITY_COOLDOWNS = abilityCooldowns

    net.Start( "Botched.SendUseAbility" )
        net.WriteString( abilityKey )
        net.WriteUInt( abilityCooldowns[abilityKey], 22 )
    net.Send( ply )
end )