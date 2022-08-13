if not simfphys then return end

local V = {
	Name = "Civil Patrol Vehicle",
	Model = "models/combine_apc.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "TDM Rebalance",

	Members = {
		Mass = 4000,
		MaxHealth = 7500,

		LightsTable = "capc_siren",

		IsArmored = true,

		OnSpawn =
			function(ent)
				ent:SetNWBool( "simfphys_NoRacingHud", true )
				ent.IsArmored = true
				ent.DamageThreshold = 80
				ent.DamageBlock = 100
				SIMF_TDM.OnSpawned(ent)
			end,

		GibModels = {
			"models/combine_apc_destroyed_gib01.mdl",
			"models/combine_apc_destroyed_gib02.mdl",
			"models/combine_apc_destroyed_gib03.mdl",
			"models/combine_apc_destroyed_gib04.mdl",
			"models/combine_apc_destroyed_gib05.mdl",
			"models/combine_apc_destroyed_gib06.mdl",
		},

		FrontWheelRadius = 28,
		RearWheelRadius = 28,

		SeatOffset = Vector(-25,0,104),
		SeatPitch = 0,

		PassengerSeats = {
			{
				pos = Vector(0,-30,50),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(0,-30,50),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(0,-30,50),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(0,-30,50),
				ang = Angle(0,0,0)
			},
		},

		FrontHeight = 10,
		FrontConstant = 50000,
		FrontDamping = 3000,
		FrontRelativeDamping = 3000,

		RearHeight = 10,
		RearConstant = 50000,
		RearDamping = 3000,
		RearRelativeDamping = 3000,

		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 535,

		TurnSpeed = 8,

		MaxGrip = 85,
		Efficiency = 2,
		GripOffset = 0,
		BrakePower = 85,
		BulletProofTires = true,


		IdleRPM = 300,
		LimitRPM = 3500,
		PeakTorque = 175,
		PowerbandStart = 1200,
		PowerbandEnd = 3200,
		Turbocharged = false,
		Supercharged = false,

		FuelFillPos = Vector(32.82,-78.31,81.89),

		PowerBias = 0,

		EngineSoundPreset = 0,

		Sound_Idle = "simulated_vehicles/c_apc/apc_idle.wav",
		Sound_IdlePitch = 1,

		Sound_Mid = "simulated_vehicles/c_apc/apc_mid.wav",
		Sound_MidPitch = 1,
		Sound_MidVolume = 1,
		Sound_MidFadeOutRPMpercent = 100,
		Sound_MidFadeOutRate = 1,

		Sound_High = "",

		Sound_Throttle = "",

		snd_horn = "ambient/alarms/apc_alarm_pass1.wav",

		ForceTransmission = 1,
		DifferentialGear = 0.3,
		Gears = {-0.1,0,0.1,0.2,0.3}
	}
}
list.Set( "simfphys_vehicles", "avx_tdm_combineapc", V )

