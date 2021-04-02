include('shared.lua')

function ENT:Draw()
    if( (self:GetFallEndTime() or 0) == 0 ) then
	    self:DrawModel()
    else
        if( not IsValid( self.fallModel ) ) then
            self.fallModel = ents.CreateClientProp()
            self.fallModel:SetPos( self:GetPos() )
            self.fallModel:SetModel( self:GetModel() )
            self.fallModel:Spawn()
        end

        self.fallModel:SetPos( self:GetPos() )
        local endAngles = self:GetEndAngles()
        local fallLerp = Lerp( math.Clamp( 1-((self:GetFallEndTime()-CurTime())/self:GetFallTime()), 0, 1 ), 0, 90 )
        self.fallModel:SetAngles( Angle( endAngles[1], endAngles[2], endAngles[3]+fallLerp ) )
    end
end

DEFINE_BASECLASS( "base_farmable" )
function ENT:OnRemove()
    if( IsValid( self.fallModel ) ) then
        self.fallModel:Remove()
    end

    BaseClass.OnRemove( self )
end