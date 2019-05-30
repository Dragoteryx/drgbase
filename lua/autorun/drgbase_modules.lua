
--[[local str = "modules/"
DrGBase.IncludeFiles({
  str.."coroutine.lua",
  str.."debugoverlay.lua",
  --str.."nodegraph.lua",
  str.."render.lua",
  str.."timer.lua",
  str.."util.lua",
})]]

-- COROUTINE --

local id = 0
local coroutines = {}
hook.Add("Think", "DrGBaseCoroutines", function()
  for id, co in pairs(coroutines) do
    local status = coroutine.status(co)
    if status == "suspended" then
			coroutine.resume(co)
		elseif status == "dead" then
			coroutine.DrG_Remove(id)
		end
  end
end)

function coroutine.DrG_Create(callback)
  local co = coroutine.create(callback)
  local curr = id
  id = id+1
  coroutines[curr] = co
  return co, curr
end
function coroutine.DrG_Remove(id)
  coroutines[id] = nil
end

-- DEBUGOVERLAY --

function debugoverlay.DrG_Trajectory(start, velocity, lifetime, color, ignoreZ, options)
  local info = start:DrG_TrajectoryInfo(velocity)
  options = options or {}
  options.from = options.from or 0
  options.to = options.to or 10
  options.increments = options.increments or 0.01
  if options.colors == nil then options.colors = function() end end
  if options.height == nil then options.height = true end
  local t = options.from
  while t < options.to do
    debugoverlay.Line(info.Predict(t), info.Predict(t + options.increments), lifetime, options.colors(t) or color, ignoreZ)
    t = t + options.increments
  end
  if options.height then
    local highestPoint = info.Predict(info.highest)
    local tr = util.TraceLine({
      start = highestPoint,
      endpos = highestPoint + Vector(0, 0, -999999999),
      collisiongroup = COLLISION_GROUP_IN_VEHICLE
    })
    debugoverlay.Line(highestPoint, tr.HitPos, lifetime, options.colors(info.highest) or color, ignoreZ)
  end
end

-- TIMER --

function timer.DrG_Loop(delay, callback)
  timer.Simple(delay, function()
    if callback() ~= false then timer.DrG_Loop(delay, callback) end
  end)
end

-- UTIL --

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
  dmg:SetAmmoType(data.ammoType)
  if IsValid(data.attacker) then
    dmg:SetAttacker(data.attacker)
  end
  dmg:SetDamage(data.damage)
  dmg:SetDamageBonus(data.damageBonus)
  dmg:SetDamageCustom(data.damageCustom)
  dmg:SetDamageForce(data.damageForce)
  dmg:SetDamagePosition(data.damagePosition)
  dmg:SetDamageType(data.damageType)
  if IsValid(data.inflictor) then
    dmg:SetInflictor(data.inflictor)
  end
  dmg:SetMaxDamage(data.maxDamage)
  dmg:SetReportedPosition(data.reportedPosition)
  return dmg
end

if SERVER then



else

  -- RENDER --

  function render.DrG_DrawTrajectory(start, velocity, color, writeZ, options)
    local info = start:DrG_TrajectoryInfo(velocity)
    options = options or {}
    options.from = options.from or 0
    options.to = options.to or 10
    options.increments = options.increments or 0.01
    local t = options.from
    while t < options.to do
      render.DrawLine(info.Predict(t), info.Predict(t+options.increments), color, writeZ)
      t = t+options.increments
    end
    if options.height then
      local highestPoint = info.Predict(info.highest)
      local tr = util.TraceLine({
        start = highestPoint,
        endpos = highestPoint + Vector(0, 0, -999999999),
        collisiongroup = COLLISION_GROUP_IN_VEHICLE
      })
      render.DrawLine(highestPoint, tr.HitPos, color, writeZ)
    end
  end

end