local V = {
	Name = "V-100 APC",
	Model = "models/blu/conscript_apc.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "TDM Rebalance",
	SpawnOffset = Vector(0,0,50),

	Members = {
		Mass = 5500,
		MaxHealth = 9000,

		IsArmored = true,

		GibModels = {
			"models/blu/conscript_apc.mdl",
			"models/props_vehicles/apc_tire001.mdl",
			"models/props_vehicles/apc_tire001.mdl",
			"models/props_vehicles/apc_tire001.mdl",
			"models/props_vehicles/apc_tire001.mdl",
			"models/props_c17/TrapPropeller_Engine.mdl",
			"models/gibs/helicopter_brokenpiece_01.mdl",
			"models/gibs/manhack_gib01.mdl",
			"models/gibs/manhack_gib02.mdl",
			"models/gibs/manhack_gib03.mdl",
			"models/combine_apc_destroyed_gib02.mdl",
			"models/combine_apc_destroyed_gib03.mdl",
			"models/combine_apc_destroyed_gib04.mdl",
			"models/combine_apc_destroyed_gib05.mdl",
		},

		EnginePos = Vector(-16.1,-81.68,47.25),

		LightsTable = "conapc",

		OnSpawn =
			function(ent)
				ent:SetNWBool( "simfphys_NoRacingHud", true )
				ent.IsArmored = true
				ent.DamageThreshold = 100
				ent.DamageBlock = 120
				SIMF_TDM.OnSpawned(ent)
			end,

		CustomWheels = true,
		CustomSuspensionTravel = 10,

		CustomWheelModel = "models/props_vehicles/apc_tire001.mdl",
		CustomWheelPosFL = Vector(-45,77,-22),
		CustomWheelPosFR = Vector(45,77,-22),
		CustomWheelPosRL = Vector(-45,-74,-22),
		CustomWheelPosRR = Vector(45,-74,-22),
		CustomWheelAngleOffset = Angle(0,180,0),

		CustomMassCenter = Vector(0,0,0),

		CustomSteerAngle = 35,

		SeatOffset = Vector(65,-13,35),
		SeatPitch = 0,
		SeatYaw = 0,

		PassengerSeats = {
			{
				pos = Vector(13,75,-3.5),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(0,0,-3.5),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(0,0,-3.5),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(0,0,-3.5),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(0,0,-3.5),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(0,0,-3.5),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(0,0,-3.5),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(0,0,-3.5),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(0,0,-3.5),
				ang = Angle(0,0,0)
			},
		},

		Attachments = {
			{
				model = "models/hunter/plates/plate075x105.mdl",
				material = "lights/white",
				color = Color(0,0,0,255),
				pos = Vector(0.04,57.5,16.74),
				ang = Angle(90,-90,0)
			},
			{
				model = "models/hunter/plates/plate025x05.mdl",
				material = "lights/white",
				color = Color(0,0,0,255),
				pos = Vector(-25.08,91.34,29.46),
				ang = Angle(4.2,-109.19,68.43)
			},
			{
				pos = Vector(-24.63,77.76,8.65),
				ang = Angle(24.05,-12.81,-1.87),
				model = "models/hunter/plates/plate05x1.mdl",
				material = "lights/white",
				color = Color(0,0,0,255)
			},
			{
				pos = Vector(24.63,77.76,8.65),
				ang = Angle(24.05,-167.19,1.87),
				model = "models/hunter/plates/plate05x1.mdl",
				material = "lights/white",
				color = Color(0,0,0,255)
			},
			{
				pos = Vector(-30.17,61.36,32.79),
				ang = Angle(-1.21,-92.38,-130.2),
				model = "models/hunter/plates/plate025x05.mdl",
				material = "lights/white",
				color = Color(0,0,0,255)
			},
			{
				pos = Vector(30.17,61.36,32.79),
				ang = Angle(-1.21,-87.62,130.2),
				model = "models/hunter/plates/plate025x05.mdl",
				material = "lights/white",
				color = Color(0,0,0,255)
			},
			{
				pos = Vector(0,72.92,40.54),
				ang = Angle(0,-180,0.79),
				model = "models/hunter/plates/plate1x1.mdl",
				material = "lights/white",
				color = Color(0,0,0,255)
			},
			{
				pos = Vector(25.08,91.34,29.46),
				ang = Angle(4.2,-70.81,-68.43),
				model = "models/hunter/plates/plate025x05.mdl",
				material = "lights/white",
				color = Color(0,0,0,255)
			},
			{
				pos = Vector(-29.63,79.02,19.28),
				ang = Angle(90,-18,0),
				model = "models/hunter/plates/plate05x1.mdl",
				material = "lights/white",
				color = Color(0,0,0,255)
			},
			{
				pos = Vector(29.63,79.02,19.28),
				ang = Angle(90,-162,0),
				model = "models/hunter/plates/plate05x1.mdl",
				material = "lights/white",
				color = Color(0,0,0,255)
			},
			{
				pos = Vector(0,75.33,5.91),
				ang = Angle(0,0,0),
				model = "models/hunter/plates/plate1x1.mdl",
				material = "lights/white",
				color = Color(0,0,0,255)
			},
			{
				pos = Vector(0,98.02,35.74),
				ang = Angle(63,90,0),
				model = "models/hunter/plates/plate025x025.mdl",
				material = "lights/white",
				color = Color(0,0,0,255)
			},
			{
				pos = Vector(0,100.55,7.41),
				ang = Angle(90,-90,0),
				model = "models/hunter/plates/plate1x1.mdl",
				material = "lights/white",
				color = Color(0,0,0,255)
			}
		},

		FrontHeight = 20,
		FrontConstant = 70000,
		FrontDamping = 4000,
		FrontRelativeDamping = 3000,

		RearHeight = 20,
		RearConstant = 70000,
		RearDamping = 4000,
		RearRelativeDamping = 3000,

		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 535,

		TurnSpeed = 8,

		MaxGrip = 140,
		Efficiency = 1.5,
		GripOffset = -14,
		BrakePower = 120,
		BulletProofTires = true,


		IdleRPM = 500,
		LimitRPM = 3000,
		PeakTorque = 100,
		PowerbandStart = 1000,
		PowerbandEnd = 2900,

		Turbocharged = false,
		Supercharged = false,

		FuelFillPos = Vector(-61.34,49.71,15.98),
		FuelType = FUELTYPE_DIESEL,
		FuelTankSize = 120,

		PowerBias = 0,

		EngineSoundPreset = 0,

		Sound_Idle = "simulated_vehicles/misc/Nanjing_loop.wav",
		Sound_IdlePitch = 1,

		Sound_Mid = "simulated_vehicles/misc/m50.wav",
		Sound_MidPitch = 1,
		Sound_MidVolume = 1,
		Sound_MidFadeOutRPMpercent = 58,
		Sound_MidFadeOutRate = 0.476,

		Sound_High = "simulated_vehicles/misc/v8high2.wav",
		Sound_HighPitch = 1,
		Sound_HighVolume = 0.75,
		Sound_HighFadeInRPMpercent = 58,
		Sound_HighFadeInRate = 0.19,

		Sound_Throttle = "",
		Sound_ThrottlePitch = 0,
		Sound_ThrottleVolume = 0,

		snd_horn = "simulated_vehicles/horn_2.wav",

		ForceTransmission = 1,

		DifferentialGear = 0.27,
		--Gears = {-0.09,0,0.09,0.18,0.28,0.35}
		Gears = {-0.09, 0, 0.09, 0.25, 0.4, 0.5},
	}
}
list.Set( "simfphys_vehicles", "avx_tdm_hecuapc", V )

