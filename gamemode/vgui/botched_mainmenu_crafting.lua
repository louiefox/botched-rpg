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

            BSHADOWS.BeginShadow( "crafting_sidepanel", 0, y, ScrW(), y+h )
            BSHADOWS.SetShadowSize( "crafting_sidepanel", w, h-4 )
            surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 1 ) )
            surface.DrawRect( x, y, w, h )
            BSHADOWS.EndShadow( "crafting_sidepanel", x, y, 1, 2, 2, 255, 0, 0, true )
        end

        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 1 ) )
        surface.DrawRect( 0, 0, w, h )

        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 2, 35 ) )
        surface.DrawRect( 0, 0, w, h )
    end

    self.navigationPanel = vgui.Create( "DPanel", self )
    self.navigationPanel:Dock( TOP )
    self.navigationPanel:SetSize( self:GetWide()-self.rightPanel:GetWide(), 50 )
    self.navigationPanel.Paint = function( self, w, h ) 
        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 2, 100 ) )
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

    self:RefreshCategories()
    timer.Simple( 0, function() self:RefreshItems() end )

    hook.Add( "Botched.Hooks.InventoryUpdated", self, self.Refresh )
    hook.Add( "Botched.Hooks.EquipmentUpdated", self, self.Refresh )
    hook.Add( "Botched.Hooks.ManaChanged", self, self.Refresh )
end

