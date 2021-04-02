-- TIME REWARDS --
util.AddNetworkString( "Botched.RequestClaimTimeReward" )
net.Receive( "Botched.RequestClaimTimeReward", function( len, ply )
    local rewardKey = net.ReadUInt( 6 )
    local rewardConfig = BOTCHED.CONFIG.TimeRewards[rewardKey or 0]

    if( not rewardConfig or ply:GetTimePlayed() < rewardConfig.Time ) then return end

    local claimedRewards = ply:GetClaimedTimeRewards()
    if( claimedRewards[rewardKey] ) then return end

    ply:GiveReward( rewardConfig.Reward )
    ply:SendNotification( 0, 3, "Time reward successfully claimed!" )

    claimedRewards[rewardKey] = os.time()
    ply.BOTCHED_CLAIMED_TIMEREWARDS = claimedRewards

    BOTCHED.FUNC.SQLQuery( "INSERT INTO botched_claimed_timerewards( userID, rewardKey, claimTime ) VALUES(" .. ply:GetUserID() .. ", " .. rewardKey .. ", " .. claimedRewards[rewardKey] .. ");" )

    ply:SendUpdateClaimedTimeRewards( rewardKey )
end )

util.AddNetworkString( "Botched.RequestClaimTimeRewards" )
net.Receive( "Botched.RequestClaimTimeRewards", function( len, ply )
    local claimedRewards = ply:GetClaimedTimeRewards()

    local rewardKeys = {}
    for k, v in ipairs( BOTCHED.CONFIG.TimeRewards ) do
        if( claimedRewards[k] or ply:GetTimePlayed() < v.Time ) then continue end
        table.insert( rewardKeys, k )
    end

    if( #rewardKeys < 1 ) then return end

    local rewardTables = {}
    for k, v in ipairs( rewardKeys ) do
        claimedRewards[v] = os.time()
        BOTCHED.FUNC.SQLQuery( "INSERT INTO botched_claimed_timerewards( userID, rewardKey, claimTime ) VALUES(" .. ply:GetUserID() .. ", " .. v .. ", " .. claimedRewards[v] .. ");" )

        table.insert( rewardTables, BOTCHED.CONFIG.TimeRewards[v].Reward )
    end

    ply:GiveReward( BOTCHED.FUNC.MergeRewardTables( unpack( rewardTables ) ) )
    ply:SendNotification( 0, 3, "Time rewards successfully claimed!" )

    ply.BOTCHED_CLAIMED_TIMEREWARDS = claimedRewards
    ply:SendUpdateClaimedTimeRewards( unpack( rewardKeys ) )
end )

-- LOGIN REWARDS --
util.AddNetworkString( "Botched.RequestClaimLoginReward" )
net.Receive( "Botched.RequestClaimLoginReward", function( len, ply )
    if( not ply:CanClaimLoginReward() ) then return end

    local loginStreak = ply:GetLoginRewardStreak()
    local daysClaimed, claimTime = loginStreak+1, BOTCHED.FUNC.UTCTime()

    ply:GiveReward( BOTCHED.CONFIG.LoginRewards[daysClaimed] )
    ply:SetLoginRewardInfo( daysClaimed, claimTime )

    BOTCHED.FUNC.SQLQuery( "SELECT * FROM botched_claimed_loginrewards WHERE userID = '" .. ply:GetUserID() .. "';", function( data )
        if( data ) then
            BOTCHED.FUNC.SQLQuery( "UPDATE botched_claimed_loginrewards SET daysClaimed = " .. daysClaimed .. ", claimTime = " .. claimTime .. " WHERE userID = '" .. ply:GetUserID() .. "';" )
        else
            BOTCHED.FUNC.SQLQuery( "INSERT INTO botched_claimed_loginrewards( userID, daysClaimed, claimTime ) VALUES(" .. ply:GetUserID() .. ", " .. daysClaimed .. ", " .. claimTime .. ");" )
        end
    end, true )

    ply:SendNotification( 0, 3, "Login rewards successfully claimed!" )
end )