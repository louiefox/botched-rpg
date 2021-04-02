net.Receive( "Botched.SendWeaponVariable", function()
	if( not LocalPlayer().GetWeapon ) then return end

	local wepClass = net.ReadString()
	local variable = net.ReadString()
	local value = net.ReadFloat()

	local weaponEnt = LocalPlayer():GetWeapon( wepClass or "" )

	if( not IsValid( weaponEnt ) ) then return end

	if( weaponEnt.Primary and weaponEnt.Primary[variable] ) then
		weaponEnt.Primary[variable] = value
	else
		weaponEnt[variable] = value
	end
end )

local cancelBinds = {
	["cancelselect"] = true,
	["invprev"] = true,
	["invnext"] = true
}

hook.Add( "PlayerBindPress", "Botched.PlayerBindPress.Equipment", function( ply, bind, pressed )
	bind = string.lower( bind )

	if( cancelBinds[bind] or bind:sub( 1, 4 ) == "slot" ) then return true end
end )