
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

local CLR_R = Color(255, 200, 200, 255)
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

local am_pi = Material("tdm/pistol.png", "smooth")
local am_ri = Material("tdm/rifle.png", "smooth")
local am_sg = Material("tdm/shotgun.png", "smooth")
local am_gr = Material("tdm/grenade.png", "smooth")
local am_fr = Material("tdm/frag.png", "smooth")

local toop = {
	["rifle"] = {
		Texture = am_ri,
		gap_hor = 8,
		gap_ver = 32,
		rep = 31,
		size = 32,
	},
	["pistol"] = {
		Texture = am_pi,
		gap_hor = 12,
		gap_ver = 32,
		rep = 20,
		size = 32,
	},
	["shotgun"] = {
		Texture = am_sg,
		gap_hor = 12,
		gap_ver = 32,
		rep = 13,
		size = 32,
	},
	["grenade"] = {
		Texture = am_gr,
		gap_hor = 64,
		gap_ver = 32,
		rep = 30,
		size = 32,
	},
	["frag"] = {
		Texture = am_fr,
		gap_hor = 64,
		gap_ver = 32,
		rep = 30,
		size = 32,
	},
}
local refer = {
	["AR2"] = toop.rifle,
	["SMG1"] = toop.rifle,
	["SniperPenetratedRound"] = toop.rifle,
	["SniperRound"] = toop.rifle,
	["Pistol"] = toop.pistol,
	["357"] = toop.pistol,
	["Buckshot"] = toop.shotgun,
	["Grenade"] = toop.frag,
	["SMG1_Grenade"] = toop.grenade,
}

