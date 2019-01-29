DrGBase.Utils = DrGBase.Utils or {}

function DrGBase.Utils.RunTraces(starts, ends, data, callback)
  for i, start in ipairs(starts) do
    for h, endpos in ipairs(ends) do
      data.start = start
      data.endpos = endpos
      local tr = util.TraceLine(data)
      local res = callback(tr, data)
      if res ~= nil then return {
        data = data,
        tr = tr,
        res = res,
        startKey = i,
        endposKey = h
      } end
    end
  end
  return {
    data = {},
    tr = {},
    res = nil,
    startKey = -1,
    endposKey = -1
  }
end

local coroutines = {}
hook.Add("Think", "DrGBaseCoroutines", function()
  for i, co in ipairs(coroutines) do
    local status = coroutine.status(co)
    if status == "suspended" then
			coroutine.resume(co)
		elseif status == "dead" then
			table.RemoveByValue(coroutines, co)
		end
  end
end)

function DrGBase.Utils.Coroutine(callback)
  local co = coroutine.create(callback)
  table.insert(coroutines, co)
end

function DrGBase.Utils.ConvertDamage(dmg)
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

function DrGBase.Utils.RecreateDamage(data)
  local dmg = DamageInfo()
  dmg:SetAmmoType(data.ammoType)
  if IsValid(data.attacker) then dmg:SetAttacker(data.attacker) end
  -- data.baseDamage is not used
  dmg:SetDamage(data.damage)
  dmg:SetDamageBonus(data.damageBonus)
  dmg:SetDamageCustom(data.damageCustom)
  dmg:SetDamageForce(data.damageForce)
  dmg:SetDamagePosition(data.damagePosition)
  dmg:SetDamageType(data.damageType)
  if IsValid(data.inflictor) then dmg:SetInflictor(data.inflictor) end
  dmg:SetMaxDamage(data.maxDamage)
  dmg:SetReportedPosition(data.reportedPosition)
  return dmg
end

function DrGBase.Utils.RandomPos(pos, maxradius, minradius, nodegraph)
  minradius = minradius or 0
  if nodegraph or CLIENT then
    local node = DrGBase.Nodegraph.RandomNode(pos, maxradius, minradius)
    if node ~= nil then return node:GetPos() end
  elseif navmesh.IsLoaded() then
    local point = nil
    while point == nil do
      local x = math.random(minradius, maxradius)
      local y = math.random(minradius, maxradius)
      if math.random(2) == 2 then x = x*-1 end
      if math.random(2) == 2 then y = y*-1 end
      local area = navmesh.GetNearestNavArea(pos + Vector(x, y, 0))
      if area ~= nil then point = area:GetRandomPoint() end
    end
    return point
  end
end

function DrGBase.Utils.BitFlag(num, flag)
  return bit.band(num, flag) ~= 0
end

if SERVER then

  function DrGBase.Utils.Explosion(pos, options)
    if options == nil then options = {} end
    if type(options) == "number" then options = {magnitude = options} end
    options.damage = options.damage or 0
    local explosion = ents.Create("env_explosion")
  	if options.owner ~= nil then explosion:SetOwner(options.owner) end
    explosion:SetPos(pos)
  	explosion:Spawn()
    explosion:SetKeyValue("iMagnitude", options.damage)
  	if options.radius ~= nil then explosion:SetKeyValue("iRadiusOverride", options.radius) end
  	explosion:Fire("Explode", 0, 0)
  end

else

  

end
