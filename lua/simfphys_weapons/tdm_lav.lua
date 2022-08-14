local apc_susdata = {}
for i = 1,4 do
	apc_susdata[i] = {
		attachment = "sus_left_attach_" .. i,
		poseparameter = "suspension_left_" .. i,
	}

	local ir = i + 4

	apc_susdata[ir] = {
		attachment = "sus_right_attach_" .. i,
		poseparameter = "suspension_right_" .. i,
	}
end

simfphys.weapon.ATGMClipsize = 2
simfphys.weapon.GunClipsize = 20

local function cannon_fire(ply,vehicle,shootOrigin,shootDirection)
	vehicle:EmitSound("tdm/lav_fire.wav", 130)

	vehicle:GetPhysicsObject():ApplyForceOffset( -shootDirection * 20000, shootOrigin )

	local projectile = ents.Create( "simfphys_tankprojectile" )
	projectile:SetPos( shootOrigin )
	projectile:SetAngles( shootDirection:Angle() )
	projectile:SetOwner( vehicle )
	projectile.Attacker = ply
	projectile.DeflectAng = 0
	projectile.AttackingEnt = vehicle
	projectile.Force = 30
	projectile.Damage = 80
	projectile.BlastRadius = 96
	projectile.BlastDamage = 50
	projectile:SetBlastEffect("simfphys_tankweapon_explosion_micro")
	projectile:SetSize( 4 )
	projectile.Filter = table.Copy( vehicle.VehicleData["filter"] )
	projectile.MuzzleVelocity = 450
	projectile:Spawn()
	projectile:Activate()
end

local function atgm_fire(ply,vehicle,shootOrigin,shootDirection)
	vehicle:EmitSound("tdm/lav_missile.wav", 120)

	vehicle:GetPhysicsObject():ApplyForceOffset( -shootDirection * 10000, shootOrigin )

	vehicle.missile = ents.Create( "tdm_atgm" )
	vehicle.missile:SetPos( shootOrigin )
	vehicle.missile:SetAngles( shootDirection:Angle() )
	vehicle.missile:SetOwner( ply )
	vehicle.missile:Spawn()
	vehicle.missile:Activate()
	vehicle.missile.DirVector = shootDirection

	vehicle.missile:SetVelocity(shootDirection * 9000)

	vehicle.MissileTracking = vehicle.MissileTracking or {}

	table.insert(vehicle.MissileTracking, vehicle.missile)
end

function simfphys.weapon:ValidClasses()
	return { "tdm_lav" }
end

function simfphys.weapon:Initialize( vehicle )
	vehicle:SetNWBool( "SpecialCam_Loader", false )
	vehicle:SetNWFloat( "SpecialCam_LoaderTime", 5 )

	simfphys.RegisterCrosshair( vehicle:GetDriverSeat(), { Attachment = "muzzle", Direction = Vector(0, 0, -1), Type = 3 } )
	simfphys.RegisterCamera( vehicle:GetDriverSeat(), Vector(15,53,-20), Vector(0,45,100), true, "muzzle_up" )

	simfphys.RegisterCamera( vehicle.pSeat[1], Vector(-4,26,24), Vector(0,45,100), true, "muzzle_up" )

	vehicle:SetNWString( "WeaponMode", "Cannon | ATGM")
	vehicle:SetNWInt("MaxWPNAmmo", self.GunClipsize)
	vehicle:SetNWInt("CurWPNAmmo", self.GunClipsize)
	vehicle:SetNWInt("MaxWPNAmmo2", self.ATGMClipsize)
	vehicle:SetNWInt("CurWPNAmmo2", self.ATGMClipsize)
	vehicle:SetNWString("WPNType", "cannon")
	vehicle:SetNWString("WPNType2", "missile")
	--vehicle:SetNWString("WeaponMode", tostring(self.GunClipsize) .. " | " .. tostring(self.ATGMClipsize))

	self.ATGMClip = self.ATGMClipsize

	timer.Simple( 1, function()
		if not IsValid( vehicle ) then return end
		if not vehicle.VehicleData["filter"] then print("[simfphys Armed Vehicle Pack] ERROR:TRACE FILTER IS INVALID. PLEASE UPDATE SIMFPHYS BASE") return end

		vehicle.WheelOnGround = function( ent )
			ent.FrontWheelPowered = ent:GetPowerDistribution() ~= 1
			ent.RearWheelPowered = ent:GetPowerDistribution() ~= -1

			for i = 1, table.Count( ent.Wheels ) do
				local Wheel = ent.Wheels[i]
				if IsValid( Wheel ) then
					local dmgMul = Wheel:GetDamaged() and 0.5 or 1
					local surfacemul = simfphys.TractionData[Wheel:GetSurfaceMaterial():lower()]

					ent.VehicleData[ "SurfaceMul_" .. i ] = (surfacemul and math.max(surfacemul,0.001) or 1) * dmgMul

					local WheelPos = ent:LogicWheelPos( i )

					local WheelRadius = WheelPos.IsFrontWheel and ent.FrontWheelRadius or ent.RearWheelRadius
					local startpos = Wheel:GetPos()
					local dir = -ent.Up
					local len = WheelRadius + math.Clamp(-ent.Vel.z / 50,2.5,6)
					local HullSize = Vector(WheelRadius,WheelRadius,0)
					local tr = util.TraceHull( {
						start = startpos,
						endpos = startpos + dir * len,
						maxs = HullSize,
						mins = -HullSize,
						filter = ent.VehicleData["filter"]
					} )

					local onground = self:IsOnGround( vehicle ) and 1 or 0
					Wheel:SetOnGround( onground )
					ent.VehicleData[ "onGround_" .. i ] = onground

					if tr.Hit then
						Wheel:SetSpeed( Wheel.FX )
						Wheel:SetSkidSound( Wheel.skid )
						Wheel:SetSurfaceMaterial( util.GetSurfacePropName( tr.SurfaceProps ) )
					end
				end
			end

			local FrontOnGround = math.max(ent.VehicleData[ "onGround_1" ],ent.VehicleData[ "onGround_2" ])
			local RearOnGround = math.max(ent.VehicleData[ "onGround_3" ],ent.VehicleData[ "onGround_4" ])

			ent.DriveWheelsOnGround = math.max(ent.FrontWheelPowered and FrontOnGround or 0,ent.RearWheelPowered and RearOnGround or 0)
		end
	end)
