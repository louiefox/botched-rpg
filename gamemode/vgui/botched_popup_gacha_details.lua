local PANEL = {}

function PANEL:Init()
    self:SetHeader( "GACHA DETAILS" )
    self:SetPopupWide( ScrW()*0.4 )
    self:SetExtraHeight( ScrH()*0.4 )
    self.navWide = self:GetPopupWide()-50

    local bottomButton = vgui.Create( "DButton", self )
    bottomButton:Dock( BOTTOM )
    bottomButton:DockMargin( self:GetPopupWide()*0.3, 25, self:GetPopupWide()*0.3, 25 )
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

        draw.SimpleText( "CLOSE", "MontserratMedium20", w/2, h/2, BOTCHED.FUNC.GetTheme( 4, 75+(180*(alpha/150)) ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
    bottomButton.DoClick = function()
        self:Close()
    end

    self.centerArea = vgui.Create( "DPanel", self )
    self.centerArea:Dock( FILL )
    self.centerArea:DockMargin( 25, 0, 25, 0 )
    self.centerArea:SetSize( self:GetPopupWide()-50, self.mainPanel.targetH-self.header:GetTall()-bottomButton:GetTall()-75 )
    self.centerArea.Paint = function( self, w, h ) end 

    self.mainSection = vgui.Create( "DPanel", self.centerArea )
    self.mainSection:Dock( FILL )
    self.mainSection.Paint = function( self, w, h ) end 

    self.navigationPanel = vgui.Create( "DPanel", self.mainSection )
    self.navigationPanel:Dock( TOP )
    self.navigationPanel:SetTall( 50 )
    self.navigationPanel.Paint = function( self, w, h ) 
        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ) )
    end 

    self.navigationContent = vgui.Create( "DPanel", self.mainSection )
    self.navigationContent:Dock( FILL )
    self.navigationContent:DockMargin( 0, 25, 0, 0 )
    self.navigationContent:SetSize( self:GetPopupWide()-50, self.mainPanel.targetH-self.header:GetTall()-self.navigationPanel:GetTall()-bottomButton:GetTall()-75 )
    self.navigationContent.Paint = function() end

    self.pages = {}
end

