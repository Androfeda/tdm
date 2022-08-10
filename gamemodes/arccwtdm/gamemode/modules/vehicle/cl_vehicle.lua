
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