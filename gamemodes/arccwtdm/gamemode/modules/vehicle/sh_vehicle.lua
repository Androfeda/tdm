
VEHICLE_TYPE_UNARMED = 0
VEHICLE_TYPE_LIGHT = 1
VEHICLE_TYPE_MEDIUM = 2
VEHICLE_TYPE_HEAVY = 3

PLANE_TYPE_LIGHT = 10
PLANE_TYPE_HEAVY = 11

HELO_TYPE_UNARMED = 20
HELO_TYPE_LIGHT = 21
HELO_TYPE_HEAVY = 22

GM.Vehicles = {
	["avx_tdm_combineapc"] = {
		Team = TEAM_CMB,
		Type = VEHICLE_TYPE_MEDIUM,
		Points = 500,

		Description = "Flexible and mobile",
		Armaments = {
			"Pulse Suppression Gun (AP)",
			"HEAT Guided Missiles",
		}
	},
	["avx_tdm_hecuapc"] = {
		Team = TEAM_HECU,
		Type = VEHICLE_TYPE_MEDIUM,
		Points = 500,

		Description = "Durable, can switch ammo types",
		Armaments = {
			"Twin-barrel Cannon (AP)",
			"Twin-barrel Cannon (HE)",
		}
	},
}

GM.VehiclePadTypes = {
	[VEHICLE_TYPE_UNARMED] = {
		Name = "Transport Vehicle",
		Model = "models/hunter/plates/plate4x6.mdl",
		Icon = Material("tdm/vehicle_pad/vehicle_unarmed.png", "smooth mips"),
	},
	[VEHICLE_TYPE_LIGHT] = {
		Name = "Light Vehicle",
		Model = "models/hunter/plates/plate4x6.mdl",
		Icon = Material("tdm/vehicle_pad/vehicle_light.png", "smooth mips"),
	},
	[VEHICLE_TYPE_MEDIUM] = {
		Name = "Medium Vehicle",
		Model = "models/hunter/plates/plate5x7.mdl",
		Icon = Material("tdm/vehicle_pad/vehicle_medium.png", "smooth mips"),
	},
	[VEHICLE_TYPE_HEAVY] = {
		Name = "Heavy Vehicle",
		Model = "models/hunter/plates/plate6x8.mdl",
		Icon = Material("tdm/vehicle_pad/vehicle_heavy.png", "smooth mips"),
	},

	[PLANE_TYPE_LIGHT] = {
		Name = "Light Aircraft",
		Model = "models/hunter/plates/plate8x16.mdl",
		Icon = Material("tdm/vehicle_pad/plane_light.png", "smooth mips"),
	},
	[PLANE_TYPE_HEAVY] = {
		Name = "Heavy Aircraft",
		Model = "models/hunter/plates/plate8x16.mdl",
		Icon = Material("tdm/vehicle_pad/plane_heavy.png", "smooth mips"),
	},

	[HELO_TYPE_UNARMED] = {
		Name = "Transport Helicopter",
		Model = "models/hunter/plates/plate8x8.mdl",
		Icon = Material("tdm/vehicle_pad/helo_unarmed.png", "smooth mips"),
	},
	[HELO_TYPE_LIGHT] = {
		Name = "Recon Helicopter",
		Model = "models/hunter/plates/plate8x8.mdl",
		Icon = Material("tdm/vehicle_pad/helo_light.png", "smooth mips"),
	},
	[HELO_TYPE_HEAVY] = {
		Name = "Attack Helicopter",
		Model = "models/hunter/plates/plate8x8.mdl",
		Icon = Material("tdm/vehicle_pad/helo_heavy.png", "smooth mips"),
	},
}