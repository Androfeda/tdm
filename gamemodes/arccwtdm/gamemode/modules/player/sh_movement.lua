--
-- Player calculations
--

function GM:PlayerPostThink( ply )
	--print( ply:GetAbsVelocity():Length2D() )
end

function GM:OnPlayerHitGround( ply, inWater, onFloater, speed )
	ply:SetNextJump(0)
end

hook.Add("StartCommand", "TDM_StartCommand", function( ply, cmd )
	local time = GetConVar("tdm_jump_gain"):GetFloat() -- time to restore full jump
	ply:SetNextJump( math.Approach( ply:GetNextJump(), 1, FrameTime()/time ) )
	local tong = Lerp( ply:GetNextJump(), 0, GetConVar("tdm_jump_power"):GetFloat() )
	if tong <= 50 then tong = 0 end
	ply:SetJumpPower( tong )

	local actio = ply:GetMoveType() != MOVETYPE_NOCLIP and ply:GetAbsVelocity():Length2D() > 0 and ply:OnGround()

	if cmd:KeyDown(IN_SPEED) and actio then
		if ply:GetStamina_Run() == 0 then cmd:RemoveKey(IN_SPEED) end
		ply:SetStamina_Jump( CurTime() + GetConVar("tdm_stamina_wain"):GetFloat() )
	end

	if ply:IsSprinting() and actio then
		ply:SetStamina_Run( math.Approach( ply:GetStamina_Run(), 0, FrameTime()/GetConVar("tdm_stamina_drain"):GetFloat() ) )
	elseif ply:GetStamina_Jump() <= CurTime() then -- it's actually just delay
		ply:SetStamina_Run( math.Approach( ply:GetStamina_Run(), 1, FrameTime()/GetConVar("tdm_stamina_gain"):GetFloat() ) )
	end
end)

hook.Add("HandlePlayerJumping", "TDM_HandlePlayerJumping", function( ply, velocity )
	-- yeah
	return true
end)