local V = {
	Name = "Bulldog (Unarmed)",
	Model = "models/simfphys/tdm/bulldog.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "TDM Rebalance",
	SpawnOffset = Vector(0,0,0),
	SpawnAngleOffset = 90,

	Members = {
		Mass = 3500,
		EnginePos = Vector(90,0,48),
		BulletProofTires = false,

		LightsTable = "",

		MaxHealth = 4500,

		IsArmored = false,

		CustomWheels = true,       	 -- You have to set this to "true" in order to define custom wheels
		CustomSuspensionTravel = 10,	--suspension travel limiter length

		--FrontWheelRadius = 18,		-- if you set CustomWheels to true then the script will figure the radius out by itself using the CustomWheelModel
		--RearWheelRadius = 20,

		CustomWheelModel = "models/simfphys/tdm/bulldog_wheel.mdl",	-- since we create our own wheels we have to define a model. It has to have a collission model
		--CustomWheelModel_R = "",			-- different model for rear wheels?
		CustomWheelPosFL = Vector(78,40,16),		-- set the position of the front left wheel.
		CustomWheelPosFR = Vector(78,-45,16),	-- position front right wheel
		CustomWheelPosRL = Vector(-75,40,16),	-- rear left
		CustomWheelPosRR = Vector(-75,-45,16),	-- rear right		NOTE: make sure the position actually matches the name. So FL is actually at the Front Left ,  FR Front Right, ...   if you do this wrong the wheels will spin in the wrong direction or the car will drive sideways/reverse
		CustomWheelAngleOffset = Angle(0,90,0),

		CustomMassCenter = Vector(0,0,10),		-- custom masscenter offset. The script creates a counter weight to make the masscenter exactly in the center of the wheels. However you can add an offset to this to create more body roll if you really have to...

		CustomSteerAngle = 15,				-- max clamped steering angle,

		SeatOffset = Vector(-1,-28,68),
		SeatPitch = 0,
		SeatYaw = 90,

		PassengerSeats = {
			{
				pos = Vector(4,-32,36),
				ang = Angle(0,-90,0)
			},
			{
				pos = Vector(-36,-32,36),
				ang = Angle(0,-90,0)
			},
			{
				pos = Vector(-36,28,36),
				ang = Angle(0,-90,0)
			},
		},

		FrontHeight = 1.5,
		FrontConstant = 90000.00,
		FrontDamping = 5000,
		FrontRelativeDamping = 1000,

		RearHeight = 1.5,
		RearConstant = 90000.00,
		RearDamping = 5000,
		RearRelativeDamping = 1000,

		FastSteeringAngle = 12,
		SteeringFadeFastSpeed = 535,

		TurnSpeed = 20,

		MaxGrip = 120,
		Efficiency = 0.75,
		GripOffset = -0,
		BrakePower = 65,

		IdleRPM = 750,
		LimitRPM = 4500,

		PeakTorque = 150,
		PowerbandStart = 2200,
		PowerbandEnd = 5300,
		Turbocharged = false,
		Supercharged = false,

		FuelFillPos = Vector(-40,48,48),
		FuelType = FUELTYPE_PETROL,
		FuelTankSize = 30,

		PowerBias = 0.8,

		EngineSoundPreset = -1,

		snd_pitch = 1,
		snd_idle = "simulated_vehicles/4banger/4banger_idle.wav",

		snd_low = "simulated_vehicles/4banger/4banger_low.wav",
		snd_low_pitch = 0.6,

		snd_mid = "simulated_vehicles/4banger/4banger_mid.wav",
		snd_mid_gearup = "simulated_vehicles/4banger/4banger_second.wav",
		snd_mid_pitch = 0.5,

		snd_horn = "simulated_vehicles/horn_2.wav",

		DifferentialGear = 0.30,
		Gears = {-0.09, 0, 0.09, 0.18, 0.28, 0.35},

		OnSpawn = function(ent)
			ent:SetNWBool( "simfphys_NoRacingHud", true )
			ent.DamageThreshold = nil
			ent.DamageBlock = 35
			ent.ArmorThreshold = 0.5
			ent:SetBodygroup(3, 1)
			ent:SetBodygroup(2, 1)
			SIMF_TDM.OnSpawned(ent)
		end,

		SetPassenger = function(vehicle, ply)
			SIMF_TDM.SetPassenger(vehicle, ply)
		end,

		PlayerBoneManipulation = {
			[1] = {
				["ValveBiped.Bip01_R_Calf"] = Angle(0,-90),
				["ValveBiped.Bip01_L_Calf"] = Angle(0,-90),

				["ValveBiped.Bip01_R_Thigh"] = Angle(5,100,0),
				["ValveBiped.Bip01_L_Thigh"] = Angle(-5,100,0),

				["ValveBiped.Bip01_L_Clavicle"] = Angle(10,0,-30),
				["ValveBiped.Bip01_R_Clavicle"] = Angle(10,0,30),

				["ValveBiped.Bip01_L_UpperArm"] = Angle(0,-35,30),
				["ValveBiped.Bip01_R_UpperArm"] = Angle(0,-25,-30),

				["ValveBiped.Bip01_L_Forearm"] = Angle(0,45,-30),
				["ValveBiped.Bip01_R_Forearm"] = Angle(0,45,30),

			}
		}
	}
}
list.Set( "simfphys_vehicles", "avx_tdm_bulldog", V )

