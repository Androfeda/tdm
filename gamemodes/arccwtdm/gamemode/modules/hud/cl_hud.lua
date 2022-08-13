-- HUD
local C_W = Color(255, 255, 255, 255)
local C_B = Color(0, 0, 0, 127)

function CGHUD_FT(text, font, x, y, ax, ay)
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
local CLR_B2 = Color(0, 0, 0, 100)
local CLR_W = Color(255, 255, 255, 255)
local CLR_W2 = Color(255, 255, 255, 255)
local CLR_R2 = Color(255, 150, 150, 150)

local CLR_FUEL = Color(255, 255, 150, 255)

local veh = Material("tdm/vehiclehealth.png", "smooth")
local spawnpro = Material("tdm/spawnpro.png", "smooth")
local am_pi = Material("tdm/pistol.png", "smooth")
local am_ri = Material("tdm/rifle.png", "smooth")
local am_sg = Material("tdm/shotgun.png", "smooth")
local am_gr = Material("tdm/grenade.png", "smooth")
local am_fr = Material("tdm/frag.png", "smooth")
local am_he = Material("tdm/flame.png", "smooth")
local am_ms = Material("tdm/missile.png", "smooth")
local am_cn = Material("tdm/cannon.png", "smooth")

local diamond = Material("tdm/diamond.png", "smooth")
local skull = Material("tdm/skull.png", "smooth")

