local PANEL = {}

function PANEL:Init()
    self:DockPadding( 0, 50, 0, 0 )

    self.backButton = vgui.Create( "DButton", self )
    self.backButton:SetSize( 40, 40 )
    self.backButton:SetPos( 10, 10 )
    self.backButton:SetText( "" )
    local alpha = 0
    local backMat = Material( "materials/botched/icons/back.png" )
    self.backButton.Paint = function( self2, w, h )
        if( self2:IsHovered() ) then
            alpha = math.Clamp( alpha+10, 150, 255 )
        else
            alpha = math.Clamp( alpha-10, 150, 255 )
        end

        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 1, alpha ) )

        BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 2 ), 8 )

        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 4, 75+(180*((alpha-150)/105)) ) )
        surface.SetMaterial( backMat )
        local iconSize = 24
        surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
    end
    self.backButton.DoClick = function()
        if( self.OnClose ) then self.OnClose() end

        self:SizeTo( 0, 0, 0.2, 0, -1, function()
            self:Remove()
        end )
    end
end

function PANEL:SetArticleTable( articleTable )
    local typeConfig = BOTCHED.CONFIG.NoticeTypes[articleTable.Type]

    local imageMat
    BOTCHED.FUNC.GetImage( articleTable.Image, function( mat ) 
        imageMat = mat
    end )

    surface.SetFont( "MontserratMedium17" )
    local typeX, typeY = surface.GetTextSize( typeConfig.Name )
    typeX, typeY = typeX+10, typeY+5

    local infoPanel = vgui.Create( "DPanel", self )
    infoPanel:Dock( TOP )
    infoPanel:DockMargin( 25, 25, 25, 0 )
    infoPanel:SetTall( 150 )
    infoPanel.Paint = function( self2, w, h )
        local imageSectionW = w*0.25
        if( imageMat ) then
            local imageH = (imageMat:Height()/imageMat:Width())*imageSectionW

            BOTCHED.FUNC.DrawRoundedMask( 8, 0, 0, imageSectionW, h, function()
                surface.SetDrawColor( 255, 255, 255 )
                surface.SetMaterial( imageMat )
                surface.DrawTexturedRect( 0, (h/2)-(imageH/2), imageSectionW, imageH )
            end )
        end

        draw.SimpleText( articleTable.Header, "MontserratBold30", imageSectionW+25, 10, BOTCHED.FUNC.GetTheme( 4 ) )

        draw.RoundedBox( 8, imageSectionW+25, 45, typeX, typeY, typeConfig.Color )
        draw.SimpleText( typeConfig.Name, "MontserratMedium17", imageSectionW+25+(typeX/2), 45+(typeY/2)-2, BOTCHED.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

        draw.SimpleText( string.upper( BOTCHED.FUNC.FormatWordTime( math.max( 0, BOTCHED.FUNC.UTCTime()-articleTable.Time ) ) .. " ago" ), "MontserratMedium20", w, h, BOTCHED.FUNC.GetTheme( 4 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )
    end

    local html = vgui.Create( "DHTML", self )
    html:Dock( FILL )
    html:DockMargin( 25, 25, 25, 25 )
    html:SetAllowLua( true )
    html:SetHTML( articleTable.HTML .. [[
        <style>
            body {
                margin: 0;
                color: white;
                font-family: Montserrat;
            }

            a {
                color: #00adb5;
            }

            a:hover {
                color: #02dee8;
            }
        </style>
    ]] )
end

function PANEL:Paint( w, h )
    BSHADOWS.BeginShadow( "popup_notices_article" )
    BSHADOWS.SetShadowSize( "popup_notices_article", w, h )
    local x, y = self:LocalToScreen( 0, 0 )
    draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 1 ) )			
    BSHADOWS.EndShadow( "popup_notices_article", x, y, 1, 2, 2, 255, 0, 0, false )

    draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ) )
end

vgui.Register( "botched_popup_notices_article", PANEL, "DPanel" )