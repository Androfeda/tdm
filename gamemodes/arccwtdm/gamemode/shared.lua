
-- Shared initialization

GM.Name				= "ArcCW TDM"
GM.Author			= "Fesiug"
GM.Email			= "publicfesiug@outlook.com"
GM.Website			= "example.com"
GM.TeamBased		= true
GM.SecondsBetweenTeamSwitches = 0 -- YOU ARE A WILLY RIDER

DeriveGamemode( "sandbox" )

include( "player_class/player_arccwtdm.lua" )

function GM:Initialize()
	if SERVER then
		RunConsoleCommand("mp_falldamage", "1")
		RunConsoleCommand("sbox_godmode", "0")
		RunConsoleCommand("sbox_playershurtplayers", "1")
	end
end

function GM:PlayerNoClip( pl, on )
	-- Admin check this

	if ( !on ) then return true end
	-- Allow noclip if we're in single player and living
	return IsValid( pl ) and pl:Alive() and pl:IsAdmin()
end

CreateConVar( "tdm_spawn", 0, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Allow sandbox spawning.", 0, 1 )
CreateConVar( "tdm_deathcam", 5, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Deathcam." )

CreateConVar( "tdm_regen_enabled", 1, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Health regen", 0, 1 )
CreateConVar( "tdm_regen_speed", (100/8), FCVAR_ARCHIVE + FCVAR_REPLICATED, "How much to regenerate in a second" )
CreateConVar( "tdm_regen_delay", 5, FCVAR_ARCHIVE + FCVAR_REPLICATED, "How long it takes to start regenerating" )

CreateConVar( "tdm_stamina_drain", 4, FCVAR_ARCHIVE + FCVAR_REPLICATED, "How long it takes to drain stamina" )
CreateConVar( "tdm_stamina_gain", 3, FCVAR_ARCHIVE + FCVAR_REPLICATED, "How long it takes to regain stamina" )
CreateConVar( "tdm_stamina_wain", 1, FCVAR_ARCHIVE + FCVAR_REPLICATED, "How long it takes to start recharging" )
CreateConVar( "tdm_jump_gain", 0.5, FCVAR_ARCHIVE + FCVAR_REPLICATED, "How long it takes to get full jump" )
CreateConVar( "tdm_jump_power", 220, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Jump power" )

hook.Add( "PlayerCheckLimit", "ArcCWTDM_PlayerCheckLimit", function( ply, name, cur, max )
	-- This disables spawning or using anything else
	if GetConVar("tdm_spawn"):GetBool() == false then return false end
end )
hook.Add( "PlayerGiveSWEP", "BlockPlayerSWEPs", function( ply, class, swep )
	-- Check if they're based on ArcCW or ARC9 here
	if weapons.IsBasedOn( class, "arccw_base" ) or weapons.IsBasedOn( class, "arccw_base_melee" ) or weapons.IsBasedOn( class, "arccw_base_nade" ) or weapons.IsBasedOn( class, "arccw_uo_grenade_base" ) or weapons.IsBasedOn( class, "arc9_base" ) then return true end
	-- Otherwise, no
	if GetConVar("tdm_spawn"):GetBool() == false then return false end
end )

function GM:CreateTeams()
	TEAM_HECU = 1
	team.SetUp( TEAM_HECU, "HECU", Color(175, 205, 120) )
	team.SetSpawnPoint( TEAM_HECU, "info_player_counterterrorist" )

	TEAM_CMB = 2
	team.SetUp( TEAM_CMB, "CMB", Color(152, 169, 255) )
	team.SetSpawnPoint( TEAM_CMB, "info_player_terrorist" )

	team.SetSpawnPoint( TEAM_SPECTATOR, "worldspawn" )
end

concommand.Add( "tdm_setteam", function( ply, cmd, args )
	local Team = args[1] or 1
	local ee = args[2] or 1
	Entity(ee):SetTeam( Team )
	--Entity(ee):Spawn()
end )

--
-- Player calculations
--

function GM:PlayerPostThink( ply )
	--print( ply:GetAbsVelocity():Length2D() )
end

function GM:OnPlayerHitGround( ply, inWater, onFloater, speed )
	ply:SetNextJump(0)
end

function GM:StartCommand( ply, cmd )
	local time = GetConVar("tdm_jump_gain"):GetFloat() -- time to restore full jump
	ply:SetNextJump( math.Approach( ply:GetNextJump(), 1, FrameTime()/time ) )
	local tong = Lerp( ply:GetNextJump(), 0, GetConVar("tdm_jump_power"):GetFloat() )
	if tong <= 50 then tong = 0 end
	ply:SetJumpPower( tong )

	if !ply:OnGround() then
		cmd:RemoveKey(IN_DUCK)
	end

	local actio = ply:GetMoveType() != MOVETYPE_NOCLIP and ply:GetAbsVelocity():Length2D() > 0 and ply:OnGround()

	if cmd:KeyDown(IN_SPEED) and actio then
		if ply:GetStamina_Run() == 0 then cmd:RemoveKey(IN_SPEED) end
		ply:SetStamina_Jump( CurTime() + GetConVar("tdm_stamina_wain"):GetFloat() )
	end

	if ply:IsSprinting() and actio then
		ply:SetStamina_Run( math.Approach( ply:GetStamina_Run(), 0, FrameTime()/GetConVar("tdm_stamina_drain"):GetFloat() ) )
	elseif ply:GetStamina_Jump() <= CurTime() then -- it's actually just delay
		ply:SetStamina_Run( math.Approach( ply:GetStamina_Run(), 1, FrameTime()/GetConVar("tdm_stamina_gain"):GetFloat() ) )
	end
end

function GM:HandlePlayerJumping( ply, velocity )
	-- yeah
end

hook.Add( "Think", "TDM_HealthRegen", function()
	local enabled = GetConVarNumber( "tdm_regen_enabled" ) > 0
	local speed = 1 / GetConVarNumber( "tdm_regen_speed" )
	local time = FrameTime()
	
	for _, ply in pairs( player.GetAll() ) do
		if ( ply:Alive() ) then
			local health = ply:Health()
	
			if ( health < ( ply.LastHealth or 0 ) ) then
				ply.HealthRegenNext = CurTime() + GetConVarNumber( "tdm_regen_delay" )
			end
			
			if ( CurTime() > ( ply.HealthRegenNext or 0 ) && enabled ) then
				ply.HealthRegen = ( ply.HealthRegen or 0 ) + time
				if ( ply.HealthRegen >= speed ) then
					local add = math.floor( ply.HealthRegen / speed )
					ply.HealthRegen = ply.HealthRegen - ( add * speed )
					if ( health < ply:GetMaxHealth() || speed < 0 ) then
						ply:SetHealth( math.min( health + add, ply:GetMaxHealth() ) )
					end
				end
			end
			
			ply.LastHealth = ply:Health()
		end
	end
end)


if SERVER then
	util.AddNetworkString("BEEP!")
else
	net.Receive("BEEP!", function(len, pl)
		EmitSound( net.ReadBool() and "tdm/respawn.wav" or "tdm/countdown.wav", vector_origin, -1, CHAN_AUTO, 1, 75, 0, 100, 0 )
	end)
end

local function se(p)
	p.DeathTime2 = CurTime()
	p.doob = {
		[3] = true,
		[2] = true,
		[1] = true,
		[0] = true,
	}
end

hook.Add("PlayerDeath", "BEEP!_PlayerDeath", function( p )
	se(p)
end)

hook.Add("PlayerDeathThink", "BEEP!_PlayerDeathThink", function( pl )
	if GetConVar("tdm_deathcam"):GetBool() then
		local retime = GetConVar("tdm_deathcam"):GetFloat()
		if pl.DeathTime2 and (pl.DeathTime2+retime+0.1) <= CurTime() then
			pl:Spawn()
			return true
		else
			local wham = math.floor( ( ( pl.DeathTime2 or 0 ) - CurTime()) + (retime+1) )
			if !pl.doob then 
				pl.doob = {
					[3] = true,
					[2] = true,
					[1] = true,
					[0] = true,
				}
			end
			if pl.doob[wham] then
				net.Start("BEEP!")
					net.WriteBool(wham == 0)
				net.Send(pl)
				if pl.doob[wham] then
					if wham == 1 then
						pl:ScreenFade( SCREENFADE.OUT, Color( 0, 0, 0, 255 ), 1, 1 )
					end
				end
				pl.doob[wham] = false
			end
			return false
		end

	end



end)

if CLIENT then

	-- pain
	local pain_sobel = 5
	local strength = 0

	local lasthealth = 100

	gameevent.Listen( "player_spawn" )
	hook.Add("player_spawn", "BEEP!", function( data )
		if GetConVar("tdm_deathcam"):GetBool() and data.userid == LocalPlayer():UserID() then
			LocalPlayer():ScreenFade( SCREENFADE.IN, Color( 0, 0, 0, 255 ), 0.25, 0.06 )
			pain_sobel = 5
			strength = 0
		end
	end)

	hook.Add( "Think", "TDM_Pain", function()
		pain_sobel = math.Approach( pain_sobel, 5, FrameTime()/0.5 )
		strength = math.Approach( strength, 0, FrameTime()/3 )
		local ply = LocalPlayer()
		local health = ply:Health()

		if health < ( lasthealth or 0 ) then
			pain_sobel = Lerp( (lasthealth - health)/400, 0.5, -0.02 )
			strength = Lerp( (lasthealth - health)/200, 0, 5 )
		end

		lasthealth = ply:Health()
	end)

	local tab = {
		[ "$pp_colour_addr" ] = 0,
		[ "$pp_colour_addg" ] = 0,
		[ "$pp_colour_addb" ] = 0,
		[ "$pp_colour_brightness" ] = -0.1,
		[ "$pp_colour_contrast" ] = 1.2,
		[ "$pp_colour_colour" ] = 1,
		[ "$pp_colour_mulr" ] = 0.1,
		[ "$pp_colour_mulg" ] = 0,
		[ "$pp_colour_mulb" ] = 0
	}

	hook.Add( "RenderScreenspaceEffects", "TDM_Pain_RenderScreenspaceEffects", function()
		if pain_sobel < 5 then
			DrawSobel( pain_sobel )
		end
		if strength > 0 then
			DrawSharpen( math.sin( CurTime() * 2 ) * strength, math.sin( CurTime() * 1 ) * 10 )
		end

		local ha = LocalPlayer():Health()/LocalPlayer():GetMaxHealth()

		tab["$pp_colour_mulr"] = Lerp(ha, 0.1, 0)
		tab["$pp_colour_brightness"] = Lerp(ha, -0.1, 0)
		tab["$pp_colour_contrast"] = Lerp(ha, 1.1, 1)
		tab["$pp_colour_colour"] = Lerp(ha, 0, 1)

		DrawColorModify( tab )

	end )

	hook.Add( "GetMotionBlurValues", "GetNewMotionBlurValues", function( horizontal, vertical, forward, rotational )
		local ha = LocalPlayer():Health()/LocalPlayer():GetMaxHealth()
		if ha < 1 then
			forward = Lerp(ha, -0.05, 0)
			return horizontal, vertical, forward, rotational
		end
	end )

end


--
-- Playermodels
--

player_manager.AddValidModel( "ArcCW TDM - CMB", "models/ffcm_player/combine_pm.mdl" );
player_manager.AddValidHands( "ArcCW TDM - CMB", "models/ffcm_hands/combine_hands.mdl", 0, "0000000" )

player_manager.AddValidModel( "ArcCW TDM - HECU", "models/Yukon/HECU/HECU_01_player.mdl" );
player_manager.AddValidHands( "ArcCW TDM - HECU", "models/weapons/c_arms_hecu_a3.mdl", 6, "311" )