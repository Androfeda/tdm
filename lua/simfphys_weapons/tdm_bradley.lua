local m1a1_susdata = {}

for i = 1, 6 do
	m1a1_susdata[i] = {
		attachment = "sus_left_attach_" .. i,
		poseparameter = "suspension_left_" .. i,
	}

	local ir = i + 6

	m1a1_susdata[ir] = {
		attachment = "sus_right_attach_" .. i,
		poseparameter = "suspension_right_" .. i,
	}
end

simfphys.weapon.M2Clipsize = 15
simfphys.weapon.ATGMClipsize = 2

local function cannon_fire(ply, vehicle, shootOrigin, shootDirection)
	vehicle:EmitSound("tdm/bradley_fire.wav", 130, 100, 1)
	vehicle:GetPhysicsObject():ApplyForceOffset(-shootDirection * 40000, shootOrigin)
	local projectile = ents.Create("simfphys_tankprojectile")
	projectile:SetPos(shootOrigin)
	projectile:SetAngles(shootDirection:Angle())
	projectile:SetOwner(vehicle)
	projectile.Attacker = ply
	projectile.DeflectAng = 0
	projectile.AttackingEnt = vehicle
	projectile.Force = 30
	projectile.Damage = 80
	projectile.BlastRadius = 96
	projectile.BlastDamage = 75
	projectile:SetBlastEffect("simfphys_tankweapon_explosion_micro")
	projectile:SetSize(4)
	projectile.Filter = table.Copy(vehicle.VehicleData["filter"])
	projectile.MuzzleVelocity = 450
	projectile:Spawn()
	projectile:Activate()
end

local function atgm_fire(ply, vehicle, shootOrigin, shootDirection)
	vehicle:EmitSound("weapons/stinger_fire1.wav", 125)
	vehicle:GetPhysicsObject():ApplyForceOffset(-shootDirection * 100000, shootOrigin)
	vehicle.missile = ents.Create("tdm_atgm")
	vehicle.missile:SetPos(shootOrigin)
	vehicle.missile:SetAngles(shootDirection:Angle())
	vehicle.missile:SetOwner(ply)
	vehicle.missile:Spawn()
	vehicle.missile:Activate()
	vehicle.missile.DirVector = shootDirection
	vehicle.missile:SetVelocity(shootDirection * 4000)
	vehicle.MissileTracking = vehicle.MissileTracking or {}
	table.insert(vehicle.MissileTracking, vehicle.missile)
end

local function mg_fire(ply, vehicle, shootOrigin, shootDirection)
	vehicle:EmitSound("tdm/browning.wav")
	vehicle:GetPhysicsObject():ApplyForceOffset(-shootDirection * 12300, shootOrigin)
	local bullet = {}
	bullet.Num = 1
	bullet.Src = shootOrigin
	bullet.Dir = shootDirection
	local s = 0.005 + (vehicle.weaponheat or 0) * 0.025 * 0.01
	bullet.Spread = Vector(s, s, 0)
	bullet.Tracer = 1
	bullet.TracerName = "Tracer"
	bullet.Force = 8
	bullet.Damage = 65
	bullet.HullSize = 2
	bullet.Attacker = ply
	vehicle:FireBullets(bullet)
end

function simfphys.weapon:ValidClasses()
	return {"tdm_bradley"}
end

