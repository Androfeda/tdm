
SWEP.Base = "weapon_base"
SWEP.PrintName = "Whistle"
SWEP.Spawnable = false
SWEP.Category = "Other"

SWEP.Instructions = "Attack to whistle"

SWEP.ViewModel = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
SWEP.ViewModelFOV = 10

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Ammo = "none"
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Ammo = "none"

SWEP.Delay = 1.5

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "Fired")
end

function SWEP:Think()
	if !self:GetOwner():KeyDown(IN_ATTACK) then
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
		self:GetOwner():EmitSound( ")tdm/whistle" .. math.random(1, 6) .. ".ogg", 100, 100, 1, CHAN_VOICE )
	end

	self:SetFired(true)
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
end

function SWEP:Deploy()
	return true
end

function SWEP:Holster()
	return true
end

function SWEP:ShouldDrawViewModel()
	return false
end

function SWEP:DrawWorldModel()
	return false
end