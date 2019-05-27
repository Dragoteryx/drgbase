
-- Getters/setters --

function ENT:GetSightFOV()
  return self:GetNW2Int("DrGBaseSightFOV")
end
function ENT:GetSightRange()
  return self:GetNW2Int("DrGBaseSightRange")
end
function ENT:IsBlind()
  return self:GetSightFOV() <= 0 or self:GetSightRange() <= 0
end

function ENT:GetHearingCoefficient()
  return self:GetNW2Int("DrGBaseHearingCoefficient")
end
function ENT:IsDeaf()
  return self:GetHearingCoefficient() <= 0
end

-- Functions --

-- Hooks --

-- Handlers --

function ENT:_InitDetection()
  if CLIENT then return end
  self:SetSightFOV(self.SightFOV)
  self:SetSightRange(self.SightRange)
  self:SetHearingCoefficient(self.HearingCoefficient)
  self._DrGBaseSight = {}
  self:LoopTimer(0.25, function()
    for i, ent in ipairs(self:ConsideredEntities()) do
      local crea = ent:GetCreationID()
      local res = self:IsInSight(ent)
      if res and not self._DrGBaseSight[crea] then
        self._DrGBaseSight[crea] = true
        self:OnSight(ent, true)
      elseif not res and self._DrGBaseSight[crea] then
        self._DrGBaseSight[crea] = false
        self:OnLostSight(ent)
      elseif res and self._DrGBaseSight[crea] then
        self:OnSight(ent, false)
      end
    end
  end)
end

if SERVER then

  -- Getters/setters --

  function ENT:SetSightFOV(angle)
    if angle > 360 then angle = 360 end
    if angle < 0 then angle = 0 end
    self:SetNW2Int("DrGBaseSightFOV", angle)
  end
  function ENT:SetSightRange(range)
    if range < 0 then range = 0 end
    self:SetNW2Int("DrGBaseSightRange", range)
  end
  function ENT:SetHearingCoefficient(coeff)
    if coeff < 0 then coeff = 0 end
    self:SetNW2Int("DrGBaseHearingCoefficient", coeff)
  end

  -- Functions --

  function ENT:IsInSight(ent)
    if self:EyePos():DistToSqr(ent:GetPos()) > self:GetSightRange()^2 then return false end
    local eyepos = self:EyePos()
    local angle = (eyepos + self:EyeAngles():Forward()):DrG_Degrees(ent:WorldSpaceCenter(), eyepos)
    if angle > self:GetSightFOV()/2 then return false end
    local los = self:Visible(ent)
    if los then
      return self:OnSightCheck(ent) or false
    else return false end
  end

  -- Hooks --

  function ENT:OnSightCheck(ent) return true end
  function ENT:OnSight(ent)
    if self:HasSpottedEntity(ent) then
      self:IncreaseAwarenessLevel(ent, 0.5)
    else
      self:IncreaseAwarenessLevel(ent, 0.2)
    end
  end
  function ENT:OnLostSight(ent) end
  function ENT:OnSound(ent, sound)
    self:SpotEntity(ent)
  end
  function ENT:OnShake(ent)
    self:SpotEntity(ent)
  end

  -- Handlers --

  hook.Add("EntityEmitSound", "DrGBaseNextbotHearing", function(sound)
    if not IsValid(sound.Entity) then return end
    if #DrGBase.GetNextbots() == 0 then return end
    local pos = sound.Pos or sound.Entity:WorldSpaceCenter()
    local distance = math.pow(sound.SoundLevel/2, 2)*sound.Volume
    for i, nextbot in ipairs(DrGBase.GetNextbots()) do
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
