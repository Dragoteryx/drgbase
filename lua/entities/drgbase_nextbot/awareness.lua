
function ENT:LineOfSight(ent, fov, range)
  if not IsValid(ent) then return false end
  if self:EntIndex() == ent:EntIndex() then return false end
  if range == nil then range = self.SightRange end
  if range <= 0 then return false end
  local sqrdist = self:GetRangeSquaredTo(ent)
  if sqrdist > math.pow(range, 2) then return false end
  if fov == nil then fov = self.SightFOV end
  if fov > 360 then fov = 360 end
  if fov <= 0 then return false end
  local entpos = ent:GetPos()
  local endpos = {ent:WorldSpaceCenter()}
  local min, max = ent:GetModelBounds()
  if min ~= nil and max ~= nil then
    for i = math.Round(min.z/10), math.Round(max.z/10) do
      table.insert(endpos, entpos + Vector(0, 0, i*10))
    end
  end
  local eyepos = self:DrG_EyePos()
  return DrGBase.Utils.RunTraces({eyepos}, endpos, {filter = {self}}, function(tr)
    if IsValid(tr.Entity) and
    (tr.Entity:EntIndex() == ent:EntIndex() or
    (SERVER and tr.Entity:IsVehicle() and IsValid(tr.Entity:GetDriver()) and tr.Entity:GetDriver():EntIndex() == ent:EntIndex())) then
      local angle = DrGBase.Math.VectorsAngle(eyepos + self:GetForward(), tr.HitPos, eyepos)
      return angle <= fov/2
    end
  end).res or false
end

function ENT:IsBlind()
  return self.SightFOV <= 0 or self.SightRange <= 0
end

if SERVER then

  function ENT:HasSpottedEntity(ent)
    if not IsValid(ent) then return false end
    if self.Omniscient then return true end
    if self:IsAlly(ent) and self.KnowAlliesPosition then return true end
    self._DrGBaseSpotted[ent:GetCreationID()] = self._DrGBaseSpotted[ent:GetCreationID()] or 0
    return CurTime() < self._DrGBaseSpotted[ent:GetCreationID()] + self.ForgetTime
  end

  local onspotentity = false
  function ENT:SpotEntity(ent)
    if not IsValid(ent) then return end
    if self:EntIndex() == ent:EntIndex() then return end
    if not self:HasSpottedEntity(ent) then
      self:_Debug("spotted entity '"..ent:GetClass().."' ("..ent:EntIndex()..").")
    end
    self._DrGBaseSpotted[ent:GetCreationID()] = CurTime()
    if not onspotentity then
      onspotentity = true
      self:OnSpotEntity(ent)
      onspotentity = false
    end
  end
  function ENT:OnSpotEntity() end

  function ENT:ForgetEntity(ent)
    if not IsValid(ent) then return end
    self._DrGBaseSpotted[ent:GetCreationID()] = 0
  end

  hook.Add("PostPlayerDeath", "DrGBaseNextbotPostPlayerDeathForget", function(ply)
    for i, nextbot in ipairs(DrGBase.Nextbot.GetAll()) do
      nextbot:ForgetEntity(ply)
    end
  end)

  function ENT:CanSeeEntity(ent)
    if self:LineOfSight(ent) then
      local res = self:OnSeeEntity(ent)
      if res == nil or res then return true end
    end
    return false
  end

  -- Handlers --

  function ENT:_HandleLineOfSight()
    if self:IsBlind() then return end
    if CurTime() < self._DrGBaseLOSCheckDelay then return end
    self._DrGBaseLOSCheckDelay = CurTime() + 1
    for i, ent in ipairs(self:GetTargettableEntities()) do
      if self:CanSeeEntity(ent) then self:SpotEntity(ent) end
    end
  end
  function ENT:OnSeeEntity() end

  hook.Add("EntityEmitSound", "DrGBaseEntityEmitSoundHearing", function(sound)
    if not IsValid(sound.Entity) or GetConVar("ai_disabled"):GetBool() then return end
    if not sound.Entity:DrG_IsTargettable() then return end
    for i, ent in ipairs(DrGBase.Nextbot.GetAll()) do
      if ent.HearingRange <= 0 then continue end
      if ent:GetRangeSquaredTo(sound.Entity) <= math.pow(ent.HearingRange, 2) then
        local heard = ent:OnHearEntity(sound.Entity, sound)
        if heard == nil or heard then ent:SpotEntity(sound.Entity) end
      end
    end
  end)
  function ENT:OnHearEntity() end

  hook.Add("EntityFireBullets", "DrGBaseEntityFireBullets", function(ent2, bullet)
    if not IsValid(ent2) or GetConVar("ai_disabled"):GetBool() then return end
    if not ent2:DrG_IsTargettable() then return end
    for i, ent in ipairs(DrGBase.Nextbot.GetAll()) do
      if ent.HearingRangeBullets <= 0 then continue end
      if ent:GetRangeSquaredTo(ent2) <= math.pow(ent.HearingRangeBullets, 2) then
        local heard = ent:OnHearGunshot(ent2, bullet)
        if heard == nil or heard then ent:SpotEntity(ent2) end
      end
    end
  end)
  function ENT:OnHearGunshot() end

else



end
