local playerMeta = FindMetaTable( "Player" )

-- GENERAL FUNCTIONS --
util.AddNetworkString( "Botched.SendUserID" )
function playerMeta:SetUserID( userID )
    self.BOTCHED_USERID = userID

    net.Start( "Botched.SendUserID" )
        net.WriteUInt( userID, 10 )
    net.Send( self )
end

util.AddNetworkString( "Botched.SendNotification" )
function playerMeta:SendNotification( type, time, message )
	net.Start( "Botched.SendNotification" )
		net.WriteString( message or "" )
		net.WriteUInt( (type or 1), 8)
		net.WriteUInt( (time or 3), 8)
	net.Send( self )
end

util.AddNetworkString( "Botched.SendChatNotification" )
function playerMeta:SendChatNotification( tagColor, tagString, msgColor, msgString )
    local whiteColor = Color( 255, 255, 255 )
	net.Start( "Botched.SendChatNotification" )
		net.WriteColor( tagColor or whiteColor )
		net.WriteString( tagString or "" )
		net.WriteColor( msgColor or whiteColor )
		net.WriteString( msgString or "" )
	net.Send( self )
end

util.AddNetworkString( "Botched.SendBottomErrorNotification" )
function playerMeta:SendChatNotification( text, time )
	net.Start( "Botched.SendBottomErrorNotification" )
		net.WriteString( text or "" )
        net.WriteUInt( time, 6 )
	net.Send( self )
end

function playerMeta:TakeCost( costTable )
    if( costTable.Gems ) then self:TakeGems( costTable.Gems ) end
    if( costTable.Mana ) then self:TakeMana( costTable.Mana ) end
    if( costTable.MagicCoins ) then self:TakeMagicCoins( costTable.MagicCoins ) end

    if( costTable.Items ) then
        local itemsToTake = {}
        for k, v in pairs( costTable.Items ) do
            table.insert( itemsToTake, k )
            table.insert( itemsToTake, v )
        end

        self:TakeInventoryItems( unpack( itemsToTake ) )
    end
end

function playerMeta:GiveReward( rewardTable )
    if( rewardTable.Gems ) then self:AddGems( rewardTable.Gems ) end
    if( rewardTable.Mana ) then self:AddMana( rewardTable.Mana ) end
    if( rewardTable.MagicCoins ) then self:AddMagicCoins( rewardTable.MagicCoins ) end

    if( rewardTable.Equipment ) then self:GiveEquipment( unpack( rewardTable.Equipment ) ) end
    if( rewardTable.Characters ) then self:GiveCharacters( unpack( rewardTable.Characters ) ) end

    if( rewardTable.Items ) then
        local itemsToGive = {}
        for k, v in pairs( rewardTable.Items ) do
            table.insert( itemsToGive, k )
            table.insert( itemsToGive, v )
        end

        self:AddInventoryItems( unpack( itemsToGive ) )
    end
end

-- STAMINA FUNCTIONS --
util.AddNetworkString( "Botched.SendStamina" )
function playerMeta:SetStamina( stamina, dontSave )
    self.BOTCHED_STAMINA = stamina
    
    net.Start( "Botched.SendStamina" )
        net.WriteUInt( stamina, 16 )
    net.Send( self )
    
    if( not dontSave ) then
        BOTCHED.FUNC.SQLQuery( "UPDATE botched_players SET stamina = " .. stamina .. " WHERE userID = '" .. self:GetUserID() .. "';" )
    end
end

function playerMeta:AddStamina( amount )
    self:SetStamina( self:Stamina()+amount )
end

function playerMeta:TakeStamina( amount )
    self:SetStamina( self:Stamina()-amount )
end

-- GEM FUNCTIONS --
util.AddNetworkString( "Botched.SendGems" )
function playerMeta:SetGems( gems, dontSave )
    self.BOTCHED_GEMS = gems
    
    net.Start( "Botched.SendGems" )
        net.WriteUInt( gems, 32 )
    net.Send( self )
    
    if( not dontSave ) then
        BOTCHED.FUNC.SQLQuery( "UPDATE botched_players SET gems = " .. gems .. " WHERE userID = '" .. self:GetUserID() .. "';" )
    end
end

function playerMeta:AddGems( amount )
    self:SetGems( self:GetGems()+amount )
end

function playerMeta:TakeGems( amount )
    self:SetGems( self:GetGems()-amount )
end

