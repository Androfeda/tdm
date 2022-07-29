
-- Serverside initialization

AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

AddCSLuaFile( "client/hud.lua" )


function GM:PlayerInitialSpawn( pl, transiton )
	pl:SetTeam( TEAM_UNASSIGNED )

	if ( GAMEMODE.TeamBased ) then
		pl:ConCommand( "gm_showteam" )
	end
end

--[[---------------------------------------------------------
	Name: gamemode:PlayerSpawnAsSpectator()
	Desc: Player spawns as a spectator
-----------------------------------------------------------]]
function GM:PlayerSpawnAsSpectator( pl )
	pl:StripWeapons()
	if ( pl:Team() == TEAM_UNASSIGNED ) then
		pl:Spectate( OBS_MODE_FIXED )
		return
	end
	pl:SetTeam( TEAM_SPECTATOR )
	pl:Spectate( OBS_MODE_ROAMING )
end

function GM:PlayerSpawn( pl, transiton )
	if pl:Team() == TEAM_SPECTATOR or pl:Team() == TEAM_UNASSIGNED then
		self:PlayerSpawnAsSpectator( pl )
		return
	end

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