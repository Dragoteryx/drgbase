-- Convars --

local EnableSight = CreateConVar("drgbase_ai_sight", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})
local EnableHearing = CreateConVar("drgbase_ai_hearing", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})

-- Getters/setters --

function ENT:GetSightAngle()
  return math.Clamp(self:GetNW2Int("DrGBaseSightAngle", tonumber(self.SightAngle or self.SightFOV)), 0, 360)
end
function ENT:GetSightRange()
  return math.Clamp(self:GetNW2Int("DrGBaseSightRange", self.SightRange), 0, math.huge)
end
function ENT:GetSightLuminosityRange()
  return math.Clamp(self:GetNW2Float("DrGBaseMinLuminosity", self.MinLuminosity), 0, 1), math.Clamp(self:GetNW2Float("DrGBaseMaxLuminosity", self.MaxLuminosity), 0, 1)
end
function ENT:IsBlind()
  if not EnableSight:GetBool() then return true end
  if self:GetCooldown("DrGBaseBlind") > 0 then return true end
  return self:GetSightFOV() <= 0 or self:GetSightRange() <= 0
end

function ENT:GetHearingCoefficient()
  return math.Clamp(self:GetNW2Int("DrGBaseHearingCoefficient", self.HearingCoefficient), 0, math.huge)
end
function ENT:IsDeaf()
  return not EnableHearing:GetBool() or self:GetHearingCoefficient() <= 0
end

if SERVER then

  -- Setters --

  function ENT:SetSightAngle(angle)
    self:SetNW2Int("DrGBaseSightAngle", tonumber(angle))
  end
  function ENT:SetSightRange(range)
    self:SetNW2Int("DrGBaseSightRange", tonumber(range))
  end
  function ENT:SetSightLuminosityRange(min, max)
    if isnumber(max) then
      self:SetNW2Float("DrGBaseMinLuminosity", tonumber(min))
      self:SetNW2Float("DrGBaseMaxLuminosity", tonumber(max))
    else self:SetSightLuminosityRange(0, min) end
  end

  function ENT:SetHearingCoefficient(coeff)
    self:SetNW2Int("DrGBaseHearingCoefficient", tonumber(coeff))
  end

  -- Util --

  function ENT:IsInSight(ent)
    return false
  end

  function ENT:UpdateSight(disp, spotted)

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
  function ENT:UpdateHostilesSight(spotted)
    return self:UpdateSight({D_HT, D_FR}, spotted)
  end
  function ENT:UpdateNeutralSight(spotted)
    return self:UpdateSight(D_NU, spotted)
  end

end