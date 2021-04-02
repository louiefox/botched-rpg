local PANEL = {}

function PANEL:Init()
    self:SetDrawOnTop( true )
end

function PANEL:SetNotificationInfo( text, type, length )
    local notificationTypes = {
        [0] = {
            Name = "Generic",
            Mat = Material( "materials/botched/icons/notification.png" )
        },
        [1] = {
            Name = "Error",
            Mat = Material( "materials/botched/icons/error.png" )
        },
        [3] = {
            Name = "Hint",
            Mat = Material( "materials/botched/icons/hint.png" )
        }
    }

    self.notificationMat = (notificationTypes[type] and notificationTypes[type].Mat) or notificationTypes[0].Mat
    self.notificationText = text 

    surface.SetFont( "MontserratMedium23" )
    local textX, textY = surface.GetTextSize( text )

    local tall = 40
    self:SetSize( tall+textX+25, tall )
end

function PANEL:Paint( w, h )
    local uniqueID = "notification_" .. self.notificationText or ""
    BSHADOWS.BeginShadow( uniqueID )
    BSHADOWS.SetShadowSize( uniqueID, w, h )
    local x, y = self:LocalToScreen( 0, 0 )
    draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 1 ) )			
    BSHADOWS.EndShadow( uniqueID, x, y, 1, 2, 2, 255, 0, 0, false )

    draw.RoundedBoxEx( 8, 0, 0, h, h, BOTCHED.FUNC.GetTheme( 2, 100 ), true, false, true, false )

    if( self.notificationMat ) then
        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 4, 75 ) )
        surface.SetMaterial( self.notificationMat )
        local iconSize = 24
        surface.DrawTexturedRect( (h/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
    end

    draw.SimpleText( self.notificationText or "", "MontserratMedium23", h+((w-h)/2), h/2-1, BOTCHED.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end

vgui.Register( "botched_popup_notification", PANEL, "DPanel" )