local V = {
	Name = "Bulldog",
	Model = "models/simfphys/tdm/bulldog.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "TDM Rebalance",
	SpawnOffset = Vector(0,0,0),
	SpawnAngleOffset = 90,

	Members = {
		Mass = 3500,
		EnginePos = Vector(90,0,48),
		BulletProofTires = false,

		LightsTable = "",

		MaxHealth = 4500,

		IsArmored = false,

		CustomWheels = true,       	 -- You have to set this to "true" in order to define custom wheels
		CustomSuspensionTravel = 10,	--suspension travel limiter length

		--FrontWheelRadius = 18,		-- if you set CustomWheels to true then the script will figure the radius out by itself using the CustomWheelModel
		--RearWheelRadius = 20,

		CustomWheelModel = "models/simfphys/tdm/bulldog_wheel.mdl",	-- since we create our own wheels we have to define a model. It has to have a collission model
		--CustomWheelModel_R = "",			-- different model for rear wheels?
		CustomWheelPosFL = Vector(78,40,16),		-- set the position of the front left wheel.
		CustomWheelPosFR = Vector(78,-45,16),	-- position front right wheel
		CustomWheelPosRL = Vector(-75,40,16),	-- rear left
		CustomWheelPosRR = Vector(-75,-45,16),	-- rear right		NOTE: make sure the position actually matches the name. So FL is actually at the Front Left ,  FR Front Right, ...   if you do this wrong the wheels will spin in the wrong direction or the car will drive sideways/reverse
		CustomWheelAngleOffset = Angle(0,90,0),

		CustomMassCenter = Vector(0,0,10),		-- custom masscenter offset. The script creates a counter weight to make the masscenter exactly in the center of the wheels. However you can add an offset to this to create more body roll if you really have to...

		CustomSteerAngle = 15,				-- max clamped steering angle,

		SeatOffset = Vector(-1,-28,68),
		SeatPitch = 0,
		SeatYaw = 90,

		PassengerSeats = {
			{
				pos = Vector(-30,-3,68),
				ang = Angle(0,-90,0)
			},
			{
				pos = Vector(4,-32,36),
				ang = Angle(0,-90,0)
			},
			{
				pos = Vector(-36,-32,36),
				ang = Angle(0,-90,0)
			},
			{
				pos = Vector(-36,28,36),
				ang = Angle(0,-90,0)
			},
		},

		FrontHeight = 1.5,
		FrontConstant = 90000.00,
		FrontDamping = 5000,
		FrontRelativeDamping = 1000,

		RearHeight = 1.5,
		RearConstant = 90000.00,
		RearDamping = 5000,
		RearRelativeDamping = 1000,

		FastSteeringAngle = 12,
		SteeringFadeFastSpeed = 535,

		TurnSpeed = 20,

		MaxGrip = 120,
		Efficiency = 0.75,
		GripOffset = -0,
		BrakePower = 65,

		IdleRPM = 750,
		LimitRPM = 4500,

		PeakTorque = 150,
		PowerbandStart = 2200,
		PowerbandEnd = 5300,
		Turbocharged = false,
		Supercharged = false,

		FuelFillPos = Vector(-40,48,48),
		FuelType = FUELTYPE_PETROL,
		FuelTankSize = 30,

		PowerBias = 0.8,

		EngineSoundPreset = -1,

		snd_pitch = 1,
		snd_idle = "simulated_vehicles/4banger/4banger_idle.wav",

		snd_low = "simulated_vehicles/4banger/4banger_low.wav",
		snd_low_pitch = 0.6,

		snd_mid = "simulated_vehicles/4banger/4banger_mid.wav",
		snd_mid_gearup = "simulated_vehicles/4banger/4banger_second.wav",
		snd_mid_pitch = 0.5,

		snd_horn = "simulated_vehicles/horn_2.wav",

		DifferentialGear = 0.30,
		Gears = {-0.09, 0, 0.09, 0.18, 0.28, 0.35},

		OnSpawn = function(ent)
			ent:SetNWBool( "simfphys_NoRacingHud", true )
			ent.DamageThreshold = nil
			ent.DamageBlock = 35
			ent.ArmorThreshold = 0.5
			SIMF_TDM.OnSpawned(ent)
		end,

		SetPassenger = function(vehicle, ply)
			SIMF_TDM.SetPassenger(vehicle, ply)
		end,

		PlayerBoneManipulation = {
			[1] = {
				["ValveBiped.Bip01_R_Calf"] = Angle(0,-90),
				["ValveBiped.Bip01_L_Calf"] = Angle(0,-90),

				["ValveBiped.Bip01_R_Thigh"] = Angle(5,100,0),
				["ValveBiped.Bip01_L_Thigh"] = Angle(-5,100,0),

				["ValveBiped.Bip01_L_Clavicle"] = Angle(10,0,-30),
				["ValveBiped.Bip01_R_Clavicle"] = Angle(10,0,30),

				["ValveBiped.Bip01_L_UpperArm"] = Angle(0,-35,30),
				["ValveBiped.Bip01_R_UpperArm"] = Angle(0,-25,-30),

				["ValveBiped.Bip01_L_Forearm"] = Angle(0,45,-30),
				["ValveBiped.Bip01_R_Forearm"] = Angle(0,45,30),

			}
		}
	}
}
list.Set( "simfphys_vehicles", "avx_tdm_bulldog_mg", V )

