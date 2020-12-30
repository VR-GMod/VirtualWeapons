include( "shared.lua" )
local mat = Material( "debug/debugwireframe" )

function ENT:Draw()
    if not IsValid( self:GetCarrier() ) and self:GetHand() == "" then
        self:DrawModel()
    end
end

hook.Add( "PostPlayerDraw", "VRW:Test", function( ply )
    local right_weapon = ply:GetNWEntity( "vr_weapon_right" )
    if IsValid( right_weapon ) and right_weapon:GetCarrier() == ply then
        local pos, ang = vrmod.GetRightHandPose( ply )
        pos, ang = LocalToWorld( right_weapon.OffsetPos, right_weapon.OffsetAngles, pos, ang )
        
        render.Model( {
            model = right_weapon.Model,
            pos = pos,
            angle = ang
        } )

        pos, ang = LocalToWorld( right_weapon.ShootOffset, right_weapon.ShootAngles, pos, ang )

        render.DrawWireframeSphere( pos, 0.1, 10, 10, Color( 255, 0, 0 ), false )
        render.DrawLine( pos, pos + -ang:Forward() * 1000, Color( 255, 0, 0 ), true )
    end

    local left_weapon = ply:GetNWEntity( "vr_weapon_left" )
    if IsValid( left_weapon ) and left_weapon:GetCarrier() == ply then
        local pos, ang = vrmod.GetLeftHandPose( ply )
        pos, ang = LocalToWorld( left_weapon.OffsetPos * Vector( 1, -1, 1 ), left_weapon.OffsetAngles, pos, ang )
        
        render.Model( {
            model = left_weapon.Model,
            pos = pos,
            angle = ang
        } )

        pos, ang = LocalToWorld( left_weapon.ShootOffset, left_weapon.ShootAngles, pos, ang )

        render.DrawWireframeSphere( pos, 0.1, 10, 10, Color( 255, 0, 0 ), false )
        render.DrawLine( pos, pos + -ang:Forward() * 1000, Color( 255, 0, 0 ), true )
    end
end )