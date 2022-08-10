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
	return not IsValid(self:GetSpawnedVehicle() or self:NextReady() > CurTime())
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

	local s = 1024

	function ENT:Draw()
		self:DrawModel()


		local pos = self:GetPos() + Vector(0, 0, 64)
		local dir = (pos - EyePos()):GetNormalized():Angle()

		local angle = Angle(0, dir.y - 90, math.Clamp(math.NormalizeAngle(-dir.p + 90), 30, 150)) --Angle(0, (CurTime() * 90) % 180, 90)
		cam.Start3D2D(pos, angle, 0.05)
			local r, g, b = team.GetColor(self:GetTeam() or 0):Unpack()
			surface.SetDrawColor(r * 0.8, g * 0.8, b * 0.8)
			surface.SetMaterial(bg)
			surface.DrawTexturedRect(-s / 2, -s / 2, s, s)
			if not self:CanSpawn() then
				surface.SetDrawColor(r * 0.7, g * 0.7, b * 0.7, 200)
			else
				surface.SetDrawColor(r, g, b)
			end
			surface.SetMaterial(GAMEMODE.VehiclePadTypes[self:GetPadType()].Icon or mat)
			surface.DrawTexturedRect(-s / 2, -s / 2, s, s)
		cam.End3D2D()
		--local mins, maxs = self:GetModelBounds()
		--render.DrawWireframeBox(self:WorldSpaceCenter(), self:GetAngles(), mins, maxs, team.GetColor(self:GetTeam()))
	end
end