local V = {
	Name = "Humvee (Unarmed)",
	Model = "models/simfphys/tdm/hmmwv.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "TDM Rebalance",
	SpawnOffset = Vector(0,0,0),
	SpawnAngleOffset = 90,

	Members = {
		Mass = 3500,
		EnginePos = Vector(90,0,48),
		BulletProofTires = false,

		LightsTable = "",

		MaxHealth = 4500,

		IsArmored = false,

		CustomWheels = true,       	 -- You have to set this to "true" in order to define custom wheels
		CustomSuspensionTravel = 10,	--suspension travel limiter length

		--FrontWheelRadius = 18,		-- if you set CustomWheels to true then the script will figure the radius out by itself using the CustomWheelModel
		--RearWheelRadius = 20,

		CustomWheelModel = "models/simfphys/tdm/hmmwv_wheel.mdl",	-- since we create our own wheels we have to define a model. It has to have a collission model
		--CustomWheelModel_R = "",			-- different model for rear wheels?
		CustomWheelPosFL = Vector(72,40,14),		-- set the position of the front left wheel.
		CustomWheelPosFR = Vector(72,-40,14),	-- position front right wheel
		CustomWheelPosRL = Vector(-72,40,14),	-- rear left
		CustomWheelPosRR = Vector(-72,-40,14),	-- rear right		NOTE: make sure the position actually matches the name. So FL is actually at the Front Left ,  FR Front Right, ...   if you do this wrong the wheels will spin in the wrong direction or the car will drive sideways/reverse
		CustomWheelAngleOffset = Angle(180,0,0),

		CustomMassCenter = Vector(0,0,10),		-- custom masscenter offset. The script creates a counter weight to make the masscenter exactly in the center of the wheels. However you can add an offset to this to create more body roll if you really have to...

		CustomSteerAngle = 15,				-- max clamped steering angle,

		SeatOffset = Vector(2,-30,58),
		SeatPitch = 0,
		SeatYaw = 90,

		PassengerSeats = {
			{
				pos = Vector(0,-30,24),
				ang = Angle(0,-90,0)
			},
			{
				pos = Vector(-30,-30,24),
				ang = Angle(0,-90,0)
			},
			{
				pos = Vector(-30,30,24),
				ang = Angle(0,-90,0)
			},
		},

		FrontHeight = 4,
		FrontConstant = 90000.00,
		FrontDamping = 5000,
		FrontRelativeDamping = 1000,

		RearHeight = 4,
		RearConstant = 90000.00,
		RearDamping = 5000,
		RearRelativeDamping = 1000,

		FastSteeringAngle = 12,
		SteeringFadeFastSpeed = 535,

		TurnSpeed = 20,

		MaxGrip = 120,
		Efficiency = 0.75,
		GripOffset = -0,
		BrakePower = 65,

		IdleRPM = 750,
		LimitRPM = 4500,

		PeakTorque = 150,
		PowerbandStart = 2200,
		PowerbandEnd = 5300,
		Turbocharged = false,
		Supercharged = false,

		FuelFillPos = Vector(-40,48,48),
		FuelType = FUELTYPE_PETROL,
		FuelTankSize = 30,

		PowerBias = 0.8,

		EngineSoundPreset = -1,

		snd_pitch = 1,
		snd_idle = "simulated_vehicles/4banger/4banger_idle.wav",

		snd_low = "simulated_vehicles/4banger/4banger_low.wav",
		snd_low_pitch = 0.6,

		snd_mid = "simulated_vehicles/4banger/4banger_mid.wav",
		snd_mid_gearup = "simulated_vehicles/4banger/4banger_second.wav",
		snd_mid_pitch = 0.5,

		snd_horn = "simulated_vehicles/horn_2.wav",

		DifferentialGear = 0.30,
		Gears = {-0.09, 0, 0.09, 0.18, 0.28, 0.35},

		OnSpawn = function(ent)
			ent:SetNWBool( "simfphys_NoRacingHud", true )
			ent.DamageThreshold = nil
			ent.DamageBlock = 35
			ent.ArmorThreshold = 0.5
			ent:SetBodygroup(1, 1)
			SIMF_TDM.OnSpawned(ent)
		end,

		SetPassenger = function(vehicle, ply)
			SIMF_TDM.SetPassenger(vehicle, ply)
		end,

		PlayerBoneManipulation = {
			[1] = {
				["ValveBiped.Bip01_R_Calf"] = Angle(0,-90),
				["ValveBiped.Bip01_L_Calf"] = Angle(0,-90),

				["ValveBiped.Bip01_R_Thigh"] = Angle(5,100,0),
				["ValveBiped.Bip01_L_Thigh"] = Angle(-5,100,0),

				["ValveBiped.Bip01_L_Clavicle"] = Angle(10,0,-30),
				["ValveBiped.Bip01_R_Clavicle"] = Angle(10,0,30),

				["ValveBiped.Bip01_L_UpperArm"] = Angle(0,-35,30),
				["ValveBiped.Bip01_R_UpperArm"] = Angle(0,-25,-30),

				["ValveBiped.Bip01_L_Forearm"] = Angle(0,45,-30),
				["ValveBiped.Bip01_R_Forearm"] = Angle(0,45,30),

			}
		}
	}
}
list.Set( "simfphys_vehicles", "avx_tdm_hmmvv", V )

