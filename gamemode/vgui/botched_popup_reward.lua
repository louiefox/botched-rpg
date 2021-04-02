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
        BSHADOWS.BeginShadow( "popup_reward" )
        BSHADOWS.SetShadowSize( "popup_reward", w, h )
        local x, y = self2:LocalToScreen( 0, 0 )
        draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 1 ) )			
        BSHADOWS.EndShadow( "popup_reward", x, y, 1, 2, 2, 255, 0, 0, false )
    end
    self.mainPanel.OnSizeChanged = function( self2 )
        self2:Center()
    end

    self.header = vgui.Create( "DPanel", self.mainPanel )
    self.header:Dock( TOP )
    self.header:DockMargin( 0, 25, 0, 25 )
    self.header:SetTall( 35 )
    self.header.Paint = function( self2, w, h )
        draw.SimpleText( self.headerText or "", "MontserratBold30", w/2, h/2-1, BOTCHED.FUNC.GetTheme( 3 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
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

function PANEL:DisableClose()
    self.backButton:SetDisabled( true )
    self.closeButton:Remove()
end

function PANEL:SetHeader( header )
    self.headerText = header
end

function PANEL:SetButtonText( buttonText )
    self.buttonText = buttonText
end

function PANEL:SetRewardTable( rewardTable, doClick )
    local itemEntries = 0
    local function AddItemEntry( rewardAmount, name, model )
        local itemSlot = vgui.Create( "botched_item_slotbar", self.mainPanel )
        itemSlot:Dock( TOP )
        itemSlot:DockMargin( 25, 0, 25, 10 )
        itemSlot:SetItemInfo( rewardAmount, false, name, model )

        itemEntries = itemEntries+1
    end

    if( rewardTable.Gems ) then
        AddItemEntry( rewardTable.Gems, "Gems", "materials/botched/icons/gems.png" )
    end

    if( rewardTable.Mana ) then
        AddItemEntry( rewardTable.Mana, "Mana", "materials/botched/icons/mana.png" )
    end

    for k, v in pairs( rewardTable.Items or {} ) do
        local itemConfig = BOTCHED.CONFIG.Items[k]
        if( not itemConfig ) then continue end

        AddItemEntry( v, itemConfig.Name, itemConfig.Model )
    end

    local continueButton = vgui.Create( "DButton", self.mainPanel )
	continueButton:Dock( BOTTOM )
	continueButton:DockMargin( 10, 10, 10, 10 )
	continueButton:SetTall( 40 )
	continueButton:SetText( "" )
	local alpha = 0
	continueButton.Paint = function( self2, w, h )
		if( self2:IsHovered() ) then
			alpha = math.Clamp( alpha+5, 0, 75 )
		else
			alpha = math.Clamp( alpha-5, 0, 75 )
        end
        
        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ) )
		draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 3, alpha ) )

		draw.SimpleText( self.buttonText or "CONTINUE", "MontserratBold25", w/2, h/2-1, BOTCHED.FUNC.GetTheme( 4, 75+(180*(alpha/75)) ), 1, 1 )
	end
    continueButton.DoClick = function()
        doClick()
        self.backButton.DoClick()
    end

    self.mainPanel.targetH = self.header:GetTall()+50+(itemEntries*50)+continueButton:GetTall()+25
    self.mainPanel:SizeTo( self.mainPanel:GetWide(), self.mainPanel.targetH, 0.2 )
end

function PANEL:Paint( w, h )
    BOTCHED.FUNC.DrawBlur( self, 4, 4 )
end

vgui.Register( "botched_popup_reward", PANEL, "DFrame" )