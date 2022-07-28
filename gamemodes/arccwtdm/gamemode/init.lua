
-- Serverside initialization

AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

AddCSLuaFile( "client/hud.lua" )

function GM:PlayerSpawn( pl, transiton )
	player_manager.SetPlayerClass( pl, "player_arccwtdm" )

	-- Stop observer mode
	pl:UnSpectate()
	pl:SetupHands()

	player_manager.OnPlayerSpawn( pl, transiton )
	player_manager.RunClass( pl, "Spawn" )

	-- Set player model
	hook.Call( "PlayerSetModel", GAMEMODE, pl )

	if pl:Team() == 1001 then pl:SetTeam(team.BestAutoJoinTeam()) end
end