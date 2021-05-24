-- Detection --

function ENT:IsOmniscient()
  return DrGBase.AIOmniscient:GetBool() or self:GetNW2Bool("DrG/Omniscient", tobool(self.Omniscient))
end

-- Hooks --

function ENT:OnDetectEntity() end
function ENT:OnForgetEntity() end

if SERVER then
  util.AddNetworkString("DrG/PlayerDetectState")
  util.AddNetworkString("DrG/PlayerSight")
  util.AddNetworkString("DrG/PlayerSightLost")
  util.AddNetworkString("DrG/PlayerSound")

  -- Detection --

  function ENT:SetOmniscient(omniscient)
    self:SetNW2Bool("DrG/Omniscient", tobool(omniscient))
  end

  ENT.DrG_DetectState = {}
  ENT.DrG_DetectStateLastUpdate = {}
  function ENT:GetDetectState(ent)
    if not IsValid(ent) then return DETECT_STATE_INVALID end
    if self:IsOmniscient() then return DETECT_STATE_DETECTED end
    return self.DrG_DetectState[ent] or DETECT_STATE_UNDETECTED
  end
  function ENT:SetDetectState(ent, state)
    if not IsValid(ent) then return end
    if self:IsOmniscient() then return end
    local oldState = self:GetDetectState(ent)
    state = math.Clamp(state,
      DETECT_STATE_UNDETECTED,
      DETECT_STATE_DETECTED)
    self.DrG_DetectStateLastUpdate[ent] = CurTime()
    if oldState ~= state then
      if state == DETECT_STATE_UNDETECTED then
        self.DrG_DetectState[ent] = nil
        self.DrG_RelationshipCacheDetected[D_LI][ent] = nil
        self.DrG_RelationshipCacheDetected[D_HT][ent] = nil
        self.DrG_RelationshipCacheDetected[D_FR][ent] = nil
        if self:GetEnemy() == ent then self:UpdateEnemy() end
      else
        self.DrG_DetectState[ent] = state
        local disp = self:GetRelationship(ent)
        if disp == D_LI or disp == D_HT or disp == D_FR then
          self.DrG_RelationshipCacheDetected[disp][ent] = true
        end
      end
    end
  end

  function ENT:GetDetectStateLastUpdate(ent)
    return self.DrG_DetectStateLastUpdate[ent] or -1
  end

  function ENT:DetectEntity(ent, state)
    if not IsValid(ent) or self:IsOmniscient() then return end
    if state == DETECT_STATE_UNDETECTED then return end
    if not isnumber(state) then state = DETECT_STATE_DETECTED end
    self:UpdateLastTimeDetected(ent)
    self:UpdateLastKnownPos(ent)
    return self:SetDetectState(ent, math.max(state, self:GetDetectState(ent)))
  end
  function ENT:SearchEntity(ent)
    return self:DetectEntity(ent, DETECT_STATE_SEARCHING)
  end
  function ENT:ForgetEntity(ent)
    return self:SetDetectState(ent, DETECT_STATE_UNDETECTED)
  end

  function ENT:HasDetected(ent)
    return self:GetDetectState(ent) > DETECT_STATE_UNDETECTED
  end

  ENT.DrG_LastKnownPos = {}
  function ENT:LastKnownPos(ent)
    return self.DrG_LastKnownPos[ent]
  end
  function ENT:UpdateLastKnownPos(ent, pos)
    pos = isvector(pos) and pos or ent:GetPos()
    self.DrG_LastKnownPos[ent] = pos
  end

  ENT.DrG_LastTimeDetected = {}
  function ENT:LastTimeDetected(ent)
    return self.DrG_LastTimeDetected[ent] or -1
  end
  function ENT:UpdateLastTimeDetected(ent)
    self.DrG_LastTimeDetected[ent] = CurTime()
  end

  -- iterators

  function ENT:DetectedEntities(state)
    if self:IsOmniscient() then
      local i = 1
      local entities = ents.GetAll()
      return function()
        for j = i, #entities do
          if not IsValid(ent) then continue end
          i = j+1
          return ent, DETECT_STATE_DETECTED
        end
      end
    else
      return function(_, ent)
        while true do
          ent, entState = next(self.DrG_DetectState, ent)
          if not ent then return end
          if not IsValid(ent) then continue end
          if state and entState ~= state then continue end
          return ent, entState
        end
      end
    end
  end
  function ENT:GetDetectedEntities(state)
    local entities = {}
    for ent in self:DetectedEntities(state) do
      table.insert(entities, ent)
    end
    return entities
  end

  -- hooks

  function ENT:OnUpdateDetectState(_ent, state, lastUpdate)
    if state == DETECT_STATE_DETECTED and lastUpdate > 10 then
      return DETECT_STATE_SEARCHING
    end
  end

  -- Vision --

  function ENT:GetMinLuminosity()
    return math.Clamp(self.MinLuminosity, 0, 1)
  end
  function ENT:SetMinLuminosity(luminosity)
    self.MinLuminosity = tonumber(luminosity)
  end

  function ENT:GetMaxLuminosity()
    return math.Clamp(self.MaxLuminosity, 0, 1)
  end
  function ENT:SetMaxLuminosity(luminosity)
    self.MaxLuminosity = tonumber(luminosity)
  end

  -- sight info

  local SightInfo = DrGBase.FlagsHelper(4)

  function SightInfo.prototype:IsAbleToSee()
    return self:GetFlags() == SIGHT_TEST_PASSED_ALL
  end
  function SightInfo.prototype:IsLineOfSightClear()
    return self:IsFlagSet(SIGHT_TEST_LOS)
  end
  function SightInfo.prototype:IsCloseEnough()
    return self:IsFlagSet(SIGHT_TEST_RANGE)
  end
  function SightInfo.prototype:IsInViewCone()
    return self:IsFlagSet(SIGHT_TEST_ANGLE)
  end
  function SightInfo.prototype:IsLuminosityOk()
    return self:IsFlagSet(SIGHT_TEST_LUMINOSITY)
  end

  function SightInfo.prototype:tostring()
    return "AbleToSee = " .. tostring(self:IsAbleToSee()) .. "\n" ..
      "| LineOfSightClear = " .. tostring(self:IsLineOfSightClear()) .. "\n" ..
      "| CloseEnough = " .. tostring(self:IsCloseEnough()) .. "\n" ..
      "| InViewCone = " .. tostring(self:IsInViewCone()) .. "\n" ..
      "| LuminosityOk = " .. tostring(self:IsLuminosityOk())
  end

  -- meta

  local nextbotMETA = FindMetaTable("NextBot")

  local function LOSTest(self, ent)
    return self:Visible(ent)
  end
  local function RangeTest(self, ent)
    return self:EyePos():DistToSqr(ent:WorldSpaceCenter()) <= self:GetMaxVisionRange()^2
  end
  local function AngleTest(self, ent)
    local eyepos = self:EyePos()
    local eyeangles = self:EyeAngles()
    return eyepos:DrG_Degrees(
      eyepos + eyeangles:Forward(),
      ent:WorldSpaceCenter()
    ) <= self:GetFOV()/2
  end
  local function LuminosityTest(self, ent)
    if not ent:IsPlayer() then return true end
    local luminosity = ent:FlashlightIsOn() and 1 or ent:DrG_Luminosity()
    return luminosity >= self:GetMinLuminosity() and luminosity <= self:GetMaxLuminosity()
  end

  local IsAbleToSee = nextbotMETA.IsAbleToSee
  function nextbotMETA:IsAbleToSee(ent, useFOV, ...)
    if self.IsDrGNextbot then
      if not IsValid(ent) then return false end
      if ent == self then return true end
      if DrGBase.AIBlind:GetBool() then return false end
      if GetConVar("nb_blind"):GetBool() then return false end
      if isfunction(self.CustomSightTest) then
        local flags = SIGHT_TEST_PASSED_ALL
        if not LOSTest(self, ent) then flags = flags - SIGHT_TEST_LOS end
        if not RangeTest(self, ent) then flags = flags - SIGHT_TEST_RANGE end
        if useFOV ~= false and not AngleTest(self, ent) then flags = flags - SIGHT_TEST_ANGLE end
        if not LuminosityTest(self, ent) then flags = flags - SIGHT_TEST_LUMINOSITY end
        local res = self:CustomSightTest(ent, SightInfo(flags))
        if not isbool(res) then return flags == SIGHT_TEST_PASSED_ALL
        else return res end
      else
        return LuminosityTest(self, ent)
        and RangeTest(self, ent)
        and (useFOV == false or AngleTest(self, ent))
        and LOSTest(self, ent)
      end
    else return IsAbleToSee(self, ent, useFOV, ...) end
  end

  local GetFOV = nextbotMETA.GetFOV
  function nextbotMETA:GetFOV(...)
    if self.IsDrGNextbot then
      return math.Clamp(self.SightFOV, 0, 360)
    else return GetFOV(self, ...) end
  end
  local SetFOV = nextbotMETA.SetFOV
  function nextbotMETA:SetFOV(fov, ...)
    if self.IsDrGNextbot then
      self.SightFOV = tonumber(fov)
    else return SetFOV(self, fov, ...) end
  end

  local GetMaxVisionRange = nextbotMETA.GetMaxVisionRange
  function nextbotMETA:GetMaxVisionRange(...)
    if self.IsDrGNextbot then
      return math.max(0, self.SightRange)
    else return GetMaxVisionRange(self, ...) end
  end
  local SetMaxVisionRange = nextbotMETA.SetMaxVisionRange
  function nextbotMETA:SetMaxVisionRange(range, ...)
    if self.IsDrGNextbot then
      self.SightRange = tonumber(range)
    else return SetMaxVisionRange(self, range, ...) end
  end

  -- update

  ENT.DrG_InSight = {}

  local OnSightDeprecation = DrGBase.Deprecation("ENT:OnSight(ent)", "ENT:OnEntitySight(ent, angle)")
  local OnLostSightDeprecation = DrGBase.Deprecation("ENT:OnLostSight(ent)", "ENT:OnEntitySightLost(ent, angle)")
  function ENT:UpdateSight(ent)
    if not IsValid(ent) then return end
    local res = self:IsAbleToSee(ent)
    if res then
      if not self.DrG_InSight[ent] then
        self.DrG_InSight[ent] = true
        if isfunction(self.OnSight) then
          OnSightDeprecation()
          self:OnSight(ent)
        else
          self:OnEntitySight(ent)
          self:ReactInCoroutine(self.DoEntitySight, ent)
        end
        if ent:IsPlayer() then ent:DrG_Send("DrG/PlayerSight", self) end
      else
        self:OnEntitySightKept(ent, angle)
        self:ReactInCoroutine(self.DoEntitySightKept, ent)
      end
    else
      if self.DrG_InSight[ent] then
        self.DrG_InSight[ent] = nil
        if isfunction(self.OnLostSight) then
          OnLostSightDeprecation()
          self:OnLostSight(ent)
        else
          self:OnEntitySightLost(ent)
          self:ReactInCoroutine(self.DoEntitySightLost, ent)
        end
        if ent:IsPlayer() then ent:DrG_Send("DrG/PlayerSightLost", self) end
      else
        self:OnEntityNotInSight(ent)
        self:ReactInCoroutine(self.DoEntityNotInSight, ent)
      end
    end
  end

  -- hooks

  function ENT:OnEntitySight(_ent) end
  function ENT:OnEntitySightLost(_ent) end
  function ENT:OnEntitySightKept(ent) self:DetectEntity(ent) end
  function ENT:OnEntityNotInSight(_ent) end

  -- Sounds --

  function ENT:GetHearingCoefficient()
    return math.max(0, self.HearingCoefficient)
  end
  function ENT:SetHearingCoefficient(coeff)
    self.HearingCoefficient = tonumber(coeff)
  end

  function ENT:ListenTo(ent, listen)
    if not IsValid(ent) or ent == self then return end
    ent.DrG_Listening = ent.DrG_Listening or {}
    local rmv = "DrG/Remove"..self:GetCreationID().."FromListening"
    if listen then
      ent.DrG_Listening[self] = true
      self:CallOnRemove(rmv, function(self)
        if not IsValid(ent) then return end
        ent.DrG_Listening[self] = nil
      end)
    else
      ent.DrG_Listening[self] = nil
      self:RemoveCallOnRemove(rmv)
    end
  end
  function ENT:IsListeningTo(ent)
    if not IsValid(ent) or ent == self then return false end
    return istable(ent.DrG_Listening) and ent.DrG_Listening[self] or false
  end

  -- hooks

  local OnSoundDeprecation = DrGBase.Deprecation("ENT:OnSound(entity, sound)", "ENT:OnEntitySound(ent, sound)")
  function ENT:OnEntitySound(ent, sound)
    if isfunction(self.OnSound) then
      OnSoundDeprecation()
      self:OnSound(ent, sound)
    else self:SearchEntity(ent) end
  end

  hook.Add("EntityEmitSound", "DrG/SoundDetection", function(sound)
    if DrGBase.AIDeaf:GetBool() then return end
    local ent = sound.Entity
    if not istable(ent.DrG_Listening) then return end
    local pos = sound.Pos or ent:GetPos()
    local radius = math.pow(sound.SoundLevel/2, 2)*sound.Volume
    for nextbot in pairs(ent.DrG_Listening) do
      if not IsValid(nextbot) or not nextbot.IsDrGNextbot then continue end
      if nextbot:GetHearingCoefficient() == 0 then continue end
      local mult = nextbot:VisibleVec(pos) and 1 or 0.5
      if (radius*nextbot:GetHearingCoefficient()*mult)^2 >= nextbot:GetRangeSquaredTo(pos) then
        nextbot:OnEntitySound(ent, sound)
        nextbot:ReactInCoroutine(nextbot.DoEntitySound, ent, sound)
        if ent:IsPlayer() then ent:DrG_Send("DrG/PlayerSound", nextbot) end
      end
    end
  end)

  -- Other --

  function ENT:OnContact(ent)
    self:SearchEntity(ent)
  end

