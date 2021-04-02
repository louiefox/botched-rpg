local PANEL = {}

function PANEL:Init()
    self:SetHeader( "EQUIPMENT REFINEMENT" )
    self:SetPopupWide( ScrW()*0.25 )
end

function PANEL:SetInfo( currentStar, nextStar, equipmentKey, currentRank )
    local currentStarConfig = BOTCHED.CONFIG.EquipmentStars[currentStar]
    local nextStarConfig = BOTCHED.CONFIG.EquipmentStars[nextStar]
    local equipmentConfig = BOTCHED.CONFIG.Equipment[equipmentKey]
    if( not currentStarConfig or not nextStarConfig or not equipmentConfig ) then return end

    local slotSize = 200

    local topPanel = vgui.Create( "DPanel", self.mainPanel )
    topPanel:Dock( TOP )
    topPanel:DockMargin( 25, 25, 25, 0 )
    topPanel:SetTall( slotSize*1.2 )
    local iconMat = Material( "materials/botched/icons/compare_32.png" )
    topPanel.Paint = function( self2, w, h ) 
        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 4 ) )
        surface.SetMaterial( iconMat )
        local iconSize = 32
        surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
    end

    local itemSlot1 = vgui.Create( "botched_equipment_slot", topPanel )
    itemSlot1:SetSize( slotSize, slotSize*1.2 )
    itemSlot1:SetItemInfo( equipmentConfig.Name, equipmentConfig.Model, currentStar, currentRank )
    itemSlot1:SetBorder( (BOTCHED.CONFIG.CharacterRanks[currentRank] or {}).Border )

    local itemSlot2 = vgui.Create( "botched_equipment_slot", topPanel )
    itemSlot2:SetSize( slotSize, slotSize*1.2 )
    itemSlot2:SetPos( self:GetPopupWide()-50-itemSlot1:GetWide(), 0 )
    itemSlot2:SetItemInfo( equipmentConfig.Name, equipmentConfig.Model, nextStar, currentRank )
    itemSlot2:SetBorder( (BOTCHED.CONFIG.CharacterRanks[currentRank] or {}).Border )

    local infoPanel = vgui.Create( "DPanel", self.mainPanel )
    infoPanel:Dock( TOP )
    infoPanel:DockMargin( 25, 25, 25, 0 )
    infoPanel:SetTall( 40 )
    infoPanel.lerpWidth = 0
    infoPanel.Paint = function( self2, w, h ) 
        draw.SimpleText( "REFINEMENT POINTS", "MontserratBold21", 0, 0, BOTCHED.FUNC.GetTheme( 3 ) )
        draw.SimpleText( string.Comma( self.GetSelectedPoints() ) .. "/" .. string.Comma( nextStarConfig.PointsRequired ), "MontserratBold21", w, 0, BOTCHED.FUNC.GetTheme( 3 ), TEXT_ALIGN_RIGHT )

        draw.RoundedBox( 8, 0, h-16, w, 16, BOTCHED.FUNC.GetTheme( 2, 100 ) )

        self2.lerpWidth = Lerp( FrameTime()*20, self2.lerpWidth, math.Clamp( w*(self.GetSelectedPoints()/nextStarConfig.PointsRequired), 0, w ) )
        BOTCHED.FUNC.DrawRoundedMask( 8, 0, h-16, w, 16, function()
            surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 3, 100 ) )
            surface.DrawRect( 0, h-16, self2.lerpWidth, 16 )
        end )
    end

    self.SelectedCrystals = {}
    function self.GetSelectedPoints()
        local totalPoints = 0
        for k, v in pairs( self.SelectedCrystals ) do
            totalPoints = totalPoints+(((BOTCHED.CONFIG.Items[k] or {}).Points or 0)*v)
        end

        return totalPoints
    end

    self.bottomButton = vgui.Create( "DButton", self.mainPanel )
	self.bottomButton:Dock( BOTTOM )
	self.bottomButton:DockMargin( 25, 25, 25, 25 )
	self.bottomButton:SetTall( 40 )
	self.bottomButton:SetText( "" )
	local alpha = 0
	self.bottomButton.Paint = function( self2, w, h )
		if( self2:IsHovered() ) then
			alpha = math.Clamp( alpha+5, 0, 75 )
		else
			alpha = math.Clamp( alpha-5, 0, 75 )
        end
        
        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ) )
		draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 3, alpha ) )

		draw.SimpleText( "REFINE", "MontserratBold25", w/2, h/2-1, BOTCHED.FUNC.GetTheme( 4, 75+(180*(alpha/75)) ), 1, 1 )
	end
    self.bottomButton.DoClick = function()
        if( self.GetSelectedPoints() < nextStarConfig.PointsRequired ) then 
            notification.AddLegacy( "You haven't selected enough points!", 1, 3 )
            return 
        end

        net.Start( "Botched.RequestEquipmentRefinement" )
            net.WriteString( equipmentKey )
            net.WriteUInt( table.Count( self.SelectedCrystals ), 3 )
            
            for k, v in pairs( self.SelectedCrystals ) do
                net.WriteString( k )
                net.WriteUInt( v, 20 )
            end
        net.SendToServer()

        self:Close()
    end

    local manaCost = vgui.Create( "botched_item_slotbar", self.mainPanel )
    manaCost:Dock( BOTTOM )
    manaCost:DockMargin( 25, 25, 25, 0 )
    manaCost:SetItemInfo( LocalPlayer():GetMana(), (nextStarConfig.Cost or {}).Mana or 0, "Mana", "materials/botched/icons/mana.png" )

    local gridWide = (self:GetPopupWide()-75)/2
    local slotsWide = math.floor( gridWide/BOTCHED.FUNC.ScreenScale( 100 ) )
    local spacing = 10
    self.slotSize = (gridWide-((slotsWide-1)*spacing))/slotsWide

    local availableBack = vgui.Create( "DPanel", self.mainPanel )
    availableBack:Dock( LEFT )
    availableBack:DockMargin( 25, 25, 0, 0 )
    availableBack:SetWide( (self:GetPopupWide()-75)/2 )
    availableBack.Paint = function() end

    local availableHeader = vgui.Create( "DPanel", availableBack )
    availableHeader:Dock( TOP )
    availableHeader:SetTall( 25 )
    availableHeader.Paint = function( self2, w, h ) 
        draw.SimpleText( "AVAILABLE", "MontserratBold21", 0, 0, BOTCHED.FUNC.GetTheme( 3 ) )
    end

    self.availableGrid = vgui.Create( "DIconLayout", availableBack )
    self.availableGrid:Dock( TOP )
    self.availableGrid:SetSpaceY( spacing )
    self.availableGrid:SetSpaceX( spacing )

    local selectedBack = vgui.Create( "DPanel", self.mainPanel )
    selectedBack:Dock( RIGHT )
    selectedBack:DockMargin( 0, 25, 25, 0 )
    selectedBack:SetWide( (self:GetPopupWide()-75)/2 )
    selectedBack.Paint = function() end

    local selectedHeader = vgui.Create( "DPanel", selectedBack )
    selectedHeader:Dock( TOP )
    selectedHeader:SetTall( 25 )
    selectedHeader.Paint = function( self2, w, h ) 
        draw.SimpleText( "SELECTED", "MontserratBold21", 0, 0, BOTCHED.FUNC.GetTheme( 3 ) )
    end

    self.selectedGrid = vgui.Create( "DIconLayout", selectedBack )
    self.selectedGrid:Dock( TOP )
    self.selectedGrid:SetSpaceY( spacing )
    self.selectedGrid:SetSpaceX( spacing )

    function self.RefreshCrystals()
        self.availableGrid:Clear()
        self.availableGrid:SetTall( 0 )
        self.availableGrid.SlotCount = 0
    
        local sortedInventory = {}
        for k, v in pairs( LocalPlayer():GetInventory() ) do
            local configItem = BOTCHED.CONFIG.Items[k]
    
            if( not configItem or configItem.Type != "refinement_crystal" ) then continue end

            table.insert( sortedInventory, { configItem.Stars or 0, k, v, configItem } )
        end
        table.SortByMember( sortedInventory, 1, true )

        for k, v in ipairs( sortedInventory ) do
            local amount = v[3]-(self.SelectedCrystals[v[2]] or 0)
            if( amount < 1 ) then continue end
            
            local itemPanel = self.availableGrid:Add( "botched_item_slot" )
            itemPanel:SetSize( self.slotSize, self.slotSize )
            itemPanel:SetItemInfo( v[4].Name, v[4].Model, amount, v[1], function()
                if( self.GetSelectedPoints() >= nextStarConfig.PointsRequired ) then 
                    notification.AddLegacy( "You already have enough points!", 1, 3 )
                    return 
                end

                self.SelectedCrystals[v[2]] = (self.SelectedCrystals[v[2]] or 0)+1
                self.RefreshCrystals()
            end )
            itemPanel:DisableText( true )
            itemPanel:AddTopLeftText( string.Comma( v[4].Points ) .. "PT" )
            if( v[4].Border ) then itemPanel:SetBorder( v[4].Border ) end
            if( v[4].ModelColor ) then itemPanel:SetModelColor( v[4].ModelColor ) end

            self.availableGrid.SlotCount = self.availableGrid.SlotCount+1
        end

        self.selectedGrid:Clear()
        self.selectedGrid:SetTall( 0 )
        self.selectedGrid.SlotCount = 0

        local sortedSelected = {}
        for k, v in pairs( self.SelectedCrystals ) do
            local configItem = BOTCHED.CONFIG.Items[k]
    
            if( not configItem or configItem.Type != "refinement_crystal" ) then continue end

            table.insert( sortedSelected, { configItem.Stars or 0, k, v, configItem } )
        end
        table.SortByMember( sortedSelected, 1, true )
    
        for k, v in pairs( sortedSelected ) do
            local itemPanel = self.selectedGrid:Add( "botched_item_slot" )
            itemPanel:SetSize( self.slotSize, self.slotSize )
            itemPanel:SetItemInfo( v[4].Name .. "_selected", v[4].Model, v[3], v[1], function()
                self.SelectedCrystals[v[2]] = (self.SelectedCrystals[v[2]] or 0)-1
                if( self.SelectedCrystals[v[2]] < 1 ) then self.SelectedCrystals[v[2]] = nil end

                self.RefreshCrystals()
            end )
            itemPanel:DisableText( true )
            itemPanel:AddTopLeftText( string.Comma( v[4].Points ) .. "PT" )
            if( v[4].Border ) then itemPanel:SetBorder( v[4].Border ) end
            if( v[4].ModelColor ) then itemPanel:SetModelColor( v[4].ModelColor ) end

            self.selectedGrid.SlotCount = self.selectedGrid.SlotCount+1
        end

        self.availableGrid:SetTall( (math.ceil( self.availableGrid.SlotCount/slotsWide )*(self.slotSize+spacing))-spacing )
        self.selectedGrid:SetTall( (math.ceil( self.selectedGrid.SlotCount/slotsWide )*(self.slotSize+spacing))-spacing )

        self:SetExtraHeight( topPanel:GetTall()+25+infoPanel:GetTall()+25+math.max( availableHeader:GetTall(), selectedHeader:GetTall() )+math.max( self.availableGrid:GetTall(), self.selectedGrid:GetTall() )+25+self.bottomButton:GetTall()+50+manaCost:GetTall()+25 )
    end

    self.OnClose = function()
        itemSlot1:Remove()
        itemSlot2:Remove()
    end

    self.RefreshCrystals()
end

vgui.Register( "botched_popup_refine", PANEL, "botched_popup_base" )