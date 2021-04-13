ENT.Type = "anim"
ENT.Base = "base_gmodentity"
 
ENT.PrintName		= "Base Farmable"
ENT.Category		= "Admin"
ENT.Author			= "Brickwall"
ENT.AutomaticFrameAdvance = true

ENT.FarmTool = "loading"

function ENT:SetupDataTables()
    self:NetworkVar( "Int", 0, "StartTime" )
    self:NetworkVar( "Entity", 0, "Farmer" )
end