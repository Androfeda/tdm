
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

	["avx_tdm_bulldog"] = {
		Team = TEAM_CMB,
		Type = VEHICLE_TYPE_UNARMED,
		Points = 150,

		Description = "Light armored recon vehicle",
	},
	["avx_tdm_hmmvv"] = {
		Team = TEAM_HECU,
		Type = VEHICLE_TYPE_UNARMED,
		Points = 150,

		Description = "Light armored recon vehicle",
	},

	["avx_tdm_bulldog_mg"] = {
		Team = TEAM_CMB,
		Type = VEHICLE_TYPE_LIGHT,
		Points = 300,

		Description = "Light armored recon vehicle",
		Description2 = "Armed with top-mounted machine gun",

	},
	["avx_tdm_hmmvv_mg"] = {
		Team = TEAM_HECU,
		Type = VEHICLE_TYPE_LIGHT,
		Points = 300,

		Description = "Light armored recon vehicle",
		Description2 = "Armed with top-mounted machine gun",
	},

	["avx_tdm_lav"] = {
		Team = TEAM_CMB,
		Type = VEHICLE_TYPE_MEDIUM,
		Points = 600,

		Description = "Anti-vehicle armored personnel carrier",
		Description2 = "Fires two high velocity ATGMs rapidly",
	},

	["avx_tdm_combineapc"] = {
		Team = TEAM_CMB,
		Type = VEHICLE_TYPE_MEDIUM,
		Points = 800,

		Description = "Mobile and versatile armored car",
		Description2 = "Pulse gun penetrates armor",
	},
	["avx_tdm_hecuapc"] = {
		Team = TEAM_HECU,
		Type = VEHICLE_TYPE_MEDIUM,
		Points = 800,

		Description = "Durable armored personnel carrier",
		Description2 = "Can switch between AP and HE rounds",
	},
}

GM.VehiclePadTypes = {
	[VEHICLE_TYPE_UNARMED] = {
		Name = "Transport Vehicle",
		Model = "models/hunter/plates/plate4x6.mdl",
		Icon = Material("tdm/vehicle_pad/vehicle_unarmed.png", "smooth mips"),
		Cooldown = 60,
	},
	[VEHICLE_TYPE_LIGHT] = {
		Name = "Light Vehicle",
		Model = "models/hunter/plates/plate4x6.mdl",
		Icon = Material("tdm/vehicle_pad/vehicle_light.png", "smooth mips"),
		Cooldown = 120,
	},
	[VEHICLE_TYPE_MEDIUM] = {
		Name = "Medium Vehicle",
		Model = "models/hunter/plates/plate5x7.mdl",
		Icon = Material("tdm/vehicle_pad/vehicle_medium.png", "smooth mips"),
		Cooldown = 180,
	},
	[VEHICLE_TYPE_HEAVY] = {
		Name = "Heavy Vehicle",
		Model = "models/hunter/plates/plate6x8.mdl",
		Icon = Material("tdm/vehicle_pad/vehicle_heavy.png", "smooth mips"),
		Cooldown = 240,
	},

	[PLANE_TYPE_LIGHT] = {
		Name = "Light Aircraft",
		Model = "models/hunter/plates/plate8x16.mdl",
		Icon = Material("tdm/vehicle_pad/plane_light.png", "smooth mips"),
		Cooldown = 180,
	},
	[PLANE_TYPE_HEAVY] = {
		Name = "Heavy Aircraft",
		Model = "models/hunter/plates/plate8x16.mdl",
		Icon = Material("tdm/vehicle_pad/plane_heavy.png", "smooth mips"),
		Cooldown = 240,
	},

	[HELO_TYPE_UNARMED] = {
		Name = "Transport Helicopter",
		Model = "models/hunter/plates/plate8x8.mdl",
		Icon = Material("tdm/vehicle_pad/helo_unarmed.png", "smooth mips"),
		Cooldown = 90,
	},
	[HELO_TYPE_LIGHT] = {
		Name = "Recon Helicopter",
		Model = "models/hunter/plates/plate8x8.mdl",
		Icon = Material("tdm/vehicle_pad/helo_light.png", "smooth mips"),
		Cooldown = 120,
	},
	[HELO_TYPE_HEAVY] = {
		Name = "Attack Helicopter",
		Model = "models/hunter/plates/plate8x8.mdl",
		Icon = Material("tdm/vehicle_pad/helo_heavy.png", "smooth mips"),
		Cooldown = 180,
	},
}

GM.SpawnedVehicles = {}

function GM:WithinVehiclePadRange(ply, ent)
	return ply:GetPos():DistToSqr(ent:GetPos()) <= 256 * 256
end

function GM:GetVehiclesForPlayer(ply, padtype)
	local vehs = {}
	for k, v in pairs(GAMEMODE.Vehicles) do
		if v.Type == padtype and (not v.Team or v.Team == ply:Team()) then
			vehs[k] = v
		end
	end
	return vehs
end

function GM:GetVehicleName(class)
	if list.Get("simfphys_vehicles") and list.Get("simfphys_vehicles")[class] then
		return list.Get("simfphys_vehicles")[class].Name
	elseif scripted_ents.Get(class) then
		return scripted_ents.Get(class).PrintName
	end

	return class
end

function GM:GetVehicleTeam(ent, count_unoccupied)
	local cur_team = nil
	local vehtbl = {}
	for k, v in pairs(GAMEMODE.SpawnedVehicles) do
		if v.Entity == ent then
			vehtbl = v
			break
		end
	end

	local occupied = false
	if simfphys and simfphys.IsCar(ent) then
		for _, ply in pairs(player.GetAll()) do
			if ply:GetSimfphys() == ent then
				occupied = true
				if ply:Team() == vehtbl.Team then
					-- if anyone in the original team is in the vehicle, it is their team's even if enemies are on board
					cur_team = ply:Team()
					break
				elseif cur_team == nil then
					cur_team = ply:Team()
				end
			end
		end
	end

	if not occupied and count_unoccupied then
		return vehtbl.Team, false
	else
		return cur_team, occupied
	end
end