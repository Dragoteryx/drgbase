if not DrGBase then return end -- return if DrGBase isn't installed
SWEP.Base = "drgbase_weapon" -- DO NOT TOUCH (obviously)

-- Misc --
SWEP.PrintName = "Steyr AUG"
SWEP.Class = "weapon_drg_aug"
SWEP.Category = "DrG - CSS"
SWEP.Author = "Dragoteryx"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions	= ""
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Slot = 2
SWEP.SlitPos = 0

-- Looks --
SWEP.HoldType = "ar2"
SWEP.ViewModelFOV	= 80
SWEP.ViewModelFlip = true
SWEP.ViewModel = "models/weapons/v_rif_aug.mdl"
SWEP.WorldModel	= "models/weapons/w_rif_aug.mdl"

-- Functions
function SWEP:CustomInitialize() end
function SWEP:CustomThink() end

-- Primary --

-- Shooting
SWEP.Primary.Damage = 5
SWEP.Primary.Bullets = 1
SWEP.Primary.Spread = 0.02
SWEP.Primary.Automatic = true
SWEP.Primary.Delay = 0
SWEP.Primary.Cooldown = 0.2

-- Ammo
SWEP.Primary.Ammo	= "AR2"
SWEP.Primary.Cost = 1
SWEP.Primary.ClipSize	= 30
SWEP.Primary.DefaultClip = 90

-- Effects
SWEP.Primary.Sound = "weapons/aug/aug-1.wav"
SWEP.Primary.EmptySound = "weapons/clipempty_rifle.wav"
SWEP.Primary.ViewPunch = Angle(-1, 0, 0)

-- Functions
function SWEP:TriedToPrimaryAttack() end
function SWEP:PrePrimaryAttack() end
-- function SWEP:FirePrimary() end
function SWEP:PostPrimaryAttack() end

-- Secondary --
SWEP.Secondary.Enabled = false

-- Shooting
SWEP.Secondary.Damage = 1
SWEP.Secondary.Bullets = 1
SWEP.Secondary.Spread = 0
SWEP.Secondary.Automatic = true
SWEP.Secondary.Delay = 0
SWEP.Secondary.Cooldown = 0

-- Ammo
SWEP.Secondary.Ammo	= ""
SWEP.Secondary.Cost = 1
SWEP.Secondary.ClipSize = 0
SWEP.Secondary.DefaultClip = 1

-- Effects
SWEP.Secondary.Sound = ""
SWEP.Secondary.EmptySound = ""
SWEP.Secondary.ViewPunch = Angle(-1, 0, 0)

-- Functions
function SWEP:TriedToSecondaryAttack() end
function SWEP:PreSecondaryAttack() end
-- function SWEP:FireSecondary() end
function SWEP:PostSecondaryAttack() end

-- DO NOT TOUCH --
if SERVER then
  AddCSLuaFile("shared.lua")
end
DrGBase.Weapons.Load({
  Name = SWEP.PrintName,
  Class = SWEP.Class,
  Category = SWEP.Category,
  Spawnable = SWEP.Spawnable,
  AdminOnly = SWEP.AdminOnly
})