function simfphys.weapon:Initialize(vehicle)
	if GetConVar("tdm_simfphys_arcade"):GetBool() then
		vehicle.gunnerseat = vehicle:GetDriverSeat()
		simfphys.RegisterCamera( vehicle.pSeat[1], Vector(-4,26,24), Vector(0,45,100), true, "muzzle_up" )
	else
		vehicle.gunnerseat = vehicle.pSeat[1]
	end

	simfphys.RegisterCrosshair(vehicle.gunnerseat, {
		Attachment = "muzzle_cannon",
		Direction = Vector(1, 0, 0),
		Type = 3
	})

	simfphys.RegisterCamera(vehicle.gunnerseat, Vector(-60, -10, 5), Vector(0, 0, 110), true, "muzzle_cannon")

	self.M2Clip = self.M2Clipsize
	self.ATGMClip = self.ATGMClipsize
	vehicle.weaponheat = 0
	vehicle:SetNWString("WeaponMode", "Cannon | ATGM")
	vehicle:SetNWInt("MaxWPNAmmo", self.M2Clipsize)
	vehicle:SetNWInt("CurWPNAmmo", self.M2Clipsize)
	vehicle:SetNWInt("MaxWPNAmmo2", self.ATGMClipsize)
	vehicle:SetNWInt("CurWPNAmmo2", self.ATGMClipsize)
	vehicle:SetNWString("WPNType", "cannon")
	vehicle:SetNWString("WPNType2", "missile")
	vehicle:SetPoseParameter("cannon_aim_pitch", 75)
	vehicle:SetPoseParameter("cannon_aim_yaw", 0)
	---звук поворота башни
	vehicle.TurretHorizontal = CreateSound(vehicle, "tdm/bradley_cannon_turn.wav")
	vehicle.TurretHorizontal:SetSoundLevel(70)
	vehicle.TurretHorizontal:Play()

	vehicle:CallOnRemove("stopmgsounds", function(v)
		v.TurretHorizontal:Stop()
	end)

	---
	timer.Simple(1, function()
		if not IsValid(vehicle) then return end

		if not vehicle.VehicleData["filter"] then
			print("[simfphys Armed Vehicle Pack] ERROR:TRACE FILTER IS INVALID. PLEASE UPDATE SIMFPHYS BASE")

			return
		end

		vehicle.WheelOnGround = function(ent)
			ent.FrontWheelPowered = ent:GetPowerDistribution() ~= 1
			ent.RearWheelPowered = ent:GetPowerDistribution() ~= -1

			for i = 1, table.Count(ent.Wheels) do
				local Wheel = ent.Wheels[i]

				if IsValid(Wheel) then
					local dmgMul = Wheel:GetDamaged() and 0.5 or 1
					local surfacemul = simfphys.TractionData[Wheel:GetSurfaceMaterial():lower()]
					ent.VehicleData["SurfaceMul_" .. i] = (surfacemul and math.max(surfacemul, 0.001) or 1) * dmgMul
					local WheelPos = ent:LogicWheelPos(i)
					local WheelRadius = WheelPos.IsFrontWheel and ent.FrontWheelRadius or ent.RearWheelRadius
					local startpos = Wheel:GetPos()
					local dir = -ent.Up
					local len = WheelRadius + math.Clamp(-ent.Vel.z / 50, 2.5, 6)
					local HullSize = Vector(WheelRadius, WheelRadius, 0)

					local tr = util.TraceHull({
						start = startpos,
						endpos = startpos + dir * len,
						maxs = HullSize,
						mins = -HullSize,
						filter = ent.VehicleData["filter"]
					})

					local onground = self:IsOnGround(vehicle) and 1 or 0
					Wheel:SetOnGround(onground)
					ent.VehicleData["onGround_" .. i] = onground

					if tr.Hit then
						Wheel:SetSpeed(Wheel.FX)
						Wheel:SetSkidSound(Wheel.skid)
						Wheel:SetSurfaceMaterial(util.GetSurfacePropName(tr.SurfaceProps))
					end
				end
			end

			local FrontOnGround = math.max(ent.VehicleData["onGround_1"], ent.VehicleData["onGround_2"])
			local RearOnGround = math.max(ent.VehicleData["onGround_3"], ent.VehicleData["onGround_4"])
			ent.DriveWheelsOnGround = math.max(ent.FrontWheelPowered and FrontOnGround or 0, ent.RearWheelPowered and RearOnGround or 0)
		end
	end)
end

function simfphys.weapon:GetForwardSpeed(vehicle)
	return vehicle.ForwardSpeed
end

function simfphys.weapon:IsOnGround(vehicle)
	return vehicle.susOnGround == true
end

function simfphys.weapon:AimCannon(ply, vehicle, pod, Attachment)
	if not IsValid(pod) then return end
	local Aimang = pod:WorldToLocalAngles(ply:EyeAngles())
	Aimang:Normalize()
	local AimRate = 75
	local Angles = vehicle:WorldToLocalAngles(Aimang)
	---звуки
	local v = math.abs(math.Round(Angles.y, 1) - (vehicle.sm_pp_yaw and math.Round(vehicle.sm_pp_yaw, 1) or 0))
	vehicle.VAL_TurretHorizontal = (v <= 0.5 or (v >= 359.7 and v <= 360)) and 0 or 1
	local ft = FrameTime()
	vehicle.sm_pp_yaw = vehicle.sm_pp_yaw and math.ApproachAngle(vehicle.sm_pp_yaw, Angles.y, AimRate * ft) or 180
	vehicle.sm_pp_pitch = vehicle.sm_pp_pitch and math.ApproachAngle(vehicle.sm_pp_pitch, -Angles.p, AimRate * ft) or 0
	local TargetAng = Angle(vehicle.sm_pp_pitch, vehicle.sm_pp_yaw, 0)
	TargetAng:Normalize()
	vehicle:SetPoseParameter("turret_yaw", TargetAng.y)
	vehicle:SetPoseParameter("cannon_aim_yaw", TargetAng.y)
	vehicle:SetPoseParameter("cannon_aim_pitch", -TargetAng.p + 70)