function PANEL:AddPage( title, func )
    local pageButton = vgui.Create( "DButton", self.navigationPanel )
    pageButton:Dock( LEFT )
    pageButton:SetText( "" )
    local alpha = 0
    pageButton.Paint = function( self2, w, h )
        if( self.activeCategory == title ) then
            alpha = math.Clamp( alpha+10, 0, 255 )
        elseif( self2:IsHovered() ) then
            alpha = math.Clamp( alpha+10, 0, 150 )
        else
            alpha = math.Clamp( alpha-10, 0, 255 )
        end

        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 2, 100*(alpha/255) ) )
        surface.DrawRect( 0, 0, w, h )

        BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 2 ) )

        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 3, alpha ) )
        surface.DrawRect( 0, h-5, w, 5 )

        draw.SimpleText( title, "MontserratMedium20", w/2, h/2, BOTCHED.FUNC.GetTheme( 4, 75+(180*(alpha/150)) ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
    pageButton.DoClick = func

    local children = self.navigationPanel:GetChildren()
    for k, v in ipairs( children ) do
        if( k == #children ) then
            v:SetWide( self.navigationPanel:GetWide()-((#children-1)*math.floor( self.navigationPanel:GetWide()/#children )) )
        else
            v:SetWide( math.floor( self.navigationPanel:GetWide()/#children ) )
        end
    end
end

function PANEL:SetDisplayItem( itemKey )
    self.displayItemKey = itemKey
    self.rightPanel:Clear()

    local configItem = BOTCHED.CONFIG.Crafting[itemKey]
    if( not configItem ) then return end

    local itemInfo = configItem.ItemInfo or {}
    local stars = itemInfo.Stars or 0
    local border = itemInfo.Border or (((stars >= 3 and BOTCHED.CONFIG.Borders.Gold) or (stars == 2 and BOTCHED.CONFIG.Borders.Silver)) or BOTCHED.CONFIG.Borders.Bronze)

    local disableCraft, errorMsg
    if( configItem.Reward and configItem.Reward.Equipment ) then
        local equipment = LocalPlayer():GetEquipment()
        for k, v in ipairs( configItem.Reward.Equipment ) do
            if( equipment[v] ) then
                disableCraft, errorMsg = true, "Equipment already owned!"
                break
            end
        end
    end

    self.maxCraftAmount = ((disableCraft and 0) or ((configItem.Reward and configItem.Reward.Equipment) and 1)) or 9999

    local costTable = configItem.Cost
    if( costTable.Gems ) then
        self.maxCraftAmount = math.min( self.maxCraftAmount, math.floor( LocalPlayer():GetGems()/costTable.Gems ) )
    end

    if( costTable.Mana ) then
        self.maxCraftAmount = math.min( self.maxCraftAmount, math.floor( LocalPlayer():GetMana()/costTable.Mana ) )
    end

    for k, v in pairs( costTable.Items or {} ) do
        local itemConfig = BOTCHED.CONFIG.Items[k]
        if( not itemConfig ) then continue end

        self.maxCraftAmount = math.min( self.maxCraftAmount, math.floor( (LocalPlayer():GetInventory()[k] or 0)/v ) )
    end

    self.craftAmount = math.min( (disableCraft and 0 or 1), self.maxCraftAmount )

    local infoTop = vgui.Create( "DPanel", self.rightPanel )
    infoTop:Dock( TOP )
    infoTop:SetTall( 75 )
    infoTop.Paint = function( self2, w, h )
        draw.SimpleText( (configItem.Name or itemInfo.Name), "MontserratBold40", w/2, h/2, BOTCHED.FUNC.GetTheme( 3 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

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
    itemPanel:SetItemInfo( itemKey .. "_selected", (configItem.Model or itemInfo.Model), (configItem.Amount or 1), itemInfo.Stars or 0 )
    itemPanel:DisableText( true )
    itemPanel:SetShadowDisable( function() return not BOTCHED_MAINMENU.FullyOpened end )
    if( border ) then itemPanel:SetBorder( border ) end

    surface.SetFont( "MontserratBold20" )
    local textX, textY = surface.GetTextSize( "ITEM INFO" )
    textX, textY = textX+15, textY+10

    local itemPanelInfo = vgui.Create( "DPanel", self.rightPanel )
    itemPanelInfo:Dock( TOP )
    itemPanelInfo:DockMargin( 25+itemPanel:GetWide()+25, 25, 25, 25 )
    itemPanelInfo:DockPadding( 0, textY+5, 0, 0 )
    itemPanelInfo:SetTall( itemPanel:GetTall() )
    itemPanelInfo.Paint = function( self2, w, h )
        draw.RoundedBox( 8, 0, 0, textX, textY, BOTCHED.FUNC.GetTheme( 2 ) )
        draw.SimpleText( "ITEM INFO", "MontserratBold20", textX/2, textY/2-1, BOTCHED.FUNC.GetTheme( 3 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

        if( configItem.Description or itemInfo.Description ) then
            local text = BOTCHED.FUNC.TextWrap( configItem.Description or itemInfo.Description, "MontserratMedium20", w )
            BOTCHED.FUNC.DrawNonParsedText( text, "MontserratMedium20", 0, textY+5, BOTCHED.FUNC.GetTheme( 4 ) )
        end
    end

    if( itemInfo.Stats ) then
        local starConfig = BOTCHED.CONFIG.EquipmentStars[itemInfo.Stars or 1]
        for k, v in pairs( itemInfo.Stats ) do
            local devConfigTable = BOTCHED.DEVCONFIG.EquipmentStats[k]

            local text = math.Round( v+(v*(starConfig.StatMultiplier or 0)), 2 )
            surface.SetFont( "MontserratBold22" )
            local textX, textY = surface.GetTextSize( text )
    
            local statEntry = vgui.Create( "DPanel", itemPanelInfo )
            statEntry:Dock( TOP )
            statEntry:SetTall( textY )
            statEntry.Paint = function( self2, w, h )
                draw.SimpleText( devConfigTable.Name, "MontserratMedium20", 0, h/2, BOTCHED.FUNC.GetTheme( 4, 100 ), 0, TEXT_ALIGN_CENTER )
    
                draw.SimpleText( text, "MontserratBold22", w/2, h/2, BOTCHED.FUNC.GetTheme( 3 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            end
        end
    end

    local itemEntries = {}
    local function AddItemEntry( ownedAmount, neededAmount, name, model )
        local itemSlot = vgui.Create( "botched_item_slotbar", self.rightPanel )
        itemSlot:Dock( TOP )
        itemSlot:DockMargin( 25, 0, 25, 10 )
        itemSlot:SetItemInfo( ownedAmount, neededAmount, name, model )

        table.insert( itemEntries, itemSlot )
    end

    local function RefreshCraftAmount()
        for k, v in ipairs( itemEntries ) do
            v:Remove()
        end

        local multiplier = math.max( 1, self.craftAmount )

        if( costTable.Gems ) then
            AddItemEntry( LocalPlayer():GetGems(), costTable.Gems*multiplier, "Gems", "materials/botched/icons/gems.png" )
        end

        if( costTable.Mana ) then
            AddItemEntry( LocalPlayer():GetMana(), costTable.Mana*multiplier, "Mana", "materials/botched/icons/mana.png" )
        end

        for k, v in pairs( costTable.Items or {} ) do
            local itemConfig = BOTCHED.CONFIG.Items[k]
            if( not itemConfig ) then continue end

            AddItemEntry( LocalPlayer():GetInventory()[k] or 0, v*multiplier, itemConfig.Name, itemConfig.Model )
        end
    end
    RefreshCraftAmount()

    local bottomButton = vgui.Create( "DButton", self.rightPanel )
    bottomButton:Dock( BOTTOM )
    bottomButton:DockMargin( 25, 0, 25, 25 )
    bottomButton:SetTall( 50 )
    bottomButton:SetText( "" )
    local alpha = 0
    bottomButton.Paint = function( self2, w, h )
        if( self2:IsHovered() ) then
            alpha = math.Clamp( alpha+10, 0, 150 )
        else
            alpha = math.Clamp( alpha-10, 0, 255 )
        end

        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ) )
        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100*(alpha/255) ) )

        BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 2 ), 8 )

        BOTCHED.FUNC.DrawPartialRoundedBox( 8, 0, h-5, w, 5, BOTCHED.FUNC.GetTheme( 3, alpha ), false, 16, false, h-5-11 )

        draw.SimpleText( "CRAFT", "MontserratMedium20", w/2, h/2, BOTCHED.FUNC.GetTheme( 4, 75+(180*(alpha/150)) ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
    bottomButton.DoClick = function()
        if( self.craftAmount < 1 ) then return end

        net.Start( "Botched.RequestCraftItem" )
            net.WriteString( itemKey )
            net.WriteUInt( self.craftAmount, 16 )
        net.SendToServer()
    end

    local amountPanel = vgui.Create( "DPanel", self.rightPanel )
    amountPanel:Dock( BOTTOM )
    amountPanel:DockMargin( 25, 0, 25, 10 )
    amountPanel:SetTall( 40 )
    amountPanel.Paint = function( self2, w, h )
        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ) )
    end

    if( disableCraft ) then
        local errorPanel = vgui.Create( "DPanel", self.rightPanel )
        errorPanel:Dock( BOTTOM )
        errorPanel:DockMargin( 25, 0, 25, 10 )
        errorPanel:SetTall( 30 )
        errorPanel.Paint = function( self2, w, h )
            draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.CONFIG.Themes.DarkRed )

            draw.SimpleText( string.upper( errorMsg ), "MontserratBold20", w/2, h/2-1, BOTCHED.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
    end

    local function IncreaseAmount( amount )
        self.craftAmount = math.Clamp( (self.craftAmount or 1)+amount, 1, self.maxCraftAmount )
        RefreshCraftAmount()
    end

    local decreaseButton = vgui.Create( "DButton", amountPanel )
	decreaseButton:Dock( LEFT )
	decreaseButton:SetWide( amountPanel:GetTall() )
	decreaseButton:SetText( "" )
	local alpha = 0
	decreaseButton.Paint = function( self2, w, h )
		if( self2:IsHovered() ) then
			alpha = math.Clamp( alpha+5, 0, 75 )
		else
			alpha = math.Clamp( alpha-5, 0, 75 )
        end
        
        draw.RoundedBoxEx( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ), true, false, true, false )
		draw.RoundedBoxEx( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 3, alpha ), true, false, true, false )

        BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 3 ), 8 )

		draw.SimpleText( "-", "MontserratBold40", w/2, h/2-3, BOTCHED.FUNC.GetTheme( 4, 75+(180*(alpha/75)) ), 1, 1 )
	end
    decreaseButton.DownFunc = function()
        if( timer.Exists( "BOTCHED.Timer.CraftingDecrease." .. tostring( decreaseButton ) ) ) then return end

        timer.Create( "BOTCHED.Timer.CraftingDecrease." .. tostring( decreaseButton ), 0.1, 1, function()
            if( decreaseButton:IsDown() ) then
                IncreaseAmount( -1 )
                timer.Simple( 0, function() decreaseButton.DownFunc() end )
            end
        end )
    end
    decreaseButton.OnDepressed = function( self2 )
        IncreaseAmount( -1 )
        decreaseButton.DownFunc()
    end

    surface.SetFont( "MontserratBold25" )
    local maxX, maxY = surface.GetTextSize( "MAX" )

    local maxButton = vgui.Create( "DButton", amountPanel )
	maxButton:Dock( RIGHT )
	maxButton:SetWide( maxX+20 )
	maxButton:SetText( "" )
	local alpha = 0
	maxButton.Paint = function( self2, w, h )
		if( self2:IsHovered() ) then
			alpha = math.Clamp( alpha+5, 0, 75 )
		else
			alpha = math.Clamp( alpha-5, 0, 75 )
        end
        
        draw.RoundedBoxEx( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2 ), false, true, false, true )
		draw.RoundedBoxEx( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 3, alpha ), false, true, false, true )

        BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 3 ), 8 )

		draw.SimpleText( "MAX", "MontserratBold25", w/2, h/2-1, BOTCHED.FUNC.GetTheme( 4, 75+(180*(alpha/75)) ), 1, 1 )
	end
    maxButton.DoClick = function()
        IncreaseAmount( self.maxCraftAmount )
    end

    local increaseButton = vgui.Create( "DButton", amountPanel )
	increaseButton:Dock( RIGHT )
	increaseButton:SetWide( amountPanel:GetTall() )
	increaseButton:SetText( "" )
	local alpha = 0
	increaseButton.Paint = function( self2, w, h )
		if( self2:IsHovered() ) then
			alpha = math.Clamp( alpha+5, 0, 75 )
		else
			alpha = math.Clamp( alpha-5, 0, 75 )
        end

        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 2, 100 ) )
        surface.DrawRect( 0, 0, w, h )

        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 3, alpha ) )
        surface.DrawRect( 0, 0, w, h )

        BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 3 ) )

		draw.SimpleText( "+", "MontserratBold40", w/2, h/2-1, BOTCHED.FUNC.GetTheme( 4, 75+(180*(alpha/75)) ), 1, 1 )
	end
    increaseButton.DownFunc = function()
        if( timer.Exists( "BOTCHED.Timer.CraftingIncrease." .. tostring( increaseButton ) ) ) then return end

        timer.Create( "BOTCHED.Timer.CraftingIncrease." .. tostring( increaseButton ), 0.1, 1, function()
            if( increaseButton:IsDown() ) then
                IncreaseAmount( 1 )
                timer.Simple( 0, function() increaseButton.DownFunc() end )
            end
        end )
    end
    increaseButton.OnDepressed = function( self2 )
        IncreaseAmount( 1 )
        increaseButton.DownFunc()
    end

    local amountBar = vgui.Create( "DPanel", amountPanel )
    amountBar:Dock( FILL )
    local barWLerp
    amountBar.Paint = function( self2, w, h )
        barWLerp = barWLerp and Lerp( FrameTime()*20, barWLerp, math.Clamp( w*(self.craftAmount/self.maxCraftAmount), 0, w ) ) or w*(self.craftAmount/self.maxCraftAmount)

        local barH = 5
        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 1, 100 ) )
        surface.DrawRect( 0, h-barH, w, barH )

        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 3 ) )
        surface.DrawRect( 0, h-barH, barWLerp+(self.craftAmount > 0 and 1 or 0), barH )

        draw.SimpleText( math.min( self.maxCraftAmount or 1, self.craftAmount or 1 ) .. "/" .. (self.maxCraftAmount or 1), "MontserratBold25", w/2, h/2-1, BOTCHED.FUNC.GetTheme( 4, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
end

function PANEL:RefreshCategories()
    self.navigationPanel:Clear()
    self.activeCategory = nil

    local createdCategories = {}
    for k, v in pairs( BOTCHED.CONFIG.Crafting ) do
        if( v.Category and not createdCategories[v.Category] ) then
            createdCategories[v.Category] = true

            self:AddPage( v.Category, function()
                self.activeCategory = v.Category
                self:RefreshItems()
            end )

            if( not self.activeCategory ) then
                self.activeCategory = v.Category
            end
        end
    end
end

function PANEL:RefreshItems()
    self.grid:Clear()

    local sortedCrafting = {}
    for k, v in pairs( BOTCHED.CONFIG.Crafting ) do
        if( self.activeCategory != "" and self.activeCategory != (v.Category or "") ) then continue end

        local stars = (v.ItemInfo or {}).Stars or 0
        local border = ((stars >= 3 and BOTCHED.CONFIG.Borders.Gold) or (stars == 2 and BOTCHED.CONFIG.Borders.Silver)) or BOTCHED.CONFIG.Borders.Bronze
        table.insert( sortedCrafting, { (stars*10)+(border.Order or 0), border, k } )
    end

    table.SortByMember( sortedCrafting, 1 )

    for k, v in pairs( sortedCrafting ) do
        local border, itemKey = v[2], v[3]
        local configItem = BOTCHED.CONFIG.Crafting[itemKey]
        local itemInfo = configItem.ItemInfo or {}

        if( not self.displayItemKey or (BOTCHED.CONFIG.Crafting[self.displayItemKey].Category != self.activeCategory) ) then
            self:SetDisplayItem( itemKey )
        end

        local itemPanel = self.grid:Add( "botched_item_slot" )
        itemPanel:SetSize( self.slotSize, self.slotSize*1.2 )
        itemPanel:SetItemInfo( (configItem.Name or itemInfo.Name), (configItem.Model or itemInfo.Model), (configItem.Amount or 1), (itemInfo.Stars or 0), function()
            self:SetDisplayItem( itemKey )
        end )
        itemPanel:SetBorder( itemInfo.Border or border )
        itemPanel:SetShadowScissor( 0, self.scrollPanel.screenY, ScrW(), self.scrollPanel.screenY+self:GetTall()-100 )
    end
end

function PANEL:Refresh()
    --self:RefreshItems()
    self:SetDisplayItem( self.displayItemKey )
end

function PANEL:Paint( w, h )

end

vgui.Register( "botched_mainmenu_crafting", PANEL, "DPanel" )