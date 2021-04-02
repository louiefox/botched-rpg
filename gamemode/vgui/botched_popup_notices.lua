local PANEL = {}

function PANEL:Init()
    self:SetHeader( "NOTICES" )
    self:SetPopupWide( ScrW()*0.6 )
    self:SetExtraHeight( ScrH()*0.6 )
    self.navWide = self:GetPopupWide()-50

    local bottomButton = vgui.Create( "DButton", self )
    bottomButton:Dock( BOTTOM )
    bottomButton:DockMargin( self:GetPopupWide()*0.3, 25, self:GetPopupWide()*0.3, 25 )
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
    self.centerArea:DockMargin( 25, 0, 25, 0 )
    self.centerArea:SetSize( self:GetPopupWide()-50, self.mainPanel.targetH-self.header:GetTall()-bottomButton:GetTall()-75 )
    self.centerArea.Paint = function( self, w, h ) end 

    self.mainSection = vgui.Create( "DPanel", self.centerArea )
    self.mainSection:Dock( FILL )
    self.mainSection.Paint = function( self, w, h ) end 

    self.navigationPanel = vgui.Create( "DPanel", self.mainSection )
    self.navigationPanel:Dock( TOP )
    self.navigationPanel:SetTall( 50 )
    self.navigationPanel.Paint = function( self, w, h ) 
        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ) )
    end 

    self.navigationContent = vgui.Create( "DPanel", self.mainSection )
    self.navigationContent:Dock( FILL )
    self.navigationContent:DockMargin( 0, 25, 0, 0 )
    self.navigationContent:SetSize( self:GetPopupWide()-50, self.mainPanel.targetH-self.header:GetTall()-self.navigationPanel:GetTall()-bottomButton:GetTall()-75 )
    self.navigationContent.Paint = function() end

    self.pages = {}

    local function CreateNotice( parent, k, v )
        local typeConfig = BOTCHED.CONFIG.NoticeTypes[v.Type]

        local imageMat
        BOTCHED.FUNC.GetImage( v.Image, function( mat ) 
            imageMat = mat
        end )

        surface.SetFont( "MontserratMedium17" )
        local typeX, typeY = surface.GetTextSize( typeConfig.Name )
        typeX, typeY = typeX+10, typeY+5

        local noticeEntry = vgui.Create( "DButton", parent )
        noticeEntry:Dock( TOP )
        noticeEntry:DockMargin( 0, 0, 25, 10 )
        noticeEntry:SetTall( 150 )
        noticeEntry:SetText( "" )
        local alpha = 0
        local circleAlpha, circleAlphaIncreasing = 0, true
        noticeEntry.Paint = function( self2, w, h )
            if( self2:IsHovered() ) then
                alpha = math.Clamp( alpha+5, 0, 75 )
            else
                alpha = math.Clamp( alpha-5, 0, 75 )
            end

            BSHADOWS.BeginShadow( "notice_latest_" .. k, 0, parent.screenY-10, ScrW(), parent.screenY+parent:GetTall() )
            local x, y = self2:LocalToScreen( 0, 0 )
            draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 1 ) )		
            BSHADOWS.EndShadow( "notice_latest_" .. k, x, y, 1, 1, 2, 255, 0, 0, false )

            draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ) )

            local imageSectionW = w*0.25
            if( imageMat ) then
                local imageH = (imageMat:Height()/imageMat:Width())*imageSectionW

                BOTCHED.FUNC.DrawRoundedExMask( 8, 0, 0, imageSectionW, h, function()
                    surface.SetDrawColor( 255, 255, 255 )
                    surface.SetMaterial( imageMat )
                    surface.DrawTexturedRect( 0, (h/2)-(imageH/2), imageSectionW, imageH )
                end, true, false, true, false )
            end

            draw.SimpleText( v.Header, "MontserratBold30", imageSectionW+25, 10, BOTCHED.FUNC.GetTheme( 4 ) )

            draw.RoundedBox( 8, imageSectionW+25, 45, typeX, typeY, typeConfig.Color )
            draw.SimpleText( typeConfig.Name, "MontserratMedium17", imageSectionW+25+(typeX/2), 45+(typeY/2)-2, BOTCHED.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

            draw.SimpleText( string.upper( BOTCHED.FUNC.FormatWordTime( math.max( 0, BOTCHED.FUNC.UTCTime()-v.Time ) ) .. " ago" ), "MontserratMedium20", w-10, h-10, BOTCHED.FUNC.GetTheme( 4 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )

            if( cookie.GetNumber( "BOTCHED.Cookie.NoticeRead_" .. v.Time, 0 ) != 1 ) then
                local radius = 8
                BOTCHED.FUNC.DrawCircle( w-radius-10, 10+radius, radius, BOTCHED.CONFIG.Themes.Red )

                if( circleAlphaIncreasing ) then
                    circleAlpha = math.Clamp( circleAlpha+2, 0, 255 )
                    if( circleAlpha == 255 ) then circleAlphaIncreasing = false end
                else
                    circleAlpha = math.Clamp( circleAlpha-2, 0, 255 )
                    if( circleAlpha == 0 ) then circleAlphaIncreasing = true end
                end

                BOTCHED.FUNC.DrawCircle( w-radius-10, 10+radius, radius, Color( BOTCHED.CONFIG.Themes.DarkRed.r, BOTCHED.CONFIG.Themes.DarkRed.g, BOTCHED.CONFIG.Themes.DarkRed.b, circleAlpha ) )
            end

            draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, alpha ) )
            BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 2, 50 ), 8 )
        end
        noticeEntry.DoClick = function()
            if( IsValid( self.noticePopout ) ) then return end

            local mainW, mainH = self.centerArea:GetSize()
            self.mainSection:AlphaTo( 0, 0.2 )

            self.noticePopout = vgui.Create( "botched_popup_notices_article", self.centerArea )
            self.noticePopout:SetSize( 0, 0 )
            self.noticePopout:SizeTo( mainW, mainH, 0.2 )
            self.noticePopout.OnSizeChanged = function( self2, w, h )
                self.noticePopout:SetPos( (mainW/2)-(w/2), (mainH/2)-(h/2) )
            end
            self.noticePopout.OnClose = function()
                self.mainSection:AlphaTo( 255, 0.2 )
            end
            self.noticePopout:SetArticleTable( BOTCHED.CONFIG.Notices[k] )

            if( cookie.GetNumber( "BOTCHED.Cookie.NoticeRead_" .. v.Time, 0 ) != 1 ) then
                cookie.Set( "BOTCHED.Cookie.NoticeRead_" .. v.Time, 1 )
            end
        end
    end

    local latestPage = vgui.Create( "botched_scrollpanel" )
    latestPage:Dock( FILL )
    latestPage.screenX, latestPage.screenY = 0, 0
    latestPage.Paint = function( self2, w, h ) self2.screenX, self2.screenY = self2:LocalToScreen( 0, 0 ) end
    latestPage.Refresh = function()
        latestPage:Clear()

        for k, v in ipairs( BOTCHED.CONFIG.Notices ) do
            CreateNotice( latestPage, k, v )
        end
    end
    timer.Simple( 0, function() latestPage.Refresh() end )
    self:AddPage( "Latest", latestPage )

    local eventsPage = vgui.Create( "botched_scrollpanel" )
    eventsPage:Dock( FILL )
    eventsPage.screenX, eventsPage.screenY = 0, 0
    eventsPage.Paint = function( self2, w, h ) self2.screenX, self2.screenY = self2:LocalToScreen( 0, 0 ) end
    eventsPage.Refresh = function()
        eventsPage:Clear()

        for k, v in ipairs( BOTCHED.CONFIG.Notices ) do
            if( v.Type != 3 ) then continue end
            CreateNotice( eventsPage, k, v )
        end
    end
    timer.Simple( 0, function() eventsPage.Refresh() end )
    self:AddPage( "Events", eventsPage )

    local issuesPage = vgui.Create( "botched_scrollpanel" )
    issuesPage:Dock( FILL )
    issuesPage.screenX, issuesPage.screenY = 0, 0
    issuesPage.Paint = function( self2, w, h ) self2.screenX, self2.screenY = self2:LocalToScreen( 0, 0 ) end
    issuesPage.Refresh = function()
        issuesPage:Clear()

        for k, v in ipairs( BOTCHED.CONFIG.Notices ) do
            if( v.Type != 5 ) then continue end
            CreateNotice( issuesPage, k, v )
        end
    end
    timer.Simple( 0, function() issuesPage.Refresh() end )
    self:AddPage( "Issues", issuesPage )
