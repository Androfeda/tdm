
AddCSLuaFile()

local PLAYER = {}

PLAYER.DisplayName			= "ArcCW TDM Player Class"

PLAYER.SlowWalkSpeed		= 180		-- How fast to move when slow-walking (+WALK)
PLAYER.WalkSpeed			= 250		-- How fast to move when not running
PLAYER.RunSpeed				= 300		-- How fast to move when running
PLAYER.CrouchedWalkSpeed	= 0.5		-- Multiply move speed by this when crouching
PLAYER.DuckSpeed			= 0.4		-- How fast to go from not ducking, to ducking
PLAYER.UnDuckSpeed			= 0.4		-- How fast to go from ducking, to not ducking
PLAYER.JumpPower			= 170		-- How powerful our jump should be
PLAYER.CanUseFlashlight		= true		-- Can we use the flashlight
PLAYER.MaxHealth			= 100		-- Max health we can have
PLAYER.MaxArmor				= 0			-- Max armor we can have
PLAYER.StartHealth			= 100		-- How much health we start with
PLAYER.StartArmor			= 0			-- How much armour we start with
PLAYER.DropWeaponOnDie		= false		-- Do we drop our weapon when we die
PLAYER.TeammateNoCollide	= true		-- Do we collide with teammates or run straight through them
PLAYER.AvoidPlayers			= true		-- Automatically swerves around other players
PLAYER.UseVMHands			= true		-- Uses viewmodel hands

--
-- Name: PLAYER:SetupDataTables
-- Desc: Set up the network table accessors
-- Arg1:
-- Ret1:
--
function PLAYER:SetupDataTables()
	self.Player:NetworkVar("Float", 0, "Stamina_Run")
	self.Player:NetworkVar("Float", 1, "Stamina_Jump")
	self.Player:NetworkVar("Float", 2, "NextJump")

	self.Player:SetStamina_Run(1)
	self.Player:SetStamina_Jump(1)
	self.Player:SetNextJump(1)
end

--
-- Name: PLAYER:Init
-- Desc: Called when the class object is created (shared)
-- Arg1:
-- Ret1:
--
function PLAYER:Init()
end

--
-- Name: PLAYER:Spawn
-- Desc: Called serverside only when the player spawns
-- Arg1:
-- Ret1:
--
function PLAYER:Spawn()
	self.Player:SetStamina_Run(1)
	self.Player:SetStamina_Jump(1)
	self.Player:SetNextJump(1)
end

--
-- Name: PLAYER:Loadout
-- Desc: Called on spawn to give the player their default loadout
-- Arg1:
-- Ret1:
--
function PLAYER:Loadout()

	self.Player:GiveAmmo( 9999, "AR2", true )
	self.Player:GiveAmmo( 9999, "AR2AltFire", true )
	self.Player:GiveAmmo( 9999, "Pistol", true )
	self.Player:GiveAmmo( 9999, "SMG1", true )
	self.Player:GiveAmmo( 9999, "357", true )
	self.Player:GiveAmmo( 9999, "XBowBolt", true )
	self.Player:GiveAmmo( 9999, "Buckshot", true )
	self.Player:GiveAmmo( 9999, "RPGRound", true )
	self.Player:GiveAmmo( 9999, "SMG1_Grenade", true )
	self.Player:GiveAmmo( 9999, "Grenade", true )
	self.Player:GiveAmmo( 9999, "slam", true )
	self.Player:GiveAmmo( 9999, "AlyxGun", true )
	self.Player:GiveAmmo( 9999, "SniperRound", true )
	self.Player:GiveAmmo( 9999, "SniperPenetratedRound", true )
	self.Player:GiveAmmo( 9999, "Thumper", true )
	self.Player:GiveAmmo( 9999, "Gravity", true )
	self.Player:GiveAmmo( 9999, "Battery", true )
	self.Player:GiveAmmo( 9999, "GaussEnergy", true )
	self.Player:GiveAmmo( 9999, "CombineCannon", true )
	self.Player:GiveAmmo( 9999, "AirboatGun", true )
	self.Player:GiveAmmo( 9999, "StriderMinigun", true )
	self.Player:GiveAmmo( 9999, "HelicopterGun", true )
	self.Player:GiveAmmo( 9999, "9mmRound", true )
	self.Player:GiveAmmo( 9999, "357Round", true )
	self.Player:GiveAmmo( 9999, "BuckshotHL1", true )
	self.Player:GiveAmmo( 9999, "XBowBoltHL1", true )
	self.Player:GiveAmmo( 9999, "MP5_Grenade", true )
	self.Player:GiveAmmo( 9999, "RPG_Rocket", true )
	self.Player:GiveAmmo( 9999, "Uranium", true )
	self.Player:GiveAmmo( 9999, "GrenadeHL1", true )
	self.Player:GiveAmmo( 9999, "Hornet", true )
	self.Player:GiveAmmo( 9999, "Snark", true )
	self.Player:GiveAmmo( 9999, "TripMine", true )
	self.Player:GiveAmmo( 9999, "Satchel", true )
	self.Player:GiveAmmo( 9999, "12mmRound", true )
	self.Player:GiveAmmo( 9999, "StriderMinigunDirect", true )
	self.Player:GiveAmmo( 9999, "CombineHeavyCannon", true )

	-- uc
	self.Player:GiveAmmo( 9999, "plinking", true )

end


