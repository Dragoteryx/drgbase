
function util.DrG_TrajectoryTrace(start, velocity, data)
  data = data or {}
  local info = start:DrG_TrajectoryInfo(velocity)
  local tr = {HitPos = false}
  local t = 0
  while true do
    data.start = info.Predict(t)
    data.endpos = info.Predict(t + 0.01)
    tr = util.TraceLine(data)
    if tr.Hit then
      tr.StartPos = start
      return tr
    else t = t + 0.01 end
  end
end

function util.DrG_SaveDmg(dmg)
  local data = {}
  data.ammoType = dmg:GetAmmoType()
  data.attacker = dmg:GetAttacker()
  data.baseDamage = dmg:GetBaseDamage()
  data.damage = dmg:GetDamage()
  data.damageBonus = dmg:GetDamageBonus()
  data.damageCustom = dmg:GetDamageCustom()
  data.damageForce = dmg:GetDamageForce()
  data.damagePosition = dmg:GetDamagePosition()
  data.damageType = dmg:GetDamageType()
  data.inflictor = dmg:GetInflictor()
  data.maxDamage = dmg:GetMaxDamage()
  data.reportedPosition = dmg:GetReportedPosition()
  return data
end
function util.DrG_LoadDmg(data)
  local dmg = DamageInfo()
  if not istable(data) then return end
  smg:SetAmmoType(data.ammoType)
  if IsValid(data.attacker) then
    smg:SetAttacker(data.attacker)
  end
  smg:SetDamage(data.damage)
  smg:SetDamageBonus(data.damageBonus)
  smg:SetDamageCustom(data.damageCustom)
  smg:SetDamageForce(data.damageForce)
  smg:SetDamagePosition(data.damagePosition)
  smg:SetDamageType(data.damageType)
  if IsValid(data.inflictor) then
    smg:SetInflictor(data.inflictor)
  end
  smg:SetMaxDamage(data.maxDamage)
  smg:SetReportedPosition(data.reportedPosition)
  return dmg
end
