local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel()
    self.topPanel = vgui.Create( "DPanel", self )
    self.topPanel:SetSize( 0, 50 )
    self.topPanel:SetPos( self:GetWide()-25-self.topPanel:GetWide(), 25 )
    self.topPanel.Paint = function( self2, w, h ) 
        BSHADOWS.BeginShadow( "gacha_currency_back" )
        local x, y = self2:LocalToScreen( 0, 0 )
        draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 1 ) )			
        BSHADOWS.EndShadow( "gacha_currency_back", x, y, 1, 2, 2, 255, 0, 0, false )
        
        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ) )
    end
    self.topPanel.AddSpacer = function() 
        local spacer = vgui.Create( "DPanel", self.topPanel )
        spacer:Dock( LEFT )
        spacer:DockMargin( 0, 3, 0, 3 )
        spacer:SetWide( 2 )
        spacer.Paint = function( self2, w, h )
            surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 1, 200 ) )
            surface.DrawRect( 0, 0, w, h )
        end 
    end

    local addMat = Material( "materials/botched/icons/add_16.png" )
    local function CreateCurrencyPanel( material, getAmount, func, buttonMat )
        if( self.topPanel:GetWide() > 0 ) then
            self.topPanel.AddSpacer()
        end

        local currencyPanel = vgui.Create( "DPanel", self.topPanel )
        currencyPanel:Dock( LEFT )
        currencyPanel:SetWide( self:GetWide()*0.15 )
        currencyPanel.Paint = function( self2, w, h )
            surface.SetDrawColor( 255, 255, 255 )
            surface.SetMaterial( material )
            local iconSize = 24
            surface.DrawTexturedRect( (h/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )

            draw.SimpleText( string.Comma( getAmount() ), "MontserratMedium21", w/2, h/2-1, BOTCHED.FUNC.GetTheme( 4, 125 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end 

        currencyPanel.button = vgui.Create( "DButton", currencyPanel )
        currencyPanel.button:Dock( RIGHT )
        currencyPanel.button:DockMargin( 0, 0, 6, 0 )
        currencyPanel.button:SetWide( self.topPanel:GetTall() )
        currencyPanel.button:SetText( "" )
        local alpha = 125
        currencyPanel.button.Paint = function( self2, w, h )
            if( self2:IsHovered() ) then
                alpha = math.Clamp( alpha+10, 125, 255 )
            else
                alpha = math.Clamp( alpha-10, 125, 255 )
            end

            local iconSize = 16
            local boxSize = iconSize+10
            draw.RoundedBox( 8, (w/2)-(boxSize/2), (h/2)-(boxSize/2), boxSize, boxSize, BOTCHED.FUNC.GetTheme( 2, alpha-125 ) )

            surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 4, alpha ) )
            surface.SetMaterial( buttonMat or addMat )
            surface.DrawTexturedRect( (h/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
        end
        currencyPanel.button.DoClick = func

        self.topPanel:SetWide( self.topPanel:GetWide()+currencyPanel:GetWide() )
        self.topPanel:SetPos( self:GetWide()-25-self.topPanel:GetWide(), 25 )
    end

    CreateCurrencyPanel( Material( "materials/botched/icons/gems.png" ), function() return LocalPlayer():GetGems() end, BOTCHED.FUNC.DermaCreateGemStore )

    CreateCurrencyPanel( Material( "materials/botched/icons/mana.png" ), function() return LocalPlayer():GetMana() end, function()
    
    end )

    CreateCurrencyPanel( Material( "materials/botched/icons/magic_coin.png" ), function() return LocalPlayer():GetMagicCoins() end, function()
    
    end, Material( "materials/botched/icons/info_16.png" ) )

    self.navigationContent = vgui.Create( "DPanel", self )
    self.navigationContent:Dock( FILL )
    self.navigationContent:SetZPos( -10 )
    self.navigationContent.Paint = function() end

    self.previousPage = vgui.Create( "DButton", self )
    self.previousPage:SetSize( BOTCHED.FUNC.ScreenScale( 50 ), BOTCHED.FUNC.ScreenScale( 75 ) )
    self.previousPage:SetPos( 25, (self:GetTall()/2)-(self.previousPage:GetTall()/2) )
    self.previousPage:SetText( "" )
    local alpha = 0
    local previousIconMat = Material( "materials/botched/icons/previous.png" )
    self.previousPage.Paint = function( self2, w, h )
        if( self2:IsHovered() ) then
            alpha = math.Clamp( alpha+10, 100, 150 )
        else
            alpha = math.Clamp( alpha-10, 100, 150 )
        end

        BSHADOWS.BeginShadow( "gacha_previous" )
        local x, y = self2:LocalToScreen( 0, 0 )
        draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 1 ) )			
        BSHADOWS.EndShadow( "gacha_previous", x, y, 1, 2, 2, 255, 0, 0, false )
        
        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, alpha ) )

        BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 2 ), 8 )

        surface.SetDrawColor( 255, 255, 255 )
        surface.SetMaterial( previousIconMat )
        local iconSize = BOTCHED.FUNC.ScreenScale( 32 )
        surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
    end
    self.previousPage.UpdateVisibility = function()
        self.previousPage:SetVisible( self.activePage > 1 )
    end
    self.previousPage.DoClick = function()
        self:SetActivePage( math.Clamp( self.activePage-1, 1, #self.pages ) )
    end

    self.nextPage = vgui.Create( "DButton", self )
    self.nextPage:SetSize( BOTCHED.FUNC.ScreenScale( 50 ), BOTCHED.FUNC.ScreenScale( 75 ) )
    self.nextPage:SetPos( self:GetWide()-self.nextPage:GetWide()-25, (self:GetTall()/2)-(self.nextPage:GetTall()/2) )
    self.nextPage:SetText( "" )
    local alpha = 0
    local nextIconMat = Material( "materials/botched/icons/next.png" )
    self.nextPage.Paint = function( self2, w, h )
        if( self2:IsHovered() ) then
            alpha = math.Clamp( alpha+10, 100, 150 )
        else
            alpha = math.Clamp( alpha-10, 100, 150 )
        end

        BSHADOWS.BeginShadow( "gacha_next" )
        local x, y = self2:LocalToScreen( 0, 0 )
        draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 1 ) )			
        BSHADOWS.EndShadow( "gacha_next", x, y, 1, 2, 2, 255, 0, 0, false )

        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, alpha ) )

        BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 2 ), 8 )

        surface.SetDrawColor( 255, 255, 255 )
        surface.SetMaterial( nextIconMat )
        local iconSize = BOTCHED.FUNC.ScreenScale( 32 )
        surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
    end
    self.nextPage.UpdateVisibility = function()
        self.nextPage:SetVisible( self.activePage != #self.pages )
    end
    self.nextPage.DoClick = function()
        self:SetActivePage( math.Clamp( self.activePage+1, 1, #self.pages ) )
    end

    self.pages = {}

    local function CreateDrawButton( parent, uniqueID, text, cost, costMat )
        surface.SetFont( "MontserratBold30" )
        local textX, textY = surface.GetTextSize( text )
        textX, textY = textX+40, textY+10

        surface.SetFont( "MontserratBold25" )
        local text2X, text2Y = surface.GetTextSize( string.Comma( cost ) )
        text2Y = text2Y+10

        local drawButton = vgui.Create( "DButton", parent )
        drawButton:SetSize( textX, textY+text2Y )
        drawButton:SetText( "" )
        local alpha = 0
        drawButton.Paint = function( self2, w, h ) 
            if( self2:IsHovered() ) then
                alpha = math.Clamp( alpha+10, 100, 150 )
            else
                alpha = math.Clamp( alpha-10, 100, 150 )
            end

            BSHADOWS.BeginShadow( uniqueID, self:GetShadowBounds() )
            local x, y = self2:LocalToScreen( 0, 0 )
            draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 1 ) )			
            BSHADOWS.EndShadow( uniqueID, x, y, 1, 2, 2, 255, 0, 0, false )

            draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, alpha ) )
            BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 2 ), 8 )

            draw.SimpleText( text, "MontserratBold30", w/2, text2Y+(textY/2)-1, BOTCHED.FUNC.GetTheme( 4, 150 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

            draw.RoundedBoxEx( 8, 0, 0, w, text2Y, BOTCHED.FUNC.GetTheme( 1, 150 ), true, true )

            local iconSize = 24
            local contentW = iconSize+text2X+10
            draw.SimpleText( string.Comma( cost ), "MontserratBold25", (w/2)+(contentW/2), text2Y/2, BOTCHED.FUNC.GetTheme( 4, 150 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )

            surface.SetDrawColor( 255, 255, 255 )
            surface.SetMaterial( costMat )
            surface.DrawTexturedRect( (w/2)-(contentW/2), (text2Y/2)-(iconSize/2), iconSize, iconSize )
        end

        return drawButton
    end

    local maxChar, spacing = 6, 25
    local slotWide = (self:GetWide()-50-((maxChar-1)*spacing))/maxChar
    for k, v in ipairs( BOTCHED.CONFIG.Banners ) do
        local imageMat
        BOTCHED.FUNC.GetImage( v.Image or "", function( mat ) 
            imageMat = mat
        end )

        surface.SetFont( "MontserratBold50" )
        local headerX, headerY = surface.GetTextSize( string.upper( v.Name ) )

        local bannerPage = vgui.Create( "DPanel", self.navigationContent )
        bannerPage.Paint = function( self2, w, h ) 
            if( not imageMat ) then return end

            local imageH = (imageMat:Height()/imageMat:Width())*w

            surface.SetDrawColor( 255, 255, 255 )
            surface.SetMaterial( imageMat )
            surface.DrawTexturedRect( 0, (h/2)-(imageH/2), w, imageH )

            BSHADOWS.BeginShadow( "banner_name" .. k, self:GetShadowBounds() )
            local x, y = self2:LocalToScreen( 30, 25 )
            draw.SimpleText( string.upper( v.Name ), "MontserratBold50", x, y, BOTCHED.FUNC.GetTheme( 4 ) )
            BSHADOWS.EndShadow( "banner_name" .. k, x, y, 1, 2, 2, 255, 0, 0, false )

            local num25 = BOTCHED.FUNC.ScreenScale( 25 )
            local num20 = BOTCHED.FUNC.ScreenScale( 20 )
            draw.SimpleTextOutlined( "Banners have a higher chance to get certain characters!", "MontserratMedium25", 30, h-num25-num20-num25, BOTCHED.FUNC.GetTheme( 3 ), 0, TEXT_ALIGN_BOTTOM, 1, BOTCHED.FUNC.GetTheme( 1 ) )
            draw.SimpleTextOutlined( "A 2★ or higher character is guaranteed with each 10x draw.", "MontserratMedium21", 30, h-num25-num20, BOTCHED.FUNC.GetTheme( 4, 100 ), 0, TEXT_ALIGN_BOTTOM, 1, BOTCHED.FUNC.GetTheme( 1 ) )
            draw.SimpleTextOutlined( "Already recruited characters will be converted to Magic Coins!", "MontserratMedium21", 30, h-num25, BOTCHED.FUNC.GetTheme( 4, 100 ), 0, TEXT_ALIGN_BOTTOM, 1, BOTCHED.FUNC.GetTheme( 1 ) )
        end
        self:AddPage( bannerPage )

        local detailsButton = vgui.Create( "DButton", bannerPage )
        detailsButton:SetSize( 32, 32 )
        detailsButton:SetPos( 30+headerX+10, BOTCHED.FUNC.ScreenScale( 37 ) )
        detailsButton:SetText( "" )
        local alpha = 0
        local infoMat = Material( "materials/botched/icons/info_16.png" )
        detailsButton.Paint = function( self2, w, h )
            if( self2:IsHovered() ) then
                alpha = math.Clamp( alpha+10, 0, 100 )
            else
                alpha = math.Clamp( alpha-10, 0, 100 )
            end
    
            draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, alpha ) )
    
            BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ), 8 )
    
            surface.SetDrawColor( 255, 255, 255 )
            surface.SetMaterial( infoMat )
            local iconSize = 16
            surface.DrawTexturedRect( (h/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
        end
        detailsButton.DoClick = function()
            if( IsValid( self.popupPanel ) ) then return end

            self.popupPanel = vgui.Create( "botched_popup_gacha_details" )
            self.popupPanel:SetGachaInfo( k, v )
        end

        local previousSpacing = BOTCHED.FUNC.ScreenScale( 25 )
        for key, val in ipairs( table.Reverse( v.Draws ) ) do
            local drawButton = CreateDrawButton( bannerPage, "banner_" .. k .. "_draw" .. key, "DRAW x" .. val.Amount, (val.Cost.Gems or 0), Material( "materials/botched/icons/gems.png" ) )
            drawButton:SetPos( self:GetWide()-previousSpacing-drawButton:GetWide(), self:GetTall()-BOTCHED.FUNC.ScreenScale( 25 )-drawButton:GetTall() )
            drawButton.DoClick = function()
                self.popupPanel =  vgui.Create( "botched_popup_cost" )
                self.popupPanel:SetHeader( "DRAW x" .. val.Amount )
                self.popupPanel:SetButtonText( "DRAW" )
                self.popupPanel:SetCostTable( val.Cost, function()
                    net.Start( "Botched.RequestDrawBanner" )
                        net.WriteUInt( k, 4 )
                        net.WriteUInt( #v.Draws-(key-1), 4 )
                    net.SendToServer()
                end, function()
                    BOTCHED.FUNC.DermaQuery( "You don't have enough gems, do you want to buy more?", "GEMS", "Yes", BOTCHED.FUNC.DermaCreateGemStore, "No" )
                end )
            end

            previousSpacing = previousSpacing+drawButton:GetWide()+25
        end

        local totalSlotsWide = (#v.Characters*(slotWide+spacing))-spacing
        for key, val in ipairs( v.Characters ) do
            local characterConfig = BOTCHED.CONFIG.Characters[val]
            if( not characterConfig ) then continue end

            local characterPanel = vgui.Create( "DPanel", bannerPage )
            characterPanel:SetSize( slotWide, slotWide*2 )
            local charX, charY = ((self:GetWide()/2)-(totalSlotsWide/2))+((key-1)*(slotWide+spacing)), (self:GetTall()/2)-(characterPanel:GetTall()/2)
            characterPanel:SetPos( charX, charY )
            characterPanel.Paint = function() end

            characterPanel.model = vgui.Create( "DModelPanel", characterPanel )
            characterPanel.model:Dock( FILL )
            characterPanel.model.Load = function()
                if( not IsValid( self ) ) then return end
                
                characterPanel.model:SetModel( characterConfig.Model )
                characterPanel.model.LayoutEntity = function() end
                if( IsValid( characterPanel.model.Entity ) ) then
                    characterPanel.model:SetFOV( 35 )
                    characterPanel.model.Entity:SetAngles(Angle(0, 45,  0))
                end
    
                BOTCHED.TEMP.ModelsLoaded[characterConfig.Model] = true
            end
    
            if( not BOTCHED.TEMP.ModelsLoaded[characterConfig.Model] ) then
                BOTCHED.FUNC.AddSlotToLoad( characterPanel, characterPanel.model.Load )
            else
                characterPanel.model.Load()
            end

            surface.SetFont( "MontserratBold21" )
            local nameX, nameY = surface.GetTextSize( characterConfig.Name )
            nameX = nameX+40

            local starMat = Material( "materials/botched/icons/star_16.png" )

            characterPanel.info = vgui.Create( "DPanel", bannerPage )
            characterPanel.info:SetSize( nameX, 45 )
            characterPanel.info:SetPos( charX+(characterPanel:GetWide()/2)-(characterPanel.info:GetWide()/2), charY+characterPanel:GetTall()  )
            local uniqueID = "banner_" .. k .. "_char" .. val
            characterPanel.info.Paint = function( self2, w, h ) 
                BSHADOWS.BeginShadow( uniqueID, self:GetShadowBounds() )
                local x, y = self2:LocalToScreen( w/2, 0 )
                draw.SimpleTextOutlined( characterConfig.Name, "MontserratBold30", x, y, BOTCHED.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, 0, 1, BOTCHED.FUNC.GetTheme( 1 ) )	
                BSHADOWS.EndShadow( uniqueID, x, y, 1, 2, 2, 255, 0, 0, false )

                local stars = characterConfig.Stars
                local iconSize, starSpacing = 16, 5
                surface.SetMaterial( starMat )
        
                local starTotalW = (stars*(iconSize+starSpacing))-starSpacing
        
                for i = 1, stars do
                    local starXPos = ((w/2)-(starTotalW/2))+((i-1)*(iconSize+starSpacing))
                    surface.SetDrawColor( 0, 0, 0 )
                    surface.DrawTexturedRect( starXPos, h-iconSize, iconSize, iconSize )
        
                    surface.SetDrawColor( 255, 255, 255 )
                    surface.DrawTexturedRect( starXPos-1, h-iconSize-1, iconSize, iconSize )
                end
            end
        end
    end

    self:SetActivePage( 1 )
end

function PANEL:AddPage( panel )
    local pageKey = table.insert( self.pages, panel )

    panel:SetSize( self:GetSize() )
    panel:SetPos( pageKey == 1 and 0 or self:GetWide(), 0 )
end

function PANEL:SetActivePage( pageKey )
    if( self.activePage == pageKey ) then return end

    if( self.activePage and self.pages[self.activePage] ) then
        if( self.activePage > pageKey ) then
            self.pages[self.activePage]:MoveTo( self:GetWide(), 0, 0.2 )
        else
            self.pages[self.activePage]:MoveTo( -self:GetWide(), 0, 0.2 )
        end
    end

    self.activePage = pageKey
    self.pages[pageKey]:MoveTo( 0, 0, 0.2 )

    self.previousPage.UpdateVisibility()
    self.nextPage.UpdateVisibility()
end

function PANEL:GetShadowBounds()
    local x = self:LocalToScreen( 0, 0 )
    return x, 0, x+self:GetWide(), ScrH()
end

function PANEL:Paint( w, h )

end

vgui.Register( "botched_mainmenu_gacha", PANEL, "DPanel" )