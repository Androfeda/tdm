local PANEL = {}
local matOverlay_Normal = Material("gui/ContentIcon-normal.png")
local matOverlay_Hovered = Material("gui/ContentIcon-hovered.png")

AccessorFunc(PANEL, "m_Color", "Color")
AccessorFunc(PANEL, "m_SpawnName", "SpawnName")
AccessorFunc(PANEL, "m_NPCWeapon", "NPCWeapon")
AccessorFunc(PANEL, "m_bAdminOnly", "AdminOnly")
AccessorFunc(PANEL, "m_bIsNPCWeapon", "IsNPCWeapon")
AccessorFunc(PANEL, "m_Price", "Price", FORCE_NUMBER)

function PANEL:Init()
	self:SetPaintBackground( false )
	local sw, sh = self:GetParent():GetParent():GetParent():GetSize()
	self:SetSize( 384, 128 ) -- TODO: get real long n har. nvm
	self:SetText( "" )
	self:SetDoubleClickingEnabled( false )

	self.Image = self:Add( "DImage" )
	self.Image:SetPos( 3, 3 )
	self.Image:SetSize( 128 - 6, 128 - 6 )
	self.Image:SetVisible( false )

	self.Border = 0
end

function PANEL:SetName( name )
	self:SetTooltip(name)
	self.m_NiceName = name
end

function PANEL:SetDescription( desc )
	self:SetTooltip(self.m_NiceName .. "\n" .. desc)
	self.Description = desc
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

	-- Couldn't find any material.. just return
	if not mat or mat:IsError() then return end
	self.Image:SetMaterial(mat)
end

function PANEL:DoRightClick()
	local pCanvas = self:GetSelectionCanvas()
	if IsValid(pCanvas) and pCanvas:NumSelectedChildren() > 0 and self:IsSelected() then return hook.Run("SpawnlistOpenGenericMenu", pCanvas) end
	self:OpenMenu()
end

function PANEL:DoClick()
	RunConsoleCommand("tdm_buy", self:GetSpawnName())
end

function PANEL:OpenMenu()
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

	if not dragndrop.IsDragging() and (self:IsHovered() or self.Depressed or self:IsChildHovered()) then
		surface.SetMaterial(Material("entities/uchover.png"))
		surface.DrawTexturedRect(self.Border, self.Border, w, h)
	end

	--surface.SetMaterial( matOverlay_Normal )
	--self.Label:Show()
	local c_w, c_s = Color(255, 255, 255, 200), Color(0, 0, 0, 127)
	local c_r = Color(255, 255, 100, 200)

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

	-- Price
	local price = GAMEMODE:FormatMoney(self:GetPrice() or 0)
	surface.SetFont("TDMShopicon2")
	surface.SetTextPos((128 + 16) + 2, (14 + 32) + 2)
	surface.SetTextColor(c_s)
	surface.DrawText(price)
	surface.SetTextPos(128 + 16, 14 + 32)
	surface.SetTextColor(color_white)
	surface.DrawText(price)


	if self.Description then
		surface.SetFont("TDMShopicon3")
		surface.SetTextPos((128 + 16) + 2, (14 + 50 + 8) + 2)
		surface.SetTextColor(c_s)
		surface.DrawText(self.Description)
		surface.SetTextPos(128 + 16, 14 + 50 + 8)
		surface.SetTextColor(LocalPlayer():GetMoney() > self:GetPrice() and c_w or c_r)
		surface.DrawText(self.Description)
	end

	render.PushFilterMag(TEXFILTER.ANISOTROPIC)
	render.PushFilterMin(TEXFILTER.ANISOTROPIC)
	self.Image:PaintAt(3 + self.Border, 3 + self.Border, 128 - 8 - self.Border * 2, 128 - 8 - self.Border * 2)
	render.PopFilterMin()
	render.PopFilterMag()

	--surface.DrawTexturedRect( self.Border, self.Border, w-self.Border*2, h-self.Border*2 )
end

function PANEL:ScanForNPCWeapons()
	if self.HasScanned then return end
	self.HasScanned = true

	for _, v in pairs(list.Get("NPCUsableWeapons")) do
		if v.class == self:GetSpawnName() then
			self:SetIsNPCWeapon(true)
			break
		end
	end
end

function PANEL:PaintOver(w, h)
	self:DrawSelections()
end

function PANEL:ToTable(bigtable)
	local tab = {}
	tab.nicename = self.m_NiceName
	tab.material = self.m_MaterialName
	tab.admin = self:GetAdminOnly()
	tab.spawnname = self:GetSpawnName()
	tab.weapon = self:GetNPCWeapon()
	table.insert(bigtable, tab)
end

function PANEL:Copy()
	local copy = vgui.Create("ContentIcon", self:GetParent())
	copy:SetSpawnName(self:GetSpawnName())
	copy:SetName(self.m_NiceName)
	copy:SetMaterial(self.m_MaterialName)
	copy:SetNPCWeapon(self:GetNPCWeapon())
	copy:SetAdminOnly(self:GetAdminOnly())
	copy:CopyBase(self)
	copy.DoClick = self.DoClick
	copy.OpenMenu = self.OpenMenu
	copy.OpenMenuExtra = self.OpenMenuExtra

	return copy
end

vgui.Register("TDMShopIcon", PANEL, "DButton")


surface.CreateFont( "TDMShopicon", {
	font = "Bahnschrift",
	size = 36,
	weight = 0,
	blursize = 0,
	antialias = true,
} )

surface.CreateFont( "TDMShopicon2", {
	font = "Bahnschrift Light",
	size = 24,
	weight = 0,
	blursize = 0,
	antialias = true,
} )

surface.CreateFont( "TDMShopicon3", {
	font = "Bahnschrift Light",
	size = 20,
	weight = 0,
	blursize = 0,
	antialias = true,
} )