AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.Category = "Virtual Weapons"
ENT.Spawnable = true
ENT.VRWeapon = true

ENT.Model = "models/weapons/w_pistol.mdl"

function ENT:SetupDataTables()
    self:NetworkVar( "String", 0, "Hand" )
    self:NetworkVar( "Entity", 0, "Carrier" )
end

function ENT:Initialize()
    self:SetModel( self.Model )

    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )
    self:SetCollisionGroup( COLLISION_GROUP_WEAPON )

    self:PhysicsInit( SOLID_VPHYSICS )
    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
    end
end

function ENT:PickUp( ply, left_hand )
    if not IsValid( ply ) then return false end
    if not ply:IsPlayer() then return false end
    if not ( IsValid( ply:GetActiveWeapon() ) and ply:GetActiveWeapon():GetClass() == "vr_empty" ) then return false end

    self:SetHand( left_hand and "left" or "right" )
    self:SetCarrier( ply )
    ply:SetNWEntity( "vr_weapon_" .. self:GetHand(), self )

    local pos, ang
    if left_hand then
        pos, ang = vrmod.GetLeftHandPose( ply ) 
    else
        pos, ang = vrmod.GetRightHandPose( ply )
    end

    --self:SetPos( pos )
    --self:SetAngles( ang )

    self:FollowBone( ply, ply:LookupBone( left_hand and "ValveBiped.Bip01_L_Hand" or "ValveBiped.Bip01_R_Hand" ) )
end

function ENT:OnPickedUp( left_hand )
end

function ENT:Drop()
    self:GetCarrier():SetNWEntity( "vr_weapon_" .. self:GetHand(), nil )

    self:SetHand( "" )
    self:SetCarrier( nil )
    self:SetParent()
end

function ENT:OnDropped()
end

function ENT:Shoot()
    if not IsValid( self:GetCarrier() ) then return end
    if not self:GetCarrier():IsPlayer() then return end

    self:FireBullets( {
        Attacker = self:GetCarrier(),
        Damage = 1, -- At the moment I just want to get it working, let's see damages later
        Force = 1, -- Same
        Num = 1,
        TracerName = "Tracer",
        Dir = self:GetForward(),
        Src = self:GetPos()
    } )
    self:EmitSound( "garrysmod/save_load" .. math.random( 1, 4 ) .. ".wav" )
end

function ENT:Draw()
    self:DrawModel()

    render.DrawLine( self:GetPos(), self:GetPos() * self:GetForward() * 10, Color( 255, 0, 0 ), true )
end