-- EQUIPMENT CONFIG --
BOTCHED.CONFIG.EquipmentRanks = {
    [1] = {},
    [2] = {
        StatMultiplier = 0.1,
        Border = BOTCHED.CONFIG.Borders.Bronze,
        Cost = {
            Mana = 1000,
            Items = {
                ["iron_bar"] = 5,
                ["shell"] = 5
            }
        }
    },
    [3] = {
        StatMultiplier = 0.2,
        Border = BOTCHED.CONFIG.Borders.Bronze,
        Cost = {
            Mana = 5000,
            Items = {
                ["iron_bar"] = 25,
                ["shell"] = 10
            }
        }
    },
    [4] = {
        StatMultiplier = 0.3,
        Border = BOTCHED.CONFIG.Borders.Silver,
        Cost = {
            Mana = 10000,
            Items = {
                ["copper_ore"] = 25,
                ["iron_ore"] = 25,
                ["gold_ore"] = 5,
                ["silver_fragment"] = 10
            }
        }
    },
    [5] = {
        StatMultiplier = 0.4,
        Border = BOTCHED.CONFIG.Borders.Silver,
        Cost = {
            Mana = 25000,
            Items = {
                ["tough_shell"] = 15,
                ["amethyst"] = 5,
                ["amber"] = 5,
                ["sapphire"] = 5,
                ["emerald"] = 5
            }
        }
    },
    [6] = {
        StatMultiplier = 0.5,
        Border = BOTCHED.CONFIG.Borders.Gold,
        Cost = {
            Mana = 50000,
            Items = {
                ["compressed_shell"] = 20,
                ["amethyst"] = 15,
                ["amber"] = 15,
                ["sapphire"] = 15,
                ["emerald"] = 15
            }
        }
    },
    [7] = {
        StatMultiplier = 0.6,
        Border = BOTCHED.CONFIG.Borders.Gold,
        Cost = {
            Mana = 100000,
            Items = {
                ["gold_bar"] = 25,
                ["steel_bar"] = 25,
                ["magma_fragment"] = 25,
                ["compressed_shell"] = 5,
                ["amethyst_compressed"] = 5
            }
        }
    },
    [8] = {
        StatMultiplier = 0.7,
        Border = BOTCHED.CONFIG.Borders.Diamond,
        Cost = {
            Mana = 250000,
            Items = {
                ["amethyst"] = 25,
                ["amethyst_compressed"] = 15,
                ["amber"] = 25,
                ["amber_compressed"] = 15,
                ["sapphire"] = 25,
                ["sapphire_compressed"] = 15,
                ["emerald"] = 40
            }
        }
    }
}
BOTCHED.CONFIG.EquipmentStars = {
    [1] = {},
    [2] = {
        StatIncrease = 0.1,
        PointsRequired = 50,
        Cost = {
            Mana = 1000
        }
    },
    [3] = {
        StatMultiplier = 0.2,
        PointsRequired = 500,
        Cost = {
            Mana = 10000
        }
    },
    [4] = {
        StatMultiplier = 0.3,
        PointsRequired = 2500,
        Cost = {
            Mana = 100000
        }
    },
    [5] = {
        StatMultiplier = 0.4,
        PointsRequired = 10000,
        Cost = {
            Mana = 500000
        }
    }
}

BOTCHED.CONFIG.Equipment = {}

-- PICKAXES --
BOTCHED.CONFIG.Equipment["basic_pick"] = {
    Name = "Basic Pickaxe",
    Model = "models/sterling/w_crafting_pickaxe.mdl",
    Type = "pickaxe",
    Class = "weapon_farming_pickaxe",
    Stars = 1,
    Stats = {
        GatherRate = 1
    },
    RankColors = {
        [2] = Color( 150, 90, 56 ),
        [3] = Color( 150, 90, 56 ),
        [4] = BOTCHED.CONFIG.Themes.Silver,
        [5] = BOTCHED.CONFIG.Themes.Silver,
        [6] = Color( 217, 164, 65 ),
        [7] = Color( 217, 164, 65 ),
        [8] = Color( 184, 216, 231 )
    }
}

