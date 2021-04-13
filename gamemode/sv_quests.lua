util.AddNetworkString( "Botched.RequestStartQuest" )
util.AddNetworkString( "Botched.SendStartQuest" )
util.AddNetworkString( "Botched.SendQuestFailed" )
net.Receive( "Botched.RequestStartQuest", function( len, ply )
    if( ply.BOTCHED_ACTIVE_QUEST ) then return end

    local questLine = net.ReadUInt( 8 )
    local questKey = net.ReadUInt( 8 )

    if( not questLine or not questKey or not BOTCHED.CONFIG.QuestsLines[questLine] or not BOTCHED.CONFIG.QuestsLines[questLine].Quests[questKey] ) then return end
    local questConfig = BOTCHED.CONFIG.QuestsLines[questLine].Quests[questKey]

    if( ply:Stamina() < questConfig.StaminaCost ) then return end
    ply:TakeStamina( questConfig.StaminaCost )

    ply.BOTCHED_ACTIVE_QUEST = {
        QuestLine = questLine,
        QuestKey = questKey,
        QuestProgress = {
            TimeStarted = CurTime(),
            Monsters = {}
        }
    }

    net.Start( "Botched.SendStartQuest" )
        net.WriteUInt( questLine, 5 )
        net.WriteUInt( questKey, 5 )
        net.WriteUInt( ply.BOTCHED_ACTIVE_QUEST.QuestProgress.TimeStarted, 32 )
    net.Send( ply )

    timer.Create( "BOTCHED.Timer.QuestTimer." .. ply:SteamID64(), questConfig.TimeLimit, 1, function()
        if( not IsValid( ply ) or not ply.BOTCHED_ACTIVE_QUEST ) then return end

        ply.BOTCHED_ACTIVE_QUEST.Failed = true

        net.Start( "Botched.SendQuestFailed" )
        net.Send( ply )
    end )
end )

util.AddNetworkString( "Botched.SendUpdateQuestProgress" )
util.AddNetworkString( "Botched.SendQuestCompleted" )
hook.Add( "Botched.Hooks.MonsterKilled", "Botched.MonsterKilled.Quests", function( ply, monsterClass )
    local questInfo = ply.BOTCHED_ACTIVE_QUEST
    if( not questInfo ) then return end

    local questLine = questInfo.QuestLine
    local questKey = questInfo.QuestKey

    local questLineConfig = BOTCHED.CONFIG.QuestsLines[questLine]
    local questConfig = questLineConfig.Quests[questKey]
    if( not questConfig ) then return end

    if( not questConfig.Monsters or not questConfig.Monsters[monsterClass] or (questInfo.QuestProgress.Monsters[monsterClass] or 0) >= questConfig.Monsters[monsterClass] ) then return end

    questInfo.QuestProgress.Monsters[monsterClass] = (questInfo.QuestProgress.Monsters[monsterClass] or 0)+1

    local questCompleted = true
    for k, v in pairs( questConfig.Monsters ) do
        if( (questInfo.QuestProgress.Monsters[k] or 0) < v ) then questCompleted = false break end
    end

    if( not questCompleted ) then
        net.Start( "Botched.SendUpdateQuestProgress" )
            net.WriteString( monsterClass )
            net.WriteUInt( questInfo.QuestProgress.Monsters[monsterClass], 16 )
        net.Send( ply )
    else
        local timeRemaining = timer.TimeLeft( "BOTCHED.Timer.QuestTimer." .. ply:SteamID64() ) or 0
        if( timer.Exists( "BOTCHED.Timer.QuestTimer." .. ply:SteamID64() ) ) then
            timer.Remove( "BOTCHED.Timer.QuestTimer." .. ply:SteamID64() )
        end

        questInfo.Completed = true

        local deaths = questInfo.Deaths or 0
        local completedStars = ((deaths == 0 and 3) or (deaths == 1 and 2)) or 1

        local completedQuests = ply:GetCompletedQuests()
        local previousStars = (completedQuests[questLine] or {})[questKey] or 0

        questInfo.FirstClear = previousStars <= 0
        questInfo.First3Stars = previousStars != 3 and completedStars == 3

        local randomItems = questLineConfig.RandomItems
        for k, v in pairs( questConfig.Items ) do
            table.insert( randomItems, v )
        end

        questInfo.Items = {}
        for k, v in pairs( randomItems ) do
            if( math.random( 0, 100 ) > v[2] ) then continue end

            questInfo.Items[v[1]] = (questInfo.Items[v[1]] or 0)+(v[3] or 1)
        end

        questInfo.PlayerEXP = questConfig.StaminaCost*10
        questInfo.Mana = questConfig.StaminaCost*math.random( 190, 210 )

        net.Start( "Botched.SendQuestCompleted" )
            net.WriteUInt( completedStars, 2 )
            net.WriteUInt( timeRemaining, 16 )
            net.WriteBool( questInfo.FirstClear )
            net.WriteBool( questInfo.First3Stars )

            net.WriteUInt( questInfo.PlayerEXP, 16 )
            net.WriteUInt( questInfo.Mana, 16 )
            net.WriteUInt( table.Count( questInfo.Items ), 4 )
            for k, v in pairs( questInfo.Items ) do
                net.WriteString( k )
                net.WriteUInt( v, 16 )
            end
        net.Send( ply )
    end
end )

