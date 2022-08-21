util.AddNetworkString("tdm_updateobjareas")
util.AddNetworkString("tdm_fullupdateobjareas")

local function writearea(i)
	local a = GAMEMODE.ObjectiveAreas[i]
	if not a then return end
	net.WriteUInt(i, 8)
	net.WriteVector(a[1])
	net.WriteBool(isnumber(a[2]))
	if isnumber(a[2]) then
		net.WriteFloat(a[2])
	else
		net.WriteVector(a[2])
	end
end

function GM:SendObjArea(i)
	net.Start("tdm_updateobjareas")
		if GAMEMODE.ObjectiveAreas[i] == nil then
			net.WriteBool(true)
			net.WriteUInt(i, 8)
		else
			net.WriteBool(false)
			writearea(i)
		end
	net.Broadcast()
end

function GM:SendObjAreaFull(ply)
	net.Start("tdm_fullupdateobjareas")
		net.WriteUInt(table.Count(GAMEMODE.ObjectiveAreas), 8)
		for k, v in pairs(GAMEMODE.ObjectiveAreas) do
			writearea(k)
		end
	if not ply then net.Broadcast() else net.Send(ply) end
end