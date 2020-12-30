AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

function ENT:Initialize()
    self:SetModel( self.Model )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

    self:SetCollisionGroup( COLLISION_GROUP_WEAPON )

    local phys = self:GetPhysicsObject()
    if IsValid( phys ) then
        phys:Wake()
    end
end

function ENT:CalculatePose()
    local ply = self:GetCarrier()
    if not IsValid( ply ) then return false end
    if not ply:IsPlayer() then return false end

    local left_handed = self:GetHand() == "left"

    local pos, ang
    if left_handed then
        pos, ang = vrmod.GetLeftHandPose( ply ) 
    else
        pos, ang = vrmod.GetRightHandPose( ply )
    end

    pos, ang = LocalToWorld( left_handed and ( self.OffsetPos * Vector( 1, -1, 1 ) ) or self.OffsetPos, self.OffsetAngles, pos, ang )

    self:SetPos( pos )
    local phys = self:GetPhysicsObject()
    if IsValid( phys ) then
        phys:SetPos( pos )
    end
    self:SetAngles( ang )

    return pos, ang
end

function ENT:PickUp( ply, left_hand )
    if not IsValid( ply ) then return false end
    if not ply:IsPlayer() then return false end
    if not ( IsValid( ply:GetActiveWeapon() ) and ply:GetActiveWeapon():GetClass() == "vr_empty" ) then return false end

    self:SetHand( left_hand and "left" or "right" )
    self:SetCarrier( ply )
    ply:SetNWEntity( "vr_weapon_" .. self:GetHand(), self )

    self:OnPickedUp( ply, left_hand )
end

function ENT:OnPickedUp( ply, left_hand )
end

function ENT:Drop()
    self:SetParent()
    self:CalculatePose()

    self:SetMoveType( MOVETYPE_VPHYSICS )
    local phys = self:GetPhysicsObject()
    if IsValid( phys ) then
        phys:EnableMotion( true )
    end

    self:OnDropped()

    self:GetCarrier():SetNWEntity( "vr_weapon_" .. self:GetHand(), nil )
    self:SetHand( "" )
    self:SetCarrier( nil )
end

function ENT:OnDropped()
end

function ENT:Shoot()
    local ply = self:GetCarrier()
    if not IsValid( ply ) then return end
    if not ply:IsPlayer() then return end

    local pos, ang = self:CalculatePose()
    pos, ang = LocalToWorld( self.ShootOffset, self.ShootAngles, pos, ang )

    self:FireBullets( {
        Attacker = ply,
        Damage = 1, -- At the moment I just want to get it working, let's see damages later
        Force = 1, -- Same
        Num = 1,
        TracerName = "Tracer",
        Dir = - ang:Forward(),
        Src = pos
    } )

    self:EmitSound( "weapons/pistol/pistol_fire2.wav" )
end

hook.Add( "PhysgunPickup", "VRW:DisablePhysgun", function( ply, ent )
	if ent.VRWeapon and IsValid( ent:GetCarrier() ) then return false end
end )