-- HATCHETS --
BOTCHED.CONFIG.Equipment["basic_hatchet"] = {
    Name = "Basic Hatchet",
    Model = "models/sterling/w_crafting_axe.mdl",
    Type = "hatchet",
    Class = "weapon_farming_hatchet",
    Stars = 1,
    Stats = {
        GatherRate = 1
    },
    RankColors = {
        [2] = Color( 150, 90, 56 ),
        [3] = Color( 150, 90, 56 ),
        [4] = BOTCHED.CONFIG.Themes.Silver,
        [5] = BOTCHED.CONFIG.Themes.Silver,
        [6] = Color( 217, 164, 65 ),
        [7] = Color( 217, 164, 65 ),
        [8] = Color( 184, 216, 231 )
    }
}

-- PRIMARY WEAPONS --
BOTCHED.CONFIG.Equipment["sword_yoshiyuki"] = {
    Name = "Yoshiyuki",
    Model = "models/props_ffvii/cloud/weapons/yoshiyuki.mdl",
    Type = "primaryWeapon",
    Class = "weapon_sword_yoshiyuki",
    Stars = 1,
    Stats = {
        Damage = 14
    }
}

BOTCHED.CONFIG.Equipment["sword_nail_bat"] = {
    Name = "Nail Bat",
    Model = "models/props_ffvii/cloud/weapons/nail_bat.mdl",
    Type = "primaryWeapon",
    Class = "weapon_sword_nail_bat",
    Stars = 1,
    Stats = {
        Damage = 8
    }
}

BOTCHED.CONFIG.Equipment["sword_organics"] = {
    Name = "Organics",
    Model = "models/props_ffvii/cloud/weapons/organics.mdl",
    Type = "primaryWeapon",
    Class = "weapon_sword_organics",
    Stars = 1,
    Stats = {
        Damage = 12
    }
}

BOTCHED.CONFIG.Equipment["sword_hard_breaker"] = {
    Name = "Hard Breaker",
    Model = "models/props_ffvii/cloud/weapons/hard_breaker.mdl",
    Type = "primaryWeapon",
    Class = "weapon_sword_hard_breaker",
    Stars = 1,
    Stats = {
        Damage = 10
    }
}

BOTCHED.CONFIG.Equipment["sword_mythril_saber"] = {
    Name = "Mythril Saber",
    Model = "models/props_ffvii/cloud/weapons/mythril_saber.mdl",
    Type = "primaryWeapon",
    Class = "weapon_sword_mythril_saber",
    Stars = 2,
    Stats = {
        Damage = 15
    }
}

BOTCHED.CONFIG.Equipment["sword_heavens_cloud"] = {
    Name = "Heaven's Cloud",
    Model = "models/props_ffvii/cloud/weapons/heaven's_cloud.mdl",
    Type = "primaryWeapon",
    Class = "weapon_sword_heavens_cloud",
    Stars = 2,
    Stats = {
        Damage = 18
    }
}

BOTCHED.CONFIG.Equipment["sword_butterfly"] = {
    Name = "Butterfly Edge",
    Model = "models/props_ffvii/cloud/weapons/butterfly_edge.mdl",
    Type = "primaryWeapon",
    Class = "weapon_sword_butterfly",
    Stars = 2,
    Stats = {
        Damage = 20
    }
}

BOTCHED.CONFIG.Equipment["sword_buster"] = {
    Name = "Buster",
    Model = "models/props_ffvii/cloud/weapons/buster.mdl",
    Type = "primaryWeapon",
    Class = "weapon_sword_buster",
    Stars = 2,
    Stats = {
        Damage = 14
    }
}

BOTCHED.CONFIG.Equipment["sword_apocalypse"] = {
    Name = "Apocalypse",
    Model = "models/props_ffvii/cloud/weapons/apocalypse.mdl",
    Type = "primaryWeapon",
    Class = "weapon_sword_apocalypse",
    Stars = 2,
    Stats = {
        Damage = 16
    }
}

BOTCHED.CONFIG.Equipment["sword_crystal"] = {
    Name = "Crystal Sword",
    Model = "models/props_ffvii/cloud/weapons/crystal_sword.mdl",
    Type = "primaryWeapon",
    Class = "weapon_sword_crystal",
    Stars = 2,
    Stats = {
        Damage = 22
    }
}

