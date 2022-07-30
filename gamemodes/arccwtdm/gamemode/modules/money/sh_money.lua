local Player = FindMetaTable("Player")

function Player:GetMoney()
    return self:GetNWInt("tdm_money", 0)
end

function Player:GetEarnings()
    return self:GetNWInt("tdm_earnings", 0)
end