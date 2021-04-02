local PANEL = {}

function PANEL:Init()
    self:SetSize( ScrW(), ScrH() )
    self:MakePopup()
    self:SetTitle( "" )
    self:SetDraggable( false )
    self:ShowCloseButton( false )
    self:SetAlpha( 0 )
    self:AlphaTo( 255, 0.2 )

    self.backButton = vgui.Create( "DButton", self )
	self.backButton:Dock( FILL )
	self.backButton:SetText( "" )
	self.backButton:SetCursor( "arrow" )
	self.backButton.Paint = function() end
    self.backButton.DoClick = function()
        self:AlphaTo( 0, 0.2 )
        self.mainPanel:SizeTo( self.mainPanel:GetWide(), 0, 0.2, 0, -1, function()
            self:Remove()
        end )
    end

    self.mainPanel = vgui.Create( "DPanel", self )
    self.mainPanel:SetSize( ScrW()*0.15, 0 )
    self.mainPanel:Center()
    self.mainPanel.Paint = function( self2, w, h )
        BSHADOWS.BeginShadow( "popup_rankup" )
        BSHADOWS.SetShadowSize( "popup_rankup", w, h )
        local x, y = self2:LocalToScreen( 0, 0 )
        draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 1 ) )			
        BSHADOWS.EndShadow( "popup_rankup", x, y, 1, 2, 2, 255, 0, 0, false )
    end
    self.mainPanel.OnSizeChanged = function( self2 )
        self2:Center()
    end

    self.header = vgui.Create( "DPanel", self.mainPanel )
    self.header:Dock( TOP )
    self.header:DockMargin( 0, 25, 0, 25 )
    self.header:SetTall( 35 )
    self.header.Paint = function( self2, w, h )
        draw.SimpleText( "RANKUP", "MontserratBold30", w/2, h/2-1, BOTCHED.FUNC.GetTheme( 3 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end

    local size = 24
    self.closeButton = vgui.Create( "DButton", self.mainPanel )
	self.closeButton:SetSize( size, size )
	self.closeButton:SetPos( self.mainPanel:GetWide()-size-10, 10 )
	self.closeButton:SetText( "" )
    local closeMat = Material( "materials/botched/icons/close.png" )
    local textColor = BOTCHED.FUNC.GetTheme( 4 )
	self.closeButton.Paint = function( self2, w, h )
		if( self2:IsHovered() and !self2:IsDown() ) then
			surface.SetDrawColor( textColor.r*0.6, textColor.g*0.6, textColor.b*0.6 )
		elseif( self2:IsDown() || self2.m_bSelected ) then
			surface.SetDrawColor( textColor.r*0.8, textColor.g*0.8, textColor.b*0.8 )
		else
			surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 2, 200 ) )
		end

		surface.SetMaterial( closeMat )
		surface.DrawTexturedRect( 0, 0, w, h )
	end
    self.closeButton.DoClick = self.backButton.DoClick

    self.mainPanel.targetH = self.header:GetTall()+50
    self.mainPanel:SetTall( self.mainPanel.targetH )
end