end

function PANEL:OnClose()
    if( IsValid( self.noticePopout ) ) then
        self.noticePopout:Remove()
    end
end

function PANEL:AddPage( title, panel )
    panel:SetParent( self.navigationContent )
    panel:SetSize( self.navigationContent:GetSize() )

    local pageKey = #self.pages+1

    local pageButton = vgui.Create( "DButton", self.navigationPanel )
    pageButton:Dock( LEFT )
    pageButton:SetText( "" )
    local alpha = 0
    pageButton.Paint = function( self2, w, h )
        if( self.activePage == pageKey ) then
            alpha = math.Clamp( alpha+10, 0, 255 )
        elseif( self2:IsHovered() ) then
            alpha = math.Clamp( alpha+10, 0, 150 )
        else
            alpha = math.Clamp( alpha-10, 0, 255 )
        end

        draw.RoundedBoxEx( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100*(alpha/255) ), pageKey == 1, pageKey == #self.pages, pageKey == 1, pageKey == #self.pages )

        BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 2 ), 8 )

        BOTCHED.FUNC.DrawPartialRoundedBoxEx( 8, 0, h-5, w, 5, BOTCHED.FUNC.GetTheme( 3, alpha ), false, 16, false, h-5-11, pageKey == 1, pageKey == #self.pages, pageKey == 1, pageKey == #self.pages )

        draw.SimpleText( title, "MontserratMedium20", w/2, h/2, BOTCHED.FUNC.GetTheme( 4, 75+(180*(alpha/150)) ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
    pageButton.DoClick = function()
        self:SetActivePage( pageKey )
    end

    self.pages[pageKey] = { panel, pageButton }

    if( self.activePage ) then
        panel:SetVisible( false )
    else
        self.activePage = pageKey
        if( panel.FillPanel and not panel.loaded ) then 
            panel:FillPanel() 
            panel.loaded = true
        end
    end

    for k, v in ipairs( self.pages ) do
        if( k == #self.pages ) then
            v[2]:SetWide( self.navWide-((#self.pages-1)*math.floor( self.navWide/#self.pages )) )
        else
            v[2]:SetWide( math.floor( self.navWide/#self.pages ) )
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

vgui.Register( "botched_popup_notices", PANEL, "botched_popup_base" )