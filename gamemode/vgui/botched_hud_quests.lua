local PANEL = {}

function PANEL:Init()
    self.headerHeight = 40

    self:SetAlpha( 0 )
    self:SetSize( ScrW()*0.13, self.headerHeight )
    self:SetPos( ScrW()-25-self:GetWide(), 25 )
    self:ParentToHUD()

    self.mainPanel = vgui.Create( "DPanel", self )
    self.mainPanel:Dock( FILL )
    self.mainPanel:DockPadding( 0, self.headerHeight, 0, 0 )
    self.mainPanel.Paint = function( self2, w, h )
        BOTCHED.FUNC.DrawBlur( self2, 4, 4 )
        draw.RoundedBoxEx( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 1, 200 ), true, true, not self.hasActiveQuest, not self.hasActiveQuest )
        draw.RoundedBoxEx( 8, 0, 0, w, self.headerHeight, BOTCHED.FUNC.GetTheme( 1 ), true, true )
    
        draw.SimpleText( "CURRENT QUEST", "MontserratBold30", 10, self.headerHeight/2-1, BOTCHED.FUNC.GetTheme( 4, 75 ), 0, TEXT_ALIGN_CENTER )
        draw.SimpleText( "(F3)", "MontserratBold25", w-10, self.headerHeight/2-2, BOTCHED.FUNC.GetTheme( 4, 75 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
    end
end

function PANEL:Reset()
    self.mainPanel:Clear()

    if( IsValid( self.timeLeftPanel ) ) then
        self.timeLeftPanel:Remove()
    end
end

function PANEL:SetNoQuest()
    self:AlphaTo( 255, 0.2 )
    self:SizeTo( self:GetWide(), self.headerHeight+75, 0.2 )

    self:Reset()
    self.hasActiveQuest = false

    local noQuestPanel = vgui.Create( "DPanel", self.mainPanel )
    noQuestPanel:Dock( FILL )
    noQuestPanel.Paint = function( self2, w, h )
        draw.SimpleText( "NO ACTIVE QUEST", "MontserratBold20", w/2, h/2-1, BOTCHED.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
end

function PANEL:SetQuestCompleted()
    self:AlphaTo( 255, 0.2 )
    self:SizeTo( self:GetWide(), self.headerHeight+75, 0.2 )

    self:Reset()
    self.hasActiveQuest = false

    local questCompletedPanel = vgui.Create( "DPanel", self.mainPanel )
    questCompletedPanel:Dock( FILL )
    questCompletedPanel.Paint = function( self2, w, h )
        draw.SimpleText( "QUEST COMPLETED", "MontserratBold20", w/2, h/2-1, BOTCHED.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
        draw.SimpleText( "PRESS F4 TO CLAIM", "MontserratBold20", w/2, h/2-1, BOTCHED.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER )
    end
end

function PANEL:SetQuestFailed()
    self:AlphaTo( 255, 0.2 )
    self:SizeTo( self:GetWide(), self.headerHeight+75, 0.2 )

    self:Reset()
    self.hasActiveQuest = false

    local questCompletedPanel = vgui.Create( "DPanel", self.mainPanel )
    questCompletedPanel:Dock( FILL )
    questCompletedPanel.Paint = function( self2, w, h )
        draw.SimpleText( "QUEST FAILED", "MontserratBold20", w/2, h/2-1, BOTCHED.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
        draw.SimpleText( "PRESS F4 VIEW DETAILS", "MontserratBold20", w/2, h/2-1, BOTCHED.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER )
    end
end

function PANEL:Close()
    self:AlphaTo( 0, 0.2 )
    self:SizeTo( self:GetWide(), self.headerHeight, 0.2, 0, -1, function()
        self:Remove()
    end )
end

function PANEL:UpdateQuestProgress( questProgress )
    self.questProgress = questProgress

    if( self.progressPanels ) then
        for k, v in pairs( self.progressPanels ) do
            if( not IsValid( v ) ) then continue end

            if( v.monsterCount != (self.questProgress.Monsters[k] or 0) ) then
                v.Refresh()
            end
        end
    end
end

function PANEL:SetActiveQuest( questLineKey, quest )
    local questLine = BOTCHED.CONFIG.QuestsLines[questLineKey]
    if( not questLine ) then return end

    local questConfig = questLine.Quests[quest]
    if( not questConfig ) then return end

    self.questLine = questLineKey
    self.quest = quest

    self:Reset()
    self.hasActiveQuest = true

    local progressSpacing = 10
    self.progressPanels = {}
    local monsterPanelH = 0
    local tickMat = Material( "materials/botched/icons/tick.png" )
    for k, v in pairs( questConfig.Monsters or {} ) do
        local monsterConfig = BOTCHED.CONFIG.Monsters[k]
        local monsterPanelCount = table.Count( self.progressPanels )

        local progressPanel = vgui.Create( "DPanel", self.mainPanel )
        progressPanel:Dock( TOP )
        progressPanel:DockMargin( 0, progressSpacing, 0, 0 )
        progressPanel.monsterCount = self.questProgress.Monsters[k] or 0
        progressPanel.Refresh = function()
            progressPanel.progressPercent = math.Clamp( (self.questProgress.Monsters[k] or 0)/v, 0, 1 )

            local progressTall = progressPanel.progressPercent != 1 and 60 or 35
            if( progressTall != progressPanel:GetTall() ) then
                if( progressPanel:GetTall() != 0 ) then
                    self:SizeTo( self:GetWide(), self:GetTall()-progressPanel:GetTall()+progressTall, 0.2 )
                end

                progressPanel:SetTall( progressTall )
                progressPanel.main:SetTall( progressTall )
            end
        end
        progressPanel.Paint = function() end

        progressPanel.main = vgui.Create( "DPanel", progressPanel )
        progressPanel.main:SetWide( self:GetWide()-(2*progressSpacing) )
        progressPanel.main:SetPos( self:GetWide(), 0 )
        progressPanel.main:MoveTo( progressSpacing, 0, 0.2+(monsterPanelCount*0.1) )
        progressPanel.main.Paint = function( self2, w, h )
            BSHADOWS.BeginShadow( "quest_hud_monster_" .. k )
            BSHADOWS.SetShadowSize( "quest_hud_monster_" .. k, w, h )
            local x, y = self2:LocalToScreen( 0, 0 )
            draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 1 ) )			
            BSHADOWS.EndShadow( "quest_hud_monster_" .. k, x, y, 1, 2, 2, 255, 0, 0, false )

            draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 150 ) )

            draw.SimpleText( "Kill " .. v .. " " .. monsterConfig.Name .. "s", "MontserratBold20", 10, progressPanel.progressPercent != 1 and 7 or h/2-1, BOTCHED.FUNC.GetTheme( 3 ), 0, progressPanel.progressPercent == 1 and TEXT_ALIGN_CENTER )

            if( progressPanel.progressPercent != 1 ) then
                draw.SimpleText( math.floor( progressPanel.progressPercent*100 ) .. "%", "MontserratBold25", w-10, 5, BOTCHED.FUNC.GetTheme( 4, 75 ), TEXT_ALIGN_RIGHT )

                local progressBarH = 10
                draw.RoundedBox( progressBarH/2, 10, h-10-progressBarH, w-20, progressBarH, BOTCHED.FUNC.GetTheme( 1, 150 ) )

                BOTCHED.FUNC.DrawRoundedMask( progressBarH/2, 10, h-10-progressBarH, w-20, progressBarH, function()
                    surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 3, 150 ) )
                    surface.DrawRect( 10, h-10-progressBarH, (w-20)*progressPanel.progressPercent, progressBarH )
                end )
            else
                surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 4, 75 ) )
                surface.SetMaterial( tickMat )
                local iconSize = 16
                surface.DrawTexturedRect( w-(h/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
            end
        end

        progressPanel.Refresh()

        monsterPanelH = monsterPanelH+progressPanel:GetTall()
        self.progressPanels[k] = progressPanel
    end

    self.timeLeftPanel = vgui.Create( "DPanel", self )
    self.timeLeftPanel:Dock( BOTTOM )
    self.timeLeftPanel:SetTall( 35 )
    self.timeLeftPanel.Paint = function( self2, w, h )
        draw.RoundedBoxEx( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 1 ), false, false, true, true )
        draw.RoundedBoxEx( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 150 ), false, false, true, true )

        local progressBarH = 8
        draw.SimpleText( "Time Remaining", "MontserratBold20", 10, (h-progressBarH)/2-1, BOTCHED.FUNC.GetTheme( 4, 75 ), 0, TEXT_ALIGN_CENTER )

        local timeLeft = self.questProgress.TimeStarted+questConfig.TimeLimit-CurTime()

        local timeTable = string.FormattedTime( math.max( 0, timeLeft ) )
        draw.SimpleText( timeTable.m .. "m " .. timeTable.s .. "s", "MontserratBold20", w-10, (h-progressBarH)/2-1, BOTCHED.FUNC.GetTheme( 4, 75 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )

        BOTCHED.FUNC.DrawPartialRoundedBoxEx( 8, 0, h-progressBarH, w, progressBarH, BOTCHED.FUNC.GetTheme( 1, 150 ), false, 16, false, h-16, false, false, true, true )
        BOTCHED.FUNC.DrawRoundedMask( 8, -1, h-16, w+2, 16, function()
            surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 3, 150 ) )
            surface.DrawRect( 0, h-progressBarH, w*math.Clamp( timeLeft/questConfig.TimeLimit, 0, 1 ), progressBarH )
        end )
    end

    self:AlphaTo( 255, 0.2 )
    self:SizeTo( self:GetWide(), self.headerHeight+monsterPanelH+(table.Count( self.progressPanels )*progressSpacing)+progressSpacing+self.timeLeftPanel:GetTall(), 0.2 )
end

function PANEL:Paint( w, h )

end

vgui.Register( "botched_hud_quests", PANEL, "DPanel" )