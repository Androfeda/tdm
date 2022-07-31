TOOL.Category = "TDM"
TOOL.Name = "#tool.tdm_spawn.name"

TOOL.Information = {
	{name = "left"},
	{name = "right"},
	{name = "reload"},
}

if CLIENT then
	language.Add("tool.tdm_spawn.name", "Spawnpoint Tool")
	language.Add("tool.tdm_spawn.desc", "Create or remove spawns for the map.")
	language.Add("tool.tdm_spawn.left", "Add Spawn")
	language.Add("tool.tdm_spawn.right", "Remove Spawn")
	language.Add("tool.tdm_spawn.reload", "Switch Teams")
end

local function find_spawn(pos)
	for _, e in pairs(ents.FindInSphere(pos, 8)) do
		if scripted_ents.IsBasedOn(e:GetClass(), "tdm_spawn")  then
			return e
		end
	end
end

local spawns = {[TEAM_HECU] = "tdm_spawn_hecu", [TEAM_CMB] = "tdm_spawn_cmb"}

function TOOL:LeftClick(tr)
	if find_spawn(tr.HitPos) then
		return false
	end
	if SERVER then
		local spawn = ents.Create(spawns[self.TeamMode])
		spawn:SetPos(tr.HitPos)
		spawn:Spawn()
	end

	return true
end

function TOOL:RightClick(tr)
	local spawn = find_spawn(tr.HitPos)
	if IsValid(spawn) then
		if SERVER then spawn:Remove() end
		return true
	end
end

TOOL.TeamMode = TEAM_HECU
function TOOL:Reload(tr)
	if not IsFirstTimePredicted() then return end
	self.TeamMode = (self.TeamMode == TEAM_HECU and TEAM_CMB) or TEAM_HECU

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
		local x, y = (w - tw) / 2, h / 3 * 2 + th / 2
		surface.SetTextColor(team.GetColor(self.TeamMode):Unpack())
		surface.SetTextPos(x + 3, y + 3)
		surface.DrawText(text)
		surface.SetTextColor(255, 255, 255, 255)
		surface.SetTextPos(x, y)
		surface.DrawText(text)

		surface.SetFont( "GModToolScreen" )
		DrawScrollingText("#tool." .. GetConVar("gmod_toolmode"):GetString() .. ".name", 104, 256)
	end
end