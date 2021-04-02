AddCSLuaFile()

ENT.Base 			= "base_nextbot"

function ENT:Initialize()
	self:SetCollisionGroup( COLLISION_GROUP_NONE )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	self.IsMonster = true

	self.LoseTargetDist	= 500
	self.SearchRadius 	= 500
    self.WanderDistance = 200
    self.SpawnZoneRadius = 1000
    self.SpawnPos = self:GetPos()
    self.AttackDistance = 8000
	self.SpeedMultiplier = 1

	self.AttackAnimTime = 0.2
	self.AttackDelay = 2

	if( CLIENT ) then
		BOTCHED.TEMP.Monsters[self] = true
	end
end

function ENT:SetupDataTables()
	self:NetworkVar( "Int", 0, "MaxHealth" )
	self:NetworkVar( "String", 0, "MonsterClass" )
end

function ENT:SetInitMonsterClass( monsterClass )
	local monsterConfig = BOTCHED.CONFIG.Monsters[monsterClass]
	if( not monsterConfig ) then
		self:Remove()
		return
	end

	self:SetMonsterClass( monsterClass )
	self:SetMaxHealth( monsterConfig.Health or 100 )
	self:SetHealth( self:GetMaxHealth() )
end

function ENT:SetEnemy( ent )
	self.Enemy = ent
end

function ENT:GetEnemy()
	return self.Enemy
end

function ENT:HaveEnemy()
	if ( self:GetEnemy() and IsValid(self:GetEnemy()) ) then
		if( self.SpawnPos:Distance( self:GetEnemy():GetPos() ) > self.SpawnZoneRadius ) then
			return self:FindEnemy()
        elseif( self:GetPos():Distance( self:GetEnemy():GetPos() ) > self.LoseTargetDist ) then
			return self:FindEnemy()
		elseif( self:GetEnemy():IsPlayer() and !self:GetEnemy():Alive() ) then
			return self:FindEnemy()
		end	

		return true
	else
		return self:FindEnemy()
	end
end

function ENT:FindEnemy()
	for k,v in ipairs( ents.FindInSphere( self:GetPos(), self.SearchRadius ) ) do
		if( v:IsPlayer() and v:Alive() and self.SpawnPos:Distance( v:GetPos() ) < self.SpawnZoneRadius ) then
			self:SetEnemy(v)
			self:EmitSound( self.AlertSound or "" )
			return true
		end
	end	

	self:SetEnemy(nil)
	return false
end

function ENT:EnemyIsInFront()
	local isInFront = false
	for k, v in ipairs( ents.FindInCone( self:GetPos(), self:GetForward()*200, 100, 45 ) ) do
		if( v == self:GetEnemy() ) then
			return true
		end
	end

	return false
end

function ENT:CanAttackEnemy()
	return self:GetPos():DistToSqr( self:GetEnemy():GetPos() ) <= self.AttackDistance and self:EnemyIsInFront()
end

function ENT:RunBehaviour()
	while( true ) do
		if( self:HaveEnemy() ) then
			if( self:GetPos():DistToSqr( self:GetEnemy():GetPos() ) <= self.AttackDistance ) then
				if( self:EnemyIsInFront() ) then
					if( not self.AttackStarted and CurTime() >= (self.LastAttack or 0)+self.AttackDelay ) then
						self.AttackStarted = true
						self.LastAttack = CurTime()

						self:StartActivity( ACT_MELEE_ATTACK1 )
						self:EmitSound( self.MeleeSound or "npc/zombie/zombie_hit.wav" )

						local startTime = CurTime()
						timer.Simple( self.AttackAnimTime, function()
							if( not IsValid( self ) ) then return end

							self.AttackStarted = false
							
							self:StartActivity( ACT_IDLE )

							if( not IsValid( self:GetEnemy() ) or not self:CanAttackEnemy() ) then return end
							self:GetEnemy():TakeDamage( (self.MeleeDamage and math.random( self.MeleeDamage[1], self.MeleeDamage[2] )) or 10, self, self )
						end )
					end
				else
					self.loco:FaceTowards( self:GetEnemy():GetPos() )
				end

				coroutine.wait( 0.1 )
			else
				self.loco:FaceTowards( self:GetEnemy():GetPos() )
				self:StartActivity( self.HasRunAct and ACT_RUN or ACT_WALK )
				self.loco:SetDesiredSpeed( 200*self.SpeedMultiplier )
				self.loco:SetAcceleration( 700 )
				self:ChaseEnemy()
				self.loco:SetAcceleration( 400 )
				self:StartActivity( ACT_IDLE )
			end
		else
			self:StartActivity( ACT_WALK )
			self.loco:SetDesiredSpeed( 200*self.SpeedMultiplier )

            if( self:GetPos():DistToSqr( self.SpawnPos ) > (self.WanderDistance*1.1)^2 ) then
                self:MoveToPos( self.SpawnPos )
            else
                self:MoveToPos( self:GetPos() + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * self.WanderDistance )
            end
            
			self:StartActivity( ACT_IDLE )
			coroutine.wait( 1 )
		end
	end
end	

function ENT:ChaseEnemy( options )
	local options = options or {}
	local path = Path( "Follow" )
	path:SetMinLookAheadDistance( options.lookahead or 300 )
	path:SetGoalTolerance( options.tolerance or 20 )
	path:Compute( self, self:GetEnemy():GetPos() )

	if ( !path:IsValid() ) then return "failed" end

	while( path:IsValid() and self:HaveEnemy() and not self:CanAttackEnemy() ) do
	
		if ( path:GetAge() > 0.1 ) then
			path:Compute(self, self:GetEnemy():GetPos())
		end
		path:Update( self )
		
		if ( options.draw ) then path:Draw() end

		if ( self.loco:IsStuck() ) then
			self:HandleStuck()
			return "stuck"
		end

		coroutine.yield()

	end

	return "ok"

end

function ENT:OnRemove()
	self:StopSound( self.PassiveSound or "" )
end

function ENT:OnKilled( dmginfo )
	hook.Call( "OnNPCKilled", GAMEMODE, self, dmginfo:GetAttacker(), dmginfo:GetInflictor() )

	self:EmitSound( self.DeathSound or "" )
	self:StopSound( self.PassiveSound or "" )
	
	local body = ents.Create( "prop_ragdoll" )
	body:SetPos( self:GetPos() )
	body:SetModel( self:GetModel() )
	body:SetCollisionGroup( 1 )
	body:Spawn()
	
	self:Remove()
	
	timer.Simple( 5, function()
		body:Remove()
	end )

	local attacker = dmginfo:GetAttacker()
	
	if( IsValid( attacker ) and attacker:IsPlayer() ) then
		local monsterConfig = BOTCHED.CONFIG.Monsters[self:GetMonsterClass()] or {}

		attacker:AddExperience( monsterConfig.PlayerEXP )
		attacker:SendExpNotification( monsterConfig.PlayerEXP, (monsterConfig.Name or "Monster") .. " Killed" )
	end
end