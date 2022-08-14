
TDM_Gametypes = {}

local ENDLESS = -1
local USERDEFINED = -2

TDM_Gametypes["tdm"] = {
	PrintName						= "Team Deathmatch",

	ScoreLimit						= USERDEFINED,
	TimeLimit						= USERDEFINED,
}

TDM_Gametypes["ctf"] = {
	PrintName						= "Capture the Flag",

	ScoreLimit						= USERDEFINED,
	TimeLimit						= USERDEFINED,
}

TDM_Gametypes["cp"] = {
	PrintName						= "Control Points",

	ScoreLimit						= USERDEFINED,
	TimeLimit						= USERDEFINED,
}

TDM_Gametypes["dom"] = {
	PrintName						= "Domination",

	ScoreLimit						= USERDEFINED,
	TimeLimit						= USERDEFINED,
}


-- You shouldn't be able to change this on a fly, you'd have to restart the round.
function GM:GT()
	return "tdm"
end

function GM:GTTable()
	return TDM_GameTypes["tdm"]
end

function GM:GTName()
	return TDM_GameTypes["tdm"].PrintName
end