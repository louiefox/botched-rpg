-- LEVELLING FUNCTIONS --
BOTCHED.TEMP.ExpNotifications = BOTCHED.TEMP.ExpNotifications or {}
function BOTCHED.FUNC.AddExpNotification( amount, reason )
    if( IsValid( BOTCHED_EXP_NOTIFICATION ) and BOTCHED_EXP_NOTIFICATION:GetAlpha() != 255 ) then
        BOTCHED_EXP_NOTIFICATION:Remove()
    end

    if( not IsValid( BOTCHED_EXP_NOTIFICATION ) ) then
        BOTCHED_EXP_NOTIFICATION = vgui.Create( "DPanel" )
        BOTCHED_EXP_NOTIFICATION:SetAlpha( 0 )
        BOTCHED_EXP_NOTIFICATION:AlphaTo( 255, 0.2 )
        BOTCHED_EXP_NOTIFICATION.XPos, BOTCHED_EXP_NOTIFICATION.YPos = ScrW()*0.55, ScrH()/2
        BOTCHED_EXP_NOTIFICATION:SetPos( BOTCHED_EXP_NOTIFICATION.XPos, BOTCHED_EXP_NOTIFICATION.YPos )
        BOTCHED_EXP_NOTIFICATION.Paint = function( self2, w, h )
            local totalExpText = "+" .. string.Comma( self2.TotalExpEarned or 0 ) .. " EXP" 
            draw.SimpleText( totalExpText, "MontserratBold25", 1, 1, BOTCHED.FUNC.GetTheme( 1 ) )
            draw.SimpleText( totalExpText, "MontserratBold25", 0, 0, BOTCHED.FUNC.GetTheme( 4 ) )
        end
        BOTCHED_EXP_NOTIFICATION.UpdateSize = function()
            surface.SetFont( "MontserratBold25" )
            local textX, textY = surface.GetTextSize( "+" .. string.Comma( BOTCHED_EXP_NOTIFICATION.TotalExpEarned ) .. " EXP"  )
            BOTCHED_EXP_NOTIFICATION:SetSize( textX+1, textY+1 )
        end
    end

    BOTCHED_EXP_NOTIFICATION.TotalExpEarned = (BOTCHED_EXP_NOTIFICATION.TotalExpEarned or 0)+amount
    BOTCHED_EXP_NOTIFICATION.UpdateSize()

    local entryText = "+" .. string.Comma( amount ) .. " " .. reason
    surface.SetFont( "MontserratMedium21" )
    local textX, textY = surface.GetTextSize( entryText  )

    local notificationPanel = vgui.Create( "DPanel" )
    notificationPanel:SetAlpha( 0 )
    notificationPanel:AlphaTo( 255, 0.2 )
    notificationPanel:SetPos( BOTCHED_EXP_NOTIFICATION.XPos+15, BOTCHED_EXP_NOTIFICATION.YPos+BOTCHED_EXP_NOTIFICATION:GetTall() )
    notificationPanel:SetSize( textX+1, textY+1 )
    notificationPanel.Paint = function( self2, w, h )
        draw.SimpleText( entryText, "MontserratMedium21", 1, 1, BOTCHED.FUNC.GetTheme( 1 ) )
        draw.SimpleText( entryText, "MontserratMedium21", 0, 0, BOTCHED.FUNC.GetTheme( 4 ) )
    end

    local function GetNotifsCount()
        local totalCount = 0
        for k, v in ipairs( BOTCHED.TEMP.ExpNotifications ) do
            if( not v ) then continue end

            totalCount = totalCount+1
        end

        return totalCount
    end

    if( GetNotifsCount() > 0 ) then
        surface.SetFont( "MontserratMedium21" )
        local textX, textY = surface.GetTextSize( "+50 REASON" )

        for k, v in pairs( BOTCHED.TEMP.ExpNotifications ) do
            if( IsValid( v ) ) then
                local xPos, yPos = v:GetPos()
                v:MoveTo( xPos, yPos+textY, 0.2 )
            end
        end
    end

    if( GetNotifsCount() >= 3 ) then
        for k, v in pairs( BOTCHED.TEMP.ExpNotifications ) do
            if( GetNotifsCount() < 3 ) then break end

            if( v and IsValid( v ) ) then
                BOTCHED.TEMP.ExpNotifications[k] = false

                if( timer.Exists( "BOTCHED.Timer.ExpNotification.Key_" .. k ) ) then
                    timer.Remove( "BOTCHED.Timer.ExpNotification.Key_" .. k )    
                end

                v:AlphaTo( 0, 0.2, 0, function()
                    v:Remove()
                end )
            end
        end
    end

    local notificationKey = table.insert( BOTCHED.TEMP.ExpNotifications, notificationPanel )

    if( timer.Exists( "BOTCHED.Timer.ExpNotification.Key_" .. notificationKey ) ) then
        timer.Remove( "BOTCHED.Timer.ExpNotification.Key_" .. notificationKey )    
    end

    timer.Create( "BOTCHED.Timer.ExpNotification.Key_" .. notificationKey, 2, 1, function()
        if( IsValid( notificationPanel ) ) then
            notificationPanel:AlphaTo( 0, 0.2, 0, function()
                notificationPanel:Remove()
            end )
            BOTCHED.TEMP.ExpNotifications[notificationKey] = false
        end

        if( IsValid( BOTCHED_EXP_NOTIFICATION ) and GetNotifsCount() < 1 ) then
            BOTCHED_EXP_NOTIFICATION:AlphaTo( 0, 0.2, 0, function()
                BOTCHED_EXP_NOTIFICATION:Remove()
            end )
            BOTCHED.TEMP.ExpNotifications = {}
        end
    end )
