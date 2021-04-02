local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel()
    local ply = LocalPlayer()

    local infoPanel = vgui.Create( "DPanel", self )
    infoPanel:SetSize( ScrW()*0.175, 90 )
    infoPanel:SetPos( 25, 25 )
    infoPanel.mainBodyH = infoPanel:GetTall()*0.75
    infoPanel.Paint = function( self2, w, h )
        BSHADOWS.BeginShadow( "home_screen_info" )
        local x, y = self2:LocalToScreen( 0, 0 )
        draw.RoundedBoxEx( 8, x+h/2, y+(h/2), w-(h/2)-10, self2.mainBodyH/2, BOTCHED.FUNC.GetTheme( 2 ), false, false, false, true )
        draw.RoundedBox( 8, x+h/2, y+(h/2)-(self2.mainBodyH/2), w-(h/2), self2.mainBodyH/2, BOTCHED.FUNC.GetTheme( 2 ) )
        BOTCHED.FUNC.DrawCircle( x+h/2, y+h/2, h/2, BOTCHED.FUNC.GetTheme( 2 ) )	
        BSHADOWS.EndShadow( "home_screen_info", x, y, 1, 2, 2, 255, 0, 0, false )

        draw.RoundedBoxEx( 8, h/2, (h/2), w-(h/2)-10-2, self2.mainBodyH/2-2, BOTCHED.FUNC.GetTheme( 1 ), false, false, false, true )
        draw.RoundedBox( 8, h/2, (h/2)-(self2.mainBodyH/2)+2, w-(h/2)-2, self2.mainBodyH/2-4, BOTCHED.FUNC.GetTheme( 1 ) )
        draw.RoundedBox( 8, h/2, (h/2)-(self2.mainBodyH/2)+2, w-(h/2)-2, self2.mainBodyH/2-4, BOTCHED.FUNC.GetTheme( 2, 50 ) )
        BOTCHED.FUNC.DrawCircle( h/2, h/2, h/2, BOTCHED.FUNC.GetTheme( 2 ) )
        BOTCHED.FUNC.DrawCircle( h/2, h/2, h/2-2, BOTCHED.FUNC.GetTheme( 1 ) )
        BOTCHED.FUNC.DrawCircle( h/2, h/2, h/2-2, BOTCHED.FUNC.GetTheme( 2, 50 ) )

        local level, experience = ply:GetLevel(), ply:GetExperience()
        local nextLevelTable = BOTCHED.CONFIG.Levels[level+1]
        local requiredEXP = (nextLevelTable or {}).RequiredEXP or 1
        draw.SimpleTextOutlined( "EXP " .. ply:GetExperience() .. "/" .. requiredEXP, "MontserratBold21", h+(w-h)/4, 0, Color(46, 204, 113), TEXT_ALIGN_CENTER, 0, 1, BOTCHED.FUNC.GetTheme( 1 ) )

        draw.SimpleTextOutlined( "STAMINA " .. ply:Stamina() .. "/" .. ply:GetMaxStamina(), "MontserratBold21", (w-(w-h)/4), 0, Color(243, 156, 18), TEXT_ALIGN_CENTER, 0, 1, BOTCHED.FUNC.GetTheme( 1 ) )

        surface.SetFont( "MontserratBold40" )
        local levelX, levelY = surface.GetTextSize( ply:GetLevel() )

        surface.SetFont( "MontserratMedium17" )
        local levelTxtX, levelTxtY = surface.GetTextSize( "Level" )

        local contentH = levelY+levelTxtY-16

        draw.SimpleText( ply:GetLevel(), "MontserratBold40", h/2, (h/2)-(contentH/2)-10, BOTCHED.FUNC.GetTheme( 4, 75 ), TEXT_ALIGN_CENTER )
        draw.SimpleText( "LEVEL", "MontserratBold20", h/2, (h/2)+(contentH/2), BOTCHED.FUNC.GetTheme( 4, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
    end 

    infoPanel.top = vgui.Create( "DPanel", infoPanel )
    infoPanel.top:Dock( TOP )
    infoPanel.top:DockMargin( infoPanel:GetTall(), (infoPanel:GetTall()-infoPanel.mainBodyH)/2, 0, 0 )
    infoPanel.top:SetSize( infoPanel:GetWide()-infoPanel:GetTall(), infoPanel.mainBodyH/2 )
    infoPanel.top.Paint = function() end 

    local expBar = vgui.Create( "DPanel", infoPanel.top )
    expBar:Dock( LEFT )
    expBar:SetWide( infoPanel.top:GetWide()/2 )
    local expColor = Color( 46, 204, 113 )
    expBar.Paint = function( self2, w, h )
        local barW, barH = w*0.75, 16
        draw.RoundedBox( barH/2, (w/2)-(barW/2), (h/2)-(barH/2), barW, barH, BOTCHED.FUNC.GetTheme( 1 ) )

        local level, experience = ply:GetLevel(), ply:GetExperience()
        local nextLevelTable = BOTCHED.CONFIG.Levels[level+1]
        local requiredEXP = (nextLevelTable or {}).RequiredEXP or 1

        BOTCHED.FUNC.DrawRoundedMask( barH/2, (w/2)-(barW/2), (h/2)-(barH/2), barW, barH, function()
            surface.SetDrawColor( expColor )
            surface.DrawRect( (w/2)-(barW/2), (h/2)-(barH/2)+1, math.Clamp( (experience/requiredEXP)*barW, 0, barW ), barH )
        end )
    end 

    local staminaBar = vgui.Create( "DPanel", infoPanel.top )
    staminaBar:Dock( RIGHT )
    staminaBar:SetWide( infoPanel.top:GetWide()/2 )
    local staminaColor = Color( 243, 156, 18 )
    staminaBar.Paint = function( self2, w, h )
        local barW, barH = w*0.75, 16
        draw.RoundedBox( barH/2, (w/2)-(barW/2), (h/2)-(barH/2), barW, barH, BOTCHED.FUNC.GetTheme( 1 ) )

        BOTCHED.FUNC.DrawRoundedMask( barH/2, (w/2)-(barW/2), (h/2)-(barH/2), barW, barH, function()
            surface.SetDrawColor( staminaColor )
            surface.DrawRect( (w/2)-(barW/2), (h/2)-(barH/2)+1, math.Clamp( (ply:Stamina()/ply:GetMaxStamina())*barW, 0, barW ), barH )
        end )
    end 

    infoPanel.bottom = vgui.Create( "DPanel", infoPanel )
    infoPanel.bottom:Dock( FILL )
    infoPanel.bottom:DockMargin( infoPanel:GetTall(), 0, 10, (infoPanel:GetTall()-infoPanel.mainBodyH)/2 )
    infoPanel.bottom:SetSize( infoPanel:GetWide()-infoPanel:GetTall()-10, infoPanel.mainBodyH/2 )
    infoPanel.bottom.Paint = function( self2, w, h ) 
        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 2 ) )
        surface.DrawRect( (w/2)-1, 3, 2, h-7 )
    end

    local gemsPanel = vgui.Create( "DPanel", infoPanel.bottom )
    gemsPanel:Dock( LEFT )
    gemsPanel:SetWide( infoPanel.bottom:GetWide()/2 )
    local gemMat = Material( "materials/botched/icons/gems.png" )
    gemsPanel.Paint = function( self2, w, h )
        surface.SetDrawColor( 255, 255, 255 )
        surface.SetMaterial( gemMat )
        local iconSize = 24
        surface.DrawTexturedRect( (h/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )

        draw.SimpleText( string.Comma( LocalPlayer():GetGems() ), "MontserratMedium21", w/2, h/2-1, BOTCHED.FUNC.GetTheme( 4, 125 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end 

    gemsPanel.button = vgui.Create( "DButton", gemsPanel )
    gemsPanel.button:Dock( RIGHT )
    gemsPanel.button:DockMargin( 0, 0, 6, 0 )
    gemsPanel.button:SetWide( infoPanel.bottom:GetTall() )
    gemsPanel.button:SetText( "" )
    local addMat = Material( "materials/botched/icons/add_16.png" )
    local alpha = 125
    gemsPanel.button.Paint = function( self2, w, h )
        if( self2:IsHovered() ) then
            alpha = math.Clamp( alpha+10, 125, 255 )
        else
            alpha = math.Clamp( alpha-10, 125, 255 )
        end

        local iconSize = 16
        local boxSize = iconSize+10
        draw.RoundedBox( 8, (w/2)-(boxSize/2), (h/2)-(boxSize/2), boxSize, boxSize, BOTCHED.FUNC.GetTheme( 2, alpha-125 ) )

        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 4, alpha ) )
        surface.SetMaterial( addMat )
        surface.DrawTexturedRect( (h/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
    end 
    gemsPanel.button.DoClick = BOTCHED.FUNC.DermaCreateGemStore

    local manaPanel = vgui.Create( "DPanel", infoPanel.bottom )
    manaPanel:Dock( RIGHT )
    manaPanel:SetWide( infoPanel.bottom:GetWide()/2 )
    local manaMat = Material( "materials/botched/icons/mana.png" )
    manaPanel.Paint = function( self2, w, h )
        surface.SetDrawColor( 255, 255, 255 )
        surface.SetMaterial( manaMat )
        local iconSize = 24
        surface.DrawTexturedRect( (h/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )

        draw.SimpleText( string.Comma( LocalPlayer():GetMana() ), "MontserratMedium21", w/2, h/2-1, BOTCHED.FUNC.GetTheme( 4, 125 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end 

    manaPanel.button = vgui.Create( "DButton", manaPanel )
    manaPanel.button:Dock( RIGHT )
    manaPanel.button:DockMargin( 0, 0, 6, 0 )
    manaPanel.button:SetWide( infoPanel.bottom:GetTall() )
    manaPanel.button:SetText( "" )
    local addMat = Material( "materials/botched/icons/add_16.png" )
    local alpha = 125
    manaPanel.button.Paint = function( self2, w, h )
        if( self2:IsHovered() ) then
            alpha = math.Clamp( alpha+10, 125, 255 )
        else
            alpha = math.Clamp( alpha-10, 125, 255 )
        end

        local iconSize = 16
        local boxSize = iconSize+10
        draw.RoundedBox( 8, (w/2)-(boxSize/2), (h/2)-(boxSize/2), boxSize, boxSize, BOTCHED.FUNC.GetTheme( 2, alpha-125 ) )

        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 4, alpha ) )
        surface.SetMaterial( addMat )
        surface.DrawTexturedRect( (h/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
    end 

    local timeRewardPanel = vgui.Create( "DPanel", self )
    timeRewardPanel:SetSize( ScrW()*0.1, BOTCHED.FUNC.ScreenScale( 75 ) )
    timeRewardPanel:SetPos( 25, self:GetTall()-25-timeRewardPanel:GetTall() )
    timeRewardPanel.Paint = function( self2, w, h )
        BSHADOWS.BeginShadow( "home_screen_time" )
        local x, y = self2:LocalToScreen( 0, 0 )
        draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 1 ) )
        BSHADOWS.EndShadow( "home_screen_time", x, y, 1, 2, 2, 255, 0, 0, false )

        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ) )

        draw.SimpleText( "TIME PLAYED", "MontserratBold20", 10, 5, BOTCHED.FUNC.GetTheme( 3 ) )

        local plyTimePlayed = LocalPlayer():GetTimePlayed()
        draw.SimpleText( BOTCHED.FUNC.FormatLetterTime( plyTimePlayed ), "MontserratBold20", 10, h-10, BOTCHED.FUNC.GetTheme( 4, 75 ), 0, TEXT_ALIGN_BOTTOM )

        local nextTimeReward
        for k, v in ipairs( BOTCHED.CONFIG.TimeRewards ) do
            if( plyTimePlayed >= v.Time ) then continue end

            nextTimeReward = v
            break
        end

        draw.SimpleText( "Next: " .. (nextTimeReward and BOTCHED.FUNC.FormatLetterTime( nextTimeReward.Time ) or "None"), "MontserratBold20", w-10, h-10, BOTCHED.FUNC.GetTheme( 4, 75 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )

        local progressBarH = BOTCHED.FUNC.ScreenScale( 8 )
        BOTCHED.FUNC.DrawRoundedMask( 8, 0, h-(progressBarH*2), w, progressBarH*2, function()
            surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 1 ) )
            surface.DrawRect( 0, h-progressBarH, w, progressBarH )

            surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 3 ) )
            surface.DrawRect( 0, h-progressBarH, w*math.Clamp( plyTimePlayed/(nextTimeReward and nextTimeReward.Time or 1), 0, 1 ), progressBarH )
        end )
    end

    surface.SetFont( "MontserratBold20" )
    local textX, textY = surface.GetTextSize( "VIEW" )

    timeRewardPanel.button = vgui.Create( "DButton", timeRewardPanel )
    timeRewardPanel.button:SetSize( textX+BOTCHED.FUNC.ScreenScale( 15 ), textY+BOTCHED.FUNC.ScreenScale( 10 ) )
    timeRewardPanel.button:SetPos( timeRewardPanel:GetWide()-5-timeRewardPanel.button:GetWide(), 5 )
    timeRewardPanel.button:SetText( "" )
    timeRewardPanel.button.Paint = function( self2, w, h )
        self2:CreateFadeAlpha( false, 50 )

        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 1 ) )
        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, self2.alpha ) )

        BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 2 ), 8 )

        draw.SimpleText( "VIEW", "MontserratBold20", w/2, h/2, BOTCHED.FUNC.GetTheme( 4, 75+(180*(self2.alpha/50)) ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
    timeRewardPanel.button.DoClick = function()
        if( IsValid( self.timePopup ) ) then return end
        self.timePopup = vgui.Create( "botched_popup_timerewards" )
    end

    local linkPanel = vgui.Create( "DPanel", self )
    linkPanel:SetSize( 0, BOTCHED.FUNC.ScreenScale( 40 ) )
    linkPanel:SetPos( 25, self:GetTall()-25-timeRewardPanel:GetTall()-linkPanel:GetTall()-10 )
    linkPanel.Paint = function( self2, w, h ) end
    linkPanel.AddLinkButton = function( self2, iconMat, link )
        local linkButton = vgui.Create( "DButton", self2 )
        linkButton:Dock( LEFT )
        linkButton:DockMargin( 0, 0, 10, 0 )
        linkButton:SetWide( self2:GetTall() )
        linkButton:SetText( "" )
        linkButton.Paint = function( self2, w, h )
            self2:CreateFadeAlpha( false, 100 )
    
            draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 1 ) )
            draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100+self2.alpha ) )
    
            BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 2 ), 8 )
    
            local iconSize = BOTCHED.FUNC.ScreenScale( 24 )
            surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 4, 75+((self2.alpha/100)*180) ) )
            surface.SetMaterial( iconMat )
            surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
        end
        linkButton.DoClick = function()
            gui.OpenURL( link )
        end

        self2:SetWide( self2:GetWide()+self2:GetTall()+(self2:GetWide() > 0 and 10 or 0) )
    end

    linkPanel:AddLinkButton( Material( "materials/botched/icons/discord.png" ), "https://discord.gg/NAaTvpK8vQ" )
    linkPanel:AddLinkButton( Material( "materials/botched/icons/steam.png" ), "http://steamcommunity.com/groups/botched-rpg" )

    self.navigationPanel = vgui.Create( "DPanel", self )
    self.navigationPanel:SetSize( 0, BOTCHED.FUNC.ScreenScale( 75 ) )
    self.navigationPanel:SetPos( ScrW()*0.5-25-self.navigationPanel:GetWide(), ScrH()*0.55-40-50-self.navigationPanel:GetTall()-25 )
    self.navigationPanel.Paint = function( self, w, h )
        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 225 ) )
    end 

    self.pages = {}
