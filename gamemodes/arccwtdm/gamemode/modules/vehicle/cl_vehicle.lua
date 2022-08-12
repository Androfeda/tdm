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
			if not ent or dist > vd then
				ent = v
				dist = vd
			end
		end
	end
	LocalPlayer().VehiclePad = ent
end)

hook.Add("KeyPress", "tdm_vehicle", function( ply, key )
	if IsValid(LocalPlayer().VehiclePad) and key == IN_USE and LocalPlayer().VehiclePad:CanSpawn() and LocalPlayer().VehiclePad:GetTeam() == ply:Team() then
		local vehList = vgui.Create("TDMVehicleList")
		vehList:SetPadType(LocalPlayer().VehiclePad:GetPadType())
	end
end)