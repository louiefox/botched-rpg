-- CRAFTING CONFIG --
BOTCHED.CONFIG.Crafting = {
    ---------- RESOURCES ----------
    ["gold_bar"] = {
        Category = "Resources",
        ItemInfo = BOTCHED.CONFIG.Items["gold_bar"],
        Cost = {
            Mana = 1000,
            Items = {
                ["gold_ore"] = 5
            }
        },
        Reward = { Items = { ["gold_bar"] = 1 } }
    },
    ["iron_bar"] = {
        Category = "Resources",
        ItemInfo = BOTCHED.CONFIG.Items["iron_bar"],
        Cost = {
            Mana = 100,
            Items = {
                ["iron_ore"] = 2
            }
        },
        Reward = { Items = { ["iron_bar"] = 1 } }
    },
    ["steel_bar"] = {
        Amount = 2,
        Category = "Resources",
        ItemInfo = BOTCHED.CONFIG.Items["steel_bar"],
        Cost = {
            Mana = 500,
            Items = {
                ["iron_ore"] = 2,
                ["coal"] = 3
            }
        },
        Reward = { Items = { ["steel_bar"] = 2 } }
    },
    ["copper_ore"] = {
        Category = "Resources",
        ItemInfo = BOTCHED.CONFIG.Items["copper_ore"],
        Cost = {
            Mana = 500,
            Items = {
                ["copper_fragment"] = 2,
            }
        },
        Reward = { Items = { ["copper_ore"] = 1 } }
    },

    ["amethyst_raw"] = {
        Category = "Resources",
        ItemInfo = BOTCHED.CONFIG.Items["amethyst_raw"],
        Cost = {
            Mana = 500,
            Items = {
                ["amethyst_fragment"] = 2,
            }
        },
        Reward = { Items = { ["amethyst_raw"] = 1 } }
    },
    ["amethyst"] = {
        Category = "Resources",
        ItemInfo = BOTCHED.CONFIG.Items["amethyst"],
        Cost = {
            Mana = 500,
            Items = {
                ["amethyst_raw"] = 2,
            }
        },
        Reward = { Items = { ["amethyst"] = 1 } }
    },
    ["amethyst_compressed"] = {
        Category = "Resources",
        ItemInfo = BOTCHED.CONFIG.Items["amethyst_compressed"],
        Cost = {
            Mana = 500,
            Items = {
                ["amethyst"] = 2,
            }
        },
        Reward = { Items = { ["amethyst_compressed"] = 1 } }
    },

    ["amber"] = {
        Category = "Resources",
        ItemInfo = BOTCHED.CONFIG.Items["amber"],
        Cost = {
            Mana = 500,
            Items = {
                ["amber_raw"] = 2,
            }
        },
        Reward = { Items = { ["amber"] = 1 } }
    },
    ["amber_compressed"] = {
        Category = "Resources",
        ItemInfo = BOTCHED.CONFIG.Items["amber_compressed"],
        Cost = {
            Mana = 500,
            Items = {
                ["amber"] = 2,
            }
        },
        Reward = { Items = { ["amber_compressed"] = 1 } }
    },

    ["sapphire_raw"] = {
        Category = "Resources",
        ItemInfo = BOTCHED.CONFIG.Items["sapphire_raw"],
        Cost = {
            Mana = 500,
            Items = {
                ["sapphire_fragment"] = 2,
            }
        },
        Reward = { Items = { ["sapphire_raw"] = 1 } }
    },
    ["sapphire"] = {
        Category = "Resources",
        ItemInfo = BOTCHED.CONFIG.Items["sapphire"],
        Cost = {
            Mana = 500,
            Items = {
                ["sapphire_raw"] = 2,
            }
        },
        Reward = { Items = { ["sapphire"] = 1 } }
    },
    ["sapphire_compressed"] = {
        Category = "Resources",
        ItemInfo = BOTCHED.CONFIG.Items["sapphire_compressed"],
        Cost = {
            Mana = 500,
            Items = {
                ["sapphire"] = 2,
            }
        },
        Reward = { Items = { ["sapphire_compressed"] = 1 } }
    },

    ---------- SWORDS ----------
    ["sword_nail_bat"] = {
        Category = "Weapons",
        ItemInfo = BOTCHED.CONFIG.Equipment["sword_nail_bat"],
        Cost = {
            Mana = 5000,
            Items = {
                ["iron_bar"] = 5,
            }
        },
        Reward = { Equipment = { "sword_nail_bat" } }
    },
    ["sword_hard_breaker"] = {
        Category = "Weapons",
        ItemInfo = BOTCHED.CONFIG.Equipment["sword_hard_breaker"],
        Cost = {
            Mana = 5000,
            Items = {
                ["iron_bar"] = 5,
                ["steel_bar"] = 2
            }
        },
        Reward = { Equipment = { "sword_hard_breaker" } }
    },
    ["sword_organics"] = {
        Category = "Weapons",
        ItemInfo = BOTCHED.CONFIG.Equipment["sword_organics"],
        Cost = {
            Mana = 5000,
            Items = {
                ["copper_ore"] = 5,
                ["silver_fragment"] = 5
            }
        },
        Reward = { Equipment = { "sword_organics" } }
    },
    ["sword_yoshiyuki"] = {
        Category = "Weapons",
        ItemInfo = BOTCHED.CONFIG.Equipment["sword_yoshiyuki"],
        Cost = {
            Mana = 5000,
            Items = {
                ["copper_fragment"] = 15,
                ["iron_bar"] = 5
            }
        },
        Reward = { Equipment = { "sword_yoshiyuki" } }
    },

    ["sword_butterfly"] = {
        Category = "Weapons",
        ItemInfo = BOTCHED.CONFIG.Equipment["sword_butterfly"],
        Cost = {
            Mana = 25000,
            Items = {
                ["steel_bar"] = 15,
                ["gold_bar"] = 5
            }
        },
        Reward = { Equipment = { "sword_butterfly" } }
    },
    ["sword_crystal"] = {
        Category = "Weapons",
        ItemInfo = BOTCHED.CONFIG.Equipment["sword_crystal"],
        Cost = {
            Mana = 25000,
            Items = {
                ["amethyst_fragment"] = 4,
                ["sapphire_fragment"] = 4
            }
        },
        Reward = { Equipment = { "sword_crystal" } }
    },
    ["sword_apocalypse"] = {
        Category = "Weapons",
        ItemInfo = BOTCHED.CONFIG.Equipment["sword_apocalypse"],
        Cost = {
            Mana = 25000,
            Items = {
                ["amber"] = 5,
                ["magma_fragment"] = 5
            }
        },
        Reward = { Equipment = { "sword_apocalypse" } }
    },
    ["sword_heavens_cloud"] = {
        Category = "Weapons",
        ItemInfo = BOTCHED.CONFIG.Equipment["sword_heavens_cloud"],
        Cost = {
            Mana = 25000,
            Items = {
                ["silver_fragment"] = 10,
                ["gold_bar"] = 5
            }
        },
        Reward = { Equipment = { "sword_heavens_cloud" } }
    },
    ["sword_mythril_saber"] = {
        Category = "Weapons",
        ItemInfo = BOTCHED.CONFIG.Equipment["sword_mythril_saber"],
        Cost = {
            Mana = 25000,
            Items = {
                ["amethyst_raw"] = 10,
                ["amber_raw"] = 5,
                ["sapphire_raw"] = 5
            }
        },
        Reward = { Equipment = { "sword_mythril_saber" } }
    },
    ["sword_buster"] = {
        Category = "Weapons",
        ItemInfo = BOTCHED.CONFIG.Equipment["sword_buster"],
        Cost = {
            Mana = 25000,
            Items = {
                ["iron_bar"] = 25,
                ["steel_bar"] = 10,
                ["gold_bar"] = 5
            }
        },
        Reward = { Equipment = { "sword_buster" } }
    },

    ["sword_murasame"] = {
        Category = "Weapons",
        ItemInfo = BOTCHED.CONFIG.Equipment["sword_murasame"],
        Cost = {
            Mana = 250000,
            Items = {
                ["amethyst_compressed"] = 5,
                ["amber_compressed"] = 5,
                ["sapphire_compressed"] = 5
            }
        },
        Reward = { Equipment = { "sword_murasame" } }
    },
    ["sword_enhanced"] = {
        Category = "Weapons",
        ItemInfo = BOTCHED.CONFIG.Equipment["sword_enhanced"],
        Cost = {
            Mana = 250000,
            Items = {
                ["gold_bar"] = 50,
                ["sapphire_compressed"] = 5
            }
        },
        Reward = { Equipment = { "sword_enhanced" } }
    },
    ["sword_force_eater"] = {
        Category = "Weapons",
        ItemInfo = BOTCHED.CONFIG.Equipment["sword_force_eater"],
        Cost = {
            Mana = 250000,
            Items = {
                ["sapphire"] = 20,
                ["emerald"] = 20,
                ["amethyst"] = 20
            }
        },
        Reward = { Equipment = { "sword_force_eater" } }
    },
    ["sword_ragnarok"] = {
        Category = "Weapons",
        ItemInfo = BOTCHED.CONFIG.Equipment["sword_ragnarok"],
        Cost = {
            Mana = 250000,
            Items = {
                ["sapphire"] = 15,
                ["amber_compressed"] = 5
            }
        },
        Reward = { Equipment = { "sword_ragnarok" } }
    },
    ["sword_ultima_weapon"] = {
        Category = "Weapons",
        ItemInfo = BOTCHED.CONFIG.Equipment["sword_ultima_weapon"],
        Cost = {
            Mana = 250000,
            Items = {
                ["magma_fragment"] = 25,
                ["silver_fragment"] = 25,
                ["amethyst"] = 15
            }
        },
        Reward = { Equipment = { "sword_ultima_weapon" } }
    },
    ["sword_rune_blade"] = {
        Category = "Weapons",
        ItemInfo = BOTCHED.CONFIG.Equipment["sword_rune_blade"],
        Cost = {
            Mana = 250000,
            Items = {
                ["gold_bar"] = 25,
                ["silver_fragment"] = 25,
                ["amethyst_compressed"] = 10
            }
        },
        Reward = { Equipment = { "sword_rune_blade" } }
    },

    ---------- ARMOR ----------
    ["armor3"] = {
        Category = "Armor",
        ItemInfo = BOTCHED.CONFIG.Equipment["armor3"],
        Cost = {
            Mana = 5000,
            Items = {
                ["iron_bar"] = 5,
                ["shell"] = 5
            }
        },
        Reward = { Equipment = { "armor3" } }
    },
    ["armor2"] = {
        Category = "Armor",
        ItemInfo = BOTCHED.CONFIG.Equipment["armor2"],
        Cost = {
            Mana = 5000,
            Items = {
                ["silver_fragment"] = 5,
                ["shell"] = 5
            }
        },
        Reward = { Equipment = { "armor2" } }
    },
    ["armor7"] = {
        Category = "Armor",
        ItemInfo = BOTCHED.CONFIG.Equipment["armor7"],
        Cost = {
            Mana = 5000,
            Items = {
                ["silver_fragment"] = 2,
                ["iron_bar"] = 3,
                ["shell"] = 5
            }
        },
        Reward = { Equipment = { "armor7" } }
    },
    ["armor4"] = {
        Category = "Armor",
        ItemInfo = BOTCHED.CONFIG.Equipment["armor4"],
        Cost = {
            Mana = 25000,
            Items = {
                ["tough_shell"] = 5,
                ["silver_fragment"] = 10,
                ["amethyst"] = 4,
            }
        },
        Reward = { Equipment = { "armor4" } }
    },
    ["armor1"] = {
        Category = "Armor",
        ItemInfo = BOTCHED.CONFIG.Equipment["armor1"],
        Cost = {
            Mana = 25000,
            Items = {
                ["tough_shell"] = 5,
                ["silver_fragment"] = 10,
                ["sapphire"] = 4
            }
        },
        Reward = { Equipment = { "armor1" } }
    },
    ["armor6"] = {
        Category = "Armor",
        ItemInfo = BOTCHED.CONFIG.Equipment["armor6"],
        Cost = {
            Mana = 250000,
            Items = {
                ["compressed_shell"] = 5,
                ["gold_bar"] = 15,
                ["sapphire"] = 25
            }
        },
        Reward = { Equipment = { "armor6" } }
    },
    ["armor8"] = {
        Category = "Armor",
        ItemInfo = BOTCHED.CONFIG.Equipment["armor8"],
        Cost = {
            Mana = 250000,
            Items = {
                ["compressed_shell"] = 5,
                ["magma_fragment"] = 25,
                ["amethyst_compressed"] = 3
            }
        },
        Reward = { Equipment = { "armor8" } }
    },
    ["armor5"] = {
        Category = "Armor",
        ItemInfo = BOTCHED.CONFIG.Equipment["armor5"],
        Cost = {
            Mana = 250000,
            Items = {
                ["compressed_shell"] = 5,
                ["amethyst_compressed"] = 5,
                ["amber_compressed"] = 5
            }
        },
        Reward = { Equipment = { "armor5" } }
    },

    ---------- TRINKETS ----------
    ["book11"] = {
        Category = "Trinkets",
        ItemInfo = BOTCHED.CONFIG.Equipment["book11"],
        Cost = {
            Mana = 5000,
            Items = {
                ["copper_fragment"] = 5,
                ["coal"] = 5
            }
        },
        Reward = { Equipment = { "book11" } }
    },
    ["book10"] = {
        Category = "Trinkets",
        ItemInfo = BOTCHED.CONFIG.Equipment["book10"],
        Cost = {
            Mana = 5000,
            Items = {
                ["copper_fragment"] = 5,
                ["iron_ore"] = 5
            }
        },
        Reward = { Equipment = { "book10" } }
    },
    ["book1"] = {
        Category = "Trinkets",
        ItemInfo = BOTCHED.CONFIG.Equipment["book1"],
        Cost = {
            Mana = 5000,
            Items = {
                ["iron_ore"] = 5,
                ["copper_ore"] = 2
            }
        },
        Reward = { Equipment = { "book1" } }
    },
    ["book3"] = {
        Category = "Trinkets",
        ItemInfo = BOTCHED.CONFIG.Equipment["book3"],
        Cost = {
            Mana = 5000,
            Items = {
                ["amethyst_fragment"] = 2,
                ["sapphire_fragment"] = 2
            }
        },
        Reward = { Equipment = { "book3" } }
    },
    ["book2"] = {
        Category = "Trinkets",
        ItemInfo = BOTCHED.CONFIG.Equipment["book2"],
        Cost = {
            Mana = 5000,
            Items = {
                ["emerald"] = 1,
                ["sapphire"] = 1,
                ["amethyst"] = 1
            }
        },
        Reward = { Equipment = { "book2" } }
    },

    ["book8"] = {
        Category = "Trinkets",
        ItemInfo = BOTCHED.CONFIG.Equipment["book8"],
        Cost = {
            Mana = 25000,
            Items = {
                ["iron_ore"] = 3,
                ["gold_ore"] = 3
            }
        },
        Reward = { Equipment = { "book8" } }
    },
    ["book15"] = {
        Category = "Trinkets",
        ItemInfo = BOTCHED.CONFIG.Equipment["book15"],
        Cost = {
            Mana = 25000,
            Items = {
                ["iron_bar"] = 5,
                ["steel_bar"] = 2
            }
        },
        Reward = { Equipment = { "book15" } }
    },
    ["book12"] = {
        Category = "Trinkets",
        ItemInfo = BOTCHED.CONFIG.Equipment["book12"],
        Cost = {
            Mana = 25000,
            Items = {
                ["coal"] = 10,
                ["magma_fragment"] = 5
            }
        },
        Reward = { Equipment = { "book12" } }
    },
    ["book9"] = {
        Category = "Trinkets",
        ItemInfo = BOTCHED.CONFIG.Equipment["book9"],
        Cost = {
            Mana = 25000,
            Items = {
                ["amethyst_fragment"] = 5,
                ["sapphire_fragment"] = 5
            }
        },
        Reward = { Equipment = { "book9" } }
    },
    ["book4"] = {
        Category = "Trinkets",
        ItemInfo = BOTCHED.CONFIG.Equipment["book4"],
        Cost = {
            Mana = 25000,
            Items = {
                ["gold_bar"] = 5
            }
        },
        Reward = { Equipment = { "book4" } }
    },
    ["book5"] = {
        Category = "Trinkets",
        ItemInfo = BOTCHED.CONFIG.Equipment["book5"],
        Cost = {
            Mana = 25000,
            Items = {
                ["amethyst"] = 2,
                ["amber"] = 2
            }
        },
        Reward = { Equipment = { "book5" } }
    },

    ["book6"] = {
        Category = "Trinkets",
        ItemInfo = BOTCHED.CONFIG.Equipment["book6"],
        Cost = {
            Mana = 250000,
            Items = {
                ["amethyst_compressed"] = 1,
                ["amber_compressed"] = 1,
                ["sapphire_compressed"] = 1
            }
        },
        Reward = { Equipment = { "book6" } }
    },
    ["book7"] = {
        Category = "Trinkets",
        ItemInfo = BOTCHED.CONFIG.Equipment["book7"],
        Cost = {
            Mana = 250000,
            Items = {
                ["emerald"] = 5,
                ["sapphire"] = 10
            }
        },
        Reward = { Equipment = { "book7" } }
    },
    ["book13"] = {
        Category = "Trinkets",
        ItemInfo = BOTCHED.CONFIG.Equipment["book13"],
        Cost = {
            Mana = 250000,
            Items = {
                ["magma_fragment"] = 15,
                ["gold_bar"] = 10
            }
        },
        Reward = { Equipment = { "book13" } }
    },
    ["book14"] = {
        Category = "Trinkets",
        ItemInfo = BOTCHED.CONFIG.Equipment["book14"],
        Cost = {
            Mana = 250000,
            Items = {
                ["gold_bar"] = 15,
                ["amethyst_compressed"] = 5
            }
        },
        Reward = { Equipment = { "book14" } }
    },
    ["book16"] = {
        Category = "Trinkets",
        ItemInfo = BOTCHED.CONFIG.Equipment["book16"],
        Cost = {
            Mana = 250000,
            Items = {
                ["silver_fragment"] = 25,
                ["gold_bar"] = 25
            }
        },
        Reward = { Equipment = { "book16" } }
    },
}