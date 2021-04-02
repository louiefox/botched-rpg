local PANEL = {}

function PANEL:Init()
    self:SetHeader( "GEM STORE" )
    self:SetPopupWide( ScrW()*0.5 )
    self:SetExtraHeight( ScrH()*0.5 )

    local bottomButton = vgui.Create( "DButton", self )
    bottomButton:Dock( BOTTOM )
    bottomButton:DockMargin( self:GetPopupWide()*0.3, 0, self:GetPopupWide()*0.3, 25 )
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

    self.centerArea = vgui.Create( "DPanel", self )
    self.centerArea:Dock( FILL )
    self.centerArea:SetSize( self:GetPopupWide(), self.mainPanel.targetH-self.header:GetTall()-bottomButton:GetTall()-75 )
    self.centerArea.Paint = function( self, w, h ) end 

    self.scrollPanel = vgui.Create( "botched_scrollpanel", self.centerArea )
    self.scrollPanel:Dock( FILL )
    self.scrollPanel:DockMargin( 25, 25, 25, 25 )
    self.scrollPanel.screenX, self.scrollPanel.screenY = 0, 0
    self.scrollPanel.Paint = function( self2, w, h )
        self.scrollPanel.screenX, self.scrollPanel.screenY = self2:LocalToScreen( 0, 0 )
        self.scrollPanel.h = h
    end

    local gridWide = self:GetPopupWide()-50-20
    local slotsWide = math.floor( gridWide/BOTCHED.FUNC.ScreenScale( 225 ) )
    local spacing = 10
    self.slotSize = (gridWide-((slotsWide-1)*spacing))/slotsWide

    self.grid = vgui.Create( "DIconLayout", self.scrollPanel )
    self.grid:Dock( TOP )
    self.grid:SetSpaceY( spacing )
    self.grid:SetSpaceX( spacing )

    timer.Simple( 0, function() self:Refresh() end )
end

function PANEL:Refresh()
    self.grid:Clear()

    local sortedStore = {}
    for k, v in pairs( BOTCHED.CONFIG.StoreItems ) do
        table.insert( sortedStore, { v.Order or 0, k, v } )
    end

    table.SortByMember( sortedStore, 1 )

    local borderSize = 2
    for k, v in pairs( sortedStore ) do
        local itemKey, configItem = v[2], v[3]

        local itemPanel = self.grid:Add( "DPanel" )
        itemPanel:SetSize( self.slotSize, self.slotSize*1.3 )
        itemPanel:DockPadding( borderSize, borderSize+25, borderSize, borderSize )
        itemPanel.Paint = function( self2, w, h )
            local uniqueID = "gemstore_item_" .. itemKey
            BSHADOWS.BeginShadow( uniqueID, 0, self.scrollPanel.screenY, ScrW(), self.scrollPanel.screenY+self.scrollPanel.h )
            BSHADOWS.SetShadowSize( uniqueID, w, h )
            local x, y = self2:LocalToScreen( 0, 0 )
            draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 1 ) )		
            BSHADOWS.EndShadow( uniqueID, x, y, 1, 1, 2, 255, 0, 0, false )
        
            draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2 ) )
            draw.RoundedBox( 8, borderSize, borderSize, w-(2*borderSize), h-(2*borderSize), BOTCHED.FUNC.GetTheme( 1 ) )	
            
            local text = BOTCHED.FUNC.TextWrap( configItem.Name, "MontserratBold20", w-30 )
            BOTCHED.FUNC.DrawNonParsedText( text, "MontserratBold20", w/2, 10, BOTCHED.FUNC.GetTheme( 3 ), 1 )
        end

        local viewButton = vgui.Create( "DButton", itemPanel )
        viewButton:Dock( BOTTOM )
        viewButton:DockMargin( 10, 10, 10, 10 )
        viewButton:SetTall( 35 )
        viewButton:SetText( "" )
        local alpha = 0
        viewButton.Paint = function( self2, w, h )
            if( self2:IsHovered() ) then
                alpha = math.Clamp( alpha+5, 0, 75 )
            else
                alpha = math.Clamp( alpha-5, 0, 75 )
            end
            
            draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ) )
            draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 3, alpha ) )
    
            draw.SimpleText( "VIEW", "MontserratBold25", w/2, h/2-1, BOTCHED.FUNC.GetTheme( 4, 75+(180*(alpha/75)) ), 1, 1 )
        end
        viewButton.DoClick = function()
            gui.OpenURL( configItem.Link )
        end

        local pricePanel = vgui.Create( "DPanel", itemPanel )
        pricePanel:Dock( BOTTOM )
        pricePanel:DockMargin( 10, 0, 10, 0 )
        pricePanel:SetTall( 35 )
        pricePanel.Paint = function( self2, w, h )
            draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ) )

            draw.SimpleText( "Price", "MontserratBold25", 15, h/2-1, BOTCHED.FUNC.GetTheme( 4, 75 ), 0, TEXT_ALIGN_CENTER )
            draw.SimpleText( "£" .. string.Comma( configItem.Price ), "MontserratBold22", w-15, h/2-1, BOTCHED.FUNC.GetTheme( 3 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
        end

        local imageMat
        BOTCHED.FUNC.GetImage( configItem.Image or "", function( mat ) 
            imageMat = mat
        end )

        local itemIcon = vgui.Create( "DPanel", itemPanel )
        itemIcon:Dock( FILL )
        itemIcon.Paint = function( self2, w, h )
            if( imageMat ) then
                local iconSize = w*0.5
                surface.SetDrawColor( 255, 255, 255 )
                surface.SetMaterial( imageMat )
                surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
            end
        end

    end
end

vgui.Register( "botched_popup_gemstore", PANEL, "botched_popup_base" )