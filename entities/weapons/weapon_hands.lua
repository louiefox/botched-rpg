if CLIENT then
	SWEP.PrintName = "Hands"
	SWEP.Slot = 0
	SWEP.SlotPos = 5
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = true
end

SWEP.WorldModel = ""
SWEP.UseHands = true

SWEP.Primary.DefaultClip = 0;
SWEP.Primary.Automatic = true;
SWEP.Primary.ClipSize = -1;
SWEP.Primary.Damage = 1;
SWEP.Primary.Delay = 1;
SWEP.Primary.Ammo = "";

function SWEP:Initialize()
	self:SetHoldType( "normal" )
end

function SWEP:DoDrawCrosshair( x, y )
	return true
end

function SWEP:PrimaryAttack()

end

function SWEP:SecondaryAttack()

end