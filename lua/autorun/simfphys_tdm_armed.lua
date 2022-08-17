AddCSLuaFile()

if not simfphys then return end

CreateConVar("tdm_simfphys_arcade", "0", FCVAR_ARCHIVE + FCVAR_REPLICATED, "If set, drivers use guns instead of the gunner. Only affects APCs and tanks.", 0, 1)

SIMF_TDM = {}

-- Custom damage bit flag to indicate damage came from vehicle.
SIMF_TDM.FROM_VEHICLE = 128

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
	self:SetCollisionGroup(COLLISION_GROUP_VEHICLE) -- This will block wheels (COLLISION_GROUP_WEAPON) from colliding. Awkward when on top of one another, but prevents wheels from getting in the way of vehicle collisions
	self.OnTakeDamage = SIMF_TDM.OnTakeDamage
	self.PhysicsCollide = SIMF_TDM.PhysicsCollide
	self.HurtPlayerInfo = SIMF_TDM.HurtPlayerInfo
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

	local bprop = ents.Create( "tdm_simfphys_gib" )
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

	local i, a, p, h = dmginfo:GetInflictor(), dmginfo:GetAttacker(), ent:GetPos(), ent:GetMaxHealth()
	timer.Simple(0.1, function()
		util.BlastDamage(IsValid(i) and i or game.GetWorld(), IsValid(a) and a or game.GetWorld(), p, 250 + h ^ 0.6, 500 + h * 0.25)
	end)

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

	-- the explosion gonna kill them anyways
	-- local Driver = ent:GetDriver()
	-- if IsValid( Driver ) then
	-- 	if ent.RemoteDriver ~= Driver then
	-- 		Driver:TakeDamage( Driver:Health() + Driver:Armor(), ent.LastAttacker or Entity(0), ent.LastInflictor or Entity(0) )
	-- 	end
	-- end

	-- if ent.PassengerSeats then
	-- 	for i = 1, table.Count( ent.PassengerSeats ) do
	-- 		local Passenger = ent.pSeat[i]:GetDriver()
	-- 		if IsValid( Passenger ) then
	-- 			Passenger:TakeDamage( Passenger:Health() + Passenger:Armor(), ent.LastAttacker or Entity(0), ent.LastInflictor or Entity(0) )
	-- 		end
	-- 	end
	-- end

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
	if dmginfo:IsDamageType(DMG_AIRBOAT) then
		-- "pure" damage
		skipthreshold = true
	elseif dmginfo:GetDamageType() == DMG_CRUSH then
		-- physics damage
		skipthreshold = true
	elseif dmginfo:GetDamageType() == DMG_BURN then
		local factor = 3 -- pure fire gets bonus factor
		dmginfo:ScaleDamage(2 + math.Clamp((ent:GetCurHealth() / ent:GetMaxHealth()) * factor, 0, factor))
		skipthreshold = true
	elseif dmginfo:IsExplosionDamage() then
		-- partial resistance against HE
		dmginfo:SetDamage(dmginfo:GetDamage() - (ent.DamageBlock or 0) / 2)
	elseif dmginfo:IsDamageType(DMG_BURN) then
		-- mixed burn damage
		local factor = 1.5
		dmginfo:ScaleDamage(1 + math.Clamp((ent:GetCurHealth() / ent:GetMaxHealth()) * factor, 0, factor))
	elseif not dmginfo:IsDamageType(DMG_DIRECT) then
		-- DMG_DIRECT is used by simfphys_projectiles, skips block but affected by threshold
		dmginfo:SetDamage(dmginfo:GetDamage() - (ent.DamageBlock or 0))
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
		if type ~= DMG_GENERIC and type ~= DMG_CRUSH or dmginfo:GetDamage() > 400 then

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

local function Spark( pos , normal , snd )
	local effectdata = EffectData()
	effectdata:SetOrigin( pos - normal )
	effectdata:SetNormal( -normal )
	util.Effect( "stunstickimpact", effectdata, true, true )

	if snd then
		sound.Play( Sound( snd ), pos, 75)
	end
