function BOTCHED.FUNC.SQLQuery( queryStr, func, singleRow )
	local query
	if( not singleRow ) then
		query = sql.Query( queryStr )
	else
		query = sql.QueryRow( queryStr, 1 )
	end
	
	if( query == false ) then
		print( "[Botched SQLLite] ERROR", sql.LastError() )
	elseif( func ) then
		func( query )
	end
end

-- PLAYERS --
if( not sql.TableExists( "botched_players" ) ) then
	BOTCHED.FUNC.SQLQuery( [[ CREATE TABLE botched_players ( 
		userID INTEGER PRIMARY KEY AUTOINCREMENT,
		steamID64 varchar(20) NOT NULL UNIQUE,
		stamina int,
		gems int,
		mana int,
		magicCoins int,
		level int,
		experience int,
		timePlayed int,
		lastPlayed int,
		character varchar(25)
	); ]] )
end

print( "[Botched SQLLite] botched_players table validated!" )

-- PLAYERMODELS --
if( not sql.TableExists( "botched_owned_characters" ) ) then
	BOTCHED.FUNC.SQLQuery( [[ CREATE TABLE botched_owned_characters ( 
		userID int NOT NULL,
		characterKey varchar(25) NOT NULL
	); ]] )
end

print( "[Botched SQLLite] botched_owned_characters table validated!" )

-- EQUIPMENT --
if( not sql.TableExists( "botched_owned_equipment" ) ) then
	BOTCHED.FUNC.SQLQuery( [[ CREATE TABLE botched_owned_equipment (
		userID int NOT NULL,
		equipmentKey varchar(20) NOT NULL,
		stars int,
		rank int
	); ]] )
end

print( "[Botched SQLLite] botched_owned_equipment table validated!" )

-- CHOSEN EQUIPMENT --
if( not sql.TableExists( "botched_chosen_equipment" ) ) then
	BOTCHED.FUNC.SQLQuery( [[ CREATE TABLE botched_chosen_equipment ( 
		userID int NOT NULL,
		primaryWeapon varchar(20),
		secondaryWeapon varchar(20),
		pickaxe varchar(20),
		hatchet varchar(20),
		trinket1 varchar(20),
		trinket2 varchar(20),
		armour varchar(20)
	); ]] )
end

print( "[Botched SQLLite] botched_chosen_equipment table validated!" )

-- INVENTORY --
if( not sql.TableExists( "botched_inventory" ) ) then
	BOTCHED.FUNC.SQLQuery( [[ CREATE TABLE botched_inventory (
		userID int NOT NULL,
		itemKey varchar(20) NOT NULL,
		amount int
	); ]] )
end

print( "[Botched SQLLite] botched_inventory table validated!" )

-- QUESTS --
if( not sql.TableExists( "botched_completed_quests" ) ) then
	BOTCHED.FUNC.SQLQuery( [[ CREATE TABLE botched_completed_quests (
		userID int NOT NULL,
		questLineKey int NOT NULL,
		questKey int NOT NULL,
		completionStars int
	); ]] )
end

print( "[Botched SQLLite] botched_completed_quests table validated!" )

-- TIME REWARDS --
if( not sql.TableExists( "botched_claimed_timerewards" ) ) then
	BOTCHED.FUNC.SQLQuery( [[ CREATE TABLE botched_claimed_timerewards (
		userID int NOT NULL,
		rewardKey int NOT NULL,
		claimTime int NOT NULL
	); ]] )
end

print( "[Botched SQLLite] botched_claimed_timerewards table validated!" )

-- LOGIN REWARDS --
if( not sql.TableExists( "botched_claimed_loginrewards" ) ) then
	BOTCHED.FUNC.SQLQuery( [[ CREATE TABLE botched_claimed_loginrewards (
		userID int NOT NULL,
		daysClaimed int NOT NULL,
		claimTime int NOT NULL
	); ]] )
end

print( "[Botched SQLLite] botched_claimed_loginrewards table validated!" )