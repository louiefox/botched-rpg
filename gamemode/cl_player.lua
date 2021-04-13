-- GENERAL FUNCTIONS --
net.Receive( "Botched.SendUserID", function()
    BOTCHED_USERID = net.ReadUInt( 10 )
end )

net.Receive( "Botched.SendNotification", function()
    notification.AddLegacy( net.ReadString(), net.ReadUInt( 8 ) or 1, net.ReadUInt( 8 ) or 3 )
end )

net.Receive( "Botched.SendChatNotification", function()
    chat.AddText( net.ReadColor(), net.ReadString(), " ", net.ReadColor(), net.ReadString() )
end )

net.Receive( "Botched.SendBottomErrorNotification", function()
    BOTCHED.FUNC.SetBottomErrorNotif( net.ReadString(), net.ReadUInt( 6 ) or 3 )
end )

-- STAMINA FUNCTIONS --
net.Receive( "Botched.SendStamina", function()
    BOTCHED_STAMINA = net.ReadUInt( 16 )
end )

-- GEM FUNCTIONS --
net.Receive( "Botched.SendGems", function()
    BOTCHED_GEMS = net.ReadUInt( 32 )
end )

-- MANA FUNCTIONS --
net.Receive( "Botched.SendMana", function()
    BOTCHED_MANA = net.ReadUInt( 32 )

    hook.Run( "Botched.Hooks.ManaChanged" )
end )

-- MAGICCOINS FUNCTIONS --
net.Receive( "Botched.SendMagicCoins", function()
    BOTCHED_MAGICCOINS = net.ReadUInt( 32 )
end )

-- LEVELLING FUNCTIONS --
net.Receive( "Botched.SendExpNotification", function()
    BOTCHED.FUNC.AddExpNotification( net.ReadUInt( 32 ), net.ReadString() )
end )

net.Receive( "Botched.SendLevelNotification", function()
    BOTCHED.FUNC.AddLevelNotification( net.ReadUInt( 32 ) )
end )

-- MODEL FUNCTIONS --
net.Receive( "Botched.SendChosenCharacter", function()
    BOTCHED_CHOSENCHAR = net.ReadString()

    hook.Run( "Botched.Hooks.ChosenCharacterChanged" )
end )

net.Receive( "Botched.SendOwnedCharacters", function()
    BOTCHED_OWNED_CHARACTERS = net.ReadTable() or {}

    hook.Run( "Botched.Hooks.CharacterUpdated" )
end )

net.Receive( "Botched.SendNewCharacter", function()
    BOTCHED_OWNED_CHARACTERS = BOTCHED_OWNED_CHARACTERS or {}

    local amount = net.ReadUInt( 10 )
    for i = 1, amount do
        BOTCHED_OWNED_CHARACTERS[net.ReadString()] = {}
    end

    hook.Run( "Botched.Hooks.CharacterUpdated" )
end )

-- EQUIPMENT FUNCTIONS --
net.Receive( "Botched.SendEquipment", function()
    BOTCHED_EQUIPMENT = net.ReadTable() or {}

    hook.Run( "Botched.Hooks.EquipmentUpdated" )
end )

net.Receive( "Botched.SendEquipmentPiece", function()
    BOTCHED_EQUIPMENT = BOTCHED_EQUIPMENT or {}

    local amount = net.ReadUInt( 10 )
    for i = 1, amount do
        local equipmentKey = net.ReadString()

        local equipmentData = {}
        if( net.ReadBool() == true ) then
            equipmentData.Rank = net.ReadUInt( 5 ) 
        end

        if( net.ReadBool() == true ) then
            equipmentData.Stars = net.ReadUInt( 5 ) 
        end

        BOTCHED_EQUIPMENT[equipmentKey] = equipmentData
    end

    hook.Run( "Botched.Hooks.EquipmentUpdated" )
end )

-- CHOSEN EQUIPMENT FUNCTIONS --
net.Receive( "Botched.SendChosenEquipment", function()
    BOTCHED_CHOSEN_EQUIPMENT = net.ReadTable() or {}

    hook.Run( "Botched.Hooks.ChosenEquipmentUpdated" )
end )

net.Receive( "Botched.SendChosenEquipmentPiece", function()
    local equipmentKey = net.ReadString()

    local equipmentConfig = BOTCHED.CONFIG.Equipment[equipmentKey]
    if( not equipmentConfig ) then return end

    BOTCHED_CHOSEN_EQUIPMENT = BOTCHED_CHOSEN_EQUIPMENT or {}
    BOTCHED_CHOSEN_EQUIPMENT[equipmentConfig.Type] = equipmentKey

    hook.Run( "Botched.Hooks.ChosenEquipmentUpdated" )
end )

