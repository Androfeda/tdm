local function mg_fire(ply,vehicle,shootOrigin,shootDirection)

	vehicle:EmitSound("^simulated_vehicles/weapons/apc_fire.wav", 130, 105, 0.5)

	local projectile = ents.Create( "simfphys_tankprojectile" )
	projectile:SetPos( shootOrigin )
	projectile:SetAngles( shootDirection:Angle() )
	projectile:SetOwner( vehicle )
	projectile.Attacker = ply
	projectile.DeflectAng = 0
	projectile.AttackingEnt = vehicle
	projectile.Force = 50
	projectile.Damage = 90
	projectile.BlastRadius = 96
	projectile.BlastDamage = 50
	projectile:SetBlastEffect("simfphys_tankweapon_explosion_micro")
	projectile:SetSize( 2 )
	projectile.Filter = table.Copy( vehicle.VehicleData["filter"] )
	projectile.MuzzleVelocity = 400
	projectile:Spawn()
	projectile:Activate()

	--local projectile = {}
	--	projectile.filter = vehicle.VehicleData["filter"]
	--	projectile.shootOrigin = shootOrigin
	--	projectile.shootDirection = shootDirection
	--	projectile.attacker = ply
	--	projectile.attackingent = vehicle
	--	projectile.Damage = 100
	--	projectile.Force = 50
	--	projectile.Size = 3
	--	projectile.BlastRadius = 50
	--	projectile.BlastDamage = 50
	--	projectile.DeflectAng = 40
	--	projectile.BlastEffect = "simfphys_tankweapon_explosion_micro"

	--simfphys.FirePhysProjectile( projectile )
end

local function mg_fire2(ply,vehicle,shootOrigin,shootDirection)

	vehicle:EmitSound("^simulated_vehicles/weapons/apc_fire.wav", 130, 95, 0.5)

	local projectile = ents.Create( "simfphys_tankprojectile" )
	projectile:SetPos( shootOrigin )
	projectile:SetAngles( shootDirection:Angle() )
	projectile:SetOwner( vehicle )
	projectile.Attacker = ply
	projectile.DeflectAng = 0
	projectile.AttackingEnt = vehicle
	projectile.Force = 10
	projectile.Damage = 0
	projectile.BlastRadius = 300
	projectile.BlastDamage = 80
	projectile.MuzzleVelocity = 250
	projectile:SetBlastEffect("simfphys_tankweapon_explosion_small")
	projectile:SetSize( 5 )
	projectile.Filter = table.Copy( vehicle.VehicleData["filter"] )
	projectile:Spawn()
	projectile:Activate()
end

local function m240_fire(ply,vehicle,shootOrigin,shootDirection)

	vehicle:EmitSound("^weapons/ar1/ar1_dist2.wav", 115, 92)

	local projectile = {}
		projectile.filter = vehicle.VehicleData["filter"]
		projectile.shootOrigin = shootOrigin
		projectile.shootDirection = shootDirection
		projectile.attacker = ply
		projectile.Tracer	= 1
		projectile.Spread = Vector(0.015, 0.015, 0)
		projectile.HullSize = 1
		projectile.attackingent = vehicle
		projectile.Damage = 20
		projectile.Force = 12

	vehicle:GetPhysicsObject():ApplyForceOffset( -shootDirection * 1500, shootOrigin )

	simfphys.FireHitScan( projectile )
end

function simfphys.weapon:ValidClasses()

	local classes = {
		"avx_tdm_hecuapc"
	}

	return classes
end

