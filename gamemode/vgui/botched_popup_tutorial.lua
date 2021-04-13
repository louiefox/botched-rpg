local PANEL = {}

function PANEL:Init()
    self:SetDrawOnTop( true )
    self.headerHeight = 40

    self:DockPadding( 0, self.headerHeight, 0, 0 )

    self.defaultH = self.headerHeight+35
    self:SetSize( ScrW()*0.13, self.defaultH )

    self:SetTutorial( 1, 1 )
end

function PANEL:OnSizeChanged( w, h )
    self:SetPos( ScrW()-w-25, (ScrH()/3)-(h/2) )
end

function PANEL:SetTutorial( tutorialKey )
    self:Clear()
    self.tutorialKey, self.stepKey = tutorialKey, 1

    local tutorialConfig = BOTCHED.CONFIG.Tutorials[tutorialKey]

    self.progressPanel = vgui.Create( "DPanel", self )
    self.progressPanel:Dock( BOTTOM )
    self.progressPanel:SetTall( 35 )
    self.progressPanel.Paint = function( self2, w, h )
        draw.RoundedBoxEx( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 1 ), false, false, true, true )
        draw.RoundedBoxEx( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 150 ), false, false, true, true )

        local progressBarH = 8
        draw.SimpleText( "Tutorial: " .. tutorialConfig.Title, "MontserratBold20", 10, (h-progressBarH)/2-1, BOTCHED.FUNC.GetTheme( 4, 75 ), 0, TEXT_ALIGN_CENTER )

        draw.SimpleText( "Step " .. self.stepKey .. "/" .. #tutorialConfig.Steps, "MontserratBold20", w-10, (h-progressBarH)/2-1, BOTCHED.FUNC.GetTheme( 4, 75 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )

        BOTCHED.FUNC.DrawPartialRoundedBoxEx( 8, 0, h-progressBarH, w, progressBarH, BOTCHED.FUNC.GetTheme( 1, 150 ), false, 16, false, h-16, false, false, true, true )
        BOTCHED.FUNC.DrawRoundedMask( 8, -1, h-16, w+2, 16, function()
            surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 3, 150 ) )
            surface.DrawRect( 0, h-progressBarH, w*math.Clamp( (self.stepKey-1)/#tutorialConfig.Steps, 0, 1 ), progressBarH )
        end )
    end

    self.stepInfo = vgui.Create( "DPanel", self )
    self.stepInfo:Dock( TOP )
    self.stepInfo:SetTall( 0 )
    self.stepInfo:DockMargin( 10, 10, 10, 10 )
    self.stepInfo.Paint = function( self2, w, h )
        BSHADOWS.BeginShadow( "tutorial_popup_stepinfo" )
        BSHADOWS.SetShadowSize( "tutorial_popup_stepinfo", w, h )
        local x, y = self2:LocalToScreen( 0, 0 )
        draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 1 ) )			
        BSHADOWS.EndShadow( "tutorial_popup_stepinfo", x, y, 1, 2, 2, 255, 0, 0, false )

        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 150 ) )

        BOTCHED.FUNC.DrawNonParsedText( self2.text or "", "MontserratMedium20", 15, 10, BOTCHED.FUNC.GetTheme( 4, 200 ) )
    end
    self.stepInfo.SetStepKey = function( self2, stepKey )
        self.stepKey = stepKey

        local stepText = tutorialConfig.Steps[stepKey]

        surface.SetFont( "MontserratMedium20" )
        local textY = select( 2, surface.GetTextSize( stepText ) )
    
        local text, lineCount = BOTCHED.FUNC.TextWrap( stepText, "MontserratMedium20", self:GetWide()-20-30 )
        self2.text = text
    
        self2:SetTall( 20+(lineCount*(textY+1)) )
        self:SetTall( self.defaultH+20+self2:GetTall() )
    end

    self:SetStepKey( self.stepKey )
end

function PANEL:SetStepKey( stepKey )
    self.stepInfo:SetStepKey( stepKey )
end

function PANEL:Paint( w, h )
    BOTCHED.FUNC.DrawBlur( self, 4, 4 )
    draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 1, 200 ) )

    draw.RoundedBoxEx( 8, 0, 0, w, self.headerHeight, BOTCHED.FUNC.GetTheme( 1 ), true, true )

    draw.SimpleText( "TUTORIAL", "MontserratBold30", 10, self.headerHeight/2-1, BOTCHED.FUNC.GetTheme( 4, 75 ), 0, TEXT_ALIGN_CENTER )
end

vgui.Register( "botched_popup_tutorial", PANEL, "DPanel" )