else

 -- Net --

  net.DrG_DelayedReceive("DrG/PlayerDetect", function(nb)
    if not IsValid(nb) then return end
    nb.DrG_LocalPlayerDetected = true
    nb:OnDetectEntity(LocalPlayer())
  end)
  net.DrG_DelayedReceive("DrG/PlayerForget", function(nb)
    if not IsValid(nb) then return end
    nb.DrG_LocalPlayerDetected = false
    nb:OnForgetEntity(LocalPlayer())
  end)
  net.DrG_DelayedReceive("DrG/PlayerSight", function(nb)
    if not IsValid(nb) then return end
    nb.DrG_LocalPlayerInSight = true
    nb:OnEntitySight(LocalPlayer())
  end)
  net.DrG_DelayedReceive("DrG/PlayerSightLost", function(nb)
    if not IsValid(nb) then return end
    nb.DrG_LocalPlayerInSight = false
    nb:OnEntitySightLost(LocalPlayer())
  end)
  net.DrG_DelayedReceive("DrG/PlayerSound", function(nb)
    if not IsValid(nb) then return end
    nb:OnEntitySound(LocalPlayer())
  end)

  -- Hooks --

  function ENT:OnEntitySight(_ent) end
  function ENT:OnEntitySightLost(_ent) end
  function ENT:OnEntitySightKept(_ent) end
  function ENT:OnEntityNotInSight(_ent) end
  function ENT:OnEntitySound(_ent) end

  -- Getters --

  function ENT:HasDetected(ent)
    if self:IsOmniscient() then return true end
    if ent ~= LocalPlayer() then return false end
    return self.DrG_LocalPlayerDetected == true
  end
  function ENT:HasForgotten(ent)
    if self:IsOmniscient() then return false end
    if ent ~= LocalPlayer() then return false end
    return self.DrG_LocalPlayerDetected == false
  end

  function ENT:IsAbleToSee(ent)
    if ent == self then return true end
    if ent ~= LocalPlayer() then return false end
    return self.DrG_LocalPlayerInSight or false
  end

end