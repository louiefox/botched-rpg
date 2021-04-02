local PANEL = {}

function PANEL:Init()
    self:SetSize( ScrW(), ScrH() )
    self:MakePopup()
    self:SetTitle( "" )
    self:SetDraggable( false )
    self:ShowCloseButton( false )
    self:SetAlpha( 0 )
    self:AlphaTo( 255, 0.2 )

    self.mainPanel = vgui.Create( "DPanel", self )
    self.mainPanel:SetSize( ScrW()*0.8, 0 )
    self.mainPanel:SizeTo( ScrW()*0.8, ScrH()*0.8, 0.2 )
    self.mainPanel.targetH = ScrH()*0.8
    self.mainPanel:Center()
    self.mainPanel.OnSizeChanged = function( self2 )
        self2:Center()
    end
    self.mainPanel.Paint = function( self2, w, h )
        BSHADOWS.BeginShadow( "popup_banner" )
        BSHADOWS.SetShadowSize( "popup_banner", w, h )
        local x, y = self2:LocalToScreen( 0, 0 )
        draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 1 ) )			
        BSHADOWS.EndShadow( "popup_banner", x, y, 1, 2, 2, 255, 0, 0, true )

        if( not self.imageMat ) then return end
        local imageH = (self.imageMat:Height()/self.imageMat:Width())*w
        BOTCHED.FUNC.DrawRoundedMask( 8, 0, 0, w, h, function()
            surface.SetDrawColor( 255, 255, 255 )
            surface.SetMaterial( self.imageMat )
            surface.DrawTexturedRect( 0, (h/2)-(imageH/2), w, imageH )
		end )
    end

    self.bottomButton = vgui.Create( "DButton", self.mainPanel )
    self.bottomButton:Dock( BOTTOM )
    self.bottomButton:DockMargin( self.mainPanel:GetWide()*0.4, 0, self.mainPanel:GetWide()*0.4, 25 )
    self.bottomButton:SetTall( 50 )
    self.bottomButton:SetAlpha( 0 )
    self.bottomButton:SetText( "" )
    local alpha = 0
    self.bottomButton.Paint = function( self2, w, h )
        if( self2:IsHovered() ) then
            alpha = math.Clamp( alpha+10, 150, 255 )
        else
            alpha = math.Clamp( alpha-10, 150, 255 )
        end

        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 1 ) )
        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, alpha ) )

        BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 2 ), 8 )

        BOTCHED.FUNC.DrawPartialRoundedBox( 8, 0, h-5, w, 5, BOTCHED.FUNC.GetTheme( 3, alpha ), false, 16, false, h-5-11 )

        draw.SimpleText( "CLOSE", "MontserratMedium20", w/2, h/2, BOTCHED.FUNC.GetTheme( 4, 75+(180*(alpha/150)) ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
    self.bottomButton.DoClick = function()
        if( IsValid( BOTCHED_MAINMENU ) ) then BOTCHED_MAINMENU:SetVisible( true ) end

        self:AlphaTo( 0, 0.2, 0, function()
            self:Remove()
        end )
    end

    self.skipButton = vgui.Create( "DButton", self.mainPanel )
    self.skipButton:SetSize( 48, 48 )
    self.skipButton:SetPos( self.mainPanel:GetWide()-self.skipButton:GetWide()-25, 25 )
    self.skipButton:SetText( "" )
    local alpha = 0
    local skipMat = Material( "materials/botched/icons/skip.png" )
    self.skipButton.Paint = function( self2, w, h )
        if( self2:IsHovered() ) then
            alpha = math.Clamp( alpha+10, 0, 175 )
        else
            alpha = math.Clamp( alpha-10, 0, 175 )
        end

        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 1, alpha ) )

        BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 1 ), 8 )

        surface.SetDrawColor( 255, 255, 255 )
        surface.SetMaterial( skipMat )
        local iconSize = 32
        surface.DrawTexturedRect( (h/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
    end
end

function PANEL:SetDrawInfo( bannerKey, drawnCharacters, givenCharacters )
    local bannerConfig = BOTCHED.CONFIG.Banners[bannerKey]
    if( not bannerConfig ) then return end

    BOTCHED.FUNC.GetImage( bannerConfig.Image or "", function( mat ) 
        self.imageMat = mat
    end )

    local slotWide = (self.mainPanel:GetWide()/5)*0.65
    local slotTall = slotWide*1.2
    local starMat = Material( "materials/botched/icons/star_32.png" )
    local magicCoinMat = Material( "materials/botched/icons/magic_coin_64.png" )

    local bottomSlotW = slotWide*0.5
    local totalSlotBottomW = (#drawnCharacters*bottomSlotW)+(slotWide-bottomSlotW)

    local bottomSlot1W = slotWide*0.1
    local totalSlotBottom1W = (#drawnCharacters*bottomSlot1W)+(slotWide-bottomSlot1W)

    local borderSize = 4

    local ownedCharacters = LocalPlayer():GetOwnedCharacters()

    local characterPanels = {}
    for k, v in ipairs( drawnCharacters ) do
        local characterConfig = BOTCHED.CONFIG.Characters[v]
        if( not characterConfig ) then continue end

        local stars = characterConfig.Stars or 0
        local border = (stars == 3 and BOTCHED.CONFIG.Borders.Gold) or (stars == 2 and BOTCHED.CONFIG.Borders.Silver) or BOTCHED.CONFIG.Borders.Bronze

        local characterPanel = vgui.Create( "DPanel", self.mainPanel )
        characterPanel:SetSize( slotWide, slotTall )
        characterPanel:SetPos( (self.mainPanel:GetWide()/2)-(totalSlotBottom1W/2)+((k-1)*bottomSlot1W), self.mainPanel.targetH-(slotTall*0.4) )
        characterPanel:MoveTo( (self.mainPanel:GetWide()/2)-(totalSlotBottomW/2)+((k-1)*bottomSlotW), self.mainPanel.targetH-(slotTall*0.4), 0.4 )
        characterPanel:SetZPos( #drawnCharacters-(k-1) )
        characterPanel.stars = stars
        characterPanel.Paint = function( self2, w, h )
            local startY = (ScrH()/2)-(self.mainPanel:GetTall()/2)
            BSHADOWS.BeginShadow( "banner_draw_" .. k, 0, startY, ScrW(), startY+self.mainPanel:GetTall() )
            BSHADOWS.SetShadowSize( "banner_draw_" .. k, w, h )
            local x, y = self2:LocalToScreen( 0, 0 )
            draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 1 ) )		
            BSHADOWS.EndShadow( "banner_draw_" .. k, x, y, 1, 1, 2, 255, 0, 0, false )

            BOTCHED.FUNC.DrawRoundedMask( 8, 0, 0, w, h, function()
                BOTCHED.FUNC.DrawGradientBox( 0, 0, w, h, 1, unpack( border.Colors ) )
            end )

            draw.RoundedBox( 8, borderSize, borderSize, w-(2*borderSize), h-(2*borderSize), BOTCHED.FUNC.GetTheme( 1 ) )	
            draw.RoundedBox( 8, borderSize, borderSize, w-(2*borderSize), h-(2*borderSize), BOTCHED.FUNC.GetTheme( 2, 100 ) )	
        end
        characterPanel.LoadInfo = function( xPos, yPos )
            surface.PlaySound( stars > 1 and "botched/gacha_won.wav" or "botched/gacha_draw.wav" )

            characterPanel.info = vgui.Create( "DPanel", self.mainPanel )
            characterPanel.info:SetSize( slotWide, 34 )
            characterPanel.info:SetPos( xPos, yPos+slotTall-23 )
            characterPanel.info:SetZPos( 100 )
            characterPanel.info.Paint = function( self2, w, h ) 
                local iconSize, starSpacing = 32, 5
                surface.SetMaterial( starMat )
        
                local starTotalW = (stars*(iconSize+starSpacing))-starSpacing
        
                for i = 1, stars do
                    local starXPos = ((w/2)-(starTotalW/2))+((i-1)*(iconSize+starSpacing))
                    surface.SetDrawColor( 0, 0, 0 )
                    surface.DrawTexturedRect( starXPos-1, h-iconSize-1, iconSize+2, iconSize+2 )
        
                    surface.SetDrawColor( 255, 255, 255 )
                    surface.DrawTexturedRect( starXPos, h-iconSize, iconSize, iconSize )
                end
            end

            local drawnBefore = false
            for key, val in ipairs( drawnCharacters ) do
                if( key >= k ) then break end

                if( val == v ) then 
                    drawnBefore = true 
                    break
                end
            end
            
            if( (ownedCharacters[v] and not givenCharacters[v]) or drawnBefore ) then
                timer.Simple( 0.5, function()
                    if( not IsValid( characterPanel ) ) then return end
                    
                    local refundAmount = BOTCHED.CONFIG.AlreadyOwnedRefunds[stars] or 1

                    characterPanel.refund = vgui.Create( "DPanel", characterPanel )
                    characterPanel.refund:Dock( FILL )
                    characterPanel.refund:DockMargin( 10, 10, 10, 10 )
                    characterPanel.refund:SetAlpha( 0 )
                    characterPanel.refund:AlphaTo( 255, 0.5 )
                    characterPanel.refund.Paint = function( self2, w, h ) 
                        BOTCHED.FUNC.DrawBlur( self2, 4, 4 )

                        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 4 ) )
                        surface.SetMaterial( magicCoinMat )
                        local iconSize = 64
                        surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )

                        draw.SimpleTextOutlined( "DUPLICATE", "MontserratBold40", w/2, (h/2)-(iconSize/2)-5, BOTCHED.FUNC.GetTheme( 3 ), 1, TEXT_ALIGN_BOTTOM, 2, BOTCHED.FUNC.GetTheme( 1 ) )
                        draw.SimpleTextOutlined( "x" .. refundAmount .. " COINS", "MontserratBold40", w/2, (h/2)+(iconSize/2)+5, BOTCHED.FUNC.GetTheme( 4 ), 1, 0, 2, BOTCHED.FUNC.GetTheme( 1 ) )
                    end
                end )
            end
        end

        characterPanel.model = vgui.Create( "DModelPanel", characterPanel )
        characterPanel.model:Dock( FILL )
        characterPanel.model:SetAlpha( 0 )
        characterPanel.model.Load = function()
            if( not IsValid( characterPanel ) ) then return end
            
            characterPanel.model:SetModel( characterConfig.Model )
            characterPanel.model.LayoutEntity = function() end
            characterPanel.model.PreDrawModel = function()
                render.ClearDepth()
            end
            if( IsValid( characterPanel.model.Entity ) ) then
                characterPanel.model:SetFOV( 60 )
                characterPanel.model.Entity:SetAngles(Angle(0, 45,  0))
            end
        end

        characterPanels[k] = characterPanel
    end

    local panelSpacing = 25
    local row1Y, row2Y = (self.mainPanel.targetH/2)-(panelSpacing/2)-slotTall, (self.mainPanel.targetH/2)+(panelSpacing/2)
    local totalPanelWide = (5*slotWide)+(4*panelSpacing)
    local totalAnimTime = 0.3
    local function RunAnimation( panelKey )
        local characterPanel = characterPanels[panelKey]
        if( not IsValid( characterPanel ) ) then 
            if( IsValid( self.bottomButton ) ) then self.bottomButton:AlphaTo( 255, 0.2 ) end
            return 
        end

        if( characterPanel.Loaded ) then return end
        characterPanel.Loaded = true

        local rowPosition = panelKey <= 5 and panelKey or panelKey-5
        local newX, newY = (self.mainPanel:GetWide()/2)-(totalPanelWide/2)+((rowPosition-1)*(slotWide+panelSpacing)), panelKey <= 5 and row1Y or row2Y
        characterPanel.model.Load()
        characterPanel.model:AlphaTo( 255, totalAnimTime )

        characterPanel:MoveTo( newX, newY, totalAnimTime, 0, -1, function() 
            characterPanel.LoadInfo( newX, newY )
        end )

        timer.Simple( totalAnimTime+(characterPanel.stars > 1 and 1 or 0.2), function() RunAnimation( panelKey+1 ) end )
    end

    timer.Simple( 2, function()
        if( not IsValid( self ) ) then return end
        RunAnimation( 1 )
    end )

    self.skipButton.DoClick = function()
        for k, v in ipairs( characterPanels ) do
            v.Loaded = true
            local rowPosition = k <= 5 and k or k-5
            local newX, newY = (self.mainPanel:GetWide()/2)-(totalPanelWide/2)+((rowPosition-1)*(slotWide+panelSpacing)), k <= 5 and row1Y or row2Y
            v.model.Load()
            v.model:SetAlpha( 255 )
            v:SetPos( newX, newY )
            v.LoadInfo( newX, newY )
        end

        self.bottomButton:AlphaTo( 255, 0.2 )
        self.skipButton:Remove()
    end
end

function PANEL:Paint( w, h )
    BOTCHED.FUNC.DrawBlur( self, 4, 4 )
end

vgui.Register( "botched_popup_banner_draw", PANEL, "DFrame" )