end
function SIMF_TDM.PhysicsCollide(ent, data, physobj)
	if hook.Run("simfphysPhysicsCollide", ent, data, physobj) then return end


	local speed = data.OurOldVelocity:Length()
	if data.HitEntity:IsVehicle() then
		-- In vehicle on vehicle collisions, favor attackers
		speed = data.TheirOldVelocity:Length() * 1.5 + speed * 0.5
		-- More durable vehicles take less damage on collisions
		-- if data.HitEntity:GetClass() == ent:GetClass() then
		-- 	speed = speed * math.Clamp(data.HitEntity:GetMaxHealth() / ent:GetMaxHealth(), 0.5, 1)
		-- end
	elseif data.OurNewVelocity:Length() / data.OurOldVelocity:Length() >= 0.9 then
		speed = 0
	end

	--debugoverlay.Line(data.HitPos, data.HitPos + data.HitNormal * 24, 5, Color(0, 255, 255), true)
	--debugoverlay.Line(data.HitPos, data.HitPos + data.OurOldVelocity:GetNormalized() * math.log(data.Speed) * 10, 5, Color(255, 255, 0), true)

	local dot = math.abs(data.HitNormal:Dot(data.OurOldVelocity:GetNormalized()))
	speed = speed * math.Clamp(dot, 0, 1) ^ 0.5


	if IsValid(data.HitEntity) and (data.HitEntity:IsNPC() or data.HitEntity:IsNextBot() or data.HitEntity:IsPlayer()) then
		if speed > 100 then
			Spark(data.HitPos, data.HitNormal, "MetalVehicle.ImpactSoft")
		end
		return
	end

	if speed > 60 and data.DeltaTime > 0.2 then
		local pos = data.HitPos

		local dmginfo = DamageInfo()
		dmginfo:SetDamageForce(data.OurNewVelocity)
		dmginfo:SetDamagePosition(data.HitPos)
		dmginfo:SetAttacker(data.HitEntity)
		dmginfo:SetInflictor(data.HitEntity)
		dmginfo:SetDamage(0)
		dmginfo:SetDamageType(DMG_CRUSH)

		local plydmg = 0
		local factor = 0.5

		if speed > 800 then
			Spark(pos, data.HitNormal, "MetalVehicle.ImpactHard")
			plydmg = 10
			factor = 0.9
		else
			Spark(pos, data.HitNormal, "MetalVehicle.ImpactSoft")

			if speed > 400 then
				factor = 0.75
			end
		end

		dmginfo:SetDamage((speed * factor) ^ factor * simfphys.DamageMul)

		if dmginfo:GetDamage() > 0 then

			dmginfo:ScaleDamage(1 + ent:GetMaxHealth() * 0.0005)
			--print(ent:GetSpawn_List(), math.Round(data.OurOldVelocity:Length()), math.Round(speed), dmginfo:GetDamage())

			-- if data.HitEntity:IsVehicle() then
			-- 	print("us:", ent:GetSpawn_List(),data.OurOldVelocity:Length())
			-- 	print("them:", data.HitEntity:GetSpawn_List(), data.TheirOldVelocity:Length())
			-- 	print(speed, dmginfo:GetDamage())
			-- else
			-- 	print(data.HitEntity)
			-- end

			ent:TakeDamageInfo(dmginfo)

			dmginfo:SetDamage(plydmg)
			ent:HurtPlayerInfo(dmginfo)
		end
	end
end

function SIMF_TDM.HurtPlayerInfo(ent, dmginfo)
	if not simfphys.pDamageEnabled then return end

	local oldc = dmginfo:GetDamageCustom()
	dmginfo:SetDamageCustom(SIMF_TDM.FROM_VEHICLE)

	local Driver = ent:GetDriver()

	if IsValid( Driver ) and ent.RemoteDriver ~= Driver then
		Driver:TakeDamageInfo(dmginfo)
	end

	if ent.PassengerSeats then
		for i = 1, table.Count( ent.PassengerSeats ) do
			local Passenger = ent.pSeat[i]:GetDriver()

			if IsValid(Passenger) then
				Passenger:TakeDamageInfo(dmginfo)
			end
		end
	end

	dmginfo:SetDamageCustom(oldc)
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

local candamage = DMG_BURN + DMG_DISSOLVE + DMG_NERVEGAS + DMG_SONIC

-- rogue blast damage may damage the player when it shouldn't
local function cust_damage(ent, dmginfo)
	if ent:IsPlayer() and (ent.GetSimfphys and IsValid(ent:GetSimfphys())) and bit.band(dmginfo:GetDamageType(), candamage) == 0 and bit.band(dmginfo:GetDamageCustom(), SIMF_TDM.FROM_VEHICLE) ~= SIMF_TDM.FROM_VEHICLE then
		return true
	end
end
hook.Add("EntityTakeDamage", "tdm_simfphys", cust_damage)