local PANEL = {}

function PANEL:Init()
    self:SetDrawOnTop( true )
end

function PANEL:SetNotificationInfo( itemKey, amount )
    local configItem = BOTCHED.CONFIG.Items[itemKey]

    if( not configItem ) then return end

    self.notificationText = "x" .. amount .. " " .. configItem.Name

    surface.SetFont( "MontserratBold25" )
    local textX, textY = surface.GetTextSize( self.notificationText )

    local tall = 60
    self:SetSize( math.max( textX+tall+75, ScrW()*0.12 ), tall )

    if( configItem.Model and string.EndsWith( configItem.Model, ".mdl" ) ) then
        self.model = vgui.Create( "DModelPanel", self )
        self.model:Dock( LEFT )
        self.model:SetWide( self:GetTall() )
        self.model:SetModel( configItem.Model )
        self.model.LayoutEntity = function() end

        if( IsValid( self.model.Entity ) ) then
            local mn, mx = self.model.Entity:GetRenderBounds()
            local size = 0
            size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
            size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
            size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )

            self.model:SetFOV( 50 )
            self.model:SetCamPos( Vector( size, size, size ) )
            self.model:SetLookAt( (mn + mx) * 0.5 )
        end
    else
        self.notificationMat = Material( configItem.Model )
    end

    self.stars = configItem.Stars or 0
    self.border = configItem.Border
end

local starMat = Material( "materials/botched/icons/star_24.png" )
function PANEL:Paint( w, h )
    local uniqueID = "item_notification_" .. (self.notificationText or "")
    BSHADOWS.BeginShadow( uniqueID )
    BSHADOWS.SetShadowSize( uniqueID, w, h )
    local x, y = self:LocalToScreen( 0, 0 )
    draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 2 ) )			
    BSHADOWS.EndShadow( uniqueID, x, y, 1, 1, 1, 255, 0, 0, false )

    if( self.border ) then
        if( not self.border.Anim ) then
            BOTCHED.FUNC.DrawRoundedMask( 8, 0, 0, w, h, function()
                BOTCHED.FUNC.DrawGradientBox( 0, 0, w, h, 1, unpack( self.border.Colors ) )
            end )
        end
    end

    local border = 1
    draw.RoundedBox( 8, border, border, w-(2*border), h-(2*border), BOTCHED.FUNC.GetTheme( 1 ) )

    if( self.notificationMat ) then
        surface.SetDrawColor( 255, 255, 255 )
        surface.SetMaterial( self.notificationMat )
        local iconSize = h*0.7
        surface.DrawTexturedRect( (h/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
    end

    surface.SetFont( "MontserratBold25" )
    local textX, textY = surface.GetTextSize( self.notificationText or "" )

    surface.SetFont( "MontserratBold20" )
    local subTextX, subTextY = surface.GetTextSize( "ITEM RECEIVED" )

    local contentH = textY+subTextY-7

    draw.SimpleText( self.notificationText or "", "MontserratBold25", w/2, (h/2)-(contentH/2)-3, BOTCHED.FUNC.GetTheme( 3 ), TEXT_ALIGN_CENTER, 0 )
    draw.SimpleText( "ITEM RECEIVED", "MontserratBold20", w/2, (h/2)+(contentH/2), BOTCHED.FUNC.GetTheme( 4, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )

    if( (self.stars or 0) >= 1 ) then
        local iconSize, starSpacing = 24, 3
        surface.SetMaterial( starMat )
    
        local starTotalW = (self.stars*(iconSize+starSpacing))-starSpacing
    
        DisableClipping( true )
        for i = 1, self.stars do
            local starXPos = ((w/2)-(starTotalW/2))+((i-1)*(iconSize+starSpacing))
            surface.SetDrawColor( 255, 255, 255 )
            surface.DrawTexturedRect( starXPos, h-14, iconSize, iconSize )
        end
        DisableClipping( false )
    end
end

vgui.Register( "botched_popup_itemnotification", PANEL, "DPanel" )