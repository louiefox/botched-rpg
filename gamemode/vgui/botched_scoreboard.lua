local PANEL = {}

function PANEL:Init()
    self:SetSize( ScrW(), ScrH() )
    self:SetPos( 0, 0 )

    self.mainPanel = vgui.Create( "DPanel", self )
    self.mainPanel:SetSize( ScrW()*0.4, 0 )
    self.mainPanel:Center()
    self.mainPanel.Paint = function( self2, w, h )
        BSHADOWS.BeginShadow( "scoreboard" )
        BSHADOWS.SetShadowSize( "scoreboard", w, h )
        local x, y = self2:LocalToScreen( 0, 0 )
        draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 1 ) )			
        BSHADOWS.EndShadow( "scoreboard", x, y, 1, 2, 2, 255, 0, 0, false )
    end
    self.mainPanel.OnSizeChanged = function( self2 )
        self2:Center()
    end
    self.mainPanel.targetH = 0
    self.mainPanel:SetAlpha( 0 )
    self.mainPanel:AlphaTo( 255, 0.2 )
    self.mainPanel:SizeTo( self.mainPanel:GetWide(), ScrH()*0.65, 0.2, 0, -1, function()
        self.mainPanel:Center()
    end )

    local headerBack = vgui.Create( "DPanel", self.mainPanel )
	headerBack:Dock( TOP )
	headerBack:SetTall( 50 )
	headerBack.Paint = function( self2, w, h )
        draw.RoundedBoxEx( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2 ), true, true )
        
        draw.SimpleText( "Botched RPG", "MontserratMedium25", w/2, h/2, BOTCHED.FUNC.GetTheme( 4 ), 1, 1 )
    end
    
    local fieldHeaderPanel = vgui.Create( "DPanel", self.mainPanel )
	fieldHeaderPanel:Dock( TOP )
	fieldHeaderPanel:DockPadding( 25, 0, 25, 0 )
	fieldHeaderPanel:SetTall( 45 )
	fieldHeaderPanel.Paint = function( self2, w, h )
        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 2, 100 ) )
        surface.DrawRect( 0, 0, w, h )
    end

    self.playerFields = {}
    self.playerFields[1] = {
        Header = "Name",
        GetText = function( ply )
            return ply:Nick() or "Disconnected"
        end
    }
    self.playerFields[2] = {
        Header = "Level",
        GetText = function( ply )
            return "Level " .. ply:GetLevel()
        end,
        Color = BOTCHED.FUNC.GetTheme( 3 )
    }
    self.playerFields[3] = {
        Header = "Ping",
        GetText = function( ply )
            return ply:Ping()
        end
    }
    
    for k, v in ipairs( self.playerFields ) do
        local fieldEntry = vgui.Create( "DButton", fieldHeaderPanel )
        fieldEntry:Dock( LEFT )
        fieldEntry:DockMargin( 0, 5, 0, 5 )
        fieldEntry:SetWide( (self.mainPanel:GetWide()-50)/#self.playerFields )
        fieldEntry:SetText( "" )
        local alpha = 0
        fieldEntry.Paint = function( self2, w, h )
            if( self2:IsHovered() ) then
                alpha = math.Clamp( alpha+10, 0, 150 )
            else
                alpha = math.Clamp( alpha-10, 0, 150 )
            end
            
            draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 1, alpha ) )

            BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 1 ), 8 )

            draw.SimpleText( v.Header, "MontserratMedium20", w/2, h/2, BOTCHED.FUNC.GetTheme( 4 ), 1, 1 )
        end
        fieldEntry.DoClick = function()

        end
    end

    self.scrollPanel = vgui.Create( "DScrollPanel", self.mainPanel )
    self.scrollPanel:Dock( FILL )
    self.scrollPanel:DockMargin( 25, 25, 25, 25 )

    self:Refresh()
end

function PANEL:Close()
    self.mainPanel:AlphaTo( 0, 0.2 )
    self.mainPanel:SizeTo( self.mainPanel:GetWide(), 0, 0.2, 0, -1, function()
        self:Remove()
    end )
end

function PANEL:Refresh()
    self.scrollPanel:Clear()

    for k, v in ipairs( player.GetAll() ) do
        self:AddPlayer( v )
    end
end

function PANEL:AddPlayer( ply )
    local playerBackH = 45

	local playerBack = vgui.Create( "DButton", self.scrollPanel )
	playerBack:Dock( TOP )
	playerBack:DockMargin( 0, 0, 0, 10 )
	playerBack:SetTall( playerBackH )
	playerBack:SetText( "" )
	local alpha = 0
	playerBack.Paint = function( self2, w, h )
		if( self2:IsHovered() ) then
			alpha = math.Clamp( alpha+20, 0, 255 )
		else
			alpha = math.Clamp( alpha-20, 0, 255 )
        end
        
        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ) )
		draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, alpha ) )
	end
    playerBack.DoClick = function()

    end

    local avatarIcon = vgui.Create( "botched_avatar", playerBack )
    avatarIcon:SetPos( 5, 5 )
    avatarIcon:SetSize( playerBackH-10, playerBackH-10 )
    avatarIcon:SetPlayer( ply, 64 )
    avatarIcon:SetRounded( 8 )

    for k, v in ipairs( self.playerFields ) do
        local fieldEntry = vgui.Create( "DPanel", playerBack )
        fieldEntry:Dock( LEFT )
        fieldEntry:SetWide( (self.mainPanel:GetWide()-50)/#self.playerFields )
        fieldEntry.Paint = function( self2, w, h )
            if( not IsValid( ply ) ) then return end
            draw.SimpleText( v.GetText( ply ), "MontserratMedium20", w/2, h/2, v.Color or BOTCHED.FUNC.GetTheme( 4 ), 1, 1 )
        end
    end
end

function PANEL:Paint( w, h )
    
end

vgui.Register( "botched_scoreboard", PANEL, "DPanel" )