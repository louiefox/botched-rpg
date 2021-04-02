local PANEL = {}

function PANEL:Init()
    self:SetSize( ScrW(), ScrH() )
    self:SetPos( 0, 0 )
    self:MakePopup()
    self:SetTitle( "" )
    self:SetDraggable( false )
    self:ShowCloseButton( false )

    self.optionsPanel = vgui.Create( "DPanel", self )
    self.optionsPanel:SetSize( ScrW()*0.15, 0 )
    self.optionsPanel:Center()
    self.optionsPanel.Paint = function( self2, w, h )
        BSHADOWS.BeginShadow( "popup_choice" )
        BSHADOWS.SetShadowSize( "popup_choice", w, h )
        local x, y = self2:LocalToScreen( 0, 0 )
        draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 1 ) )			
        BSHADOWS.EndShadow( "popup_choice", x, y, 1, 2, 2, 255, 0, 0, false )
    end
    self.optionsPanel.OnSizeChanged = function( self2 )
        self2:Center()
    end
    self.optionsPanel.targetH = 0
    self.optionsPanel:SetAlpha( 0 )
    self.optionsPanel:AlphaTo( 255, 0.2 )
end

local optionH, optionSpacing = 45, 10
function PANEL:AddOption( label, onClick )
    local newTall = self.optionsPanel.targetH+optionH+optionSpacing
    if( self.optionsPanel.targetH <= 0 ) then
        newTall = self.optionsPanel.targetH+optionH+(2*optionSpacing)
    end

    self.optionsPanel.targetH = newTall
    self.optionsPanel:SizeTo( self.optionsPanel:GetWide(), newTall, 0.2, 0, -1, function()
        self.optionsPanel:Center()
    end )
	
	local optionButton = vgui.Create( "DButton", self.optionsPanel )
	optionButton:Dock( TOP )
	optionButton:DockMargin( optionSpacing, optionSpacing, optionSpacing, 0 )
	optionButton:SetTall( optionH )
	optionButton:SetText( "" )
	local alpha = 0
	optionButton.Paint = function( self2, w, h )
		if( self2:IsHovered() ) then
			alpha = math.Clamp( alpha+20, 0, 255 )
		else
			alpha = math.Clamp( alpha-20, 0, 255 )
        end
        
        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ) )
		draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, alpha ) )

		draw.SimpleText( label, "MontserratBold21", w/2, h/2, BOTCHED.FUNC.GetTheme( 4 ), 1, 1 )
	end
    optionButton.DoClick = function()
        onClick()

        gui.EnableScreenClicker( false )
        self:SetKeyboardInputEnabled( false )

        self.optionsPanel:AlphaTo( 0, 0.2 )
        self.optionsPanel:SizeTo( self.optionsPanel:GetWide(), 0, 0.2, 0, -1, function()
            self:Remove()
        end )
    end
end

function PANEL:Paint( w, h )
    
end

vgui.Register( "botched_popup_choice", PANEL, "DFrame" )