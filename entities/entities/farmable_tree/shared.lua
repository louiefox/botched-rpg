ENT.Type = "anim"
ENT.Base = "base_farmable"
 
ENT.PrintName		= "Tree"
ENT.Category		= "Admin"
ENT.Author			= "Brickwall"
ENT.AutomaticFrameAdvance = true

ENT.FarmTool = "hatchet"
ENT.FarmDuration = 3
ENT.StaminaCost = 1
ENT.RewardEXP = 10
ENT.RewardReason = "Wood Cutting"
ENT.RewardItems = {
    { "copper_fragment", 60 },
    { "silver_fragment", 20 },
    { "magma_fragment", 10 },
    { "amethyst_fragment", 5 },
    { "sapphire_fragment", 5 }
}

DEFINE_BASECLASS( "base_farmable" )
function ENT:SetupDataTables()
    BaseClass.SetupDataTables( self )

    self:NetworkVar( "Int", 1, "FallTime" )
    self:NetworkVar( "Int", 2, "FallEndTime" )
    self:NetworkVar( "Angle", 0, "EndAngles" )
end