end

function simfphys.weapon:GetForwardSpeed( vehicle )
	return vehicle.ForwardSpeed
end

function simfphys.weapon:IsOnGround( vehicle )
	return vehicle.susOnGround == true
end

function simfphys.weapon:AimCannon( ply, vehicle, pod, Attachment )
	if not IsValid( pod ) then return end

	local Aimang = pod:WorldToLocalAngles( ply:EyeAngles() )
	Aimang:Normalize()

	local AimRate = 50

	local Angles = vehicle:WorldToLocalAngles( Aimang + Angle(-2.3,-90,0) )

	vehicle.sm_pp_yaw = vehicle.sm_pp_yaw and math.ApproachAngle( vehicle.sm_pp_yaw, Angles.y, AimRate * FrameTime() ) or 0
	vehicle.sm_pp_pitch = vehicle.sm_pp_pitch and math.ApproachAngle( vehicle.sm_pp_pitch, -Angles.p, AimRate * FrameTime() ) or 0

	local TargetAng = Angle(vehicle.sm_pp_pitch,vehicle.sm_pp_yaw,0)
	TargetAng:Normalize()

	vehicle:SetPoseParameter("cannon_aim_yaw", TargetAng.y )
	vehicle:SetPoseParameter("cannon_aim_pitch", TargetAng.p )
end

function simfphys.weapon:ControlTurret( vehicle, deltapos )
	if not istable( vehicle.PassengerSeats ) or not istable( vehicle.pSeat ) then return end

	local pod = vehicle:GetDriverSeat()

	if not IsValid( pod ) then return end

	local ply = pod:GetDriver()

	if not IsValid( ply ) then return end

	-- local safemode = ply:KeyDown( IN_WALK )

	-- if vehicle.ButtonSafeMode ~= safemode then
	-- 	vehicle.ButtonSafeMode = safemode

	-- 	if safemode then
	-- 		vehicle:SetNWBool( "TurretSafeMode", not vehicle:GetNWBool( "TurretSafeMode", true ) )

	-- 		if vehicle:GetNWBool( "TurretSafeMode" ) then
	-- 			vehicle:EmitSound( "vehicles/tank_turret_stop1.wav")
	-- 		else
	-- 			vehicle:EmitSound( "vehicles/tank_readyfire1.wav")
	-- 		end
	-- 	end
	-- end

	-- if vehicle:GetNWBool( "TurretSafeMode", true ) then return end

	local ID = vehicle:LookupAttachment( "muzzle" )
	local Attachment = vehicle:GetAttachment( ID )

	self:AimCannon( ply, vehicle, pod, Attachment )

	local DeltaP = deltapos * engine.TickInterval()

	local fire = ply:KeyDown( IN_ATTACK )
	local fire2 = ply:KeyDown( IN_ATTACK2 )

	if fire then
		self:PrimaryAttack( vehicle, ply, Attachment.Pos + DeltaP, Attachment )
	end

	local ID2 = vehicle:LookupAttachment( "muzzle_up" )
	local Attachment2 = vehicle:GetAttachment( ID2 )

	if fire2 then
		self:SecondaryAttack( vehicle, ply, Attachment2.Pos + DeltaP, Attachment2 )
	end
