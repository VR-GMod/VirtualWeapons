include( "shared.lua" )

function ENT:Draw()
    self:DrawModel()

    render.DrawLine( self:GetPos(), self:GetPos() - self:GetForward() * 10, Color( 255, 0, 0 ), true )
end

local function draw_bone( ply, name, color )
    local pos, ang = ply:GetBonePosition( isnumber( name ) and name or ply:LookupBone( name ) )
    if not pos then return end
    render.DrawWireframeSphere( pos, 1, 10, 10, color or color_white, false )
end

hook.Add( "PostPlayerDraw", "VRW:Test", function( ply )
    render.DrawWireframeSphere( Vector( 0, 0, 0 ), 100, 10, 10, Color( 0, 255, 0 ), false )

    for i = 0, ply:GetBoneCount() + 1 do
        draw_bone( ply, i )
    end

    
    draw_bone( ply, "ValveBiped.Bip01_L_Hand", Color( 255, 0, 0 ) )
    draw_bone( ply, "ValveBiped.Bip01_R_Hand", Color( 255, 0, 0 ) )
end )