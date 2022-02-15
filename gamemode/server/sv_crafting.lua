util.AddNetworkString( "Botched.RequestCraftItem" )
net.Receive( "Botched.RequestCraftItem", function( len, ply )
    local itemKey = net.ReadString()
    local amount = net.ReadUInt( 16 )

    if( not itemKey or not amount or amount < 1 ) then return end

    local itemConfig = BOTCHED.CONFIG.Crafting[itemKey]
    if( not itemConfig ) then return end

    local costTable = amount > 1 and BOTCHED.FUNC.ChangeCostRewardAmount( itemConfig.Cost, amount ) or itemConfig.Cost
    if( not ply:CanAffordCost( costTable ) ) then
        ply:SendNotification( 1, 5, "You cannot afford this!" )
        return
    end

    if( itemConfig.Reward.Equipment ) then
        if( amount > 1 ) then
            ply:SendNotification( 1, 5, "You cannot craft more than one at a time!" )
            return
        end

        local equipment = ply:GetEquipment()
        for k, v in ipairs( itemConfig.Reward.Equipment ) do
            if( equipment[v] ) then 
                ply:SendNotification( 1, 5, "You already have this piece of equipment!" )
                return 
            end
        end
    end

    ply:TakeCost( costTable )
    ply:GiveReward( amount > 1 and BOTCHED.FUNC.ChangeCostRewardAmount( itemConfig.Reward, amount ) or itemConfig.Reward )

    ply:SendNotification( 0, 5, "Successfully crafted " .. (itemConfig.Name or (itemConfig.ItemInfo or {}).Name) .. "!" )
end )