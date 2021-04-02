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
    local slotsWide = math.floor( gridWide/BOTCHED.FUNC.ScreenScale( 175 ) )
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
    for k, v in pairs( player_manager.AllValidModels() ) do
        if( searchText != "" and not string.find( string.lower( k ), string.lower( searchText ) ) ) then continue end

        local modelPanel = self.grid:Add( "botched_equipment_slot" )
        modelPanel:SetSize( self.slotSize, self.slotSize*1.2 )
        modelPanel:SetItemInfo( k, v, false, false, function()
            SetClipboardText( v )
            notification.AddLegacy( "Copied model path.", 0, 3 )
        end, true )
        modelPanel:SetShadowScissor( 0, self.scrollPanel.screenY, ScrW(), self.scrollPanel.screenY+self:GetTall()-100 )
    end
end

function PANEL:Paint( w, h )

end

vgui.Register( "botched_adminmenu_playermodels", PANEL, "DPanel" )