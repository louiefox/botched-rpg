local PANEL = {}

function PANEL:Init()
    self:SetSize( ScrH()*0.2, ScrH()*0.2 )

    self.mapBack = vgui.Create( "DPanel", self )
    self.mapBack:SetSize( self:GetWide(), self:GetTall() )
    self.mapBack.Paint = function( self2, w, h ) end

    self.mapMovePanel = vgui.Create( "DPanel", self.mapBack )
    self.mapMovePanel.Paint = function( self2, w, h ) end

    local folderPath = "botched/mapimages/" .. game.GetMap()

    local sections = {}
    for k, v in ipairs( file.Find( folderPath .. "/*", "DATA" ) ) do
        local mat = Material( "data/" .. folderPath .. "/" .. v )

        local startPos, endPos = string.find( v, "row" )
        local row = tonumber( string.sub( v, endPos+1, endPos+2 ) )

        local startPos, endPos = string.find( v, "column" )
        local column = tonumber( string.sub( v, endPos+1, endPos+2 ) )

        sections[row] = sections[row] or {}
        sections[row][column] = mat
    end

    self.sectionPanels = {}

    local wantedSectionW = ScrW()*0.3
    local maxWide, totalH = 0, 0
    for row, columns in ipairs( sections ) do
        self.sectionPanels[row] = {}

        local totalWide, maxTall = 0, 0
        for column, mat in ipairs( columns ) do
            local sectionW = (mat:Width()/ScrW())*wantedSectionW

            local mapSection = vgui.Create( "DPanel", self.mapMovePanel )
            mapSection:SetSize( sectionW, (mat:Height()/mat:Width())*sectionW )
            mapSection:SetPos( totalWide, totalH )
            mapSection:SetPaintedManually( true )
            mapSection.Paint = function( self2, w, h )
                surface.SetDrawColor( 255, 255, 255 )
                surface.SetMaterial( mat )
                surface.DrawTexturedRect( 0, 0, w, h )
            end

            mapSection.normalW, mapSection.normalH =  mapSection:GetSize()
            self.sectionPanels[row][column] = mapSection

            totalWide = totalWide+mapSection:GetWide()
            maxTall = math.max( maxTall, mapSection:GetTall() )
        end

        maxWide = math.max( maxWide, totalWide )
        totalH = totalH+maxTall
    end

    self.mapMovePanel:SetSize( maxWide, totalH )
    self.mapMovePanel.normalW, self.mapMovePanel.normalH = self.mapMovePanel:GetSize()

    self.playerMarker = vgui.Create( "DPanel", self.mapMovePanel )
    self.playerMarker:SetSize( 40, 40 )
    self.playerMarker:SetPaintedManually( true )
    local playerMat = Material( "materials/botched/icons/map_player.png" )
    self.playerMarker.Paint = function( self2, w, h ) 
        local iconSize = 24

        surface.SetMaterial( playerMat )

        surface.SetDrawColor( 0, 0, 0 )
        surface.DrawTexturedRectRotated( w/2+1, h/2+1, iconSize, iconSize, LocalPlayer():GetAngles().y+90 )

        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 3 ) )
        surface.DrawTexturedRectRotated( w/2, h/2, iconSize, iconSize, LocalPlayer():GetAngles().y+90 )
    end

    self:AddVectorPanel( function() return LocalPlayer():GetPos() end, self.playerMarker )

    for k, v in pairs( BOTCHED.CONFIG.Map.LocationTitles ) do
        local text, font = k, "MontserratBold20"

        surface.SetFont( font )
        local textX, textY = surface.GetTextSize( text )

        local locationMarker = vgui.Create( "DPanel", self.mapMovePanel )
        locationMarker:SetSize( textX+2, textY+2 )
        locationMarker:SetPaintedManually( true )
        locationMarker.Paint = function( self2, w, h ) 
            draw.SimpleText( text, font, w/2+1, h/2+1, BOTCHED.FUNC.GetTheme( 1 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            draw.SimpleText( text, font, w/2, h/2, BOTCHED.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
    
        self:AddVectorPanel( v, locationMarker )
    end
end

function PANEL:AddVectorPanel( vector, panel, zPos )
    panel:SetZPos( zPos or 10 )
    panel.UpdatePos = function( self2 )
        local xPos, yPos = self:GetVectorPos( isfunction( vector ) and vector() or vector )
        self2:SetPos( xPos-(self2:GetWide()/2), yPos-(self2:GetTall()/2) )
    end

    panel.Think = function( self2 )
        self2:UpdatePos()
    end

    panel:UpdatePos()
end

function PANEL:GetVectorPos( vector )
    local topLeftVec = Vector( BOTCHED.TEMP.Map.SizeW, BOTCHED.TEMP.Map.SizeN, 0 )
    local mapMoveW, mapMoveH = self.mapMovePanel:GetSize()

    local xMultiplier = (0.0665*(ScrW()/2560))
    local yMultiplier = (0.067*(ScrH()/1440))

    local xPosVec = math.abs( topLeftVec.x-vector.x )
    local yPosVec = math.abs( topLeftVec.y-vector.y )

    return math.Clamp( xPosVec*xMultiplier, 0, mapMoveW ), math.Clamp( yPosVec*yMultiplier, 0, mapMoveH )
end

function PANEL:CenterOnPos( x, y )
    self.mapMovePanel:SetPos( math.Clamp( -x+(self:GetWide()/2), self.mapBack:GetWide()-self.mapMovePanel:GetWide(), 0 ), math.Clamp( -y+(self.mapBack:GetTall()/2), self.mapBack:GetTall()-self.mapMovePanel:GetTall(), 0 ) )
end

function PANEL:CenterOnPanel( panel )
    local x, y = panel:GetPos()
    x = x+(panel:GetWide()/2)
    y = y+(panel:GetTall()/2)

    self:CenterOnPos( x, y )
end

function PANEL:Think()
    if( IsValid( self.playerMarker ) ) then
        self:CenterOnPanel( self.playerMarker )
    end
end

local blankColor = Color( 255, 255, 255 )
function PANEL:Paint( w, h )
    BSHADOWS.BeginShadow( "hud_map_menu" )
    BSHADOWS.SetShadowSize( "hud_map_menu", w, h )
    local x, y = self:LocalToScreen( 0, 0 )
    BOTCHED.FUNC.DrawCircle( x+w/2, y+h/2, h/2, BOTCHED.FUNC.GetTheme( 1 ) )		
    BSHADOWS.EndShadow( "hud_map_menu", x, y, 1, 2, 2, 255, 0, 0, false )

    BOTCHED.FUNC.DrawCircle( w/2, h/2, h/2, BOTCHED.FUNC.GetTheme( 2, 100 ) )	

    render.ClearStencil()
    render.SetStencilEnable( true )

    render.SetStencilWriteMask( 1 )
    render.SetStencilTestMask( 1 )

    render.SetStencilFailOperation( STENCILOPERATION_REPLACE )
    render.SetStencilPassOperation( STENCILOPERATION_ZERO )
    render.SetStencilZFailOperation( STENCILOPERATION_ZERO )
    render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_NEVER )
    render.SetStencilReferenceValue( 1 )

    BOTCHED.FUNC.DrawCircle( w/2, h/2, h/2-3, blankColor )

    render.SetStencilFailOperation( STENCILOPERATION_ZERO )
    render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
    render.SetStencilZFailOperation( STENCILOPERATION_ZERO )
    render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
    render.SetStencilReferenceValue( 1 )

    for k, v in ipairs( self.mapMovePanel:GetChildren() ) do
        v:PaintManual()
    end

    render.SetStencilEnable( false )
    render.ClearStencil()
end

vgui.Register( "botched_hud_map", PANEL, "DPanel" )