function PANEL:SetGachaInfo( k, v )
    local gachaInfoPage = vgui.Create( "botched_scrollpanel" )
    gachaInfoPage:Dock( FILL )
    gachaInfoPage.Paint = function() end
    self:AddPage( "Gacha Info", gachaInfoPage )

    local imageMat
    BOTCHED.FUNC.GetImage( v.Image or "", function( mat ) 
        imageMat = mat
    end )

    gachaInfoPage.image = vgui.Create( "DPanel", gachaInfoPage )
    gachaInfoPage.image:Dock( TOP )
    gachaInfoPage.image:DockMargin( 0, 0, 25, 25 )
    gachaInfoPage.image:SetTall( 100 )
    gachaInfoPage.image.Paint = function( self2, w, h ) 
        if( not imageMat ) then return end
        
        local imageH = (imageMat:Height()/imageMat:Width())*w
        BOTCHED.FUNC.DrawRoundedMask( 8, 0, 0, w, h, function()
            surface.SetDrawColor( 255, 255, 255 )
            surface.SetMaterial( imageMat )
            surface.DrawTexturedRect( 0, (h/2)-(imageH/2), w, imageH )
		end )

        BSHADOWS.BeginShadow( "banner_name_popup_" .. k )
        local x, y = self2:LocalToScreen( w/2, h/2 )
        draw.SimpleText( string.upper( v.Name ), "MontserratBold50", x, y, BOTCHED.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        BSHADOWS.EndShadow( "banner_name_popup_" .. k, x, y, 1, 2, 2, 255, 0, 0, false )
    end

    local bannerText = [[
        This banner will be available for a set amount of time, it increases rates for set characters listed below.

        Characters:]]

    for key, val in ipairs( v.Characters ) do
        local characterConfig = BOTCHED.CONFIG.Characters[val]
        if( not characterConfig ) then continue end

        bannerText = bannerText .. "\n            - " .. characterConfig.Name
    end

    bannerText = bannerText .. [[


        About:
            This banner can be drawn by consuming gems earnt through playing or bought from the gem store.
            Drawn characters are all at least 1★, if draw 10 is used then the last draw is guaranteed to be at least 2★.
            If a drawn character is already owned then it will be converted to Magic Coins.
        ]]

    gachaInfoPage.text = vgui.Create( "DPanel", gachaInfoPage )
    gachaInfoPage.text:Dock( TOP )
    gachaInfoPage.text:DockMargin( 0, 0, 25, 0 )
    gachaInfoPage.text:SetTall( 250 )
    gachaInfoPage.text.Paint = function( self2, w, h ) 
        BOTCHED.FUNC.DrawNonParsedText( bannerText, "MontserratMedium20", 0, 0, BOTCHED.FUNC.GetTheme( 4 ) )
    end

    local charactersPage = vgui.Create( "botched_scrollpanel" )
    charactersPage:Dock( FILL )
    charactersPage.Paint = function() end
    self:AddPage( "Characters", charactersPage )

    local gridWide = charactersPage:GetWide()-20
    local slotsWide = math.floor( gridWide/BOTCHED.FUNC.ScreenScale( 175 ) )
    local spacing = 10
    local slotSize = (gridWide-((slotsWide-1)*spacing))/slotsWide

    charactersPage.grid = vgui.Create( "DIconLayout", charactersPage )
    charactersPage.grid:Dock( TOP )
    charactersPage.grid:SetSpaceY( spacing )
    charactersPage.grid:SetSpaceX( spacing )

    for key, val in ipairs( v.Characters ) do
        local characterConfig = BOTCHED.CONFIG.Characters[val]
        if( not characterConfig ) then continue end

        local characterPanel = charactersPage.grid:Add( "botched_equipment_slot" )
        characterPanel:SetSize( slotSize, slotSize*1.2 )
        characterPanel:SetItemInfo( characterConfig.Name, characterConfig.Model, (characterConfig.Stars or 1), false, function()

        end, true )
    end

    local drawRatesPage = vgui.Create( "botched_scrollpanel" )
    drawRatesPage:Dock( FILL )
    drawRatesPage.Paint = function() end
    self:AddPage( "Draw Rates", drawRatesPage )

    local ratesText = [[
        Character Draw Rates:]]
    
    ratesText = ratesText .. "\n            - ★★★ Character: " .. v.Chances[3].Chance .. "%"
    ratesText = ratesText .. "\n            - ★★ Character: " .. v.Chances[2].Chance .. "%"
    ratesText = ratesText .. "\n            - ★ Character: " .. v.Chances[1].Chance .. "%"

    drawRatesPage.text = vgui.Create( "DPanel", drawRatesPage )
    drawRatesPage.text:Dock( TOP )
    drawRatesPage.text:DockMargin( 0, 0, 25, 0 )
    drawRatesPage.text:SetTall( 100 )
    drawRatesPage.text.Paint = function( self2, w, h ) 
        BOTCHED.FUNC.DrawNonParsedText( ratesText, "MontserratMedium20", 0, 0, BOTCHED.FUNC.GetTheme( 4 ) )
    end

    drawRatesPage.header = vgui.Create( "DPanel", drawRatesPage )
    drawRatesPage.header:Dock( TOP )
    drawRatesPage.header:SetTall( 50 )
    drawRatesPage.header.Paint = function( self2, w, h ) 
        draw.SimpleText( "Individual Rates", "MontserratBold30", w/2, h/2, BOTCHED.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local sortedCharacters = {}
    for key, val in pairs( BOTCHED.CONFIG.Characters ) do
        if( val.DisableGacha ) then continue end
        
        if( not sortedCharacters[val.Stars] ) then
            sortedCharacters[val.Stars] = {}
        end

        table.insert( sortedCharacters[val.Stars], { key } )
    end

    for key, val in ipairs( sortedCharacters ) do
        local chanceTable = v.Chances[key]
        local normalChance, focusedChance = chanceTable.Chance/#val, chanceTable.Chance/#val
        if( chanceTable.FocusedMultiplier ) then
            normalChance = chanceTable.Chance/(#val+(#v.Characters*(chanceTable.FocusedMultiplier-1)))
            focusedChance = normalChance*chanceTable.FocusedMultiplier
        end

        for key2, val2 in ipairs( val ) do
            sortedCharacters[key][key2][2] = table.HasValue( v.Characters, val2[1] ) and focusedChance or normalChance
        end
    end

    for key, val in ipairs( table.Reverse( table.Copy( sortedCharacters ) ) ) do
        local starString = ""
        for i = 1, #sortedCharacters-(key-1) do
            starString = starString .. "★"
        end

        local rateSpacer = vgui.Create( "DPanel", drawRatesPage )
        rateSpacer:Dock( TOP )
        rateSpacer:DockMargin( 0, 5, 10, 10 )
        rateSpacer:SetTall( 4 )
        rateSpacer.Paint = function( self2, w, h ) 
            surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 2, 100 ) )
            surface.DrawRect( 0, 0, w, h )
        end

        for key2, val2 in ipairs( val ) do
            local characterConfig = BOTCHED.CONFIG.Characters[val2[1]]
            if( not characterConfig ) then continue end

            local drawRate = math.Round( val2[2], 4 )
            local isFocused = table.HasValue( v.Characters, val2[1] )
    
            local rateEntry = vgui.Create( "DPanel", drawRatesPage )
            rateEntry:Dock( TOP )
            rateEntry:DockMargin( 0, 0, 10, 5 )
            rateEntry:SetTall( 40 )
            rateEntry.Paint = function( self2, w, h ) 
                draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ) )
    
                draw.SimpleText( starString .. " " .. characterConfig.Name, "MontserratBold20", 10, h/2, BOTCHED.FUNC.GetTheme( 4 ), 0, TEXT_ALIGN_CENTER )
                draw.SimpleText( drawRate .. "%", "MontserratMedium23", w-10, h/2, BOTCHED.FUNC.GetTheme( 3 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )

                if( isFocused ) then
                    draw.SimpleText( "RATE UP", "MontserratBold20", w-(w/6), h/2, BOTCHED.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                end
            end
        end
    end
end

function PANEL:AddPage( title, panel )
    panel:SetParent( self.navigationContent )
    panel:SetSize( self.navigationContent:GetSize() )

    local pageKey = #self.pages+1

    local pageButton = vgui.Create( "DButton", self.navigationPanel )
    pageButton:Dock( LEFT )
    pageButton:SetText( "" )
    local alpha = 0
    pageButton.Paint = function( self2, w, h )
        if( self.activePage == pageKey ) then
            alpha = math.Clamp( alpha+10, 0, 255 )
        elseif( self2:IsHovered() ) then
            alpha = math.Clamp( alpha+10, 0, 150 )
        else
            alpha = math.Clamp( alpha-10, 0, 255 )
        end

        draw.RoundedBoxEx( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100*(alpha/255) ), pageKey == 1, pageKey == #self.pages, pageKey == 1, pageKey == #self.pages )

        BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 2 ), 8 )

        BOTCHED.FUNC.DrawPartialRoundedBoxEx( 8, 0, h-5, w, 5, BOTCHED.FUNC.GetTheme( 3, alpha ), false, 16, false, h-5-11, pageKey == 1, pageKey == #self.pages, pageKey == 1, pageKey == #self.pages )

        draw.SimpleText( title, "MontserratMedium20", w/2, h/2, BOTCHED.FUNC.GetTheme( 4, 75+(180*(alpha/150)) ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
    pageButton.DoClick = function()
        self:SetActivePage( pageKey )
    end

    self.pages[pageKey] = { panel, pageButton }

    if( self.activePage ) then
        panel:SetVisible( false )
    else
        self.activePage = pageKey
        if( panel.FillPanel and not panel.loaded ) then 
            panel:FillPanel() 
            panel.loaded = true
        end
    end

    for k, v in ipairs( self.pages ) do
        if( k == #self.pages ) then
            v[2]:SetWide( self.navWide-((#self.pages-1)*math.floor( self.navWide/#self.pages )) )
        else
            v[2]:SetWide( math.floor( self.navWide/#self.pages ) )
        end
    end

    return pageKey
end

function PANEL:SetActivePage( pageKey )
    self.pages[self.activePage][1]:SetVisible( false )

    local panel = self.pages[pageKey][1]
    panel:SetVisible( true )
    self.activePage = pageKey

    if( panel.FillPanel and not panel.loaded ) then 
        panel:FillPanel() 
        panel.loaded = true
    end
end

vgui.Register( "botched_popup_gacha_details", PANEL, "botched_popup_base" )