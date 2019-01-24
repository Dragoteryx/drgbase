
function ENT:LineOfSight(ent, fov, range)
  if not IsValid(ent) then return false end
  if self:EntIndex() == ent:EntIndex() then return false end
  if range == nil then range = self.SightRange*self:GetScale() end
  if range <= 0 then return false end
  if self:EyePos():DistToSqr(ent:GetPos()) > math.pow(range, 2) then return false end
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
  local eyepos = self:EyePos()
  return DrGBase.Utils.RunTraces({eyepos}, endpos, {filter = {self}}, function(tr)
    if IsValid(tr.Entity) and
    (tr.Entity:EntIndex() == ent:EntIndex() or
    (SERVER and tr.Entity:IsVehicle() and IsValid(tr.Entity:GetDriver()) and tr.Entity:GetDriver():EntIndex() == ent:EntIndex())) then
      local angle = DrGBase.Math.VectorsAngle(eyepos + self:EyeAngles():Forward(), tr.HitPos, eyepos)
      return angle <= fov/2
    end
  end).res or false
end

function ENT:IsBlind()
  return self.SightFOV <= 0 or self.SightRange <= 0
end

function ENT:IsSeenBy(ent)
  if ent.IsDrGNextbot then
    return ent:CanSeeEntity(self)
  elseif ent:IsPlayer() then
    if GetConVar("ai_ignoreplayers"):GetBool() then return false end
    if ent:DrG_IsPossessing() then return false end
    return ent:VisibleVec(self:WorldSpaceCenter()) and
    DrGBase.Math.VectorsAngle(ent:EyePos() + ent:EyeAngles():Forward(), self:GetPos(), ent:EyePos()) < ent:GetFOV()/2 + 10
  elseif ent:IsNPC() then
    return ent:Visible(self)
  else return false end
end
function ENT:SeenBy(ignoreallies)
  local entities = {}
  for i, ent in ipairs(self:GetTargettableEntities()) do
    if not IsValid(ent) then continue end
    if ent:EntIndex() == self:EntIndex() then continue end
    if self:IsSeenBy(ent) and not (ignoreallies and self:IsAlly(ent)) then
      table.insert(entities, ent)
    end
  end
  return entities
end
function ENT:IsSeen(ignoreallies)
  return #self:SeenBy(ignoreallies) ~= 0
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
    self:_Debug("spotted entity '"..ent:GetClass().."' ("..ent:EntIndex()..").")
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
    self:_Debug("spotted entity '"..ent:GetClass().."' ("..ent:EntIndex()..").")
    self._DrGBaseSpotted[ent:GetCreationID()] = 0
  end

  hook.Add("PostPlayerDeath", "DrGBaseNextbotPostPlayerDeathForget", function(ply)
    for i, ent in ipairs(DrGBase.Nextbot.GetAll()) do
      ent:ForgetEntity(ply)
    end
  end)

  function ENT:CanSeeEntity(ent)
    if self:LineOfSight(ent) then
      local res = self:OnSeeEntity(ent)
      if res ~= false then return true end
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
    if not IsValid(sound.Entity) then return end
    for i, ent in ipairs(DrGBase.Nextbot.GetAll()) do
      if ent.HearingRange == nil then continue end
      if ent.HearingRange <= 0 then continue end
      if ent:GetRangeSquaredTo(sound.Entity) <= math.pow(ent.HearingRange, 2) then
        local heard = ent:OnHearEntity(sound.Entity, sound)
        if heard ~= false then ent:SpotEntity(sound.Entity) end
      end
    end
  end)
  function ENT:OnHearEntity() end

  hook.Add("EntityFireBullets", "DrGBaseEntityFireBullets", function(ent2, bullet)
    if not IsValid(ent2) then return end
    for i, ent in ipairs(DrGBase.Nextbot.GetAll()) do
      if ent.HearingRangeBullets == nil then continue end
      if ent.HearingRangeBullets <= 0 then continue end
      if ent:GetRangeSquaredTo(ent2) <= math.pow(ent.HearingRangeBullets, 2) then
        local heard = ent:OnHearGunshot(ent2, bullet)
        if heard ~= false then ent:SpotEntity(ent2) end
      end
    end
  end)
  function ENT:OnHearGunshot() end

else



end
