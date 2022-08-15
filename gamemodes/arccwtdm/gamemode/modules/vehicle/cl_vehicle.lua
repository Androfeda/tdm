concommand.Add("tdm_vehicle", function(ply, cmd, args, argStr)
	local vehtbl = GAMEMODE.Vehicles[args[1]]
	if not vehtbl then return end

	local ent = LocalPlayer().VehiclePad
	if not IsValid(ent) or not ent:CanSpawn() or ent:GetPadType() ~= vehtbl.Type or ent:GetTeam() ~= ply:Team() or (vehtbl.Team and vehtbl.Team ~= LocalPlayer():Team()) then return end

	net.Start("tdm_vehicle")
		net.WriteEntity(ent)
		net.WriteString(args[1])
	net.SendToServer()
end, function(cmd, args)
	local ret = {}
	for k, _ in pairs(GAMEMODE.Vehicles) do
		table.insert(ret, "tdm_vehicle " .. k)
	end
	return ret
end, "Spawn the specified vehicle. You must be standing in an approproate spawn pad.")

local nexttick = 0
hook.Add("Think", "tdm_vehiclepad", function()
	if not IsValid(LocalPlayer()) then return end
	if LocalPlayer():InVehicle() then
		LocalPlayer().VehiclePad = nil
		return
	end
	if nexttick > CurTime() then return end
	nexttick = CurTime() + 0.2
	local ent
	local dist
	for _, v in pairs(ents.FindByClass("tdm_vehiclepad")) do
		if v:GetTeam() == LocalPlayer():Team() and GAMEMODE:WithinVehiclePadRange(LocalPlayer(), v) then
			local vd = LocalPlayer():GetPos():DistToSqr(v:GetPos())
			local zd = LocalPlayer():GetPos().z - v:GetPos().z
			if (not ent or dist > vd) and zd > -32 and zd < 72 then
				ent = v
				dist = vd
			end
		end
	end
	LocalPlayer().VehiclePad = ent
end)

hook.Add("KeyPress", "tdm_vehicle", function( ply, key )
	if IsValid(LocalPlayer().VehiclePad) and key == IN_USE and LocalPlayer().VehiclePad:CanSpawn() and LocalPlayer().VehiclePad:GetTeam() == ply:Team() then
		if GAMEMODE.VehicleListMenu then
			GAMEMODE.VehicleListMenu:Remove()
		end
		GAMEMODE.VehicleListMenu = vgui.Create("TDMVehicleList")
		GAMEMODE.VehicleListMenu:SetPadType(LocalPlayer().VehiclePad:GetPadType())
	end
end)

net.Receive("tdm_vehicle", function()
	local padi = net.ReadUInt(16)
	local enti = net.ReadUInt(16)
	local vname = net.ReadString()
	local t = net.ReadUInt(4)
	local cur = CurTime()
	timer.Create("addveh_" .. enti, 0, 0, function()
		if CurTime() > cur + 1 then
			timer.Remove("addveh_" .. enti)
			return
		end
		if IsValid(Entity(enti)) then
			GAMEMODE.SpawnedVehicles[padi] = {
				Entity = Entity(enti),
				VehicleName = vname,
				Team = t,
			}
			timer.Remove("addveh_" .. enti)
		end
	end)

end)