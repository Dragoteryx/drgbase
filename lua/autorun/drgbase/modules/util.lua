DrGBase.Utils = DrGBase.Utils or {}

function util.DrG_RunTraces(starts, ends, data, callback)
  for i, start in ipairs(starts) do
    for h, endpos in ipairs(ends) do
      data.start = start
      data.endpos = endpos
      local tr = data.hull and util.TraceHull(data) or util.TraceLine(data)
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

function util.DrG_BitFlag(num, flag)
  return bit.band(num, flag) ~= 0
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

function util.DrG_BallisticTrace(start, velocity, data)
  data = data or {}
  local info = math.DrG_BallisticTrajectoryInfoVectors(start, velocity)
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

function util.DrG_SoundDistance(sound)
  if sound.SoundLevel > 0 then
    local lvl = sound.SoundLevel
    return 9*math.pow(5, (lvl-40)/20)*math.pow(2, 2+(lvl-40)/20)
  else return math.huge end
end
function util.DrG_DistanceToSoundLevel(distance)
  return 40+20*math.log10(distance/36)
end

if SERVER then

  function util.DrG_Explosion(pos, options)
    if isnumber(options) then options = {damage = options}
    elseif options == nil then options = {} end
    options.damage = options.damage or 0
    local explosion = ents.Create("env_explosion")
    explosion:SetPos(pos)
  	explosion:Spawn()
    explosion:SetKeyValue("iMagnitude", options.damage)
    if options.owner ~= nil then explosion:SetOwner(options.owner) end
  	if options.radius ~= nil then explosion:SetKeyValue("iRadiusOverride", options.radius) end
  	explosion:Fire("Explode", 0, 0)
  end

  function util.DrG_CreateProjectile(model, pos, angles, binds, class)
    local proj = ents.Create(class or "drgbase_projectile")
    if istable(model) and #model > 0 then model = model[math.random(#model)] end
    pos = pos or Vector(0, 0, 0)
    angles = angles or Angle(0, 0, 0)
    proj:SetPos(pos)
    proj:SetAngles(angles)
    if isfunction(binds.Init) then binds.Init(proj) end
    if isfunction(binds.Think) then proj.CustomThink = binds.Think end
    if isfunction(binds.Filter) then proj.CustomFilter = binds.Filter end
    if isfunction(binds.Contact) then proj.CustomContact = binds.Contact end
    if isfunction(binds.Use) then proj.CustomUse = binds.Use end
    if isfunction(binds.Damage) then proj.CustomDamage = binds.Damage end
    if isfunction(binds.Remove) then proj.CustomRemove = binds.Remove end
    proj:Spawn()
    if isstring(model) then proj:SetModel(model) end
    proj:PhysicsInit(SOLID_VPHYSICS)
    proj:SetMoveType(MOVETYPE_VPHYSICS)
    proj:SetSolid(SOLID_VPHYSICS)
    proj:SetUseType(SIMPLE_USE)
    local phys = proj:GetPhysicsObject()
    if IsValid(phys) then
      phys:Wake()
    end
    return proj
  end

else



end
