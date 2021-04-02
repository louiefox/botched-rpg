include('shared.lua')

BOTCHED.TEMP.ResourceEnts = BOTCHED.TEMP.ResourceEnts or {}
function ENT:Initialize()
    BOTCHED.TEMP.ResourceEnts = BOTCHED.TEMP.ResourceEnts or {}
	BOTCHED.TEMP.ResourceEnts[self] = true
end

function ENT:OnRemove()
    if( not BOTCHED.TEMP.ResourceEnts ) then return end
	BOTCHED.TEMP.ResourceEnts[self] = nil
end

hook.Add( "HUDPaint", "Botched.HUDPaint.Resources", function()
    local ply = LocalPlayer()
    local scrW, scrH = ScrW(), ScrH()

    for k, v in pairs( BOTCHED.TEMP.ResourceEnts or {} ) do
        if( not IsValid( k ) ) then
            BOTCHED.TEMP.ResourceEnts[k] = nil
            continue
        end

        if( k.GetFallEndTime and k:GetFallEndTime() != 0 ) then return end

		local distance = ply:GetPos():DistToSqr( k:GetPos() )
		if( distance > 100000 ) then continue end

        local pos = k:GetPos()
        pos.z = pos.z+50

        local pos2d = pos:ToScreen()

        local farmer = k:GetFarmer()
        if( IsValid( farmer ) and farmer == LocalPlayer() ) then
            local topText = "Farming " .. k.PrintName .. "..."
            draw.SimpleText( topText, "MontserratBold25", pos2d.x+1, pos2d.y+1, BOTCHED.FUNC.GetTheme( 1 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
            draw.SimpleText( topText, "MontserratBold25", pos2d.x, pos2d.y, BOTCHED.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )

            local bottomText = "Press " .. string.upper( input.LookupBinding( "+use" ) ) .. " to cancel"
            draw.SimpleText( bottomText, "MontserratBold25", pos2d.x+1, pos2d.y+1, BOTCHED.FUNC.GetTheme( 1 ), TEXT_ALIGN_CENTER, 0 )
            draw.SimpleText( bottomText, "MontserratBold25", pos2d.x, pos2d.y, BOTCHED.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, 0 )

            local boxW, boxH = ScrW()*0.1, 8
            local boxX, boxY = pos2d.x-(boxW/2), pos2d.y+30

            surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 1 ) )
            surface.DrawRect( boxX+1, boxY+1, boxW, boxH )

            surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 2 ) )
            surface.DrawRect( boxX, boxY, boxW, boxH )

            surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 3 ) )
            surface.DrawRect( boxX, boxY, math.Clamp( ((k.FarmDuration-((k:GetStartTime()+k.FarmDuration)-CurTime()))/k.FarmDuration)*boxW, 0, boxW ), boxH )
        else
            local hintText = "Press " .. string.upper( input.LookupBinding( "+use" ) ) .. " to start farming"
            draw.SimpleText( hintText, "MontserratBold25", pos2d.x+1, pos2d.y+1, BOTCHED.FUNC.GetTheme( 1 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            draw.SimpleText( hintText, "MontserratBold25", pos2d.x, pos2d.y, BOTCHED.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
    end
end )