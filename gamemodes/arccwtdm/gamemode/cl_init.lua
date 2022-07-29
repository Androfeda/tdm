
-- Clientside initialization

include( "shared.lua" )
include( "client/hud.lua" )

function GM:ContextMenuOpen()
	return GetConVar("tdm_spawn"):GetBool()
end