function simfphys.weapon:Initialize( vehicle )
	local data = {}
	data.Attachment = "muzzle_left"
	data.Direction = Vector(1,0,0)
	data.Attach_Start_Left = "muzzle_right"
	data.Attach_Start_Right = "muzzle_left"
	data.Type = 3

	vehicle.MaxMag = 30
	vehicle.CurMag = vehicle.MaxMag
	vehicle:SetNWString( "WeaponMode", (vehicle.UsingHE and "HE" or "AP") .. " Cannon")
	vehicle:SetNWInt("MaxWPNAmmo", vehicle.MaxMag)
	vehicle:SetNWInt("CurWPNAmmo", vehicle.CurMag)
	vehicle:SetNWString("WPNType", "cannon")

	simfphys.RegisterCrosshair( vehicle:GetDriverSeat(), data )
	simfphys.RegisterCamera( vehicle:GetDriverSeat(), Vector(13,45,50), Vector(13,45,50), true )

	if not istable( vehicle.PassengerSeats ) or not istable( vehicle.pSeat ) then return end

	for i = 2, table.Count( vehicle.pSeat ) do
		simfphys.RegisterCamera( vehicle.pSeat[ i ], Vector(0,0,60), Vector(0,0,60) )
	end
end

function simfphys.weapon:AimWeapon( ply, vehicle, pod )
	local Aimang = pod:WorldToLocalAngles( ply:EyeAngles() )
	local AimRate = 50

	local Angles = vehicle:WorldToLocalAngles( Aimang ) - Angle(0,90,0)

	vehicle.sm_pp_yaw = vehicle.sm_pp_yaw and math.ApproachAngle( vehicle.sm_pp_yaw, Angles.y, AimRate * FrameTime() ) or 0
	vehicle.sm_pp_pitch = vehicle.sm_pp_pitch and math.ApproachAngle( vehicle.sm_pp_pitch, Angles.p, AimRate * FrameTime() ) or 0

	local TargetAng = Angle(vehicle.sm_pp_pitch,vehicle.sm_pp_yaw,0)
	TargetAng:Normalize()

	vehicle:SetPoseParameter("turret_yaw", TargetAng.y )
	vehicle:SetPoseParameter("turret_pitch", -TargetAng.p )
end

function simfphys.weapon:Think( vehicle )
	local pod = vehicle:GetDriverSeat()
	if not IsValid( pod ) then return end

	local ply = pod:GetDriver()

	local curtime = CurTime()

	vehicle.wOldPos = vehicle.wOldPos or Vector(0,0,0)
	local deltapos = vehicle:GetPos() - vehicle.wOldPos
	vehicle.wOldPos = vehicle:GetPos()
	local DeltaP = deltapos * engine.TickInterval()

	if not IsValid( ply ) then
		if vehicle.wpn then
			vehicle.wpn:Stop()
			vehicle.wpn = nil
		end

		return
	end

	self:AimWeapon( ply, vehicle, pod )

	local fire = ply:KeyDown( IN_ATTACK )
	local fire2 = ply:KeyDown( IN_ATTACK2 )
	local reload = ply:KeyDown( IN_RELOAD )

	if fire then
		self:PrimaryAttack( vehicle, ply, vehicle.UsingHE )
	elseif fire2 and (vehicle.NextShoot or 0) < CurTime() then
		vehicle.CurMag = vehicle.MaxMag
		vehicle:SetNWInt("CurWPNAmmo", vehicle.CurMag)
		vehicle:EmitSound("simulated_vehicles/weapons/apc_reload.wav")
		vehicle.UsingHE = not vehicle.UsingHE
		vehicle:EmitSound("buttons/lever6.wav", 75, vehicle.UsingHE and 100 or 90)

		self:SetNextPrimaryFire( vehicle, CurTime() + 2 )
		vehicle:SetNWString( "WeaponMode", (vehicle.UsingHE and "HE" or "AP") .. " Cannon")
	end
	--if fire2 then
	--	self:SecondaryAttack( vehicle, ply, DeltaP, shootOrigin )
	--end

	if reload then
		self:ReloadPrimary( vehicle )
	end
end

function simfphys.weapon:ReloadPrimary( vehicle )
	if not IsValid( vehicle ) then return end
	if vehicle.CurMag == vehicle.MaxMag then return end

	vehicle.CurMag = vehicle.MaxMag
	vehicle:SetNWInt("CurWPNAmmo", vehicle.CurMag)

	vehicle:EmitSound("simulated_vehicles/weapons/apc_reload.wav")

	self:SetNextPrimaryFire( vehicle, CurTime() + 2 )

	vehicle:SetIsCruiseModeOn( false )
end