end

function PANEL:AddPageButton( title, iconMat, doClick, getNotifications )
    surface.SetFont( "MontserratMedium20" )
    local textX, textY = surface.GetTextSize( title )

    local iconSize = BOTCHED.FUNC.ScreenScale( 32 )
    local contentH = iconSize+textY+3

    local pageKey = #self.pages+1

    local pageButton = vgui.Create( "DButton", self.navigationPanel )
    pageButton:Dock( LEFT )
    pageButton:SetWide( textX+25 )
    pageButton:SetText( "" )
    local alpha = 0
    pageButton.Paint = function( self2, w, h )
        if( self2:IsHovered() ) then
            alpha = math.Clamp( alpha+10, 0, 100 )
        else
            alpha = math.Clamp( alpha-10, 0, 100 )
        end

        draw.RoundedBoxEx( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, alpha ), pageKey == 1, pageKey == #self.pages, pageKey == 1, pageKey == #self.pages )

        BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 2 ), (pageKey == 1 or pageKey == #self.pages) and 8 )

        surface.SetDrawColor( 255, 255, 255 )
        surface.SetMaterial( iconMat )
        surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(contentH/2), iconSize, iconSize )

        draw.SimpleText( title, "MontserratMedium20", w/2, (h/2)+(contentH/2), BOTCHED.FUNC.GetTheme( 4, 100 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )

        if( getNotifications ) then
            local notificationCount = getNotifications()

            if( notificationCount <= 0 ) then return end

            surface.SetFont( "MontserratBold19" )
            local textX, textY = surface.GetTextSize( notificationCount )
            textX, textY = textX+25, textY

            local x, y = self2:LocalToScreen( (w/2)-(textX/2), -(textY/2) )
            BSHADOWS.BeginShadow( "home_screen_notif_" .. title )
            BSHADOWS.SetShadowSize( "home_screen_notif_" .. title, textX, textY )
            draw.RoundedBox( 8, x, y, textX, textY, BOTCHED.CONFIG.Themes.Red )
            draw.SimpleText( notificationCount, "MontserratBold19", x+(textX/2)-1, y+(textY/2)-1, BOTCHED.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            BSHADOWS.EndShadow( "home_screen_notif_" .. title, x, y, 1, 1, 1, 255, 0, 0, false )
        end
    end
    pageButton.DoClick = doClick

    self.navigationPanel:SetWide( self.navigationPanel:GetWide()+pageButton:GetWide() )
    self.navigationPanel:SetPos( ScrW()*0.5-25-self.navigationPanel:GetWide(), ScrH()*0.55-40-50-self.navigationPanel:GetTall()-25 )

    table.insert( self.pages, pageButton )
end

local backgroundMat = Material( "materials/botched/f4_background.jpg" )
function PANEL:Paint( w, h )
    surface.SetDrawColor( 255, 255, 255 )
    surface.SetMaterial( backgroundMat )
    surface.DrawTexturedRect( 0, 0, w, (backgroundMat:Height()/backgroundMat:Width())*w )
end

vgui.Register( "botched_mainmenu_home", PANEL, "DPanel" )