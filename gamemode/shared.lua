GM.Name = "gMMO"
GM.Author = "Brickwall & dotCore"
GM.Email = "N/A"
GM.Website = "waurum.net"

BOTCHED = {
    FUNC = {},
    CONFIG = {},
    TEMP = (BOTCHED and BOTCHED.TEMP) or {}
}

local function AddSharedFile( filePath )
	AddCSLuaFile( filePath )
	include( filePath )
end

AddSharedFile( "shared/sh_devconfig.lua" )

AddSharedFile( "config/cfg_main.lua" )
AddSharedFile( "config/cfg_admin.lua" )
AddSharedFile( "config/cfg_levelling.lua" )
AddSharedFile( "config/cfg_characters.lua" )
AddSharedFile( "config/cfg_equipment.lua" )
AddSharedFile( "config/cfg_items.lua" )
AddSharedFile( "config/cfg_crafting.lua" )
AddSharedFile( "config/cfg_store.lua" )
AddSharedFile( "config/cfg_monsters.lua" )
AddSharedFile( "config/cfg_quests.lua" )

AddSharedFile( "shared/sh_player.lua" )
AddSharedFile( "shared/sh_weapons.lua" )
AddSharedFile( "shared/sh_party_system.lua" )

function GM:Initialize()

end

function BOTCHED.FUNC.FormatWordTime( time )
	local timeText = (time != 1 and string.format( "%d seconds", time )) or string.format( "%d second", time )

	if( time >= 60 ) then
		if( time < 3600 ) then
			local minutes = math.floor( time/60 )
			timeText = (minutes != 1 and string.format( "%d minutes", minutes )) or string.format( "%d minute", minutes )
		else
			if( time < 86400 ) then
				local hours = math.floor( time/3600 )
				timeText = (hours != 1 and string.format( "%d hours", hours )) or string.format( "%d hour", hours )
			else
				local days = math.floor( time/86400 )
				timeText = (days != 1 and string.format( "%d days", days )) or string.format( "%d day", days )
			end
		end
	end

	return timeText
end

function BOTCHED.FUNC.FormatLetterTime( time )
	local timeTable = string.FormattedTime( time )
	local days = math.floor( timeTable.h/24 )

	local formattedTime
	if( days > 0 ) then
		formattedTime = string.format( "%dd %dh", days, timeTable.h-(days*24) )
	elseif( timeTable.h > 0 ) then
		formattedTime = string.format( "%dh %dm", timeTable.h, timeTable.m )
	else
		formattedTime = string.format( "%dm %ds", timeTable.m, timeTable.s )
	end

	return formattedTime
end

function BOTCHED.FUNC.ChangeCostRewardAmount( oldTable, amount )
	local newTable = {}

	if( oldTable.Gems ) then
		newTable.Gems = oldTable.Gems*amount
	end

	if( oldTable.Mana ) then
		newTable.Mana = oldTable.Mana*amount
	end

	if( oldTable.Items ) then
		newTable.Items = {}
		for k, v in pairs( oldTable.Items ) do
			newTable.Items[k] = v*amount
		end
	end

	return newTable
end

function BOTCHED.FUNC.MergeRewardTables( ... )
	local rewardsTable = {}
	for _, tableToAdd in pairs( { ... } ) do
		if( tableToAdd.Items ) then
			rewardsTable.Items = rewardsTable.Items or {}
			for k, v in pairs( tableToAdd.Items ) do
				rewardsTable.Items[k] = (rewardsTable.Items[k] or 0)+v
			end
		end

		for k, v in pairs( tableToAdd ) do
			if( istable( v ) ) then 
				if( k == "Equipment" or k == "Characters" ) then
					rewardsTable[k] = rewardsTable[k] or {}
					for key, val in pairs( v ) do
						table.insert( rewardsTable[k], val )
					end
				end

				continue
			end

			rewardsTable[k] = (rewardsTable[k] or 0)+v
		end
	end

	return rewardsTable
end

function BOTCHED.FUNC.GetNextLoginRewardTime()
	local currentDate = os.date( "!*t" )

	local nextDate = table.Copy( currentDate )
	nextDate.hour = 13
	nextDate.min = 0
	nextDate.sec = 0
	nextDate = os.time( nextDate )

	if( currentDate.hour >= 13 ) then
		nextDate = nextDate+86400
	end

	return nextDate
end

function BOTCHED.FUNC.UTCTime()
	return os.time( os.date( "!*t" ) )
end

// test