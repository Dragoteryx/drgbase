-- Convars --

local AllOmniscient = DrGBase.ConVar("drgbase_ai_omniscient", "0")
local EnableHearing = DrGBase.ConVar("drgbase_ai_hearing", "1")

-- Detection --

function ENT:IsOmniscient()
  return AllOmniscient:GetBool() or self:GetNW2Bool("DrGBaseOmniscient", tobool(self.Omniscient))
end

-- Hooks --

function ENT:OnDetect() end
function ENT:OnForget() end

if SERVER then
  util.AddNetworkString("DrGBaseNextbotPlayerDetection")

  -- Detection --

  function ENT:SetOmniscient(omniscient)
    self:SetNW2Bool("DrGBaseOmniscient", tobool(omniscient))
  end

  ENT._DrGBaseDetected = {}
  ENT._DrGBaseForgotten = {}
  ENT._DrGBaseLastTimeDetected = {}
  ENT._DrGBaseLastKnownPosition = {}
  ENT._DrGBaseDetectedRecently = {}

  function ENT:HasDetected(ent)
    if not IsValid(ent) then return false end
    if ent == self then return true end
    if self:IsOmniscient() then return true end
    return self._DrGBaseDetected[ent] or false
  end
  function ENT:HasDetectedRecently(ent)
    if not self:HasDetected(ent) then return false end
    if ent == self then return true end
    if self:IsOmniscient() then return true end
    return CurTime() < self._DrGBaseDetectedRecently[ent]
  end
  function ENT:HasForgotten(ent)
    if not IsValid(ent) then return false end
    if ent == self then return false end
    if self:IsOmniscient() then return false end
    return self._DrGBaseForgotten[ent] or false
  end

  function ENT:LastTimeDetected(ent)
    if self:IsOmniscient() or ent == self then return CurTime()
    else return self._DrGBaseLastTimeDetected[ent] end
  end
  function ENT:LastKnownPosition(ent)
    if self:IsOmniscient() or ent == self then return ent:GetPos()
    else return self._DrGBaseLastKnownPosition[ent] end
  end
  function ENT:SetKnownPosition(ent, pos)
    if self:IsOmniscient() or ent == self then return end
    self._DrGBaseLastKnownPosition[ent] = pos
  end
  function ENT:LastDetectedEntity()
    return self._DrGBaseLastDetectedEntity or NULL
  end

  function ENT:DetectEntity(ent, recent)
    if self:IsOmniscient() or ent == self then return end
    local detected = self:HasDetected(ent)
    self._DrGBaseDetected[ent] = true
    self._DrGBaseForgotten[ent] = nil
    self._DrGBaseLastTimeDetected[ent] = CurTime()
    self._DrGBaseLastKnownPosition[ent] = ent:GetPos()
    self._DrGBaseLastDetectedEntity = ent
    local recently = CurTime() + (isnumber(recent) and math.Clamp(recent, 0, math.huge) or 0)
    if not self._DrGBaseDetectedRecently or recently > self._DrGBaseDetectedRecently then
      self._DrGBaseDetectedRecently = recently
    end
    if not detected then
      local disp = self:GetRelationship(ent, true)
      if disp == D_LI or disp == D_HT or disp == D_FR then
        self._DrGBaseRelationshipCachesDetected[D_LI][ent] = nil
        self._DrGBaseRelationshipCachesDetected[D_HT][ent] = nil
        self._DrGBaseRelationshipCachesDetected[D_FR][ent] = nil
        self._DrGBaseRelationshipCachesDetected[disp][ent] = true
      end
      self:OnDetect(ent)
      self:ReactInCoroutine(self.DoOnDetect, ent)
    end
    ent:CallOnRemove("DrGBaseRemoveFromDrGNextbot"..self:GetCreationID().."DetectionCache", function()
      if not IsValid(self) then return end
      self._DrGBaseDetected[ent] = nil
      self._DrGBaseForgotten[ent] = nil
      self._DrGBaseLastTimeDetected[ent] = nil
      self._DrGBaseLastKnownPosition[ent] = nil
      self._DrGBaseDetectedRecently[ent] = nil
    end)
  end
  function ENT:ForgetEntity(ent)
    if self:IsOmniscient() or ent == self then return end
    if not self:HasDetected(ent) then return end
    self._DrGBaseDetected[ent] = nil
    self._DrGBaseForgotten[ent] = true
    self._DrGBaseDetectedHostiles[ent] = nil
    self._DrGBaseRelationshipCachesDetected[D_LI][ent] = nil
    self._DrGBaseRelationshipCachesDetected[D_HT][ent] = nil
    self._DrGBaseRelationshipCachesDetected[D_FR][ent] = nil
    self:OnForget(ent)
    self:ReactInCoroutine(self.DoOnForget, ent)
  end
  function ENT:ForgetAllEntities()
    if self:IsOmniscient() then return end
    for ent in self:DetectedEntities() do
      self:ForgetEntity(ent)
    end
  end

  function ENT:DetectedEntities()
    local cor
    if self:IsOmniscient() then
      cor = coroutine.create(function()
        for _, ent in ipairs(ents.GetAll()) do
          if not IsValid(ent) then continue end
          coroutine.yield(ent)
        end
      end)
    else
      cor = coroutine.create(function()
        for ent in pairs(self._DrGBaseDetected) do
          if not IsValid(ent) then continue end
          coroutine.yield(ent)
        end
      end)
    end
    return function()
      local _, res = coroutine.resume(cor)
      return res
    end
  end
  function ENT:GetDetectedEntities()
    local entities = {}
    for ent in self:DetectedEntities() do
      table.insert(entities, ent)
    end
    return entities
  end
  function ENT:GetClosestDetectedEntity()
    local closest = NULL
    for ent in self:DetectedEntities() do
      if not IsValid(closest) or
      self:GetRangeSquaredTo(ent) < self:GetRangeSquaredTo(closest) then
        closest = ent
      end
    end
    return closest
  end
  function ENT:GetNumberOfDetectedEntities()
    return #self:GetDetectedEntities()
  end

  function ENT:ForgottenEntities()
    if not self:IsOmniscient() then
      local cor = coroutine.create(function()
        for ent in pairs(self._DrGBaseForgotten) do
          if not IsValid(ent) then continue end
          coroutine.yield(ent)
        end
      end)
      return function()
        local _, res = coroutine.resume(cor)
        return res
      end
    else return function() end end
  end
  function ENT:GetForgottenEntities()
    local entities = {}
    for ent in self:ForgottenEntities() do
      table.insert(entities, ent)
    end
    return entities
  end
  function ENT:GetClosestForgottenEntity()
    local closest = NULL
    for ent in self:ForgottenEntities() do
      if not IsValid(closest) or
      self:GetRangeSquaredTo(ent) < self:GetRangeSquaredTo(closest) then
        closest = ent
      end
    end
    return closest
  end
  function ENT:GetNumberOfForgottenEntities()
    return #self:GetForgottenEntities()
  end

  -- Vision --

  function ENT:IsBlind()
    return GetConVar("nb_blind"):GetBool() or self:GetFOV() <= 0 or self:GetMaxVisionRange() <= 0
  end

  function ENT:UpdateSight(detected)
    self:UpdateAlliesSight(detected)
    self:UpdateEnemiesSight(detected)
    self:UpdateAfraidOfSight(detected)
    self:UpdateNeutralSight(detected)
  end
  function ENT:UpdateAlliesSight(detected)
    for ent in self:AllyIterator(detected) do self:IsAbleToSee(ent) end
  end
  function ENT:UpdateEnemiesSight(detected)
    for ent in self:EnemyIterator(detected) do self:IsAbleToSee(ent) end
  end
  function ENT:UpdateAfraidOfSight(detected)
    for ent in self:AfraidOfIterator(detected) do self:IsAbleToSee(ent) end
  end
  function ENT:UpdateHostilesSight(detected)
    for ent in self:HostileIterator(detected) do self:IsAbleToSee(ent) end
  end
  function ENT:UpdateNeutralSight(detected)
    for ent in self:NeutralIterator(detected) do self:IsAbleToSee(ent) end
  end

  -- meta

  local nextbotMETA = FindMetaTable("NextBot")

  ENT._DrGBaseInSight = {}

  local function UsesCPPSightSystem(ent)
    return false
  end

  local old_IsAbleToSee = nextbotMETA.IsAbleToSee
  function nextbotMETA:IsAbleToSee(ent, ...)
    local res = old_IsAbleToSee(self, ent, ...)
    if self.IsDrGNextbot and not UsesCPPSightSystem(ent) then
      if res and not self._DrGBaseInSight[ent] then
        self._DrGBaseInSight[ent] = true
        self:OnSight(ent)
      elseif not res and self._DrGBaseInSight[ent] then
        self._DrGBaseInSight[ent] = false
        self:OnLostSight(ent)
      end
    end
    return res
  end

  -- hooks

  function ENT:OnSight(ent) self:DetectEntity(ent, 5) end
  function ENT:OnLostSight() end

  -- Sounds --

  function ENT:GetHearingCoefficient()
    return math.Clamp(self.HearingCoefficient, 0, math.huge)
  end
  function ENT:SetHearingCoefficient(coeff)
    self.HearingCoefficient = coeff
  end
  function ENT:IsDeaf()
    return not EnableHearing:GetBool() or self:GetHearingCoefficient() == 0
  end

  -- hooks

  function ENT:OnSound(ent)
    self:DetectEntity(ent)
  end

