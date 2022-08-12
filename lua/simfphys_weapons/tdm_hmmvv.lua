local function mg_fire(ply, vehicle, shootOrigin, shootDirection)
	vehicle:EmitSound("tdm/browning.wav")
	vehicle:GetPhysicsObject():ApplyForceOffset(-shootDirection * 12300, shootOrigin)
	local bullet = {}
	bullet.Num = 1
	bullet.Src = shootOrigin
	bullet.Dir = shootDirection
	bullet.Spread = Vector(0.01, 0.01, 0)
	bullet.Tracer = 1
	bullet.TracerName = "simfphys_tracer"
	bullet.Force = 8
	bullet.Damage = 65
	bullet.HullSize = 2
	bullet.Attacker = ply

	vehicle:FireBullets(bullet)
end

function simfphys.weapon:ValidClasses()
	local classes = {"avx_tdm_hmmvv_mg"}

	return classes
end

function simfphys.weapon:Initialize(vehicle)
	vehicle:SetBodygroup(1, 1)
	-- vehicle:SetBodygroup(2, 1)
	-- vehicle:SetBodygroup(3, 1)
	local data = {}
	data.Attachment = "muzzle"
	data.Direction = Vector(1, 0, 0)
	data.Attach_Start_Left = "muzzle"
	data.Attach_Start_Right = "muzzle"
	data.Type = 3

	simfphys.RegisterCrosshair(vehicle.pSeat[1], {
		Attachment = "muzzle",
		Type = 5
	})

	simfphys.RegisterCamera(vehicle.pSeat[1], Vector(-85, 0, -20.5), Vector(0, 0, 30), true, "muzzle")
	if not istable(vehicle.PassengerSeats) or not istable(vehicle.pSeat) then return end
end

function simfphys.weapon:AimWeapon(ply, vehicle, pod)
	if not IsValid(pod) then return end
	local ID = vehicle:LookupAttachment("muzzle")
	local Attachment = vehicle:GetAttachment(ID)
	local Aimang = pod:WorldToLocalAngles(ply:EyeAngles())
	local Angles = vehicle:WorldToLocalAngles(Aimang)
	Angles:Normalize()
	vehicle.sm_dir = vehicle.sm_dir or Vector(0, 0, 0)
	local L_Right = Angle(0, Aimang.y, 0):Right()
	local La_Right = Angle(0, Attachment.Ang.y, 0):Forward()
	local AimRate = 40
	local Yaw_Diff = math.Clamp(math.acos(math.Clamp(L_Right:Dot(La_Right), -1, 1)) * (180 / math.pi) - 90, -AimRate, AimRate)
	local TargetPitch = Angles.p
	local TargetYaw = vehicle.sm_dir:Angle().y - Yaw_Diff
	vehicle.sm_dir = vehicle.sm_dir + (Angle(0, TargetYaw, 0):Forward() - vehicle.sm_dir) * 0.05
	vehicle.sm_pitch = vehicle.sm_pitch and (vehicle.sm_pitch + (TargetPitch - vehicle.sm_pitch) * 0.50) or 0
	vehicle:SetPoseParameter("mg_aim_yaw", vehicle.sm_dir:Angle().y)
	vehicle:SetPoseParameter("mg_aim_pitch", -vehicle.sm_pitch)
	local podangles = vehicle:GetAngles()
	podangles:RotateAroundAxis(vehicle:GetAngles():Up(), vehicle.sm_dir:Angle().y - 90)
	pod:SetAngles(podangles)
end

function simfphys.weapon:Think(vehicle)
	if not istable(vehicle.PassengerSeats) or not istable(vehicle.pSeat) then return end
	local pod = vehicle.pSeat[1]
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

	self:AimWeapon(ply, vehicle, pod)
	local fire = ply:KeyDown(IN_ATTACK)

	if fire then
		self:PrimaryAttack(vehicle, ply, shootOrigin)
	end
end

function simfphys.weapon:CanPrimaryAttack(vehicle)
	vehicle.NextShoot = vehicle.NextShoot or 0

	return vehicle.NextShoot < CurTime()
end

function simfphys.weapon:SetNextPrimaryFire(vehicle, time)
	vehicle.NextShoot = time
end

function simfphys.weapon:PrimaryAttack(vehicle, ply)
	if not self:CanPrimaryAttack(vehicle) then return end
	vehicle.wOldPos = vehicle.wOldPos or Vector(0, 0, 0)
	local deltapos = vehicle:GetPos() - vehicle.wOldPos
	vehicle.wOldPos = vehicle:GetPos()

	local AttachmentID = vehicle.swapMuzzle and vehicle:LookupAttachment("muzzle") or vehicle:LookupAttachment("muzzle")
	local Attachment = vehicle:GetAttachment(AttachmentID)
	local shootOrigin = Attachment.Pos + deltapos * engine.TickInterval()
	local shootDirection = Attachment.Ang:Forward()
	local effectdata = EffectData()
	effectdata:SetOrigin(shootOrigin)
	effectdata:SetAngles(Attachment.Ang)
	effectdata:SetEntity(vehicle)
	effectdata:SetAttachment(AttachmentID)
	effectdata:SetScale(1)
	util.Effect("AirboatMuzzleFlash", effectdata, true, true)
	mg_fire(ply, vehicle, shootOrigin, shootDirection)
	self:SetNextPrimaryFire(vehicle, CurTime() + (60 / 600))
end

function simfphys.weapon:Initialize( vehicle )
	local data = {}
	data.Attachment = "muzzle"
	data.Direction = Vector(1,0,0)
	data.Attach_Start_Left = "muzzle"
	data.Attach_Start_Right = "muzzle"
	data.Type = 3

	simfphys.RegisterCrosshair( vehicle.pSeat[1] , { Attachment = "muzzle", Type = 3 } )
	simfphys.RegisterCamera( vehicle.pSeat[1], Vector(-70,-5,0), Vector(0,0,30), true, "muzzle" )

	if not istable( vehicle.PassengerSeats ) or not istable( vehicle.pSeat ) then return end
end