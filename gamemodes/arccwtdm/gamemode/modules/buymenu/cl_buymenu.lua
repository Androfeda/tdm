hook.Add("PopulateShop", "AddShopContent", function(pnlContent, tree, _)
	local categorized = {}

	for k, v in pairs(GAMEMODE.Buyables) do
		local Category = v.Category or "Other"

		if not isstring(Category) then
			Category = tostring(Category)
		end

		categorized[Category] = categorized[Category] or {}

		if v.EntityClass then
			if scripted_ents.Get(v.EntityClass) then
				v.Name = v.Name or scripted_ents.Get(v.EntityClass).PrintName
				v.Icon = v.Icon or scripted_ents.Get(v.EntityClass).IconOverride
			elseif weapons.Get(v.EntityClass) then
				v.Name = v.Name or weapons.Get(v.EntityClass).PrintName
				v.Icon = v.Icon or weapons.Get(v.EntityClass).IconOverride
			else
				v.Name = v.Name or v.EntityClass or "Item"
			end
		end

		v.SpawnName = k
		table.insert(categorized[Category], v)
	end

	--
	-- Add a tree node for each category
	--
	for CategoryName, v in SortedPairs(categorized) do
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

			for k, ent in SortedPairsByMemberValue(v, "Name") do
				local icon = vgui.Create("TDMShopIcon", self.PropPanel)
				icon:SetSpawnName(ent.SpawnName)
				icon:SetName(ent.Name)
				icon:SetDescription(ent.Description, ent.Description2)
				icon:SetMaterial(ent.Icon or "entities/" .. ent.SpawnName .. ".png")
				icon:SetPrice(ent.Price or 0)
				icon:SetColor(Color(135, 206, 250, 255))
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

spawnmenu.AddCreationTab("Shop", function()
	local ctrl = vgui.Create("SpawnmenuContentPanel")
	ctrl:EnableSearch("shop", "PopulateShop")
	ctrl:CallPopulateHook("PopulateShop")

	return ctrl
end, "icon16/money.png", 20)