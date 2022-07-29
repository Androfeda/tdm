
-- HUD

local C_W = Color( 255, 255, 255, 255 )
local C_B = Color( 0, 0, 0, 127 )

function CGSS( size )
	return size * ( ScrH() / 720 )
end

local bs = 3
local bs_shadow = 1
surface.CreateFont( "CGHUD_1", {
	font = "Cascadia Mono",
	size = CGSS(72),
	weight = 0,
	blursize = bs,
} )
surface.CreateFont( "CGHUD_2", {
	font = "Bahnschrift",
	size = CGSS(48),
	weight = 0,
} )
surface.CreateFont( "CGHUD_2_Glow", {
	font = "Bahnschrift",
	size = CGSS(48),
	weight = 0,
	blursize = bs,
} )
surface.CreateFont( "CGHUD_2_Shadow", {
	font = "Bahnschrift",
	size = CGSS(48),
	weight = 0,
	blursize = bs_shadow,
} )
surface.CreateFont( "CGHUD_3", {
	font = "Bahnschrift",
	size = CGSS(36),
	weight = 0,
} )
surface.CreateFont( "CGHUD_3_Glow", {
	font = "Bahnschrift",
	size = CGSS(36),
	weight = 0,
	blursize = bs,
} )
surface.CreateFont( "CGHUD_3_Shadow", {
	font = "Bahnschrift",
	size = CGSS(36),
	weight = 0,
	blursize = bs_shadow,
} )
surface.CreateFont( "CGHUD_4", {
	font = "Bahnschrift",
	size = CGSS(24),
	weight = 0,
} )
surface.CreateFont( "CGHUD_4_Glow", {
	font = "Bahnschrift",
	size = CGSS(24),
	weight = 0,
	blursize = bs,
} )
surface.CreateFont( "CGHUD_4_Shadow", {
	font = "Bahnschrift",
	size = CGSS(24),
	weight = 0,
	blursize = bs_shadow,
} )
surface.CreateFont( "CGHUD_5", {
	font = "Bahnschrift",
	size = CGSS(18),
	weight = 0,
} )
surface.CreateFont( "CGHUD_5_Glow", {
	font = "Bahnschrift",
	size = CGSS(18),
	weight = 0,
	blursize = bs,
} )
surface.CreateFont( "CGHUD_5_Shadow", {
	font = "Bahnschrift",
	size = CGSS(18),
	weight = 0,
	blursize = bs_shadow,
} )

function CGHUD_FT( text, font, x, y, ax, ay )
	surface.SetFont(font)

	local zx, zy = surface.GetTextSize(text)

	local tx, ty = Lerp(ax, x, y - zx), Lerp(ay, y, y - zy)

	--surface.SetDrawColor( 0, 0, 0, 127)
	--surface.DrawRect(tx, ty, zx, zy)

	surface.SetTextPos(tx, ty)
	surface.DrawText(text)
end

local CLR_B = Color(0, 0, 0, 255)
local CLR_B2 = Color(0, 0, 0, 127)
local CLR_W = Color(255, 255, 255, 255)
local CLR_W2 = Color(255, 255, 255, 255)

local function qt(text, font, x, y, color, color2, t, l, glow)
	draw.SimpleText(text, font .. "_Shadow", x+CGSS(4), y+CGSS(4), color2, t, l)
	if glow then
		draw.SimpleText(text, font .. "_Glow", x, y, CLR_B, t, l)
		draw.SimpleText(text, font .. "_Glow", x, y, CLR_B, t, l)
	end
	draw.SimpleText(text, font, x, y, color, t, l)
end

