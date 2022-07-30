
-- Clientside initialization

include( "shared.lua" )
include( "client/hud.lua" )

function GM:ContextMenuOpen()
	return GetConVar("tdm_spawn"):GetBool()
end

hook.Add( "SpawnMenuEnabled", "TDM_SpawnMenuEnabled", function()
	if !GetConVar("tdm_spawn"):GetBool() then
		spawnmenu.GetCreationTabs()["#spawnmenu.category.dupes"] = nil
		spawnmenu.GetCreationTabs()["#spawnmenu.category.saves"] = nil
		spawnmenu.GetCreationTabs()["#spawnmenu.category.npcs"] = nil
		spawnmenu.GetCreationTabs()["#spawnmenu.category.vehicles"] = nil
		spawnmenu.GetCreationTabs()["#spawnmenu.category.entities"] = nil
		spawnmenu.GetCreationTabs()["#spawnmenu.category.postprocess"] = nil
		spawnmenu.GetCreationTabs()["#spawnmenu.content_tab"] = nil
	end
end)

--[[
#spawnmenu.category.dupes
#spawnmenu.category.entities
#spawnmenu.category.npcs
#spawnmenu.category.postprocess
#spawnmenu.category.saves
#spawnmenu.category.vehicles
#spawnmenu.category.weapons
#spawnmenu.content_tab
]]