end

function simfphys.weapon:ControlTurret(vehicle, deltapos)
	if not istable(vehicle.PassengerSeats) or not istable(vehicle.pSeat) then return end
	---звуки башни
	vehicle.VAL_TurretHorizontal = vehicle.VAL_TurretHorizontal or 0
	vehicle.TurretHorizontal:ChangePitch(vehicle.VAL_TurretHorizontal * 100, 0.5)
	vehicle.TurretHorizontal:ChangeVolume(vehicle.VAL_TurretHorizontal, 0.5)
	vehicle.VAL_TurretHorizontal = 0
	---
	local pod = vehicle.gunnerseat --vehicle:GetDriverSeat()
	if not IsValid(pod) then return end
	local ply = pod:GetDriver()
	if not IsValid(ply) then return end
	local ID = vehicle:LookupAttachment("muzzle_cannon")
	local Attachment = vehicle:GetAttachment(ID)
	self:AimCannon(ply, vehicle, pod, Attachment)
	local DeltaP = deltapos * engine.TickInterval()
	local fire = ply:KeyDown(IN_ATTACK)
	local fire2 = ply:KeyDown(IN_WALK)
	local fire3 = ply:KeyDown(IN_ATTACK2)

	if fire then
		self:PrimaryAttack(vehicle, ply, Attachment.Pos + DeltaP, Attachment)
	end

	local ID2 = vehicle:LookupAttachment("muzzle_missile")
	local Attachment2 = vehicle:GetAttachment(ID2)
	local ID3 = vehicle:LookupAttachment("muzzle_mg")
	local Attachment3 = vehicle:GetAttachment(ID3)

	if fire2 then
		self:SecondaryAttack(vehicle, ply, Attachment2.Pos + DeltaP, Attachment2)
	end

	if fire3 then
		self:MachineGunAttack(vehicle, ply, Attachment3.Pos + DeltaP, Attachment3)
	else
		vehicle.weaponheat = math.max(0, (vehicle.weaponheat or 0) - 0.4)
	end
end

function simfphys.weapon:CanAttack(vehicle)
	vehicle.NextShoot3 = vehicle.NextShoot3 or 0

	return vehicle.NextShoot3 < CurTime()
end

function simfphys.weapon:SetNextFire(vehicle, time)
	vehicle.NextShoot3 = time
end

function simfphys.weapon:CanAttackMG(vehicle)
	vehicle.NextShoot4 = vehicle.NextShoot4 or 0

	return vehicle.NextShoot4 < CurTime()
end

function simfphys.weapon:SetNextMGFire(vehicle, time)
	vehicle.NextShoot4 = time
end

function simfphys.weapon:PrimaryAttack(vehicle, ply, shootOrigin, Attachment)
	if not self:CanPrimaryAttack(vehicle) then return end
	if not self:CanAttack(vehicle) then return end

	if self.M2Clip <= 0 then
		self.M2Clip = self.M2Clipsize
		vehicle:SetNWInt("CurWPNAmmo", self.M2Clip)
		vehicle:EmitSound("tdm/bradley_reload.wav")
		self:SetNextFire(vehicle, CurTime() + 2)

		return
	end

	self.M2Clip = self.M2Clip - 1
	vehicle:SetNWInt("CurWPNAmmo", self.M2Clip)
	local shootDirection = Attachment.Ang:Forward()
	cannon_fire(ply, vehicle, shootOrigin + shootDirection * 80, shootDirection)
	local effectdata = EffectData()
	effectdata:SetEntity(vehicle)
	util.Effect("arctic_m2_muzzle", effectdata, true, true)
	self:SetNextPrimaryFire(vehicle, CurTime() + 0.35)
end

function simfphys.weapon:SecondaryAttack(vehicle, ply, shootOrigin, Attachment)
	if not self:CanSecondaryAttack(vehicle) then return end
	if self.ATGMClip <= 0 then return end
	local shootDirection = Attachment.Ang:Forward()
	self.ATGMClip = self.ATGMClip - 1
	vehicle:SetNWInt("CurWPNAmmo2", self.ATGMClip)
	atgm_fire(ply, vehicle, shootOrigin + shootDirection * 80, shootDirection)

	if (self.ATGMNext or 0) == 0 then
		self.ATGMNext = CurTime() + 7
	end

	self:SetNextSecondaryFire(vehicle, CurTime() + 1.5)
