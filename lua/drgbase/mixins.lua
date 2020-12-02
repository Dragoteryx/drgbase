-- Mixins --

local GenericMixin = DrGBase.IncludeFile("drgbase/mixins/generic.lua")
local NextbotMixin = DrGBase.IncludeFile("drgbase/mixins/nextbot.lua")
local ProjectileMixin = DrGBase.IncludeFile("drgbase/mixins/projectile.lua")
local SpawnerMixin = DrGBase.IncludeFile("drgbase/mixins/spawner.lua")
local WeaponMixin = DrGBase.IncludeFile("drgbase/mixins/weapon.lua")

local ENT_Waiting = {}
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
    if not extends then return end
    for i = 1, #mixins do
      mixins[i](ENT)
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
  elseif class == "weapon_base" then fn(false)
  else SWEP_Get(SWEP.Base, function(BASE)
    SWEP_Extends(BASE, SWEP.Base, base, fn)
  end) end
end
local function SWEP_Mixin(SWEP, class, base, mixins)
  SWEP_Extends(SWEP, class, base, function(extends)
    if not extends then return end
    for i = 1, #mixins do
      mixins[i](ENT)
    end
  end)
end

-- Entities --

hook.Add("PreRegisterSENT", "DrG/SENTMixins", function(ENT, class)
  ENT_Mixin(ENT, class, "drgbase_nextbot", {GenericMixin, NextbotMixin})
  ENT_Mixin(ENT, class, "drgbase_projectile", {GenericMixin, ProjectileMixin})
  ENT_Mixin(ENT, class, "drgbase_spawner", {GenericMixin, SpawnerMixin})
end)

-- Weapons --

hook.Add("PreRegisterSWEP", "DrG/SWEPMixins", function(SWEP, class)
  SWEP_Mixin(SWEP, class, "drgbase_weapon", {GenericMixin, WeaponMixin})
end)