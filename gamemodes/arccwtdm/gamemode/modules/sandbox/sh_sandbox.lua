GM.EntityBlacklist = {
    ["arccw_ud_m79"] = true,
}

hook.Add("PlayerCheckLimit", "ArcCWTDM_PlayerCheckLimit", function(ply, name, cur, max)
	-- This disables spawning or using anything else
	if not ply:IsAdmin() and GetConVar("tdm_spawn"):GetBool() == false then return false end
end)

hook.Add("PlayerGiveSWEP", "BlockPlayerSWEPs", function(ply, class, swep)
	-- Use the blacklist
	if GAMEMODE.EntityBlacklist[class] then return false end

	-- Check if they're based on ArcCW or ARC9 here
	if	weapons.IsBasedOn(class, "arccw_base") or
		weapons.IsBasedOn(class, "arccw_base_melee") or
		weapons.IsBasedOn(class, "arccw_base_nade") or
		weapons.IsBasedOn(class, "arccw_uo_grenade_base") or
		weapons.IsBasedOn(class, "arc9_base") then

		timer.Simple(0.8, function()
			if ply:GetWeapon(class) and IsValid(ply:GetWeapon(class)) then
				local swep = ply:GetWeapon(class)
				swep:SetClip1( swep:GetCapacity() )
			end
		end)
		return true
	end
	-- Otherwise, no
	if not ply:IsAdmin() and GetConVar("tdm_spawn"):GetBool() == false then return false end
end)

function GM:PlayerNoClip(pl, on)
	-- Admin check this
	if not on then return true end
	-- Allow noclip if we're in single player and living

	return IsValid(pl) and pl:Alive() and pl:IsAdmin()
end