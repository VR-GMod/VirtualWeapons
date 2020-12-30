local bits = 2

if SERVER then
    util.AddNetworkString( "VRWeapons" )

    net.Receive( "VRWeapons", function( len, ply )
        local hands = ply:GetActiveWeapon()
        if not IsValid( hands ) then return end
        if hands:GetClass() ~= "vr_empty" then return end

        local act = net.ReadUInt( bits )
        local left_hand = net.ReadBool()
        local pressed = net.ReadBool()

        local weapon = ply:GetNWEntity( "vr_weapon_" .. ( left_hand and "left" or "right" ) )

        if act == 0 then -- Pick up
            if not pressed then
                if IsValid( weapon ) then
                    weapon:Drop()
                end

                return
            end

            local pos, ang
            if left_hand then
                pos, ang = vrmod.GetLeftHandPose( ply ) 
            else
                pos, ang = vrmod.GetRightHandPose( ply )
            end

            local origin = LocalToWorld( Vector( 3, left_hand and -1.5 or 1.5, 0 ), Angle(), pos, ang )

            for k, v in ipairs( ents.FindInSphere( origin, 2 ) ) do
                if v.VRWeapon and not IsValid( v:GetCarrier() ) then
                    v:PickUp( ply, left_hand )

                    break
                end
            end

        elseif act == 1 then -- Trigger
            if IsValid( weapon ) and weapon:GetCarrier() == ply then
                if pressed then
                    weapon:Shoot()
                end
            end
        end
    end )
else
    local inputs = {
        ["boolean_left_pickup"] = function( pressed ) -- Left hand pickup
            net.Start( "VRWeapons" )
                net.WriteUInt( 0, bits )
                net.WriteBool( true )
                net.WriteBool( pressed )
            net.SendToServer()
        end,
        ["boolean_right_pickup"] = function( pressed ) -- Right hand pickup
            net.Start( "VRWeapons" )
                net.WriteUInt( 0, bits )
                net.WriteBool( false )
                net.WriteBool( pressed )
            net.SendToServer()
        end,
        ["boolean_reload"] = function( pressed ) -- Left hand trigger
            net.Start( "VRWeapons" )
                net.WriteUInt( 1, bits )
                net.WriteBool( true )
                net.WriteBool( pressed )
            net.SendToServer()
        end,
        ["boolean_primaryfire"] = function( pressed ) -- Right hand trigger
            net.Start( "VRWeapons" )
                net.WriteUInt( 1, bits )
                net.WriteBool( false )
                net.WriteBool( pressed )
            net.SendToServer()
        end,
        ["boolean_use"] = true, -- Just overwrite it
    }

    hook.Add( "VRMod_AllowDefaultAction", "VRWeapon:BlockDefaults", function( action )
        local weapon = LocalPlayer():GetActiveWeapon()

        if IsValid( weapon ) and weapon:GetClass() == "vr_empty" then
            return inputs[ action ] == nil
        end
    end )

    hook.Add( "VRMod_Input", "VRWeapons:Inputs", function( action, pressed )
        local weapon = LocalPlayer():GetActiveWeapon()

        if IsValid( weapon ) and weapon:GetClass() == "vr_empty" then
            if isfunction( inputs[ action ] ) then
                inputs[ action ]( pressed )
            end
        end
    end )

    -- Left hand bone fix, because the vrmod developer forgot to add a line....
    local callbackBone
    hook.Add("VRMod_Start", "VRWeapons:BoneFix", function(ply)
        callbackBone = ply:AddCallback("BuildBonePositions", function( ply, numbones )
            local steamid = ply:SteamID()
            if not g_VR.net[steamid].lerpedFrame or (ply:InVehicle() and ply:GetVehicle():GetClass() ~= "prop_vehicle_prisoner_pod") then return end
            -- Already set in VRmod:
            -- ply:SetBonePosition(characterInfo[steamid].bones.b_rightHand, g_VR.net[steamid].lerpedFrame.righthandPos, g_VR.net[steamid].lerpedFrame.righthandAng + Angle(0,0,180))
            ply:SetBonePosition(ply:LookupBone("ValveBiped.Bip01_L_Hand") or -1, g_VR.net[steamid].lerpedFrame.lefthandPos, g_VR.net[steamid].lerpedFrame.lefthandAng + Angle(0,0,180))
        end)
    end)

    hook.Add("VRMod_Exit", "VRWeapons:BoneFix", function(ply)
        if callbackBone then ply:RemoveCallback("BuildBonePositions", callbackBone) end
    end)
end