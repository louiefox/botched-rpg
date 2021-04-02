local PANEL = {}

function PANEL:Init()
    self:SetHeader( "QUEST OVER" )
    self:SetDrawHeader( false )

    self:SetPopupWide( ScrW()*0.45 )
    self:SetExtraHeight( ScrH()*0.4 )
    self.closeButton:Remove()
    self.backButton.DoClick = function() end

    self.centerArea = vgui.Create( "DPanel", self )
    self.centerArea:SetPos( 0, 0 )
    self.centerArea:SetSize( self:GetPopupWide(), self.mainPanel.targetH )
    self.centerArea.Paint = function( self2, w, h ) 
        DisableClipping( true )
        draw.SimpleTextOutlined( self.topText or "", "MontserratBold120", w/2, 0, BOTCHED.FUNC.GetTheme( 3 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, BOTCHED.FUNC.GetTheme( 1 ) )
        DisableClipping( false )
    end
end

function PANEL:SetQuestInfo( questInfo )
    self.questInfo = questInfo
    
    self.questLine = BOTCHED.CONFIG.QuestsLines[questInfo.QuestLine]
    if( not self.questLine ) then return end

    self.questConfig = self.questLine.Quests[questInfo.QuestKey]
    if( not self.questConfig ) then return end

    self.topText = questInfo.Completed and "COMPLETED" or "FAILED"
    self.lastPage = not questInfo.Completed

    local bottomButton = vgui.Create( "DButton", self.centerArea )
    bottomButton:Dock( BOTTOM )
    bottomButton:SetTall( 50 )
    bottomButton:DockMargin( self.centerArea:GetWide()*0.3, 0, self.centerArea:GetWide()*0.3, 25 )
    bottomButton:SetText( "" )
    bottomButton.Paint = function( self2, w, h )
        self2:CreateFadeAlpha( 0.1, 255 )

        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100+((self2.alpha/255)*155) ) )

        BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 2 ), 8 )
        BOTCHED.FUNC.DrawPartialRoundedBox( 8, 0, h-5, w, 5, BOTCHED.FUNC.GetTheme( 3, self2.alpha ), false, 16, false, h-5-11 )

        draw.SimpleText( self.lastPage and "CONTINUE" or "NEXT", "MontserratBold25", w/2, h/2, BOTCHED.FUNC.GetTheme( 4, 75+(180*(self2.alpha/255)) ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
    bottomButton.DoClick = function()
        if( questInfo.Completed and not self.lastPage ) then
            self:OpenItemsEarned()
        else
            net.Start( "Botched.SendClaimQuest" )
            net.SendToServer()
    
            self:Close()
        end
    end

    surface.SetFont( "MontserratBold120" )
    local topTextX, topTextY = surface.GetTextSize( self.topText )

    self.pageW, self.pageH = self.centerArea:GetWide()-50, self.centerArea:GetTall()-(topTextY/2)-bottomButton:GetTall()-50
    self.pageX, self.pageY = 25, topTextY/2

    self.firstPage = vgui.Create( "DPanel", self.centerArea )
    self.firstPage:SetSize( self.pageW, self.pageH )
    self.firstPage:SetPos( self.pageX, self.pageY )
    self.firstPage.Paint = function() end
    self.firstPage.SlidePanels = {}
    self.firstPage.CreateSlidePanel = function( tall )
        local slidePanel = vgui.Create( "DPanel", self.firstPage )
        slidePanel:SetSize( self.firstPage:GetWide(), tall )
        slidePanel:SetPos( self.firstPage:GetWide(), self.firstPage.PreviousTall or 0 )

        self.firstPage.PreviousTall = (self.firstPage.PreviousTall or 0)+tall

        table.insert( self.firstPage.SlidePanels, slidePanel )
        return slidePanel
    end

    local iconSize, iconSpacing = 64, 10
    local starMat = Material( "materials/botched/icons/star_64.png" )
    local starBlankMat = Material( "materials/botched/icons/star_64_blank.png" )
    local totalStarW = (3*(iconSize+iconSpacing))-iconSpacing
    surface.SetFont( "MontserratBold30" )
    local subTextX, subTextY = surface.GetTextSize( "COMPLETED STARS" )
    local contentH = iconSize+subTextY+10
    local completedStars = self.firstPage.CreateSlidePanel( self.firstPage:GetTall()/3 )
    completedStars.Paint = function( self2, w, h )
        surface.SetMaterial( starBlankMat )
        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 2, 100 ) )
        for i = 1, 3 do
            surface.DrawTexturedRect( (w/2)-(totalStarW/2)+((i-1)*(iconSize+iconSpacing)), (h/2)-(contentH/2), iconSize, iconSize )
        end

        surface.SetMaterial( starMat )
        surface.SetDrawColor( 255, 255, 255 )
        for i = 1, (questInfo.CompletedStars or 0) do
            surface.DrawTexturedRect( (w/2)-(totalStarW/2)+((i-1)*(iconSize+iconSpacing)), (h/2)-(contentH/2), iconSize, iconSize )
        end

        draw.SimpleText( "COMPLETED STARS", "MontserratBold30", w/2, (h/2)+(contentH/2), BOTCHED.FUNC.GetTheme( 4, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
    end 

    local timerMat = Material( "materials/botched/icons/timer.png" )
    local iconSize = 64
    local timeTable = string.FormattedTime( questInfo.TimeRemaining or 0 )
    local timeText = string.format( "%02d:%02d", timeTable.m, timeTable.s )
    surface.SetFont( "MontserratBold70" )
    local textX, textY = surface.GetTextSize( timeText )
    surface.SetFont( "MontserratBold30" )
    local subTextX, subTextY = surface.GetTextSize( "TIME REMAINING" )
    local contentW, contentH = iconSize+textX+10, iconSize+subTextY+10
    local timeRemaining = self.firstPage.CreateSlidePanel( self.firstPage:GetTall()/3 )
    timeRemaining.Paint = function( self2, w, h )
        surface.SetMaterial( timerMat )
        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 2 ) )
        surface.DrawTexturedRect( (w/2)-(contentW/2), (h/2)-(contentH/2), iconSize, iconSize )

        draw.SimpleText( timeText, "MontserratBold70", (w/2)+(contentW/2), (h/2)-(contentH/2)+(iconSize/2), BOTCHED.FUNC.GetTheme( 2 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )

        draw.SimpleText( "TIME REMAINING", "MontserratBold30", w/2, (h/2)+(contentH/2), BOTCHED.FUNC.GetTheme( 4, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
    end 
    
    local deathMat = Material( "materials/botched/icons/death.png" )
    local iconSize = 64
    local deathText = questInfo.Deaths or 0
    surface.SetFont( "MontserratBold70" )
    local textX, textY = surface.GetTextSize( deathText )
    surface.SetFont( "MontserratBold30" )
    local subTextX, subTextY = surface.GetTextSize( "DEATHS" )
    local contentW, contentH = iconSize+textX+10, iconSize+subTextY+10
    local deathsPanel = self.firstPage.CreateSlidePanel( self.firstPage:GetTall()/3 )
    deathsPanel.Paint = function( self2, w, h )
        surface.SetMaterial( deathMat )
        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 2 ) )
        surface.DrawTexturedRect( (w/2)-(contentW/2), (h/2)-(contentH/2), iconSize, iconSize )

        draw.SimpleText( deathText, "MontserratBold70", (w/2)+(contentW/2), (h/2)-(contentH/2)+(iconSize/2), BOTCHED.FUNC.GetTheme( 2 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )

        draw.SimpleText( "DEATHS", "MontserratBold30", w/2, (h/2)+(contentH/2), BOTCHED.FUNC.GetTheme( 4, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
    end 

    local currentSlidePanel = 0
    local function SlideNextPanel()
        if( not IsValid( self ) ) then return end

        currentSlidePanel = currentSlidePanel+1
        if( not self.firstPage.SlidePanels[currentSlidePanel] ) then return end

        local currentX, currentY = self.firstPage.SlidePanels[currentSlidePanel]:GetPos()
        self.firstPage.SlidePanels[currentSlidePanel]:MoveTo( 0, currentY, 0.2, 0, -1, SlideNextPanel )
    end
    SlideNextPanel()
end

function PANEL:CreateSlotPanel( name, model, amount, border, modelColor )
    local slotBack = self.itemsEarnedLayout:Add( "DPanel" )
    slotBack:SetSize( self.slotSize, self.slotSize )
    slotBack.borderSize = 2
    slotBack.border = border
    slotBack.Paint = function( self2, w, h ) 
        BSHADOWS.BeginShadow( name .. (amount or 0), self:GetShadowBounds() )
        local x, y = self2:LocalToScreen( 0, 0 )
        draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 1 ) )		
        BSHADOWS.EndShadow( name .. (amount or 0), x, y, 1, 1, 2, 255, 0, 0, false )
    
        if( self2.border ) then
            BOTCHED.FUNC.DrawRoundedMask( 8, 0, 0, w, h, function()
                BOTCHED.FUNC.DrawGradientBox( 0, 0, w, h, 1, unpack( self2.border.Colors ) )
            end )
        else
            draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2 ) )
        end
    
        draw.RoundedBox( 8, self2.borderSize, self2.borderSize, w-(2*self2.borderSize), h-(2*self2.borderSize), BOTCHED.FUNC.GetTheme( 1 ) )
    end

    local slotPanel = vgui.Create( "botched_item_questslot", slotBack )
    slotPanel:SetSize( self.slotSize, self.slotSize )
    slotPanel:SetItemInfo( name, model, amount, border, modelColor )

    return slotPanel
