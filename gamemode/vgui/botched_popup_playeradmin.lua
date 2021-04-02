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
        BSHADOWS.BeginShadow( "popup_playeradmin" )
        BSHADOWS.SetShadowSize( "popup_playeradmin", w, h )
        local x, y = self2:LocalToScreen( 0, 0 )
        draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 1 ) )			
        BSHADOWS.EndShadow( "popup_playeradmin", x, y, 1, 2, 2, 255, 0, 0, false )
    end
    self.mainPanel.OnSizeChanged = function( self2 )
        self2:Center()
    end

    self.header = vgui.Create( "DPanel", self.mainPanel )
    self.header:Dock( TOP )
    self.header:DockMargin( 0, 25, 0, 25 )
    self.header:SetTall( 35 )
    self.header.Paint = function( self2, w, h )
        draw.SimpleText( "ADMIN - PLAYER", "MontserratBold30", w/2, h/2-1, BOTCHED.FUNC.GetTheme( 3 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
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

function PANEL:SetSteamID64( steamID64 )
    local ply = player.GetBySteamID64( steamID64 )

    local actions = {
        ["setstamina"] = {
            Name = "Set Stamina",
            DoClick = function()
                BOTCHED.FUNC.DermaNumberRequest( "How much stamina would you like to set them to?", "SET STAMINA", 0, "Set", function( num )
                    RunConsoleCommand( "botched_admincmd", "setstamina", steamID64, num )
                end )
            end
        },
        ["setlevel"] = {
            Name = "Set Level",
            DoClick = function()
                BOTCHED.FUNC.DermaNumberRequest( "What level would you like to set them to?", "SET LEVEL", 0, "Set", function( num )
                    RunConsoleCommand( "botched_admincmd", "setlevel", steamID64, num )
                end )
            end
        },
        ["setgems"] = {
            Name = "Set Gems",
            DoClick = function()
                BOTCHED.FUNC.DermaNumberRequest( "What would you like to set their gems to?", "SET GEMS", 0, "Set", function( num )
                    RunConsoleCommand( "botched_admincmd", "setgems", steamID64, num )
                end )
            end
        },
        ["setmana"] = {
            Name = "Set Mana",
            DoClick = function()
                BOTCHED.FUNC.DermaNumberRequest( "What would you like to set their mana to?", "SET MANA", 0, "Set", function( num )
                    RunConsoleCommand( "botched_admincmd", "setmana", steamID64, num )
                end )
            end
        },
        ["giveitems"] = {
            Name = "Give Items",
            DoClick = function()
                local options = {}
                for k, v in pairs( BOTCHED.CONFIG.Items ) do
                    options[k] = v.Name
                end

                BOTCHED.FUNC.DermaComboRequest( "What item would you like to give?", "GIVE ITEMS", options, "", false, "Continue", function( value, key )
                    BOTCHED.FUNC.DermaNumberRequest( "How many would you like to give?", "GIVE ITEMS", 1, "Give", function( num )
                        RunConsoleCommand( "botched_admincmd", "giveitem", steamID64, key, num )
                    end )
                end )
            end
        },
        ["giveplayermodel"] = {
            Name = "Give Playermodel",
            DoClick = function()
                local options = {}
                for k, v in pairs( BOTCHED.CONFIG.Characters ) do
                    options[k] = v.Name
                end

                BOTCHED.FUNC.DermaComboRequest( "What playermodel would you like to give?", "GIVE PLAYERMODEL", options, "", false, "Give", function( value, key )
                    RunConsoleCommand( "botched_admincmd", "giveplayermodel", steamID64, key )
                end )
            end
        }
    }

    for k, v in pairs( actions ) do
        local actionButton = vgui.Create( "DButton", self.mainPanel )
        actionButton:Dock( TOP )
        actionButton:DockMargin( 10, 0, 10, 10 )
        actionButton:SetTall( 40 )
        actionButton:SetText( "" )
        local alpha = 0
        actionButton.Paint = function( self2, w, h )
            if( self2:IsHovered() ) then
                alpha = math.Clamp( alpha+5, 0, 75 )
            else
                alpha = math.Clamp( alpha-5, 0, 75 )
            end
            
            draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ) )
            draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 3, alpha ) )

            draw.SimpleText( v.Name, "MontserratBold25", w/2, h/2-1, BOTCHED.FUNC.GetTheme( 4, 75+(180*(alpha/75)) ), 1, 1 )
        end
        actionButton.DoClick = function()
            v.DoClick()
        end
    end

    self.mainPanel.targetH = self.header:GetTall()+50+(table.Count( actions )*50)
    self.mainPanel:SizeTo( self.mainPanel:GetWide(), self.mainPanel.targetH, 0.2 )
end

function PANEL:Paint( w, h )
    BOTCHED.FUNC.DrawBlur( self, 4, 4 )
end

vgui.Register( "botched_popup_playeradmin", PANEL, "DFrame" )