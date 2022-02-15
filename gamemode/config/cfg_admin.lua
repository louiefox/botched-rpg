// Use gMMO privilege system
BOTCHED.CONFIG.UseInBuiltSystem = true
BOTCHED.CONFIG.CommandsPrefix = "!"

// Use an external administration system
BOTCHED.CONFIG.UseThirdPartyMods = false

/*
             gMMO - Built-in privilege system
            Put SteamID / SteamID64 of GMs here
    Use if you set BOTCHED.CONFIG.UseInBuiltSystem to true
*/
BOTCHED.CONFIG.GameMasters = {
    "76561198195008670"
}

/*
        Put allowed admin ranks here (case sensitive)
    Use if you set BOTCHED.CONFIG.UseThirdPartyMods to false
*/
BOTCHED.CONFIG.ThirdPartyRanks = {
    "owner"
}