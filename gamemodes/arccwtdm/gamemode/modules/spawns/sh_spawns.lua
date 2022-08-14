-- Areas within which a team is invulnerable, and the other team cannot enter.
GM.SpawnAreas = {
	-- {Vector mins, Vector maxs, number team}
	-- {Vector origin, number radius, number team}
}

local PLAYER = FindMetaTable("Player")

function PLAYER:GetSpawnArea()
	local p = self:WorldSpaceCenter()
	for i, a in pairs(GAMEMODE.SpawnAreas) do
		if (isnumber(a[2]) and (p:Distance(a[1]) <= a[2]))
				or (not isnumber(a[2]) and p:WithinAABox(a[1], a[2])) then
			return a[3]
		end
	end
	return false
end

function PLAYER:SpawnProtection()
	if self:GetSpawnArea() == self:Team() then return true end
	return false
end

concommand.Add("tdm_loadspawnset", function(ply, cmd, args, argStr)
	if CLIENT or (IsValid(ply) and not ply:IsAdmin()) then return end
	local name = args[1]
	if not name or name == "" then
		name = GetConVar("tdm_game"):GetString()
	end
	GAMEMODE:LoadSpawnSet(name)
end)

concommand.Add("tdm_savespawnset", function(ply, cmd, args, argStr)
	if CLIENT or (IsValid(ply) and not ply:IsAdmin()) then return end
	local name = args[1]
	if not name or name == "" then
		name = GetConVar("tdm_game"):GetString()
	end
	GAMEMODE:SaveSpawnSet(name)
end)