hook.Add( "HUDPaint", "HUDPaint_DrawABox", function()
	local w, h = ScrW(), ScrH()
	local c = CGSS(1)


	local P		= LocalPlayer()
	local PW	= LocalPlayer():GetActiveWeapon()
	if !IsValid(PW) then PW = false end

	if IsValid(P) and P:Health() > 0 then
		CLR_W = team.GetColor(P:Team())
		CLR_W.r = (CLR_W.r * 0.25) + (255*0.75)
		CLR_W.g = (CLR_W.g * 0.25) + (255*0.75)
		CLR_W.b = (CLR_W.b * 0.25) + (255*0.75)
		qt("+ " .. P:Health(), "CGHUD_2", 0 + (c*16), h - (c*16), CLR_W, CLR_B2, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
		
		surface.SetDrawColor(CLR_B2)
		surface.DrawOutlinedRect( (c*128) + (c*4), h - (c*46) + (c*4), (c*200), (c*18), (c*4) )

		if P:Health() != 100 then
		surface.SetDrawColor(CLR_B2)
		surface.DrawRect( (c*128) + (c*4), h - (c*46) + (c*8), (c*200)*(P:Health()/P:GetMaxHealth()), (c*10) )
		end

		surface.SetDrawColor(CLR_W)
		surface.DrawOutlinedRect( (c*128), h - (c*46), (c*200), (c*18), (c*4) )

		surface.SetDrawColor(CLR_W)
		surface.DrawRect( (c*128), h - (c*46), (c*200)*(P:Health()/P:GetMaxHealth()), (c*18) )

		if PW then
			local str1 = ( PW:Clip1() .. " | " .. P:GetAmmoCount(PW:GetPrimaryAmmoType()) )
			local str2 = ( PW:Clip2() .. " | " .. P:GetAmmoCount(PW:GetSecondaryAmmoType()) )


			if PW:GetPrimaryAmmoType() == -1 and PW:Clip1() <= 0 then
				str1 = ""
			elseif PW:Clip1() == -1 then
				str1 = P:GetAmmoCount(PW:GetPrimaryAmmoType())
			elseif true or PW:GetPrimaryAmmoType() == -1 then
				str1 = PW:Clip1()
			end

			if PW:GetSecondaryAmmoType() == -1 and PW:Clip2() <= 0 then
				str2 = ""
			elseif PW:Clip2() == -1 then
				str2 = P:GetAmmoCount(PW:GetSecondaryAmmoType())
			elseif true or PW:GetSecondaryAmmoType() == -1 then
				str2 = PW:Clip2()
			end

			qt(str1, "CGHUD_2", w - (c*16), h - (c*16), CLR_W, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
			qt(str2, "CGHUD_2", w - (c*16), h - (c*16*4), CLR_W, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
		end
	end
end )

local SHOWSCORE = false

hook.Add( "ScoreboardShow", "ArcCWTDM_ScoreboardShow", function()
	SHOWSCORE = true
	return true
end )
hook.Add( "ScoreboardHide", "ArcCWTDM_ScoreboardHide", function()
	SHOWSCORE = false
	return true
end )

local tshow = { [1] = true, [2] = true }

hook.Add( "HUDDrawScoreBoard", "ArcCWTDM_HUDDrawScoreBoard", function()
	if SHOWSCORE then
		local w, h = ScrW(), ScrH()
		local c = CGSS(1)

		local ax, ay = (w/2), (h/2) - (c*196)

		surface.SetDrawColor(CLR_B2)
		local yd = 0
		qt("Score", "CGHUD_3", ax - (c*200), ay + (c*36), CLR_W2, CLR_B2, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, true)
		qt("Frags", "CGHUD_5", ax + (c*100), ay + (c*36), CLR_W2, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, true)
		qt("Deaths", "CGHUD_5", ax + (c*150), ay + (c*36), CLR_W2, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, true)
		qt("Ping", "CGHUD_5", ax + (c*200), ay + (c*36), CLR_W2, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, true)
		yd = yd + 36
		for teamnum, teamdata in SortedPairs( team.GetAllTeams() ) do
			if !tshow[teamnum] then continue end
			qt(teamdata.Name, "CGHUD_5", ax - (c*200), ay + (c*yd), teamdata.Color, CLR_B2, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, true)
			yd = yd + 26
			for i, ply in ipairs(team.GetPlayers(teamnum)) do
				qt(ply:GetName(), "CGHUD_4", ax - (c*200), ay + (c*yd), teamdata.Color, CLR_B2, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, true)
				qt(ply:Frags(), "CGHUD_5", ax + (c*100), ay + (c*yd), CLR_W2, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, true)
				qt(ply:Deaths(), "CGHUD_5", ax + (c*150), ay + (c*yd), CLR_W2, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, true)
				qt(ply:Ping(), "CGHUD_5", ax + (c*200), ay + (c*yd), CLR_W2, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, true)
				yd = yd + 24
			end
			yd = yd - 8
		end
	end
end)

local hide = {
	["CHudHealth"] = true,
	["CHudBattery"] = false,
	["CHudDamageIndicator"] = true,
	["CHudAmmo"] = true,
	["CHudSecondaryAmmo"] = true,
}

hook.Add( "HUDShouldDraw", "CG_HUDShouldDraw", function( name )
	if ( hide[ name ] ) then return false end
end )