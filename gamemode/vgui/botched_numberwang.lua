
local PANEL = {}

function PANEL:Init()
	self:SetRoundedCorners( true, true, true, true )
	self:SetCornerRadius( 8 )
	self:SetBackColor( BOTCHED.FUNC.GetTheme( 2, 100 ) )
	self:SetHighlightColor( BOTCHED.FUNC.GetTheme( 2 ) )

	self.numberWang = vgui.Create( "DNumberWang", self )
	self.numberWang:Dock( FILL )
	self.numberWang:DockMargin( 10, 0, 0, 0 )
	self.numberWang:SetFont( "MontserratMedium25" )
	self.numberWang:SetText( "" )
	self.numberWang:SetTextColor( Color( 255, 255, 255, 20 ) )
	self.numberWang:SetCursorColor( Color( 255, 255, 255 ) )
	self.numberWang:SetMinMax( 0, 99999999 )
	self.numberWang.Paint = function( self2, w, h ) 
		if( self2:GetTextColor().a != 255 or self2:GetTextColor().a != 20 ) then
			self2:SetTextColor( Color( 255, 255, 255, (self.alpha or 20) ) )
		end

		if( self2.GetPlaceholderText && self2.GetPlaceholderColor && self2:GetPlaceholderText() && self2:GetPlaceholderText():Trim() != "" && self2:GetPlaceholderColor() && ( !self2:GetText() || self2:GetText() == "" ) ) then
			local oldText = self2:GetText()
	
			local str = self2:GetPlaceholderText()
			if ( str:StartWith( "#" ) ) then str = str:sub( 2 ) end
			str = language.GetPhrase( str )
	
			self2:SetText( str )
			self2:DrawTextEntryText( self2:GetPlaceholderColor(), self2:GetHighlightColor(), self2:GetCursorColor() )
			self2:SetText( oldText )
	
			return
		end
	
		self2:DrawTextEntryText( self2:GetTextColor(), self2:GetHighlightColor(), self2:GetCursorColor() )
	
		if( not self2:IsEditing() and self2:GetText() == "" ) then
			draw.SimpleText( self2.backText or "", self2:GetFont(), 0, h/2, (self2.backTextColor or Color( 255, 255, 255, 20 )), 0, TEXT_ALIGN_CENTER )
		end
	end
	self.numberWang.OnChange = function()
        if( self.OnChange ) then
            self.OnChange()
        end
    end
    self.numberWang.OnEnter = function()
        if( self.OnEnter ) then
            self.OnEnter()
        end
    end
end

function PANEL:SetMinMax( min, max )
    self.numberWang:SetMinMax( min, max )
end

function PANEL:SetValue( val )
    self.numberWang:SetValue( val )
end

function PANEL:GetValue()
    return self.numberWang:GetValue()
end

function PANEL:SetBackColor( color )
    self.backColor = color
end

function PANEL:SetHighlightColor( color )
    self.highlightColor = color
end

function PANEL:SetCornerRadius( cornerRadius )
    self.cornerRadius = cornerRadius
end

function PANEL:SetRoundedCorners( roundTopLeft, roundTopRight, roundBottomLeft, roundBottomRight )
    self.roundTopLeft, self.roundTopRight, self.roundBottomLeft, self.roundBottomRight = roundTopLeft, roundTopRight, roundBottomLeft, roundBottomRight
end

function PANEL:Paint( w, h )
	if( self.numberWang:IsEditing() ) then
		self.alpha = math.Clamp( (self.alpha or 20)+10, 20, 255 )
	else
		self.alpha = math.Clamp( (self.alpha or 20)-10, 20, 255 )
	end

	draw.RoundedBoxEx( self.cornerRadius, 0, 0, w, h, self.backColor, self.roundTopLeft, self.roundTopRight, self.roundBottomLeft, self.roundBottomRight )
    
    surface.SetAlphaMultiplier( (((self.alpha or 20)-20)/235)*0.5 )
    draw.RoundedBoxEx( self.cornerRadius, 0, 0, w, h, self.highlightColor, self.roundTopLeft, self.roundTopRight, self.roundBottomLeft, self.roundBottomRight )
	surface.SetAlphaMultiplier( 1 )
end

vgui.Register( "botched_numberwang", PANEL, "DPanel" )