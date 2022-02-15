net.Receive( "Botched.SendAdminResourceSpawns", function()
    if( not LocalPlayer():HasAdminPrivilege() ) then return end

    BOTCHED.ResourceSpawns = net.ReadTable() or {}

    for k, v in pairs( BOTCHED.TEMP.ClientsideResourceSpawns or {} ) do
        if( not IsValid( v ) ) then continue end
        v:Remove()
    end

    BOTCHED.TEMP.ClientsideResourceSpawns = {}

    for k, v in pairs( BOTCHED.ResourceSpawns ) do
        if( BOTCHED.TEMP.ClientsideResourceSpawns[k] ) then continue end

        local typeConfig = BOTCHED.DEVCONFIG.ResourceTypes[v.Type] or {}

        BOTCHED.TEMP.ClientsideResourceSpawns[k] = ents.CreateClientProp()
        BOTCHED.TEMP.ClientsideResourceSpawns[k]:SetPos( v.Pos )
        BOTCHED.TEMP.ClientsideResourceSpawns[k]:SetAngles( Angle( v.Angles ) )
        BOTCHED.TEMP.ClientsideResourceSpawns[k]:SetModel( typeConfig.Model or "" )
        BOTCHED.TEMP.ClientsideResourceSpawns[k]:Spawn()
        BOTCHED.TEMP.ClientsideResourceSpawns[k]:SetRenderMode( RENDERMODE_TRANSCOLOR )
        BOTCHED.TEMP.ClientsideResourceSpawns[k]:SetColor( Color( 255, 255, 255, 160 ) )
    end
end )