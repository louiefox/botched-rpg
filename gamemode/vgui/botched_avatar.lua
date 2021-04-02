local PANEL = {}

function PANEL:Init()
	self.avatar = vgui.Create( "AvatarImage", self )
	self.avatar:SetPaintedManually( true )
end

function PANEL:PerformLayout()
	self.avatar:SetSize( self:GetWide(), self:GetTall() )
end

function PANEL:SetPlayer( ply, size )
	self.avatar:SetPlayer( ply, size )
end

function PANEL:SetSteamID( steamID, size )
	self.avatar:SetSteamID( steamID, size )
end

function PANEL:SetRounded( cornerRadius )
	self.cornerRadius = cornerRadius
end

function PANEL:SetCircleAvatar( value )
	self.cornerRadius = nil
	self.circleAvatar = value
end

function PANEL:Paint( w, h )
	if( self.cornerRadius ) then
		BOTCHED.FUNC.DrawRoundedMask( self.cornerRadius, 0, 0, w, h, function()
			self.avatar:PaintManual()
		end )
	elseif( self.circleAvatar ) then
		render.ClearStencil()
		render.SetStencilEnable( true )
	
		render.SetStencilWriteMask( 1 )
		render.SetStencilTestMask( 1 )
	
		render.SetStencilFailOperation( STENCILOPERATION_REPLACE )
		render.SetStencilPassOperation( STENCILOPERATION_ZERO )
		render.SetStencilZFailOperation( STENCILOPERATION_ZERO )
		render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_NEVER )
		render.SetStencilReferenceValue( 1 )
	
		draw.NoTexture()
		surface.SetDrawColor( Color( 0, 0, 0, 255 ) )
		BOTCHED.FUNC.DrawCircle( w/2, h/2, h/2, w/2 )
	
		render.SetStencilFailOperation( STENCILOPERATION_ZERO )
		render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
		render.SetStencilZFailOperation( STENCILOPERATION_ZERO )
		render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
		render.SetStencilReferenceValue( 1 )
	
		self.avatar:PaintManual()
	
		render.SetStencilEnable( false )
		render.ClearStencil()
	end
end
 
vgui.Register( "botched_avatar", PANEL )