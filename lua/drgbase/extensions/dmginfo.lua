
local dmgMETA = FindMetaTable("CTakeDamageInfo")

local DMG_SAVES = {}
function dmgMETA:DrG_Save(name)
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
  if isstring(name) then DMG_SAVES[name] = data end
  return data
end
function dmgMETA:DrG_Load(data)
  if isstring(data) then data = DMG_SAVES[data] end
  if not istable(data) then return false end
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
  return true
end
