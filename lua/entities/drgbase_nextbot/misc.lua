
-- Print --

function ENT:PrintBones()
  for i = 0, self:GetBoneCount() - 1 do
    local bonename = self:GetBoneName(i)
    if bonename == nil then continue end
    print(i.." => "..bonename)
  end
end
function ENT:PrintAttachments()
  for i, attach in ipairs(self:GetAttachments()) do
    print(attach.id.." => "..attach.name)
  end
end

-- Helpers --

function ENT:Timer(delay, callback)
  timer.Simple(delay, function()
    if not IsValid(self) then return end
    return callback()
  end)
end
function ENT:LoopTimer(delay, callback)
  timer.DrG_Loop(delay, function()
    if not IsValid(self) then return false end
    return callback()
  end)
end

function ENT:Altitude()
  local tr = util.TraceLine({
    start = self:GetPos(),
    endpos = self:GetPos() - Vector(0, 0, 999999999),
    collisiongroup = COLLISION_GROUP_IN_VEHICLE
  })
  if tr.HitWorld then return self:GetPos().z - tr.HitPos.z
  else return 0 end
end

function ENT:RandomBodygroup(id)
  self:SetBodygroup(id, math.random(0, self:GetBodygroupCount(id)-1))
end
function ENT:RandomBodygroups()
  for i, bodygroup in ipairs(self:GetBodyGroups()) do
    self:RandomBodygroup(bodygroup.id)
  end
end

function ENT:InRange(ent, dist)
  return self:GetRangeSquaredTo(ent:GetPos()) <= math.pow(dist*self:GetScale(), 2)
end
function ENT:FindInRange(dist)
  local entities = {}
  for i, ent in ipairs(self:GetTargets()) do
    if not IsValid(ent) then continue end
    if ent:EntIndex() == self:EntIndex() then continue end
    if not self:InRange(ent, dist) then continue end
    table.insert(entities, ent)
  end
  return entities
end

-- Getters --

function ENT:GetScale()
  return self:GetDrGVar("DrGBaseScale")
end

function ENT:CombineBall(value)
  if CLIENT then return self:GetDrGVar("DrGBaseCombineBall")
  elseif isstring(value) then self:SetDrGVar("DrGBaseCombineBall", value)
  else return self:GetDrGVar("DrGBaseCombineBall") end
end

-- Info --

function ENT:IsDying()
  return self:GetDrGVar("DrGBaseDying")
end
function ENT:IsDead()
  return self:IsDying() or self:GetDrGVar("DrGBaseDead")
end
function ENT:Alive()
  return not self:IsDead()
end
function ENT:IsAlive()
  return self:Alive()
end

function ENT:AnglePos(pos)
  return math.DrG_DegreeAngle(self:GetPos() + self:GetForward(), pos, self:GetPos())
end
function ENT:AngleEntity(ent)
  return self:AnglePos(ent:GetPos())
end