end

function simfphys.weapon:PrimaryAttack( vehicle, ply, shootOrigin, Attachment )

	self.GunClip = self.GunClip or self.GunClipsize

	if not self:CanPrimaryAttack( vehicle ) then return end

	if self.GunClip <= 0 then
		self.GunClip = self.GunClipsize
		vehicle:EmitSound("simulated_vehicles/weapons/apc_reload.wav")
		self:SetNextPrimaryFire(vehicle, CurTime() + 2)
		vehicle:SetNWInt("CurWPNAmmo", self.GunClip)
		--vehicle:SetNWString("WeaponMode", tostring(self.GunClip) .. " | " .. tostring(self.ATGMClip))
		return
	end

	self.GunClip = self.GunClip - 1
	vehicle:SetNWInt("CurWPNAmmo", self.GunClip)
	--vehicle:SetNWString("WeaponMode", tostring(self.GunClip) .. " | " .. tostring(self.ATGMClip))

	local shootDirection = -Attachment.Ang:Up()

	vehicle:PlayAnimation( "fire" )
	cannon_fire( ply, vehicle, shootOrigin + shootDirection * 80, shootDirection )

	local effectdata = EffectData()
		effectdata:SetEntity( vehicle )
	util.Effect( "arctic_apc_muzzle", effectdata, true, true )

	self:SetNextPrimaryFire( vehicle, CurTime() + 0.3 )
end

function simfphys.weapon:SecondaryAttack( vehicle, ply, shootOrigin, Attachment )

	self.ATGMClip = self.ATGMClip or self.ATGMClipsize

	if not self:CanSecondaryAttack( vehicle ) then return end

	if self.ATGMClip <= 0 then
		-- self.ATGMClip = self.ATGMClipsize
		-- vehicle:EmitSound("tiger_reload")
		-- self:SetNextSecondaryFire( vehicle, CurTime() + 6 )
		return
	end

	local up = self.ATGMClip == 2

	local AttachmentID = up and vehicle:LookupAttachment( "muzzle_up" ) or vehicle:LookupAttachment( "muzzle_down" )
	local Attachment = vehicle:GetAttachment( AttachmentID )

	self.ATGMClip = self.ATGMClip - 1
	vehicle:SetNWInt("CurWPNAmmo2", self.ATGMClip)
	--vehicle:SetNWString("WeaponMode", tostring(self.GunClip) .. " | " .. tostring(self.ATGMClip))

	local shootDirection = -Attachment.Ang:Up()

	atgm_fire( ply, vehicle, shootOrigin + shootDirection * 80, shootDirection )

	if (self.ATGMNext or 0) == 0 then
		self.ATGMNext = CurTime() + 5
	end

	self:SetNextSecondaryFire( vehicle, CurTime() + 0.5 )
end

function simfphys.weapon:CanPrimaryAttack( vehicle )
	vehicle.NextShoot = vehicle.NextShoot or 0
	return vehicle.NextShoot < CurTime()
end

function simfphys.weapon:SetNextPrimaryFire( vehicle, time )
	vehicle.NextShoot = time

	-- vehicle:SetNWFloat( "SpecialCam_LoaderNext", time )
end

function simfphys.weapon:CanSecondaryAttack( vehicle )
	vehicle.NextShoot2 = vehicle.NextShoot2 or 0
	return vehicle.NextShoot2 < CurTime()
end

function simfphys.weapon:SetNextSecondaryFire( vehicle, time )
	vehicle.NextShoot2 = time
end

function simfphys.weapon:ModPhysics( vehicle, wheelslocked )
	if wheelslocked and self:IsOnGround( vehicle ) then
		local phys = vehicle:GetPhysicsObject()
		phys:ApplyForceCenter( -vehicle:GetVelocity() * phys:GetMass() * 0.04 )
	end
end

function simfphys.weapon:ControlTrackSounds( vehicle, wheelslocked )
	local speed = math.abs( self:GetForwardSpeed( vehicle ) )
	local fastenuf = speed > 20 and not wheelslocked and self:IsOnGround( vehicle )

	if fastenuf ~= vehicle.fastenuf then
		vehicle.fastenuf = fastenuf

		if fastenuf then
			vehicle.track_snd = CreateSound( vehicle, "" )
			vehicle.track_snd:PlayEx(0,0)
			vehicle:CallOnRemove( "stopmesounds", function( veh )
				if veh.track_snd then
					veh.track_snd:Stop()
				end
			end)
		else
			if vehicle.track_snd then
				vehicle.track_snd:Stop()
				vehicle.track_snd = nil
			end
		end
	end

	if vehicle.track_snd then
		vehicle.track_snd:ChangePitch( math.Clamp(60 + speed / 40,0,150) )
		vehicle.track_snd:ChangeVolume( math.min( math.max(speed - 20,0) / 200,1) )
	end
