
function ENT:_Debug(text)
  if not GetConVar("developer"):GetBool() then return end
  DrGBase.Print("Nextbot '"..self:GetClass().."' ("..self:EntIndex().."): "..text)
end

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

function ENT:Height()
  local bound1, bound2 = self:GetCollisionBounds()
  return math.abs(bound1.z - bound2.z)
end

function ENT:HeightVector()
  return Vector(0, 0, self:Height())
end

function ENT:Altitude()
  local tr = util.TraceLine({
    start = self:GetPos(),
    endpos = self:GetPos() - Vector(0, 0, 999999),
    collisiongroup = COLLISION_GROUP_IN_VEHICLE
  })
  if tr.HitWorld then return self:GetPos().z - tr.HitPos.z
  else return 0 end
end

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

function ENT:CombineBall(value)
  if CLIENT then return self:GetDrGVar("DrGBaseCombineBall")
  elseif isstring(value) then self:SetDrGVar("DrGBaseCombineBall", value)
  else return self:GetDrGVar("DrGBaseCombineBall") end
end

function ENT:AnglePos(pos)
  return math.DrG_DegreeAngle(self:GetPos() + self:GetForward(), pos, self:GetPos())
end

function ENT:AngleEntity(ent)
  return self:AnglePos(ent:GetPos())
end

function ENT:GetScale()
  return self:GetDrGVar("DrGBaseScale")
end

function ENT:InRange(ent, dist)
  return self:GetPos():DistToSqr(ent:GetPos()) <= math.pow(dist*self:GetScale(), 2)
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

function ENT:PrintBones()
  for i = 0, self:GetBoneCount() - 1 do
    local bonename = self:GetBoneName(i)
    if bonename == nil then continue end
    print(i.." => "..bonename)
  end
end

if SERVER then

  function ENT:RandomPos(maxradius, minradius)
    local pos = util.DrG_RandomPos(self:GetPos(), maxradius, minradius)
    if pos == nil then return self:GetPos()
    else return pos end
  end

  function ENT:Kill(attacker, inflictor)
    local dmg = DamageInfo()
    dmg:SetDamage(self:Health())
    if attacker ~= nil then dmg:SetAttacker(attacker) end
    if inflictor ~= nil then dmg:SetInflictor(inflictor) end
    self:TakeDamageInfo(dmg)
  end

  hook.Add("PhysgunDrop", "DrGBaseNextbotPhysgunDrop", function(ply, ent)
    if not ent.IsDrGNextbot then return end
    ent:InvalidatePath()
    ent:Timer(0, function()
      ent.loco:SetVelocity(Vector(0, 0, 0))
    end)
  end)

  function ENT:SetScale(scale)
    self:SetDrGVar("DrGBaseScale", scale)
    self:SetModelScale(self.ModelScale*scale)
  end

  function ENT:Scale(mult)
    self:SetScale(self:GetScale()*mult)
  end

  function ENT:DefineHitGroup(name, bones)
    if not istable(bones) then bones = {bones} end
    self._DrGBaseHitGroups[name] = {}
    for i, bone in ipairs(bones) do
      if isstring(bone) then bone = self:LookupBone(bone) end
      if not isnumber(bone) then continue end
      self._DrGBaseHitGroups[name][bone] = true
    end
  end
  function ENT:RemoveHitGroup(name)
    self._DrGBaseHitGroups[name] = nil
  end
  function ENT:FetchHitGroups(dmg)
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

  -- Handlers --

  function ENT:_HandleHealthRegen()
    if CurTime() < self._DrGBaseHealthRegenDelay then return end
    self._DrGBaseHealthRegenDelay = CurTime() + (1/self.HealthRegen)
    local health = self:Health() + 1
    if health < 0 then health = 0 end
    if health > self:GetMaxHealth() then health = self:GetMaxHealth() end
    self:SetHealth(health)
  end

else

  function ENT:GetRangeTo(pos)
    if not isvector(pos) then pos = pos:GetPos() end
    return self:GetPos():Distance(pos)
  end
  function ENT:GetRangeSquaredTo(pos)
    if not isvector(pos) then pos = pos:GetPos() end
    return self:GetPos():DistToSqr(pos)
  end

end
