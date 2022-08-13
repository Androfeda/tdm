local function cAPCFire(ply, vehicle, shootOrigin, Attachment, damage, ID)
	local effectdata = EffectData()
	effectdata:SetOrigin(shootOrigin)
	effectdata:SetAngles(Attachment.Ang)
	effectdata:SetEntity(vehicle)
	effectdata:SetAttachment(ID)
	effectdata:SetScale(1)
	util.Effect("AirboatMuzzleFlash", effectdata, true, true)
	local bullet = {}
	bullet.Num = 1
	bullet.Src = shootOrigin
	bullet.Dir = Attachment.Ang:Forward()
	local c = (1 - vehicle.charge / 100) ^ 0.5 * 0.03 + 0.01
	bullet.Spread = Vector(c, c, 0)
	bullet.Tracer = 0
	bullet.TracerName = "none"
	bullet.Force = damage
	bullet.Damage = damage
	bullet.HullSize = 2
	bullet.DisableOverride = true

	bullet.Callback = function(att, tr, dmginfo)
		dmginfo:SetDamageType(DMG_AIRBOAT)
		local effectdata = EffectData()
		effectdata:SetEntity(vehicle)
		effectdata:SetAttachment(ID)
		effectdata:SetStart(shootOrigin)
		effectdata:SetOrigin(tr.HitPos)
		effectdata:SetScale(10000)
		util.Effect("AirboatGunHeavyTracer", effectdata)
		local effectdata = EffectData()
		effectdata:SetOrigin(tr.HitPos + tr.HitNormal)
		effectdata:SetNormal(tr.HitNormal)
		util.Effect("AR2Impact", effectdata, true, true)

		if IsValid(tr.Entity) and tr.Entity:IsVehicle() then
			dmginfo:ScaleDamage(1.5)
			effectdata:SetOrigin(tr.HitPos + tr.HitNormal)
			effectdata:SetNormal(-tr.Normal)
			util.Effect("ManhackSparks", effectdata)
		elseif IsValid(tr.Entity) and tr.Entity:GetClass() == "npc_helicopter" then
			dmginfo:ScaleDamage(0.5)
		end
	end

	bullet.Attacker = ply
	vehicle:FireBullets(bullet)
	vehicle:GetPhysicsObject():ApplyForceOffset(-Attachment.Ang:Forward() * 10000, shootOrigin)
end

local function atgm_fire(ply, vehicle, shootOrigin, shootDirection)
	vehicle:EmitSound("PropAPC.FireCannon", 125)
	vehicle:GetPhysicsObject():ApplyForceOffset(-shootDirection * 100000, shootOrigin)
	vehicle.missile = ents.Create("avx_tdm_atgm")
	vehicle.missile:SetPos(shootOrigin)
	vehicle.missile:SetAngles(shootDirection:Angle())
	vehicle.missile:SetOwner(ply)
	vehicle.missile:Spawn()
	vehicle.missile:Activate()
	vehicle.missile.DirVector = shootDirection
	vehicle.missile:SetVelocity(shootDirection * 3500 + vehicle:GetVelocity())
	vehicle.missile.TurnRate = 0.1
	vehicle.MissileTracking = vehicle.MissileTracking or {}
	vehicle.missile.Vehicle = vehicle
	table.insert(vehicle.MissileTracking, vehicle.missile)
end

function simfphys.weapon:ValidClasses()
	local classes = {"avx_tdm_combineapc"}

	return classes
end

function simfphys.weapon:Initialize(vehicle)
	local pod = vehicle:GetDriverSeat()
	simfphys.RegisterCrosshair(pod)
	if not istable(vehicle.PassengerSeats) or not istable(vehicle.pSeat) then return end

	for i = 1, table.Count(vehicle.pSeat) do
		simfphys.RegisterCamera(vehicle.pSeat[i], Vector(0, 30, 60), Vector(0, -20, 60))
	end

	vehicle:SetNWInt("MaxWPNAmmo", 100 / 5)
	vehicle:SetNWInt("CurWPNAmmo", 100 / 5)
	vehicle:SetNWInt("MaxWPNAmmo2", 1)
	vehicle:SetNWInt("CurWPNAmmo2", 1)
	vehicle:SetNWString("WPNType", "frag")
	vehicle:SetNWString("WPNType2", "missile")
	vehicle:SetNWString("WeaponMode", "Pulse Gun | ATGM")
	--vehicle:SetNWString("WeaponMode", tostring(math.Round(100)) .. "%")
end