end

function PANEL:OpenItemsEarned()
    self.lastPage = true

    self.itemsEarnedPage = vgui.Create( "DPanel", self.centerArea )
    self.itemsEarnedPage:SetSize( self.pageW, self.pageH )
    self.itemsEarnedPage:SetPos( self.centerArea:GetWide()+self.pageX, self.pageY )
    self.itemsEarnedPage.Paint = function() end

    self.firstPage:MoveTo( -self.centerArea:GetWide()+self.pageX, self.pageY, 0.2 )
    self.itemsEarnedPage:MoveTo( self.pageX, self.pageY, 0.2 )

    surface.SetFont( "MontserratBold50" )
    local textX, textY = surface.GetTextSize( "ITEMS EARNED" )

    local itemsEarnedTop = vgui.Create( "DPanel", self.itemsEarnedPage )
    itemsEarnedTop:Dock( TOP )
    itemsEarnedTop:SetTall( textY-18 )
    itemsEarnedTop.Paint = function( self2, w, h )
        draw.SimpleText( "ITEMS EARNED", "MontserratBold50", w/2, h/2-2, BOTCHED.FUNC.GetTheme( 4, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end 

    local gridWide = self.itemsEarnedPage:GetWide()
    local slotsWide = math.floor( gridWide/BOTCHED.FUNC.ScreenScale( 125 ) )
    local spacing = 10
    self.slotSize = (gridWide-((slotsWide-1)*spacing))/slotsWide

    self.itemsEarnedLayout = vgui.Create( "DIconLayout", self.itemsEarnedPage )
    self.itemsEarnedLayout:Dock( FILL )
    self.itemsEarnedLayout:DockMargin( 0, 25, 0, 0 )
    self.itemsEarnedLayout:SetSpaceX( spacing )
    self.itemsEarnedLayout:SetSpaceY( spacing )

    local function AddRewardSlot( title, material, amount, is3Star )
        local slotPanel = self:CreateSlotPanel( title, material, amount, BOTCHED.CONFIG.Borders.Gold )
        slotPanel:SetSpecial( is3Star )
    end

    local function AddRewardSlots( rewardTable, is3Star )
        if( rewardTable.Mana ) then
            AddRewardSlot( "Mana", "materials/botched/icons/mana_64.png", rewardTable.Mana, is3Star )
        end

        if( rewardTable.Gems ) then
            AddRewardSlot( "Gems", "materials/botched/icons/gems_64.png", rewardTable.Gems, is3Star )
        end

        for k, v in pairs( rewardTable.Items or {} ) do
            local configItem = BOTCHED.CONFIG.Items[k]
            if( not configItem ) then continue end

            local slotPanel = self:CreateSlotPanel( configItem.Name, configItem.Model, v, configItem.Border, configItem.ModelColor )
            slotPanel:SetSpecial( is3Star )
        end
    end

    if( self.questInfo.First3Stars ) then AddRewardSlots( self.questConfig.Reward3Stars, true ) end
    if( self.questInfo.FirstClear ) then AddRewardSlots( self.questConfig.Reward ) end
    if( self.questInfo.Items ) then 
        for k, v in pairs( self.questInfo.Items ) do
            local configItem = BOTCHED.CONFIG.Items[k]
            if( not configItem ) then continue end

            self:CreateSlotPanel( configItem.Name, configItem.Model, v, configItem.Border, configItem.ModelColor )
        end
    end
end

function PANEL:GetShadowBounds()
    local x, y = self.mainPanel:LocalToScreen( 0, 0 )
    return x, y, x+self.mainPanel:GetWide(), y+self.mainPanel:GetTall()
end

vgui.Register( "botched_popup_quest_over", PANEL, "botched_popup_base" )