if SERVER then
  util.AddNetworkString("DrGBaseData")

  -- Helpers --

  function ENT:RandomPos(maxradius, minradius)
    return util.DrG_RandomPos(self:GetPos(), maxradius, minradius)
  end

  function ENT:Kill(attacker, inflictor)
    local dmg = DamageInfo()
    dmg:SetDamage(self:Health())
    dmg:SetAttacker(attacker or self)
    dmg:SetInflictor(inflictor or self)
    self:TakeDamageInfo(dmg)
  end
  function ENT:KillSilent(attacker, inflictor)
    self._DrGBaseKillSilent = true
    self:Kill(attacker, inflictor)
  end

  function ENT:SendData(name, data)
    net.Start("DrGBaseData")
    local compressed = util.Compress(util.TableToJSON({
      ent = self:EntIndex(),
      name = name, data = data
    }))
    net.WriteData(compressed, #compressed)
    net.Broadcast()
    self:_Debug("sent data: '"..name.."'.")
  end

  function ENT:TraceHull(data, steps)
    local bound1, bound2 = self:GetCollisionBounds()
    if bound1.z < bound2.z then
      local temp = bound1
      bound1 = bound2
      bound2 = temp
    end
    if steps then bound2.z = self.loco:GetStepHeight() end
    data = data or {}
    if data.start == nil then
      local center = self:GetPos() + (bound1 + bound2)/2
      center.z = self:GetPos().z
      data.start = center
    end
    data.maxs = bound1
    data.mins = bound2
    return util.TraceHull(data)
  end

  function ENT:CollisionHulls(distance, forwardOnly)
    distance = distance or 5
    if distance < 0 then distance = 0 end
    local bound1, bound2 = self:GetCollisionBounds()
    if bound1.z < bound2.z then
      local temp = bound1
      bound1 = bound2
      bound2 = temp
    end
    bound2.z = self.loco:GetStepHeight()
    local center = self:GetPos() + (bound1 + bound2)/2
    center.z = self:GetPos().z
    local data = {
      start = center,
      filter = {self, self:GetWeapon(), self:GetEnemy()},
      collisiongroup = self:GetCollisionGroup(),
      mask = self:GetSolidMask(),
      maxs = bound1, mins = bound2
    }
    data.endpos = center + self:GetForward()*distance + self:GetRight()*-distance
    local trNW = util.TraceHull(data)
    data.endpos = center + self:GetForward()*distance + self:GetRight()*distance
    local trNE = util.TraceHull(data)
    if forwardOnly then
      return {
        NorthWest = trNW,
        NorthEast = trNE
      }
    else
      data.endpos = center + self:GetForward()*-distance + self:GetRight()*distance
      local trSE = util.TraceHull(data)
      data.endpos = center + self:GetForward()*-distance + self:GetRight()*-distance
      local trSW = util.TraceHull(data)
      return {
        NorthWest = trNW,
        NorthEast = trNE,
        SouthEast = trSE,
        SouthWest = trSW
      }
    end
  end

  -- Setters --

  function ENT:SetScale(scale)
    self:SetDrGVar("DrGBaseScale", scale)
    self:SetModelScale(self.ModelScale*scale)
  end

  function ENT:Scale(mult)
    self:SetScale(self:GetScale()*mult)
  end

  function ENT:SetNoTarget(bool)
    if bool then self:AddFlags(FL_NOTARGET)
    else self:RemoveFlags(FL_NOTARGET) end
  end

  -- HitGroups --

  function ENT:DefineHitGroup(name, bones)
    if self._DrGBaseHitGroups[name] ~= nil then self:RemoveHitGroup(name) end
    if not istable(bones) then bones = {bones} end
    self._DrGBaseHitGroups[name] = {}
    for i, bone in ipairs(bones) do
      if isstring(bone) then bone = self:LookupBone(bone) end
      if not isnumber(bone) then continue end
      self._DrGBaseHitGroups[name][bone] = true
      self._DrGBaseNbHitGroups = self._DrGBaseNbHitGroups + 1
    end
  end
  function ENT:RemoveHitGroup(name)
    if self._DrGBaseHitGroups[name] == nil then return end
    self._DrGBaseHitGroups[name] = nil
    self._DrGBaseNbHitGroups = self._DrGBaseNbHitGroups - 1
  end
  function ENT:FetchHitGroups(dmg)
    if self._DrGBaseNbHitGroups == 0 then return {}, "" end
    local pos = dmg:GetDamagePosition()
    local closestbone = nil
    local dist = math.huge
    for i = 0, self:GetBoneCount() - 1 do
      local bonename = self:GetBoneName(i)
      if bonename == nil then continue end
      local bonepos = self:GetBonePosition(i)
      local bonedist = pos:DistToSqr(bonepos)
      if bonedist < dist then
        closestbone = bonename
        dist = bonedist
      end
    end
    local hitgroups = {}
    if closestbone ~= nil then
      local closestboneid = self:LookupBone(closestbone)
      for name, hitgroup in pairs(self._DrGBaseHitGroups) do
        if hitgroup == nil then continue end
        hitgroups[name] = hitgroup[closestboneid] or false
      end
    end
    return hitgroups, closestbone
  end

  -- Hooks --

  hook.Add("PhysgunDrop", "DrGBaseNextbotPhysgunDrop", function(ply, ent)
    if not ent.IsDrGNextbot then return end
    ent:InvalidatePath()
    ent:Timer(0, function()
      ent:SetVelocity(Vector(0, 0, 0))
    end)
  end)

  -- Handlers --

  function ENT:_HandleHealthRegen()
    if CurTime() < self._DrGBaseHealthRegenDelay then return end
    self._DrGBaseHealthRegenDelay = CurTime() + 1
    if self.HealthRegen > 0 then
      local health = self:Health() + self.HealthRegen
      if health > self:GetMaxHealth() then health = self:GetMaxHealth() end
      self:SetHealth(health)
    elseif self.HealthRegen < 0 then
      local dmg = DamageInfo()
      dmg:SetDamage(self.HealthRegen)
      dmg:SetAttacker(self)
      dmg:SetInflictor(self)
      dmg:SetDamageType(DMG_DIRECT)
      self:TakeDamageInfo(dmg)
    end
  end

else

  -- Helpers --

  function ENT:GetRangeTo(pos)
    if not isvector(pos) then pos = pos:GetPos() end
    return self:GetPos():Distance(pos)
  end
  function ENT:GetRangeSquaredTo(pos)
    if not isvector(pos) then pos = pos:GetPos() end
    return self:GetPos():DistToSqr(pos)
  end

  function ENT:ReceiveData() end
  net.Receive("DrGBaseData", function(len)
    local tab = util.JSONToTable(util.Decompress(net.ReadData(len/8)))
    local ent = Entity(tab.ent)
    if not IsValid(ent) then return end
    ent:_Debug("received data: '"..tab.name.."'.")
    ent:ReceiveData(tab.name, tab.data)
  end)

end
