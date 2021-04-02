local PANEL = {}

function PANEL:Init()
    self.targetW, self.targetH = ScrW()*0.5, ScrH()*0.55
    self.headerHeight = 40
    self:SetSize( ScrW()*0.5, 0 )
    self:MakePopup()
    self:SetTitle( "" )
    self:SetDraggable( false )
    self:ShowCloseButton( false )
    self:DockPadding( 0, self.headerHeight, 0, 0 )

    self:SetAlpha( 0 )
    self:AlphaTo( 255, 0.2 )
    self:SizeTo( self:GetWide(), ScrH()*0.55, 0.2, 0, -1, function()
        self:Center()
    end )

    self:SetHeader( "Admin Menu" )

    self.navigation = vgui.Create( "botched_mainmenu_sheet_bottom", self )
    self.navigation:Dock( FILL )
    self.navigation:SetSize( self.targetW, self.targetH-self.headerHeight )
    self.navigation.Paint = function() end

    -- local homePage = vgui.Create( "botched_adminmenu_home", self.navigation )
    -- self.navigation:AddPage( "HOME", Material( "materials/botched/icons/home.png" ), homePage )

    local playersPage = vgui.Create( "botched_adminmenu_players", self.navigation )
    self.navigation:AddPage( "PLAYERS", Material( "materials/botched/icons/players.png" ), playersPage )

    local playermodelsPage = vgui.Create( "botched_adminmenu_playermodels", self.navigation )
    self.navigation:AddPage( "PLAYERMODELS", Material( "materials/botched/icons/character.png" ), playermodelsPage )

    local themesPage = vgui.Create( "botched_adminmenu_themes", self.navigation )
    self.navigation:AddPage( "THEMES", Material( "materials/botched/icons/inventory.png" ), themesPage )
end

function PANEL:CreateCloseButton()
    local size = 24

    if( IsValid( self.closeButton ) ) then
        self.closeButton:SetSize( size, size )
        self.closeButton:SetPos( self:GetWide()-size-((self.headerHeight-size)/2), (self.headerHeight/2)-(size/2) )
        return
    end

    self.closeButton = vgui.Create( "DButton", self )
	self.closeButton:SetSize( size, size )
	self.closeButton:SetPos( self:GetWide()-size-((self.headerHeight-size)/2), (self.headerHeight/2)-(size/2) )
	self.closeButton:SetText( "" )
    local closeMat = Material( "materials/botched/icons/close.png" )
    local textColor = BOTCHED.FUNC.GetTheme( 4 )
	self.closeButton.Paint = function( self2, w, h )
		if( self2:IsHovered() and !self2:IsDown() ) then
			surface.SetDrawColor( textColor.r*0.6, textColor.g*0.6, textColor.b*0.6 )
		elseif( self2:IsDown() || self2.m_bSelected ) then
			surface.SetDrawColor( textColor.r*0.8, textColor.g*0.8, textColor.b*0.8 )
		else
			surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 1, 200 ) )
		end

		surface.SetMaterial( closeMat )
		surface.DrawTexturedRect( 0, 0, w, h )
	end
    self.closeButton.DoClick = function()
        self:Close()
    end
end

function PANEL:Close()
    gui.EnableScreenClicker( false )
    self:SetKeyboardInputEnabled( false )
    
    self:AlphaTo( 0, 0.2 )
    self:SizeTo( self:GetWide(), 0, 0.2, 0, -1, function()
        self:Remove()
    end )
end

function PANEL:OnSizeChanged( newW, newH )
    self:CreateCloseButton()
    self:Center()
end

function PANEL:SetHeader( header )
    self.header = header
end

function PANEL:Paint( w, h )
    BSHADOWS.BeginShadow( "admin_menu" )
    BSHADOWS.SetShadowSize( "admin_menu", w, h )
    local x, y = self:LocalToScreen( 0, 0 )
    draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 1 ) )			
    BSHADOWS.EndShadow( "admin_menu", x, y, 1, 2, 2, 255, 0, 0, false )

    draw.RoundedBoxEx( 8, 0, 0, w, self.headerHeight, BOTCHED.FUNC.GetTheme( 2 ), true, true, false, false )

    draw.SimpleText( (self.header or ""), "MontserratMedium25", 10, (self.headerHeight or 40)/2-2, BOTCHED.FUNC.GetTheme( 4 ), 0, TEXT_ALIGN_CENTER )
end

vgui.Register( "botched_adminmenu", PANEL, "DFrame" )