-- MANA FUNCTIONS --
util.AddNetworkString( "Botched.SendMana" )
function playerMeta:SetMana( mana, dontSave )
    self.BOTCHED_MANA = mana
    
    net.Start( "Botched.SendMana" )
        net.WriteUInt( mana, 32 )
    net.Send( self )
    
    if( not dontSave ) then
        BOTCHED.FUNC.SQLQuery( "UPDATE botched_players SET mana = " .. mana .. " WHERE userID = '" .. self:GetUserID() .. "';" )
    end
end

function playerMeta:AddMana( amount )
    self:SetMana( self:GetMana()+amount )
end

function playerMeta:TakeMana( amount )
    self:SetMana( self:GetMana()-amount )
end

-- MAGICCOINS FUNCTIONS --
util.AddNetworkString( "Botched.SendMagicCoins" )
function playerMeta:SetMagicCoins( magicCoins, dontSave )
    self.BOTCHED_MAGICCOINS = magicCoins
    
    net.Start( "Botched.SendMagicCoins" )
        net.WriteUInt( magicCoins, 32 )
    net.Send( self )
    
    if( not dontSave ) then
        BOTCHED.FUNC.SQLQuery( "UPDATE botched_players SET magicCoins = " .. magicCoins .. " WHERE userID = '" .. self:GetUserID() .. "';" )
    end
end

function playerMeta:AddMagicCoins( amount )
    self:SetMagicCoins( self:GetMagicCoins()+amount )
end

function playerMeta:TakeMagicCoins( amount )
    self:SetMagicCoins( self:GetMagicCoins()-amount )
end

-- LEVELLING FUNCTIONS --
function playerMeta:SetLevel( level, dontSave )
    self:SetNWInt( "Level", level )
    
    if( not dontSave ) then
        BOTCHED.FUNC.SQLQuery( "UPDATE botched_players SET level = " .. level .. " WHERE userID = '" .. self:GetUserID() .. "';" )
    end
end

function playerMeta:AddLevel( amount )
    self:SetLevel( self:GetLevel()+amount )

    self:SendLevelNotification( self:GetLevel() )
end

function playerMeta:SetExperience( experience, dontSave )
    self:SetNWInt( "Experience", experience )
    
    if( not dontSave ) then
        BOTCHED.FUNC.SQLQuery( "UPDATE botched_players SET experience = " .. experience .. " WHERE userID = '" .. self:GetUserID() .. "';" )
    end
end

function playerMeta:CheckLevelUp()
    local nextLevelTable = BOTCHED.CONFIG.Levels[self:GetLevel()+1]
    if( nextLevelTable and self:GetExperience() >= nextLevelTable.RequiredEXP ) then
        self:TakeExperience( nextLevelTable.RequiredEXP )
        self:AddLevel( 1 )
        self:AddStamina( self:GetMaxStamina() )
        self:CheckLevelUp()
	end
end

function playerMeta:AddExperience( amount )
    amount = math.max( amount or 0, 0 )
    self:SetExperience( self:GetExperience()+amount )

    self:CheckLevelUp()
end

function playerMeta:TakeExperience( amount )
    amount = math.max( amount or 0, 0 )
    self:SetExperience( self:GetExperience()-amount )
end

util.AddNetworkString( "Botched.SendExpNotification" )
function playerMeta:SendExpNotification( amount, reason )
	net.Start( "Botched.SendExpNotification" )
		net.WriteUInt( amount, 32 )
		net.WriteString( reason )
	net.Send( self )
end

util.AddNetworkString( "Botched.SendLevelNotification" )
function playerMeta:SendLevelNotification( newLevel )
	net.Start( "Botched.SendLevelNotification" )
		net.WriteUInt( newLevel, 32 )
	net.Send( self )
end

-- MODEL FUNCTIONS --
util.AddNetworkString( "Botched.SendChosenCharacter" )
function playerMeta:SetChosenCharacter( characterKey, dontSave )
    self.BOTCHED_CHOSENCHAR = characterKey

    net.Start( "Botched.SendChosenCharacter" )
        net.WriteString( characterKey )
    net.Send( self )

    self:SetModel( self:GetChosenCharacter() )
    self:SetupHands()

    if( not dontSave ) then
        BOTCHED.FUNC.SQLQuery( "UPDATE botched_players SET character = '" .. characterKey .. "' WHERE userID = '" .. self:GetUserID() .. "';" )
    end
