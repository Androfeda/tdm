-- https://freesound.org/people/moviemusicman/sounds/142896/

SWEP.Base = "weapon_base"
SWEP.PrintName = "Whistle"
SWEP.Spawnable = false
SWEP.Category = "Other"

SWEP.Instructions = "Attack to whistle\nSecondary to catcall"

SWEP.ViewModel = "models/tdm/whistle.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
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

SWEP.Delay = 1.5
SWEP.Delay2 = 2

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "Fired")
end

function SWEP:Think()
	if !self:GetOwner():KeyDown(IN_ATTACK) and !self:GetOwner():KeyDown(IN_ATTACK2) then
		self:SetFired(false)
	end
	
	self:SetHoldType( "normal" )
	self:SetWeaponHoldType( "normal" )
end

function SWEP:PrimaryAttack()
	if self:GetNextPrimaryFire() > CurTime() then
		return false
	end
	if self:GetFired() then
		return false
	end
	
	self:SetNextPrimaryFire( CurTime() + self.Delay )

	if (game.SinglePlayer() and true) or (!game.SinglePlayer() and IsFirstTimePredicted()) then
		self:GetOwner():EmitSound( ")tdm/whistle" .. math.Round(util.SharedRandom("whistle", 1, 6)) .. ".ogg", 100, 100, 1, CHAN_VOICE )
	end

	self:GetOwner():AnimRestartGesture(GESTURE_SLOT_CUSTOM, ACT_GMOD_GESTURE_WAVE, true)

	self:SendAnim( "whistle", 1.5 )

	self:SetFired(true)
end

function SWEP:SecondaryAttack()
	if self:GetNextPrimaryFire() > CurTime() then
		return false
	end
	if self:GetFired() then
		return false
	end
	
	self:SetNextPrimaryFire( CurTime() + self.Delay2 )

	if (game.SinglePlayer() and true) or (!game.SinglePlayer() and IsFirstTimePredicted()) then
		self:GetOwner():EmitSound( ")tdm/catcall.ogg", 100, 100, 1, CHAN_VOICE )
	end

	self:GetOwner():AnimRestartGesture(GESTURE_SLOT_CUSTOM, ACT_GMOD_GESTURE_AGREE, true)

	self:SendAnim( "whistle", 1 )

	self:SetFired(true)
end

function SWEP:SendAnim( seq, mult )
	local vm = self:GetOwner():GetViewModel()
	if IsValid(vm) then
		vm:SendViewModelMatchingSequence( vm:LookupSequence( seq ) )
		vm:SetPlaybackRate( mult or 1 )
	end
end

function SWEP:Reload()
end

function SWEP:Deploy()
	self:SendAnim( "idle", 1 )
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