end

function simfphys.weapon:Think( vehicle )
	if not IsValid( vehicle ) or not vehicle:IsInitialized() then return end

	vehicle.wOldPos = vehicle.wOldPos or Vector(0,0,0)
	local deltapos = vehicle:GetPos() - vehicle.wOldPos
	vehicle.wOldPos = vehicle:GetPos()

	local handbrake = vehicle:GetHandBrakeEnabled()

	self:UpdateSuspension( vehicle )
	self:DoWheelSpin( vehicle )
	self:ControlTurret( vehicle, deltapos )
	self:ControlTrackSounds( vehicle, handbrake )
	self:ModPhysics( vehicle, handbrake )

	local ID = vehicle:LookupAttachment( "muzzle_up" )
	local Attachment = vehicle:GetAttachment( ID )

	local filter = table.Copy(vehicle.MissileTracking or {})
	table.Add(filter, {vehicle})

	local tr = util.TraceLine( {
		start = Attachment.Pos,
		endpos = Attachment.Pos + -Attachment.Ang:Up() * 30000,
		filter = filter
	} )

	local Aimpos = tr.HitPos

	local remove = {}
	for i, missile in pairs(vehicle.MissileTracking or {}) do
		if IsValid( missile ) then
			local targetdir = Aimpos - missile:GetPos()
			targetdir:Normalize()
			missile.DirVector = missile.DirVector + (targetdir - missile.DirVector) * 1

			local vel = -missile:GetVelocity() + missile.DirVector * 9000

			local phys = missile:GetPhysicsObject()

			phys:SetVelocity( vel )
			missile:SetAngles( missile.DirVector:Angle() )
		else
			table.insert(remove, i)
		end
	end

	for k, i in pairs(remove) do
		table.remove(vehicle.MissileTracking, i)
	end

	if (self.ATGMNext or 0) > 0 and self.ATGMNext < CurTime() then
		self.ATGMClip = self.ATGMClip + 1
		vehicle:SetNWInt("CurWPNAmmo2", self.ATGMClip)
		--vehicle:SetNWString("WeaponMode", tostring(self.GunClip) .. " | " .. tostring(self.ATGMClip))
		vehicle:EmitSound("buttons/lever6.wav", 75, 105)
		if self.ATGMClip < self.ATGMClipsize then
			self.ATGMNext = CurTime() + 5
		else
			self.ATGMNext = 0
		end
	end
end

function simfphys.weapon:UpdateSuspension( vehicle )
	if not vehicle.filterEntities then
		vehicle.filterEntities = player.GetAll()
		table.insert(vehicle.filterEntities, vehicle)

		for i, wheel in pairs( ents.FindByClass( "gmod_sent_vehicle_fphysics_wheel" ) ) do
			table.insert(vehicle.filterEntities, wheel)
		end
	end

	vehicle.oldDist = istable( vehicle.oldDist ) and vehicle.oldDist or {}

	vehicle.susOnGround = false
	local Up = vehicle:GetUp()

	for i, v in pairs( apc_susdata ) do
		local pos = vehicle:GetAttachment( vehicle:LookupAttachment( apc_susdata[i].attachment ) ).Pos + Up * 20

		local trace = util.TraceHull( {
			start = pos,
			endpos = pos + Up * - 100,
			maxs = Vector(10,10,0),
			mins = -Vector(10,10,0),
			filter = vehicle.filterEntities,
		} )
		local Dist = (pos - trace.HitPos):Length() - 50

		if trace.Hit then
			vehicle.susOnGround = true
		end

		vehicle.oldDist[i] = vehicle.oldDist[i] and (vehicle.oldDist[i] + math.Clamp(Dist - vehicle.oldDist[i],-5,1)) or 0

		vehicle:SetPoseParameter(apc_susdata[i].poseparameter, vehicle.oldDist[i] )
	end
end

function simfphys.weapon:DoWheelSpin( vehicle )
	local spin_r = (vehicle.VehicleData[ "spin_4" ] + vehicle.VehicleData[ "spin_6" ]) * 0.9
	local spin_l = (vehicle.VehicleData[ "spin_3" ] + vehicle.VehicleData[ "spin_5" ]) * 0.9
	local turn = vehicle:GetVehicleSteer() * 2 -- -1 or 1

	net.Start( "simfphys_update_tracks", true )
		net.WriteEntity( vehicle )
		net.WriteFloat( spin_r )
		net.WriteFloat( spin_l )
	net.Broadcast()

	vehicle:SetPoseParameter("spin_wheels_right", -spin_r)
	vehicle:SetPoseParameter("spin_wheels_left", -spin_l )
	vehicle:SetPoseParameter("steer_wheels", -turn / 2)

end