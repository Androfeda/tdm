local function read()
	local i = net.ReadUInt(8)
	GAMEMODE.ObjectiveAreas[i] = {}
	GAMEMODE.ObjectiveAreas[i][1] = net.ReadVector()
	if net.ReadBool() then
		GAMEMODE.ObjectiveAreas[i][2] = net.ReadFloat()
	else
		GAMEMODE.ObjectiveAreas[i][2] = net.ReadVector()
	end
end

net.Receive("tdm_updateobjareas", function()
	if net.ReadBool() then
		GAMEMODE.ObjectiveAreas[net.ReadUInt(8)] = nil
	else
		read()
	end
end)

net.Receive("tdm_fullupdateobjareas", function()
	GAMEMODE.ObjectiveAreas = {}
	for i = 1, net.ReadUInt(8) do
		read()
	end
end)