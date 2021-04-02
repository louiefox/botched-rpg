if CLIENT then
	SWEP.PrintName = "Primary Weapon"
	SWEP.Slot = 1
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = true
end

SWEP.Author = "Brickwall"
SWEP.Instructions = "LeftClick - Attack, R - Holster"
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.Damage = 0
SWEP.Primary.Delay = 0.6
SWEP.Primary.Ammo = ""

SWEP.WorldModel = ""
SWEP.AttackHoldType = "melee"

function SWEP:Initialize()
	self:SetHoldType( "normal" )
end

function SWEP:SetupDataTables()
	self:NetworkVar( "Bool", 0, "IsHolstered" )
end

function SWEP:PrimaryAttack()
	if( self:GetIsHolstered() ) then
		self:SetIsHolstered( false )
	end
	
	if( self:GetHoldType() != self.AttackHoldType ) then
		self:SetNextPrimaryFire( CurTime()+0.2 )
		self:SetHoldType( self.AttackHoldType )
	else
		self:SetNextPrimaryFire( CurTime()+self.Primary.Delay )
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
		self:EmitSound( "npc/vort/claw_swing2.wav" )

		if( SERVER ) then
			timer.Simple( 0.07, function()
				if( not IsValid( self ) or not IsValid( self.Owner ) ) then return end

				local dir = self.Owner:GetAimVector()
				local angle = math.cos( math.rad( 30 ) )
				local startPos = self.Owner:EyePos()
				local entities = ents.FindInCone( startPos, dir, 65, angle )
		
				for k, v in ipairs( entities ) do
					if( not IsValid( v ) or not v.IsMonster ) then continue end
		
					net.Start( "Botched.SendWeaponParticleEffect" )
						net.WriteEntity( v )
						net.WriteVector( Vector( 0, 0, 35 ) )
						net.WriteString( "[2]gushing_blood" )
					net.Broadcast()

					self:EmitSound( "botched/monster_hit.wav" )
					v:TakeDamage( self.Primary.Damage, self.Owner, self )
		
					break
				end
			end )
		end
	end
end

function SWEP:SecondaryAttack()

end

if( SERVER ) then
	util.AddNetworkString( "Botched.SendWeaponParticleEffect" )
	function SWEP:Reload()
		if( CurTime() < (self.lastReload or 0)+0.5 ) then return end
		self.lastReload = CurTime()

		if( self:GetHoldType() != "normal" ) then
			self:SetHoldType( "normal" )
		end
		
		if( self:GetIsHolstered() ) then
			self:SetIsHolstered( false )
		else
			self:SetIsHolstered( true )
		end
	end

	function SWEP:Think()
		if( self:GetHoldType() == self.AttackHoldType and CurTime() >= self:GetNextPrimaryFire()+1 ) then
			self:SetHoldType( "normal" )
		end
	end
end

if( CLIENT ) then
	function SWEP:DrawWorldModel()
		local owner = self:GetOwner()

		if( not IsValid( self.ClientsideWorldModel ) ) then
			self.ClientsideWorldModel = ClientsideModel( self.WorldModel )
			self.ClientsideWorldModel:SetNoDraw( true )
		end

		if( IsValid( owner ) ) then
			local offsetVec, offsetAng, matrix
			if( not self:GetIsHolstered() ) then
				offsetVec = Vector( 3.2, -0.3, 4 )
				offsetAng = Angle( 180, 0, 0 )
				
				local boneid = owner:LookupBone( "ValveBiped.Bip01_R_Hand" )
				if( boneid ) then matrix = owner:GetBoneMatrix( boneid ) end
			else
				local adjustmentsCfg = BOTCHED.DEVCONFIG.PlayermodelAdjustments[owner:GetModel()]
				if( not adjustmentsCfg or not adjustmentsCfg.WeaponHolster ) then
					offsetVec = Vector( -15, -6.5, 5 )
					offsetAng = Angle( 110, 0, 0 )
				else
					offsetVec = Vector( -15, adjustmentsCfg.WeaponHolster.BackDist, 5 )
					offsetAng = Angle( 110, 0, 0 )
				end
				
				local boneid = owner:LookupBone( "ValveBiped.Bip01_Spine" )
				if( boneid ) then matrix = owner:GetBoneMatrix( boneid ) end
			end

			if( matrix ) then
				local newPos, newAng = LocalToWorld( offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles() )

				self.ClientsideWorldModel:SetPos( newPos )
				self.ClientsideWorldModel:SetAngles( newAng )

				self.ClientsideWorldModel:SetupBones()
			end
		else
			self.ClientsideWorldModel:SetPos( self:GetPos() )
			self.ClientsideWorldModel:SetAngles( self:GetAngles() )
		end

		self.ClientsideWorldModel:DrawModel()
	end

	net.Receive( "Botched.SendWeaponParticleEffect", function()
		local ent = net.ReadEntity()
		if( not IsValid( ent ) ) then return end

		local offset = net.ReadVector()
		local effect = net.ReadString()

		local parSys = CreateParticleSystem( ent, effect, PATTACH_ABSORIGIN_FOLLOW, 0, offset )

		timer.Simple( 0.5, function()
			parSys:StopEmission( false, true, false )
		end )
	end )
end