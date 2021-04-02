local PANEL = {}

function PANEL:Init()
    self.borderSize = 2
end

local star24Mat = Material( "materials/botched/icons/star_24.png" )
function PANEL:SetItemInfo( name, model, amount, border, modelColor )
    self.amount = amount
    self.iconMat = string.StartWith( model, "materials" ) and Material( model )

    if( not self.iconMat ) then
        self.model = vgui.Create( "DModelPanel", self )
        self.model:Dock( FILL )
        self.model:DockMargin( self.borderSize, self.borderSize, self.borderSize, self.borderSize )
        self.model.Load = function()
            if( not IsValid( self ) ) then return end
            
            self.model:SetModel( model )
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

            if( modelColor ) then
                self.model:SetColor( modelColor )
            end

            BOTCHED.TEMP.ModelsLoaded[model] = true
        end

        if( not BOTCHED.TEMP.ModelsLoaded[model] ) then
            BOTCHED.FUNC.AddSlotToLoad( self, self.model.Load )
        else
            self.model.Load()
        end
    end

    self.button = vgui.Create( "DButton", self )
    self.button:Dock( FILL )
    self.button:SetText( "" )
    self.button.Paint = function() end
end

function PANEL:SetSpecial( is3Star )
    self.is3Star = is3Star
    self.isReward = true
end

function PANEL:Paint( w, h )
    self.button:CreateFadeAlpha( false, 50 )
    draw.RoundedBox( 8, 2, 2, w-4, h-4, BOTCHED.FUNC.GetTheme( 2, self.button.alpha ) )

    if( self.iconMat ) then
        local iconSize = w*0.5

        surface.SetDrawColor( 255, 255, 255 )
        surface.SetMaterial( self.iconMat )
        surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
    end

    if( self.amount ) then 
        draw.SimpleTextOutlined( "x" .. string.Comma( self.amount ), "MontserratBold25", w, h, BOTCHED.FUNC.GetTheme( 4, 75 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2, BOTCHED.FUNC.GetTheme( 1 ) )
    end

    if( self.is3Star ) then
        DisableClipping( true )
        local iconSize, iconSpacing = 24, 2
        surface.SetMaterial( star24Mat )
        surface.SetDrawColor( 255, 255, 255 )
        local totalWidth = (3*(iconSize+iconSpacing))-iconSpacing
        for i = 1, 3 do
            surface.DrawTexturedRect( (w/2)-(totalWidth/2)+((i-1)*(iconSize+iconSpacing)), -12, iconSize, iconSize )
        end
        DisableClipping( false )
    elseif( self.isReward ) then
        draw.SimpleTextOutlined( "1st CLEAR", "MontserratBold20", w/2, -4, BOTCHED.FUNC.GetTheme( 3 ), TEXT_ALIGN_CENTER, 0, 2, BOTCHED.FUNC.GetTheme( 1 ) )
    end
end

vgui.Register( "botched_item_questslot", PANEL, "DPanel" )