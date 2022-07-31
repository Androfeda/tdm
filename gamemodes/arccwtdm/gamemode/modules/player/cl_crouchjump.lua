hook.Add("Think", "Crouchjumpshit", function()
	for k,v in pairs(player.GetAll()) do
		local nextpos = v:GetVelocity()*engine.TickInterval()
		local pos = v:GetPos() + nextpos
		local smins, smaxs = v:GetHull()
		local cmins, cmaxs = v:GetHullDuck()
		local tr1 = util.TraceLine({
		start = pos - Vector(16,16,0),
		endpos = pos - Vector(16,16,smaxs.z),
		filter = v})
		local tr2 = util.TraceLine({
		start = pos - Vector(16,-16,0),
		endpos = pos - Vector(16,-16,smaxs.z),
		filter = v})
		local tr3 = util.TraceLine({
		start = pos - Vector(-16,16,0),
		endpos = pos - Vector(-16,16,smaxs.z),
		filter = v})
		local tr4 = util.TraceLine({
		start = pos - Vector(-16,-16,0),
		endpos = pos - Vector(-16,-16,smaxs.z),
		filter = v})
		local tr5 = util.TraceLine({
		start = pos,
		endpos = pos - Vector(0,0,smaxs.z),
		filter = v})
		local total = tr1.Fraction + tr2.Fraction + tr3.Fraction + tr4.Fraction + tr5.Fraction
		local min, max = math.min(tr1.Fraction,tr2.Fraction,tr3.Fraction,tr4.Fraction,tr5.Fraction), math.max(tr1.Fraction,tr2.Fraction,tr3.Fraction,tr4.Fraction,tr5.Fraction)
		if !v:OnGround() && v:Crouching() then
			v:ManipulateBonePosition(0, Vector(0,0,total/4*-(smaxs-cmaxs).z), false)
		else
			v:ManipulateBonePosition(0, Vector(0,0,0), false)
		end
	end
end)