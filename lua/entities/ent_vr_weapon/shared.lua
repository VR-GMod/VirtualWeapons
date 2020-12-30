ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.Category = "Virtual Weapons"
ENT.Spawnable = true
ENT.VRWeapon = true

ENT.Model = "models/weapons/w_pistol.mdl"
ENT.ShootOffset = Vector( -5.8, 0.13, 0.5 )
ENT.ShootAngles = Angle( 0, 2, 0 )

ENT.OffsetPos = Vector( 5.5, 1, 2.75 )
ENT.OffsetAngles = Angle( 180, 0, 180 )

function ENT:SetupDataTables()
    self:NetworkVar( "String", 0, "Hand" )
    self:NetworkVar( "Entity", 0, "Carrier" )
end