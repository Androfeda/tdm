hook.Add("Think", "TDM_HealthRegen", function()
	local enabled = GetConVar("tdm_regen_enabled"):GetBool()
	local speed = 1 / GetConVar("tdm_regen_speed"):GetFloat()
	local time = FrameTime()

	for _, ply in pairs(player.GetAll()) do
		if ply:Alive() then
			local health = ply:Health()

			if health < (ply.LastHealth or 0) then
				ply.HealthRegenNext = CurTime() + GetConVar("tdm_regen_delay"):GetFloat()
			end

			if CurTime() > (ply.HealthRegenNext or 0) and enabled then
				ply.HealthRegen = (ply.HealthRegen or 0) + time

				if ply.HealthRegen >= speed then
					local add = math.floor(ply.HealthRegen / speed)
					ply.HealthRegen = ply.HealthRegen - (add * speed)

					if health < ply:GetMaxHealth() or speed < 0 then
						ply:SetHealth(math.min(health + add, ply:GetMaxHealth()))
					end
				end
			end

			ply.LastHealth = ply:Health()
		end
	end
end)

function GM:PlayerShouldTakeDamage(ply, attacker)
	-- Global godmode, players can't be damaged in any way
	if cvars.Bool("sbox_godmode", false) then return false end

	-- No player vs player damage
	if attacker:IsValid() and attacker:IsPlayer() and ply ~= attacker then
		if attacker:Team() == ply:Team() then return false end

		return cvars.Bool("sbox_playershurtplayers", true)
	end
	-- Default, let the player be hurt

	return true
end