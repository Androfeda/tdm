local CLR_B2 = Color(0, 0, 0, 127)
local CLR_W2 = Color(255, 255, 255, 255)

local SHOWSCORE = false
local dead = Material("tdm/dead.png", "smooth")
local dead_glow = Material("tdm/dead_glow.png", "smooth")

hook.Add("ScoreboardShow", "ArcCWTDM_ScoreboardShow", function()
	SHOWSCORE = true

	return true
end)

hook.Add("ScoreboardHide", "ArcCWTDM_ScoreboardHide", function()
	SHOWSCORE = false

	return true
end)

local tshow = {
	[1] = true,
	[2] = true,
	[1002] = true
}

local function utime_timeToStr( time )
	local tmp = time
	local s = tmp % 60
	tmp = math.floor( tmp / 60 )
	local m = tmp % 60
	tmp = math.floor( tmp / 60 )
	local h = tmp % 24
	tmp = math.floor( tmp / 24 )
	local d = tmp-- / 7

	if d > 0 then
		return string.format( "%id %02ih %01im", d, h, m )
	elseif h > 0 then
		return string.format( "%01ih %01im", h, m )
	else
		return string.format( "%01im", m )
	end
end


hook.Add("HUDDrawScoreBoard", "ArcCWTDM_HUDDrawScoreBoard", function()
	if SHOWSCORE then
		local plycnt = player.GetCount()

		-- line size is reduced with high player count
		local font, font2 = "CGHUD_5", "CGHUD_6"
		local add = 24
		local y_offset = 196
		if plycnt >= 64 then
			font, font2 = "CGHUD_7", "CGHUD_8"
			add = 10
			y_offset = 256
		elseif plycnt >= 32 then
			font, font2 = "CGHUD_7", "CGHUD_8"
			add = 12
			y_offset = 256
		elseif plycnt >= 16 then
			font, font2 = "CGHUD_6", "CGHUD_7"
			add = 18
		end

		local w, h = ScrW(), ScrH()
		local c = CGSS(1)
		local ax, ay = w / 2, (h / 2) - (c * y_offset)
		surface.SetDrawColor(CLR_B2)
		local yd = 0
		GAMEMODE:ShadowText(GetHostName(), "CGHUD_3", ax, ay + (c * 0), CLR_W2, CLR_B2, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, true)
		GAMEMODE:ShadowText("Team Deathmatch", "CGHUD_5", ax, ay + (c * 16), CLR_W2, CLR_B2, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, true)
		-- GAMEMODE:ShadowText("Score", "CGHUD_3", ax - (c * 200), ay + (c * 36), CLR_W2, CLR_B2, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, true)
		local utime_installed = false
		if FindMetaTable( "Player" ).GetUTimeTotalTime then
			utime_installed = true
		end
			
		if utime_installed then GAMEMODE:ShadowText("Time", "CGHUD_7", ax + (c * 80), ay + (c * 36), CLR_W2, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, true) end
		GAMEMODE:ShadowText("Earnings", "CGHUD_7", ax + (c * 140), ay + (c * 36), CLR_W2, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, true)
		GAMEMODE:ShadowText("KDR", "CGHUD_7", ax + (c * 180), ay + (c * 36), CLR_W2, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, true)
		GAMEMODE:ShadowText("Frags", "CGHUD_7", ax + (c * 220), ay + (c * 36), CLR_W2, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, true)
		GAMEMODE:ShadowText("Deaths", "CGHUD_7", ax + (c * 260), ay + (c * 36), CLR_W2, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, true)
		GAMEMODE:ShadowText("Ping", "CGHUD_7", ax + (c * 300), ay + (c * 36), CLR_W2, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, true)
		yd = yd + 36


		for teamnum, teamdata in SortedPairs(team.GetAllTeams()) do
			if not tshow[teamnum] then continue end
			if #team.GetPlayers(teamnum) == 0 then continue end

			if teamnum == 1002 then
				teamdata.Color = CLR_W2
			end

			GAMEMODE:ShadowText(teamdata.Name, "CGHUD_6", ax - (c * 300), ay + (c * yd), teamdata.Color, CLR_B2, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, true)

			surface.SetDrawColor(CLR_B2)
			surface.DrawRect(ax - (c * 300) + CGSS(2), ay + (c * yd) + CGSS(18) + CGSS(2), c * 600, CGSS(2))
			surface.SetDrawColor(teamdata.Color)
			surface.DrawRect(ax - (c * 300), ay + (c * yd) + CGSS(18), c * 600, CGSS(2))

			yd = yd + 30 + CGSS(2)

			local players = team.GetPlayers(teamnum)

			table.sort(players, function(a, b) return (math.max(a:Frags(), 0) / math.max(a:Deaths(), 1)) > (math.max(b:Frags(), 0) / math.max(b:Deaths(), 1)) end)

			for i, ply in ipairs(players) do
				GAMEMODE:ShadowText(ply:GetName(), font, ax - (c * 300), ay + (c * yd), teamdata.Color, CLR_B2, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, true)

				if !ply:Alive() then
					surface.SetMaterial(dead)
					local sz = (c * 32)
					surface.SetDrawColor(CLR_B2)
					surface.DrawTexturedRect(ax - (c * 302) - (sz * 0.75) + (c * 4), ay + (c * yd) - (sz * 0.47) + (c * 4), sz, sz)

					surface.SetMaterial(dead_glow)
					surface.SetDrawColor(CLR_B2)
					surface.DrawTexturedRect(ax - (c * 302) - (sz * 0.75), ay + (c * yd) - (sz * 0.47), sz, sz)
					surface.DrawTexturedRect(ax - (c * 302) - (sz * 0.75), ay + (c * yd) - (sz * 0.47), sz, sz)
					surface.DrawTexturedRect(ax - (c * 302) - (sz * 0.75), ay + (c * yd) - (sz * 0.47), sz, sz)

					surface.SetMaterial(dead)
					surface.SetDrawColor(teamdata.Color)
					surface.DrawTexturedRect(ax - (c * 302) - (sz * 0.75), ay + (c * yd) - (sz * 0.47), sz, sz)
				end

				if teamnum ~= 1002 then
					if utime_installed then GAMEMODE:ShadowText(utime_timeToStr( ply:GetUTimeTotalTime() ), font2, ax + (c * 80), ay + (c * yd), CLR_W2, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, true) end
					GAMEMODE:ShadowText(GAMEMODE:FormatMoney(ply:GetEarnings()), font2, ax + (c * 140), ay + (c * yd), CLR_W2, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, true)
					-- k/d
					local kd = math.max(ply:Frags(), 0) / math.max(ply:Deaths(), 1)
					--if ply:Deaths() < ply:Frags() then
					--	kd = ply:Frags()
					--else
					--	kd = math.Round(kd, 2)
					--end
					GAMEMODE:ShadowText(string.format("%f", kd):Left(4), font2, ax + (c * 180), ay + (c * yd), CLR_W2, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, true)
					GAMEMODE:ShadowText(ply:Frags(), font2, ax + (c * 220), ay + (c * yd), CLR_W2, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, true)
					GAMEMODE:ShadowText(ply:Deaths(), font2, ax + (c * 260), ay + (c * yd), CLR_W2, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, true)
					GAMEMODE:ShadowText(ply:Ping(), font2, ax + (c * 300), ay + (c * yd), CLR_W2, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, true)
				end

				yd = yd + add
			end

			yd = yd
		end
	end
end)
