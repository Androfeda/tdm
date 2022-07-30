util.AddNetworkString("tdm_updatemoney")

hook.Add("Initialize", "tdm_money", function()
	sql.Query([[CREATE TABLE IF NOT EXISTS `tdm_money` (
		sid64 BIGINT unsigned,
		balance BIGINT,
		earnings BIGINT,
		PRIMARY KEY (`sid64`)
	);]])
end)

local Player = FindMetaTable("Player")

function Player:SaveMoney()
	local sid64 = tostring(self:SteamID64() or 0)
	local amt = math.floor(self:GetNWInt("tdm_money", 0))
	local earnings = math.floor(self:GetNWInt("tdm_earnings", 0))

	local data = sql.Query("SELECT * FROM tdm_money WHERE sid64 = " .. sid64 .. ";")
	if data then
		sql.Query("UPDATE tdm_money SET balance = " .. amt .. ", earnings = " .. earnings .. " WHERE sid64 = " .. sid64 .. ";")
	else
		sql.Query("INSERT INTO tdm_money ( sid64, balance, earnings ) VALUES ( " .. sid64 .. ", " .. amt .. "," .. earnings .. " )")
	end
end

function Player:LoadMoney()
	local sid64 = tostring(self:SteamID64() or 0)

	local data = sql.QueryRow("SELECT * FROM tdm_money WHERE sid64 = " .. sid64 .. ";")
	if data then
		self:SetNWInt("tdm_money", data.balance)
		self:SetNWInt("tdm_earnings", data.earnings)
	else
		self:SetNWInt("tdm_money", GetConVar("tdm_money_starting"):GetInt())
		self:SetNWInt("tdm_earnings", 0)
		sql.Query("INSERT INTO tdm_money ( sid64, balance, earnings ) VALUES ( " .. sid64 .. ", " .. self:GetNWInt("tdm_money", 0) .. "," .. "0" .. " )")
	end
end

hook.Add("PlayerInitialSpawn", "tdm_money", function(ply)
	ply:LoadMoney()
end)

hook.Add("PlayerDisconnected", "tdm_money", function(ply)
	ply:SaveMoney()
end)

hook.Add("ShutDown", function()
	for _, ply in ipairs(player.GetAll()) do
		ply:SaveMoney()
	end
end)

timer.Create("tdm_money", 60, 0, function()
	for _, ply in ipairs(player.GetAll()) do
		if ply._money_dirty then
			ply:SaveMoney()
			ply._money_dirty = false
		end
	end
end)

function Player:SetMoney(amt)
	self._money_dirty = true
	self:SetNWInt("tdm_money", math.floor(amt))
end

function Player:AddMoney(amt, no_notify, not_earnings)
	self._money_dirty = true

	if not no_notify then
		net.Start("tdm_updatemoney")
			net.WriteInt(amt, 32)
			net.WriteInt(self:GetNWInt("tdm_money", 0), 32) -- write anyways because we want to know the old amount (nwint refresh may not catch up)
		net.Send(self)
	end

	self:SetNWInt("tdm_money", self:GetNWInt("tdm_money", 0) + math.floor(amt))

	if not not_earnings and amt > 0 then
		self:SetNWInt("tdm_earnings", self:GetNWInt("tdm_earnings", 0) + math.floor(amt))
	end
end

hook.Add("DoPlayerDeath", "tdm_money", function(ply, attacker, dmginfo)
	if attacker:IsPlayer() and attacker ~= ply and attacker:Team() ~= ply:Team() and GetConVar("tdm_money_per_kill"):GetInt() > 0 then
		local reward = GetConVar("tdm_money_per_kill"):GetInt()
		local class = dmginfo:GetInflictor():IsWeapon() and dmginfo:GetInflictor():GetClass() or attacker:GetActiveWeapon():GetClass()

		reward = reward * (GAMEMODE.WeaponRewardMultipliers[class] or 1)

		attacker:AddMoney(reward)
	end
end)