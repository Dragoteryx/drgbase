-- Mixins --

local GenericMixin = DrGBase.IncludeFile("drgbase/mixins/generic.lua")
local NextbotMixin = DrGBase.IncludeFile("drgbase/mixins/nextbot.lua")
local ProjectileMixin = DrGBase.IncludeFile("drgbase/mixins/projectile.lua")
local SpawnerMixin = DrGBase.IncludeFile("drgbase/mixins/spawner.lua")
local WeaponMixin = DrGBase.IncludeFile("drgbase/mixins/weapon.lua")

local function ENT_Get(class, fn)
  local ENT = scripted_ents.Get(class)
  if ENT then fn(ENT)
  else

  end
end
local function ENT_Extends(ENT, class, base, fn)
  if class == base then fn(true)
  elseif ENT.Base == base then fn(true)
  elseif class == "base_entity" then fn(false)
  else ENT_Get(ENT.Base, function(BASE)
    ENT_Extends(BASE, ENT.Base, base, fn)
  end) end
end
local function ENT_Mixin(ENT, class, base, mixins)
  ENT_Extends(ENT, class, base, function(extends)
    if extends then
      for i = 1, #mixins do
        mixins[i](ENT)
      end
    end
  end)
end

local function SWEP_Get(class, fn)
  local SWEP = weapons.Get(class)
  if SWEP then fn(SWEP)
  else

  end
end
local function SWEP_Extends(SWEP, class, base, fn)
  if class == base then fn(true)
  elseif SWEP.Base == base then fn(true)
  elseif class == "base_weapon" then fn(false)
  else SWEP_Get(SWEP.Base, function(BASE)
    SWEP_Extends(BASE, SWEP.Base, base, fn)
  end) end
end
local function SWEP_Mixin(SWEP, class, base, mixins)
  SWEP_Extends(SWEP, class, base, function(extends)
    if extends then
      for i = 1, #mixins do
        mixins[i](ENT)
      end
    end
  end)
end

-- Entities --

DrG_Old_Register = DrG_Old_Register or scripted_ents.Register
function scripted_ents.Register(ENT, class, ...)
  -- mixins
  ENT_Mixin(ENT, class, "drgbase_nextbot", {
    GenericMixin, NextbotMixin
  })
  ENT_Mixin(ENT, class, "drgbase_projectile", {
    GenericMixin, ProjectileMixin
  })
  ENT_Mixin(ENT, class, "drgbase_spawner", {
    GenericMixin, SpawnerMixin
  })

  -- register
  return DrG_Old_Register(ENT, class, ...)
end

-- Weapons --

DrG_Old_WeaponRegister = DrG_Old_WeaponRegister or weapons.Register
function weapons.Register(SWEP, class, ...)
  -- mixins
  SWEP_Mixin(SWEP, class, "drgbase_weapon", {
    GenericMixin, WeaponMixin
  })

  -- register
  return DrG_Old_WeaponRegister(SWEP, class, ...)
end