function simfphys.weapon:TakePrimaryAmmo( vehicle )
	vehicle.CurMag = isnumber( vehicle.CurMag ) and vehicle.CurMag - 1 or vehicle.MaxMag
end

function simfphys.weapon:CanPrimaryAttack( vehicle )
	vehicle.CurMag = isnumber( vehicle.CurMag ) and vehicle.CurMag or vehicle.MaxMag

	if vehicle.CurMag <= 0 then
		self:ReloadPrimary( vehicle )
		return false
	end

	vehicle.NextShoot = vehicle.NextShoot or 0
	return vehicle.NextShoot < CurTime()
end

function simfphys.weapon:SetNextPrimaryFire( vehicle, time )
	vehicle.NextShoot = time
end

function simfphys.weapon:PrimaryAttack( vehicle, ply, he )
	if not self:CanPrimaryAttack( vehicle ) then return end

	vehicle.wOldPos = vehicle.wOldPos or vehicle:GetPos()
	local deltapos = vehicle:GetPos() - vehicle.wOldPos
	vehicle.wOldPos = vehicle:GetPos()

	if vehicle.swapMuzzle then
		vehicle.swapMuzzle = false
	else
		vehicle.swapMuzzle = true
	end

	local AttachmentID = vehicle.swapMuzzle and vehicle:LookupAttachment( "muzzle_right" ) or vehicle:LookupAttachment( "muzzle_left" )
	local Attachment = vehicle:GetAttachment( AttachmentID )

	local shootOrigin = Attachment.Pos + deltapos * engine.TickInterval()
	local shootDirection = (Attachment.Ang + (he and AngleRand(-0.5, 0.5) or AngleRand(-0.15, 0.15))):Forward()

	local effectdata = EffectData()
		effectdata:SetOrigin( shootOrigin )
		effectdata:SetAngles( Attachment.Ang )
		effectdata:SetEntity( vehicle )
		effectdata:SetAttachment( AttachmentID )
		effectdata:SetScale( 4 )
	util.Effect( "CS_MuzzleFlash", effectdata, true, true )

	if he then
		mg_fire2( ply, vehicle, shootOrigin, shootDirection )
	else
		mg_fire( ply, vehicle, shootOrigin, shootDirection )
	end

	self:TakePrimaryAmmo( vehicle )

	vehicle:SetNWInt("CurWPNAmmo", vehicle.CurMag)

	vehicle:GetPhysicsObject():ApplyForceOffset( -shootDirection * 40000, shootOrigin )

	self:SetNextPrimaryFire( vehicle, CurTime() + (he and 0.2 or 0.15) )
end



function simfphys.weapon:SecondaryAttack( vehicle, ply, deltapos, cPos, cAng )

	if not self:CanSecondaryAttack( vehicle ) then return end

	local ID = vehicle:LookupAttachment( "muzzle_right" )
	local Attachment = vehicle:GetAttachment( ID )

	cPos = cPos or Attachment.Pos
	cAng = cAng or Attachment.Ang

	local effectdata = EffectData()
		effectdata:SetOrigin( Attachment.Pos + deltapos )
		effectdata:SetAngles( Attachment.Ang + Angle(0,90,0) )
		effectdata:SetEntity( vehicle )
		effectdata:SetAttachment( ID )
		effectdata:SetScale( 2 )
	util.Effect( "CS_MuzzleFlash_X", effectdata, true, true )

	local trace = util.TraceLine( {
		start = cPos,
		endpos = cPos + cAng:Forward() * 50000,
		filter = vehicle.VehicleData["filter"]
	} )

	m240_fire( ply, vehicle, Attachment.Pos, (trace.HitPos - Attachment.Pos):GetNormalized() )

	self:SetNextSecondaryFire( vehicle, CurTime() + (60 / 850) )
end

function simfphys.weapon:CanSecondaryAttack( vehicle )
	vehicle.NextShoot2 = vehicle.NextShoot2 or 0
	return vehicle.NextShoot2 < CurTime()
end

function simfphys.weapon:SetNextSecondaryFire( vehicle, time )
	vehicle.NextShoot2 = time
end