end

function simfphys.weapon:MachineGunAttack(vehicle, ply, shootOrigin, Attachment)
	if not self:CanAttackMG(vehicle) then return end
	local shootDirection = Attachment.Ang:Forward()
	local effectdata = EffectData()
	effectdata:SetOrigin(shootOrigin)
	effectdata:SetAngles(shootDirection:Angle())
	effectdata:SetEntity(vehicle)
	effectdata:SetAttachment(vehicle:LookupAttachment("muzzle_mg"))
	effectdata:SetScale(1)
	util.Effect("AirboatMuzzleFlash", effectdata, true, true)
	mg_fire(ply, vehicle, shootOrigin, shootDirection)
	self:SetNextMGFire(vehicle, CurTime() + (60 / 600))
	vehicle.weaponheat = math.min(100, vehicle.weaponheat + 1)
end

function simfphys.weapon:CanPrimaryAttack(vehicle)
	vehicle.NextShoot = vehicle.NextShoot or 0

	return vehicle.NextShoot < CurTime()
end

function simfphys.weapon:SetNextPrimaryFire(vehicle, time)
	vehicle.NextShoot = time
end

function simfphys.weapon:CanSecondaryAttack(vehicle)
	vehicle.NextShoot2 = vehicle.NextShoot2 or 0

	return vehicle.NextShoot2 < CurTime()
end

function simfphys.weapon:SetNextSecondaryFire(vehicle, time)
	vehicle.NextShoot2 = time
end

function simfphys.weapon:ModPhysics(vehicle, wheelslocked)
	if wheelslocked and self:IsOnGround(vehicle) then
		local phys = vehicle:GetPhysicsObject()
		phys:ApplyForceCenter(-vehicle:GetVelocity() * phys:GetMass() * 0.04)
	end
end

