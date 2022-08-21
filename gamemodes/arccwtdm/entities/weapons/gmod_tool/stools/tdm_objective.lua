TOOL.Category = "TDM"
TOOL.Name = "#tool.tdm_objective.name"

TOOL.Information = {
	{name = "left", stage = 0, op = 0},
	{name = "left.1", stage = 1, op = 0},
	{name = "left_ent", stage = 0, op = 1},
	{name = "right", stage = 0},
	{name = "right.1", stage = 1},
	{name = "reload"},
	{name = "reload_use"},
}

if CLIENT then
	language.Add("tool.tdm_objective.name", "Objective Tool")
	language.Add("tool.tdm_objective.desc", "Create or remove objective areas or entities.")
	language.Add("tool.tdm_objective.left", "Add Area")
	language.Add("tool.tdm_objective.left.1", "Finalize Area")
	language.Add("tool.tdm_objective.left_ent", "Add Entity")

	language.Add("tool.tdm_objective.right", "Remove")
	language.Add("tool.tdm_objective.right.1", "Cancel")

	language.Add("tool.tdm_objective.reload", "Switch Type")
	language.Add("tool.tdm_objective.reload_use", "Switch Modes")
end

local entities = {
	"tdm_obj_cache"
}

local grid_size = 4
local function vector_grid(vec)
	vec.x = math.Round(vec.x)
	vec.x = vec.x + (vec.x % grid_size)
	vec.y = math.Round(vec.y)
	vec.y = vec.y + (vec.y % grid_size)
	-- do nothing to z (usually we want it aligned to the floor)
	return vec
end

function TOOL:LeftClick(tr)
	if self:GetOperation() == 1 then
		if SERVER then
			local ent = ents.Create(entities[self.ModeNum + 1])
			ent:SetPos(tr.HitPos)
			ent:SetAngles(Angle(0, self:GetOwner():GetAngles().y, 0))
			ent:Spawn()
		end
	else
		if self:GetStage() == 0 then
			self:SetStage(1)
			self.StepInfo = vector_grid(tr.HitPos)
		else
			if SERVER then
				local pos2 = tr.HitPos
				if self.ModeNum == 0 and math.abs(tr.HitPos.z - self.StepInfo.z) < 72 then
					pos2.z = self.StepInfo.z + 256
				end
				vector_grid(pos2)
				local i = table.insert(GAMEMODE.ObjectiveAreas,
						{self.StepInfo,
						self.ModeNum == 1 and (pos2 - self.StepInfo):Length() or pos2})
				GAMEMODE:SendObjArea(i)
			end
			self:SetStage(0)
		end
	end
	return true
end

function TOOL:RightClick(tr)
	if self:GetStage() == 0 then

		local pos = tr.HitPos + tr.HitNormal * 4

		for i, a in pairs(GAMEMODE.ObjectiveAreas) do
			if (isnumber(a[2]) and pos:Distance(a[1]) < a[2]) or
					(not isnumber(a[2]) and pos:WithinAABox(a[1], a[2])) then
				if SERVER then
					GAMEMODE.ObjectiveAreas[i] = nil
					GAMEMODE:SendObjArea(i)
				end
				return true
			end
		end
		return true
	else
		self:SetStage(0)
		return true
	end
end

TOOL.ModeNum = 0
function TOOL:Reload(tr)
	if not IsFirstTimePredicted() then return end

	if self:GetOwner():KeyDown(IN_USE) then
		self:SetOperation((self:GetOperation() + 1) % 2)
		self:SetStage(0)
		self.ModeNum = 0
	else
		if self:GetOperation() == 0 then
			self.ModeNum = (self.ModeNum + 1) % 2
		else
			self.ModeNum = (self.ModeNum + 1) % #entities
		end
	end

	if CLIENT then surface.PlaySound("garrysmod/content_downloaded.wav") end

	return false
end

function TOOL:Think()
end

