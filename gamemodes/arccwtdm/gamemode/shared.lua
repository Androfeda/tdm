
-- Shared initialization

GM.Name				= "ArcCW TDM"
GM.Author			= "Fesiug"
GM.Email			= "publicfesiug@outlook.com"
GM.Website			= "example.com"

DeriveGamemode( "sandbox" )

include( "player_class/player_arccwtdm.lua" )

function GM:Initialize()
end

function GM:PlayerNoClip( pl, on )
	if ( !on ) then return true end
	-- Allow noclip if we're in single player and living
	return IsValid( pl ) && pl:Alive()
end

CreateConVar("arccwtdm_spawn", 0, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Allow sandbox spawning.", 0, 1)
hook.Add( "PlayerCheckLimit", "ArcCWTDM_PlayerCheckLimit", function( ply, name, cur, max )
	if GetConVar("arccwtdm_spawn"):GetBool() == false then return false end
end )
hook.Add( "PlayerGiveSWEP", "BlockPlayerSWEPs", function( ply, class, swep )
	if GetConVar("arccwtdm_spawn"):GetBool() == false then return false end
end )





hook.Add( "CreateTeams", "ArcCWTDM_CreateTeams", function()
	team.SetUp(1, "HECU", Color(175, 205, 120))
	team.SetUp(2, "CMB", Color(152, 169, 255))
end)

concommand.Add( "arccwtdm_setteam", function( ply, cmd, args )
	local Team = args[1] or 1
	local ee = args[2] or 1
	Entity(ee):SetTeam( Team )
	--Entity(ee):Spawn()
end )


--
-- Playermodels
--

player_manager.AddValidModel( "ArcCW TDM - CMB", "models/ffcm_player/combine_pm.mdl" );
player_manager.AddValidHands( "ArcCW TDM - CMB", "models/ffcm_hands/combine_hands.mdl", 0, "0000000" )

player_manager.AddValidModel( "ArcCW TDM - HECU", "models/Yukon/HECU/HECU_01_player.mdl" );
player_manager.AddValidHands( "ArcCW TDM - HECU", "models/weapons/c_arms_hecu_a3.mdl", 6, "311" )