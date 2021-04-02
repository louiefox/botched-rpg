local PANEL = {}

function PANEL:Init()
    self:SetTall( 40 )
    self.borderSize, self.borderColor = 1, BOTCHED.FUNC.GetTheme( 2 )
end

function PANEL:SetItemInfo( ownedAmount, neededAmount, name, model )
    self.infoSet = true
    self.ownedAmount, self.neededAmount, self.name = ownedAmount, neededAmount, name

    if( model and (string.EndsWith( model, ".png" ) or string.EndsWith( model, ".jpg" )) ) then
        self.iconMat = Material( model )
    end

    if( model and isstring( model ) and string.EndsWith( model, ".mdl" ) ) then
        local modelPanel = vgui.Create( "DModelPanel", self )
        modelPanel:Dock( LEFT )
        modelPanel:SetWide( self:GetTall()-(2*self.borderSize) )
        modelPanel:DockMargin( self.borderSize, self.borderSize, self.borderSize, self.borderSize )
        modelPanel.LayoutEntity = function() end
        modelPanel.Load = function()
            if( not IsValid( self ) ) then return end
            
            modelPanel:SetModel( model )
            modelPanel.LayoutEntity = function() end
    
            if( IsValid( modelPanel.Entity ) ) then
                local mn, mx = modelPanel.Entity:GetRenderBounds()
                local size = 0
                size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
                size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
                size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )

                modelPanel:SetFOV( 45 )
                modelPanel:SetCamPos( Vector( size, size, size ) )
                modelPanel:SetLookAt( (mn + mx) * 0.5 )
            end

            BOTCHED.TEMP.ModelsLoaded[model] = true
        end

        if( not BOTCHED.TEMP.ModelsLoaded[model] ) then
            BOTCHED.FUNC.AddSlotToLoad( self, modelPanel.Load )
        else
            modelPanel.Load()
        end
    end
end

function PANEL:Paint( w, h )
    if( not self.infoSet ) then return end
    local uniqueID = "itemslotbar_entry_" .. self.name .. "_" .. (self.neededAmount or 0)

    BSHADOWS.BeginShadow( uniqueID )
    BSHADOWS.SetShadowSize( uniqueID, w, h )
    local x, y = self:LocalToScreen( 0, 0 )
    draw.RoundedBox( 8, x, y, w, h, self.borderColor or BOTCHED.FUNC.GetTheme( 2 ) )
    BSHADOWS.EndShadow( uniqueID, x, y, 1, 1, 2, 255, 0, 0, false )

    draw.RoundedBox( 8, self.borderSize, self.borderSize, w-(2*self.borderSize), h-(2*self.borderSize), BOTCHED.FUNC.GetTheme( 1 ) )	

    draw.SimpleText( self.name, "MontserratMedium21", h+5, h/2-1, BOTCHED.FUNC.GetTheme( 3 ), 0, TEXT_ALIGN_CENTER )

    if( self.neededAmount ) then
        draw.SimpleText( string.Comma( self.ownedAmount ) .. "/" .. string.Comma( self.neededAmount ), "MontserratMedium20", w-10, h/2-1, BOTCHED.FUNC.GetTheme( 4, 75 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
    else
        draw.SimpleText( "x" .. string.Comma( self.ownedAmount ), "MontserratMedium20", w-10, h/2-1, BOTCHED.FUNC.GetTheme( 4, 75 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
    end

    if( self.iconMat ) then
        surface.SetDrawColor( 255, 255, 255 )
        surface.SetMaterial( self.iconMat )
        local iconSize = 24
        surface.DrawTexturedRect( (h/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
    end
end

vgui.Register( "botched_item_slotbar", PANEL, "DPanel" )