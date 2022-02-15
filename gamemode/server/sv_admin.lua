// Register an empty table
local adminCommands = {}

adminCommands["noclip"] = {
    Arguments = {},
    Func = function(caller, ply)
        if (caller:GetMoveType() == MOVETYPE_NOCLIP) then
            caller:SetMoveType(MOVETYPE_WALK)
        else
            caller:SetMoveType(MOVETYPE_NOCLIP)
        end
    end
}

adminCommands["setgems"] = {
    Arguments = {
        [1] = { "Player", "Victim" },
        [2] = { "Integer", "Gems" }
    },
    Func = function(caller, ply, gems)
        ply:SetGems(gems)
        ply:SendNotification(1, 5, "Set " .. ply:Nick() .. "'s gems to ".. gems .. "!")
    end
}

adminCommands["setmana"] = {
    Arguments = {
        [1] = { "Player", "Victim" },
        [2] = { "Integer", "Mana" }
    },
    Func = function(caller, ply, mana)
        ply:SetMana(mana)
        ply:SendNotification(1, 5, "Set " .. ply:Nick() .. "'s mana to ".. mana .. "!")
    end
}

adminCommands["setlevel"] = {
    Arguments = {
        [1] = { "Player", "Victim" },
        [2] = { "Integer", "Level" }
    },
    Func = function(caller, ply, level)
        ply:SetExperience(0)
        ply:SetLevel(level)
        ply:SendNotification(1, 5, "Set " .. ply:Nick() .. " to level ".. level .. "!")
    end
}

adminCommands["setstamina"] = {
    Arguments = {
        [1] = { "Player", "Victim" },
        [2] = { "Integer", "Stamina" }
    },
    Func = function(caller, ply, stamina)
        ply:SetStamina(stamina)
        ply:SendNotification(1, 5, "Set " .. ply:Nick() .. "'s stamina to ".. stamina .. "!")
    end
}

adminCommands["giveitem"] = {
    Arguments = {
        [1] = { "Player", "Victim" },
        [2] = { "String", "ItemKey" },
        [3] = { "Integer", "Amount" }
    },
    Func = function(caller, ply, itemKey, amount)
        ply:AddInventoryItems(itemKey, amount)

        local itemConfig = BOTCHED.CONFIG.Items[itemKey]
        if (not itemConfig) then return end

        ply:SendNotification(1, 5, "Given " .. ply:Nick() .. " ".. amount .. " " .. itemConfig.Name .. "!")
    end
}

adminCommands["giveplayermodel"] = {
    Arguments = {
        [1] = { "Player", "Victim" },
        [2] = { "String", "ModelKey" }
    },
    Func = function(caller, ply, characterKey, amount)
        ply:GiveCharacters(characterKey)

        local modelConfig = BOTCHED.CONFIG.Characters[characterKey]
        if (not modelConfig) then return end

        ply:SendNotification(1, 5, "Given " .. ply:Nick() .. " " .. modelConfig.Name .. "!")
    end
}

/*
    Register new console commands let's go
*/
concommand.Add("gmmo", function(ply, cmd, args)
    if (IsValid(ply) and not ply:HasAdminPrivilege()) then 
        ply:SendNotification(1, 5, "You don't have the permission to use this!")
        return 
    end

    local commandTable = adminCommands[args[1] or ""]
    if (not commandTable) then return end

    local commandArguments = {}
    for k,v in pairs(commandTable.Arguments or {}) do
        local argument = args[k+1]
        if (not argument) then return end

        if (v[1] == "Player") then
            argument = player.GetBySteamID64(argument)
            if (not IsValid(argument)) then return end
        elseif (v[1] == "Integer") then
            argument = tonumber( argument )
            if( not isnumber( argument ) ) then return end
        end

        commandArguments[k] = argument
    end

    commandTable.Func(ply, unpack(commandArguments))
end )

/*
    Chat commands handler
*/
hook.Add("PlayerSay", "Botched.HandleChatCommands", function(ply, msg)
    if (!IsValid(ply) or !ply:HasAdminPrivilege()) then return end

    if (string.StartWith(msg, BOTCHED.CONFIG.CommandsPrefix)) then
        local command = string.Split(msg, " ")
        local commandTable = adminCommands[string.Trim(command[0], "!")  or ""]
        if (not commandTable) then return end

        local commandArguments = {}
        for k,v in pairs(commandTable.Arguments or {}) do
            local argument = args[k+1]
            if (not argument) then return end

            if (v[1] == "Player") then
                argument = player.GetBySteamID64(argument)
                if (not IsValid(argument)) then return end
            elseif (v[1] == "Integer") then
                argument = tonumber( argument )
                if( not isnumber( argument ) ) then return end
            end

            commandArguments[k] = argument
        end

        commandTable.Func(ply, unpack(commandArguments))
    end
end)