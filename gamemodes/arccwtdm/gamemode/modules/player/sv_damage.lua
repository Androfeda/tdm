local nextDecay = 0
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
		if nextDecay < CurTime() then
			ply.FFDealt = math.max(0, (ply.FFDealt or 0) - GetConVar("tdm_ff_reflect_decay"):GetFloat())
			if ply.FFDealt <= 0 and ply.FFReflect then
				ply.FFReflect = false
				ply:PrintMessage(HUD_PRINTTALK, "Friendly damage will no longer reflect onto you.")
			end
		end
	end
	if nextDecay < CurTime() then
		nextDecay = CurTime() + 60
	end
end)

function GM:PlayerShouldTakeDamage(ply, attacker)
	-- Global godmode, players can't be damaged in any way
	if cvars.Bool("sbox_godmode", false) then return false end

	-- No player vs player damage
	if attacker:IsValid() and attacker:IsPlayer() and ply ~= attacker then
		--if attacker:Team() == ply:Team() then return false end

		return cvars.Bool("sbox_playershurtplayers", true)
	end
	-- Default, let the player be hurt

	return true
end

hook.Add("EntityTakeDamage", "TeamDamage", function(ply, dmg)
	if not ply:IsPlayer() or not dmg:GetAttacker():IsPlayer() then return end
	local attacker = dmg:GetAttacker()
	if ply ~= attacker and ply:Team() == attacker:Team() then
		local mult = GetConVar("tdm_ff"):GetFloat()
		if mult > 0 then
			if GetConVar("tdm_ff_reflect"):GetBool() then
				local thres = GetConVar("tdm_ff_reflect_threshold"):GetInt()
				attacker.FFDealt = (attacker.FFDealt or 0)
				if not attacker.FFReflect and attacker.FFDealt + dmg:GetDamage() >= thres then
					attacker.FFReflect = true
					if attacker.FFDealt < thres then
						attacker:PrintMessage(HUD_PRINTTALK, "You have dealt too much friendly damage. Further damage will be reflected onto you.")
					end
				end
				attacker.FFDealt = math.min(GetConVar("tdm_ff_reflect_cap"):GetFloat(), attacker.FFDealt + dmg:GetDamage())
				if attacker.FFReflect then
					-- Can't create a new DamageInfo here.
					mult = mult * 0.5
					attacker:SetHealth(attacker:Health() - dmg:GetDamage() * mult)
					if attacker:Alive() and attacker:Health() <= 0 then
						attacker:Kill()
					else
						attacker.HealthRegenNext = CurTime() + GetConVar("tdm_regen_delay"):GetFloat()
					end
				end
				print(attacker.FFDealt, attacker.FFReflect)
			end
			dmg:ScaleDamage(math.Clamp(mult, 0, 1))
		else
			return true
		end
	end
end)