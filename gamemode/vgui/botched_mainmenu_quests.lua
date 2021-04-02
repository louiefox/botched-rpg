local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel()
    self.previousPage = vgui.Create( "DButton", self )
    self.previousPage:SetSize( 50, 75 )
    self.previousPage:SetPos( 25, (self:GetTall()/2)-(self.previousPage:GetTall()/2) )
    self.previousPage:SetZPos( 100 )
    self.previousPage:SetText( "" )
    local alpha = 0
    local previousIconMat = Material( "materials/botched/icons/previous.png" )
    self.previousPage.Paint = function( self2, w, h )
        if( self2:IsHovered() ) then
            alpha = math.Clamp( alpha+10, 100, 150 )
        else
            alpha = math.Clamp( alpha-10, 100, 150 )
        end

        BSHADOWS.BeginShadow( "gacha_previous" )
        local x, y = self2:LocalToScreen( 0, 0 )
        draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 1 ) )			
        BSHADOWS.EndShadow( "gacha_previous", x, y, 1, 1, 1, 255, 0, 0, false )
        
        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, alpha ) )

        BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 2 ), 8 )

        surface.SetDrawColor( 255, 255, 255 )
        surface.SetMaterial( previousIconMat )
        local iconSize = 32
        surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
    end
    self.previousPage.UpdateVisibility = function()
        self.previousPage:SetVisible( self.currentQuestLine > 1 )
    end
    self.previousPage.DoClick = function()
        self:LoadQuestLine( math.Clamp( self.currentQuestLine-1, 1, #BOTCHED.CONFIG.QuestsLines ) )
    end

    self.nextPage = vgui.Create( "DButton", self )
    self.nextPage:SetSize( 50, 75 )
    self.nextPage:SetPos( self:GetWide()-self.nextPage:GetWide()-25, (self:GetTall()/2)-(self.nextPage:GetTall()/2) )
    self.nextPage:SetZPos( 100 )
    self.nextPage:SetText( "" )
    local alpha = 0
    local nextIconMat = Material( "materials/botched/icons/next.png" )
    self.nextPage.Paint = function( self2, w, h )
        if( self2:IsHovered() ) then
            alpha = math.Clamp( alpha+10, 100, 150 )
        else
            alpha = math.Clamp( alpha-10, 100, 150 )
        end

        BSHADOWS.BeginShadow( "gacha_next" )
        local x, y = self2:LocalToScreen( 0, 0 )
        draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 1 ) )			
        BSHADOWS.EndShadow( "gacha_next", x, y, 1, 1, 1, 255, 0, 0, false )

        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, alpha ) )

        BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 2 ), 8 )

        surface.SetDrawColor( 255, 255, 255 )
        surface.SetMaterial( nextIconMat )
        local iconSize = 32
        surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
    end
    self.nextPage.UpdateVisibility = function()
        self.nextPage:SetVisible( self.currentQuestLine != #BOTCHED.CONFIG.QuestsLines )
    end
    self.nextPage.DoClick = function()
        self:LoadQuestLine( math.Clamp( self.currentQuestLine+1, 1, #BOTCHED.CONFIG.QuestsLines ) )
    end

    self.currentQuestLine = cookie.GetNumber( "BOTCHED.Cookie.QuestLineViewed", 1 )
    self.loadedQuestLines = {}
    self:LoadQuestLine( self.currentQuestLine, true )

    hook.Add( "Botched.Hooks.CompletedQuestsUpdated", self, function()
        for k, v in pairs( self.loadedQuestLines ) do
            if( not IsValid( v ) ) then continue end

            v:Remove()
        end
        self.loadedQuestLines = {}

        self:LoadQuestLine( self.currentQuestLine, true )
    end )
end

function PANEL:LoadQuestLine( questLineKey, noAnim )
    if( cookie.GetNumber( "BOTCHED.Cookie.QuestLineViewed", 1 ) != questLineKey ) then
        cookie.Set( "BOTCHED.Cookie.QuestLineViewed", questLineKey )
    end

    local previousQuestLine = self.currentQuestLine
    if( previousQuestLine != questLineKey ) then
        self.loadedQuestLines[previousQuestLine]:MoveTo( previousQuestLine > questLineKey and self:GetWide() or -self:GetWide(), 0, 0.2 )
    end

    self.currentQuestLine = questLineKey
    self.previousPage.UpdateVisibility()
    self.nextPage.UpdateVisibility()

    if( self.loadedQuestLines[questLineKey] ) then
        if( not noAnim ) then
            self.loadedQuestLines[questLineKey]:MoveTo( 0, 0, 0.2 )
        else
            self.loadedQuestLines[questLineKey]:SetPos( 0, 0 )
        end
        return
    end

    local questLine = BOTCHED.CONFIG.QuestsLines[questLineKey]
    if( not questLine ) then return end

    local imageMat
    BOTCHED.FUNC.GetImage( questLine.Image or "", function( mat ) 
        imageMat = mat
    end )

    local questButtons = {}

    local questLinePage = vgui.Create( "DPanel", self )
    questLinePage:SetSize( self:GetWide(), self:GetTall() )
    if( not noAnim ) then
        questLinePage:SetPos( questLineKey > previousQuestLine and self:GetWide() or -self:GetWide(), 0 )
        questLinePage:MoveTo( 0, 0, 0.2 )
    else
        questLinePage:SetPos( 0, 0 )
    end
    questLinePage.Paint = function( self2, w, h )
        if( not imageMat ) then return end

        local imageH = (imageMat:Height()/imageMat:Width())*w

        surface.SetDrawColor( 255, 255, 255 )
        surface.SetMaterial( imageMat )
        surface.DrawTexturedRect( 0, (h/2)-(imageH/2), w, imageH )

        BSHADOWS.BeginShadow( "questline_name" .. questLineKey, self:GetShadowBounds() )
        local x, y = self2:LocalToScreen( w/2, 25 )
        draw.SimpleText( questLineKey .. " - " .. string.upper( questLine.Title ), "MontserratBold50", x, y, BOTCHED.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER )
        BSHADOWS.EndShadow( "questline_name" .. questLineKey, x, y, 1, 2, 2, 255, 0, 0, false )

        for k, v in ipairs( questButtons ) do
            local next = questButtons[k+1]
            if( not IsValid( next ) ) then break end

            local nextX, nextY = next:GetPos()
            local x, y = v:GetPos()
            surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 2 ) )

            local lineWidth = 3

            for i = 1, lineWidth do
                surface.DrawLine( x+v:GetWide()/2, y+v:GetTall()/2-(lineWidth/2)+(i-1), nextX+next:GetWide()/2, nextY+next:GetTall()/2-(lineWidth/2)+(i-1) )
            end
        end
    end
    self.loadedQuestLines[questLineKey] = questLinePage

    local completedQuests = LocalPlayer():GetCompletedQuests()
    local star24Mat = Material( "materials/botched/icons/star_24.png" )
    local star24BlankMat = Material( "materials/botched/icons/star_24_blank.png" )
    local lockMat = Material( "materials/botched/icons/lock.png" )

    local questButtonSize = 100
    local totalWidth = 0

    local previousQuestLine = BOTCHED.CONFIG.QuestsLines[questLineKey-1]
    local previousStars = (previousQuestLine and ((completedQuests[questLineKey-1] or {})[#previousQuestLine.Quests] or 0) < 1) and 0 or 1
    for k, v in ipairs( questLine.Quests ) do
        local hasUnlocked = previousStars > 0
        local completedStars = (completedQuests[questLineKey] or {})[k] or 0

        previousStars = completedStars

        local questButton = vgui.Create( "DButton", questLinePage )
        questButton:SetSize( questButtonSize, questButtonSize )
        questButton:SetText( "" )
        questButton.leftSpacing = k != 1 and 50 or 0
        questButton.Paint = function( self2, w, h )
            self2:CreateFadeAlpha( false, 75 )

            BSHADOWS.BeginShadow( "questline_questbutton_" .. questLineKey .. k, self:GetShadowBounds() )
            local x, y = self2:LocalToScreen( 0, 0 )
            draw.RoundedBox( 16, x, y, w, h, BOTCHED.FUNC.GetTheme( 2 ) )
            BSHADOWS.EndShadow( "questline_questbutton_" .. questLineKey .. k, x, y, 1, 1, 1, 255, 0, 0, false )

            draw.RoundedBox( 16, 2, 2, w-4, h-4, BOTCHED.FUNC.GetTheme( 1 ) )
            draw.RoundedBox( 16, 2, 2, w-4, h-4, BOTCHED.FUNC.GetTheme( 2, self2.alpha ) )
            BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 2 ), 16 )

            draw.SimpleText( questLineKey .. "-" .. k, "MontserratBold30", w/2, h/2, BOTCHED.FUNC.GetTheme( 4, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

            if( not hasUnlocked ) then
                surface.SetMaterial( lockMat )
                surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 2 ) )
                local iconSize = 24
                surface.DrawTexturedRect( w-7-iconSize, 7, iconSize, iconSize )
            end

            -- CLIPPING --
            DisableClipping( true )

            local iconSize, iconSpacing = 24, 2
            local totalWidth = (3*(iconSize+iconSpacing))-iconSpacing

            surface.SetMaterial( star24BlankMat )
            surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 2 ) )
            for i = 1, 3 do
                surface.DrawTexturedRect( (w/2)-(totalWidth/2)+((i-1)*(iconSize+iconSpacing)), h-14, iconSize, iconSize )
            end

            surface.SetMaterial( star24Mat )
            surface.SetDrawColor( 255, 255, 255 )
            for i = 1, completedStars do
                surface.DrawTexturedRect( (w/2)-(totalWidth/2)+((i-1)*(iconSize+iconSpacing)), h-14, iconSize, iconSize )
            end

            DisableClipping( false )
        end
        questButton.DoClick = function()
            if( not hasUnlocked ) then
                notification.AddLegacy( "You must complete the previous quest first!", 1, 5 )
                return
            end

            self:OpenQuestPopup( questLineKey, k )
        end

        totalWidth = totalWidth+questButton:GetWide()+questButton.leftSpacing
        questButtons[k] = questButton
    end

    local usedWidth = 0
    for k, v in ipairs( questButtons ) do
        v:SetPos( (questLinePage:GetWide()/2)-(totalWidth/2)+usedWidth+v.leftSpacing, (questLinePage:GetTall()/2)-(v:GetTall()/2) )
        usedWidth = usedWidth+v.leftSpacing+v:GetWide()
    end
end

function PANEL:GetShadowBounds()
    local x = self:LocalToScreen( 0, 0 )
    return x, 0, x+self:GetWide(), ScrH()
end

function PANEL:OpenQuestPopup( questLineKey, questKey )
    self.popup = vgui.Create( "botched_popup_quest_view" )
    self.popup:SetQuestInfo( questLineKey, questKey )
end

function PANEL:Paint( w, h )

end

vgui.Register( "botched_mainmenu_quests", PANEL, "DPanel" )