net.Receive( "Botched.SendUnChosenEquipmentPiece", function()
    local equipmentKey = net.ReadString()

    local equipmentConfig = BOTCHED.CONFIG.Equipment[equipmentKey]
    if( not equipmentConfig ) then return end

    BOTCHED_CHOSEN_EQUIPMENT = BOTCHED_CHOSEN_EQUIPMENT or {}
    BOTCHED_CHOSEN_EQUIPMENT[equipmentConfig.Type] = nil

    hook.Run( "Botched.Hooks.ChosenEquipmentUpdated" )
end )

-- INVENTORY FUNCTIONS --
net.Receive( "Botched.SendInventory", function()
    BOTCHED_INVENTORY = net.ReadTable() or {}

    hook.Run( "Botched.Hooks.InventoryUpdated" )
end )

net.Receive( "Botched.SendInventoryItems", function()
    BOTCHED_INVENTORY = BOTCHED_INVENTORY or {}

    local amount = net.ReadUInt( 10 )
    for i = 1, amount do
        local itemKey, itemAmount = net.ReadString(), net.ReadUInt( 32 )
        if( itemAmount > 0 ) then
            BOTCHED_INVENTORY[itemKey] = itemAmount
        else
            BOTCHED_INVENTORY[itemKey] = nil
        end
    end

    hook.Run( "Botched.Hooks.InventoryUpdated" )
end )

net.Receive( "Botched.SendItemNotification", function()
    BOTCHED.FUNC.AddItemNotification( net.ReadString(), net.ReadUInt( 32 ) )
end )

-- COMPLETED QUESTS FUNCTIONS --
net.Receive( "Botched.SendCompletedQuests", function()
    BOTCHED_COMPLETED_QUESTS = net.ReadTable() or {}

    hook.Run( "Botched.Hooks.CompletedQuestsUpdated" )
end )

net.Receive( "Botched.UpdateCompletedQuest", function()
    local questLine, questKey, completedStars = net.ReadUInt( 8 ), net.ReadUInt( 8 ), net.ReadUInt( 2 )

    local completedQuests = LocalPlayer():GetCompletedQuests()
    completedQuests[questLine] = completedQuests[questLine] or {}
    completedQuests[questLine][questKey] = completedStars

    BOTCHED_COMPLETED_QUESTS = completedQuests

    hook.Run( "Botched.Hooks.CompletedQuestsUpdated" )
end )

-- TIME PLAYED FUNCTIONS --
net.Receive( "Botched.SendPreviousTimePlayed", function()
    BOTCHED_PREVIOUS_TIME = net.ReadUInt( 32 ) or 0
end )

net.Receive( "Botched.SendJoinTime", function()
    BOTCHED_JOIN_TIME = net.ReadUInt( 22 ) or 0
end )

net.Receive( "Botched.SendClaimedTimeRewards", function()
    BOTCHED_CLAIMED_TIMEREWARDS = net.ReadTable() or {}

    hook.Run( "Botched.Hooks.ClaimedTimeRewardsUpdated" )
end )

net.Receive( "Botched.SendUpdateClaimedTimeRewards", function()
    BOTCHED_CLAIMED_TIMEREWARDS = BOTCHED_CLAIMED_TIMEREWARDS or {}
    for i = 1, net.ReadUInt( 6 ) do
        BOTCHED_CLAIMED_TIMEREWARDS[net.ReadUInt( 6 )] = net.ReadUInt( 32 )
    end

    hook.Run( "Botched.Hooks.ClaimedTimeRewardsUpdated" )
end )

-- LOGIN REWARD FUNCTIONS --
net.Receive( "Botched.SendLoginRewardInfo", function()
    BOTCHED_LOGIN_DAYSCLAIMED = net.ReadUInt( 5 ) or 0
    BOTCHED_LOGIN_CLAIMTIME = net.ReadUInt( 32 ) or 0

    hook.Run( "Botched.Hooks.LoginRewardsUpdated" )
end )

-- PARTY FUNCTIONS --
net.Receive( "Botched.SendPartyID", function()
    local partyID = net.ReadUInt( 10 ) or 0
    BOTCHED_PARTY_ID = partyID

    if( partyID != 0 and not IsValid( BOTCHED_PARTYHUD ) ) then
        BOTCHED_PARTYHUD = vgui.Create( "botched_hud_party" )
    end

    hook.Run( "Botched.Hooks.PartyIDUpdated" )
end )