local pmrules = {
	[1] = {
		Model = "models/Yukon/HECU/HECU_01_player.mdl",
		Mods = {
			["skins"] = { -- SKin
				0,
				1,
				2,
				3,
				4,
				5,
				6,
				7,
				8,
				9,
				10,
				11,
				12,
				13,
				14,
				15,
				16,
				17,
				18,
			},
			[1] = { -- Shirt
				0,
				1,
				2,
				3,
			},
			[2] = { -- Watch
				0,
				1,
			},
			[3] = { -- Arms
				0,
				1,
				2,
			},
			[4] = { -- Legs
				0,
				1,
				2,
			},
			[7] = { -- Belt
				0,
				1,
			},
			[8] = { -- Straps
				0,
				1,
			},
			[9] = { -- Gear
				0,
				1,
				2,
				3,
			},
			[12] = { -- Shouldergear
				0,
				1,
				2,
				3,
			},

		},
	},
	[2] = {
		Model = "models/ffcm_player/combine_pm.mdl",
		Mods = {
			["skins"] = { -- SKin
				0,
				1,
				2,
			},
			[2] = {
				0,
				1,
			},
			[3] = {
				0,
				1,
			},
			[6] = {
				0,
				1,
			},
			[9] = {
				0,
				1,
			},
		},
	}
}

function PLAYER:SetModel()

	if pmrules[self.Player:Team()] then
		local la = pmrules[self.Player:Team()]
		self.Player:SetModel( la.Model )

		self.Player:SetSkin( 0 )
		self.Player:SetBodyGroups( "00000000000000000000000" )

		for index, mod in pairs(la.Mods) do
			if index == "skins" then
				self.Player:SetSkin( table.Random( la.Mods[index] ) )
			else
				self.Player:SetBodygroup( index, table.Random( mod ) )
			end
		end

		self.Player:SetupHands()

		if string.lower(self.Player:GetModel()) == "models/yukon/hecu/hecu_01_player.mdl" then
			local roll1 = math.random(0, 2)
			local balaclava = math.random(0, 1)
			if roll1 == 1 then -- Use headgear
				self.Player:SetBodygroup( 15, math.random(1, 6) ) -- Headgear
				self.Player:SetBodygroup( 18, balaclava ) -- Balaclava
			elseif roll1 == 2 then -- Use helmet
				self.Player:SetBodygroup( 17, 1 ) -- Helmet
				self.Player:SetBodygroup( 19, 1 ) -- Strap
				self.Player:SetBodygroup( 20, math.random(0, 10) ) -- Helmetgear

				if balaclava then
					self.Player:SetBodygroup( 18, 1 ) -- Balaclava
					self.Player:SetBodygroup( 19, 2 ) -- Strap
				end
			elseif roll1 == 0 then
				self.Player:SetBodygroup( 18, balaclava ) -- Balaclava
			end

			local h = self.Player:GetHands()
			local pl = self.Player

			h:SetModel( "models/weapons/c_arms_hecu_a3.mdl" )
			h:SetSkin( pl:GetSkin() )
			h:SetBodyGroups( pl:GetBodygroup(1) .. pl:GetBodygroup(2) .. pl:GetBodygroup(3) .. "000000" )
		elseif self.Player:Team() == 2 then
			local roll1 = math.random(0, 1)
			local nosupers = math.random(0, 1)
			if roll1 == 1 then -- Metrocop head
				self.Player:SetBodygroup( 4, 1 ) -- Metrocop
				self.Player:SetBodygroup( 10, 1 ) -- Supers helmet
			else -- Combine head
				if nosupers == 1 then
					self.Player:SetBodygroup( 10, 1 ) -- Disable super soldier helmet
				else
					self.Player:SetBodygroup( 11, math.random(0, 1) ) -- Night vision
				end
			end

			-- The ones it comes with are REALLY BAD
			local h = self.Player:GetHands()
			h:SetModel( "models/weapons/c_arms_combine_tdmrecolor.mdl" )
			h:SetSkin( 0 )
			h:SetBodyGroups( "000000" )
		end


		--Entity:GetBodygroupCount( number bodygroup )
	else

		local cl_playermodel = self.Player:GetInfo( "cl_playermodel" )
		local modelname = player_manager.TranslatePlayerModel( cl_playermodel )
		util.PrecacheModel( modelname )
		self.Player:SetModel( modelname )

		local skin = self.Player:GetInfoNum( "cl_playerskin", 0 )
		self.Player:SetSkin( skin )

		local groups = self.Player:GetInfo( "cl_playerbodygroups" )
		if ( groups == nil ) then groups = "" end
		local groups = string.Explode( " ", groups )
		for k = 0, self.Player:GetNumBodyGroups() - 1 do
			self.Player:SetBodygroup( k, tonumber( groups[ k + 1 ] ) or 0 )
		end

	end

end

function PLAYER:Death( inflictor, attacker )
end

-- Clientside only
function PLAYER:CalcView( view ) end		-- Setup the player's view
function PLAYER:CreateMove( cmd ) end		-- Creates the user command on the client
function PLAYER:ShouldDrawLocal() end		-- Return true if we should draw the local player

-- Shared
function PLAYER:StartMove( cmd, mv ) end	-- Copies from the user command to the move
function PLAYER:Move( mv ) end				-- Runs the move (can run multiple times for the same client)
function PLAYER:FinishMove( mv ) end		-- Copy the results of the move back to the Player

function PLAYER:ViewModelChanged( vm, old, new ) end
function PLAYER:PreDrawViewModel( vm, weapon ) end
function PLAYER:PostDrawViewModel( vm, weapon ) end

function PLAYER:GetHandsModel()
	local playermodel = player_manager.TranslateToPlayerModelName( self.Player:GetModel() )
	playermodel = player_manager.TranslatePlayerHands( playermodel )
	-- return { model = "models/weapons/c_arms_cstrike.mdl", skin = 1, body = "0100000" }
	return playermodel
end

player_manager.RegisterClass( "player_arccwtdm", PLAYER, nil )
