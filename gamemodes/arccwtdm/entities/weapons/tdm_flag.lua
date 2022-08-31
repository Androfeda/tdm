-- https://freesound.org/people/moviemusicman/sounds/142896/

SWEP.Base = "weapon_base"
SWEP.PrintName = "Flag"
SWEP.Spawnable = false
SWEP.Category = "Other"

SWEP.Instructions = "Attack to melee"

SWEP.ViewModel = "models/tdm/flag.mdl"
SWEP.WorldModel = "models/tdm/flag.mdl"
SWEP.ViewModelFOV = 62
SWEP.UseHands = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Ammo = "none"
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Ammo = "none"

SWEP.Delay = 2

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "Fired")

	self:NetworkVar("Float", 0, "IdleIn")
end

function SWEP:Think()
	if !self:GetOwner():KeyDown(IN_ATTACK) and !self:GetOwner():KeyDown(IN_ATTACK2) then
		self:SetFired(false)
	end
	
	if self:GetIdleIn() > 0 and self:GetIdleIn() <= CurTime() then
		self:SendAnim( "idle", 1, "idle" )
	end
	
	self:SetHoldType( "melee2" )
	self:SetWeaponHoldType( "melee2" )
end

function SWEP:PrimaryAttack()
	if self:GetNextPrimaryFire() > CurTime() then
		return false
	end
	if self:GetFired() then
		return false
	end
	
	self:SetNextPrimaryFire( CurTime() + self.Delay )
	self:SendAnim( "attack", 1 )
	self:SetFired(true)
end

function SWEP:SecondaryAttack()
end

function SWEP:SendAnim( seq, mult, special )
	local vm = self:GetOwner():GetViewModel()
	if IsValid(vm) then
		vm:SendViewModelMatchingSequence( vm:LookupSequence( seq ) )
		vm:SetPlaybackRate( mult or 1 )
		if special != "idle" then
			self:SetIdleIn( CurTime() + self:SequenceDuration() )
		end
	end
end

function SWEP:Reload()
end

function SWEP:Deploy()
	self:SendAnim( "draw", 1 )
	return true
end

function SWEP:Holster()
	return true
end

function SWEP:DoDrawCrosshair()
	return true
end

function SWEP:DrawWorldModel()
	return false
end