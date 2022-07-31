util.AddNetworkString("tdm_buy")

net.Receive("tdm_buy", function(len, ply)
	local itemtbl = GAMEMODE.Buyables[net.ReadString()]
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
end)