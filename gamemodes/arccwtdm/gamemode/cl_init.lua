
-- Clientside initialization

include( "shared.lua" )
include( "client/hud.lua" )

function GM:ContextMenuOpen()
	return GetConVar("tdm_spawn"):GetBool()
end

hook.Add( "SpawnMenuEnabled", "TDM_SpawnMenuEnabled", function()
	if !GetConVar("tdm_spawn"):GetBool() then
		spawnmenu.GetCreationTabs()["#spawnmenu.category.dupes"] = nil
		spawnmenu.GetCreationTabs()["#spawnmenu.category.saves"] = nil
		spawnmenu.GetCreationTabs()["#spawnmenu.category.npcs"] = nil
		spawnmenu.GetCreationTabs()["#spawnmenu.category.vehicles"] = nil
		spawnmenu.GetCreationTabs()["#spawnmenu.content_tab"] = nil
	end
end)

local timelastlived = CurTime()
local lasteyes = vector_origin
local lasteyesa = angle_zero
local deead = lasteyes
local rgel = vector_origin
hook.Add( "CalcView", "GH3_DeadCam", function( ply, pos, angles, fov )
	if GetConVar("tdm_deathcam"):GetBool() then
		if !ply:Alive() then
			local view = {
				origin = pos,--pos - ( angles:Forward() * 100 ),
				angles = angles,
				fov = fov,
				drawviewer = true
			}

			if IsValid(ply:GetRagdollEntity()) then
				local rge = ply:GetRagdollEntity()
				rgel = rge:GetPos() + rge:OBBCenter()
			end

			local heuh = ( ( CurTime() - timelastlived ) )
			local hooh = math.min(math.Remap(heuh, 0, 6, 0, 1), 1)

			local tr = util.TraceLine( {
				start = rgel,
				endpos = rgel + view.angles:Forward() * ( -1 * Lerp( hooh, 24, 128 ) ) + LerpVector( hooh, vector_origin, Vector(0, 0, 32) ),
				filter = {ply, ply:GetRagdollEntity()},
			} )

			view.origin = LerpVector( math.pow(math.sin(hooh*math.pi*0.5), 4), deead or vector_origin, tr.HitPos )
			deead = LerpVector( FrameTime()*2, deead, tr.HitPos )
			view.fov = fov + Lerp( math.pow(math.sin(hooh*math.pi*0.5), 4), 0, -30 )

			return view
		else
			timelastlived = CurTime()
			local eyes = ply:GetAttachment(ply:LookupAttachment("eyes"))
			if eyes then
				lasteyes = eyes.Pos--LocalPlayer():EyePos()
				lasteyesa = eyes.Ang--LocalPlayer():EyeAngles()
				deead = lasteyes
			end
		end
	end
end )

--[[
#spawnmenu.category.dupes
#spawnmenu.category.entities
#spawnmenu.category.npcs
#spawnmenu.category.postprocess
#spawnmenu.category.saves
#spawnmenu.category.vehicles
#spawnmenu.category.weapons
#spawnmenu.content_tab
]]