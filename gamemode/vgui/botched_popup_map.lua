local PANEL = {}

function PANEL:Init()
    self:SetTall( ScrH()*0.5 )
    
    gui.EnableScreenClicker( true )
    self.activePage = ""

    local rightArea = vgui.Create( "DPanel", self )
    rightArea:Dock( RIGHT )
    rightArea:SetSize( ScrW()*0.15, self:GetTall() )
    rightArea:SetZPos( 100 )
    rightArea.Paint = function( self2, w, h ) 
        local x, y = self2:LocalToScreen( 0, 0 )

        BSHADOWS.BeginShadow( "map_menu_sidepanel" )
        BSHADOWS.SetShadowSize( "map_menu_sidepanel", w, h-4 )
        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 1 ) )
        draw.RoundedBoxEx( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 1 ), false, true, false, true )
        BSHADOWS.EndShadow( "map_menu_sidepanel", x, y, 1, 2, 2, 255, 0, -5, true )

        draw.RoundedBoxEx( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 1 ), false, true, false, true )
        draw.RoundedBoxEx( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 35 ), false, true, false, true )

        draw.SimpleText( "WORLD MAP", "MontserratBold30", w/2, 25, BOTCHED.FUNC.GetTheme( 3 ), TEXT_ALIGN_CENTER, 0 )
    end

    local settingsButton = vgui.Create( "DButton", rightArea )
    settingsButton:SetSize( 40, 40 )
    settingsButton:SetPos( rightArea:GetWide()-settingsButton:GetWide()-10, rightArea:GetTall()-settingsButton:GetWide()-10 )
    settingsButton:SetZPos( 100 )
    settingsButton:SetText( "" )
    local iconMat = Material( "materials/botched/icons/settings.png" )
    settingsButton.Paint = function( self2, w, h )
        self2:CreateFadeAlpha( false, 100 )

        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 1 ) )
        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100+self2.alpha ) )

        BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 2 ), 8 )

        local iconSize = 24
        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 4, 75+((self2.alpha/100)*180) ) )
        surface.SetMaterial( iconMat )
        surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
    end
    settingsButton.DoClick = function()
        BOTCHED.FUNC.DermaQuery( "Do you want to rebuild the map? It can cause lag.", "REBUILD MAP", "Yes", function() 
            if( IsValid( BOTCHED_MAPMENU ) ) then
                BOTCHED_MAPMENU:Remove()
            end
            
            net.Start( "Botched.RequestMapSize" )
            net.SendToServer()
        end, "No" )
    end

    self.rightContent = vgui.Create( "DPanel", rightArea )
    self.rightContent:Dock( FILL )
    self.rightContent.Paint = function( self2, w, h ) end

    self.mapBack = vgui.Create( "DPanel", self )
    self.mapBack:SetSize( ScrW()*0.4, self:GetTall() )
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

    local mapMoveButton = vgui.Create( "DButton", self.mapMovePanel )
    mapMoveButton:Dock( FILL )
    mapMoveButton:SetText( "" )
    mapMoveButton:SetZPos( 100 )
    mapMoveButton.Paint = function( self2, w, h ) end
    mapMoveButton.Think = function( self2 )
        if( self2:IsDown() ) then
            local cursorX, cursorY = input.GetCursorPos()
            if( not self2.startClickPanelX or not self2.startClickX or not self2.startClickPanelY or not self2.startClickY ) then
                self2.startClickPanelX, self2.startClickPanelY = self.mapMovePanel:GetPos()
                self2.startClickX, self2.startClickY = cursorX, cursorY
            end

            self.mapMovePanel:SetPos( math.Clamp( self2.startClickPanelX+cursorX-self2.startClickX, self.mapBack:GetWide()-self.mapMovePanel:GetWide(), 0 ), math.Clamp( self2.startClickPanelY+cursorY-self2.startClickY, self.mapBack:GetTall()-self.mapMovePanel:GetTall(), 0 ) )
        elseif( self2.startClickX ) then
            self2.startClickPanelX, self2.startClickPanelY = nil, nil
            self2.startClickX, self2.startClickY = nil, nil
        end
    end
    mapMoveButton.OnMouseWheeled = function( self2, scrollDelta )
        if( scrollDelta == 1 ) then
            self:SetScale( math.ceil( (self:GetScale()+0.1)*10 )/10 )
        else
            self:SetScale( math.floor( (self:GetScale()-0.1)*10 )/10 )
        end
    end

    local mapScalePanel = vgui.Create( "DButton", self.mapBack )
    mapScalePanel:SetSize( 100, 40 )
    mapScalePanel:SetPos( (self.mapBack:GetWide()/2)-(mapScalePanel:GetWide()/2), 25 )
    mapScalePanel:SetZPos( 200 )
    mapScalePanel:SetText( "" )
    mapScalePanel.Paint = function( self2, w, h )
        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 1, 200 ) )

        draw.SimpleText( math.Round( self:GetScale()*100 ) .. "%", "MontserratBold30", w/2+1, h/2+1, BOTCHED.FUNC.GetTheme(1 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        draw.SimpleText( math.Round( self:GetScale()*100 ) .. "%", "MontserratBold30", w/2, h/2, BOTCHED.FUNC.GetTheme( 3 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
    mapScalePanel.DoClick = function()
        self:SetScale( math.ceil( (self:GetScale()+0.1)*10 )/10 )
    end

    self:SetWide( self.mapBack:GetWide()+rightArea:GetWide() )
    self:Center()

    local playerMarker = vgui.Create( "DPanel", self.mapMovePanel )
    playerMarker:SetSize( 40, 40 )
    playerMarker:SetPaintedManually( true )
    local playerMat = Material( "materials/botched/icons/map_player.png" )
    playerMarker.Paint = function( self2, w, h ) 
        local iconSize = 24

        surface.SetMaterial( playerMat )

        surface.SetDrawColor( 0, 0, 0 )
        surface.DrawTexturedRectRotated( w/2+1, h/2+1, iconSize, iconSize, LocalPlayer():GetAngles().y+90 )

        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 3 ) )
        surface.DrawTexturedRectRotated( w/2, h/2, iconSize, iconSize, LocalPlayer():GetAngles().y+90 )
    end

    self:AddVectorPanel( function() return LocalPlayer():GetPos() end, playerMarker )
    self:CenterOnPanel( playerMarker )

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

    local teleportMat = Material( "materials/botched/icons/teleport_marker.png" )
    local iconSize = 24
    for k, v in ipairs( BOTCHED.CONFIG.Map.Teleports ) do
        local teleportMarker = vgui.Create( "DButton", self.mapMovePanel )
        teleportMarker:SetSize( iconSize+2, iconSize+2 )
        teleportMarker:SetText( "" )
        teleportMarker:SetPaintedManually( true )
        teleportMarker.Paint = function( self2, w, h ) 
            self2:CreateFadeAlpha( nil, 155, nil, nil, (self.activePage == "teleport_" .. k), 155 )

            surface.SetMaterial( teleportMat )

            surface.SetDrawColor( 0, 0, 0 )
            surface.DrawTexturedRect( (w/2)-(iconSize/2)+1, (h/2)-(iconSize/2)+1, iconSize, iconSize )
    
            surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 2 ) )
            surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )

            surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 4, 100+self2.alpha ) )
            surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
        end
        teleportMarker.DoClick = function()
            self:OpenSidePage( "teleport_" .. k, function( parent )
                local teleportButton = vgui.Create( "DButton", parent )
                teleportButton:Dock( BOTTOM )
                teleportButton:SetTall( 40 )
                teleportButton:DockMargin( 10, 0, 60, 10 )
                teleportButton:SetText( "" )
                teleportButton.Paint = function( self2, w, h )
                    self2:CreateFadeAlpha( false, 100 )

                    draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 1 ) )
                    draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100+self2.alpha ) )
            
                    BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 2 ), 8 )
            
                    local iconSize = 24
                    surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 4, 75+((self2.alpha/100)*180) ) )
                    surface.SetMaterial( teleportMat )
                    surface.DrawTexturedRect( (h/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
        
                    draw.SimpleText( "TELEPORT", "MontserratBold25", w/2, h/2-1, BOTCHED.FUNC.GetTheme( 4, 75+((self2.alpha/100)*180) ), 1, 1 )
                end
                teleportButton.DoClick = function()
                    BOTCHED.FUNC.DermaQuery( "Are you sure you want to teleport here?", "TELEPORT", "Yes", function() 
                        net.Start( "Botched.RequestMapTeleport" )
                            net.WriteUInt( k, 4 )
                        net.SendToServer()
                    end, "No" )
                end

                local teleportInfo = vgui.Create( "DPanel", parent )
                teleportInfo:Dock( BOTTOM )
                teleportInfo:SetTall( ScrH()*0.1 )
                teleportInfo:DockMargin( 10, 0, 10, 10 )
                teleportInfo:SetText( "" )
                teleportInfo.Paint = function( self2, w, h )
                    draw.SimpleText( "TELEPORT", "MontserratBold30", w/2, h/2+5, BOTCHED.FUNC.GetTheme( 3 ), 1, TEXT_ALIGN_BOTTOM )
                    draw.SimpleText( string.upper( v.Title ), "MontserratBold40", w/2, h/2-5, BOTCHED.FUNC.GetTheme( 4, 75 ), 1, 0 )
                end
            end )
        end
    
        self:AddVectorPanel( v.Pos, teleportMarker, 200 )
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

    local mapScale = self:GetScale()
    local xMultiplier = (0.0665*(ScrW()/2560))*mapScale
    local yMultiplier = (0.067*(ScrH()/1440))*mapScale

    local xPosVec = math.abs( topLeftVec.x-vector.x )
    local yPosVec = math.abs( topLeftVec.y-vector.y )

    return math.Clamp( xPosVec*xMultiplier, 0, mapMoveW ), math.Clamp( yPosVec*yMultiplier, 0, mapMoveH )
end

function PANEL:CenterOnPos( x, y )
    self.mapMovePanel:SetPos( math.Clamp( -x+(self.mapBack:GetWide()/2), self.mapBack:GetWide()-self.mapMovePanel:GetWide(), 0 ), math.Clamp( -y+(self.mapBack:GetTall()/2), self.mapBack:GetTall()-self.mapMovePanel:GetTall(), 0 ) )
end

function PANEL:CenterOnPanel( panel )
    local x, y = panel:GetPos()
    x = x+(panel:GetWide()/2)
    y = y+(panel:GetTall()/2)

    self:CenterOnPos( x, y )
end

function PANEL:SetScale( scale )
    local oldScale = self:GetScale()
    scale = math.Clamp( scale, math.max( self.mapBack:GetWide()/self.mapMovePanel.normalW, self.mapBack:GetTall()/self.mapMovePanel.normalH ), 2 )

    local oldX, oldY = self.mapMovePanel:GetPos()
    local centerX, centerY = math.abs( oldX )+(self.mapBack:GetWide()/2), math.abs( oldY )+(self.mapBack:GetTall()/2)
    
    local maxWide, totalH = 0, 0
    for row, columns in ipairs( self.sectionPanels ) do
        local totalWide, maxTall = 0, 0
        for column, panel in ipairs( columns ) do
            panel:SetSize( panel.normalW*scale, panel.normalH*scale )
            panel:SetPos( totalWide, totalH )

            totalWide = totalWide+panel:GetWide()
            maxTall = math.max( maxTall, panel:GetTall() )
        end

        maxWide = math.max( maxWide, totalWide )
        totalH = totalH+maxTall
    end

    self.mapMovePanel:SetSize( maxWide, totalH )
    self:CenterOnPos( (centerX/oldScale)*scale, (centerY/oldScale)*scale )
end

function PANEL:GetScale()
    local firstSection = self:GetFirstSection()
    if( not IsValid( firstSection ) or not firstSection.normalW ) then
        return 1
    end

    return firstSection:GetWide()/firstSection.normalW
end

function PANEL:GetFirstSection()
    if( not self.sectionPanels or not self.sectionPanels[1] or not self.sectionPanels[1][1] ) then return end

    return self.sectionPanels[1][1]
end

function PANEL:OpenSidePage( pageKey, panelFunc )
    self.activePage = pageKey

    self.rightContent:Clear()
    panelFunc( self.rightContent )
end

function PANEL:OnRemove()
    gui.EnableScreenClicker( false )
end

function PANEL:Paint( w, h )
    BSHADOWS.BeginShadow( "popup_map_menu" )
    BSHADOWS.SetShadowSize( "popup_map_menu", w, h )
    local x, y = self:LocalToScreen( 0, 0 )
    draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 1 ) )			
    BSHADOWS.EndShadow( "popup_map_menu", x, y, 1, 2, 2, 255, 0, 0, false )

    BOTCHED.FUNC.DrawRoundedMask( 8, 0, 0, w, h, function()
        for k, v in ipairs( self.mapMovePanel:GetChildren() ) do
            v:PaintManual()
        end
    end )
end

vgui.Register( "botched_popup_map", PANEL, "DPanel" )