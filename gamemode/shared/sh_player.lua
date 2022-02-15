local playerMeta = FindMetaTable( "Player" )

-- GENERAL FUNCTIONS --
function playerMeta:GetUserID()
	if( CLIENT and self == LocalPlayer() ) then
		return BOTCHED_USERID or 0
	else
		return self.BOTCHED_USERID or 0
	end
end

function playerMeta:CanAffordCost( costTable )
	if( costTable.Mana and self:GetMana() < costTable.Mana ) then
		return false
	end

	if( costTable.Gems and self:GetGems() < costTable.Gems ) then
		return false
	end

	if( costTable.Items and not self:HasItems( costTable.Items ) ) then
		return false
	end

	return true
end

-- STAMINA FUNCTIONS --
function playerMeta:Stamina()
	if( CLIENT and self == LocalPlayer() ) then
		return BOTCHED_STAMINA or 0
	else
		return self.BOTCHED_STAMINA or 0
	end
end

function playerMeta:GetMaxStamina()
	return 99+self:GetLevel()
end

-- GEM FUNCTIONS --
function playerMeta:GetGems()
	if( CLIENT and self == LocalPlayer() ) then
		return BOTCHED_GEMS or 0
	else
		return self.BOTCHED_GEMS or 0
	end
end

-- MANA FUNCTIONS --
function playerMeta:GetMana()
	if( CLIENT and self == LocalPlayer() ) then
		return BOTCHED_MANA or 0
	else
		return self.BOTCHED_MANA or 0
	end
end

-- MAGICCOINS FUNCTIONS --
function playerMeta:GetMagicCoins()
	if( CLIENT and self == LocalPlayer() ) then
		return BOTCHED_MAGICCOINS or 0
	else
		return self.BOTCHED_MAGICCOINS or 0
	end
end

-- LEVELLING FUNCTIONS --
function playerMeta:GetLevel()
	return self:GetNWInt( "Level", 1 )
end

function playerMeta:GetExperience()
	return self:GetNWInt( "Experience", 0 )
end

-- CHARACTER FUNCTIONS --
function playerMeta:GetChosenCharacter()
	local characterKey = (CLIENT and BOTCHED_CHOSENCHAR or self.BOTCHED_CHOSENCHAR) or "default"

	return BOTCHED.CONFIG.Characters[characterKey].Model, characterKey
end

function playerMeta:GetOwnedCharacters()
	return (CLIENT and BOTCHED_OWNED_CHARACTERS or self.BOTCHED_OWNED_CHARACTERS) or {}
end

-- EQUIPMENT FUNCTIONS --
function playerMeta:GetEquipment()
	return (CLIENT and BOTCHED_EQUIPMENT or self.BOTCHED_EQUIPMENT) or {}
end

-- CHOSEN EQUIPMENT FUNCTIONS --
function playerMeta:GetChosenEquipment()
	return (CLIENT and BOTCHED_CHOSEN_EQUIPMENT or self.BOTCHED_CHOSEN_EQUIPMENT) or {}
end

function playerMeta:GetChosenWeapon( equipmentKey )
	if( not equipmentKey ) then return end
	
	local chosenEquipment = self:GetChosenEquipment()
	local weaponClass = (BOTCHED.CONFIG.Equipment[chosenEquipment[equipmentKey] or ""] or {}).Class

	return self:GetWeapon( weaponClass )
end

function playerMeta:SelectPrimaryWeapon()
	local chosenEquipment = self:GetChosenEquipment()
	local weaponClass = (BOTCHED.CONFIG.Equipment[chosenEquipment.primaryWeapon or ""] or {}).Class

	if( not weaponClass or not self:HasWeapon( weaponClass ) ) then
		weaponClass = "weapon_hands"
	end

	if( SERVER ) then
		self:SelectWeapon( weaponClass )
	else
		local weaponEnt = self:GetWeapon( weaponClass )
		if( not IsValid( weaponEnt ) ) then return end

		input.SelectWeapon( weaponEnt )
	end
end

-- INVENTORY FUNCTIONS --
function playerMeta:GetInventory()
	return (CLIENT and BOTCHED_INVENTORY or self.BOTCHED_INVENTORY) or {}
end

function playerMeta:HasItems( itemsTable )
	local inventory = self:GetInventory()
	for k, v in pairs( itemsTable ) do
		if( (inventory[k] or 0) < v ) then return false end
	end

	return true
end

-- COMPLETED QUEST FUNCTIONS --
function playerMeta:GetCompletedQuests()
	return (CLIENT and BOTCHED_COMPLETED_QUESTS or self.BOTCHED_COMPLETED_QUESTS) or {}
end

-- TIME PLAYED FUNCTIONS --
function playerMeta:GetTimePlayed()
	return ((CLIENT and BOTCHED_PREVIOUS_TIME or self.BOTCHED_PREVIOUS_TIME) or 0)+(CurTime()-((CLIENT and BOTCHED_JOIN_TIME or self.BOTCHED_JOIN_TIME) or 0))
end

function playerMeta:GetClaimedTimeRewards()
	return (CLIENT and BOTCHED_CLAIMED_TIMEREWARDS or self.BOTCHED_CLAIMED_TIMEREWARDS) or {}
end

-- PLAYER REGEN FUNCTIONS --
function playerMeta:GetHealthRegenAmount()
	return 5
end

-- LOGIN REWARD FUNCTIONS --
function playerMeta:GetLoginRewardInfo()
	local daysClaimed, claimTime = (CLIENT and BOTCHED_LOGIN_DAYSCLAIMED or self.BOTCHED_LOGIN_DAYSCLAIMED) or 0, (CLIENT and BOTCHED_LOGIN_CLAIMTIME or self.BOTCHED_LOGIN_CLAIMTIME) or 0

	return daysClaimed, claimTime
end

function playerMeta:CanClaimLoginReward()
	local daysClaimed, claimTime = self:GetLoginRewardInfo()

	if( claimTime < BOTCHED.FUNC.GetNextLoginRewardTime()-86400 ) then return true end

	return false
end

function playerMeta:GetLoginRewardStreak()
	local daysClaimed, claimTime = self:GetLoginRewardInfo()

	if( daysClaimed > 0 and (claimTime < BOTCHED.FUNC.GetNextLoginRewardTime()-(2*86400) or daysClaimed >= 30) ) then return 0 end

	return daysClaimed
end

-- ABILITY/EFFECT FUNCTIONS --
function playerMeta:GetPlayerEffects()
	return (CLIENT and BOTCHED_PLAYER_EFFECTS or self.BOTCHED_PLAYER_EFFECTS) or {}
end

function playerMeta:GetAbilities()
	return {
		[1] = "heal",
		[2] = "frost_ball",
		[3] = "charge",
		[9] = "speed",
	}
end

function playerMeta:GetAbilityCooldowns()
	return (CLIENT and BOTCHED_ABILITY_COOLDOWNS or self.BOTCHED_ABILITY_COOLDOWNS) or {}
end

-- PARTY FUNCTIONS --
function playerMeta:GetPartyID()
	return (CLIENT and BOTCHED_PARTY_ID or self.BOTCHED_PARTY_ID) or 0
end

/*
	Function - Privilege checking
*/
function playerMeta:HasAdminPrivilege()
	if (BOTCHED.CONFIG.UseInBuiltSystem) then
		return (table.HasValue(BOTCHED.CONFIG.GameMasters, self:SteamID64()) and true) or false
	else
		return (table.HasValue(BOTCHED.CONFIG.ThirdPartyRanks, self:GetUsergroup()) and true) or false
	end
end