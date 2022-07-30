if SERVER then
    util.AddNetworkString("BEEP!")
else
    net.Receive("BEEP!", function(len, pl)
        EmitSound(net.ReadBool() and "tdm/respawn.wav" or "tdm/countdown.wav", vector_origin, -1, CHAN_AUTO, 1, 75, 0, 100, 0)
    end)
end

local function se(p)
    p.DeathTime2 = CurTime()

    p.doob = {
        [3] = true,
        [2] = true,
        [1] = true,
        [0] = true,
    }
end

hook.Add("PlayerDeath", "BEEP!_PlayerDeath", function(p)
    se(p)
end)

hook.Add("PlayerDeathThink", "BEEP!_PlayerDeathThink", function(pl)
    if GetConVar("tdm_deathcam"):GetBool() then
        local retime = GetConVar("tdm_deathcam"):GetFloat()

        if pl.DeathTime2 and (pl.DeathTime2 + retime + 0.1) <= CurTime() then
            pl:Spawn()

            return true
        else
            local wham = math.floor(((pl.DeathTime2 or 0) - CurTime()) + (retime + 1))

            if not pl.doob then
                pl.doob = {
                    [3] = true,
                    [2] = true,
                    [1] = true,
                    [0] = true,
                }
            end

            if pl.doob[wham] then
                net.Start("BEEP!")
                net.WriteBool(wham == 0)
                net.Send(pl)

                if pl.doob[wham] and wham == 1 then
                    pl:ScreenFade(SCREENFADE.OUT, Color(0, 0, 0, 255), 1, 1)
                end

                pl.doob[wham] = false
            end

            return false
        end
    end
end)