util.AddNetworkString("tdm_updatespawnareas")
util.AddNetworkString("tdm_fullupdatespawnareas")

local function writearea(i)
	local a = GAMEMODE.SpawnAreas[i]
	if not a then return end
	net.WriteUInt(i, 8)
	net.WriteVector(a[1])
	net.WriteBool(isnumber(a[2]))
	if isnumber(a[2]) then
		net.WriteFloat(a[2])
	else
		net.WriteVector(a[2])
	end
	net.WriteUInt(a[3], 4)
end

function GM:SendSpawnArea(i)
	net.Start("tdm_updatespawnareas")
		if GAMEMODE.SpawnAreas[i] == nil then
			net.WriteBool(true)
			net.WriteUInt(i, 8)
		else
			net.WriteBool(false)
			writearea(i)
		end
	net.Broadcast()
end

function GM:SendSpawnAreaFull(ply)
	net.Start("tdm_fullupdatespawnareas")
		net.WriteUInt(table.Count(GAMEMODE.SpawnAreas), 8)
		for k, v in pairs(GAMEMODE.SpawnAreas) do
			writearea(k)
		end
	if not ply then net.Broadcast() else net.Send(ply) end
end
net.Receive("tdm_fullupdatespawnareas", function(len, ply)
	GAMEMODE:SendSpawnAreaFull(ply)
end)

function GM:LoadSpawnSet(name)
	local f = "tdm/" .. game.GetMap() .. "/spawnsets/" .. string.lower(name) .. ".json"
	if not file.Exists(f, "DATA") then
		MsgN("Could not load spawn set '", name, "'!")
		return
	end

	for _, spawn in pairs(ents.FindByClass("tdm_spawn_hecu")) do
		spawn:Remove()
	end
	for _, spawn in pairs(ents.FindByClass("tdm_spawn_cmb")) do
		spawn:Remove()
	end

	local spawns = util.JSONToTable(file.Read(f))
	GAMEMODE.SpawnAreas = spawns.Areas
	for _, v in pairs(spawns.Points) do
		local spawn = ents.Create(v[2])
		spawn:SetPos(v[1])
		spawn:Spawn()
	end

	MsgN("Loaded spawn set '", name, "'.")
end

function GM:SaveSpawnSet(name)
	local spawns = {
		Areas = GAMEMODE.SpawnAreas,
		Points = {}
	}
	for _, spawn in pairs(ents.FindByClass("tdm_spawn_hecu")) do
		table.insert(spawns.Points, {spawn:GetPos(), spawn:GetClass()})
	end
	for _, spawn in pairs(ents.FindByClass("tdm_spawn_cmb")) do
		table.insert(spawns.Points, {spawn:GetPos(), spawn:GetClass()})
	end

	file.CreateDir("tdm/" .. game.GetMap() .. "/spawnsets")
	local f = "tdm/" .. game.GetMap() .. "/spawnsets/" .. string.lower(name) .. ".json"
	if table.Count(spawns.Areas) == 0 and table.Count(spawns.Points) == 0 then
		MsgN("Refusing to save empty spawnset.")
		return
	end
	file.Write(f, util.TableToJSON(spawns))

	MsgN("Saved spawn set '", name, "'.")
end



local spawns = {[TEAM_HECU] = "tdm_spawn_hecu", [TEAM_CMB] = "tdm_spawn_cmb"}
local spawns_backup = {[TEAM_HECU] = "info_player_counterterrorist", [TEAM_CMB] = "info_player_terrorist"}

function GM:PlayerSelectTeamSpawn(TeamID, pl)
	-- original doesn't work for some reason
	local SpawnPoints = ents.FindByClass(spawns[TeamID]) --team.GetSpawnPoints(TeamID)
	if #SpawnPoints == 0 then
		SpawnPoints = ents.FindByClass(spawns_backup[TeamID])
	end

	if #SpawnPoints == 0 then return end
	local ChosenSpawnPoint = nil

	for i = 0, 6 do
		ChosenSpawnPoint = table.Random(SpawnPoints)
		print(ChosenSpawnPoint)
		if hook.Call("IsSpawnpointSuitable", GAMEMODE, pl, ChosenSpawnPoint, i == 6) then return ChosenSpawnPoint end
	end

	return ChosenSpawnPoint
end