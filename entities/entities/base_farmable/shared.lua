ENT.Type = "anim"
ENT.Base = "base_gmodentity"
 
ENT.PrintName		= "Base Farmable"
ENT.Category		= "Admin"
ENT.Author			= "Brickwall"
ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()
    self:NetworkVar( "Int", 0, "StartTime" )
    self:NetworkVar( "Entity", 0, "Farmer" )
end