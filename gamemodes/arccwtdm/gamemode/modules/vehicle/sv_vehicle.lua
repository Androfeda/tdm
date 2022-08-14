util.AddNetworkString("tdm_vehicle")

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
		ent = simfphys.SpawnVehicleSimple(veh, pad:GetPos() + (vehtbl.SpawnOffset or Vector()) + Vector(0, 0, 25), pad:GetAngles() + Angle(0, 90, 0))
	end

	if IsValid(ent) then
		pad:SetSpawnedVehicle(ent)
		pad:SetNextReady(CurTime() + GAMEMODE.VehiclePadTypes[pad:GetPadType()].Cooldown or 5)
		GAMEMODE.SpawnedVehicles[pad:EntIndex()] = {
			Entity = ent,
			DespawnTries = 0,
			VehicleName = veh,
			Team = ply:Team(),
		}
		ent.VehicleInfo = GAMEMODE.SpawnedVehicles[pad:EntIndex()]
		net.Start("tdm_vehicle")
			net.WriteUInt(pad:EntIndex(), 16)
			net.WriteUInt(ent:EntIndex(), 16)
			net.WriteString(veh)
			net.WriteUInt(ply:Team(), 4)
		net.Broadcast()
	else
		print("Failed to spawn " .. veh .. "!")
	end
end)

local interval = 3
timer.Create("tdm_vehicle", interval, 0, function()
	if GetConVar("tdm_vehicle_despawn"):GetInt() == 0 then return end

	local occupied = {}
	for _, ply in pairs(player.GetAll()) do
		if simfphys and IsValid(ply:GetSimfphys()) then
			occupied[ply:GetSimfphys()] = true
		end
		if IsValid(ply:GetVehicle()) then
			occupied[ply:GetVehicle()] = true
		end
	end

	for i, tbl in pairs(GAMEMODE.SpawnedVehicles) do
		local ent = tbl.Entity
		if not IsValid(ent) then
			GAMEMODE.SpawnedVehicles[i] = nil
			continue
		end

		local despawn = not occupied[ent]
		if despawn then
			tbl.DespawnTries = (tbl.DespawnTries or 0) + 1
			if GetConVar("tdm_vehicle_despawn"):GetInt() < tbl.DespawnTries * interval then
				ent:Remove()
				GAMEMODE.SpawnedVehicles[i] = nil
			end
		else
			tbl.DespawnTries = 0
		end
	end
end)

hook.Add("simfphysOnTakeDamage", "tdm_vehicle", function(ent, dmginfo)
	local attacker = dmginfo:GetAttacker()
	if not ent.VehicleInfo or not attacker:IsPlayer() then return end

	local vt = GAMEMODE:GetVehicleTeam(ent)
	if vt == attacker:Team() then
		dmginfo:ScaleDamage(math.Clamp(GetConVar("tdm_vehicle_ff"):GetFloat(), 0, 1))
	end
end)

hook.Add("simfphysPostTakeDamage", "tdm_vehicle", function(ent, dmginfo)
	local attacker = dmginfo:GetAttacker()
	if not ent.VehicleInfo or not attacker:IsPlayer() then return end

	local vt = GAMEMODE:GetVehicleTeam(ent)
	if vt and vt ~= attacker:Team() then
		local reward = dmginfo:GetDamage() * GetConVar("tdm_money_vehicle_damage"):GetFloat()
		if not attacker:InVehicle() then
			reward = reward * GetConVar("tdm_money_vehicle_onfoot"):GetFloat()
		end
		reward = math.floor(reward)
		if reward > 0 then
			attacker:AddMoney(reward)
		end
	end
end)

hook.Add("simfphysVehicleDestroyed", "tdm_vehicle", function(ent, dmginfo)
	local attacker = dmginfo:GetAttacker()
	if not ent.VehicleInfo or not attacker:IsPlayer() then return end

	local vt = GAMEMODE:GetVehicleTeam(ent)
	if vt and vt ~= attacker:Team() then
		local reward = (GAMEMODE.Vehicles[ent.VehicleInfo.VehicleName].Points or 300) * GetConVar("tdm_money_vehicle_kill"):GetFloat()
		if not attacker:InVehicle() then
			reward = reward * GetConVar("tdm_money_vehicle_onfoot"):GetFloat()
		end
		reward = math.floor(reward)
		if reward > 0 then
			attacker:AddMoney(reward)
		end
	end
end)
