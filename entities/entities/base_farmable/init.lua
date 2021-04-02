AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()

end

function ENT:Use( ply )
	if( CurTime() < (ply.BOTCHED_USE_COOLDOWN or 0) ) then return end
	ply.BOTCHED_USE_COOLDOWN = CurTime()+0.1

	if( not self.FarmTool ) then return end

	if( (self.GetFallEndTime and self:GetFallEndTime() != 0) or ply:GetPos():DistToSqr( self:GetPos() ) > 5000 ) then return end

	local farmer = self:GetFarmer()
	if( IsValid( farmer ) and farmer:GetPos():DistToSqr( self:GetPos() ) < 5000 ) then
		if( farmer == ply ) then
			self:CancelFarming()
		else
			ply:SendChatNotification( "Another player is already farming this!", 2 )
		end
		return
	end

	local farmWep = ply:GetChosenWeapon( self.FarmTool )

	if( not IsValid( farmWep ) ) then
		ply:SendChatNotification( "You need a " .. self.FarmTool .. " equipped to farm this!", 2 )
		return
	end

	if( ply:Stamina() < self.StaminaCost ) then return end
    ply:TakeStamina( self.StaminaCost )

	self:SetFarmer( ply )
	self:SetStartTime( CurTime() )

	ply:SelectWeapon( farmWep:GetClass() )
	farmWep:StartFarmingAnim()

	local oldAngles = ply:EyeAngles()
	local newAngles = (self:GetPos()-ply:GetShootPos()):Angle()
	newAngles[1] = oldAngles[1]

	ply:Freeze( true )
	ply:SetEyeAngles( newAngles )

	ply.BOTCHED_USE_COOLDOWN = 0
end

function ENT:CancelFarming()
	local ply = self:GetFarmer()
	ply:SelectPrimaryWeapon()
	ply:Freeze( false )

	local farmWep = ply:GetChosenWeapon( self.FarmTool )
	if( IsValid( farmWep ) ) then farmWep:StopFarmingAnim() end

	self:SetFarmer( nil )
	self:SetStartTime( 0 )
end

function ENT:FinishFarming()
	local ply = self:GetFarmer()

	ply:AddExperience( self.RewardEXP )
	ply:SendExpNotification( self.RewardEXP, self.RewardReason )

	local randomNum = math.Rand( 0, 100 )
	local previousChance = 0
	for k, v in pairs( self.RewardItems ) do
		previousChance = previousChance+v[2]
		if( randomNum <= previousChance ) then
			ply:AddInventoryItems( v[1], v[3] or 1 )
			ply:SendItemNotification( v[1], v[3] or 1 )
			break
		end
	end

	if( self.SetEndAngles and self.SetFallEndTime ) then
		local angles = self:GetAngles()
		self:SetEndAngles( Angle( angles[1], ply:GetAngles()[2]+90, angles[3] ) )

		self:SetFallEndTime( CurTime()+self:GetFallTime() )

		timer.Simple( self:GetFallTime()+1, function()
			if( IsValid( self ) ) then self:Remove() end
		end )
	else
		self:Remove()
	end

	self:CancelFarming()
end

function ENT:Think()
	local ply = self:GetFarmer()
	if( IsValid( ply ) ) then
		if( CurTime() >= self:GetStartTime()+self.FarmDuration ) then
			self:FinishFarming()
		elseif( ply:GetPos():DistToSqr( self:GetPos() ) > 5000 ) then
			self:CancelFarming()
		end
	end
end