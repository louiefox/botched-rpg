-- MOB CONFIG --
BOTCHED.CONFIG.Monsters = {
    ["zombie"] = {
        Name = "Zombie",
        Level = 1,
        Model = "models/Zombie/Classic.mdl",
        Class = "botched_monster_zombie",
        Health = 100,
        Locations = {
            Vector( -3106, -3618, -2962 ),
            Vector( -2470, -5998, -2981 )
        },
        PlayerEXP = 10
    },
    ["fastZombie"] = {
        Name = "Fast Zombie",
        Level = 5,
        Model = "models/Zombie/Fast.mdl",
        Class = "botched_monster_fast_zombie",
        Health = 150,
        Locations = {
            Vector( -9394, -454, -2908 )
        },
        PlayerEXP = 25
    },
    ["poisonZombie"] = {
        Name = "Poison Zombie",
        Level = 10,
        Model = "models/Zombie/Poison.mdl",
        Class = "botched_monster_poison_zombie",
        Health = 300,
        Locations = {
            Vector( -7098, -5615, -2919 )
        },
        PlayerEXP = 50
    }
}