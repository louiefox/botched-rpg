local PANEL = {}

function PANEL:Init()
    self:SetHeader( "QUEST VIEW" )
    self:SetDrawHeader( false )

    self:SetPopupWide( ScrW()*0.45 )
    self:SetExtraHeight( ScrH()*0.4 )
    self.closeButton:Remove()

    self.centerArea = vgui.Create( "DPanel", self )
    self.centerArea:SetPos( 0, 0 )
    self.centerArea:SetSize( self:GetPopupWide(), self.mainPanel.targetH )
    self.centerArea.Paint = function( self, w, h ) end 

    self.slotSize = 110
end

local star24Mat = Material( "materials/botched/icons/star_24.png" )
function PANEL:CreateSlotPanel( parent, name, model, amount, border, modelColor )
    parent.border = border
    
    local slotPanel = vgui.Create( "botched_item_questslot", parent )
    slotPanel:SetSize( self.slotSize, self.slotSize )
    slotPanel:SetItemInfo( name, model, amount, border, modelColor )

    return slotPanel
end

function PANEL:SetQuestInfo( questLineKey, questKey )
    local questLine = BOTCHED.CONFIG.QuestsLines[questLineKey]
    if( not questLine ) then return end

    local quest = questLine.Quests[questKey]
    if( not quest ) then return end

    local completedQuests = LocalPlayer():GetCompletedQuests()
    local completedStars = (completedQuests[questLineKey] or {})[questKey] or 0

    local iconSize, iconSpacing = 64, 10
    local starMat = Material( "materials/botched/icons/star_64.png" )
    local starBlankMat = Material( "materials/botched/icons/star_64_blank.png" )

    local starPanel = vgui.Create( "DPanel", self.centerArea )
    starPanel:SetSize( (3*(iconSize+iconSpacing))-iconSpacing, iconSize )
    starPanel:SetPos( self.centerArea:GetWide()-25-starPanel:GetWide(), 25 )
    starPanel.Paint = function( self2, w, h )
        surface.SetMaterial( starBlankMat )
        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 2, 100 ) )
        for i = 1, 3 do
            surface.DrawTexturedRect( ((i-1)*(iconSize+iconSpacing)), (h/2)-(iconSize/2), iconSize, iconSize )
        end

        surface.SetMaterial( starMat )
        surface.SetDrawColor( 255, 255, 255 )
        for i = 1, completedStars do
            surface.DrawTexturedRect( ((i-1)*(iconSize+iconSpacing)), (h/2)-(iconSize/2), iconSize, iconSize )
        end
    end

    local titlePanel = vgui.Create( "DPanel", self.centerArea )
    titlePanel:Dock( TOP )
    titlePanel:DockMargin( 25, 25, 0, 0 )
    titlePanel:SetTall( iconSize )
    titlePanel.Paint = function( self2, w, h )
        draw.SimpleText( string.upper( questLine.Title ) .. " " .. questLineKey .. "-" .. questKey, "MontserratBold50", 0, (h/2)-(13/2), BOTCHED.FUNC.GetTheme( 4, 75 ), 0, TEXT_ALIGN_CENTER )
    end

    local slotSpacing = 10

    local leftPanel = vgui.Create( "DPanel", self.centerArea )
    leftPanel:Dock( LEFT )
    leftPanel:DockMargin( 25, 25, 0, 25 )
    leftPanel:SetWide( ((5*(self.slotSize+slotSpacing))-slotSpacing)+self.slotSize+25 )
    leftPanel.Paint = function() end
    leftPanel.AddRow = function( iconMat, name )
        local rowPanel = vgui.Create( "DPanel", leftPanel )
        rowPanel:Dock( BOTTOM )
        rowPanel:SetTall( self.slotSize )
        rowPanel:DockMargin( 0, 25, 0, 0 )
        rowPanel.Paint = function( self2, w, h ) 
            surface.SetMaterial( iconMat )
            surface.SetDrawColor( 255, 255, 255 )
            local iconSize = 64
            surface.DrawTexturedRect( (h/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )

            draw.SimpleText( name, "MontserratBold20", h/2, h, BOTCHED.FUNC.GetTheme( 4, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
        end

        leftPanel:SetTall( leftPanel:GetTall()+rowPanel:GetTall()+(leftPanel:GetTall() != 0 and 25 or 0) )

        local rowSlots = {}
        for i = 1, 5 do
            local rowSlot = vgui.Create( "DPanel", rowPanel )
            rowSlot:Dock( RIGHT )
            rowSlot:SetWide( rowPanel:GetTall() )
            rowSlot:DockMargin( 10, 0, 0, 0 )
            rowSlot.borderSize = 2
            rowSlot.Paint = function( self2, w, h ) 
                BSHADOWS.BeginShadow( name .. i, self:GetShadowBounds() )
                local x, y = self2:LocalToScreen( 0, 0 )
                draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 1 ) )		
                BSHADOWS.EndShadow( name .. i, x, y, 1, 1, 2, 255, 0, 0, false )
            
                if( self2.border ) then
                    BOTCHED.FUNC.DrawRoundedMask( 8, 0, 0, w, h, function()
                        BOTCHED.FUNC.DrawGradientBox( 0, 0, w, h, 1, unpack( self2.border.Colors ) )
                    end )
                else
                    draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2 ) )
                end
            
                draw.RoundedBox( 8, self2.borderSize, self2.borderSize, w-(2*self2.borderSize), h-(2*self2.borderSize), BOTCHED.FUNC.GetTheme( 1 ) )
            end

            rowSlots[5-(i-1)] = rowSlot
        end

        return rowSlots
    end

    local rewardSlots = leftPanel.AddRow( Material( "materials/botched/quests/reward.png" ), "Rewards" )

    local currentSlot = 0
    local function AddRewardSlot( title, material, amount, is3Star )
        currentSlot = currentSlot+1
        if( not IsValid( rewardSlots[currentSlot] ) ) then return end

        local slotPanel = self:CreateSlotPanel( rewardSlots[currentSlot], title, material, amount, BOTCHED.CONFIG.Borders.Gold )
        slotPanel:SetSpecial( is3Star )
    end

    local function AddRewardSlots( rewardTable, is3Star )
        for k, v in pairs( rewardTable.Items or {} ) do
            local configItem = BOTCHED.CONFIG.Items[k]
            if( not configItem ) then continue end

            currentSlot = currentSlot+1
            if( not IsValid( rewardSlots[currentSlot] ) ) then break end

            local slotPanel = self:CreateSlotPanel( rewardSlots[currentSlot], configItem.Name, configItem.Model, v, configItem.Border, configItem.ModelColor )
            slotPanel:SetSpecial( is3Star )
        end

        if( rewardTable.Mana ) then
            AddRewardSlot( "Mana", "materials/botched/icons/mana_64.png", rewardTable.Mana, is3Star )
        end

        if( rewardTable.Gems ) then
            AddRewardSlot( "Gems", "materials/botched/icons/gems_64.png", rewardTable.Gems, is3Star )
        end
    end

    AddRewardSlots( quest.Reward )
    AddRewardSlots( quest.Reward3Stars, true )
    
    local items = {}
    for k, v in pairs( quest.Items ) do
        items[v[1]] = true
    end

    local itemSlots = leftPanel.AddRow( Material( "materials/botched/quests/items.png" ), "Items" )
    local currentSlot = 0
    for k, v in pairs( items ) do
        local configItem = BOTCHED.CONFIG.Items[k]
        if( not configItem ) then continue end

        currentSlot = currentSlot+1
        if( not IsValid( itemSlots[currentSlot] ) ) then break end

        self:CreateSlotPanel( itemSlots[currentSlot], configItem.Name, configItem.Model, false, configItem.Border, configItem.ModelColor )
    end

    local monsterSlots = leftPanel.AddRow( Material( "materials/botched/quests/monster.png" ), "Monsters" )
    local currentSlot = 0
    for k, v in pairs( quest.Monsters ) do
        local monsterConfig = BOTCHED.CONFIG.Monsters[k]
        if( not monsterConfig ) then continue end

        currentSlot = currentSlot+1
        if( not IsValid( monsterSlots[currentSlot] ) ) then break end

        self:CreateSlotPanel( monsterSlots[currentSlot], monsterConfig.Name, monsterConfig.Model, v )
    end

    local rightPanel = vgui.Create( "DPanel", self.centerArea )
    rightPanel:Dock( FILL )
    rightPanel:DockMargin( 25, self.centerArea:GetTall()-65-leftPanel:GetTall(), 25, 25 )
    rightPanel:SetWide( self.centerArea:GetWide()-leftPanel:GetWide()-75 )
    rightPanel.Paint = function() end

    local bottomRightPanel = vgui.Create( "DPanel", rightPanel )
    bottomRightPanel:Dock( BOTTOM )
    bottomRightPanel:SetTall( 50 )
    bottomRightPanel.Paint = function() end

    local closeButton = vgui.Create( "DButton", bottomRightPanel )
    closeButton:Dock( LEFT )
    closeButton:SetWide( (rightPanel:GetWide()-10)/2 )
    closeButton:SetText( "" )
    closeButton.Paint = function( self2, w, h )
        self2:CreateFadeAlpha( false, 255 )

        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ) )

        BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 2 ), 8 )
        BOTCHED.FUNC.DrawPartialRoundedBox( 8, 0, h-5, w, 5, BOTCHED.FUNC.GetTheme( 3, self2.alpha ), false, 16, false, h-5-11 )

        draw.SimpleText( "CLOSE", "MontserratBold25", w/2, h/2, BOTCHED.FUNC.GetTheme( 4, 75+(180*(self2.alpha/255)) ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
    closeButton.DoClick = function()
        self:Close()
    end

    local startButton = vgui.Create( "DButton", bottomRightPanel )
    startButton:Dock( RIGHT )
    startButton:SetWide( (rightPanel:GetWide()-10)/2 )
    startButton:SetText( "" )
    startButton.Paint = function( self2, w, h )
        self2:CreateFadeAlpha( false, 255 )

        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2 ) )

        BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 2 ), 8 )
        BOTCHED.FUNC.DrawPartialRoundedBox( 8, 0, h-5, w, 5, BOTCHED.FUNC.GetTheme( 3, self2.alpha ), false, 16, false, h-5-11 )

        draw.SimpleText( "START", "MontserratBold25", w/2, h/2, BOTCHED.FUNC.GetTheme( 4, 75+(180*(self2.alpha/255)) ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
    startButton.DoClick = function()
        if( LocalPlayer():Stamina() < quest.StaminaCost ) then
            BOTCHED.FUNC.DermaMessage( "You don't have enough stamina for this quest!", "STAMINA" )
            return
        end

        if( BOTCHED_ACTIVE_QUEST ) then
            BOTCHED.FUNC.DermaMessage( "You already have an active quest!", "QUEST" )
            return
        end
        
        BOTCHED.FUNC.DermaQuery( "Would you like to start this quest?", "QUEST", "Yes", function()
            net.Start( "Botched.RequestStartQuest" )
                net.WriteUInt( questLineKey, 8 )
                net.WriteUInt( questKey, 8 )
            net.SendToServer()
            self:Close()
        end, "No" )
    end

    local staminaMat = Material( "materials/botched/icons/stamina.png" )
    
    local staminaCost = vgui.Create( "DPanel", rightPanel )
    staminaCost:Dock( BOTTOM )
    staminaCost:DockMargin( 0, 0, 0, 10 )
    staminaCost:SetTall( 40 )
    staminaCost.Paint = function( self2, w, h ) 
        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ) )

        surface.SetMaterial( staminaMat )
        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 4, 75 ) )
        local iconSize = 24
        surface.DrawTexturedRect( (h/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize)

        local stamina = LocalPlayer():Stamina()
        draw.SimpleText( "STAMINA COST", "MontserratBold22", h, h/2-1, BOTCHED.FUNC.GetTheme( 4, 75 ), 0, TEXT_ALIGN_CENTER )
        draw.SimpleText( quest.StaminaCost, "MontserratBold30", w-10, h/2-1, BOTCHED.FUNC.GetTheme( 3 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
    end

    local currentStamina = vgui.Create( "DPanel", rightPanel )
    currentStamina:Dock( BOTTOM )
    currentStamina:DockMargin( 0, 0, 0, 10 )
    currentStamina:SetTall( 40 )
    currentStamina.Paint = function( self2, w, h ) 
        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ) )

        surface.SetMaterial( staminaMat )
        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 4, 75 ) )
        local iconSize = 24
        surface.DrawTexturedRect( (h/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize)

        local stamina = LocalPlayer():Stamina()
        draw.SimpleText( "STAMINA", "MontserratBold22", h, h/2-1, BOTCHED.FUNC.GetTheme( 4, 75 ), 0, TEXT_ALIGN_CENTER )
        draw.SimpleText( stamina, "MontserratBold30", w-10, h/2-1, BOTCHED.FUNC.GetTheme( 3 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
    end

    local timerMat = Material( "materials/botched/icons/timer.png" )
    local iconSize = 64

    local timeTable = string.FormattedTime( quest.TimeLimit )
    local timeText = string.format( "%02d:%02d", timeTable.m, timeTable.s )

    surface.SetFont( "MontserratBold70" )
    local textX, textY = surface.GetTextSize( timeText )

    local contentW = iconSize+textX+10

    local staminaCost = vgui.Create( "DPanel", rightPanel )
    staminaCost:Dock( FILL )
    staminaCost.Paint = function( self2, w, h ) 
        surface.SetMaterial( timerMat )
        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 2 ) )
        surface.DrawTexturedRect( (w/2)-(contentW/2), (h/2)-(iconSize/2), iconSize, iconSize )

        draw.SimpleText( timeText, "MontserratBold70", (w/2)+(contentW/2), h/2, BOTCHED.FUNC.GetTheme( 2 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
    end
end

function PANEL:GetShadowBounds()
    local x, y = self.mainPanel:LocalToScreen( 0, 0 )
    return 0, y, ScrW(), y+self.mainPanel:GetTall()
end

vgui.Register( "botched_popup_quest_view", PANEL, "botched_popup_base" )