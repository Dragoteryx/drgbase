if not DrGBase then return end -- return if DrGBase isn't installed
SWEP.Base = "drgbase_weapon" -- DO NOT TOUCH (obviously)

-- Misc --
SWEP.PrintName = "AR2"
SWEP.Class = "weapon_drg_ar2"
SWEP.Category = "DrG - Half Life 2"
SWEP.Author = "Dragoteryx"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions	= ""
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Slot = 2
SWEP.SlotPos = 0

-- Looks --
SWEP.HoldType = "ar2"
SWEP.ViewModelFOV	= 54
SWEP.ViewModelFlip = false
SWEP.ViewModelOffset = Vector(0, 0, 0)
SWEP.ViewModelAngle = Angle(0, 0, 0)
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/c_irifle.mdl"
SWEP.WorldModel	= "models/weapons/w_irifle.mdl"
SWEP.CSMuzzleFlashes = false
SWEP.CSMuzzleX = false

-- Primary --

-- Shooting
SWEP.Primary.Damage = 10
SWEP.Primary.Bullets = 1
SWEP.Primary.Spread = 0.02
SWEP.Primary.Automatic = true
SWEP.Primary.Delay = 0.1
SWEP.Primary.Recoil = 0.5

-- Ammo
SWEP.Primary.Ammo	= "AR2"
SWEP.Primary.Cost = 1
SWEP.Primary.ClipSize	= 30
SWEP.Primary.DefaultClip = 90

-- Effects
SWEP.Primary.Sound = "Weapon_AR2.Single"
SWEP.Primary.EmptySound = "Weapon_AR2.Empty"

-- DO NOT TOUCH --
AddCSLuaFile()
DrGBase.AddWeapon(SWEP)
