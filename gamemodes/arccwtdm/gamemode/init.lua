
-- Serverside initialization

AddCSLuaFile( "shared.lua" )
include( "shared.lua" )


function GM:PlayerInitialSpawn( pl, transiton )
	pl:SetTeam(team.BestAutoJoinTeam())
	pl.DeathTime2 = CurTime()
end

function GM:PlayerSpawnAsSpectator( pl )
	pl:StripWeapons()
	pl:SetTeam( TEAM_SPECTATOR )
	pl:Spectate( OBS_MODE_ROAMING )
	pl.DeathTime2 = CurTime()
end

function GM:PlayerSpawn( pl, transiton )
	player_manager.SetPlayerClass( pl, "player_arccwtdm" )
	if pl:Team() == TEAM_SPECTATOR or pl:Team() == TEAM_UNASSIGNED then
		self:PlayerSpawnAsSpectator( pl )
		return
	end
	pl.DeathTime2 = CurTime()

	-- Stop observer mode
	pl:UnSpectate()
	pl:SetupHands()

	player_manager.OnPlayerSpawn( pl, transiton )
	player_manager.RunClass( pl, "Spawn" )

	hook.Call( "PlayerLoadout", GAMEMODE, pl )

		-- Set player model
	hook.Call( "PlayerSetModel", GAMEMODE, pl )

	if pl:Team() == 1001 then pl:SetTeam(team.BestAutoJoinTeam()) end
end

function GM:PlayerLoadout( pl )
	player_manager.RunClass( pl, "Loadout" )
end

function GM:PlayerDeathSound(ply)
	return true -- BEEP BEEP  BEEP BEEP BEEEEEEEEEEEEEEEEEEEEP
end