net.Receive( "Botched.SendToggleQuestHUD", function( len, ply )
    if( IsValid( BOTCHED_QUESTHUD ) ) then BOTCHED_QUESTHUD:Close() return end

    BOTCHED_QUESTHUD = vgui.Create( "botched_hud_quests" )

    local questInfo = BOTCHED_ACTIVE_QUEST
    if( questInfo ) then
        if( not BOTCHED_ACTIVE_QUEST.Completed ) then
            BOTCHED_QUESTHUD:UpdateQuestProgress( questInfo.QuestProgress )
            BOTCHED_QUESTHUD:SetActiveQuest( questInfo.QuestLine, questInfo.QuestKey )
        else
            BOTCHED_QUESTHUD:SetQuestCompleted( questInfo.QuestLine, questInfo.QuestKey )
        end
    else
        BOTCHED_QUESTHUD:SetNoQuest()
    end
end )

net.Receive( "Botched.SendStartQuest", function( len, ply )
    local questInfo = {
        QuestLine = net.ReadUInt( 5 ),
        QuestKey = net.ReadUInt( 5 ),
        QuestProgress = {
            TimeStarted = net.ReadUInt( 32 ),
            Monsters = {}
        }
    }

    BOTCHED_ACTIVE_QUEST = questInfo

    if( not IsValid( BOTCHED_QUESTHUD ) ) then
        BOTCHED_QUESTHUD = vgui.Create( "botched_hud_quests" )
    end

    BOTCHED_QUESTHUD:UpdateQuestProgress( questInfo.QuestProgress )
    BOTCHED_QUESTHUD:SetActiveQuest( questInfo.QuestLine, questInfo.QuestKey )

    if( questInfo.QuestLine == 1 and questInfo.QuestKey == 1 ) then
        BOTCHED.FUNC.CompleteTutorialStep( 3, 3 )
    end
end )

net.Receive( "Botched.SendQuestFailed", function( len, ply )
    if( not BOTCHED_ACTIVE_QUEST ) then return end

    BOTCHED_ACTIVE_QUEST.Failed = true

    if( not IsValid( BOTCHED_QUESTHUD ) ) then
        BOTCHED_QUESTHUD = vgui.Create( "botched_hud_quests" )
    end

    BOTCHED_QUESTHUD:SetQuestFailed( BOTCHED_ACTIVE_QUEST.QuestLine, BOTCHED_ACTIVE_QUEST.QuestKey )

    notification.AddLegacy( "Quest failed!", 1, 5 )
end )

net.Receive( "Botched.SendUpdateQuestProgress", function( len, ply )
    if( not BOTCHED_ACTIVE_QUEST ) then return end

    BOTCHED_ACTIVE_QUEST.QuestProgress.Monsters[net.ReadString()] = net.ReadUInt( 16 )

    if( IsValid( BOTCHED_QUESTHUD ) ) then
        BOTCHED_QUESTHUD:UpdateQuestProgress( BOTCHED_ACTIVE_QUEST.QuestProgress )
    end
end )

net.Receive( "Botched.SendIncreaseQuestDeaths", function( len, ply )
    if( not BOTCHED_ACTIVE_QUEST ) then return end

    BOTCHED_ACTIVE_QUEST.Deaths = (BOTCHED_ACTIVE_QUEST.Deaths or 0)+1
end )

net.Receive( "Botched.SendQuestCompleted", function( len, ply )
    local activeQuest = BOTCHED_ACTIVE_QUEST
    if( not activeQuest ) then return end

    activeQuest.Completed = true
    activeQuest.CompletedStars = net.ReadUInt( 2 )
    activeQuest.TimeRemaining = net.ReadUInt( 16 )
    activeQuest.FirstClear = net.ReadBool()
    activeQuest.First3Stars = net.ReadBool()

    activeQuest.PlayerEXP = net.ReadUInt( 16 )
    activeQuest.Mana = net.ReadUInt( 16 )

    activeQuest.Items = {}
    for i = 1, net.ReadUInt( 4 ) do
        activeQuest.Items[net.ReadString()] = net.ReadUInt( 16 )
    end

    if( not IsValid( BOTCHED_QUESTHUD ) ) then
        BOTCHED_QUESTHUD = vgui.Create( "botched_hud_quests" )
    end

    BOTCHED_QUESTHUD:SetQuestCompleted( BOTCHED_ACTIVE_QUEST.QuestLine, BOTCHED_ACTIVE_QUEST.QuestKey )

    notification.AddLegacy( "Quest successfully completed!", 0, 5 )

    if( activeQuest.QuestLine == 1 and activeQuest.QuestKey == 1 ) then
        BOTCHED.FUNC.CompleteTutorialStep( 3, 7 )
    end
end )

