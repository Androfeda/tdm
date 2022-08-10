util.AddNetworkString("tdm_vehicle")

GM.SpawnedVehicles = {}

net.Receive("tdm_vehicle", function(len, ply)
	local pad = net.ReadEntity()
	local veh = net.ReadString()

	if not IsValid(pad) or not GAMEMODE.Vehicles[veh] or not pad:CanSpawn()
			or GAMEMODE.Vehicles[veh].Type ~= pad:GetPadType()
			or (GAMEMODE.Vehicles[veh].Team and GAMEMODE.Vehicles[veh].Team ~= ply:Team()) then return end
	if not GAMEMODE:WithinVehiclePadRange(ply, pad) then return end

	local ent
	if simfphys and list.Get("simfphys_vehicles")[veh] then
		local vehtbl = list.Get("simfphys_vehicles")[veh]
		ent = simfphys.SpawnVehicleSimple(veh, pad:GetPos() + (vehtbl.SpawnOffset or Vector()) + Vector(0, 0, 25), pad:GetAngles())
	end

	if IsValid(ent) then
		pad:SetSpawnedVehicle(ent)
		pad:SetNextReady(CurTime() + GAMEMODE.VehiclePadTypes[pad:GetPadType()].Cooldown or 5)
		GAMEMODE.SpawnedVehicles[pad] = {
			Entity = ent,
			LastOccupied = CurTime(),
			Team = ply:Team(),
		}
	else
		print("Failed to spawn " .. veh .. "!")
	end
end)