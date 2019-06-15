
-- Getters/setters --

function ENT:GetSightFOV()
  return self:GetNW2Int("DrGBaseSightFOV")
end
function ENT:GetSightRange()
  return self:GetNW2Int("DrGBaseSightRange")
end
function ENT:GetSightLuminosityRange()
  return self:GetNW2Float("DrGBaseMinLuminosity"), self:GetNW2Float("DrGBaseMaxLuminosity")
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
  self:SetSightLuminosityRange(self.MinLuminosity, self.MaxLuminosity)
  self:SetHearingCoefficient(self.HearingCoefficient)
  self._DrGBaseSight = {}
  self:LoopTimer(0.25, function()
    if self:IsAIDisabled() then return end
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
  function ENT:SetSightLuminosityRange(min, max)
    if isnumber(min) then
      min = math.Clamp(min, 0, 1)
      self:SetNW2Float("DrGBaseMinLuminosity", min)
    end
    if isnumber(max) then
      max = math.Clamp(max, 0, 1)
      self:SetNW2Float("DrGBaseMaxLuminosity", max)
    end
  end

  function ENT:SetHearingCoefficient(coeff)
    if coeff < 0 then coeff = 0 end
    self:SetNW2Int("DrGBaseHearingCoefficient", coeff)
  end

  -- Functions --

  function ENT:IsInSight(ent)
    if self:EyePos():DistToSqr(ent:GetPos()) > self:GetSightRange()^2 then return false end
    if ent:IsPlayer() then
      local luminosity = ent:FlashlightIsOn() and 1 or ent:DrG_Luminosity()
      local min, max = self:GetSightLuminosityRange()
      if luminosity < min or luminosity > max then return false end
    end
    local eyepos = self:EyePos()
    local angle = (eyepos + self:EyeAngles():Forward()):DrG_Degrees(ent:WorldSpaceCenter(), eyepos)
    if angle > self:GetSightFOV()/2 then return false end
    local los = self:Visible(ent)
    return los
  end

  -- Hooks --

  function ENT:OnSight(ent)
    self:SpotEntity(ent)
  end
  function ENT:WhileInSight(ent) end
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
    local pos = sound.Pos or sound.Entity:GetPos()
    local distance = math.pow(sound.SoundLevel/2, 2)*sound.Volume
    --print(distance)
    for i, nextbot in ipairs(DrGBase.GetNextbots()) do
      if sound.Entity == nextbot then continue end
      if nextbot:IsAIDisabled() then continue end
      if nextbot:IsDeaf() then continue end
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
