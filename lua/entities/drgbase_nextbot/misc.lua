-- Helpers --

function ENT:IsInRange(pos, range)
  if isentity(pos) and not IsValid(pos) then return false end
  return self:GetHullRangeSquaredTo(pos) <= range^2
end
function ENT:GetHullRangeTo(pos)
  if isentity(pos) then pos = pos:NearestPoint(self:GetPos()) end
  return self:NearestPoint(pos):Distance(pos)
end
function ENT:GetHullRangeSquaredTo(pos)
  if isentity(pos) then pos = pos:NearestPoint(self:GetPos()) end
  return self:NearestPoint(pos):DistToSqr(pos)
end

-- Misc --

local entMETA = FindMetaTable("Entity")

local old_EyePos = entMETA.EyePos
function entMETA:EyePos()
  if self.IsDrGNextbot then
    local eyepos = self:WorldSpaceCenter()
    local eyebone = self.EyeBone
    if isstring(eyebone) then eyebone = self:LookupBone(eyebone) end
    if isnumber(eyebone) then eyepos = self:GetBonePosition(eyebone) end
    return eyepos +
      self.EyeOffset.x*self:GetForward() +
      self.EyeOffset.y*self:GetRight() +
      self.EyeOffset.z*self:GetUp()
  else return old_EyePos(self) end
end

local old_EyeAngles = entMETA.EyeAngles
function entMETA:EyeAngles()
  if self.IsDrGNextbot then
    return self:GetAngles() + self.EyeAngle
  else return old_EyeAngles(self) end
end

if SERVER then

  -- Attacks --

  function ENT:DealDamage(attack, fn)
    local hit = {}
    local entities = ents.GetAll()
    for i = 1, #entities do
      local ent = entities[i]
      if not IsValid(ent) then continue end
      local dmg = DamageInfo()
      
    end
    return hit
  end

  -- Helpers --

  function ENT:IsInRangeAndSight(ent, range)
    return self:IsInRange(ent, range) and self:IsAbleToSee(ent)
  end

  function ENT:SafeSetPos(pos)
    if self:TraceHull(nil, {
      start = pos, endpos = pos
    }).Hit then return false end
    self:SetPos(pos)
    return true
  end

  -- Meta --

  local old_GetVelocity = entMETA.GetVelocity
  function entMETA:GetVelocity(...)
    if self.IsDrGNextbot then
      return self.loco:GetVelocity()
    else return old_GetVelocity(self, ...) end
  end

  local old_SetVelocity = entMETA.SetVelocity
  function entMETA:SetVelocity(velocity, ...)
    if self.IsDrGNextbot then
      return self.loco:SetVelocity(velocity)
    else return old_SetVelocity(self, velocity, ...) end
  end

  local old_GetGravity = entMETA.GetGravity
  function entMETA:GetGravity(...)
    if self.IsDrGNextbot then
      return self.loco:GetGravity()
    else return old_GetGravity(self, ...) end
  end

  local old_SetGravity = entMETA.SetGravity
  function entMETA:SetGravity(gravity, ...)
    if self.IsDrGNextbot then
      return self.loco:SetGravity(gravity)
    else return old_SetGravity(self, gravity, ...) end
  end

  local nextbotMETA = FindMetaTable("NextBot")

  local old_BecomeRagdoll = nextbotMETA.BecomeRagdoll
  function nextbotMETA:BecomeRagdoll(...)
    if self.IsDrGNextbot then
      return self:DrG_BecomeRagdoll(...) -- calls self:OnRagdoll
    else return old_BecomeRagdoll(self, ...) end
  end

  -- Hooks --

  function ENT:OnRagdoll(_ragdoll, _dmg) end

else

  -- Getters --

  function ENT:GetRangeTo(pos)
    if isentity(pos) then pos = pos:GetPos() end
    return self:GetPos():Distance(pos)
  end

  function ENT:GetRangeSquaredTo(pos)
    if isentity(pos) then pos = pos:GetPos() end
    return self:GetPos():DistToSqr(pos)
  end

end