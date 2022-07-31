-- Shared initialization
GM.Name = "ArcCW TDM"
GM.Author = "Fesiug"
GM.Email = "publicfesiug@outlook.com"
GM.Website = "example.com"
GM.TeamBased = true
GM.SecondsBetweenTeamSwitches = 0 -- YOU ARE A WILLY RIDER

TEAM_HECU = 1
TEAM_CMB = 2

DeriveGamemode("sandbox")

-- Load modules
local path = GM.FolderName .. "/gamemode/modules/"
local modules, folders = file.Find(path .. "*", "LUA")

for _, v in ipairs(modules) do
	if string.GetExtensionFromFilename(v) ~= "lua" then continue end
	include(path .. v)
end

for _, folder in SortedPairs(folders, false) do
	if folder == "." or folder == ".." then continue end

	-- Shared modules
	for _, f in SortedPairs(file.Find(path .. folder .. "/sh_*.lua", "LUA"), false) do
		AddCSLuaFile(path .. folder .. "/" .. f)
		include(path .. folder .. "/" .. f)
	end

	-- Server modules
	if SERVER then
		for _, f in SortedPairs(file.Find(path .. folder .. "/sv_*.lua", "LUA"), false) do
			include(path .. folder .. "/" .. f)
		end
	end

	-- Client modules
	for _, f in SortedPairs(file.Find(path .. folder .. "/cl_*.lua", "LUA"), false) do
		AddCSLuaFile(path .. folder .. "/" .. f)

		if CLIENT then
			include(path .. folder .. "/" .. f)
		end
	end
end

-- vgui
local path_vgui = GM.FolderName .. "/gamemode/vgui/"
for _, f in SortedPairs(file.Find(path_vgui .. "*.lua", "LUA"), false) do
	AddCSLuaFile(path_vgui .. f)

	if CLIENT then
		include(path_vgui .. f)
	end
end

include("player_class/player_arccwtdm.lua")

if SERVER then
	tochange = {
		["mp_falldamage"] = 1,
		["sbox_godmode"] = 0,
		["sbox_playershurtplayers"] = 1,
		["arccw_override_hud_off"] = 1,
		["arccw_atts_ubglautoload"] = 1,
	}
	oldcvs = {}
end
function GM:Initialize()
	if SERVER then
		-- this could get evil... restore the old convars!!
		for conname, conval in pairs(tochange) do
			oldcvs[conname] = GetConVar(conname):GetString()
			print("Saved old config:", conname, GetConVar(conname):GetString())
			RunConsoleCommand(conname, conval)
		end
		GAMEMODE:LoadSpawnSet(GetConVar("tdm_gamemode"):GetString())
	end
end

if SERVER then
	hook.Add("ShutDown", "TDM_Consave", function()
		for conname, conval in pairs(oldcvs) do
			RunConsoleCommand(conname, conval)
			print("Restored old config:", conname, conval)
		end
	end)
end

function GM:CreateTeams()
	team.SetUp(TEAM_HECU, "HECU", Color(175, 205, 120))
	team.SetSpawnPoint(TEAM_HECU, "tdm_spawn_hecu")
	team.SetUp(TEAM_CMB, "CMB", Color(152, 169, 255))
	team.SetSpawnPoint(TEAM_CMB, "tdm_spawn_cmb")
	team.SetSpawnPoint(TEAM_SPECTATOR, "worldspawn")
end

concommand.Add("tdm_setteam", function(ply, cmd, args)
	local Team = args[1] or 1
	local ee = args[2] or 1
	Entity(ee):SetTeam(Team)
end)

--
-- Playermodels
--
player_manager.AddValidModel("ArcCW TDM - CMB", "models/ffcm_player/combine_pm.mdl")
player_manager.AddValidHands("ArcCW TDM - CMB", "models/ffcm_hands/combine_hands.mdl", 0, "0000000")
player_manager.AddValidModel("ArcCW TDM - HECU", "models/tdm/hecu.mdl")
player_manager.AddValidHands("ArcCW TDM - HECU", "models/tdm/hecu_arms.mdl", 6, "311")