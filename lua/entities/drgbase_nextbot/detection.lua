
-- Handlers --

function ENT:_InitDetection()
  if CLIENT then return end
  self:SetSightRange(self.SightRange)
  self:SetSightFOV(self.SightFOV)
  self:SetSightDuration(self.SightDuration)
  self:SetHearingCoefficient(self.HearingCoefficient)
  self._DrGBaseInSight = {}
  self._DrGBaseKeepSight = {}
  -- sight timer
  self:LoopTimer(0.25, function(self)
    if self:IsBlind() then return end
    for i, ent in ipairs(self:ConsideredEntities(true)) do
      if not IsValid(ent) then continue end
      local res = self:_CheckSight(ent)
      local crea = ent:GetCreationID()
      if res == self:IsInSight(ent) then
        self._DrGBaseKeepSight[crea] = self._DrGBaseKeepSight[crea] or 0
        if res then self:OnSight(ent) end
      else
        if self._DrGBaseKeepSight[crea] == nil then
          self._DrGBaseKeepSight[crea] = 0
        else self._DrGBaseKeepSight[crea] = self._DrGBaseKeepSight[crea] + 1 end
        if res then
          self._DrGBaseInSight[crea] = true
          self:OnSight(ent)
        else
          self._DrGBaseInSight[crea] = false
          self:OnLostSight(ent)
        end
      end
    end
  end)
end

if SERVER then

  -- Getters/setters --

  function ENT:GetSightRange()
    return self._DrGBaseSightRange
  end
  function ENT:SetSightRange(range)
    if range < 0 then range = 0 end
    self._DrGBaseSightRange = range
  end

  function ENT:GetSightFOV()
    return self._DrGBaseSightFOV
  end
  function ENT:SetSightFOV(fov)
    if fov < 0 then fov = 0 end
    if fov > 360 then fov = 360 end
    self._DrGBaseSightFOV = fov
  end

  function ENT:GetSightDuration()
    return self._DrGBaseSightDuration
  end
  function ENT:SetSightDuration(duration)
    if duration < 0 then duration = 0 end
    self._DrGBaseSightDuration = duration
  end

  function ENT:GetHearingCoefficient()
    return self._DrGBaseHearingCoefficient
  end
  function ENT:SetHearingCoefficient(coefficient)
    if coefficient < 0 then coefficient = 0 end
    self._DrGBaseHearingCoefficient = coefficient
  end

  -- Functions

  function ENT:IsBlind()
    return self:GetSightRange() == 0 or self:GetSightFOV() == 0
  end
  function ENT:IsInSight(ent)
    if self:IsBlind() then return false end
    if ent:IsPlayer() and not ent:Alive() then return false end
    return self._DrGBaseInSight[ent:GetCreationID()] or false
  end
  function ENT:KeepSight(ent, duration, callback)
    if not IsValid(ent) then return end
    if duration > 0 then
      if self:IsInSight(ent) then
        local curr = self._DrGBaseKeepSight[ent:GetCreationID()]
        self:Timer(duration, function()
          if not IsValid(ent) then return end
          callback(curr == self._DrGBaseKeepSight[ent:GetCreationID()])
        end)
      else
        self:Timer(duration, function()
          if not IsValid(ent) then return end
          callback(false)
        end)
      end
    else callback(self:IsInSight(ent)) end
  end

  function ENT:IsDeaf()
    return self:GetHearingCoefficient() == 0
  end

  function ENT:IsSeenBy(ent)
    if not ent.IsDrGNextbot then
      local fov = 75
      if ent:IsPlayer() then
        if GetConVar("ai_ignoreplayers"):GetBool() or
        ent:DrG_IsPossessing() then return false end
        fov = ent:GetFOV()
      end
      local eyepos = ent:EyePos()
      if math.DrG_DegreeAngle(eyepos + ent:EyeAngles():Forward(), self:WorldSpaceCenter(), eyepos) > fov then
        return false
      end
      return ent:Visible(self) or ent:VisibleVec(self:WorldSpaceCenter())
    else return ent:IsInSight(self) end
  end
  function ENT:SeenBy(ignoreallies)
    local entities = {}
    for i, ent in ipairs(self:ConsideredEntities()) do
      if not IsValid(ent) then continue end
      if ent == self then continue end
      if ignoreallies and self:IsAlly(ent) then continue end
      if self:IsSeenBy(ent) then table.insert(entities, ent) end
    end
    return entities
  end
  function ENT:IsSeen(ignoreallies)
    return #self:SeenBy(ignoreallies) ~= 0
  end

  -- Hooks --

  function ENT:OnSightCheck(ent) return true end
  function ENT:OnSight(ent)
    if self:HasLostEntity(ent) then
      self:KeepSight(ent, self:GetSightDuration(), function(sight)
        if sight then self:SpotEntity(ent) end
      end)
    else self:SpotEntity(ent) end
  end
  function ENT:OnLostSight() end
  function ENT:OnSound(ent, sound)
    self:SpotEntity(ent)
  end

  -- Handlers --

  function ENT:_CheckSight(ent)
    if self:EyePos():DistToSqr(ent:GetPos()) > self:GetSightRange()^2 then return false end
    local eyepos = self:EyePos()
    local angle = math.DrG_DegreeAngle(eyepos + self:EyeAngles():Forward(), ent:WorldSpaceCenter(), eyepos)
    if angle > self:GetSightFOV()/2 then return false end
    local los = self:Visible(ent)
    if los then
      return self:OnSightCheck(ent) or false
    else return false end
  end

  hook.Add("EntityEmitSound", "DrGBaseNextbotHearing", function(sound)
    if not IsValid(sound.Entity) then return end
    if #DrGBase.Nextbots.GetAll() == 0 then return end
    local pos = sound.Pos or sound.Entity:WorldSpaceCenter()
    local distance = math.pow(sound.SoundLevel/2, 2)*sound.Volume
    for i, nextbot in ipairs(DrGBase.Nextbots.GetAll()) do
      if nextbot:IsDeaf() then continue end
      if sound.Entity == nextbot then continue end
      local mult = nextbot:VisibleVec(pos) and 1 or 0.5
      if (distance*nextbot:GetHearingCoefficient()*mult)^2 >= nextbot:GetRangeSquaredTo(pos) then
        nextbot:OnSound(sound.Entity, sound)
      end
    end
  end)

else

  -- Getters/setters --

  -- Functions --

  -- Hooks --

  -- Handlers --

end
