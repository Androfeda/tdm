
-- Headshot sound:
-- https://freesound.org/people/SilverIllusionist/sounds/470585/

if SERVER then
	util.AddNetworkString( "TDM_Hitmarker" )

	if TODO then
		net.Start( "TDM_Hitmarker", false )
			net.WriteUInt(12)		-- Damage done ( 4095 as maximum )
			net.WriteBool(false)	-- Headshot
			net.WriteBool(false)	-- Final kill
		net.Send( Entity(1) )
	end

else
	net.Receive( "TDM_Hitmarker", function(len, ply)
		
	end )

	hook.Add( "HUDPaint", "TDM_Hitmarker", function()
	
	
	end )
end