CreateConVar("tdm_spawn", 0, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Allow sandbox spawning.", 0, 1)
CreateConVar("tdm_deathcam", 5, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Deathcam.")
CreateConVar("tdm_game", "tdm", FCVAR_ARCHIVE + FCVAR_REPLICATED, "Gamemode.")
CreateConVar("tdm_regen_enabled", 1, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Health regen", 0, 1)
CreateConVar("tdm_regen_speed", 100 / 8, FCVAR_ARCHIVE + FCVAR_REPLICATED, "How much to regenerate in a second")
CreateConVar("tdm_regen_delay", 5, FCVAR_ARCHIVE + FCVAR_REPLICATED, "How long it takes to start regenerating")
CreateConVar("tdm_stamina_drain", 4, FCVAR_ARCHIVE + FCVAR_REPLICATED, "How long it takes to drain stamina")
CreateConVar("tdm_stamina_gain", 3, FCVAR_ARCHIVE + FCVAR_REPLICATED, "How long it takes to regain stamina")
CreateConVar("tdm_stamina_wain", 1, FCVAR_ARCHIVE + FCVAR_REPLICATED, "How long it takes to start recharging")
CreateConVar("tdm_jump_gain", 1 / 3, FCVAR_ARCHIVE + FCVAR_REPLICATED, "How long it takes to get full jump")
CreateConVar("tdm_jump_power", 220, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Jump power")

CreateConVar("tdm_ff", 0.5, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Friendly fire damage percent (0 is no damage).", 0, 1)
CreateConVar("tdm_ff_reflect", 1, FCVAR_ARCHIVE, "Excessive friendly fire damage will reflect.", 0, 1)
CreateConVar("tdm_ff_reflect_threshold", 300, FCVAR_ARCHIVE, "Amount of friendly damage (after reduction) to trigger reflect.", 0)
CreateConVar("tdm_ff_reflect_cap", 600, FCVAR_ARCHIVE, "Maximum amount of friendly damage to track.", 0)
CreateConVar("tdm_ff_reflect_decay", 150, FCVAR_ARCHIVE, "Friendly fire threshold decays by this much every minute. When it reaches zero, damage will no longer reflect.", 0)

CreateConVar("tdm_vehicle_despawn", 60, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Amount of time before an unoccupied vehicle is removed.", 0)
CreateConVar("tdm_vehicle_ff", 0.25, FCVAR_ARCHIVE, "Friendly fire damage percent against friendly vehicles.", 0, 1)

CreateConVar("tdm_money_starting", 5000, FCVAR_ARCHIVE, "Starting cash for players.", 0)
CreateConVar("tdm_money_per_kill", 100, FCVAR_ARCHIVE, "Base income for killing an enemy gamer.", 0)
CreateConVar("tdm_money_vehicle_damage", 0.05, FCVAR_ARCHIVE, "Reward per point of damage dealt to an enemy vehicle (rounded down).", 0)
CreateConVar("tdm_money_vehicle_kill", 1, FCVAR_ARCHIVE, "Reward multiplier (of the point cost) for dealing the killing blow to an enemy vehicle.", 0)
CreateConVar("tdm_money_vehicle_onfoot", 1.5, FCVAR_ARCHIVE, "Reward multiplier for damaging/killing vehicles while not being in one.", 0)

local function set_cvar(cvar, value)
	if GetConVar(cvar) then

		if CLIENT and GetConVar(cvar):IsFlagSet(FCVAR_REPLICATED) then return end

		if isbool(value) then
			GetConVar(cvar):SetBool(value)
		elseif isstring(value) then
			GetConVar(cvar):SetString(value)
		elseif isnumber(value) then
			if math.floor(value) == value then
				GetConVar(cvar):SetInt(value)
			else
				GetConVar(cvar):SetFloat(value)
			end
		end
	end
end
hook.Add("Initialize", "tdm_convars", function()

	-- for bought weapons (we don't clear ammo so don't give any extra)
	set_cvar("arccw_mult_defaultammo", 0)

	-- bought ammo entities
	set_cvar("arccw_ammo_autopickup", 1)
	set_cvar("arccw_mult_ammoamount", 1)

	-- just to be safe
	set_cvar("arccw_mult_ammohealth", -1)

	-- handled by us
	set_cvar("arccw_mult_infiniteammo", 0)

end)