net.Receive( "Botched.SendQuestClaimed", function( len, ply )
    if( BOTCHED_ACTIVE_QUEST and BOTCHED_ACTIVE_QUEST.QuestLine == 1 and BOTCHED_ACTIVE_QUEST.QuestKey == 1 ) then
        BOTCHED.FUNC.CompleteTutorialStep( 3, 8 )
    end

    BOTCHED_ACTIVE_QUEST = nil

    if( IsValid( BOTCHED_QUESTHUD ) ) then
        BOTCHED_QUESTHUD:SetNoQuest()
    end

    notification.AddLegacy( "Quest successfully claimed!", 0, 5 )
end )

hook.Add( "HUDPaint", "Botched.HUDPaint.Quests", function()
    local ply = LocalPlayer()
    local questInfo = BOTCHED_ACTIVE_QUEST

    if( not questInfo or questInfo.Completed or questInfo.Failed ) then return end

    local questLine = BOTCHED.CONFIG.QuestsLines[questInfo.QuestLine]
    if( not questLine ) then return end

    local questConfig = questLine.Quests[questInfo.QuestKey]
    if( not questConfig ) then return end

    local targetMonster
    for k, v in pairs( questConfig.Monsters ) do
        if( (questInfo.QuestProgress.Monsters[k] or 0) >= v ) then continue end

        targetMonster = k
        break
    end

    if( not targetMonster ) then return end

    local monsterConfig = BOTCHED.CONFIG.Monsters[targetMonster] or {}
    if( not monsterConfig ) then return end

    if( monsterConfig.Locations and #monsterConfig.Locations > 0 ) then
        local plyPos = ply:GetPos()

        local previousLocation, previousDistance
        for k, v in ipairs( monsterConfig.Locations ) do
            local distance = plyPos:DistToSqr( v )
            if( previousDistance and distance > previousDistance ) then continue end

            previousLocation, previousDistance = v, distance
        end

        local pos = previousLocation
        pos = Vector( pos[1], pos[2], pos[3]+10 )

        local pos2d = pos:ToScreen()

        local displayDistance = math.Round( math.sqrt( previousDistance )/10, 0 )
        local distanceText = displayDistance .. "m"
        local monsterText = "QUEST - " .. string.upper( monsterConfig.Name )
        surface.SetFont( "MontserratBold25" )
        local textX, textY = surface.GetTextSize( monsterText )

        local screenBorder = 50
        local textXPos = math.Clamp( pos2d.x-(textX/2), screenBorder, ScrW()-screenBorder-textX )
        local textYPos = math.Clamp( pos2d.y-(textY/2), screenBorder, ScrH()-screenBorder-textY )

        surface.SetAlphaMultiplier( displayDistance/50 )
        draw.SimpleText( monsterText, "MontserratBold25", textXPos+1, textYPos+3+1, BOTCHED.FUNC.GetTheme( 1 ), 0, TEXT_ALIGN_BOTTOM )
        draw.SimpleText( monsterText, "MontserratBold25", textXPos, textYPos+3, BOTCHED.FUNC.GetTheme( 4 ), 0, TEXT_ALIGN_BOTTOM )

        draw.SimpleText( distanceText, "MontserratBold25", textXPos+(textX/2)+1, textYPos-3+1, BOTCHED.FUNC.GetTheme( 1 ), TEXT_ALIGN_CENTER )
        draw.SimpleText( distanceText, "MontserratBold25", textXPos+(textX/2), textYPos-3, BOTCHED.FUNC.GetTheme( 3 ), TEXT_ALIGN_CENTER )
        surface.SetAlphaMultiplier( 1 )
    else
        draw.SimpleText( "NO MONSTER LOCATIONS", "MontserratBold25", ScrW()/2+1, ScrH()*0.9+1, BOTCHED.FUNC.GetTheme( 1 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        draw.SimpleText( "NO MONSTER LOCATIONS", "MontserratBold25", ScrW()/2, ScrH()*0.9, BOTCHED.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
end )