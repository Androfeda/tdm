TOOL.Category = "TDM"
TOOL.Name = "#tool.tdm_spawnarea.name"

TOOL.Information = {
	{name = "left", stage = 0},
	{name = "left.1", stage = 1},
	{name = "right", stage = 0},
	{name = "right.1", stage = 1},
	{name = "reload"},
	{name = "reload_use"},
}

if CLIENT then
	language.Add("tool.tdm_spawnarea.name", "Spawn Area Tool")
	language.Add("tool.tdm_spawnarea.desc", "Create or remove spawn areas for the map.")
	language.Add("tool.tdm_spawnarea.left", "Add Area")
	language.Add("tool.tdm_spawnarea.left.1", "Finalize Area")
	language.Add("tool.tdm_spawnarea.right", "Remove Area")
	language.Add("tool.tdm_spawnarea.right.1", "Cancel")
	language.Add("tool.tdm_spawnarea.reload", "Switch Teams")
	language.Add("tool.tdm_spawnarea.reload_use", "Switch Modes")
end

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
	if self:GetStage() == 0 then
		self:SetStage(1)
		self.StepInfo = vector_grid(tr.HitPos)
	else
		if SERVER then
			local pos2 = tr.HitPos
			if self:GetOperation() == 0 and math.abs(tr.HitPos.z - self.StepInfo.z) < 72 then
				pos2.z = self.StepInfo.z + 256
			end
			vector_grid(pos2)
			local i = table.insert(GAMEMODE.SpawnAreas,
					{self.StepInfo,
					self:GetOperation() == 1 and (pos2 - self.StepInfo):Length() or pos2,
					self.TeamMode})
			GAMEMODE:SendSpawnArea(i)
		end
		self:SetStage(0)
	end
	return true
end

function TOOL:RightClick(tr)
	if self:GetStage() == 0 then

		local pos = tr.HitPos + tr.HitNormal

		for i, a in pairs(GAMEMODE.SpawnAreas) do
			if (isnumber(a[2]) and pos:Distance(a[1]) < a[2]) or
					(not isnumber(a[2]) and pos:WithinAABox(a[1], a[2])) then
				if SERVER then
					GAMEMODE.SpawnAreas[i] = nil
					GAMEMODE:SendSpawnArea(i)
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

TOOL.TeamMode = TEAM_CMB
function TOOL:Reload(tr)
	if self:GetOwner():KeyDown(IN_USE) then
		self:SetOperation((self:GetOperation() + 1) % 2)
		-- self:SetStage(0)
	else
		self.TeamMode = (self.TeamMode == TEAM_HECU and TEAM_CMB) or TEAM_HECU
	end

	if CLIENT then surface.PlaySound("garrysmod/content_downloaded.wav") end

	return false
end

function TOOL:Think()
end

if CLIENT then
	surface.CreateFont("GModToolScreen2", {
		font = "Helvetica",
		size = 40,
		weight = 900
	})

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

		local text = team.GetName(self.TeamMode)
		surface.SetFont("GModToolScreen2")
		local tw, th = surface.GetTextSize(text)
		local x, y = (w - tw) / 2, h / 3 * 2
		surface.SetTextColor(team.GetColor(self.TeamMode):Unpack())
		surface.SetTextPos(x + 3, y + 3)
		surface.DrawText(text)
		surface.SetTextColor(255, 255, 255, 255)
		surface.SetTextPos(x, y)
		surface.DrawText(text)

		local text2 = self:GetOperation() == 1 and "Sphere" or "Bounding Box"
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

	local function drawarea(a)
		if isnumber(a[2]) then
			render.DrawWireframeSphere(a[1], a[2], 16, 16, team.GetColor(a[3]), true)
		else
			render.DrawWireframeBox(Vector(0, 0, 0), Angle(0, 0, 0), a[1], a[2], team.GetColor(a[3]), true)
		end
	end

	local mat = Material("models/debug/debugwhite")
	hook.Add("PostDrawOpaqueRenderables", "spawnareatool", function()
		local w = LocalPlayer():GetTool()

		for _, a in pairs(GAMEMODE.SpawnAreas) do
			drawarea(a)
		end

		if not w then return end

		if w.Mode == "tdm_spawnarea" and w:GetStage() == 1 then
			local t = LocalPlayer():GetEyeTrace()
			render.SetMaterial(mat)

			local pos = vector_grid(t.HitPos)

			if w:GetOperation() == 1 then
				local r = (pos - w.StepInfo):Length()
				local steps = 32 --math.ceil(math.sqrt(r)) + 8
				render.DrawWireframeSphere(w.StepInfo, r, steps, steps, team.GetColor(w.TeamMode), true)
			else
				if math.abs(pos.z - w.StepInfo.z) < 72 then
					pos.z = w.StepInfo.z + 256
				end
				render.DrawWireframeBox(Vector(0, 0, 0), Angle(0, 0, 0),
						Vector(math.min(pos.x, w.StepInfo.x), math.min(pos.y, w.StepInfo.y), math.min(pos.z, w.StepInfo.z)),
						Vector(math.max(pos.x, w.StepInfo.x), math.max(pos.y, w.StepInfo.y), math.max(pos.z, w.StepInfo.z)),
						team.GetColor(w.TeamMode), true)
			end
		end
	end)
end