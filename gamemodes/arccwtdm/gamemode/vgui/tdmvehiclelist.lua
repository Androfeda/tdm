local PANEL = {}

AccessorFunc(PANEL, "m_PadType", "PadType")

function PANEL:Init()
	self:SetSize(512, 640)
	self:SetBackgroundBlur(true)
	self:SetTitle("")
	self:Center()
	self:MakePopup()

	self.Scroll = vgui.Create("DScrollPanel", self)
	self.Scroll:Dock(FILL)
end

function PANEL:SetPadType(t)
	self.m_PadType = t
	self:AddVehicles()
	self:SetTitle(GAMEMODE.VehiclePadTypes[t].Name)
end

function PANEL:AddVehicles()
	local vehs = GAMEMODE:GetVehiclesForPlayer(LocalPlayer(), self.m_PadType)
	for k, v in pairs(vehs) do
		local panel = self.Scroll:Add("TDMVehicleIcon")
		panel:Dock(TOP)
		panel:InvalidateLayout()
		panel:SetVehicle(k)
	end
	if table.Count(vehs) == 0 then
		local panel = self.Scroll:Add("DLabel")
		panel:Dock(FILL)
		panel:SetFont("TDMShopicon")
		panel:SetContentAlignment(5)
		panel:SetTall(200)
		panel:SetText("No vehicles available")
	end
end

vgui.Register("TDMVehicleList", PANEL, "DFrame")