end

function BOTCHED.FUNC.AddLevelNotification( newLevel )
    if( IsValid( BOTCHED_LEVEL_NOTIFICATION ) ) then
        BOTCHED_LEVEL_NOTIFICATION:Remove()
    end

    surface.SetFont( "MontserratBold120" )
    local textX, textY = surface.GetTextSize( "LEVEL " .. newLevel  )

    BOTCHED_LEVEL_NOTIFICATION = vgui.Create( "DPanel" )
    BOTCHED_LEVEL_NOTIFICATION:SetAlpha( 0 )
    BOTCHED_LEVEL_NOTIFICATION:AlphaTo( 255, 0.2 )
    BOTCHED_LEVEL_NOTIFICATION:SetSize( textX+1, textY+1 )
    BOTCHED_LEVEL_NOTIFICATION:SetPos( (ScrW()/2)-(BOTCHED_LEVEL_NOTIFICATION:GetWide()/2), ScrH()/2 )
    BOTCHED_LEVEL_NOTIFICATION:MoveTo( (ScrW()/2)-(BOTCHED_LEVEL_NOTIFICATION:GetWide()/2), (ScrH()/3)-(BOTCHED_LEVEL_NOTIFICATION:GetTall()/2), 0.2 )
    BOTCHED_LEVEL_NOTIFICATION.AnimDuration = 0.2
    BOTCHED_LEVEL_NOTIFICATION.AnimEndTime = CurTime()+BOTCHED_LEVEL_NOTIFICATION.AnimDuration
    BOTCHED_LEVEL_NOTIFICATION.Paint = function( self2, w, h )
        local text = "LEVEL " .. newLevel
        draw.SimpleText( text, "MontserratBold120", (w/2)+1, (h/2)+1, BOTCHED.FUNC.GetTheme( 1 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        draw.SimpleText( text, "MontserratBold120", w/2, h/2, BOTCHED.FUNC.GetTheme( 3 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end

    surface.PlaySound( "botched/levelup.wav" )

    if( timer.Exists( "BOTCHED.Timer.LevelNotification" ) ) then
        timer.Remove( "BOTCHED.Timer.LevelNotification" )    
    end

    timer.Create( "BOTCHED.Timer.LevelNotification", 2, 1, function()
        if( IsValid( BOTCHED_LEVEL_NOTIFICATION ) ) then
            BOTCHED_LEVEL_NOTIFICATION:AlphaTo( 0, 0.2, 0, function()
                BOTCHED_LEVEL_NOTIFICATION:Remove()
            end )
        end
    end )
end

-- INVENTORY FUNCTIONS --
BOTCHED.TEMP.ItemNotifications = BOTCHED.TEMP.ItemNotifications or {}
function BOTCHED.FUNC.AddItemNotification( itemKey, amount )
    local startYPos = ScrH()*0.85

    local notificationPanel = vgui.Create( "botched_popup_itemnotification" )
    notificationPanel:SetAlpha( 0 )
    notificationPanel:AlphaTo( 255, 0.2 )
    notificationPanel:SetNotificationInfo( itemKey, amount )
    notificationPanel:SetPos( (ScrW()/2)-(notificationPanel:GetWide()/2), startYPos+notificationPanel:GetTall() )
    notificationPanel:MoveTo( (ScrW()/2)-(notificationPanel:GetWide()/2), startYPos-notificationPanel:GetTall(), 0.2 )

    local function GetNotifsCount()
        local totalCount = 0
        for k, v in ipairs( BOTCHED.TEMP.ItemNotifications ) do
            if( not v ) then continue end

            totalCount = totalCount+1
        end

        return totalCount
    end

    if( GetNotifsCount() > 0 ) then
        for k, v in pairs( BOTCHED.TEMP.ItemNotifications ) do
            if( v and IsValid( v ) ) then
                local xPos, yPos = v:GetPos()
                v:MoveTo( (ScrW()/2)-(v:GetWide()/2), yPos-5-notificationPanel:GetTall(), 0.2 )
            end
        end
    end

    local notificationKey = table.insert( BOTCHED.TEMP.ItemNotifications, notificationPanel )

    if( timer.Exists( "BOTCHED.Timer.Notification.Key_" .. notificationKey ) ) then
        timer.Remove( "BOTCHED.Timer.Notification.Key_" .. notificationKey )    
    end

    timer.Create( "BOTCHED.Timer.Notification.Key_" .. notificationKey, 2, 1, function()
        if( IsValid( notificationPanel ) ) then
            notificationPanel:AlphaTo( 0, 0.2, 0, function()
                notificationPanel:Remove()
            end )
            BOTCHED.TEMP.ItemNotifications[notificationKey] = false
        end

        if( GetNotifsCount() < 1 ) then
            BOTCHED.TEMP.ItemNotifications = {}
        end
    end )
end

-- DEFAULT FUNCTIONS --
BOTCHED.TEMP.Notifications = BOTCHED.TEMP.Notifications or {}
function notification.AddLegacy( text, type, length )
    local startYPos = ScrH()*0.85

    surface.PlaySound( "buttons/lightswitch2.wav" )

    local notificationPanel = vgui.Create( "botched_popup_notification" )
    notificationPanel:SetAlpha( 0 )
    notificationPanel:AlphaTo( 255, 0.2 )
    notificationPanel:SetNotificationInfo( text, type, length )
    notificationPanel:SetPos( ScrW()+notificationPanel:GetWide(), startYPos-notificationPanel:GetTall() )
    notificationPanel:MoveTo( ScrW()-notificationPanel:GetWide()-25, startYPos-notificationPanel:GetTall(), 0.2 )

    local function GetNotifsCount()
        local totalCount = 0
        for k, v in ipairs( BOTCHED.TEMP.Notifications ) do
            if( not v ) then continue end

            totalCount = totalCount+1
        end

        return totalCount
    end

    if( GetNotifsCount() > 0 ) then
        for k, v in pairs( BOTCHED.TEMP.Notifications ) do
            if( v and IsValid( v ) ) then
                local xPos, yPos = v:GetPos()
                v:MoveTo( ScrW()-v:GetWide()-25, yPos-5-notificationPanel:GetTall(), 0.2 )
            end
        end
    end

    local notificationKey = table.insert( BOTCHED.TEMP.Notifications, notificationPanel )

    if( timer.Exists( "BOTCHED.Timer.Notification.Key_" .. notificationKey ) ) then
        timer.Remove( "BOTCHED.Timer.Notification.Key_" .. notificationKey )    
    end

    timer.Create( "BOTCHED.Timer.Notification.Key_" .. notificationKey, length, 1, function()
        if( IsValid( notificationPanel ) ) then
            notificationPanel:AlphaTo( 0, 0.2, 0, function()
                notificationPanel:Remove()
            end )
            BOTCHED.TEMP.Notifications[notificationKey] = false
        end

        if( GetNotifsCount() < 1 ) then
            BOTCHED.TEMP.Notifications = {}
        end
    end )
end

-- ERROR FUNCTIONS --
function BOTCHED.FUNC.SetBottomErrorNotif( text, time )
    local oldNotif = BOTCHED_BOTTOM_ERROR_NOTIF
    if( IsValid( oldNotif ) ) then
        oldNotif:AlphaTo( 0, 0.2, 0, function()
            oldNotif:Remove()
        end )
    end

    if( timer.Exists( "BOTCHED.Timer.BottomErrorNotif" ) ) then
        timer.Remove( "BOTCHED.Timer.BottomErrorNotif" )    
    end

    surface.SetFont( "MontserratBold30" )
    local textX, textY = surface.GetTextSize( text )
    textX, textY = textX+10, textY+10

    BOTCHED_BOTTOM_ERROR_NOTIF = vgui.Create( "DPanel" )
    BOTCHED_BOTTOM_ERROR_NOTIF:SetAlpha( 0 )
    BOTCHED_BOTTOM_ERROR_NOTIF:AlphaTo( 255, 0.2 )
    BOTCHED_BOTTOM_ERROR_NOTIF:SetSize( textX, textY )
    BOTCHED_BOTTOM_ERROR_NOTIF:SetPos( (ScrW()/2)-(BOTCHED_BOTTOM_ERROR_NOTIF:GetWide()/2), ScrH()*0.9-(BOTCHED_BOTTOM_ERROR_NOTIF:GetTall()/2) )
    BOTCHED_BOTTOM_ERROR_NOTIF.Paint = function( self2, w, h )
        draw.SimpleTextOutlined( text, "MontserratBold30", w/2, h/2, BOTCHED.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, BOTCHED.FUNC.GetTheme( 1 ) )
    end

    timer.Create( "BOTCHED.Timer.BottomErrorNotif", time-0.2, 1, function()
        if( not IsValid( BOTCHED_BOTTOM_ERROR_NOTIF ) ) then return end
        BOTCHED_BOTTOM_ERROR_NOTIF:AlphaTo( 0, 0.2, 0, function()
            BOTCHED_BOTTOM_ERROR_NOTIF:Remove()
        end )
    end )
end