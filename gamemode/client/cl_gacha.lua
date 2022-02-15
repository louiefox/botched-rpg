net.Receive( "Botched.SendDrawBanner", function()
    local bannerKey = net.ReadUInt( 4 )
    local drawKey = net.ReadUInt( 4 )

    local bannerConfig = BOTCHED.CONFIG.Banners[bannerKey]
    if( not bannerConfig ) then return end

    local drawConfig = bannerConfig.Draws[drawKey]
    if( not drawConfig ) then return end

    local drawnCharacters = {}
    for i = 1, drawConfig.Amount do
        drawnCharacters[i] = net.ReadString()
    end

    local givenCharacters = {}
    for i = 1, net.ReadUInt( 10 ) do
        givenCharacters[net.ReadString()] = true
    end

    if( IsValid( BOTCHED_MAINMENU ) ) then BOTCHED_MAINMENU:SetVisible( false ) end

    local popup = vgui.Create( "botched_popup_banner_draw" )
    popup:SetDrawInfo( bannerKey, drawnCharacters, givenCharacters )
end )