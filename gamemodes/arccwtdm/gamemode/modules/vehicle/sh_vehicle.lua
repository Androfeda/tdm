
VEHICLE_TYPE_UNARMED = 0
VEHICLE_TYPE_LIGHT = 1
VEHICLE_TYPE_MEDIUM = 2
VEHICLE_TYPE_HEAVY = 3

AIRCRAFT_TYPE_UNARMED = 10
AIRCRAFT_TYPE_LIGHT = 11
AIRCRAFT_TYPE_MEDIUM = 12
AIRCRAFT_TYPE_HEAVY = 13

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

	[AIRCRAFT_TYPE_UNARMED] = {
		Name = "Transport Aircraft",
		Model = "models/hunter/plates/plate7x7.mdl",
	},
	[AIRCRAFT_TYPE_LIGHT] = {
		Name = "Light Aircraft",
		Model = "models/hunter/plates/plate6x6.mdl",
	},
	[AIRCRAFT_TYPE_MEDIUM] = {
		Name = "Medium Aircraft",
		Model = "models/hunter/plates/plate8x8.mdl",
	},
	[AIRCRAFT_TYPE_HEAVY] = {
		Name = "Heavy Aircraft",
		Model = "models/hunter/plates/plate8x8.mdl",
	},
}