function PANEL:SetInfo( currentRank, nextRank, equipmentKey )
    local currentRankConfig = BOTCHED.CONFIG.EquipmentRanks[currentRank]
    local nextRankConfig = BOTCHED.CONFIG.EquipmentRanks[nextRank]
    local equipmentConfig = BOTCHED.CONFIG.Equipment[equipmentKey]
    if( not currentRankConfig or not nextRankConfig or not equipmentConfig ) then return end

    local rankHeader = vgui.Create( "DPanel", self.mainPanel )
    rankHeader:Dock( TOP )
    rankHeader:DockMargin( 25, 0, 25, 0 )
    rankHeader:SetTall( 15 )
    rankHeader.Paint = function( self2, w, h )
        draw.SimpleText( "RANK " .. currentRank, "MontserratBold25", w/2.5, h/2-1, currentRankConfig.Color or BOTCHED.FUNC.GetTheme( 4, 100 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        draw.SimpleText( "RANK " .. nextRank, "MontserratBold25", (w/4)*3, h/2-1, nextRankConfig.Color or BOTCHED.FUNC.GetTheme( 4, 100 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end

    for k, v in pairs( equipmentConfig.Stats ) do
        local devConfigTable = BOTCHED.DEVCONFIG.EquipmentStats[k]

        local statEntry = vgui.Create( "DPanel", self.mainPanel )
        statEntry:Dock( TOP )
        statEntry:DockMargin( 25, 0, 25, 0 )
        statEntry:SetTall( 30 )
        statEntry.Paint = function( self2, w, h )
            draw.SimpleText( devConfigTable.Name, "MontserratMedium20", 0, h/2, BOTCHED.FUNC.GetTheme( 4, 100 ), 0, TEXT_ALIGN_CENTER )

            draw.SimpleText( math.ceil( v*(currentRankConfig.StatMultiplier or 1) ), "MontserratBold22", w/2.5, h/2, BOTCHED.FUNC.GetTheme( 3 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            draw.SimpleText( math.ceil( v*(nextRankConfig.StatMultiplier or 1) ), "MontserratBold22", (w/4)*3, h/2, Color( 39, 200, 96 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
    end

    local costHeader = vgui.Create( "DPanel", self.mainPanel )
    costHeader:Dock( TOP )
    costHeader:DockMargin( 25, 25, 0, 0 )
    costHeader:SetTall( 15 )
    costHeader.Paint = function( self2, w, h )
        draw.SimpleText( "RESOURCES", "MontserratBold22", 0, h/2-1, BOTCHED.FUNC.GetTheme( 3 ), 0, TEXT_ALIGN_CENTER )
    end

    local resourceEntries = 0
    local function AddResourceEntry( ownedAmount, neededAmount, name, model )
        local itemSlot = vgui.Create( "botched_item_slotbar", self.mainPanel )
        itemSlot:Dock( TOP )
        itemSlot:DockMargin( 25, 10, 25, 0 )
        itemSlot:SetItemInfo( ownedAmount, neededAmount, name, model )

        resourceEntries = resourceEntries+1
    end

    if( (nextRankConfig.Cost or {}).Mana ) then
        AddResourceEntry( LocalPlayer():GetMana(), (nextRankConfig.Cost or {}).Mana, "Mana", "materials/botched/icons/mana.png" )
    end

    for k, v in pairs( (nextRankConfig.Cost or {}).Items or {} ) do
        local itemConfig = BOTCHED.CONFIG.Items[k]
        if( not itemConfig ) then continue end

        AddResourceEntry( LocalPlayer():GetInventory()[k] or 0, v, itemConfig.Name, itemConfig.Model )
    end

    local rankupButton = vgui.Create( "DButton", self.mainPanel )
	rankupButton:Dock( BOTTOM )
	rankupButton:DockMargin( 10, 10, 10, 10 )
	rankupButton:SetTall( 40 )
	rankupButton:SetText( "" )
	local alpha = 0
	rankupButton.Paint = function( self2, w, h )
		if( self2:IsHovered() ) then
			alpha = math.Clamp( alpha+5, 0, 75 )
		else
			alpha = math.Clamp( alpha-5, 0, 75 )
        end
        
        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ) )
		draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 3, alpha ) )

		draw.SimpleText( "RANK UP", "MontserratBold25", w/2, h/2-1, BOTCHED.FUNC.GetTheme( 4, 75+(180*(alpha/75)) ), 1, 1 )
	end
    rankupButton.DoClick = function()
        if( not LocalPlayer():CanAffordCost( nextRankConfig.Cost ) ) then
            notification.AddLegacy( "You cannot afford this!", 1, 3 )
            return
        end

        net.Start( "Botched.RequestEquipmentRankUp" )
            net.WriteString( equipmentKey )
        net.SendToServer()
        self.backButton.DoClick()
    end

    self.mainPanel.targetH = self.header:GetTall()+50+rankHeader:GetTall()+(table.Count( equipmentConfig.Stats )*30)+costHeader:GetTall()+25+(resourceEntries*50)+rankupButton:GetTall()+20+25
    self.mainPanel:SizeTo( self.mainPanel:GetWide(), self.mainPanel.targetH, 0.2 )
end

function PANEL:Paint( w, h )
    BOTCHED.FUNC.DrawBlur( self, 4, 4 )
end

vgui.Register( "botched_popup_rankup", PANEL, "DFrame" )