local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel()
    self.scrollPanel = vgui.Create( "botched_scrollpanel", self )
    self.scrollPanel:Dock( FILL )
    self.scrollPanel:DockMargin( 25, 25, 25, 25 )
    self.scrollPanel.screenX, self.scrollPanel.screenY = 0, 0
    self.scrollPanel.Paint = function( self2, w, h )
        self.scrollPanel.screenX, self.scrollPanel.screenY = self2:LocalToScreen( 0, 0 )
    end

    self.slotSize = BOTCHED.FUNC.ScreenScale( 200 )

    timer.Simple( 0, function() self:Refresh() end )
end

function PANEL:Refresh()
    self.scrollPanel:Clear()

    for k, v in pairs( BOTCHED.CONFIG.Themes ) do
        local backPanel = vgui.Create( "DPanel", self.scrollPanel )
        backPanel:Dock( TOP )
        backPanel:SetTall( self.slotSize*1.2 )
        backPanel:DockMargin( 0, 0, 0, 25 )
        backPanel.Paint = function() end

        local modelPanel = vgui.Create( "botched_equipment_slot", backPanel )
        modelPanel:SetSize( self.slotSize, self.slotSize*1.2 )
        modelPanel:SetItemInfo( k, "models/player/sophie-bear/hoodmiku/hoodmiku.mdl", 3, 1, function()

        end, true )
        modelPanel:SetShadowScissor( 0, self.scrollPanel.screenY, ScrW(), self.scrollPanel.screenY+self:GetTall()-50 )
        modelPanel:SetBorder( { v } )

        local colorMixer = vgui.Create("DColorMixer", backPanel)
        colorMixer:SetPos( self.slotSize+50, 0 )
        colorMixer:SetSize( BOTCHED.FUNC.ScreenScale( 200 ), self.slotSize*1.2 )
        colorMixer:SetPalette( false )
        colorMixer:SetAlphaBar( false )
        colorMixer:SetWangs( true )
        colorMixer:SetColor( v )
        colorMixer.ValueChanged = function( self2, color )
            modelPanel:SetBorder( { color } )
        end
    end
end

function PANEL:Paint( w, h )

end

vgui.Register( "botched_adminmenu_themes", PANEL, "DPanel" )