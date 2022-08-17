AddCSLuaFile()

if not simfphys then return end

CreateConVar("tdm_simfphys_arcade", "0", FCVAR_ARCHIVE + FCVAR_REPLICATED, "If set, drivers use guns instead of the gunner. Only affects APCs and tanks.", 0, 1)

SIMF_TDM = {}

local function manip(ply, bones)
	if not IsValid(ply) then return end
	if bones then
		local Bone
		ply.TankManipulatedBones = ply.TankManipulatedBones or {}

		for k,v in pairs(bones) do
			Bone = ply:LookupBone(k)
			if Bone then
				ply.TankManipulatedBones[k] = Bone
				ply:ManipulateBoneAngles(Bone, v)
			end
		end
	else
		if not ply.TankManipulatedBones then return end
		for k,v in pairs(ply.TankManipulatedBones) do
			ply:ManipulateBoneAngles(v, angle_zero)
		end
		ply.TankManipulatedBones = nil
	end
end
hook.Add("PlayerDeath", "simfphys_tdm", function(ply)
	manip(ply)
end)

local function killhooks(ply, vehicle)
	local sid = ply:SteamID()
	hook.Remove("PlayerEnteredVehicle", "simfphys_tdm_" .. sid)
	hook.Remove("PlayerLeaveVehicle", "simfphys_tdm_" .. sid)
	manip(ply)
end

local function addhooks(vehicle, ply)
	local sid = ply:SteamID()

	local seat = ply:GetVehicle() == vehicle.DriverSeat and 0 or table.KeyFromValue(vehicle.pSeat, ply:GetVehicle())
	if vehicle.PlayerBoneManipulation and vehicle.PlayerBoneManipulation[seat] then
		manip(ply)
		manip(ply, vehicle.PlayerBoneManipulation[seat])
	end

	hook.Add("PlayerEnteredVehicle", "simfphys_tdm_" .. sid, function(ply1, veh)
		if not IsValid(ply) then
			killhooks(ply)
		elseif ply1 == ply then
			if ply:GetSimfphys() ~= vehicle then
				killhooks(ply)
			else
				killhooks(ply)
				addhooks(vehicle, ply)
			end
		end
	end)

	hook.Add("PlayerLeaveVehicle", "simfphys_tdm_" .. sid, function(ply1, veh)
		if not IsValid(ply) then
			killhooks(ply)
		elseif ply1 == ply then
			timer.Create("CHANGESEATS_" .. sid, 0.04, 1, function()
				if not IsValid(ply) or ply:GetSimfphys() ~= vehicle then
					killhooks(ply)
				end
			end)
		end
	end)
end

function SIMF_TDM.SetPassenger(self, ply)
	if not IsValid(ply) then return end

	if not IsValid(self:GetDriver()) and not ply:KeyDown(IN_WALK) then
		ply:SetAllowWeaponsInVehicle(false)

		if IsValid(self.DriverSeat) then
			self:EnteringSequence(ply)
			ply:EnterVehicle(self.DriverSeat)
			addhooks(self, ply)

			timer.Simple(0.01, function()
				if IsValid(ply) then
					local angles = Angle(0, 90, 0)
					ply:SetEyeAngles(angles)
				end
			end)
		end
	else
		if self.PassengerSeats then
			local closestSeat = self:GetClosestSeat(ply)

			if not closestSeat or IsValid(closestSeat:GetDriver()) then
				for i = 1, table.Count(self.pSeat) do
					if IsValid(self.pSeat[i]) then
						local HasPassenger = IsValid(self.pSeat[i]:GetDriver())

						if not HasPassenger then
							ply:EnterVehicle(self.pSeat[i])
							addhooks(self, ply)
							break
						end
					end
				end
			else
				ply:EnterVehicle(closestSeat)
				addhooks(self, ply)
			end
		end
	end
end

local function tiredamage(self, dmginfo)
	self:TakePhysicsDamage( dmginfo )

	if self:GetDamaged() or not simfphys.DamageEnabled then return end

	local Damage = dmginfo:GetDamage()
	local DamagePos = dmginfo:GetDamagePosition()
	local Type = dmginfo:GetDamageType()
	local BaseEnt = self:GetBaseEnt()

	if dmginfo:IsDamageType(DMG_BLAST) or dmginfo:IsDamageType(DMG_BURN) then return end  -- no tirepopping on explosions

	if IsValid(BaseEnt) then
		if BaseEnt:GetBulletProofTires() then return end

		local odds = math.Clamp((Damage - (self.TireDamageBlock or 35)) / (self.TireDamageThreshold or 100), 0, 1) ^ 2
		if math.random() < odds then
			if not self.PreBreak then
				self.PreBreak = CreateSound(self, "ambient/gas/cannister_loop.wav")
				self.PreBreak:PlayEx(0.5,100)

				timer.Simple(math.Rand(0.5,5), function()
					if IsValid(self) and not self:GetDamaged() then
						self:SetDamaged( true )
						if self.PreBreak then
							self.PreBreak:Stop()
							self.PreBreak = nil
						end
					end
				end)
			else
				self:SetDamaged( true )
				self.PreBreak:Stop()
				self.PreBreak = nil
			end
		end
	end
