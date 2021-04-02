AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:Initialize()
	self:SetModel( "models/hunter/blocks/cube025x025x025.mdl ")
	self:SetNoDraw( true ) 
	self:SetSkin( 1 )      
	self:DrawShadow( false )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	self:SetCollisionGroup( COLLISION_GROUP_DEBRIS )

	ParticleEffectAttach( "[9]colorful_trail_1", 1, self, 1 )

	--[9]colorful_trail_1
	--[8]magic_flame

	--[1]flametrail
	--[1]smoke_lifting_01
end

function ENT:SetDamage( damage )
	self.Damage = damage
end

function ENT:SetTarget( targetEnt )
	self.TargetEnt = targetEnt
end

function ENT:SetAttacker( attacker )
	self.Attacker = attacker
end

function ENT:SetOffset( offset )
	self.Offset = offset
end

function ENT:FireAtTarget()
	self.StartPos = self:GetPos()
	self.StartTime = CurTime()

	self.TravelTime = self.StartPos:DistToSqr( self.TargetEnt:GetPos()+(self.Offset or Vector( 0, 0, 0 )) )/1000000
end

function ENT:Think()
	if( not self.TargetEnt or not self.StartTime or not self.TravelTime ) then return end

	if( not IsValid( self.TargetEnt ) ) then
		self:Remove()
		return
	end

	if( self.Offset ) then
		self:SetPos( LerpVector( math.Clamp( (CurTime()-self.StartTime)/self.TravelTime, 0, 1 ), self.StartPos, self.TargetEnt:GetPos()+self.Offset ) )
	else
		self:SetPos( LerpVector( math.Clamp( (CurTime()-self.StartTime)/self.TravelTime, 0, 1 ), self.StartPos, self.TargetEnt:GetPos() ) )
	end

	if( CurTime() >= self.StartTime+self.TravelTime ) then
		if( IsValid( self.TargetEnt ) ) then
			self.TargetEnt:TakeDamage( self.Damage or 0, self.Attacker, self )
		end

		self:EmitSound( "ambient/explosions/explode_7.wav", nil, nil, 0.5 )
		self:Remove()
	end
end