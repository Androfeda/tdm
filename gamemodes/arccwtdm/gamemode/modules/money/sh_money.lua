local Player = FindMetaTable("Player")

function Player:GetMoney()
	return self:GetNWInt("tdm_money", 0)
end

function Player:GetEarnings()
	return self:GetNWInt("tdm_earnings", 0)
end

GM.WeaponRewardMultipliers = {
	-- Pistols
	["arccw_ur_pm"]			= 3,
	["arccw_ur_329"]		= 2.5,
	["arccw_ur_m1911"]		= 2,
	["arccw_uc_usp"]		= 2,
	["arccw_ud_glock"]		= 2,
	["arccw_ur_deagle"]		= 1.5,
}