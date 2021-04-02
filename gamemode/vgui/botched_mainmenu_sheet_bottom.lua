local PANEL = {}

function PANEL:Init()
    self.navigationPanel = vgui.Create( "DPanel", self )
    self.navigationPanel:Dock( BOTTOM )
    self.navigationPanel:SetTall( 50 )
    self.navigationPanel.Paint = function( self, w, h ) 
        draw.RoundedBoxEx( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ), false, false, true, true )
    end 

    self.navigationContent = vgui.Create( "DPanel", self )
    self.navigationContent:Dock( FILL )
    self.navigationContent:SetSize( self:GetWide(), self:GetTall()-self.navigationPanel:GetTall() )
    self.navigationContent.Paint = function() end

    self.pages = {}
end

function PANEL:OnSizeChanged( w, h )
    self.navigationContent:SetSize( w, h-self.navigationPanel:GetTall() )
end

function PANEL:AddPage( title, iconMat, panel, id )
    panel:SetParent( self.navigationContent )
    panel:SetSize( self.navigationContent:GetSize() )

    local pageKey = #self.pages+1

    local pageButton
    if( title ) then
        surface.SetFont( "MontserratMedium20" )
        local textX, textY = surface.GetTextSize( title )

        pageButton = vgui.Create( "DButton", self.navigationPanel )
        pageButton:Dock( LEFT )
        pageButton:SetText( "" )
        pageButton.Paint = function( self2, w, h )
            self2:CreateFadeAlpha( 0.1, 150, false, false, self.activePage == pageKey, false, 0.1 )

            draw.RoundedBoxEx( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100*(self2.alpha/255) ), false, false, pageKey == 1, pageKey == #self.pages )

            BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 2 ), 8 )

            BOTCHED.FUNC.DrawPartialRoundedBoxEx( 8, 0, h-5, w, 5, BOTCHED.FUNC.GetTheme( 3, self2.alpha ), false, 16, false, h-5-11, false, false, pageKey == 1, pageKey == #self.pages )

            local textColor = BOTCHED.FUNC.GetTheme( 4, 75+(180*(self2.alpha/150)) )
            surface.SetDrawColor( textColor )
            surface.SetMaterial( iconMat )
            local iconSize = 16
            surface.DrawTexturedRect( (w/2)-(textX/2)-iconSize-5, (h/2)-(iconSize/2), iconSize, iconSize )

            draw.SimpleText( title, "MontserratMedium20", w/2, h/2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
        pageButton.DoClick = function()
            self:SetActivePage( pageKey )
        end
    end

    self.pages[pageKey] = { panel, pageButton, id }

    if( self.activePage ) then
        panel:SetVisible( false )
    else
        self.activePage = pageKey
        if( panel.FillPanel and not panel.loaded ) then 
            panel:FillPanel() 
            panel.loaded = true
        end
    end

    local totalPageButtons = 0
    for k, v in ipairs( self.pages ) do
        totalPageButtons = totalPageButtons+(IsValid( v[2] ) and 1 or 0)
    end

    for k, v in ipairs( self.pages ) do
        if( not IsValid( v[2] ) ) then continue end

        if( k == totalPageButtons ) then
            v[2]:SetWide( self:GetWide()-((totalPageButtons-1)*math.floor( self:GetWide()/totalPageButtons )) )
        else
            v[2]:SetWide( math.floor( self:GetWide()/totalPageButtons ) )
        end
    end

    return pageKey
end

function PANEL:SetActivePage( pageKey )
    self.pages[self.activePage][1]:SetVisible( false )

    local panel = self.pages[pageKey][1]
    panel:SetVisible( true )
    self.activePage = pageKey

    if( panel.FillPanel and not panel.loaded ) then 
        panel:FillPanel() 
        panel.loaded = true
    end
end

function PANEL:OpenPageByID( id )
    for k, v in ipairs( self.pages ) do
        if( (v[3] or "") == id ) then
            self:SetActivePage( k )
            break
        end
    end
end

function PANEL:Paint( w, h )

end

vgui.Register( "botched_mainmenu_sheet_bottom", PANEL, "DPanel" )