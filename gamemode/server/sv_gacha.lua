function BOTCHED.FUNC.GenerateBannerCharacter( bannerTable )
    local totalStarChance = 0
    for k, v in pairs( bannerTable.Chances ) do
        totalStarChance = totalStarChance+v.Chance
    end

    local randomNum = math.Rand( 0, 100 )
    local previousChance, starCategory = 0
    for k, v in pairs( bannerTable.Chances ) do
        previousChance = previousChance+((v.Chance/totalStarChance)*100)
        if( randomNum <= previousChance ) then
            starCategory = k
            break
        end
    end

    local totalCharacters = 0
    local starCharacters = {}
    for k, v in pairs( BOTCHED.CONFIG.Characters ) do
        if( not v.DisableGacha and (v.Stars or 0) == starCategory ) then
            local multiplier = bannerTable.Characters[k] != nil and (bannerTable.Chances[v.Stars or 0] or {}).FocusedMultiplier or 1
            totalCharacters = totalCharacters+multiplier
            table.insert( starCharacters, { k, multiplier } )
        end
    end

    local randomCharNum = math.Rand( 0, 100 )
    local previousCharChance = 0
    local normalChance = 100/totalCharacters
    for k, v in ipairs( starCharacters ) do
        previousCharChance = previousCharChance+(normalChance*v[2])
        if( randomCharNum <= previousCharChance ) then
            return v[1], starCategory
        end
    end
end

util.AddNetworkString( "Botched.RequestDrawBanner" )
util.AddNetworkString( "Botched.SendDrawBanner" )
net.Receive( "Botched.RequestDrawBanner", function( len, ply )
    local bannerKey = net.ReadUInt( 4 )
    local drawKey = net.ReadUInt( 4 )
    
    if( not bannerKey or not drawKey ) then return end

    local bannerConfig = BOTCHED.CONFIG.Banners[bannerKey]
    if( not bannerConfig ) then return end

    local drawConfig = bannerConfig.Draws[drawKey]
    if( not drawConfig ) then return end

    if( not ply:CanAffordCost( drawConfig.Cost ) ) then
        ply:SendNotification( 1, 5, "You cannot afford this!" )
        return
    end

    ply:TakeCost( drawConfig.Cost )

    local received2Star
    local drawnCharacters = {}
    for i = 1, drawConfig.Amount do
        if( i == 10 and not received2Star ) then
            local modifiedBanner = table.Copy( bannerConfig )
            modifiedBanner.Chances[2].Chance = modifiedBanner.Chances[2].Chance+modifiedBanner.Chances[1].Chance
            modifiedBanner.Chances[1] = nil

            drawnCharacters[i] = { BOTCHED.FUNC.GenerateBannerCharacter( modifiedBanner ) }
            continue
        end

        local characterKey, stars = BOTCHED.FUNC.GenerateBannerCharacter( bannerConfig )
        drawnCharacters[i] = { characterKey, stars }
        
        if( not received2Star and stars >= 2 ) then received2Star = true end
    end

    local modelsToGive = {}
    local ownedCharacters = ply:GetOwnedCharacters()
    local magicCoins = 0
    for k, v in ipairs( drawnCharacters ) do
        if( ownedCharacters[v[1]] or modelsToGive[v[1]] ) then
            magicCoins = magicCoins+(BOTCHED.CONFIG.AlreadyOwnedRefunds[v[2]] or 0)
        else
            modelsToGive[v[1]] = true
        end
    end

    ply:GiveCharacters( unpack( table.GetKeys( modelsToGive ) ) )

    if( magicCoins > 0 ) then
        ply:AddMagicCoins( magicCoins )
    end

    net.Start( "Botched.SendDrawBanner" )
        net.WriteUInt( bannerKey, 4 )
        net.WriteUInt( drawKey, 4 )

        for k, v in ipairs( drawnCharacters ) do
            net.WriteString( v[1] )
        end

        net.WriteUInt( table.Count( modelsToGive ), 10 )
        for k, v in pairs( modelsToGive ) do
            net.WriteString( k )
        end
    net.Send( ply )
end )