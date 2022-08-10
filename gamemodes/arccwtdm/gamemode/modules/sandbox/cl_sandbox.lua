function GM:ContextMenuOpen()
	return !LocalPlayer():IsAdmin() and GetConVar("tdm_spawn"):GetBool()
end

hook.Add("SpawnMenuEnabled", "TDM_SpawnMenuEnabled", function()
	if !LocalPlayer():IsAdmin() and !GetConVar("tdm_spawn"):GetBool() then
		spawnmenu.GetCreationTabs()["#spawnmenu.category.dupes"] = nil
		spawnmenu.GetCreationTabs()["#spawnmenu.category.saves"] = nil
		spawnmenu.GetCreationTabs()["#spawnmenu.category.npcs"] = nil
		spawnmenu.GetCreationTabs()["#spawnmenu.category.vehicles"] = nil
		spawnmenu.GetCreationTabs()["#spawnmenu.category.entities"] = nil
		spawnmenu.GetCreationTabs()["#spawnmenu.category.postprocess"] = nil
		spawnmenu.GetCreationTabs()["#spawnmenu.content_tab"] = nil
		spawnmenu.GetCreationTabs()["simfphys"] = nil
	end
end)

hook.Add("PopulateWeapons", "AddWeaponContent", function(pnlContent, tree, node)
	-- Loop through the weapons and add them to the menu
	local Weapons = list.Get("Weapon")
	local Categorised = {}

	-- Build into categories
	for k, weapon in pairs(Weapons) do
		if not weapon.Spawnable or (!LocalPlayer():IsAdmin() and !GetConVar("tdm_spawn"):GetBool() and not GAMEMODE:IsSpawnableWeapon(weapon.ClassName)) then continue end
		local Category = weapon.Category or "Other2"

		if not isstring(Category) then
			Category = tostring(Category)
		end

		Categorised[Category] = Categorised[Category] or {}
		table.insert(Categorised[Category], weapon)
	end

	Weapons = nil

	-- Loop through each category
	for CategoryName, v in SortedPairs(Categorised) do
		-- Add a node to the tree
		local node = tree:AddNode(CategoryName, "icon16/gun.png")

		-- When we click on the node - populate it using this function
		node.DoPopulate = function(self)
			-- If we've already populated it - forget it.
			if self.PropPanel then return end
			-- Create the container panel
			self.PropPanel = vgui.Create("ContentContainer", pnlContent)
			self.PropPanel:SetVisible(false)
			self.PropPanel:SetTriggerSpawnlistChange(false)

			for k, ent in SortedPairsByMemberValue(v, "PrintName") do
				spawnmenu.CreateContentIcon(ent.ScriptedEntityType or "weapon", self.PropPanel, {
					nicename = ent.PrintName or ent.ClassName,
					spawnname = ent.ClassName,
					material = ent.IconOverride or "entities/" .. ent.ClassName .. ".png",
					admin = ent.AdminOnly
				})
			end
		end

		-- If we click on the node populate it and switch to it.
		node.DoClick = function(self)
			self:DoPopulate()
			pnlContent:SwitchPanel(self.PropPanel)
		end
	end

	-- Select the first node
	local FirstNode = tree:Root():GetChildNode(0)

	if IsValid(FirstNode) then
		FirstNode:InternalDoClick()
	end
end)