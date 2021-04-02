local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel()
    self.searchBar = vgui.Create( "botched_searchbar", self )
    self.searchBar:Dock( TOP )
    self.searchBar:SetTall( 40 )
    self.searchBar:DockMargin( 25, 25, 25, 0 )
    self.searchBar.OnChange = function()
        self:Refresh()
    end

    self.scrollPanel = vgui.Create( "botched_scrollpanel", self )
    self.scrollPanel:Dock( FILL )
    self.scrollPanel:DockMargin( 25, 10, 25, 25 )
    self.scrollPanel.screenX, self.scrollPanel.screenY = 0, 0
    self.scrollPanel.Paint = function( self2, w, h )
        self.scrollPanel.screenX, self.scrollPanel.screenY = self2:LocalToScreen( 0, 0 )
    end

    local gridWide = self:GetWide()-70
    local slotsWide = math.floor( gridWide/BOTCHED.FUNC.ScreenScale( 250 ) )
    local spacing = 10
    self.slotSize = (gridWide-((slotsWide-1)*spacing))/slotsWide

    self.grid = vgui.Create( "DIconLayout", self.scrollPanel )
    self.grid:Dock( TOP )
    self.grid:SetSpaceY( spacing )
    self.grid:SetSpaceX( spacing )

    timer.Simple( 0, function() self:Refresh() end )
end

function PANEL:Refresh()
    self.grid:Clear()

    local searchText = self.searchBar:GetValue()
    for k, v in pairs( player.GetAll() ) do
        if( searchText != "" and not string.find( string.lower( v:Nick() ), string.lower( searchText ) ) ) then continue end

        local borderSize = 2
        local playerBack = self.grid:Add( "DPanel" )
        playerBack:SetSize( self.slotSize, 75 )
        local alpha = 0
        playerBack.Paint = function( self2, w, h )
            local uniqueID = "admin_ply_" .. v:Nick()
            BSHADOWS.BeginShadow( uniqueID )
            BSHADOWS.SetShadowSize( uniqueID, w, h )
            local x, y = self2:LocalToScreen( 0, 0 )
            draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 2 ) )		
            BSHADOWS.EndShadow( uniqueID, x, y, 1, 1, 2, 255, 0, 0, false )

            draw.RoundedBox( 8, borderSize, borderSize, w-(2*borderSize), h-(2*borderSize), BOTCHED.FUNC.GetTheme( 1 ) )
            
            if( IsValid( playerBack.button ) ) then
                if( playerBack.button:IsHovered() ) then
                    alpha = math.Clamp( alpha+10, 0, 50 )
                else
                    alpha = math.Clamp( alpha-10, 0, 50 )
                end
        
                draw.RoundedBox( 8, borderSize, borderSize, w-(2*borderSize), h-(2*borderSize), BOTCHED.FUNC.GetTheme( 2, alpha ) )
                BOTCHED.FUNC.DrawClickCircle( playerBack.button, w-(2*borderSize), h-(2*borderSize), BOTCHED.FUNC.GetTheme( 2, 150 ), 8 )
            end

            local iconSize = h-10
            draw.SimpleText( v:Nick(), "MontserratMedium23", iconSize+(w-iconSize)/2, h/2+2, BOTCHED.FUNC.GetTheme( 3 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
            draw.SimpleText( v:SteamID(), "MontserratMedium17", iconSize+(w-iconSize)/2, h/2-2, BOTCHED.FUNC.GetTheme( 4, 75 ), TEXT_ALIGN_CENTER, 0 )
        end

        local avatarIcon = vgui.Create( "botched_avatar", playerBack )
        avatarIcon:SetPos( 5, 5 )
        avatarIcon:SetSize( playerBack:GetTall()-10, playerBack:GetTall()-10 )
        avatarIcon:SetPlayer( v, 64 )
        avatarIcon:SetRounded( 8 )

        playerBack.button = vgui.Create( "DButton", playerBack )
        playerBack.button:Dock( FILL )
        playerBack.button:SetText( "" )
        playerBack.button.Paint = function() end
        playerBack.button.DoClick = function()
            self.popupPanel = vgui.Create( "botched_popup_playeradmin" )
            self.popupPanel:SetSteamID64( v:SteamID64() )
        end
    end
end

function PANEL:Paint( w, h )

end

vgui.Register( "botched_adminmenu_players", PANEL, "DPanel" )