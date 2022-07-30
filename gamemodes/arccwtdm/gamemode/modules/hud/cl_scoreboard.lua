local CLR_B2 = Color(0, 0, 0, 127)
local CLR_W2 = Color(255, 255, 255, 255)

local SHOWSCORE = false

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

hook.Add("HUDDrawScoreBoard", "ArcCWTDM_HUDDrawScoreBoard", function()
	if SHOWSCORE then
		local w, h = ScrW(), ScrH()
		local c = CGSS(1)
		local ax, ay = w / 2, (h / 2) - (c * 196)
		surface.SetDrawColor(CLR_B2)
		local yd = 0
		GAMEMODE:ShadowText(GetHostName(), "CGHUD_3", ax, ay + (c * 4), CLR_W2, CLR_B2, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, true)
		-- GAMEMODE:ShadowText("Score", "CGHUD_3", ax - (c * 200), ay + (c * 36), CLR_W2, CLR_B2, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, true)
		GAMEMODE:ShadowText("K/D", "CGHUD_5", ax + (c * 50), ay + (c * 36), CLR_W2, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, true)
		GAMEMODE:ShadowText("Frags", "CGHUD_5", ax + (c * 100), ay + (c * 36), CLR_W2, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, true)
		GAMEMODE:ShadowText("Deaths", "CGHUD_5", ax + (c * 150), ay + (c * 36), CLR_W2, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, true)
		GAMEMODE:ShadowText("Ping", "CGHUD_5", ax + (c * 200), ay + (c * 36), CLR_W2, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, true)
		yd = yd + 36

		for teamnum, teamdata in SortedPairs(team.GetAllTeams()) do
			if not tshow[teamnum] then continue end
			if #team.GetPlayers(teamnum) == 0 then continue end

			if teamnum == 1002 then
				teamdata.Color = CLR_W2
			end

			GAMEMODE:ShadowText(teamdata.Name, "CGHUD_5", ax - (c * 200), ay + (c * yd), teamdata.Color, CLR_B2, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, true)

			surface.SetDrawColor(CLR_B2)
			surface.DrawRect(ax - (c * 200) + CGSS(2), ay + (c * yd) + CGSS(18) + CGSS(2), c * 400, CGSS(2))
			surface.SetDrawColor(teamdata.Color)
			surface.DrawRect(ax - (c * 200), ay + (c * yd) + CGSS(18), c * 400, CGSS(2))

			yd = yd + 30 + CGSS(2)

			for i, ply in ipairs(team.GetPlayers(teamnum)) do
				GAMEMODE:ShadowText(ply:GetName(), "CGHUD_4", ax - (c * 200), ay + (c * yd), teamdata.Color, CLR_B2, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, true)

				if teamnum ~= 1002 then
					-- k/d
					local kd = ply:Frags() / ply:Deaths()
					if ply:Deaths() == 0 then
						kd = ""
					else
						kd = math.Round(kd, 2)
					end
					GAMEMODE:ShadowText(kd, "CGHUD_5", ax + (c * 50), ay + (c * yd), CLR_W2, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, true)

					GAMEMODE:ShadowText(ply:Frags(), "CGHUD_5", ax + (c * 100), ay + (c * yd), CLR_W2, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, true)
					GAMEMODE:ShadowText(ply:Deaths(), "CGHUD_5", ax + (c * 150), ay + (c * yd), CLR_W2, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, true)
					GAMEMODE:ShadowText(ply:Ping(), "CGHUD_5", ax + (c * 200), ay + (c * yd), CLR_W2, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, true)
				end

				yd = yd + 24
			end

			yd = yd - 8
		end
	end
end)