end

util.AddNetworkString( "Botched.SendOwnedCharacters" )
function playerMeta:SetCharacters( ownedCharacters )
    self.BOTCHED_OWNED_CHARACTERS = ownedCharacters

    net.Start( "Botched.SendOwnedCharacters" )
        net.WriteTable( ownedCharacters )
    net.Send( self )
end

util.AddNetworkString( "Botched.SendNewCharacter" )
function playerMeta:GiveCharacters( ... )
    local modelsToGive = { ... }

    local modelsGiven = {}
    local ownedCharacters = self:GetOwnedCharacters()
    for k, v in ipairs( modelsToGive ) do
        if( not BOTCHED.CONFIG.Characters[v] ) then return end

        if( not ownedCharacters[v] ) then
            ownedCharacters[v] = {}

            BOTCHED.FUNC.SQLQuery( "INSERT INTO botched_owned_characters( userID, characterKey ) VALUES(" .. self:GetUserID() .. ", '" .. v .. "');" )

            table.insert( modelsGiven, v )
        end
    end

    if( #modelsGiven < 1 ) then return end

    self.BOTCHED_OWNED_CHARACTERS = ownedCharacters

    net.Start( "Botched.SendNewCharacter" )
        net.WriteUInt( #modelsGiven, 10 )
        for k, v in ipairs( modelsGiven ) do
            net.WriteString( v )
        end
    net.Send( self )
end

-- EQUIPMENT FUNCTIONS --
util.AddNetworkString( "Botched.SendEquipment" )
function playerMeta:SetEquipment( equipment )
    self.BOTCHED_EQUIPMENT = equipment

    net.Start( "Botched.SendEquipment" )
        net.WriteTable( equipment )
    net.Send( self )
end

util.AddNetworkString( "Botched.SendEquipmentPiece" )
function playerMeta:GiveEquipment( ... )
    local equipmentToGive = { ... }

    local equipmentGiven = {}
    local equipment = self:GetEquipment()
    for k, v in ipairs( equipmentToGive ) do
        if( not BOTCHED.CONFIG.Equipment[v] or equipment[v] ) then continue end

        equipment[v] = {}

        BOTCHED.FUNC.SQLQuery( "INSERT INTO botched_owned_equipment( userID, equipmentKey ) VALUES(" .. self:GetUserID() .. ", '" .. v .. "');" )

        table.insert( equipmentGiven, v )
    end

    if( #equipmentGiven < 1 ) then return end

    self.BOTCHED_EQUIPMENT = equipment

    net.Start( "Botched.SendEquipmentPiece" )
        net.WriteUInt( #equipmentGiven, 10 )
        for k, v in ipairs( equipmentGiven ) do
            net.WriteString( v )

            net.WriteBool( equipment[v].Rank != nil )
            if( equipment[v].Rank ) then
                net.WriteUInt( equipment[v].Rank, 5 )
            end

            net.WriteBool( equipment[v].Stars != nil )
            if( equipment[v].Stars ) then
                net.WriteUInt( equipment[v].Stars, 5 )
            end
        end
    net.Send( self )
end

-- CHOSEN EQUIPMENT FUNCTIONS --
util.AddNetworkString( "Botched.SendChosenEquipment" )
function playerMeta:SetChosenEquipment( chosenEquipment )
    self.BOTCHED_CHOSEN_EQUIPMENT = chosenEquipment

    net.Start( "Botched.SendChosenEquipment" )
        net.WriteTable( chosenEquipment )
    net.Send( self )
end

-- INVENTORY FUNCTIONS --
util.AddNetworkString( "Botched.SendInventory" )
function playerMeta:SetInventory( inventory )
    self.BOTCHED_INVENTORY = inventory

    net.Start( "Botched.SendInventory" )
        net.WriteTable( inventory )
    net.Send( self )
end

util.AddNetworkString( "Botched.SendInventoryItems" )
function playerMeta:SendInventoryItems( itemsTable )
    net.Start( "Botched.SendInventoryItems" )
        net.WriteUInt( table.Count( itemsTable ), 10 )
        for k, v in pairs( itemsTable ) do
            net.WriteString( k )
            net.WriteUInt( v, 32 )
        end
    net.Send( self )
end

function playerMeta:AddInventoryItems( ... )
    local itemsToGive = { ... }

    local itemsGiven = {}
    local inventory = self:GetInventory()
    for k, v in ipairs( itemsToGive ) do
        if( k % 2 == 0 or not BOTCHED.CONFIG.Items[v] ) then continue end

        inventory[v] = (inventory[v] or 0)+(itemsToGive[k+1] or 1)

        BOTCHED.FUNC.SQLQuery( "INSERT OR REPLACE INTO botched_inventory( userID, itemKey, amount ) VALUES(" .. self:GetUserID() .. ", '" .. v .. "'," .. inventory[v] .. ");" )

        itemsGiven[v] = inventory[v]
    end

    if( table.Count( itemsGiven ) < 1 ) then return end

    self.BOTCHED_INVENTORY = inventory
    self:SendInventoryItems( itemsGiven )
end

function playerMeta:TakeInventoryItems( ... )
    local itemsToTake = { ... }

    local itemsTaken = {}
    local inventory = self:GetInventory()
    for k, v in ipairs( itemsToTake ) do
        if( k % 2 == 0 or not BOTCHED.CONFIG.Items[v] ) then continue end

        local newAmount = (inventory[v] or 0)-(itemsToTake[k+1] or 1)

        if( newAmount > 0 ) then
            inventory[v] = newAmount
        else
            inventory[v] = nil
        end

        if( newAmount > 0 ) then
            BOTCHED.FUNC.SQLQuery( "INSERT OR REPLACE INTO botched_inventory( userID, itemKey, amount ) VALUES(" .. self:GetUserID() .. ", '" .. v .. "'," .. newAmount .. ");" )
        else
            BOTCHED.FUNC.SQLQuery( "DELETE FROM botched_inventory WHERE userID = '" .. self:GetUserID() .. "' AND itemKey = '" .. v .. "';" )
        end

        itemsTaken[v] = newAmount
    end

    if( table.Count( itemsTaken ) < 1 ) then return end

    self.BOTCHED_INVENTORY = inventory
    self:SendInventoryItems( itemsTaken )
end

util.AddNetworkString( "Botched.SendItemNotification" )
function playerMeta:SendItemNotification( itemKey, amount )
    net.Start( "Botched.SendItemNotification" )
        net.WriteString( itemKey )
        net.WriteUInt( amount, 32 )
    net.Send( self )
end

-- COMPLETED QUEST FUNCTIONS --
util.AddNetworkString( "Botched.SendCompletedQuests" )
function playerMeta:SetCompletedQuests( completedQuests )
    self.BOTCHED_COMPLETED_QUESTS = completedQuests

    net.Start( "Botched.SendCompletedQuests" )
        net.WriteTable( completedQuests )
    net.Send( self )
end

util.AddNetworkString( "Botched.UpdateCompletedQuest" )
function playerMeta:UpdateQuestStars( questLine, questKey, completedStars )
    local completedQuests = self:GetCompletedQuests()
    completedQuests[questLine] = completedQuests[questLine] or {}
    completedQuests[questLine][questKey] = completedStars

    self.BOTCHED_COMPLETED_QUESTS = completedQuests

    net.Start( "Botched.UpdateCompletedQuest" )
        net.WriteUInt( questLine, 8 )
        net.WriteUInt( questKey, 8 )
        net.WriteUInt( completedStars, 2 )
    net.Send( self )

    local userID = self:GetUserID()
    BOTCHED.FUNC.SQLQuery( "SELECT * FROM botched_completed_quests WHERE userID = '" .. userID .. "' AND questLineKey = '" .. questLine .. "' AND questKey = '" .. questKey .. "';", function( data )
        if( data ) then
            BOTCHED.FUNC.SQLQuery( "UPDATE botched_completed_quests SET completionStars = '" .. completedStars .. "' WHERE userID = '" .. userID .. "' AND questLineKey = '" .. questLine .. "' AND questKey = '" .. questKey .. "';" )
        else
            BOTCHED.FUNC.SQLQuery( "INSERT INTO botched_completed_quests( userID, questLineKey, questKey, completionStars ) VALUES(" .. userID .. ", " .. questLine .. ", " .. questKey .. ", " .. completedStars .. ");" )
        end
    end, true )
end

-- TIME PLAYED FUNCTIONS --
util.AddNetworkString( "Botched.SendPreviousTimePlayed" )
function playerMeta:SetPreviousTimePlayed( previousTime )
    self.BOTCHED_PREVIOUS_TIME = previousTime

    net.Start( "Botched.SendPreviousTimePlayed" )
        net.WriteUInt( previousTime, 32 )
    net.Send( self )
end

util.AddNetworkString( "Botched.SendJoinTime" )
function playerMeta:SetJoinTime( joinTime )
    self.BOTCHED_JOIN_TIME = joinTime

    net.Start( "Botched.SendJoinTime" )
        net.WriteUInt( joinTime, 22 )
    net.Send( self )
end

util.AddNetworkString( "Botched.SendClaimedTimeRewards" )
function playerMeta:SetClaimedTimeRewards( claimedRewards )
    self.BOTCHED_CLAIMED_TIMEREWARDS = claimedRewards

    net.Start( "Botched.SendClaimedTimeRewards" )
        net.WriteTable( claimedRewards )
    net.Send( self )
end

util.AddNetworkString( "Botched.SendUpdateClaimedTimeRewards" )
function playerMeta:SendUpdateClaimedTimeRewards( ... )
    local rewardKeys = { ... }

    net.Start( "Botched.SendUpdateClaimedTimeRewards" )
        net.WriteUInt( #rewardKeys, 6 )
        for k, v in ipairs( rewardKeys ) do
            net.WriteUInt( v, 6 )
            net.WriteUInt( self.BOTCHED_CLAIMED_TIMEREWARDS[v] or 0, 32 )
        end
    net.Send( self )
end

-- LOGIN REWARD FUNCTIONS --
util.AddNetworkString( "Botched.SendLoginRewardInfo" )
function playerMeta:SetLoginRewardInfo( daysClaimed, claimTime )
    self.BOTCHED_LOGIN_DAYSCLAIMED = daysClaimed
    self.BOTCHED_LOGIN_CLAIMTIME = claimTime

    net.Start( "Botched.SendLoginRewardInfo" )
        net.WriteUInt( daysClaimed, 5 )
        net.WriteUInt( claimTime, 32 )
    net.Send( self )
end

-- ABILITY/EFFECT FUNCTIONS --
util.AddNetworkString( "Botched.SendPlayerEffectAdded" )
util.AddNetworkString( "Botched.SendPlayerEffectRemoved" )
function playerMeta:AddPlayerEffect( effect, duration, ... )
    local effectConfig = BOTCHED.DEVCONFIG.PlayerEffects[effect]
    if( not effectConfig ) then return end

    local varArgs = { ... }
    effectConfig.StartFunc( self, ... )

    local playerEffects = self:GetPlayerEffects()
    playerEffects[effect] = { CurTime(), duration }

    self.BOTCHED_PLAYER_EFFECTS = playerEffects

    timer.Simple( duration, function()
        if( not IsValid( self ) ) then return end
        effectConfig.EndFunc( self, unpack( varArgs ) )

        local playerEffects = self:GetPlayerEffects()
        playerEffects[effect] = nil
        self.BOTCHED_PLAYER_EFFECTS = playerEffects

        net.Start( "Botched.SendPlayerEffectRemoved" )
            net.WriteString( effect )
        net.Send( self )
    end )

    net.Start( "Botched.SendPlayerEffectAdded" )
        net.WriteString( effect )
        net.WriteUInt( playerEffects[effect][1], 22 )
        net.WriteUInt( duration, 16 )
    net.Send( self )
end

function playerMeta:SetSpeedMultiplier( multiplier )
    self:SetCrouchedWalkSpeed( 0.75*multiplier )
    self:SetWalkSpeed( 150*multiplier )
    self:SetRunSpeed( 200*multiplier )
end

-- PARTY FUNCTIONS --
util.AddNetworkString( "Botched.SendPartyID" )
function playerMeta:SetPartyID( partyID )
	self.BOTCHED_PARTY_ID = partyID

    net.Start( "Botched.SendPartyID" )
        net.WriteUInt( partyID, 10 )
    net.Send( self )
end

util.AddNetworkString( "Botched.SendPartyTable" )
function playerMeta:SendPartyTable( partyID )
    local partyTable = BOTCHED.FUNC.GetPartyTable( partyID )
    if( not partyTable ) then return end

    net.Start( "Botched.SendPartyTable" )
        net.WriteUInt( partyID, 10 )
        net.WriteEntity( partyTable.Leader )

        net.WriteUInt( #partyTable.Members, 3 )
        for k, v in ipairs( partyTable.Members ) do
            net.WriteEntity( v )
        end
    net.Send( self )
end