local GenericMixin = DrGBase.IncludeFile("drgbase/mixins/generic.lua")
local NextbotMixin = DrGBase.IncludeFile("drgbase/mixins/nextbot.lua")
local ProjectileMixin = DrGBase.IncludeFile("drgbase/mixins/projectile.lua")
local SpawnerMixin = DrGBase.IncludeFile("drgbase/mixins/spawner.lua")
local WeaponMixin = DrGBase.IncludeFile("drgbase/mixins/weapon.lua")

local old_Register = scripted_ents.Register
function scripted_ents.Register(ENT, class, ...)
  if not ENT.DrGBase_NoMixins and
  not ENT._DrGBase_MixedIn then
    ENT._DrGBase_MixedIn = true
    GenericMixin(ENT)
    NextbotMixin(ENT)
    ProjectileMixin(ENT)
    SpawnerMixin(ENT)
  end
  return old_Register(ENT, class, ...)
end

local old_WeaponRegister = weapons.Register
function weapons.Register(SWEP, class, ...)
  if not SWEP.DrGBase_NoMixins and
  not SWEP._DrGBase_MixedIn then
    SWEP._DrGBase_MixedIn = true
    GenericMixin(SWEP)
    WeaponMixin(SWEP)
  end
  return old_WeaponRegister(SWEP, class, ...)
end