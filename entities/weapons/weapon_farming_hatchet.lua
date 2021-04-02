if CLIENT then
	SWEP.PrintName = "Hatchet"
	SWEP.Slot = 0
	SWEP.SlotPos = 5
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = true
end

SWEP.WorldModel = Model("models/sterling/w_crafting_axe.mdl")

SWEP.UseHands = true

SWEP.Sound = Sound("physics/wood/wood_box_impact_hard3.wav")

SWEP.Primary.DefaultClip = 0;
SWEP.Primary.Automatic = true;
SWEP.Primary.ClipSize = -1;
SWEP.Primary.Damage = 1;
SWEP.Primary.Delay = 1;
SWEP.Primary.Ammo = "";

function SWEP:Initialize()
	self:SetHoldType( "melee" )

	self:SetRankColor( Vector( 1, 1, 1 ) )
	self:UpdateSWEPColour()
end

function SWEP:SetupDataTables()
	self:NetworkVar( "Vector", 0, "RankColor" )
	self:NetworkVar( "Bool", 0, "IsFarming" )
end

function SWEP:UpdateSWEPColour()
	if( not IsValid( self.Owner ) or self.Owner:GetActiveWeapon() != self ) then return end
	
	if( self:GetRankColor()  ) then
		self:SetColor( self:GetRankColor():ToColor() )
	end
end

function SWEP:Deploy()
	self:UpdateSWEPColour()

    return true
end

function SWEP:RunFarmingAnim( time )
	timer.Simple( time, function()
		if( not IsValid( self ) or not IsValid( self.Owner ) or not self:GetIsFarming() ) then return end

		self.Owner:DoAttackEvent()
		self.Owner:FireBullets( {
			Src    = self.Owner:GetShootPos(),
			Dir    = self.Owner:GetAimVector(),
			Tracer = 0,
			Force  = 3,
			Damage = 0
		} ) 

		self:RunFarmingAnim( 1 )
	end )
end

function SWEP:StartFarmingAnim()
	self:SetIsFarming( true )
	self:RunFarmingAnim( 0 )
end

function SWEP:StopFarmingAnim()
	self:SetIsFarming( false )
end

function SWEP:PrimaryAttack()

end

function SWEP:SecondaryAttack()

end