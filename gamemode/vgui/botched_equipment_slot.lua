local PANEL = {}

function PANEL:Init()
    self.borderSize = 3
end

function PANEL:SetItemInfo( name, model, stars, rank, doClick, isCharacter )
    self.uniqueID = name

    if( model and (string.EndsWith( model, ".png" ) or string.EndsWith( model, ".jpg" )) ) then
        self.iconMat = Material( model )
    end

    self.hoverDraw = vgui.Create( "DPanel", self )
    self.hoverDraw:SetSize( self:GetSize() )
    local alpha = 0
    self.hoverDraw.Paint = function( self2, w, h ) 
        if( not IsValid( self.info ) ) then return end

        if( self.info:IsHovered() ) then
            alpha = math.Clamp( alpha+10, 0, 50 )
        else
            alpha = math.Clamp( alpha-10, 0, 50 )
        end

        draw.RoundedBox( 8, self.borderSize, self.borderSize, w-(2*self.borderSize), h-(2*self.borderSize), BOTCHED.FUNC.GetTheme( 2, alpha ) )
        BOTCHED.FUNC.DrawClickCircle( self.info, w-(2*self.borderSize), h-(2*self.borderSize), BOTCHED.FUNC.GetTheme( 2, 150 ), 8 )
    end

    if( model and string.EndsWith( model, ".mdl" ) ) then
        self.model = vgui.Create( "DModelPanel", self )
        self.model:Dock( FILL )
        self.model:DockMargin( self.borderSize, self.borderSize, self.borderSize, self.borderSize )
        self.model.Load = function()
            if( not IsValid( self ) ) then return end
            
            self.model:SetModel( model )
            self.model.LayoutEntity = function() end
    
            if( IsValid( self.model.Entity ) ) then
                if( not isCharacter ) then
                    local mn, mx = self.model.Entity:GetRenderBounds()
                    local size = 0
                    size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
                    size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
                    size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )
    
                    self.model:SetFOV( 50 )
                    self.model:SetCamPos( Vector( size, size, size ) )
                    self.model:SetLookAt( (mn + mx) * 0.5 )
                else
                    local bone = self.model.Entity:LookupBone( "ValveBiped.Bip01_Head1" )
                    if( bone ) then
                        local headpos = self.model.Entity:GetBonePosition( bone )
                        self.model:SetLookAt( headpos )
                        self.model:SetCamPos( headpos-Vector( -35, 0, 0 ) )
                    end
                end
            end

            BOTCHED.TEMP.ModelsLoaded[model] = true
        end

        if( not BOTCHED.TEMP.ModelsLoaded[model] ) then
            BOTCHED.FUNC.AddSlotToLoad( self, self.model.Load )
        else
            self.model.Load()
        end
    end

    self.info = vgui.Create( "DButton", self )
    self.info:SetSize( self:GetSize() )
    self.info:SetText( "" )
    local starMat = Material( "materials/botched/icons/star_16.png" )
    self.info.Paint = function( self2, w, h ) 
        local textY = 30
        if( not self.disableText ) then
            if( name ) then draw.SimpleText( name, "MontserratBold22", w/2, textY+1, BOTCHED.FUNC.GetTheme( 3 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )	end
            if( rank ) then draw.SimpleText( "Rank " .. rank, "MontserratMedium17", w/2, textY-1, BOTCHED.FUNC.GetTheme( 4, 75 ), TEXT_ALIGN_CENTER, 0 ) end
        end

        if( self.topRightText ) then draw.SimpleText( self.topRightText, "MontserratMedium20", w-10, 5, BOTCHED.FUNC.GetTheme( 4, 75 ), TEXT_ALIGN_RIGHT ) end
        if( self.topLeftText ) then draw.SimpleText( self.topLeftText, "MontserratMedium20", 10, 5, BOTCHED.FUNC.GetTheme( 4, 75 ) ) end

        if( not stars or stars < 1 ) then return end

        local iconSize, starSpacing = 16, 2
        surface.SetMaterial( starMat )

        local starTotalW = (stars*(iconSize+starSpacing))-starSpacing

        if( self.shadowStartX ) then
            render.SetScissorRect( self.shadowStartX, self.shadowStartY, self.shadowEndX, self.shadowEndY, true )
        end

        DisableClipping( true )
        for i = 1, stars do
            local starXPos, starYPos = ((w/2)-(starTotalW/2))+((i-1)*(iconSize+starSpacing)), h-(iconSize/2)-2
            surface.SetDrawColor( 0, 0, 0 )
            surface.DrawTexturedRect( starXPos, starYPos, iconSize, iconSize )

            surface.SetDrawColor( 255, 255, 255 )
            surface.DrawTexturedRect( starXPos-1, starYPos-1, iconSize, iconSize )
        end
        DisableClipping( false )

        if( self.shadowStartX ) then
            render.SetScissorRect( 0, 0, 0, 0, false )
        end
    end
    if( doClick ) then self.info.DoClick = doClick end
end

function PANEL:SetShadowScissor( x, y, w, h )
    self.shadowStartX, self.shadowStartY, self.shadowEndX, self.shadowEndY = x, y, w, h
end

function PANEL:DisableText( bool )
    self.disableText = bool
end

function PANEL:SetBorderSize( borderSize )
    self.borderSize = borderSize
end

function PANEL:SetModelColor( color )
    self.model:SetColor( color )
end

function PANEL:SetBorder( border )
    if( not border ) then return end

    self.border = border
end

function PANEL:AddTopRightText( text )
    self.topRightText = text
end

function PANEL:AddTopLeftText( text )
    self.topLeftText = text
end

function PANEL:Paint( w, h )
    if( not self.uniqueID ) then return end

    BSHADOWS.BeginShadow( self.uniqueID, self.shadowStartX, self.shadowStartY, self.shadowEndX, self.shadowEndY )
    BSHADOWS.SetShadowSize( self.uniqueID, w, h )
    local x, y = self:LocalToScreen( 0, 0 )
    draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 2 ) )		
    BSHADOWS.EndShadow( self.uniqueID, x, y, 1, 1, 2, 255, 0, 0, false )

    if( self.border ) then
        BOTCHED.FUNC.DrawRoundedMask( 8, 0, 0, w, h, function()
            BOTCHED.FUNC.DrawGradientBox( 0, 0, w, h, 1, unpack( self.border.Colors ) )
        end )
    end

    draw.RoundedBox( 8, self.borderSize, self.borderSize, w-(2*self.borderSize), h-(2*self.borderSize), BOTCHED.FUNC.GetTheme( 1 ) )	
    
    if( self.iconMat ) then
        local iconSize = w*0.5
        surface.SetDrawColor( 255, 255, 255 )
        surface.SetMaterial( self.iconMat )
        surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
    end
end

vgui.Register( "botched_equipment_slot", PANEL, "DPanel" )