end

function SIMF_TDM.OnSpawned(self)
	for _, ent in pairs(self.Wheels) do
		ent.OnTakeDamage = tiredamage
	end
	self.OnTakeDamage = SIMF_TDM.OnTakeDamage
end


local function DestroyVehicle( ent, dmginfo )
	if not IsValid( ent ) then return end
	if ent.destroyed then return end

	ent.destroyed = true

	hook.Run( "simfphysVehicleDestroyed", ent, dmginfo )

	local ply = ent.EntityOwner
	local skin = ent:GetSkin()
	local Col = ent:GetColor()
	Col.r = Col.r * 0.8
	Col.g = Col.g * 0.8
	Col.b = Col.b * 0.8

	local bprop = ents.Create( "gmod_sent_vehicle_fphysics_gib" )
	bprop:SetModel( ent:GetModel() )
	bprop:SetPos( ent:GetPos() )
	bprop:SetAngles( ent:GetAngles() )
	bprop:Spawn()
	bprop:Activate()
	bprop:GetPhysicsObject():SetVelocity( ent:GetVelocity() + Vector(math.random(-5,5),math.random(-5,5),math.random(150,250)) )
	bprop:GetPhysicsObject():SetMass( ent.Mass * 0.75 )
	bprop.DoNotDuplicate = true
	bprop.MakeSound = true
	bprop:SetColor( Col )
	bprop:SetSkin( skin )

	ent.Gib = bprop

	simfphys.SetOwner( ply , bprop )

	if IsValid( ply ) then
		undo.Create( "Gib" )
		undo.SetPlayer( ply )
		undo.AddEntity( bprop )
		undo.SetCustomUndoText( "Undone Gib" )
		undo.Finish( "Gib" )
		ply:AddCleanup( "Gibs", bprop )
	end

	if ent.CustomWheels == true and not ent.NoWheelGibs then
		for i = 1, table.Count( ent.GhostWheels ) do
			local Wheel = ent.GhostWheels[i]
			if IsValid(Wheel) then
				local prop = ents.Create( "gmod_sent_vehicle_fphysics_gib" )
				prop:SetModel( Wheel:GetModel() )
				prop:SetPos( Wheel:LocalToWorld( Vector(0,0,0) ) )
				prop:SetAngles( Wheel:LocalToWorldAngles( Angle(0,0,0) ) )
				prop:SetOwner( bprop )
				prop:Spawn()
				prop:Activate()
				prop:GetPhysicsObject():SetVelocity( ent:GetVelocity() + Vector(math.random(-5,5),math.random(-5,5),math.random(0,25)) )
				prop:GetPhysicsObject():SetMass( 20 )
				prop.DoNotDuplicate = true
				bprop:DeleteOnRemove( prop )

				simfphys.SetOwner( ply , prop )
			end
		end
	end

	local Driver = ent:GetDriver()
	if IsValid( Driver ) then
		if ent.RemoteDriver ~= Driver then
			Driver:TakeDamage( Driver:Health() + Driver:Armor(), ent.LastAttacker or Entity(0), ent.LastInflictor or Entity(0) )
		end
	end

	if ent.PassengerSeats then
		for i = 1, table.Count( ent.PassengerSeats ) do
			local Passenger = ent.pSeat[i]:GetDriver()
			if IsValid( Passenger ) then
				Passenger:TakeDamage( Passenger:Health() + Passenger:Armor(), ent.LastAttacker or Entity(0), ent.LastInflictor or Entity(0) )
			end
		end
	end

	ent:Extinguish()

	ent:OnDestroyed()

	ent:Remove()
end