else

  local function CallAwarenessHooks(self, spotted)
    local ply = LocalPlayer()
    if spotted then
      if isfunction(self.OnSpotEntity) then
        self._DrGBaseLastTimeSpotted = CurTime()
        self._DrGBaseLastKnownPosition = ply:GetPos()
        self:OnSpotEntity(ply)
      else
        timer.Simple(engine.TickInterval(), function()
          if IsValid(self) then CallAwarenessHooks(self, spotted) end
        end)
      end
    elseif not isfunction(self.OnLoseEntity) then
      timer.Simple(engine.TickInterval(), function()
        if IsValid(self) then CallAwarenessHooks(self, spotted) end
      end)
    else self:OnLostEntity(ply) end
  end
  net.Receive("DrGBaseNextbotPlayerAwareness", function()
    local nextbot = net.ReadEntity()
    local awareness = net.ReadBit()
    if IsValid(nextbot) then
      nextbot._DrGBaseLocalPlayerAwareness = awareness
      CallAwarenessHooks(nextbot, awareness == 1)
    end
  end)

  -- Getters --

  function ENT:HasDetectedLocalPlayer()
    if self:IsOmniscient() then return true end
    return self._DrGBaseLocalPlayerAwareness == 1
  end
  function ENT:HasForgottenLocalPlayer()
    if self:IsOmniscient() then return false end
    return self._DrGBaseLocalPlayerAwareness == 0
  end

  function ENT:LastTimeSpotted()
    return self._DrGBaseLastTimeSpotted or -1
  end
  function ENT:LastKnownPosition()
    return self._DrGBaseLastKnownPosition
  end

end