local V = {
	Name = "Humvee",
	Model = "models/simfphys/tdm/hmmwv.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "TDM Rebalance",
	SpawnOffset = Vector(0,0,0),
	SpawnAngleOffset = 90,

	Members = {
		Mass = 3500,
		EnginePos = Vector(90,0,48),
		BulletProofTires = false,

		LightsTable = "",

		MaxHealth = 4500,

		IsArmored = false,

		CustomWheels = true,       	 -- You have to set this to "true" in order to define custom wheels
		CustomSuspensionTravel = 10,	--suspension travel limiter length

		--FrontWheelRadius = 18,		-- if you set CustomWheels to true then the script will figure the radius out by itself using the CustomWheelModel
		--RearWheelRadius = 20,

		CustomWheelModel = "models/simfphys/tdm/hmmwv_wheel.mdl",	-- since we create our own wheels we have to define a model. It has to have a collission model
		--CustomWheelModel_R = "",			-- different model for rear wheels?
		CustomWheelPosFL = Vector(72,40,14),		-- set the position of the front left wheel.
		CustomWheelPosFR = Vector(72,-40,14),	-- position front right wheel
		CustomWheelPosRL = Vector(-72,40,14),	-- rear left
		CustomWheelPosRR = Vector(-72,-40,14),	-- rear right		NOTE: make sure the position actually matches the name. So FL is actually at the Front Left ,  FR Front Right, ...   if you do this wrong the wheels will spin in the wrong direction or the car will drive sideways/reverse
		CustomWheelAngleOffset = Angle(180,0,0),

		CustomMassCenter = Vector(0,0,10),		-- custom masscenter offset. The script creates a counter weight to make the masscenter exactly in the center of the wheels. However you can add an offset to this to create more body roll if you really have to...

		CustomSteerAngle = 15,				-- max clamped steering angle,

		SeatOffset = Vector(2,-30,58),
		SeatPitch = 0,
		SeatYaw = 90,

		PassengerSeats = {
			{
				pos = Vector(-15,0,64),
				ang = Angle(0,-90,0)
			},
			{
				pos = Vector(0,-30,24),
				ang = Angle(0,-90,0)
			},
			{
				pos = Vector(-30,-30,24),
				ang = Angle(0,-90,0)
			},
			{
				pos = Vector(-30,30,24),
				ang = Angle(0,-90,0)
			},
		},

		FrontHeight = 4,
		FrontConstant = 90000.00,
		FrontDamping = 5000,
		FrontRelativeDamping = 1000,

		RearHeight = 4,
		RearConstant = 90000.00,
		RearDamping = 5000,
		RearRelativeDamping = 1000,

		FastSteeringAngle = 12,
		SteeringFadeFastSpeed = 535,

		TurnSpeed = 20,

		MaxGrip = 120,
		Efficiency = 0.75,
		GripOffset = -0,
		BrakePower = 65,

		IdleRPM = 750,
		LimitRPM = 4500,

		PeakTorque = 150,
		PowerbandStart = 2200,
		PowerbandEnd = 5300,
		Turbocharged = false,
		Supercharged = false,

		FuelFillPos = Vector(-40,48,48),
		FuelType = FUELTYPE_PETROL,
		FuelTankSize = 30,

		PowerBias = 0.8,

		EngineSoundPreset = -1,

		snd_pitch = 1,
		snd_idle = "simulated_vehicles/4banger/4banger_idle.wav",

		snd_low = "simulated_vehicles/4banger/4banger_low.wav",
		snd_low_pitch = 0.6,

		snd_mid = "simulated_vehicles/4banger/4banger_mid.wav",
		snd_mid_gearup = "simulated_vehicles/4banger/4banger_second.wav",
		snd_mid_pitch = 0.5,

		snd_horn = "simulated_vehicles/horn_2.wav",

		DifferentialGear = 0.30,
		Gears = {-0.09, 0, 0.09, 0.18, 0.28, 0.35},

		OnSpawn = function(ent)
			ent:SetNWBool( "simfphys_NoRacingHud", true )
			ent.DamageThreshold = nil
			ent.DamageBlock = 35
			ent.ArmorThreshold = 0.5
			-- ent:SetBodygroup(1, 1)
			SIMF_TDM.OnSpawned(ent)
		end,

		SetPassenger = function(vehicle, ply)
			SIMF_TDM.SetPassenger(vehicle, ply)
		end,

		PlayerBoneManipulation = {
			[1] = {
				["ValveBiped.Bip01_R_Calf"] = Angle(0,-90),
				["ValveBiped.Bip01_L_Calf"] = Angle(0,-90),

				["ValveBiped.Bip01_R_Thigh"] = Angle(5,100,0),
				["ValveBiped.Bip01_L_Thigh"] = Angle(-5,100,0),

				["ValveBiped.Bip01_L_Clavicle"] = Angle(10,0,-30),
				["ValveBiped.Bip01_R_Clavicle"] = Angle(10,0,30),

				["ValveBiped.Bip01_L_UpperArm"] = Angle(0,-35,30),
				["ValveBiped.Bip01_R_UpperArm"] = Angle(0,-25,-30),

				["ValveBiped.Bip01_L_Forearm"] = Angle(0,45,-30),
				["ValveBiped.Bip01_R_Forearm"] = Angle(0,45,30),

			}
		}
	}
}
list.Set( "simfphys_vehicles", "avx_tdm_hmmvv_mg", V )

