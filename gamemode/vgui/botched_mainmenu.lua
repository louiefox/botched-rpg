local PANEL = {}

function PANEL:Init()
    self.targetH = ScrH()*0.55
    self.headerHeight = 40
    self:SetSize( ScrW()*0.5, 0 )
    self:DockPadding( 0, self.headerHeight, 0, 0 )

    self:Open()
    self:SetHeader( "Main Menu" )

    self.navigation = vgui.Create( "botched_mainmenu_sheet_bottom", self )
    self.navigation:Dock( FILL )
    self.navigation:SetSize( self:GetWide(), self.targetH-self.headerHeight )
    self.navigation.Paint = function() end

    local homePage = vgui.Create( "botched_mainmenu_home", self.navigation )
    self.navigation:AddPage( "HOME", Material( "materials/botched/icons/home.png" ), homePage )

    homePage:AddPageButton( "Shop", Material( "materials/botched/icons/shop_32.png" ), function() 
        notification.AddLegacy( "This feature has not been added yet!", 1, 3 )
    end )

    homePage:AddPageButton( "Presents", Material( "materials/botched/icons/rewards_32.png" ), function() 
        notification.AddLegacy( "This feature has not been added yet!", 1, 3 )
    end )

    homePage:AddPageButton( "Login Rewards", Material( "materials/botched/icons/daily.png" ), function() 
        if( IsValid( BOTCHED_LOGINREWARDS_MENU ) ) then return end
        BOTCHED_LOGINREWARDS_MENU = vgui.Create( "botched_popup_loginrewards" )
    end, function() return LocalPlayer():CanClaimLoginReward() and 1 or 0 end )

    homePage:AddPageButton( "Missions", Material( "materials/botched/icons/missions_32.png" ), function() 
        notification.AddLegacy( "This feature has not been added yet!", 1, 3 )
    end )

    homePage:AddPageButton( "Notices", Material( "materials/botched/icons/notices_32.png" ), function() 
        if( IsValid( BOTCHED_NOTICEMENU ) ) then return end
        BOTCHED_NOTICEMENU = vgui.Create( "botched_popup_notices" )
    end, function() 
        local notifCount = 0
        for k, v in ipairs( BOTCHED.CONFIG.Notices ) do
            if( cookie.GetNumber( "BOTCHED.Cookie.NoticeRead_" .. v.Time, 0 ) == 1 ) then continue end
            notifCount = notifCount+1
        end

        return notifCount
    end )

    local characterPage = vgui.Create( "botched_mainmenu_character", self.navigation )
    self.navigation:AddPage( "CHARACTER", Material( "materials/botched/icons/character.png" ), characterPage, "character", function()
        BOTCHED.FUNC.CompleteTutorialStep( 1, 2 )
    end )

    local inventoryPage = vgui.Create( "botched_mainmenu_inventory", self.navigation )
    self.navigation:AddPage( "INVENTORY", Material( "materials/botched/icons/inventory.png" ), inventoryPage, "inventory" )

    local craftingPage = vgui.Create( "botched_mainmenu_crafting", self.navigation )
    self.navigation:AddPage( "CRAFTING", Material( "materials/botched/icons/crafting.png" ), craftingPage, "crafting" )

    local questsPage = vgui.Create( "botched_mainmenu_quests", self.navigation )
    self.navigation:AddPage( "QUESTS", Material( "materials/botched/icons/quests.png" ), questsPage, "quests", function()
        BOTCHED.FUNC.CompleteTutorialStep( 3, 1 )
    end )

    local gachaPage = vgui.Create( "botched_mainmenu_gacha", self.navigation )
    self.navigation:AddPage( "GACHA", Material( "materials/botched/icons/gacha_16.png" ), gachaPage, "gacha" )
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

function PANEL:Open()
    self:SetVisible( true )
    gui.EnableScreenClicker( true )

    self:SetAlpha( 0 )
    self:AlphaTo( 255, 0.2 )
    self:SizeTo( self:GetWide(), ScrH()*0.55, 0.2, 0, -1, function()
        self:Center()
        self.FullyOpened = true
    end )
end

function PANEL:Close()
    self.FullyOpened = false
    gui.EnableScreenClicker( false )
    
    self:AlphaTo( 0, 0.2 )
    self:SizeTo( self:GetWide(), 0, 0.2, 0, -1, function()
        if( not BOTCHED_REMOVEONCLOSE ) then
            self:SetVisible( false )
        else
            self:Remove()
        end
    end )

    BOTCHED.FUNC.CompleteTutorialStep( 1, 7 )
end

function PANEL:OnSizeChanged( newW, newH )
    self:CreateCloseButton()
    self:Center()
end

function PANEL:SetHeader( header )
    self.header = header
end

function PANEL:SetPage( id )
    self.navigation:OpenPageByID( id )
end

function PANEL:Paint( w, h )
    BSHADOWS.BeginShadow( "main_menu" )
    BSHADOWS.SetShadowSize( "main_menu", w, h )
    local x, y = self:LocalToScreen( 0, 0 )
    draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 1 ) )			
    BSHADOWS.EndShadow( "main_menu", x, y, 1, 2, 2, 255, 0, 0, false )

    draw.RoundedBoxEx( 8, 0, 0, w, self.headerHeight, BOTCHED.FUNC.GetTheme( 2 ), true, true, false, false )

    draw.SimpleText( (self.header or ""), "MontserratMedium25", 10, (self.headerHeight or 40)/2-2, BOTCHED.FUNC.GetTheme( 4 ), 0, TEXT_ALIGN_CENTER )
end

vgui.Register( "botched_mainmenu", PANEL, "DPanel" )