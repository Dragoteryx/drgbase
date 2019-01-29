SWEP.IsDrGWeapon = true

-- Misc --
SWEP.PrintName = ""
SWEP.Category = ""
SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions	= ""
SWEP.Spawnable = false
SWEP.AdminOnly = false

-- Looks --
SWEP.HoldType = "ar2"
SWEP.ViewModelFOV	= 62
SWEP.ViewModelFlip = true
SWEP.ViewModel = ""
SWEP.WorldModel	= ""

-- Primary --

-- Shooting
SWEP.Primary.Damage = 1
SWEP.Primary.Bullets = 1
SWEP.Primary.Spread = 0
SWEP.Primary.Automatic = true
SWEP.Primary.Delay = 0
SWEP.Primary.Cooldown = 0

-- Ammo
SWEP.Primary.Ammo	= ""
SWEP.Primary.Cost = 1
SWEP.Primary.ClipSize	= 30
SWEP.Primary.DefaultClip = 90

-- Effects
SWEP.Primary.Sound = ""
SWEP.Primary.EmptySound = ""
SWEP.Primary.ViewPunch = Angle(-1, 0, 0)

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

DrGBase.IncludeFile("misc.lua")
DrGBase.IncludeFile("primary.lua")
DrGBase.IncludeFile("secondary.lua")

function SWEP:Initialize()
  self:SetHoldType(self.HoldType)
  self:_BaseInitialize()
  self:CustomInitialize()
end
function SWEP:_BaseInitialize() end
function SWEP:CustomInitialize() end

function SWEP:Think()
  self:_BaseThink()
  self:CustomThink()
end
function SWEP:_BaseThink() end
function SWEP:CustomThink() end

if CLIENT then

  function SWEP:MuzzleFlash()
    local light = DynamicLight(self:EntIndex())


  end

  local ThirdPerson = CreateClientConVar("drgbase_weapons_view", "0")
  hook.Add("CalcView", "DrGBaseWeaponsCalcView", function(ply, origin, angles, fov, znear, zfar)
    if not IsValid(ply) or not ply:Alive() or not IsValid(ply:GetActiveWeapon()) then return end
    if ply:DrG_IsPossessing() then return end
    if ply:InVehicle() then return end
    if not ply:GetActiveWeapon().IsDrGWeapon then return end
    if ThirdPerson:GetInt() ~= 1 and ThirdPerson:GetInt() ~= 2 then return end
    local view = {
      angles = angles,
      fov = fov,
      znear = znear,
      zfar = zfar,
      drawviewer = true
    }
    local center
    local offset
    if ThirdPerson:GetInt() == 2 then
      center = ply:GetBonePosition(ply:LookupBone("ValveBiped.Bip01_Head1"))
      offset = Vector(5, 5, 2.5)
    else
      local bound1, bound2 = ply:GetCollisionBounds()
      center = ply:GetPos() + (bound1 + bound2)/2
      offset = Vector(-100, 30, 20)
    end
    origin = center +
    ply:GetForward()*offset.x*ply:GetModelScale() +
    ply:GetRight()*offset.y*ply:GetModelScale() +
    ply:GetUp()*offset.z*ply:GetModelScale()
    local tr = util.TraceLine({
      start = center,
      endpos = origin,
      collisiongroup = COLLISION_GROUP_IN_VEHICLE
    })
    if tr.HitWorld then origin = tr.HitPos + tr.Normal*-10 end
    view.origin = origin
    return view
  end)

end
