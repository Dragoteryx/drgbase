local dmgMETA = FindMetaTable("CTakeDamageInfo")

-- flags

local DmgFlags = DrGBase.FlagsHelper(32)

local FLAGS = {}
local function GetFlags(name)
  FLAGS[name] = FLAGS[name] or DmgFlags()
  return FLAGS[name]
end

function dmgMETA:DrG_GetFlags(name, flags)
  return GetFlags(name):GetFlags(flags)
end
function dmgMETA:DrG_AddFlags(name, flags)
  return GetFlags(name):AddFlags(flags)
end
function dmgMETA:DrG_RemoveFlags(name, flags)
  return GetFlags(name):RemoveFlags(flags)
end
function dmgMETA:DrG_IsFlagSet(name, flags)
  return GetFlags(name):IsFlagSet(flags)
end

hook.Add("PostEntityTakeDamage", "DrG/ResetDamageFlags", function()
  FLAGS = {}
end)

-- misc

function dmgMETA:DrG_Get()
  local data = {}
  data.ammoType = self:GetAmmoType()
  data.attacker = self:GetAttacker()
  data.baseDamage = self:GetBaseDamage()
  data.damage = self:GetDamage()
  data.damageBonus = self:GetDamageBonus()
  data.damageCustom = self:GetDamageCustom()
  data.damageForce = self:GetDamageForce()
  data.damagePosition = self:GetDamagePosition()
  data.damageType = self:GetDamageType()
  data.inflictor = self:GetInflictor()
  data.maxDamage = self:GetMaxDamage()
  data.reportedPosition = self:GetReportedPosition()
  data.drg_flags = {}
  for name, flags in pairs(FLAGS) do
    data.drg_flags[name] = flags:GetFlags()
  end
  return data
end

function dmgMETA:DrG_Set(data)
  if not istable(data) then return self end
  self:SetAmmoType(data.ammoType)
  if IsValid(data.attacker) then
    self:SetAttacker(data.attacker)
  end
  self:SetDamage(data.damage)
  self:SetDamageBonus(data.damageBonus)
  self:SetDamageCustom(data.damageCustom)
  self:SetDamageForce(data.damageForce)
  self:SetDamagePosition(data.damagePosition)
  self:SetDamageType(data.damageType)
  if IsValid(data.inflictor) then
    self:SetInflictor(data.inflictor)
  end
  self:SetMaxDamage(data.maxDamage)
  self:SetReportedPosition(data.reportedPosition)
  for name, flags in data.drg_flags do
    self:AddDrGFlags(name, flags)
  end
  return self
end

-- function stuff

local old_DamageInfo = DamageInfo
function DamageInfo(data)
  FLAGS = {}
  local dmg = old_DamageInfo()
  if istable(data) then dmg:DrG_Set(data) end
  return dmg
end