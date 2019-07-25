
-- Convars --

local EnableHearing = CreateConVar("drgbase_ai_hearing", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})

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
  if SERVER then
    self:SetSightFOV(self.SightFOV)
    self:SetSightRange(self.SightRange)
    self:SetSightLuminosityRange(self.MinLuminosity, self.MaxLuminosity)
    self:SetHearingCoefficient(self.HearingCoefficient)
  else self._DrGBaseWasInSight = {} end
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
    if isnumber(max) then
      self:SetNW2Float("DrGBaseMinLuminosity", math.Clamp(min, 0, 1))
      self:SetNW2Float("DrGBaseMaxLuminosity", math.Clamp(max, 0, 1))
    else self:SetSightLuminosityRange(0, min) end
  end

  function ENT:SetHearingCoefficient(coeff)
    if coeff < 0 then coeff = 0 end
    self:SetNW2Int("DrGBaseHearingCoefficient", coeff)
  end

  -- Functions --

  function ENT:IsInSight(ent)
    local eyepos = self:EyePos()
    if eyepos:DistToSqr(ent:GetPos()) > self:GetSightRange()^2 then return false end
    if ent:IsPlayer() then
      local luminosity = ent:FlashlightIsOn() and 1 or ent:DrG_Luminosity()
      local min, max = self:GetSightLuminosityRange()
      if luminosity < min or luminosity > max then return false end
    end
    local angle = (eyepos + self:EyeAngles():Forward()):DrG_Degrees(ent:WorldSpaceCenter(), eyepos)
    if angle > self:GetSightFOV()/2 then return false end
    return self:Visible(ent)
  end

  net.DrG_DefineCallback("DrGBaseIsInSight", function(nextbot, ent)
    if not IsValid(nextbot) or not IsValid(ent) then return false
    else return nextbot:IsInSight(ent) end
  end)

  -- Get entities in sight
  function ENT:GetInSight(disp, spotted)
    local inSight = {}
    if isnumber(disp) then
      for ent in self:EntityIterator(disp, spotted) do
        if self:IsInSight(ent) then table.insert(inSight, ent) end
      end
    else
      for i, ent in ipairs(ents.GetAll()) do
        if not IsValid(ent) then continue end
        if spotted and not self:HasSpotted(ent) then continue end
        if self:IsInSight(ent) then table.insert(inSight, ent) end
      end
    end
    return inSight
  end
  function ENT:GetAlliesInSight(spotted)
    return self:GetInSight(D_LI, spotted)
  end
  function ENT:GetEnemiesInSight(spotted)
    return self:GetInSight(D_HT, spotted)
  end
  function ENT:GetAfraidOfInSight(spotted)
    return self:GetInSight(D_FR, spotted)
  end
  function ENT:GetNeutralInSight(spotted)
    return self:GetInSight(D_NU, spotted)
  end

  -- Check if entities are in sight
  function ENT:UpdateSight(disp, spotted)
    if self:IsAIDisabled() then return end
    if istable(disp) then
      for i, dis in ipairs(disp) do self:UpdateSight(dis, spotted) end
    elseif isnumber(disp) then
      for ent in self:EntityIterator(disp, spotted) do
        local res = self:IsInSight(ent)
        if res then self:OnSight(ent) end
      end
    else self:UpdateSight({
      D_LI, D_HT, D_FR, D_NU
    }, spotted) end
  end
  function ENT:UpdateAlliesSight(spotted)
    return self:UpdateSight(D_LI, spotted)
  end
  function ENT:UpdateEnemiesSight(spotted)
    return self:UpdateSight(D_HT, spotted)
  end
  function ENT:UpdateAfraidOfSight(spotted)
    return self:UpdateSight(D_FR, spotted)
  end
  function ENT:UpdateNeutralSight(spotted)
    return self:UpdateSight(D_NU, spotted)
  end

  -- Hooks --

  function ENT:OnSight(ent)
    self:SpotEntity(ent)
  end
  function ENT:OnSound(ent, sound)
    self:SpotEntity(ent)
  end

  -- Handlers --

  hook.Add("EntityEmitSound", "DrGBaseNextbotHearing", function(sound)
    if not EnableHearing:GetBool() then return end
    if not IsValid(sound.Entity) then return end
    if not sound.Entity:IsPlayer() then return end
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

  function ENT:IsInSight(ent, callback)
    if IsValid(ent) then
      return self:NetCallback("DrGBaseIsInSight", callback, ent)
    elseif isfunction(callback) then callback(false) end
  end
  function ENT:WasInSight(ent)
    if not IsValid(ent) then return false end
    self:IsInSight(ent, function(insight)
      if not IsValid(ent) then return end
      self._DrGBaseWasInSight[ent] = insight
    end)
    return self._DrGBaseWasInSight[ent] or false
  end

end
