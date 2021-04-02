local PANEL = {}

function PANEL:Init()
    self.textEntry = vgui.Create( "botched_textentry", self )
    self.textEntry:Dock( FILL )
    self.textEntry:SetBackText( "Search" )
    self.textEntry.OnChange = function()
        if( self.OnChange ) then
            self.OnChange()
        end
    end
    self.textEntry.OnEnter = function()
        if( self.OnEnter ) then
            self.OnEnter()
        end
    end

    self:SetCornerRadius( 8 )
    self:SetRoundedCorners( true, true, true, true )
end

function PANEL:RequestFocus()
    return self.textEntry:RequestFocus()
end

function PANEL:SetValue( val )
    return self.textEntry:SetValue( val )
end

function PANEL:GetValue()
    return self.textEntry:GetValue()
end

function PANEL:SetBackColor( color )
    self.textEntry:SetBackColor( color )
end

function PANEL:SetHighlightColor( color )
    self.textEntry:SetHighlightColor( color )
end

function PANEL:SetCornerRadius( cornerRadius )
    self.textEntry:SetCornerRadius( cornerRadius )
end

function PANEL:SetRoundedCorners( roundTopLeft, roundTopRight, roundBottomLeft, roundBottomRight )
    self.textEntry:SetRoundedCorners( roundTopLeft, roundTopRight, roundBottomLeft, roundBottomRight )
end

local search = Material( "materials/botched/icons/search.png" )
function PANEL:Paint( w, h )
    surface.SetDrawColor( 255, 255, 255, self.textEntry.alpha or 0 )
    surface.SetMaterial( search )
    local size = 24
    surface.DrawTexturedRect( w-size-(h-size)/2, (h-size)/2, size, size )
end

vgui.Register( "botched_searchbar", PANEL, "DPanel" )