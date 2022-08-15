local Player = FindMetaTable("Player")

function Player:GetTDMVehicle()
	if self.GetSimfphys and IsValid(self:GetSimfphys()) then
		return self:GetSimfphys(), "simfphys"
	elseif self.lfsGetPlane and IsValid(self:lfsGetPlane()) then
		return self:lfsGetPlane(), "lfs"
	end
end