util.AddNetworkString( "Botched.SendIncreaseQuestDeaths" )
hook.Add( "PlayerDeath", "Botched.PlayerDeath.Quests", function( victim, inflictor, attacker )
    if( not victim:IsPlayer() ) then return end

    local questInfo = victim.BOTCHED_ACTIVE_QUEST
    if( not questInfo or questInfo.Completed ) then return end

    questInfo.Deaths = (questInfo.Deaths or 0)+1

    net.Start( "Botched.SendIncreaseQuestDeaths" )
    net.Send( victim )
end )

util.AddNetworkString( "Botched.SendClaimQuest" )
util.AddNetworkString( "Botched.SendQuestClaimed" )
net.Receive( "Botched.SendClaimQuest", function( len, ply )
    local questInfo = ply.BOTCHED_ACTIVE_QUEST
    if( not questInfo or (not questInfo.Completed and not questInfo.Failed) ) then return end

    local questLine = questInfo.QuestLine
    local questKey = questInfo.QuestKey

    local questConfig = BOTCHED.CONFIG.QuestsLines[questLine].Quests[questKey]
    if( not questConfig ) then return end

    if( questInfo.Completed ) then
        local tablesToAdd = {}
        if( questInfo.First3Stars ) then
            table.insert( tablesToAdd, questConfig.Reward3Stars )
        end

        if( questInfo.FirstClear ) then
            table.insert( tablesToAdd, questConfig.Reward )
        end

        ply:AddExperience( questInfo.PlayerEXP )
        ply:SendExpNotification( questInfo.PlayerEXP, "Quest Completed" )

        ply:AddMana( questInfo.Mana )

        if( questInfo.Items and table.Count( questInfo.Items ) > 0 ) then
            table.insert( tablesToAdd, { Items = questInfo.Items } )
        end

        ply:GiveReward( BOTCHED.FUNC.MergeRewardTables( unpack( tablesToAdd ) ) )

        local deaths = questInfo.Deaths or 0
        local completedStars = ((deaths == 0 and 3) or (deaths == 1 and 2)) or 1

        local completedQuests = ply:GetCompletedQuests()
        local previousStars = (completedQuests[questLine] or {})[questKey] or 0
        if( previousStars < 3 and previousStars != completedStars ) then
            ply:UpdateQuestStars( questLine, questKey, completedStars )
        end
    end

    ply.BOTCHED_ACTIVE_QUEST = nil

    net.Start( "Botched.SendQuestClaimed" )
    net.Send( ply )
end )