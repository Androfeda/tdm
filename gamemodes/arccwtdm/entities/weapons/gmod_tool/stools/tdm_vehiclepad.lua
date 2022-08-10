TOOL.Category = "TDM"
TOOL.Name = "#tool.tdm_vehiclepad.name"

TOOL.Information = {
	{name = "left"},
	{name = "right"},
	{name = "reload"},
	{name = "reload_use"},
}

TOOL.PadTypes = {
	VEHICLE_TYPE_UNARMED,
	VEHICLE_TYPE_LIGHT,
	VEHICLE_TYPE_MEDIUM,
	VEHICLE_TYPE_HEAVY,

	AIRCRAFT_TYPE_UNARMED,
	AIRCRAFT_TYPE_LIGHT,
	AIRCRAFT_TYPE_MEDIUM,
	AIRCRAFT_TYPE_HEAVY,
}


if CLIENT then
	language.Add("tool.tdm_vehiclepad.name", "Vehicle Pad Tool")
	language.Add("tool.tdm_vehiclepad.desc", "Create or remove vehicle pads, which serve as spawn points for vehicles.")
	language.Add("tool.tdm_vehiclepad.left", "Add Pad")
	language.Add("tool.tdm_vehiclepad.right", "Remove Pad")
	language.Add("tool.tdm_vehiclepad.reload", "Switch Teams")
	language.Add("tool.tdm_vehiclepad.reload_use", "Switch Type")
end

function TOOL:LeftClick(tr)
	if SERVER then
		local spawn = ents.Create("tdm_vehiclepad")
		spawn:SetPos(tr.HitPos)
		spawn:SetAngles(Angle(0, self:GetOwner():GetAngles().y + 90, 0))
		spawn:SetTeam(self.TeamMode)
		spawn:SetPadType(self.PadTypes[self.PadMode])
		spawn:Spawn()
	end

	return true
end

function TOOL:RightClick(tr)
	local spawn = tr.Entity
	if IsValid(spawn) and spawn:GetClass() == "tdm_vehiclepad" then
		if SERVER then spawn:Remove() end
		return true
	end
end

TOOL.TeamMode = TEAM_HECU
TOOL.PadMode = 1
function TOOL:Reload(tr)
	if not IsFirstTimePredicted() then return end

	if self:GetOwner():KeyDown(IN_USE) then
		self.PadMode = math.max(1, (self.PadMode + 1) % (#self.PadTypes + 1))
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

		local text2 = (GAMEMODE.VehiclePadTypes[self.PadTypes[self.PadMode]] or {}).Name or "WHAT"
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
end