function simfphys.weapon:AimWeapon(ply, vehicle, pod)
	local Aimang = ply:EyeAngles()
	local AimRate = 150
	local Angles = vehicle:WorldToLocalAngles(Aimang) - Angle(0, 90, 0)
	vehicle.sm_pp_yaw = vehicle.sm_pp_yaw and math.ApproachAngle(vehicle.sm_pp_yaw, Angles.y, AimRate * FrameTime()) or 0
	vehicle.sm_pp_pitch = vehicle.sm_pp_pitch and math.ApproachAngle(vehicle.sm_pp_pitch, Angles.p, AimRate * FrameTime()) or 0
	local RecoilRate = 25
	vehicle.sm_recoil_yaw = vehicle.sm_recoil_yaw and math.ApproachAngle(vehicle.sm_recoil_yaw, 0, RecoilRate * FrameTime()) or 0
	vehicle.sm_recoil_pitch = vehicle.sm_recoil_pitch and math.ApproachAngle(vehicle.sm_recoil_pitch, 0, RecoilRate * FrameTime()) or 0
	local TargetAng = Angle(vehicle.sm_pp_pitch + vehicle.sm_recoil_pitch, vehicle.sm_pp_yaw + vehicle.sm_recoil_yaw, 0)
	TargetAng:Normalize()
	vehicle:SetPoseParameter("vehicle_weapon_yaw", TargetAng.y)
	vehicle:SetPoseParameter("vehicle_weapon_pitch", TargetAng.p)

	return Aimang
end

function simfphys.weapon:Think(vehicle)
	local pod = vehicle:GetDriverSeat()
	if not IsValid(pod) then return end
	local ply = pod:GetDriver()
	local curtime = CurTime()

	if not IsValid(ply) then
		if vehicle.wpn then
			vehicle.wpn:Stop()
			vehicle.wpn = nil
		end

		return
	end

	local ID = vehicle:LookupAttachment("muzzle")
	local Attachment = vehicle:GetAttachment(ID)

	vehicle.NextShoot = vehicle.NextShoot or 0

	local Aimang = self:AimWeapon(ply, vehicle, pod)
	local filter = table.Copy(vehicle.MissileTracking or {})

	table.Add(filter, {vehicle})

	local tr = util.TraceLine({
		start = Attachment.Pos,
		endpos = Attachment.Pos + Aimang:Forward() * 10000,
		filter = filter
	})

	local Aimpos = tr.HitPos
	vehicle.wOldPos = vehicle.wOldPos or Vector(0, 0, 0)
	local deltapos = vehicle:GetPos() - vehicle.wOldPos
	vehicle.wOldPos = vehicle:GetPos()
	local shootOrigin = Attachment.Pos + deltapos * engine.TickInterval()
	vehicle.charge = vehicle.charge or 100
	local fire = ply:KeyDown(IN_ATTACK) and vehicle.charge > 0
	local alt_fire = ply:KeyDown(IN_ATTACK2)

	if not fire then
		vehicle.charge = math.min(vehicle.charge + 0.3, 100)
		vehicle:SetNWInt("CurWPNAmmo", math.ceil(vehicle.charge / 5))
		--vehicle:SetNWString("WeaponMode", tostring(math.Round(vehicle.charge)) .. "%")
	end

	if vehicle.NextShoot < curtime and fire then
		cAPCFire(ply, vehicle, shootOrigin, Attachment, 50, ID)
		vehicle:EmitSound("^npc/strider/strider_minigun.wav", 120, 100 - (1 - vehicle.charge / 100) * 20)
		vehicle.charge = vehicle.charge - 1
		if vehicle.charge <= 0 then
			if vehicle.charge >= -6 then
				vehicle:EmitSound("weapons/airboat/airboat_gun_energy" .. math.Round(math.random(1, 2), 0) .. ".wav")
			end

			vehicle.charge = -25
		end

		vehicle:SetNWInt("CurWPNAmmo", math.ceil(vehicle.charge / 5))
		--vehicle:SetNWString("WeaponMode", tostring(math.Round(vehicle.charge)) .. "%")
		vehicle.NextShoot = curtime + 0.08 -- + (1 - vehicle.charge / 100) * 0.1
	end

	ID = vehicle:LookupAttachment("cannon_muzzle")
	Attachment = vehicle:GetAttachment(ID)
	vehicle.NextSecondaryShoot = vehicle.NextSecondaryShoot or 0

	vehicle:SetNWInt("CurWPNAmmo2", (vehicle.NextSecondaryShoot < curtime) and 1 or 0)

	if alt_fire ~= vehicle.afire_pressed then
		vehicle.afire_pressed = alt_fire
		if vehicle.NextSecondaryShoot < curtime and alt_fire then
			vehicle:EmitSound("PropAPC.FireCannon")
			shootOrigin = Attachment.Pos
			local shootDirection = Attachment.Ang:Forward()
			atgm_fire(ply, vehicle, shootOrigin + shootDirection * 96, shootDirection)
			vehicle.NextSecondaryShoot = curtime + 2
			vehicle.UnlockMissle = curtime + 0.5
		end
	end

	local remove = {}

	for i, missile in pairs(vehicle.MissileTracking or {}) do
		if IsValid(missile) then
			local targetdir = Aimpos - missile:GetPos()
			targetdir:Normalize()
			missile.DirVector = missile.DirVector + (targetdir - missile.DirVector) * missile.TurnRate
			local vel = -missile:GetVelocity() + missile.DirVector * 4000
			local phys = missile:GetPhysicsObject()
			phys:SetVelocity(vel)
			missile:SetAngles(missile.DirVector:Angle())
		else
			table.insert(remove, i)
		end
	end

	for k, i in pairs(remove) do
		table.remove(vehicle.MissileTracking, i)
	end
end