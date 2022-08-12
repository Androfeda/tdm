local PANEL = {}

local c_w, c_s = Color(255, 255, 255, 200), Color(0, 0, 0, 127)
local c_r = Color(255, 100, 100, 255)

AccessorFunc(PANEL, "m_Vehicle", "Vehicle")

function PANEL:Init()
	self:SetSize( 512, 128 )
	self:SetPaintBackground( false )
	self:SetText("")
	self:SetDoubleClickingEnabled( false )

	self.Image = self:Add( "DImage" )
end

function PANEL:PerformLayout(w, h)
	self.Image:Dock(LEFT)
	self.Image:SetWide(self:GetTall())
	self.Image:SetVisible( false )
end

function PANEL:SetVehicle(veh)
	local tbl = GAMEMODE.Vehicles[veh]
	self.m_Vehicle = veh
	self.m_NiceName = GAMEMODE:GetVehicleName(veh)
	self:SetMaterial(tbl.Icon or "entities/" .. veh .. ".png")
	self.Description = tbl.Description or ""
	self.Description2 = tbl.Description2 or ""
	self.Armaments = tbl.Armaments or {}
end

function PANEL:SetMaterial(name)
	self.m_MaterialName = name
	local mat = Material(name)

	-- Look for the old style material
	if not mat or mat:IsError() then
		name = name:Replace("entities/", "VGUI/entities/")
		name = name:Replace(".png", "")
		mat = Material(name)
	end

	-- Couldn't find any material..
	if not mat or mat:IsError() then
		mat = GAMEMODE.VehiclePadTypes[GAMEMODE.Vehicles[self:GetVehicle()].Type].Icon
		if not mat then return end
	end
	self.Image:SetMaterial(mat)
end

function PANEL:DoClick()
	RunConsoleCommand("tdm_vehicle", self:GetVehicle())
	self:GetParent():GetParent():GetParent():Close()
end

function PANEL:OnDepressionChanged(b)
end

function PANEL:Paint(w, h)
	if self.Depressed and not self.Dragging then
		if self.Border ~= 8 then
			self.Border = 8
			self:OnDepressionChanged(true)
		end
	else
		if self.Border ~= 0 then
			self.Border = 0
			self:OnDepressionChanged(false)
		end
	end

	surface.SetDrawColor(255, 255, 255, 255)

	if self:IsHovered() or self.Depressed or self:IsChildHovered() then
		surface.SetMaterial(Material("entities/uchover.png"))
		surface.DrawTexturedRect(self.Border, self.Border, w, h)
	end

	-- Name
	if assert(self.m_NiceName, "Holy balls no weapon name??") then
		surface.SetFont("TDMShopicon")
		surface.SetTextPos((128 + 16) + 2, 14 + 2)
		surface.SetTextColor(c_s)
		surface.DrawText(self.m_NiceName or "idk")
		surface.SetTextPos(128 + 16, 14)
		surface.SetTextColor(color_white)
		surface.DrawText(self.m_NiceName or "idk")
	end

	if self.Description then
		surface.SetFont("TDMShopicon3")
		surface.SetTextPos((128 + 16) + 2, (14 + 50 + 8) + 2)
		surface.SetTextColor(c_s)
		surface.DrawText(self.Description)
		surface.SetTextPos(128 + 16, 14 + 50 + 8)
		surface.SetTextColor(c_w)
		surface.DrawText(self.Description)
	end
	if self.Description2 then
		surface.SetFont("TDMShopicon3")
		surface.SetTextPos((128 + 16) + 2, (14 + 50 + 8 + 20) + 2)
		surface.SetTextColor(c_s)
		surface.DrawText(self.Description2)
		surface.SetTextPos(128 + 16, 14 + 50 + 8 + 20)
		surface.SetTextColor(c_w)
		surface.DrawText(self.Description2)
	end

	render.PushFilterMag(TEXFILTER.ANISOTROPIC)
	render.PushFilterMin(TEXFILTER.ANISOTROPIC)
	self.Image:PaintAt(3 + self.Border, 3 + self.Border, 128 - 8 - self.Border * 2, 128 - 8 - self.Border * 2)
	render.PopFilterMin()
	render.PopFilterMag()

	--surface.DrawTexturedRect( self.Border, self.Border, w-self.Border*2, h-self.Border*2 )
end

function PANEL:PaintOver(w, h)
	self:DrawSelections()
end

vgui.Register("TDMVehicleIcon", PANEL, "DButton")