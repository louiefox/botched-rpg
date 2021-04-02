-- QUESTS CONFIG --
BOTCHED.CONFIG.QuestsLines = {}
BOTCHED.CONFIG.QuestsLines[1] = {
    Title = "Grasslands",
    Image = "https://i.imgur.com/ACCGRpg.jpg",
    RandomItems = {
        { "exp_bottle_1", 50 },
        { "exp_bottle_1", 25, 2 },
        { "exp_bottle_2", 15 },
        { "exp_bottle_2", 5, 2 },
        { "refinement_crystal_1", 50 },
        { "refinement_crystal_1", 25, 2 },
        { "refinement_crystal_2", 15 },
        { "refinement_crystal_2", 5, 2 }
    },
    Quests = {
        [1] = {
            TimeLimit = 300,
            StaminaCost = 5,
            Monsters = {
                ["zombie"] = 5
            },
            Items = {
                { "shell", 75 },
                { "coal", 50 },
                { "iron_bar", 50 },
                { "steel_bar", 25 },
                { "copper_fragment", 25, 2 }
            },
            Reward = {
                Mana = 5000,
                Items = {
                    ["copper_ore"] = 5,
                    ["shell"] = 2
                }
            },
            Reward3Stars = {
                Gems = 25
            }
        },
        [2] = {
            TimeLimit = 300,
            StaminaCost = 5,
            Monsters = {
                ["zombie"] = 5,
                ["fastZombie"] = 5
            },
            Items = {
                { "shell", 75 },
                { "coal", 50 },
                { "copper_fragment", 25, 2 },
                { "silver_fragment", 15, 2 },
                { "magma_fragment", 10, 2 }
            },
            Reward = {
                Mana = 7000,
                Items = {
                    ["iron_ore"] = 5,
                    ["tough_shell"] = 2
                }
            },
            Reward3Stars = {
                Gems = 25
            }
        },
        [3] = {
            TimeLimit = 600,
            StaminaCost = 8,
            Monsters = {
                ["zombie"] = 5,
                ["fastZombie"] = 10
            },
            Items = {
                { "iron_bar", 50 },
                { "steel_bar", 25 },
                { "copper_fragment", 25, 2 },
                { "silver_fragment", 15, 2 },
                { "magma_fragment", 10, 2 }
            },
            Reward = {
                Mana = 10000,
                Items = {
                    ["iron_ore"] = 10,
                    ["tough_shell"] = 4
                }
            },
            Reward3Stars = {
                Gems = 25
            }
        },
        [4] = {
            TimeLimit = 300,
            StaminaCost = 8,
            Monsters = {
                ["poisonZombie"] = 5
            },
            Items = {
                { "shell", 75 },
                { "iron_bar", 50 },
                { "steel_bar", 25 },
                { "silver_fragment", 15, 2 },
                { "magma_fragment", 10, 2 }
            },
            Reward = {
                Mana = 8000,
                Items = {
                    ["gold_ore"] = 5,
                    ["tough_shell"] = 3
                }
            },
            Reward3Stars = {
                Gems = 25
            }
        },
    }
}
BOTCHED.CONFIG.QuestsLines[2] = {
    Title = "Forest",
    Image = "https://i.imgur.com/OjZFs77.jpg",
    RandomItems = {
        { "exp_bottle_1", 50 },
        { "exp_bottle_1", 25, 2 },
        { "exp_bottle_2", 15 },
        { "exp_bottle_2", 5, 2 },
        { "refinement_crystal_1", 50 },
        { "refinement_crystal_1", 25, 2 },
        { "refinement_crystal_2", 15 },
        { "refinement_crystal_2", 5, 2 }
    },
    Quests = {
        [1] = {
            TimeLimit = 120,
            StaminaCost = 8,
            Monsters = {
                ["poisonZombie"] = 4
            },
            Items = {
                { "shell", 75 },
                { "iron_bar", 50 },
                { "steel_bar", 25 },
                { "silver_fragment", 15, 2 },
                { "magma_fragment", 10, 2 }
            },
            Reward = {
                Mana = 8000,
                Items = {
                    ["gold_ore"] = 5,
                    ["tough_shell"] = 3
                }
            },
            Reward3Stars = {
                Gems = 40
            }
        },
        [2] = {
            TimeLimit = 900,
            StaminaCost = 12,
            Monsters = {
                ["zombie"] = 10,
                ["fastZombie"] = 10,
                ["poisonZombie"] = 10
            },
            Items = {
                { "shell", 75 },
                { "iron_bar", 50 },
                { "steel_bar", 25 },
                { "silver_fragment", 15, 2 },
                { "magma_fragment", 10, 2 }
            },
            Reward = {
                Mana = 20000,
                Items = {
                    ["gold_ore"] = 5,
                    ["tough_shell"] = 3
                }
            },
            Reward3Stars = {
                Gems = 40
            }
        }
    }
}