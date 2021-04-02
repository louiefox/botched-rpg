local weaponsToCreate = {
    ["weapon_sword_butterfly"] = {
        Name = "Butterfly",
        WorldModel = "models/props_ffvii/cloud/weapons/butterfly_edge.mdl"
    },
    ["weapon_sword_buster"] = {
        Name = "Buster",
        WorldModel = "models/props_ffvii/cloud/weapons/buster.mdl"
    },
    ["weapon_sword_apocalypse"] = {
        Name = "Apocalypse",
        WorldModel = "models/props_ffvii/cloud/weapons/apocalypse.mdl"
    },
    ["weapon_sword_crystal"] = {
        Name = "Crystal Sword",
        WorldModel = "models/props_ffvii/cloud/weapons/crystal_sword.mdl"
    },
    ["weapon_sword_enhanced"] = {
        Name = "Enhanced Sword",
        WorldModel = "models/props_ffvii/cloud/weapons/enhance_sword.mdl"
    },
    ["weapon_sword_force_eater"] = {
        Name = "Force Eater",
        WorldModel = "models/props_ffvii/cloud/weapons/force_eater.mdl"
    },
    ["weapon_sword_hard_breaker"] = {
        Name = "Hard Breaker",
        WorldModel = "models/props_ffvii/cloud/weapons/hard_breaker.mdl"
    },
    ["weapon_sword_heavens_cloud"] = {
        Name = "Heaven's Cloud",
        WorldModel = "models/props_ffvii/cloud/weapons/heaven's_cloud.mdl"
    },
    ["weapon_sword_murasame"] = {
        Name = "Murasame",
        WorldModel = "models/props_ffvii/cloud/weapons/murasame.mdl"
    },
    ["weapon_sword_mythril_saber"] = {
        Name = "Mythril Saber",
        WorldModel = "models/props_ffvii/cloud/weapons/mythril_saber.mdl"
    },
    ["weapon_sword_nail_bat"] = {
        Name = "Nail Bat",
        WorldModel = "models/props_ffvii/cloud/weapons/nail_bat.mdl"
    },
    ["weapon_sword_organics"] = {
        Name = "Organics",
        WorldModel = "models/props_ffvii/cloud/weapons/organics.mdl"
    },
    ["weapon_sword_ragnarok"] = {
        Name = "Ragnarok",
        WorldModel = "models/props_ffvii/cloud/weapons/ragnarok.mdl"
    },
    ["weapon_sword_rune_blade"] = {
        Name = "Rune Blade",
        WorldModel = "models/props_ffvii/cloud/weapons/rune_blade.mdl"
    },
    ["weapon_sword_ultima"] = {
        Name = "Ultima",
        WorldModel = "models/props_ffvii/cloud/weapons/ultima_weapon.mdl"
    },
    ["weapon_sword_yoshiyuki"] = {
        Name = "Yoshiyuki",
        WorldModel = "models/props_ffvii/cloud/weapons/yoshiyuki.mdl"
    }
}

for k, v in pairs( weaponsToCreate ) do
    local SWEP = {}
    SWEP.Base = "weapon_sword_base"

    SWEP.PrintName = v.Name
    SWEP.WorldModel = Model( v.WorldModel )

    weapons.Register( SWEP, k )
end