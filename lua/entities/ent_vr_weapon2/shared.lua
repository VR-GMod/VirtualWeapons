ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.Category = "Virtual Weapons"
ENT.Spawnable = true
ENT.VRWeapon = true

ENT.Model = "models/weapons/w_pistol.mdl"

function ENT:SetupDataTables()
    self:NetworkVar( "String", 0, "Hand" )
    self:NetworkVar( "Entity", 0, "Carrier" )
end