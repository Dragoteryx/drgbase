-- Helpers --

function ENT:IsInRange(pos, range)
  if isentity(pos) then pos = pos:GetPos() end
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

if SERVER then

  -- Attacks --

  function ENT:Attack(attack, fn)
    if not istable(attack) then attack = {} end
    if isnumber(attack.delay) or isfunction(fn) then
      self:Timer(isnumber(attack.delay) and attack.delay or 0, function(self)
        local hit = self:Attack(attack)
        if isfunction(fn) then fn(self, hit) end
      end)
    else
      -- attack code
    end
  end

  -- Helpers --

  function ENT:SafeSetPos(pos)
    if self:DrG_TraceHull(nil, {
      start = pos, endpos = pos
    }).Hit then return false end
    self:SetPos(pos)
    return true
  end

  -- Meta --

  local entMETA = FindMetaTable("Entity")

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