if CLIENT then

	local function DrawScrollingText(text, y, texwide)
		local w, h = surface.GetTextSize(text)
		w = w + 64
		y = y - h / 2 -- Center text to y position
		local x = RealTime() * 250 % w * -1

		while x < texwide do
			surface.SetTextColor(0, 0, 0, 255)
			surface.SetTextPos(x + 3, y + 3)
			surface.DrawText(text)
			surface.SetTextColor(255, 255, 255, 255)
			surface.SetTextPos(x, y)
			surface.DrawText(text)
			x = x + w
		end
	end

	function TOOL:DrawToolScreen(w, h)
		surface.SetDrawColor(50, 50, 50)
		surface.DrawRect(0, h / 3 * 2, w, h / 3)

		local text = self:GetOperation() == 0 and "Area" or "Entity"
		surface.SetFont("GModToolScreen2")
		local tw, th = surface.GetTextSize(text)
		local x, y = (w - tw) / 2, h / 3 * 2
		surface.SetTextColor(0, 0, 0)
		surface.SetTextPos(x + 3, y + 3)
		surface.DrawText(text)
		surface.SetTextColor(255, 255, 255, 255)
		surface.SetTextPos(x, y)
		surface.DrawText(text)

		local text2
		if self:GetOperation() == 0 then
			text2 = self.ModeNum == 1 and "Sphere" or "Bounding Box"
		else
			text2 = scripted_ents.Get(entities[self.ModeNum + 1]).PrintName or entities[self.ModeNum + 1]

		end

		surface.SetFont("GModToolScreen3")
		local tw2, _ = surface.GetTextSize(text2)
		local x2, y2 = (w - tw2) / 2, h / 3 * 2 + th
		surface.SetTextColor(0, 0, 0, 255)
		surface.SetTextPos(x2 + 3, y2 + 3)
		surface.DrawText(text2)
		surface.SetTextColor(255, 255, 255, 255)
		surface.SetTextPos(x2, y2)
		surface.DrawText(text2)

		surface.SetFont( "GModToolScreen" )
		DrawScrollingText("#tool." .. GetConVar("gmod_toolmode"):GetString() .. ".name", 104, 256)
	end

	local clr = Color(255, 200, 0)
	local function drawarea(a)
		if isnumber(a[2]) then
			render.DrawWireframeSphere(a[1], a[2], 16, 16, clr, true)
		else
			render.DrawWireframeBox(Vector(0, 0, 0), Angle(0, 0, 0), a[1], a[2], clr, true)
		end
	end

	local mat = Material("models/debug/debugwhite")
	hook.Add("PostDrawOpaqueRenderables", "objectivetool", function()
		local w = LocalPlayer():GetTool()

		if not w then return end

		if w.Mode == "tdm_objective" then

			for _, a in pairs(GAMEMODE.ObjectiveAreas) do
				drawarea(a)
			end

			local t = LocalPlayer():GetEyeTrace()

			if w:GetOperation() == 0 and w:GetStage() == 1 then
				render.SetMaterial(mat)

				local pos = vector_grid(t.HitPos)


				if w.ModeNum == 1 then
					local r = (pos - w.StepInfo):Length()
					local steps = 32 --math.ceil(math.sqrt(r)) + 8
					render.DrawWireframeSphere(w.StepInfo, r, steps, steps, clr, true)
				else
					if math.abs(pos.z - w.StepInfo.z) < 72 then
						pos.z = w.StepInfo.z + 256
					end
					render.DrawWireframeBox(Vector(0, 0, 0), Angle(0, 0, 0),
							Vector(math.min(pos.x, w.StepInfo.x), math.min(pos.y, w.StepInfo.y), math.min(pos.z, w.StepInfo.z)),
							Vector(math.max(pos.x, w.StepInfo.x), math.max(pos.y, w.StepInfo.y), math.max(pos.z, w.StepInfo.z)),
							clr, true)
				end
			elseif w:GetOperation() == 1 then

			end
		end
	end)
end
