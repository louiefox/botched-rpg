BOTCHED.DEVCONFIG = {}

-- EQUIPMENT TYPES --
BOTCHED.DEVCONFIG.EquipmentTypes = {
    ["pickaxe"] = {
        Name = "Pickaxe"
    },
    ["hatchet"] = {
        Name = "Hatchet"
    },
    ["primaryWeapon"] = {
        Name = "Primary Weapon"
    },
    ["secondaryWeapon"] = {
        Name = "Secondary Weapon"
    },
    ["trinket1"] = {
        Name = "Trinket 1"
    },
    ["trinket2"] = {
        Name = "Trinket 2"
    },
    ["armour"] = {
        Name = "Armour"
    }
}

-- EQUIPMENT STATS --
BOTCHED.DEVCONFIG.EquipmentStats = {
    ["GatherRate"] = {
        Name = "Gather Rate",
        SetFunc = function( weapon, value )
            weapon:SetWeaponVariable( "GatherRate", value )
        end
    },
    ["Damage"] = {
        Name = "Damage",
        SetFunc = function( weapon, value )
            weapon:SetWeaponVariable( "Damage", value )
        end
    },
    ["RPM"] = {
        Name = "Fire Rate",
        SetFunc = function( weapon, value )
            weapon:SetWeaponVariable( "RPM", value )
        end
    },
    ["ClipSize"] = {
        Name = "Magazine",
        SetFunc = function( weapon, value )
            weapon:SetWeaponVariable( "ClipSize", value )

            if( weapon:Clip1() != weapon:GetMaxClip1() ) then
                weapon:SetClip1( weapon:GetMaxClip1() )
            end
        end
    },
    ["Health"] = {
        Name = "Health",
        SetFunc = function( ply, value )
            ply:SetMaxHealth( 100+value )
            if( ply:Health() > ply:GetMaxHealth() ) then
                ply:SetHealth( ply:GetMaxHealth() )
            end
        end
    }
}

-- RESOURCE TYPES --
BOTCHED.DEVCONFIG.ResourceTypes = {
    ["rock"] = {
        Name = "Rock",
        EntityClass = "farmable_rock",
        Model = "models/brickscrafting/rock.mdl",
        RespawnTime = 300
    },
    ["tree"] = {
        Name = "Tree",
        EntityClass = "farmable_tree",
        Model = "models/props_foliage/tree_deciduous_01a-lod.mdl",
        RespawnTime = 120
    }
}

-- PLAYERMODEL ADJUSTMENTS --
BOTCHED.DEVCONFIG.PlayermodelAdjustments = {
    ["models/player/astolfo.mdl"] = {
        WeaponHolster = {
            BackDist = -3.5
        }
    },
}

-- EFFECTS --
BOTCHED.DEVCONFIG.PlayerEffects = {
    ["speed"] = {
        Title = "Speed",
        Icon = Material( "materials/botched/abilities/speed.png" ), 
        StartFunc = function( ply, multiplier )
            ply:SetSpeedMultiplier( multiplier )
        end,
        EndFunc = function( ply )
            ply:SetSpeedMultiplier( 1 )
        end
    }
}

-- CHARACTER ABILITIES --
local function GetClosestTarget( startPos, normalVec )
    local foundEnts = {}
    for k, v in ipairs( ents.FindInCone( startPos, normalVec, 1000, math.cos( math.rad( 1 ) ) ) ) do
        if( v.IsMonster ) then
            table.insert( foundEnts, { v, startPos:DistToSqr( v:GetPos() ) } )
        end
    end

    if( #foundEnts < 1 ) then return end

    table.SortByMember( foundEnts, 2, true )
    return (foundEnts[1] or {})[1]
end

BOTCHED.DEVCONFIG.CharacterAbilities = {
    ["heal"] = {
        Title = "Heal",
        Icon = Material( "materials/botched/abilities/heal.png" ), 
        Cooldown = 15,
        UseFunc = function( ply )
            ply:SetHealth( ply:GetMaxHealth() )
        end
    },
    ["speed"] = {
        Title = "Speed",
        Icon = Material( "materials/botched/abilities/speed.png" ), 
        Cooldown = 15,
        UseFunc = function( ply )
            ply:AddPlayerEffect( "speed", 5, 1.5 )
        end
    },
    ["frost_ball"] = {
        Title = "Frost Ball",
        Icon = Material( "materials/botched/abilities/frost_ball.png" ), 
        Cooldown = 20,
        UseFunc = function( ply )
            local targetEnt = GetClosestTarget( ply:GetPos(), ply:GetForward()*10 )
            if( not IsValid( targetEnt ) ) then return true end

            local frostBall = ents.Create( "fire_ball" )
            frostBall:SetPos( ply:GetPos()+Vector( 0, 0, 35 ) )
            frostBall:SetDamage( math.random( 25, 50 ) )
            frostBall:SetTarget( targetEnt )
            frostBall:SetAttacker( ply )
            frostBall:SetOffset( Vector( 0, 0, 35 ) )
            frostBall:Spawn()
            frostBall:FireAtTarget()
        end
    },
    ["charge"] = {
        Title = "Charge",
        Icon = Material( "materials/botched/abilities/charge.png" ), 
        Cooldown = 5,
        UseFunc = function( ply )
            ply:SetVelocity( ply:GetForward() * 2000 )
        end
    },
}