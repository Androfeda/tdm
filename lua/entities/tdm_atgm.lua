ENT.Type 				= "anim"
ENT.Base 				= "base_entity"
ENT.PrintName 			= "ATGM"
ENT.Author 				= ""
ENT.Information 		= ""

ENT.Spawnable 			= false


AddCSLuaFile()

ENT.Model = "models/weapons/w_missile_closed.mdl"
ENT.FuseTime = 30
ENT.ArmTime = 0.25
ENT.Ticks = 0

if SERVER then

function ENT:Initialize()
	self:SetModel( self.Model )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetCollisionGroup( COLLISION_GROUP_PROJECTILE )
	self:DrawShadow( true )

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
		phys:SetBuoyancyRatio(0)
		phys:EnableGravity( false )
	end

	self.MotorSound = CreateSound( self, "weapons/rpg/rocket1.wav")
	self.MotorSound:Play()
end

function ENT:OnRemove()
	self.MotorSound:Stop()
end

function ENT:OnTakeDamage(dmginfo)

	if dmginfo:GetAttacker() == self:GetOwner() then return end

	self:TakePhysicsDamage(dmginfo)

	if not self.ShotDown and not dmginfo:IsDamageType(DMG_CRUSH) and not self.BOOM then
		self.ShotDown = true
		self:EmitSound("weapons/rpg/shotdown.wav", 130)
		self.MotorSound:Stop()
		self:GetPhysicsObject():EnableGravity(true)
		self:GetPhysicsObject():ApplyForceOffset(dmginfo:GetDamagePosition(), VectorRand() * 100 + Vector(0, 0, math.Rand(0, 150)))
		if IsValid(self.Vehicle) then
			table.RemoveByValue(self.Vehicle.MissileTracking, self)
		end
	end

end

end

local images_muzzle = {"effects/muzzleflash1", "effects/muzzleflash2", "effects/muzzleflash3", "effects/muzzleflash4"}

local function TableRandomChoice(tbl)
	return tbl[math.random(#tbl)]
end

function ENT:Think()
	if CLIENT then
		if self.Ticks % 3 == 0 then
			local emitter = ParticleEmitter(self:GetPos())

			if not self:IsValid() or self:WaterLevel() > 2 then return end

			local smoke = emitter:Add("particle/particle_smokegrenade", self:GetPos())
			smoke:SetVelocity( VectorRand() * 25 )
			smoke:SetGravity( Vector(math.Rand(-5, 5), math.Rand(-5, 5), math.Rand(-20, -25)) )
			smoke:SetDieTime( math.Rand(2.0, 2.5) )
			smoke:SetStartAlpha( 255 )
			smoke:SetEndAlpha( 0 )
			smoke:SetStartSize( 0 )
			smoke:SetEndSize( 125 )
			smoke:SetRoll( math.Rand(-180, 180) )
			smoke:SetRollDelta( math.Rand(-0.2,0.2) )
			smoke:SetColor( 20, 20, 20 )
			smoke:SetAirResistance( 5 )
			smoke:SetPos( self:GetPos() )
			smoke:SetLighting( false )
			emitter:Finish()
		end

		local emitter = ParticleEmitter(self:GetPos())

		local fire = emitter:Add(TableRandomChoice(images_muzzle), self:GetPos())
		fire:SetVelocity(self:GetAngles():Forward() * -1000)
		fire:SetDieTime(0.2)
		fire:SetStartAlpha(255)
		fire:SetEndAlpha(0)
		fire:SetStartSize(16)
		fire:SetEndSize(0)
		fire:SetRoll( math.Rand(-180, 180) )
		fire:SetColor(255, 255, 255)
		fire:SetPos(self:GetPos())

		emitter:Finish()

		self.Ticks = self.Ticks + 1
	end
end

function ENT:Detonate()
	if not self:IsValid() or self.BOOM then return end
	self.BOOM = true
	local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() )

	if self:WaterLevel() >= 1 then
		util.Effect( "WaterSurfaceExplosion", effectdata )
	else
		if self.ShotDown then
			util.Effect("simfphys_tankweapon_explosion_micro", effectdata)
		else
			util.Effect( "Explosion", effectdata)
		end
	end

	local attacker = self

	if self.Owner:IsValid() then
		attacker = self.Owner
	end

	util.BlastDamage(self, attacker, self:GetPos(), 256, self.ShotDown and 50 or 200)

	if not self.ShotDown then
		self:FireBullets({
			Attacker = attacker,
			Damage = 800,
			Tracer = 0,
			Distance = 64,
			Dir = self:GetAngles():Forward(),
			Src = self:GetPos(),
			IgnoreEntity = self,
			Callback = function(att, tr, dmg)
				util.Decal("Scorch", tr.StartPos, tr.HitPos - (tr.HitNormal * 64), self)

				if IsValid(tr.Entity) and tr.Entity:GetClass() == "npc_helicopter" then
					dmg:SetDamage(50)
				end

				dmg:SetDamageType(DMG_AIRBOAT)
			end
		})
	end

	self:Remove()
end

function ENT:PhysicsCollide(colData, collider)
	self:Detonate()
end

function ENT:Draw()
	self:DrawModel()
end