function SIMF_TDM.OnTakeDamage(ent, dmginfo)
	if not ent:IsInitialized() then return end
	if not simfphys.DamageEnabled then return end

	if hook.Run( "simfphysOnTakeDamage", ent, dmginfo ) then return end

	-- Armor

	local skipthreshold = false
	if ent.DamageBlock then
		if dmginfo:IsDamageType(DMG_AIRBOAT) then
			-- "pure" damage
			skipthreshold = true
		elseif dmginfo:GetDamageType() == 0 then
			-- physics damage
			skipthreshold = true
			if dmginfo:GetDamage() > 5 then
				dmginfo:ScaleDamage(6)
			end
		elseif dmginfo:GetDamageType() == DMG_BURN then
			local factor = 3 -- pure fire gets bonus factor
			dmginfo:ScaleDamage(2 + math.Clamp((ent:GetCurHealth() / ent:GetMaxHealth()) * factor, 0, factor))
			skipthreshold = true
		elseif dmginfo:IsExplosionDamage() then
			-- partial resistance against HE
			dmginfo:SetDamage(dmginfo:GetDamage() - ent.DamageBlock / 2)
		elseif dmginfo:IsDamageType(DMG_BURN) then
			-- mixed burn damage
			local factor = 1.5
			dmginfo:ScaleDamage(1 + math.Clamp((ent:GetCurHealth() / ent:GetMaxHealth()) * factor, 0, factor))
		elseif not dmginfo:IsDamageType(DMG_DIRECT) then
			-- DMG_DIRECT is used by simfphys_projectiles, skips block but affected by threshold
			dmginfo:SetDamage(dmginfo:GetDamage() - ent.DamageBlock)
		end
	end

	if dmginfo:GetDamage() <= 0 then return end

	if ent.DamageThreshold and not skipthreshold and dmginfo:GetDamage() < ent.DamageThreshold then
		dmginfo:ScaleDamage(dmginfo:GetDamage() / ent.DamageThreshold)
	end


	ent:TakePhysicsDamage( dmginfo )

	local DamagePos = dmginfo:GetDamagePosition()

	ent.LastAttacker = dmginfo:GetAttacker()
	ent.LastInflictor = dmginfo:GetInflictor()

	net.Start( "simfphys_spritedamage" )
		net.WriteEntity(ent)
		net.WriteVector(ent:WorldToLocal( DamagePos ))
		net.WriteBool(ent)
	net.Broadcast()


	local MaxHealth = ent:GetMaxHealth()
	local CurHealth = ent:GetCurHealth()

	local NewHealth = math.max( math.Round(CurHealth - dmginfo:GetDamage(), 0) , 0 )

	if NewHealth <= (MaxHealth * 0.6) then
		if NewHealth <= (MaxHealth * 0.3) then
			ent:SetOnFire( true )
			ent:SetOnSmoke( false )
		else
			ent:SetOnSmoke( true )
		end
	end

	if MaxHealth > 30 and NewHealth <= 31 and ent:EngineActive() then
		ent:DamagedStall()
	end

	if NewHealth <= 0 then
		if type ~= DMG_GENERIC and type ~= DMG_CRUSH or damage > 400 then

			DestroyVehicle( ent, dmginfo )

			return
		end

		if ent:EngineActive() then
			ent:DamagedStall()
		end

		return
	end

	ent:SetCurHealth( NewHealth )

	hook.Run( "simfphysPostTakeDamage", ent, dmginfo )

	local healthmult = NewHealth / MaxHealth
	if ent.IsArmored or (ent.ArmorThreshold and ent.ArmorThreshold <= healthmult) then return end
	local newdmg = dmginfo:GetDamage() * (ent.ArmorThreshold and (1 - healthmult / ent.ArmorThreshold) or 1)

	local Driver = ent:GetDriver()
	if IsValid(Driver) then
		local dist = (DamagePos - Driver:GetPos()):Length()
		if dist < 64 then
			local mult = math.Clamp(1 - (64 - dist) / 64, 0, 1)

			dmginfo:SetDamage(newdmg * mult)
			Driver:TakeDamageInfo(dmginfo)
			local effectdata = EffectData()
			effectdata:SetOrigin(DamagePos)
			util.Effect("BloodImpact", effectdata, true, true)
		end
	end

	if ent.PassengerSeats then
		for i = 1, table.Count(ent.PassengerSeats) do
			local Passenger = ent.pSeat[i]:GetDriver()

			if IsValid(Passenger) then
				local dist = (DamagePos - Passenger:GetPos()):Length()
				if dist < 64 then
					local mult = math.Clamp(1 - (64 - dist) / 64, 0, 1)
					dmginfo:SetDamage(newdmg * mult)
					Passenger:TakeDamageInfo(dmginfo)
					local effectdata = EffectData()
					effectdata:SetOrigin(DamagePos)
					util.Effect("BloodImpact", effectdata, true, true)
				end
			end
		end
	end
end

local function override_hook()
	if SERVER or engine.ActiveGamemode() ~= "arccwtdm" then return end
	timer.Simple(1, function()
		local old_hook = hook.GetTable()["HUDPaint"]["simfphys_HUD"]
		if old_hook then
			-- we have our own hud
			hook.Remove("HUDPaint", "simfphys_HUD")
		end
	end)
end
hook.Add("InitPostEntity", "tdm_simfphysoverride", override_hook)