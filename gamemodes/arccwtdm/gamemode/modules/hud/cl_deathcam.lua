local timelastlived = CurTime()
local lasteyes = vector_origin
local lasteyesa = angle_zero
local deead = lasteyes
local rgel = vector_origin

hook.Add("CalcView", "GH3_DeadCam", function(ply, pos, angles, fov)
	if GetConVar("tdm_deathcam"):GetBool() then
		if not ply:Alive() then
			local view = {
				origin = pos, --pos - ( angles:Forward() * 100 ),
				angles = angles,
				fov = fov,
				drawviewer = true
			}

			if IsValid(ply:GetRagdollEntity()) then
				local rge = ply:GetRagdollEntity()
				rgel = rge:GetPos() + rge:OBBCenter()
			end

			local heuh = CurTime() - timelastlived
			local hooh = math.min(math.Remap(heuh, 0, 6, 0, 1), 1)

			local tr = util.TraceLine({
				start = rgel,
				endpos = rgel + view.angles:Forward() * (-1 * Lerp(hooh, 24, 128)) + LerpVector(hooh, vector_origin, Vector(0, 0, 32)),
				filter = {ply, ply:GetRagdollEntity()},
			})

			view.origin = LerpVector(math.pow(math.sin(hooh * math.pi * 0.5), 4), deead or vector_origin, tr.HitPos)
			deead = LerpVector(FrameTime() * 2, deead, tr.HitPos)
			view.fov = fov + Lerp(math.pow(math.sin(hooh * math.pi * 0.5), 4), 0, -30)

			return view
		else
			timelastlived = CurTime()
			local eyes = ply:GetAttachment(ply:LookupAttachment("eyes"))

			if eyes then
				lasteyes = eyes.Pos --LocalPlayer():EyePos()
				lasteyesa = eyes.Ang --LocalPlayer():EyeAngles()
				deead = lasteyes
			end
		end
	end
end)

-- pain
local pain_sobel = 5
local strength = 0
local lasthealth = 100
gameevent.Listen("player_spawn")

hook.Add("player_spawn", "BEEP!", function(data)
	if GetConVar("tdm_deathcam"):GetBool() and data.userid == LocalPlayer():UserID() then
		LocalPlayer():ScreenFade(SCREENFADE.IN, Color(0, 0, 0, 255), 0.25, 0.06)
		pain_sobel = 5
		strength = 0
	end
end)

hook.Add("Think", "TDM_Pain", function()
	pain_sobel = math.Approach(pain_sobel, 5, FrameTime() / 3)
	strength = math.Approach(strength, 0, FrameTime() / 0.75)
	local ply = LocalPlayer()
	local health = ply:Health()

	if health < (lasthealth or 0) then
		pain_sobel = Lerp((lasthealth - health) / 100, 0.2, 0)
		strength = Lerp((lasthealth - health) / 100, 0, 3)
	end

	lasthealth = ply:Health()
end)

local tab = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = -0.1,
	["$pp_colour_contrast"] = 1.2,
	["$pp_colour_colour"] = 1,
	["$pp_colour_mulr"] = 0.1,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}

hook.Add("RenderScreenspaceEffects", "TDM_Pain_RenderScreenspaceEffects", function()
	if pain_sobel < 5 then
		DrawSobel(pain_sobel)
	end

	if strength > 0 then
		DrawSharpen(math.sin(CurTime() * 2) * strength, math.sin(CurTime() * 1) * 10 * strength)
	end

	local ha = LocalPlayer():Health() / LocalPlayer():GetMaxHealth()
	tab["$pp_colour_mulr"] = Lerp(ha, 0.1, 0)
	tab["$pp_colour_brightness"] = Lerp(ha, -0.1, 0)
	tab["$pp_colour_contrast"] = Lerp(ha, 1.1, 1)
	tab["$pp_colour_colour"] = Lerp(ha, 0, 1)
	DrawColorModify(tab)
end)

hook.Add("GetMotionBlurValues", "GetNewMotionBlurValues", function(horizontal, vertical, forward, rotational)
	local ha = LocalPlayer():Health() / LocalPlayer():GetMaxHealth()

	if ha < 1 then
		forward = Lerp(ha, -0.05, 0)

		return horizontal, vertical, forward, rotational
	end
end)