function simfphys.weapon:ControlTrackSounds(vehicle, wheelslocked)
	local speed = math.abs(self:GetForwardSpeed(vehicle))
	local fastenuf = speed > 20 and not wheelslocked and self:IsOnGround(vehicle)

	if fastenuf ~= vehicle.fastenuf then
		vehicle.fastenuf = fastenuf

		if fastenuf then
			vehicle.track_snd = CreateSound(vehicle, "simulated_vehicles/sherman/sherman_tracks.wav")
			vehicle.track_snd:PlayEx(0, 0)

			vehicle:CallOnRemove("stopmesounds", function(veh)
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
		vehicle.track_snd:ChangePitch(math.Clamp(60 + speed / 40, 0, 150))
		vehicle.track_snd:ChangeVolume(math.min(math.max(speed - 20, 0) / 200, 1))
	end
end

function simfphys.weapon:Think(vehicle)
	if not IsValid(vehicle) or not vehicle:IsInitialized() then return end

	vehicle.wOldPos = vehicle.wOldPos or Vector(0, 0, 0)
	local deltapos = vehicle:GetPos() - vehicle.wOldPos
	vehicle.wOldPos = vehicle:GetPos()
	local handbrake = vehicle:GetHandBrakeEnabled()
	self:UpdateSuspension(vehicle)
	self:DoWheelSpin(vehicle)
	self:ControlTurret(vehicle, deltapos)
	self:ControlTrackSounds(vehicle, handbrake)
	self:ModPhysics(vehicle, handbrake)
	local ID = vehicle:LookupAttachment("muzzle_cannon")
	local Attachment = vehicle:GetAttachment(ID)

	local filter = table.Copy(vehicle.MissileTracking or {})
	table.Add(filter, {vehicle})

	local tr = util.TraceLine({
		start = Attachment.Pos,
		endpos = Attachment.Pos + Attachment.Ang:Forward() * 32768,
		filter = filter
	})

	local Aimpos = tr.HitPos
	local remove = {}

	for i, missile in pairs(vehicle.MissileTracking or {}) do
		if IsValid(missile) then
			local targetdir = Aimpos - missile:GetPos()
			targetdir:Normalize()
			missile.DirVector = missile.DirVector + (targetdir - missile.DirVector) * 0.1
			local vel = -missile:GetVelocity() + missile.DirVector * 4500
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

	local trackss
	local gear = vehicle:GetGear()
	local mass = vehicle:GetPhysicsObject():GetMass()
	local TrackTurnRate = 40
	local TrackMultRate = 250
	local AntiFrictionRate = 0.1
	trackss = CreateSound(vehicle, "simulated_vehicles/sherman/tracks.wav")

	if vehicle:EngineActive() and gear == 2 and vehicle.PressedKeys["A"] == true and vehicle.susOnGround == true then
		if vehicle:GetPhysicsObject():GetAngleVelocity().z <= TrackTurnRate then
			vehicle:GetPhysicsObject():ApplyTorqueCenter(Vector(0, 0, mass * TrackMultRate))
			vehicle:GetPhysicsObject():ApplyForceCenter(Vector(0, 0, mass * AntiFrictionRate))
			trackss:Play()
			trackss:ChangePitch(math.Clamp(50 + TrackTurnRate / 80, 0, 150))
			trackss:ChangeVolume(math.min(math.max(222 - 20, 0) / 600, 1))

			vehicle:CallOnRemove("stopmesounds", function()
				if trackss then
					trackss:Stop()
				end
			end)
		end
	elseif vehicle:EngineActive() and gear == 2 and vehicle.PressedKeys["A"] == false and vehicle.susOnGround == false then
		trackss:Stop()
	end

	if vehicle:EngineActive() and gear == 2 and vehicle.PressedKeys["D"] == true and vehicle.susOnGround == true then
		if math.abs(vehicle:GetPhysicsObject():GetAngleVelocity().z) <= TrackTurnRate then
			vehicle:GetPhysicsObject():ApplyTorqueCenter(Vector(0, 0, -mass * TrackMultRate))
			vehicle:GetPhysicsObject():ApplyForceCenter(Vector(0, 0, mass * AntiFrictionRate))
			trackss:Play()
			trackss:ChangePitch(math.Clamp(50 + TrackTurnRate / 80, 0, 150))
			trackss:ChangeVolume(math.min(math.max(222 - 20, 0) / 600, 1))

			vehicle:CallOnRemove("stopmesounds", function()
				if trackss then
					trackss:Stop()
				end
			end)
		end
	elseif vehicle:EngineActive() and gear == 2 and vehicle.PressedKeys["D"] == false and vehicle.susOnGround == false then
		trackss:Stop()
	end

	if (self.ATGMNext or 0) > 0 and self.ATGMNext < CurTime() then
		self.ATGMClip = self.ATGMClip + 1
		vehicle:SetNWInt("CurWPNAmmo2", self.ATGMClip)
		--vehicle:SetNWString("WeaponMode", tostring(self.GunClip) .. " | " .. tostring(self.ATGMClip))
		vehicle:EmitSound("buttons/lever6.wav", 75, 105)

		if self.ATGMClip < self.ATGMClipsize then
			self.ATGMNext = CurTime() + 7
		else
			self.ATGMNext = 0
		end
	end
end

function simfphys.weapon:UpdateSuspension(vehicle)
	if not vehicle.filterEntities then
		vehicle.filterEntities = player.GetAll()
		table.insert(vehicle.filterEntities, vehicle)

		for i, wheel in pairs(ents.FindByClass("gmod_sent_vehicle_fphysics_wheel")) do
			table.insert(vehicle.filterEntities, wheel)
		end
	end

	vehicle.oldDist = istable(vehicle.oldDist) and vehicle.oldDist or {}
	vehicle.susOnGround = false
	local Up = vehicle:GetUp()

	for i, v in pairs(m1a1_susdata) do
		local pos = vehicle:GetAttachment(vehicle:LookupAttachment(m1a1_susdata[i].attachment)).Pos + Up * 10

		local trace = util.TraceHull({
			start = pos,
			endpos = pos + Up * -100,
			maxs = Vector(10, 10, 0),
			mins = -Vector(10, 10, 0),
			filter = vehicle.filterEntities,
		})

		local Dist = (pos - trace.HitPos):Length() - 50

		if trace.Hit then
			vehicle.susOnGround = true
		end

		vehicle.oldDist[i] = vehicle.oldDist[i] and (vehicle.oldDist[i] + math.Clamp(Dist - vehicle.oldDist[i], -5, 1)) or 0
		vehicle:SetPoseParameter(m1a1_susdata[i].poseparameter, vehicle.oldDist[i])
	end
end

function simfphys.weapon:DoWheelSpin(vehicle)
	local spin_r = (vehicle.VehicleData["spin_4"] + vehicle.VehicleData["spin_6"]) * -1.25
	local spin_l = (vehicle.VehicleData["spin_3"] + vehicle.VehicleData["spin_5"]) * -1.25
	net.Start("simfphys_update_tracks", true)
	net.WriteEntity(vehicle)
	net.WriteFloat(spin_r)
	net.WriteFloat(spin_l)
	net.Broadcast()
	vehicle:SetPoseParameter("spin_wheels_right", spin_r)
	vehicle:SetPoseParameter("spin_wheels_left", spin_l)
end