local light_table = {
	L_HeadLampPos = Vector(-32.85,147.6,45.07),
	L_HeadLampAng = Angle(15,90,0),
	R_HeadLampPos = Vector(32.85,147.6,45.07),
	R_HeadLampAng = Angle(15,90,0),

	Headlight_sprites = {
		Vector(-38,134,49.5),
		Vector(38,134,49.5)
	},
	Rearlight_sprites = {
		Vector(-41,-132,38.5),
		Vector(41,-132,38.5)
	},
	Brakelight_sprites = {
		Vector(-41,-132,38.5),Vector(-41,-132,38.5),
		Vector(41,-132,38.5),Vector(41,-132,38.5)
	},

}
list.Set( "simfphys_lights", "avx_tdm_lav", light_table)

local V = {
	Name = "Land Assault Vehicle",
	Model = "models/simfphys/tdm/lav.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "TDM Rebalance",
	SpawnOffset = Vector(0,0,30),
	SpawnAngleOffset = 0,

	Members = {
		Mass = 8000,
		AirFriction = 0,
		Inertia = Vector(10000,30000,50000),

		IsArmored = true,

		OnSpawn = function(ent)
			ent:SetNWBool( "simfphys_NoRacingHud", true )
			ent.IsArmored = true
			ent.DamageThreshold = 80
			ent.DamageBlock = 100
			ent:SetSkin(1)
			SIMF_TDM.OnSpawned(ent)
		end,

		OnDestroyed =
			function(ent)
				if IsValid( ent.Gib ) then
					ent.Gib:PhysicsInit(6)
					ent.Gib:SetCollisionGroup(0)
					local yaw = ent.sm_pp_yaw or 0
					local pitch = ent.sm_pp_pitch or 0
					ent.Gib:SetPoseParameter("cannon_aim_yaw", yaw )
					ent.Gib:SetPoseParameter("cannon_aim_pitch", pitch )
				end
			end,

		MaxHealth = 8000,

		NoWheelGibs = true,

		FirstPersonViewPos = Vector(0,-50,50),

		FrontWheelRadius = 29,
		RearWheelRadius = 29,

		EnginePos = Vector(20,65,69.45),

		CustomWheels = true,
		CustomSuspensionTravel = 10,

		CustomWheelModel = "models/props_c17/canisterchunk01g.mdl",

		CustomWheelPosFL = Vector(-48,80,16),
		CustomWheelPosFR = Vector(48,80,16),
		CustomWheelPosML = Vector(-48,0,16),
		CustomWheelPosMR = Vector(48,0,16),
		CustomWheelPosRL = Vector(-48,-80,16),
		CustomWheelPosRR = Vector(48,-80,16),
		CustomWheelAngleOffset = Angle(0,0,0),

		CustomMassCenter = Vector(0,0,5),

		CustomSteerAngle = 30,

		SeatOffset = Vector(60,1,34),
		SeatPitch = -15,
		SeatYaw = 0,

		ModelInfo = {
			WheelColor = Color(0,0,0,0),
		},

		PassengerSeats = {
			{
				pos = Vector(0,-10,26),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(25,-50,23),
				ang = Angle(0,90,0)
			},
			{
				pos = Vector(-25,-50,23),
				ang = Angle(0,-90,0)
			},
			{
				pos = Vector(25,-78,23),
				ang = Angle(0,90,0)
			},
			{
				pos = Vector(-25,-78,23),
				ang = Angle(0,-90,0)
			},
			{
				pos = Vector(25,-106,23),
				ang = Angle(0,90,0)
			},
			{
				pos = Vector(-25,-106,23),
				ang = Angle(0,-90,0)
			},
		},

		FrontHeight = 15,
		FrontConstant = 50000,
		FrontDamping = 8000,
		FrontRelativeDamping = 40000,

		RearHeight = 15,
		RearConstant = 50000,
		RearDamping = 8000,
		RearRelativeDamping = 40000,

		FastSteeringAngle = 18,
		SteeringFadeFastSpeed = 400,

		TurnSpeed = 4,

		MaxGrip = 800,
		Efficiency = 1,
		GripOffset = -300,
		BrakePower = 100,
		BulletProofTires = true,

		IdleRPM = 700,
		LimitRPM = 5000,
		PeakTorque = 140,
		PowerbandStart = 700,
		PowerbandEnd = 4800,
		Turbocharged = false,
		Supercharged = false,
		DoNotStall = true,

		FuelFillPos = Vector(-40,50,50),
		FuelType = FUELTYPE_DIESEL,
		FuelTankSize = 250,

		PowerBias = 0,

		EngineSoundPreset = 0,

		Sound_Idle = "simulated_vehicles/t90ms/idle.wav",
		Sound_IdlePitch = 1,

		Sound_Mid = "simulated_vehicles/t90ms/low.wav",
		Sound_MidPitch = 1.3,
		Sound_MidVolume = 1,
		Sound_MidFadeOutRPMpercent = 60,
		Sound_MidFadeOutRate = 0.4,

		Sound_High = "simulated_vehicles/t90ms/high.wav",
		Sound_HighPitch = 1.2,
		Sound_HighVolume = 1,
		Sound_HighFadeInRPMpercent = 45,
		Sound_HighFadeInRate = 0.2,

		Sound_Throttle = "",
		Sound_ThrottlePitch = 0,
		Sound_ThrottleVolume = 0,

		snd_horn = "common/null.wav",
		ForceTransmission = 1,

		DifferentialGear = 0.3,
		Gears = {-0.1,0,0.08,0.09,0.11,0.14,0.17}
	}
}
list.Set( "simfphys_vehicles", "avx_tdm_lav", V )