hook.Add( "HUDPaint", "HUDPaint_DrawABox", function()
	local w, h = ScrW(), ScrH()
	local c = CGSS(1)


	local P		= LocalPlayer()
	local PW	= LocalPlayer():GetActiveWeapon()
	if !IsValid(PW) then PW = false end

	if IsValid(P) and P:Health() > 0 then
		CLR_W = team.GetColor(P:Team())
		CLR_W.r = (CLR_W.r * 0.5) + (255*0.5)
		CLR_W.g = (CLR_W.g * 0.5) + (255*0.5)
		CLR_W.b = (CLR_W.b * 0.5) + (255*0.5)
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


		-- stamina

		if P.GetStamina_Run and P:GetStamina_Run() < 1 then
			surface.SetDrawColor(CLR_B2)
			surface.DrawRect( (c*128) + (c*4), h - (c*46) + (c*22) + (c*4), (c*200), (c*4) )
			surface.SetDrawColor(CLR_W)
			surface.DrawRect( (c*128), h - (c*46) + (c*22), (c*200)*(P:GetStamina_Run()/1), (c*4) )
		end

		if P.GetNextJump and P:GetNextJump() < 1 then
			surface.SetDrawColor(CLR_B2)
			surface.DrawRect( (c*128) + (c*4), h - (c*46) - (c*8) + (c*4), (c*200), (c*4) )
			surface.SetDrawColor(CLR_W)
			surface.DrawRect( (c*128), h - (c*46) - (c*8), (c*200)*(P:GetNextJump()), (c*4) )
		end

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


			local si = 32
			local lg = 8 -- lr distance
			local hg = 34 -- ud distance
			local rep = 30 -- repeating

			local dat = refer[game.GetAmmoName( PW:GetPrimaryAmmoType() )] or toop.frag
			if dat then
				si = dat.size
				rep = dat.rep
				lg = dat.gap_hor
				hg = dat.gap_ver
				surface.SetMaterial(dat.Texture)
			end

			local ind = 0
			if PW.GetFiremodeName then
				qt(PW:GetFiremodeName(), "CGHUD_4", w - (c*28), h - (c*16) - (c*ind), CLR_W, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
				ind = ind + 26
			end

			local ax, ay = (w) - (c*16) - (c*si), (h) - (c*16) - (c*si) - (c*ind)

			local li = 0 -- leftright
			local hi = 0 -- updown
			for i=1, math.max(PW:GetMaxClip1(), PW:Clip1()) do
				surface.SetDrawColor(CLR_B2)
				surface.DrawTexturedRect(ax - (c*li*lg) + (c*4), ay - (c*hi*hg) + (c*4), (c*si), (c*si))
				if i != math.max(PW:GetMaxClip1(), PW:Clip1()) and (i % rep == 0) then
					hi = hi + 1
					li = -1
				end
				li = li + 1
			end

			do
				local si = 32
				local lg = 8
				local hg = 34
				local rep = 30

				local dat = refer[game.GetAmmoName( PW:GetSecondaryAmmoType() )] or toop.pistol
				if dat then
					si = dat.size
					rep = dat.rep
					lg = dat.gap_hor
					hg = dat.gap_ver
					surface.SetMaterial(dat.Texture)
				end

				local li = 0
				local hi = hi + 1
				for i=1, math.max(PW:GetMaxClip2(), PW:Clip2()) do
					surface.SetDrawColor(CLR_B2)
					surface.DrawTexturedRect(ax - (c*li*lg) + (c*4), ay - (c*hi*hg) + (c*4), (c*si), (c*si))
					if i % rep == 0 then
						hi = hi + 1
						li = -1
					end
					li = li + 1
				end
				li = 0
				for i=1, PW:Clip2() do
					if (PW:Clip2()-i) >= PW:GetMaxClip2() then
						surface.SetDrawColor(CLR_R)
					elseif (PW:Clip2()-i) % 2 == 0 then 
						surface.SetDrawColor(CLR_W)
					else
						surface.SetDrawColor(CLR_W2)
					end
					surface.DrawTexturedRect(ax - (c*li*lg), ay - (c*hi*hg), (c*si), (c*si))
					if i % rep == 0 then
						hi = hi + 1
						li = -1
					end
					li = li + 1
				end
			end
			
			surface.SetMaterial(dat.Texture)
			li = 0
			hi = 0
			for i=1, PW:Clip1() do
				if (PW:Clip1()-i) >= PW:GetMaxClip1() then
					surface.SetDrawColor(CLR_R)
				elseif (PW:Clip1()-i) % 2 == 0 then 
					surface.SetDrawColor(CLR_W)
				else
					surface.SetDrawColor(CLR_W2)
				end
				surface.DrawTexturedRect(ax - (c*li*lg), ay - (c*hi*hg), (c*si), (c*si))
				if i % rep == 0 then
					hi = hi + 1
					li = -1
				end
				li = li + 1
			end

--			local ind = 0
--			if str1 != "" then
--				qt("Ammo", "CGHUD_5", w - (c*16), h - (c*16) - (c*ind), CLR_W, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
--				ind = ind + 12
--				qt(str1, "CGHUD_2", w - (c*16), h - (c*16) - (c*ind), CLR_W, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
--				ind = ind + 44
--			end
--			if str2 != "" then
--				qt("Secondary", "CGHUD_5", w - (c*16), h - (c*16) - (c*ind), CLR_W, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
--				ind = ind + 12
--				qt(str2, "CGHUD_2", w - (c*16), h - (c*16) - (c*ind), CLR_W, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
--				ind = ind + 44
--			end
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

local tshow = { [1] = true, [2] = true, [1002] = true }

hook.Add( "HUDDrawScoreBoard", "ArcCWTDM_HUDDrawScoreBoard", function()
	if SHOWSCORE then
		local w, h = ScrW(), ScrH()
		local c = CGSS(1)

		local ax, ay = (w/2), (h/2) - (c*196)

		surface.SetDrawColor(CLR_B2)
		local yd = 0
		qt(GetHostName(), "CGHUD_3", ax, ay + (c*4), CLR_W2, CLR_B2, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, true)
		qt("Score", "CGHUD_3", ax - (c*200), ay + (c*36), CLR_W2, CLR_B2, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, true)
		qt("K/D", "CGHUD_5", ax + (c*50), ay + (c*36), CLR_W2, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, true)
		qt("Frags", "CGHUD_5", ax + (c*100), ay + (c*36), CLR_W2, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, true)
		qt("Deaths", "CGHUD_5", ax + (c*150), ay + (c*36), CLR_W2, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, true)
		qt("Ping", "CGHUD_5", ax + (c*200), ay + (c*36), CLR_W2, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, true)
		yd = yd + 36
		for teamnum, teamdata in SortedPairs( team.GetAllTeams() ) do
			if !tshow[teamnum] then continue end
			if #team.GetPlayers(teamnum) == 0 then continue end
			if teamnum == 1002 then
				teamdata.Color = CLR_W2
			end
			qt(teamdata.Name, "CGHUD_5", ax - (c*200), ay + (c*yd), teamdata.Color, CLR_B2, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, true)
			yd = yd + 26
			for i, ply in ipairs(team.GetPlayers(teamnum)) do
				qt(ply:GetName(), "CGHUD_4", ax - (c*200), ay + (c*yd), teamdata.Color, CLR_B2, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, true)

				if teamnum != 1002 then
					do -- k/d
						local kd = math.max(ply:Frags(), 1) / math.max(ply:Deaths(), 1)
						
						qt(kd, "CGHUD_5", ax + (c*50), ay + (c*yd), CLR_W2, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, true)
					end

					qt(ply:Frags(), "CGHUD_5", ax + (c*100), ay + (c*yd), CLR_W2, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, true)
					qt(ply:Deaths(), "CGHUD_5", ax + (c*150), ay + (c*yd), CLR_W2, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, true)
					qt(ply:Ping(), "CGHUD_5", ax + (c*200), ay + (c*yd), CLR_W2, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, true)
				end
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