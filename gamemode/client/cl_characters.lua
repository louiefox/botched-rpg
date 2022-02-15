function BOTCHED.FUNC.GetSlotBinds()
    return {
        KEY_1,
        KEY_2,
        KEY_3,
        KEY_4,
        KEY_5,
        KEY_6,
        KEY_7,
        KEY_8,
        KEY_9
    }
end

hook.Add( "PlayerButtonDown", "Botched.PlayerButtonDown.Characters", function( ply, button )
    if( CurTime() < (BOTCHED_HOTBAR_SLOT_USE_COOLDOWN or 0) ) then return end

	local slotBinds = BOTCHED.FUNC.GetSlotBinds()
    
    local slotNum
    for k, v in ipairs( slotBinds ) do
        if( button == v ) then
            slotNum = k
            break
        end
    end

    if( not slotNum ) then return end

    hook.Run( "Botched.Hooks.HotbarSlotAttemptUse", slotNum )
    BOTCHED_HOTBAR_SLOT_USE_COOLDOWN = CurTime()+0.2

    local abilities = LocalPlayer():GetAbilities()
    if( abilities[slotNum] ) then
        net.Start( "Botched.RequestUseAbility" )
            net.WriteUInt( slotNum, 4 )
        net.SendToServer()
    end
end )

net.Receive( "Botched.SendUseAbility", function()
    local abilityKey = net.ReadString()
    local useTime = net.ReadUInt( 22 )

    BOTCHED_ABILITY_COOLDOWNS = BOTCHED_ABILITY_COOLDOWNS or {}
    BOTCHED_ABILITY_COOLDOWNS[abilityKey] = useTime

    if( abilityKey == "charge" ) then
        BOTCHED.FUNC.CompleteTutorialStep( 2, 2 )
    end

    if( abilityKey == "speed" ) then
        BOTCHED.FUNC.CompleteTutorialStep( 2, 3 )
    end

    hook.Run( "Botched.Hooks.HotbarSlotUsed" )
end )

net.Receive( "Botched.SendPlayerEffectAdded", function()
    local effect = net.ReadString()
    local startTime = net.ReadUInt( 22 )
    local duration = net.ReadUInt( 16 )

    BOTCHED_PLAYER_EFFECTS = BOTCHED_PLAYER_EFFECTS or {}
    BOTCHED_PLAYER_EFFECTS[effect] = { startTime, duration }

    hook.Run( "Botched.Hooks.PlayerEffectAdded" )
end )

net.Receive( "Botched.SendPlayerEffectRemoved", function()
    local effect = net.ReadString()

    BOTCHED_PLAYER_EFFECTS = BOTCHED_PLAYER_EFFECTS or {}
    BOTCHED_PLAYER_EFFECTS[effect] = nil

    hook.Run( "Botched.Hooks.PlayerEffectRemoved" )
end )