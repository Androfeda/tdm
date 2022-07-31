GM.Buyables = {
	["arccw_ud_m79"] = {
		Name = nil, -- auto-generate from EntityClass
		EntityClass = "arccw_ud_m79",
		Price = 1000,

		Description = "Break action grenade launcher",
		Description2 = "Multiple payload types",
		Category = "Launchers",
		Icon = nil,
		CanBuy = nil, -- function(self, ply)
		OnBuy = nil, -- function(self, ply)
	}
}

concommand.Add("tdm_buy", function(ply, cmd, args, argStr)
	if SERVER then
		local itemtbl = GAMEMODE.Buyables[args[1]]
		if not itemtbl then return end

		if ply:GetMoney() < (itemtbl.Price or 0) then
			return
		end
		if itemtbl.EntityClass and ply:HasWeapon(itemtbl.EntityClass) then
			return
		end
		if itemtbl.CanBuy and itemtbl:CanBuy(ply) then
			return
		end

		ply:AddMoney(-itemtbl.Price)

		if itemtbl.EntityClass then
			ply:Give(itemtbl.EntityClass) -- this actually also works for entities (places it at user's position)
		end

		if itemtbl.OnBuy then
			itemtbl:OnBuy(ply)
		end
	end
end, function(cmd, args)
	local ret = {}
	for k, _ in pairs(GAMEMODE.Buyables) do
		table.insert(ret, "tdm_buy " .. k)
	end
	return ret
end, "Buy the specified item.")