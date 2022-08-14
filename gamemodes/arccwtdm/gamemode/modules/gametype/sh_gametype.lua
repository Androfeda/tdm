
TDM_Gametypes = {}

local ENDLESS = -1
local USERDEFINED = -2

TDM_Gametypes["tdm"] = {
	ScoreLimit						= USERDEFINED
	TimeLimit						= USERDEFINED
}


-- You shouldn't be able to change this on a fly, you'd have to restart the round.
function GM:GetGameType()
	return "tdm"
end

function GM:GetGameTypeTable()
	return TDM_GameTypes["tdm"]
end