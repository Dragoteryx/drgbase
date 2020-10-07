-- Convars --

local AllOmniscient = DrGBase.ConVar("drgbase_ai_omniscient", "0")
local EnableHearing = DrGBase.ConVar("drgbase_ai_hearing", "1")

-- Detection --

function ENT:IsOmniscient()
  return AllOmniscient:GetBool() or self:GetNW2Bool("DrG/Omniscient", tobool(self.Omniscient))
end

-- Hooks --

function ENT:OnDetect() end
function ENT:OnForget() end

if SERVER then
  util.AddNetworkString("DrG/NextbotPlayerDetection")

  -- Detection --

  function ENT:SetOmniscient(omniscient)
    self:SetNW2Bool("DrG/Omniscient", tobool(omniscient))
  end

  ENT.DrG_Detected = {}
  ENT.DrG_Forgotten = {}
  ENT.DrG_LastTimeDetected = {}
  ENT.DrG_LastKnownPosition = {}
  ENT.DrG_DetectedRecently = {}

  function ENT:HasDetected(ent)
    if not IsValid(ent) then return false end
    if ent == self then return true end
    if self:IsOmniscient() then return true end
    return self.DrG_Detected[ent] or false
  end
  function ENT:HasDetectedRecently(ent)
    if not self:HasDetected(ent) then return false end
    if ent == self then return true end
    if self:IsOmniscient() then return true end
    return CurTime() < self.DrG_DetectedRecently[ent]
  end
  function ENT:HasForgotten(ent)
    if not IsValid(ent) then return false end
    if ent == self then return false end
    if self:IsOmniscient() then return false end
    return self.DrG_Forgotten[ent] or false
  end

  function ENT:LastTimeDetected(ent)
    if self:IsOmniscient() or ent == self then return CurTime()
    else return self.DrG_LastTimeDetected[ent] end
  end
  function ENT:LastKnownPosition(ent)
    if self:IsOmniscient() or ent == self then return ent:GetPos()
    else return self.DrG_LastKnownPosition[ent] end
  end
  function ENT:SetKnownPosition(ent, pos)
    if self:IsOmniscient() or ent == self then return end
    self.DrG_LastKnownPosition[ent] = pos
  end
  function ENT:LastDetectedEntity()
    return self.DrG_LastDetectedEntity or NULL
  end

  function ENT:DetectEntity(ent, recent)
    if self:IsOmniscient() or ent == self then return end
    local detected = self:HasDetected(ent)
    self.DrG_Detected[ent] = true
    self.DrG_Forgotten[ent] = nil
    self.DrG_LastTimeDetected[ent] = CurTime()
    self.DrG_LastKnownPosition[ent] = ent:GetPos()
    self.DrG_LastDetectedEntity = ent
    local recently = CurTime() + (isnumber(recent) and math.Clamp(recent, 0, math.huge) or 0)
    if not self.DrG_DetectedRecently or recently > self.DrG_DetectedRecently then
      self.DrG_DetectedRecently[ent] = recently
    end
    if not detected then
      local disp = self:GetRelationship(ent, true)
      if disp == D_LI or disp == D_HT or disp == D_FR then
        self.DrG_RelationshipCachesDetected[D_LI][ent] = nil
        self.DrG_RelationshipCachesDetected[D_HT][ent] = nil
        self.DrG_RelationshipCachesDetected[D_FR][ent] = nil
        self.DrG_RelationshipCachesDetected[disp][ent] = true
      end
      self:OnDetect(ent)
      self:ReactInThread(self.DoDetect, ent)
    end
    ent:CallOnRemove("DrG/RemoveFromDrGNextbot"..self:GetCreationID().."DetectionCache", function()
      if not IsValid(self) then return end
      self.DrG_Detected[ent] = nil
      self.DrG_Forgotten[ent] = nil
      self.DrG_LastTimeDetected[ent] = nil
      self.DrG_LastKnownPosition[ent] = nil
      self.DrG_DetectedRecently[ent] = nil
    end)
  end
  function ENT:ForgetEntity(ent)
    if self:IsOmniscient() or ent == self then return end
    if not self:HasDetected(ent) then return end
    self.DrG_Detected[ent] = nil
    self.DrG_Forgotten[ent] = true
    self.DrG_DetectedHostiles[ent] = nil
    self.DrG_RelationshipCachesDetected[D_LI][ent] = nil
    self.DrG_RelationshipCachesDetected[D_HT][ent] = nil
    self.DrG_RelationshipCachesDetected[D_FR][ent] = nil
    self:OnForget(ent)
    self:ReactInThread(self.DoForget, ent)
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
        local entities = ents.GetAll()
        for i = 1, #entities do
          local ent = entities[i]
          if not IsValid(ent) then continue end
          coroutine.yield(ent)
        end
      end)
    else
      cor = coroutine.create(function()
        for ent in pairs(self.DrG_Detected) do
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
        for ent in pairs(self.DrG_Forgotten) do
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

  ENT.DrG_InSight = {}

  local function UsesCPPSightSystem(ent)
    return ent:IsPlayer() or ent:IsNextBot()
  end

  local old_IsAbleToSee = nextbotMETA.IsAbleToSee
  function nextbotMETA:IsAbleToSee(ent, ...)
    local res = old_IsAbleToSee(self, ent, ...)
    if self.IsDrGNextbot and not UsesCPPSightSystem(ent) then
      if res and not self.DrG_InSight[ent] then
        self.DrG_InSight[ent] = true
        self:OnSight(ent)
      elseif not res and self.DrG_InSight[ent] then
        self.DrG_InSight[ent] = false
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
        self.DrG_LastTimeSpotted = CurTime()
        self.DrG_LastKnownPosition = ply:GetPos()
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
  net.Receive("DrG/NextbotPlayerAwareness", function()
    local nextbot = net.ReadEntity()
    local awareness = net.ReadBit()
    if IsValid(nextbot) then
      nextbot.DrG_LocalPlayerAwareness = awareness
      CallAwarenessHooks(nextbot, awareness == 1)
    end
  end)

  -- Getters --

  function ENT:HasDetectedLocalPlayer()
    if self:IsOmniscient() then return true end
    return self.DrG_LocalPlayerAwareness == 1
  end
  function ENT:HasForgottenLocalPlayer()
    if self:IsOmniscient() then return false end
    return self.DrG_LocalPlayerAwareness == 0
  end

  function ENT:LastTimeSpotted()
    return self.DrG_LastTimeSpotted or -1
  end
  function ENT:LastKnownPosition()
    return self.DrG_LastKnownPosition
  end

end