GM.Buyables = {
	["arccw_ud_m79"] = {
		Name = nil, -- auto-generate from EntityClass
		EntityClass = "arccw_ud_m79",
		Price = 750,

		Description = "Break action grenade launcher",
		Description2 = "Multiple payload types",
		Category = "Explosives",
		Icon = nil, -- taken from EntityClass
		CanBuy = nil, -- function(self, ply)
		OnBuy = nil, -- function(self, ply)
	},
	["arccw_uo_rgd5"] = {
		EntityClass = "arccw_uo_rgd5",
		Price = 200,

		Description = "Fragmentation grenade",
		Description2 = "3.4 second timed fuse",
		Category = "Explosives",

		AmmoOnRebuy = "arccw_uo_rgd5", -- if player has weapon, give this ammo type
		AmmoOnRebuyAmount = 1, -- of this amount
	},
	["arccw_ammo_smg1_grenade"] = {
		EntityClass = "arccw_ammo_smg1_grenade",
		Price = 150,

		Description = "Single round explosive ordnance",
		Description2 = "Use with grenade launchers",
		Category = "Explosives",
	},
}

GM.BuyableEntities = {}

for k, v in pairs(GM.Buyables) do
	if not v.EntityClass then continue end
	GM.BuyableEntities[v.EntityClass] = true
end