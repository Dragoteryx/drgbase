
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

  -- Hooks --

  function ENT:OnSight(ent)
    self:SpotEntity(ent)
  end
  function ENT:OnLostSight(ent) end
  function ENT:OnSound(ent, sound)
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