BOTCHED.CONFIG.Equipment["sword_enhanced"] = {
    Name = "Enhanced Sword",
    Model = "models/props_ffvii/cloud/weapons/enhance_sword.mdl",
    Type = "primaryWeapon",
    Class = "weapon_sword_enhanced",
    Stars = 3,
    Stats = {
        Damage = 30
    }
}

BOTCHED.CONFIG.Equipment["sword_force_eater"] = {
    Name = "Force Eater",
    Model = "models/props_ffvii/cloud/weapons/force_eater.mdl",
    Type = "primaryWeapon",
    Class = "weapon_sword_force_eater",
    Stars = 3,
    Stats = {
        Damage = 32
    }
}

BOTCHED.CONFIG.Equipment["sword_murasame"] = {
    Name = "Murasame",
    Model = "models/props_ffvii/cloud/weapons/murasame.mdl",
    Type = "primaryWeapon",
    Class = "weapon_sword_murasame",
    Stars = 3,
    Stats = {
        Damage = 36
    }
}

BOTCHED.CONFIG.Equipment["sword_ragnarok"] = {
    Name = "Ragnarok",
    Model = "models/props_ffvii/cloud/weapons/ragnarok.mdl",
    Type = "primaryWeapon",
    Class = "weapon_sword_ragnarok",
    Stars = 3,
    Stats = {
        Damage = 32
    }
}

BOTCHED.CONFIG.Equipment["sword_rune_blade"] = {
    Name = "Rune Blade",
    Model = "models/props_ffvii/cloud/weapons/rune_blade.mdl",
    Type = "primaryWeapon",
    Class = "weapon_sword_rune_blade",
    Stars = 3,
    Stats = {
        Damage = 34
    }
}

BOTCHED.CONFIG.Equipment["sword_ultima_weapon"] = {
    Name = "Ultima Weapon",
    Model = "models/props_ffvii/cloud/weapons/ultima_weapon.mdl",
    Type = "primaryWeapon",
    Class = "weapon_sword_ultima_weapon",
    Stars = 3,
    Stats = {
        Damage = 28
    }
}

-- ARMOUR -- 
BOTCHED.CONFIG.Equipment["armor2"] = {
    Name = "Blood Knights Armor",
    Model = "materials/botched/equipment/armour2.png",
    Type = "armour",
    Stars = 1,
    Stats = {
        Health = 25
    }
}

BOTCHED.CONFIG.Equipment["armor3"] = {
    Name = "Spartan Armor",
    Model = "materials/botched/equipment/armour3.png",
    Type = "armour",
    Stars = 1,
    Stats = {
        Health = 35
    }
}

BOTCHED.CONFIG.Equipment["armor7"] = {
    Name = "Elven Armor",
    Model = "materials/botched/equipment/armour7.png",
    Type = "armour",
    Stars = 1,
    Stats = {
        Health = 30
    }
}

BOTCHED.CONFIG.Equipment["armor1"] = {
    Name = "Spiked Armor",
    Model = "materials/botched/equipment/armour1.png",
    Type = "armour",
    Stars = 2,
    Stats = {
        Health = 50
    }
}

BOTCHED.CONFIG.Equipment["armor4"] = {
    Name = "Cold Armor",
    Model = "materials/botched/equipment/armour4.png",
    Type = "armour",
    Stars = 2,
    Stats = {
        Health = 45
    }
}

BOTCHED.CONFIG.Equipment["armor5"] = {
    Name = "Ram Armor",
    Model = "materials/botched/equipment/armour5.png",
    Type = "armour",
    Stars = 3,
    Stats = {
        Health = 125
    }
}

BOTCHED.CONFIG.Equipment["armor6"] = {
    Name = "Holy Knight Armor",
    Model = "materials/botched/equipment/armour6.png",
    Type = "armour",
    Stars = 3,
    Stats = {
        Health = 100
    }
}

BOTCHED.CONFIG.Equipment["armor8"] = {
    Name = "Mage Armor",
    Model = "materials/botched/equipment/armour8.png",
    Type = "armour",
    Stars = 3,
    Stats = {
        Health = 80
    }
}

