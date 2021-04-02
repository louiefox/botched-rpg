local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel()
    self.rightPanel = vgui.Create( "DPanel", self )
    self.rightPanel:Dock( RIGHT )
    self.rightPanel:SetSize( self:GetWide()*0.4, self:GetTall() )
    self.rightPanel.Paint = function( self2, w, h )
        if( BOTCHED_MAINMENU.FullyOpened ) then
            local x, y = self2:LocalToScreen( 0, 0 )

            BSHADOWS.BeginShadow( "inventory_sidepanel", 0, y, ScrW(), y+h )
            BSHADOWS.SetShadowSize( "inventory_sidepanel", w, h-4 )
            surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 1 ) )
            surface.DrawRect( x, y, w, h )
            BSHADOWS.EndShadow( "inventory_sidepanel", x, y, 1, 2, 2, 255, 0, 0, true )
        end

        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 1 ) )
        surface.DrawRect( 0, 0, w, h )

        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 2, 35 ) )
        surface.DrawRect( 0, 0, w, h )
    end

    self.scrollPanel = vgui.Create( "botched_scrollpanel", self )
    self.scrollPanel:Dock( FILL )
    self.scrollPanel:DockMargin( 25, 25, 25, 25 )
    self.scrollPanel.screenX, self.scrollPanel.screenY = 0, 0
    self.scrollPanel.Paint = function( self2, w, h )
        self.scrollPanel.screenX, self.scrollPanel.screenY = self2:LocalToScreen( 0, 0 )
    end

    local gridWide = self:GetWide()-self.rightPanel:GetWide()-70
    local slotsWide = math.floor( gridWide/BOTCHED.FUNC.ScreenScale( 150 ) )
    local spacing = 10
    self.slotSize = (gridWide-((slotsWide-1)*spacing))/slotsWide

    self.grid = vgui.Create( "DIconLayout", self.scrollPanel )
    self.grid:Dock( TOP )
    self.grid:SetSpaceY( spacing )
    self.grid:SetSpaceX( spacing )

    timer.Simple( 0, function() self:Refresh() end )

    hook.Add( "Botched.Hooks.InventoryUpdated", self, self.Refresh )
end

function PANEL:SetDisplayItem( itemKey, amount )
    local configItem = BOTCHED.CONFIG.Items[itemKey]

    if( not configItem ) then return end

    self.displayItemKey = itemKey
    self.rightPanel:Clear()

    local infoTop = vgui.Create( "DPanel", self.rightPanel )
    infoTop:Dock( TOP )
    infoTop:SetTall( 75 )
    infoTop.Paint = function( self2, w, h )
        draw.SimpleText( configItem.Name, "MontserratBold40", w/2, h/2, BOTCHED.FUNC.GetTheme( 3 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

        local sectionWide = 12
        local sections = math.floor( ((w-50)/sectionWide)/2 )
        sectionWide = (w-50)/((sections*2)-1)

        for i = 1, sections do
            surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 2 ) )
            surface.DrawRect( 25+((i-1)*(2*sectionWide)), h-2, sectionWide, 2 )
        end
    end

    local itemPanel = vgui.Create( "botched_item_slot", self.rightPanel )
    itemPanel:SetSize( BOTCHED.FUNC.ScreenScale( 175 ), BOTCHED.FUNC.ScreenScale( 175 )*1.2 )
    itemPanel:SetPos( 25, infoTop:GetTall()+25 )
    itemPanel:SetItemInfo( configItem.Name .. "_selected", configItem.Model, amount, configItem.Stars )
    itemPanel:DisableText( true )
    itemPanel:SetShadowDisable( function() return not BOTCHED_MAINMENU.FullyOpened end )
    if( configItem.Border ) then itemPanel:SetBorder( configItem.Border ) end
    if( configItem.ModelColor ) then itemPanel:SetModelColor( configItem.ModelColor ) end

    surface.SetFont( "MontserratBold20" )
    local textX, textY = surface.GetTextSize( "ITEM INFO" )
    textX, textY = textX+15, textY+10

    local itemPanelInfo = vgui.Create( "DPanel", self.rightPanel )
    itemPanelInfo:Dock( TOP )
    itemPanelInfo:DockMargin( 25+itemPanel:GetWide()+25, 25, 25, 0 )
    itemPanelInfo:SetTall( itemPanel:GetTall() )
    itemPanelInfo.Paint = function( self2, w, h )
        draw.RoundedBox( 8, 0, 0, textX, textY, BOTCHED.FUNC.GetTheme( 2 ) )
        draw.SimpleText( "ITEM INFO", "MontserratBold20", textX/2, textY/2-1, BOTCHED.FUNC.GetTheme( 3 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

        local text = BOTCHED.FUNC.TextWrap( (configItem.Description or "Some random item that has no description because it hasn't been added yet."), "MontserratMedium20", w )
        BOTCHED.FUNC.DrawNonParsedText( text, "MontserratMedium20", 0, textY+5, BOTCHED.FUNC.GetTheme( 4 ) )
    end
end

function PANEL:Refresh()
    self.grid:Clear()

    local sortedInventory = {}
    for k, v in pairs( LocalPlayer():GetInventory() ) do
        local configItem = BOTCHED.CONFIG.Items[k]

        if( not configItem ) then continue end

        table.insert( sortedInventory, { ((configItem.Stars or 0)*10)+((configItem.Border or {}).Order or 0), configItem, k, v } )
    end

    table.SortByMember( sortedInventory, 1 )

    for k, v in pairs( sortedInventory ) do
        local configItem, itemKey, amount = v[2], v[3], v[4]

        if( not self.displayItemKey ) then
            self:SetDisplayItem( itemKey, amount )
        end

        local itemPanel = self.grid:Add( "botched_item_slot" )
        itemPanel:SetSize( self.slotSize, self.slotSize*1.2 )
        itemPanel:SetItemInfo( configItem.Name, configItem.Model, amount, configItem.Stars, function()
            self:SetDisplayItem( itemKey, amount )
        end )
        if( configItem.Border ) then itemPanel:SetBorder( configItem.Border ) end
        if( configItem.ModelColor ) then itemPanel:SetModelColor( configItem.ModelColor ) end
        itemPanel:SetShadowScissor( 0, self.scrollPanel.screenY, ScrW(), self.scrollPanel.screenY+self:GetTall()-50 )
    end
end

function PANEL:Paint( w, h )

end

vgui.Register( "botched_mainmenu_inventory", PANEL, "DPanel" )