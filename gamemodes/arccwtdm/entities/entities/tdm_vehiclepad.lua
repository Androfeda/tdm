AddCSLuaFile()

ENT.PrintName = "Spawn"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.Team = TEAM_UNASSIGNED
ENT.Model = "models/hunter/plates/plate5x7.mdl"


function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "Team")
	self:NetworkVar("Int", 1, "PadType")
	self:NetworkVar("Entity", 0, "SpawnedVehicle")
	self:NetworkVar("Float", 0, "NextReady")
end

function ENT:CanSpawn()
	return not IsValid(self:GetSpawnedVehicle()) and self:GetNextReady() <= CurTime()
end

if SERVER then

	function ENT:Initialize()
		self:SetModel((GAMEMODE.VehiclePadTypes[self:GetPadType()] or {}).Model or self.Model)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetMaterial("models/shiny")
		local r, g, b = team.GetColor(self:GetTeam() or 0):Unpack()
		self:SetColor(Color(r, g, b, 25))
		self:SetRenderMode(RENDERMODE_TRANSALPHA)
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		self:DrawShadow(false)
	end

elseif CLIENT then

	local mat = Material("tdm/vehicle_pad/generic.png", "smooth mips")
	local bg = Material("tdm/vehicle_pad/background.png", "smooth mips")
	local CLR_G = Color(150, 150, 150)
	local CLR_B2 = Color(0, 0, 0, 100)

	local function drawicon(self, x, y, s)
		local r, g, b = team.GetColor(self:GetTeam() or 0):Unpack()
		--surface.SetDrawColor(r * 0.8, g * 0.8, b * 0.8)
		if not self:CanSpawn() then
			surface.SetDrawColor(200, 200, 200, 255)
		else
			surface.SetDrawColor(r * 0.8, g * 0.8, b * 0.8)
		end
		surface.SetMaterial(bg)
		surface.DrawTexturedRect(x, y, s, s)
		surface.SetDrawColor(r, g, b)
		surface.SetMaterial(GAMEMODE.VehiclePadTypes[self:GetPadType()].Icon or mat)
		surface.DrawTexturedRect(x, y, s, s)
	end

	function ENT:Draw()
		self:DrawModel()

		if LocalPlayer().VehiclePad == self then
			return
		end

		local pos = self:GetPos() + Vector(0, 0, 64)
		local dir = (pos - EyePos()):GetNormalized():Angle()

		local angle = Angle(0, dir.y - 90, math.Clamp(math.NormalizeAngle(-dir.p + 90), 30, 150)) --Angle(0, (CurTime() * 90) % 180, 90)
		cam.Start3D2D(pos, angle, 0.05)
			drawicon(self, -512, -512, 1024)
		cam.End3D2D()
	end

	hook.Add("HUDPaint", "tdm_vehiclepad", function()
		local ent = LocalPlayer().VehiclePad
		if not IsValid(ent) then return end

		local s = CGSS(64)
		drawicon(ent, ScrW() * 0.5 - s * 0.5, ScrH() * 0.75 - s * 0.5, s)

		local clr = team.GetColor(ent:GetTeam() or 0)
		GAMEMODE:ShadowText(GAMEMODE.VehiclePadTypes[ent:GetPadType()].Name, "CGHUD_4", ScrW() * 0.5, ScrH() * 0.75 + s * 0.5, clr, CLR_B2, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, true)

		if not ent:CanSpawn() then
			if ent:GetNextReady() >= CurTime() then
				GAMEMODE:ShadowText(string.ToMinutesSeconds(math.max(0, ent:GetNextReady() - CurTime())), "CGHUD_5", ScrW() * 0.5, ScrH() * 0.75 + s * 0.5 + CGSS(30), Color(clr.r * 0.7, clr.g * 0.7, clr.b * 0.7), CLR_B2, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, true)
			else
				GAMEMODE:ShadowText("ACTIVE", "CGHUD_5", ScrW() * 0.5, ScrH() * 0.75 + s * 0.5 + CGSS(30), Color(clr.r * 0.7, clr.g * 0.7, clr.b * 0.7), CLR_B2, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, true)
			end
		else
			GAMEMODE:ShadowText("USE - Spawn", "CGHUD_5", ScrW() * 0.5, ScrH() * 0.75 + s * 0.5 + CGSS(30), clr, CLR_B2, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, true)
		end
	end)
end