-- TRINKET 1 --
BOTCHED.CONFIG.Equipment["ring"] = {
    Name = "Ring",
    Model = "materials/botched/equipment/ring1.png",
    Type = "trinket1",
    Stars = 1,
    Stats = {
        Health = 25
    }
}

-- TRINKET 2 --
BOTCHED.CONFIG.Equipment["book1"] = {
    Name = "Bejewled Book",
    Model = "materials/botched/equipment/book1.png",
    Type = "trinket2",
    Stars = 1,
    Stats = {
        Health = 20
    }
}

BOTCHED.CONFIG.Equipment["book2"] = {
    Name = "Botched Cooking",
    Model = "materials/botched/equipment/book2.png",
    Type = "trinket2",
    Stars = 1,
    Stats = {
        Health = 25
    }
}

BOTCHED.CONFIG.Equipment["book3"] = {
    Name = "Scrap Book",
    Model = "materials/botched/equipment/book3.png",
    Type = "trinket2",
    Stars = 1,
    Stats = {
        Health = 15
    }
}

BOTCHED.CONFIG.Equipment["book4"] = {
    Name = "Mage's Book",
    Model = "materials/botched/equipment/book4.png",
    Type = "trinket2",
    Stars = 2,
    Stats = {
        Health = 35
    }
}

BOTCHED.CONFIG.Equipment["book5"] = {
    Name = "Beginner's Alchemy",
    Model = "materials/botched/equipment/book5.png",
    Type = "trinket2",
    Stars = 2,
    Stats = {
        Health = 40
    }
}

BOTCHED.CONFIG.Equipment["book6"] = {
    Name = "Akashic Records",
    Model = "materials/botched/equipment/book6.png",
    Type = "trinket2",
    Stars = 3,
    Stats = {
        Health = 50
    }
}

BOTCHED.CONFIG.Equipment["book7"] = {
    Name = "Hallows of Death",
    Model = "materials/botched/equipment/book7.png",
    Type = "trinket2",
    Stars = 3,
    Stats = {
        Health = 65
    }
}

BOTCHED.CONFIG.Equipment["book8"] = {
    Name = "Jewel Crafting 101",
    Model = "materials/botched/equipment/book8.png",
    Type = "trinket2",
    Stars = 2,
    Stats = {
        Health = 45
    }
}

BOTCHED.CONFIG.Equipment["book9"] = {
    Name = "Minerals And You",
    Model = "materials/botched/equipment/book9.png",
    Type = "trinket2",
    Stars = 2,
    Stats = {
        Health = 38
    }
}

BOTCHED.CONFIG.Equipment["book10"] = {
    Name = "Adventures of Kyouya",
    Model = "materials/botched/equipment/book10.png",
    Type = "trinket2",
    Stars = 1,
    Stats = {
        Health = 12
    }
}

BOTCHED.CONFIG.Equipment["book11"] = {
    Name = "Evolution of Plants",
    Model = "materials/botched/equipment/book11.png",
    Type = "trinket2",
    Stars = 1,
    Stats = {
        Health = 10
    }
}

BOTCHED.CONFIG.Equipment["book12"] = {
    Name = "Magmatic Power",
    Model = "materials/botched/equipment/book12.png",
    Type = "trinket2",
    Stars = 2,
    Stats = {
        Health = 35
    }
}

BOTCHED.CONFIG.Equipment["book13"] = {
    Name = "Satanic Rituals 666",
    Model = "materials/botched/equipment/book13.png",
    Type = "trinket2",
    Stars = 3,
    Stats = {
        Health = 65
    }
}

BOTCHED.CONFIG.Equipment["book14"] = {
    Name = "Mastery of Plants",
    Model = "materials/botched/equipment/book14.png",
    Type = "trinket2",
    Stars = 3,
    Stats = {
        Health = 70
    }
}

BOTCHED.CONFIG.Equipment["book15"] = {
    Name = "Story of Gods",
    Model = "materials/botched/equipment/book15.png",
    Type = "trinket2",
    Stars = 2,
    Stats = {
        Health = 25
    }
}

BOTCHED.CONFIG.Equipment["book16"] = {
    Name = "Alchemy Mastery",
    Model = "materials/botched/equipment/book16.png",
    Type = "trinket2",
    Stars = 3,
    Stats = {
        Health = 68
    }
}