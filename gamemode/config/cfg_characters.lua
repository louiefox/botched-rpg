-- PLAYERMODEL CONFIG --
BOTCHED.CONFIG.CharacterRanks = {
    [1] = {},
    [2] = {
        StatMultiplier = 1.2,
        Border = BOTCHED.CONFIG.Borders.Bronze
    },
    [3] = {
        StatMultiplier = 1.5,
        Border = BOTCHED.CONFIG.Borders.Bronze
    },
    [4] = {
        StatMultiplier = 1.8,
        Border = BOTCHED.CONFIG.Borders.Silver
    },
    [5] = {
        StatMultiplier = 2,
        Border = BOTCHED.CONFIG.Borders.Silver
    },
    [6] = {
        StatMultiplier = 2.5,
        Border = BOTCHED.CONFIG.Borders.Gold
    },
    [7] = {
        StatMultiplier = 3,
        Border = BOTCHED.CONFIG.Borders.Gold
    },
    [8] = {
        StatMultiplier = 4,
        Border = BOTCHED.CONFIG.Borders.Diamond
    }
}
BOTCHED.CONFIG.Characters = {
    ["default"] = {
        Name = "Default",
        Model = "models/player/knight.mdl",
        Stars = 1,
        DisableGacha = true
    },
    ["dovahkiin"] = {
        Name = "Dovahkiin",
        Model = "models/player/dovahkiin.mdl",
        Stars = 2
    }
}