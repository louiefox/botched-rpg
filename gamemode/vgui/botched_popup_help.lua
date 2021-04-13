local PANEL = {}

function PANEL:Init()
    self:SetHeader( "HELP MENU" )
    self:SetDrawHeader( false )
    self:SetPopupWide( ScrW()*0.4 )
    self:SetExtraHeight( ScrH()*0.4 )

    self.closeButton:Remove()

    self.centerArea = vgui.Create( "DPanel", self )
    self.centerArea:SetPos( 0, 0 )
    self.centerArea:SetSize( self:GetPopupWide(), self.mainPanel.targetH )
    self.centerArea.Paint = function( self, w, h ) end 

    self.rightPanel = vgui.Create( "DPanel", self.centerArea )
    self.rightPanel:Dock( RIGHT )
    self.rightPanel:SetWide( self.centerArea:GetWide()/2 )
    self.rightPanel:DockPadding( 0, ScrH()*0.1, 0, 0 )
    self.rightPanel.Paint = function( self2, w, h ) 
        local x, y = self2:LocalToScreen( 0, 0 )

        if( self.mainPanel:GetTall() == self.mainPanel.targetH ) then
            BSHADOWS.BeginShadow( "help_menu_sidepanel" )
            BSHADOWS.SetShadowSize( "help_menu_sidepanel", w, h-4 )
            surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 1 ) )
            draw.RoundedBoxEx( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 1 ), false, true, false, true )
            BSHADOWS.EndShadow( "help_menu_sidepanel", x, y, 1, 2, 2, 255, 0, -5, true )
        end

        draw.RoundedBoxEx( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 1 ), false, true, false, true )
        draw.RoundedBoxEx( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 35 ), false, true, false, true )

        draw.SimpleText( "HELP MENU", "MontserratBold30", w/2, 25, BOTCHED.FUNC.GetTheme( 3 ), TEXT_ALIGN_CENTER, 0 )
    end

    self.leftPanel = vgui.Create( "DPanel", self.centerArea )
    self.leftPanel:Dock( LEFT )
    self.leftPanel:SetWide( self.centerArea:GetWide()/2 )
    self.leftPanel.Paint = function( self2, w, h ) end 

    local bottomButton = vgui.Create( "DButton", self.rightPanel )
    bottomButton:Dock( BOTTOM )
    bottomButton:DockMargin( 25, 25, 25, 25 )
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

    local helpBackPanel = vgui.Create( "DPanel", self.rightPanel )
    helpBackPanel:SetSize( self.rightPanel:GetWide()-50, 0 )
    helpBackPanel:SetPos( 25, 0 )
    helpBackPanel.Paint = function( self2, w, h ) end

    local function CreateHelpPanel( title, description, iconMat, buttonFunc )
        local text = BOTCHED.FUNC.TextWrap( description, "MontserratMedium20", (self.rightPanel:GetWide()-50)-BOTCHED.FUNC.ScreenScale( 100 )-10 )

        local helpPanel = vgui.Create( "DButton", helpBackPanel )
        helpPanel:Dock( TOP )
        helpPanel:DockMargin( 0, 0, 0, 10 )
        helpPanel:SetTall( BOTCHED.FUNC.ScreenScale( 100 ) )
        helpPanel:SetText( "" )
        helpPanel.Paint = function( self2, w, h )
            self2:CreateFadeAlpha( false, 100 )

            BSHADOWS.BeginShadow( "help_menu_info_" .. title )
            local x, y = self2:LocalToScreen( 0, 0 )
            draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 1 ) )		
            BSHADOWS.EndShadow( "help_menu_info_" .. title, x, y, 1, 1, 1, 255, 0, 0, false )

            draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100+self2.alpha ) )
            BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ), 8 )

            local iconSize = BOTCHED.FUNC.ScreenScale( 64 )
            surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 4, 75 ) )
            surface.SetMaterial( iconMat )
            surface.DrawTexturedRect( (h/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )

            draw.SimpleText( title, "MontserratBold25", h, (h/2)-(iconSize/2), BOTCHED.FUNC.GetTheme( 3 ) )

            BOTCHED.FUNC.DrawNonParsedText( text, "MontserratMedium20", h, (h/2)-(iconSize/2)+20, BOTCHED.FUNC.GetTheme( 4, 75 ) )
        end
        helpPanel.DoClick = buttonFunc

        helpBackPanel:SetTall( helpBackPanel:GetTall()+helpPanel:GetTall()+(helpBackPanel:GetTall() > 0 and 10 or 0) )
    end

    CreateHelpPanel( "DISCORD", "You can join the discord if you need any help, have a bug report, or a suggestion!", Material( "materials/botched/icons/discord_64.png" ), function()
        gui.OpenURL( "https://discord.gg/NAaTvpK8vQ" )
    end )

    CreateHelpPanel( "TUTORIAL", "Forgotten something? Click here to start the tutorial again.", Material( "materials/botched/icons/tutorial.png" ), function()
        if( IsValid( BOTCHED_TUTORIAL_POPUP ) ) then 
            BOTCHED_TUTORIAL_POPUP:Remove()
        end

        BOTCHED_TUTORIAL_POPUP = vgui.Create( "botched_popup_tutorial" )
    end )

    local rightRemainingH = self.mainPanel.targetH-bottomButton:GetTall()-25-25-25
    helpBackPanel:SetPos( 25, 50+(rightRemainingH/2)-(helpBackPanel:GetTall()/2) )

    local hintScrollpanel = vgui.Create( "botched_scrollpanel", self.leftPanel )
    hintScrollpanel:Dock( FILL )
    hintScrollpanel:SetTall( self.mainPanel.targetH-50 )
    hintScrollpanel:DockMargin( 25, 25, 25, 25 )
    hintScrollpanel.screenX, hintScrollpanel.screenY = 0, 0
    hintScrollpanel.Paint = function( self2, w, h ) self2.screenX, self2.screenY = self2:LocalToScreen( 0, 0 ) end

    local arrowMat = Material( "materials/botched/icons/arrow.png" )
    timer.Simple( 0.2, function()
        if( not IsValid( self ) ) then return end

        for k, v in ipairs( BOTCHED.CONFIG.ChatHints ) do
            surface.SetFont( "MontserratMedium20" )
            local textY = select( 2, surface.GetTextSize( v[2] ) )

            local text, lineCount = BOTCHED.FUNC.TextWrap( v[2], "MontserratMedium20", (self.leftPanel:GetWide()-50-20)-30 )

            local hintEntry = vgui.Create( "DButton", hintScrollpanel )
            hintEntry:Dock( TOP )
            hintEntry:DockMargin( 0, 0, 10, 10 )
            hintEntry:SetTall( 40 )
            hintEntry:SetText( "" )
            hintEntry.expandedH = 40+10+(textY*lineCount)
            hintEntry.textureRotation = 0
            hintEntry.Paint = function( self2, w, h )
                self2:CreateFadeAlpha( false, 100 )

                BSHADOWS.BeginShadow( "help_menu_hint_" .. k, 0, hintScrollpanel.screenY-10, ScrW(), hintScrollpanel.screenY+hintScrollpanel:GetTall() )
                BSHADOWS.SetShadowSize( "help_menu_hint_" .. k, w, h )
                local x, y = self2:LocalToScreen( 0, 0 )
                draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 1 ) )		
                BSHADOWS.EndShadow( "help_menu_hint_" .. k, x, y, 1, 1, 1, 255, 0, 0, false )

                draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100+self2.alpha ) )
                BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ), 8 )

                local iconSize = 16
                surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 4, 75 ) )
                surface.SetMaterial( arrowMat )
                surface.DrawTexturedRectRotated( 40/2, 40/2, iconSize, iconSize, self2.textureRotation )

                draw.SimpleText( v[1], "MontserratBold20", (40-iconSize)/2+iconSize+10, 40/2, BOTCHED.FUNC.GetTheme( 3 ), 0, TEXT_ALIGN_CENTER )

                BOTCHED.FUNC.DrawNonParsedText( text, "MontserratMedium20", 15, 40, BOTCHED.FUNC.GetTheme( 4 ) )
            end
            hintEntry.DoAnim = function( expanding )
                local anim = hintEntry:NewAnimation( 0.2, 0, -1 )
            
                anim.Think = function( anim, pnl, fraction )
                    if( expanding ) then
                        hintEntry.textureRotation = fraction*-90
                    else
                        hintEntry.textureRotation = (1-fraction)*-90
                    end
                end
            end
            hintEntry.ToggleOpen = function()
                if( not hintEntry.opened ) then
                    hintEntry.opened = true
                    hintEntry:SizeTo( (self.leftPanel:GetWide()-50-20), hintEntry.expandedH, 0.2 )
                    hintEntry.DoAnim( true )
                else
                    hintEntry.opened = false
                    hintEntry:SizeTo( (self.leftPanel:GetWide()-50-20), 40, 0.2 )
                    hintEntry.DoAnim( false )
                end
            end
            hintEntry.DoClick = hintEntry.ToggleOpen
        end
    end )
end

vgui.Register( "botched_popup_help", PANEL, "botched_popup_base" )