local money_updates = {}
local money_last_t = 0

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
		rep = 22,
		size = 32,
	},
	["plinking"] = {
		Texture = am_pi,
		gap_hor = 12,
		gap_ver = 32,
		rep = 22,
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
		gap_hor = 12,
		gap_ver = 32,
		rep = 30,
		size = 32,
	},
	["frag"] = {
		Texture = am_fr,
		gap_hor = 12,
		gap_ver = 32,
		rep = 30,
		size = 32,
	},

	-- vehicles
	["missile"] = {
		Texture = am_ms,
		gap_hor = 14,
		gap_ver = 32,
		rep = 5,
		size = 32,
	},
	["cannon"] = {
		Texture = am_cn,
		gap_hor = 8,
		gap_ver = 32,
		rep = 40,
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

local HUToM = 0.0254

local wtfsimfphys = 0

hook.Add("HUDPaint", "HUDPaint_DrawABox", function()
	local w, h = ScrW(), ScrH()
	local c = CGSS(1)
	local P = LocalPlayer()
	local PW = LocalPlayer():GetActiveWeapon()

	if not IsValid(PW) then
		PW = false
	end

	local VW = false
	if IsValid(LocalPlayer():GetVehicle()) and LocalPlayer().GetSimfphys then
		VW = LocalPlayer():GetSimfphys()
	end

	if IsValid(P) then
		if P:Alive() and (P:Health() / P:GetMaxHealth()) > 0 then
			CLR_W = team.GetColor(P:Team())
			CLR_W.r = (CLR_W.r * 0.5) + (255 * 0.5)
			CLR_W.g = (CLR_W.g * 0.5) + (255 * 0.5)
			CLR_W.b = (CLR_W.b * 0.5) + (255 * 0.5)
			GAMEMODE:ShadowText("+ " .. P:Health(), "CGHUD_2", 0 + (c * 16), h - (c * 16), CLR_W, CLR_B2, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)

			-- Maybe you could use this type of display for capture points, flags and the like?
			if LocalPlayer():GetSpawnArea() == LocalPlayer():Team() then
				surface.SetMaterial(spawnpro)
				local size = (c * 96)
				surface.SetDrawColor(CLR_B2)
				surface.DrawTexturedRect( (ScrW() / 2) - (size / 2) + (c * 4), (h * 0.15) - (size / 2) + (c * 4), size, size )
				surface.SetDrawColor(CLR_W)
				surface.DrawTexturedRect( (ScrW() / 2) - (size / 2), (h * 0.15) - (size / 2), size, size )
				GAMEMODE:ShadowText("Spawn Protection", "CGHUD_6", w / 2, (h * 0.15) + (size / 2) + (c * 12), CLR_W, CLR_B2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

			surface.SetDrawColor(CLR_B2)
			surface.DrawOutlinedRect((c * 128) + (c * 4), h - (c * 46) + (c * 4), c * 200, c * 18, c * 4)

			if (P:Health() / P:GetMaxHealth()) != 1 then
				surface.SetDrawColor(CLR_B2)
				surface.DrawRect((c * 128) + (c * 4), h - (c * 46) + (c * 8), (c * 200) * (P:Health() / P:GetMaxHealth()), c * 10)
			end

			surface.SetDrawColor(CLR_W)
			surface.DrawOutlinedRect(c * 128, h - (c * 46), c * 200, c * 18, c * 4)
			surface.SetDrawColor(CLR_W)
			surface.DrawRect(c * 128, h - (c * 46), (c * 200) * (P:Health() / P:GetMaxHealth()), c * 18)

			if VW then
				GAMEMODE:ShadowText("   " .. math.Round((VW:GetCurHealth() / VW:GetMaxHealth())*100), "CGHUD_2", (c * 16), (c * 48) + (c * 16), CLR_W, CLR_B2, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
				surface.SetMaterial(veh)
				surface.SetDrawColor(CLR_B2)
				surface.DrawTexturedRect( (c * 14) + (c * 4), (c * 29) + (c * 4), (c * 26), (c * 26) ) -- wrench
				surface.DrawOutlinedRect((c * 128) + (c * 4), (c * 36) + (c * 4), c * 200, c * 18, c * 4)

				if (VW:GetCurHealth() / VW:GetMaxHealth()) != 1 then
					surface.SetDrawColor(CLR_B2)
					surface.DrawRect((c * 128) + (c * 4), (c * 36) + (c * 8), (c * 200) * (VW:GetCurHealth() / VW:GetMaxHealth()), c * 10)
				end

				surface.SetDrawColor(CLR_W)
				surface.DrawTexturedRect( (c * 14), (c * 29), (c * 26), (c * 26) ) -- wrench
				surface.DrawOutlinedRect(c * 128, (c * 36), c * 200, c * 18, c * 4)
				surface.SetDrawColor(CLR_W)
				surface.DrawRect(c * 128, (c * 36), (c * 200) * (VW:GetCurHealth() / VW:GetMaxHealth()), c * 18)

				GAMEMODE:ShadowText( math.Round( VW:GetVelocity():Length() * HUToM / 0.277778 ) .. "km/h", "CGHUD_2", (c * 16), (c * 48) + (c * 16) + (c * 48), CLR_W, CLR_B2, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
				GAMEMODE:ShadowText( math.Round( VW:GetVelocity():Length() ) .. "hU", "CGHUD_4", (c * 16), (c * 48) + (c * 16) + (c * 48) + (c * 24), CLR_W, CLR_B2, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)

				-- Fuel
				-- GAMEMODE:ShadowText( math.Round( (VW:GetFuel() / VW:GetMaxFuel())*100 ) .. "%", "CGHUD_7", (c * 128), (c * 36) - (c * 10), CLR_FUEL, CLR_B2, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
				surface.SetDrawColor(CLR_B2)
				surface.DrawRect((c * 128) + (c * 4), (c * 36) - (c * 8) + (c * 4), (c * 200) * (VW:GetFuel() / VW:GetMaxFuel()), c * 4)
				surface.SetDrawColor(CLR_FUEL)
				surface.DrawRect(c * 128, (c * 36) - (c * 8), (c * 200) * (VW:GetFuel() / VW:GetMaxFuel()), c * 4)
			end

			-- stamina
			if P.GetStamina_Run and P:GetStamina_Run() < 1 then
				surface.SetDrawColor(CLR_B2)
				surface.DrawRect((c * 128) + (c * 4), h - (c * 46) + (c * 22) + (c * 4), c * 200, c * 4)
				surface.SetDrawColor(CLR_W)
				surface.DrawRect(c * 128, h - (c * 46) + (c * 22), (c * 200) * (P:GetStamina_Run() / 1), c * 4)
			end

			local iClip1
			local iClip2
			local iMaxClip1
			local iMaxClip2
			local iAmmoType1
			local iAmmoType2
			local iAmmoCount1
			local iAmmoCount2
			local iFiremode

			if VW then
				iClip1		= VW:GetNWInt( "CurWPNAmmo", -1 )
				iClip2		= VW:GetNWInt( "CurWPNAmmo2", -1 )
				-- wtfsimfphys = math.max( wtfsimfphys, VW:GetNWInt( "CurWPNAmmo", -1 ) )
				iMaxClip1	= VW:GetNWInt( "MaxWPNAmmo", 0 ) -- wtfsimfphys
				iMaxClip2	= VW:GetNWInt( "MaxWPNAmmo2", -1 )
				iAmmoType1	= 13
				iAmmoType2	= 13
				iAmmoCount1	= 13
				iAmmoCount2	= 13
				iFiremode = VW:GetNWString( "WeaponMode" )
				iAmmoIcon1 = VW:GetNWString( "WPNType", "rifle" )
				iAmmoIcon2 = VW:GetNWString( "WPNType2", "rifle" )
			elseif PW then
				iClip1		= PW:Clip1()
				iClip2		= PW:Clip2()
				iMaxClip1	= PW:GetMaxClip1()
				iMaxClip2	= PW:GetMaxClip2()
				iAmmoType1	= PW:GetPrimaryAmmoType()
				iAmmoType2	= PW:GetSecondaryAmmoType()
				iAmmoCount1	= P:GetAmmoCount(iAmmoType1)
				iAmmoCount2	= P:GetAmmoCount(iAmmoType2)
				if PW.GetFiremodeName then
					iFiremode = PW:GetFiremodeName()
				--else
				--	iFiremode = "Not Vehicle"
				end
			end

			if !VW then
				wtfsimfphys = 0
			end

			if PW or VW then
				local si = 32
				local lg = 8 -- lr distance
				local hg = 34 -- ud distance
				local rep = 30 -- repeating
				local dat = (VW and toop[iAmmoIcon1 or ""]) or refer[game.GetAmmoName(iAmmoType1)] or toop.frag

				if dat then
					si = dat.size
					rep = dat.rep
					lg = dat.gap_hor
					hg = dat.gap_ver
					surface.SetMaterial(dat.Texture)
				end

				local ind = 0

				if iFiremode then
					surface.SetFont("CGHUD_5")
					GAMEMODE:ShadowText(iFiremode, "CGHUD_5", w - (c * 28), h - (c * 16) - (c * ind), CLR_W, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
					ind = ind + 26
				end

				local ax, ay = w - (c * 16) - (c * si), h - (c * 16) - (c * si) - (c * ind)
				local li = 0 -- leftright
				local hi = 0 -- updown

				for i = 1, math.max(iMaxClip1, iClip1) do
					surface.SetDrawColor(CLR_B2)
					surface.DrawTexturedRect(ax - (c * li * lg) + (c * 4), ay - (c * hi * hg) + (c * 4), c * si, c * si)

					if i ~= math.max(iMaxClip1, iClip1) and (i % rep == 0) then
						hi = hi + 1
						li = -1
					end

					li = li + 1
				end
				if not GAMEMODE:WeaponHasInfiniteAmmo(PW) then
					GAMEMODE:ShadowText(iAmmoCount1, "CGHUD_5", ax + (c * 1) - (c * li * lg), h - (c * 44) - (c * hi * hg), CLR_W, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
					GAMEMODE:ShadowText("+", "CGHUD_5", ax + (c * 15) - (c * li * lg), h - (c * 44) - (c * hi * hg), CLR_W, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
				end

				do
					li = 0
					if PW.HeatEnabled and PW:HeatEnabled() then
						hi = hi + 0.5
						local f = (PW:GetHeat() / PW:GetMaxHeat())
						surface.SetMaterial(am_he)

						surface.SetDrawColor(CLR_B2)
						surface.DrawTexturedRect(w - (c * 72) + (c * 4), h - (c * 108) - (c * hi * hg) + (c * 4), c * 48, c * 48)

						surface.SetDrawColor(255, 200 - 150 * f ^ 2, 200 - 150 * f ^ 2, 255)
						surface.DrawTexturedRectUV(w - (c * 72), h - (c * 108) - (c * hi * hg) + (c * 48 * (1-f)), c * 48, c * 48 * f, 0, 1 - f, 1, 1)
						hi = hi + 1.1
					end

					local si = 32
					local lg = 8
					local hg = 34
					local rep = 30
					local dat = (VW and toop[iAmmoIcon2]) or refer[game.GetAmmoName(iAmmoType2)] or toop.pistol

					if dat then
						si = dat.size
						rep = dat.rep
						lg = dat.gap_hor
						hg = dat.gap_ver
						surface.SetMaterial(dat.Texture)
					end

					local li = 0
					local hi = hi + 1

					for i = 1, math.max(iMaxClip2, iClip2) do
						surface.SetDrawColor(CLR_B2)
						surface.DrawTexturedRect(ax - (c * li * lg) + (c * 4), ay - (c * hi * hg) + (c * 4), c * si, c * si)

						if i ~= math.max(iMaxClip2, iClip2) and i % rep == 0 then
							hi = hi + 1
							li = -1
						end

						li = li + 1
					end
					if iMaxClip2 > 0 and iAmmoType2 != -1 and GAMEMODE.AmmoBlacklist[string.lower(game.GetAmmoName(iAmmoType2))] then
						GAMEMODE:ShadowText(iAmmoCount2, "CGHUD_5", ax + (c * 1) - (c * li * lg), h - (c * hi * hg) - (c * 44), CLR_W, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
						GAMEMODE:ShadowText("+", "CGHUD_5", ax + (c * 15) - (c * li * lg), h - (c * hi * hg) - (c * 44), CLR_W, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
					end

					li = 0

					for i = 1, iClip2 do
						if (iClip2 - i) >= iMaxClip2 then
							surface.SetDrawColor(CLR_R)
						elseif (iClip2 - i) % 2 == 0 then
							surface.SetDrawColor(CLR_W)
						else
							surface.SetDrawColor(CLR_W2)
						end

						surface.DrawTexturedRect(ax - (c * li * lg), ay - (c * hi * hg), c * si, c * si)

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

				for i = 1, iClip1 do
					if (iClip1 - i) >= iMaxClip1 then
						surface.SetDrawColor(CLR_R)
					elseif (iClip1 - i) % 3 == 0 then
						surface.SetDrawColor(CLR_W)
					else
						surface.SetDrawColor(CLR_W2)
					end

					surface.DrawTexturedRect(ax - (c * li * lg), ay - (c * hi * hg), c * si, c * si)

					if i % rep == 0 then
						hi = hi + 1
						li = -1
					end

					li = li + 1
				end
			end

			local ally_positions = {}
			cam.Start3D()
			for _, p in pairs(player.GetAll()) do
				if p ~= LocalPlayer() and p:Team() == LocalPlayer():Team() then
					table.insert(ally_positions, {p, (p:GetPos() + Vector(0, 0, 80)):ToScreen()})
				end
			end
			cam.End3D()

			for k, v in pairs(ally_positions) do
				local ply_dist = EyePos():DistToSqr(v[1]:GetPos() + Vector(0, 0, 80))
				local s = math.Clamp(1 - ply_dist / 4096 ^ 2, 0.5, 1) * 32
				local x, y = v[2].x, v[2].y

				local mouse_dist = math.sqrt(math.abs(ScrW() * 0.5 - x) ^ 2 + math.abs(ScrH() * 0.5 - y) ^ 2)
				local mouse_range = CGSS(math.Clamp(1 - ply_dist / 2048 ^ 2, 0.1, 1) * 256)
				if mouse_dist < mouse_range then
					GAMEMODE:ShadowText(v[1]:GetName(), "CGHUD_24_Unscaled", x, y - s / 2, CLR_W, CLR_B2, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, true)
				end

				surface.SetDrawColor(CLR_W.r, CLR_W.g, CLR_W.b, 150)
				surface.SetMaterial(v[1]:Alive() and diamond or skull)
				surface.DrawTexturedRect(x - s * 0.5, y - s * 0.5, s, s)
			end
		end

		if money_last_t + 7 > CurTime() then

			local display_money
			for k, v in pairs(money_updates) do
				if v[1] + 2 > CurTime() then
					if not display_money then display_money = v[3] end
					local f = 1 - math.Clamp((CurTime() - v[1] - 0.5) / 1.5, 0, 1)
					CLR_W.a = f * 255
					CLR_B2.a = f * 127
					local str = (v[2] > 0 and "+" or "-") .. GAMEMODE:FormatMoney(v[2])
					GAMEMODE:ShadowText(str, "CGHUD_4", 0 + CGSS(16), h - CGSS(80) - f ^ 2 * CGSS(16), CLR_W, CLR_B2, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
				else
					table.remove(money_updates, k)
				end
			end
			display_money = display_money or LocalPlayer():GetNWInt("tdm_money", 0)

			local a = (1 - math.Clamp((CurTime() - money_last_t - 5) / 2, 0, 1)) ^ 2
			CLR_W.a = a * 255
			CLR_B2.a = a * 127
			GAMEMODE:ShadowText(GAMEMODE:FormatMoney(display_money), "CGHUD_3", 0 + CGSS(16), h - CGSS(64), CLR_W, CLR_B2, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)

			CLR_W.a = 255
			CLR_B2.a = 127
		end
	end
end)

net.Receive("tdm_updatemoney", function()
	local t = CurTime()
	if money_updates[#money_updates] and t - money_updates[#money_updates][1] <= 0.5 then
		local add, new = net.ReadInt(32), net.ReadInt(32)
		money_updates[#money_updates] = {t, money_updates[#money_updates][2] + add, money_updates[#money_updates][3]}
	else
		table.insert(money_updates, {t, net.ReadInt(32), net.ReadInt(32)})
	end
	money_last_t = t
end)

local hide = {
	["CHudHealth"] = true,
	["CHudBattery"] = false,
	["CHudDamageIndicator"] = true,
	["CHudAmmo"] = true,
	["CHudSecondaryAmmo"] = true,
}

hook.Add("HUDShouldDraw", "CG_HUDShouldDraw", function(name)
	if hide[name] then return false end
end)

function GM:HUDDrawTargetID()
	local tr = util.GetPlayerTrace(LocalPlayer())
	local trace = util.TraceLine(tr)
	if not trace.Hit then return end
	if not trace.HitNonWorld then return end
	local text = "ERROR"
	local font = "CGHUD_32_Unscaled"

	if trace.Entity:IsPlayer() and trace.Entity:Team() == LocalPlayer():Team() then
		text = trace.Entity:Nick()
	else
		return
	end

	--text = trace.Entity:GetClass()
	surface.SetFont(font)
	local w, h = surface.GetTextSize(text)
	local MouseX, MouseY = gui.MousePos()

	if MouseX == 0 and MouseY == 0 then
		MouseX = ScrW() / 2
		MouseY = ScrH() / 2
	end

	local x = MouseX
	local y = MouseY
	x = x - w / 2
	y = y + 64

	local clr = self:GetTeamColor(trace.Entity)
	clr.a = 255

	GAMEMODE:ShadowText(text, font, x, y, clr, CLR_B2, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, true)

	local f = trace.Entity:Health() / trace.Entity:GetMaxHealth()

	surface.SetDrawColor(CLR_B2)
	surface.DrawOutlinedRect(MouseX - 64, MouseY + 100, 128, 8, 2)

	if trace.Entity:Health() ~= 100 then
		surface.SetDrawColor(CLR_B2)
		surface.DrawRect(MouseX - 64, MouseY + 100, 128 * f, 8)
	end

	surface.SetDrawColor(clr)
	surface.DrawOutlinedRect(MouseX - 64, MouseY + 100, 128, 8, 2)
	surface.SetDrawColor(clr)
	surface.DrawRect(MouseX - 64, MouseY + 100, 128 * f, 8)
end