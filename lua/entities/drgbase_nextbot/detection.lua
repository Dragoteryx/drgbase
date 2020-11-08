-- ConVars --

local AllOmniscient = DrGBase.ConVar("drgbase_ai_omniscient", "0")
local EnableSight = DrGBase.ConVar("drgbase_ai_sight", "1")
local EnableHearing = DrGBase.ConVar("drgbase_ai_hearing", "1")

-- Detection --

function ENT:IsOmniscient()
  return AllOmniscient:GetBool() or self:GetNW2Bool("DrG/Omniscient", tobool(self.Omniscient))
end

-- Hooks --

function ENT:OnDetectEntity() end
function ENT:OnForgetEntity() end

if SERVER then
  util.AddNetworkString("DrG/PlayerDetect")
  util.AddNetworkString("DrG/PlayerForget")
  util.AddNetworkString("DrG/PlayerSight")
  util.AddNetworkString("DrG/PlayerSightLost")
  util.AddNetworkString("DrG/PlayerSound")

  -- Detection --

  function ENT:SetOmniscient(omniscient)
    self:SetNW2Bool("DrG/Omniscient", tobool(omniscient))
  end

  ENT.DrG_Detected = {}
  ENT.DrG_Forgotten = {}
  ENT.DrG_LastTimeDetected = {}
  ENT.DrG_LastKnownPos = {}
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
  function ENT:LastKnownPos(ent)
    if self:IsOmniscient() or ent == self then return ent:GetPos()
    else return self.DrG_LastKnownPos[ent] end
  end
  function ENT:SetKnownPosition(ent, pos)
    if self:IsOmniscient() or ent == self then return end
    self.DrG_LastKnownPos[ent] = pos
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
    self.DrG_LastKnownPos[ent] = ent:GetPos()
    self.DrG_LastDetectedEntity = ent
    local recently = CurTime() + (isnumber(recent) and math.Clamp(recent, 0, math.huge) or 0)
    if not self.DrG_DetectedRecently[ent] or recently > self.DrG_DetectedRecently[ent] then
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
      self:OnDetectEntity(ent)
      self:ReactInThread(self.DoDetectEntity, ent)
      if ent:IsPlayer() then ent:DrG_Send("DrG/PlayerDetect", self) end
    end
    ent:CallOnRemove("DrG/RemoveFromDrGNextbot"..self:GetCreationID().."DetectionCache", function()
      if not IsValid(self) then return end
      self.DrG_Detected[ent] = nil
      self.DrG_Forgotten[ent] = nil
      self.DrG_LastTimeDetected[ent] = nil
      self.DrG_LastKnownPos[ent] = nil
      self.DrG_DetectedRecently[ent] = nil
    end)
  end
  function ENT:ForgetEntity(ent)
    if self:IsOmniscient() or ent == self then return end
    if not self:HasDetected(ent) then return end
    self.DrG_Detected[ent] = nil
    self.DrG_Forgotten[ent] = true
    self.DrG_RelationshipCachesDetected[D_LI][ent] = nil
    self.DrG_RelationshipCachesDetected[D_HT][ent] = nil
    self.DrG_RelationshipCachesDetected[D_FR][ent] = nil
    self:OnForgetEntity(ent)
    self:ReactInThread(self.DoForgetEntity, ent)
    if ent:IsPlayer() then ent:DrG_Send("DrG/PlayerForget", self) end
  end
  function ENT:ForgetAllEntities()
    if self:IsOmniscient() then return end
    for ent in self:DetectedEntities() do
      self:ForgetEntity(ent)
    end
  end
  function ENT:ForgetPlayers()
    if self:IsOmniscient() then return end
    local plys = player.GetAll()
    for i = 1, #plys do
      self:ForgetEntity(plys[i])
    end
  end
  function ENT:ForgetAllies()
    if self:IsOmniscient() then return end
    for ally in self:AllyIterator() do
      self:ForgetEntity(ally)
    end
  end
  function ENT:ForgetEnemies()
    if self:IsOmniscient() then return end
    for enemy in self:EnemyIterator() do
      self:ForgetEntity(enemy)
    end
  end
  function ENT:ForgetAfraidOf()
    if self:IsOmniscient() then return end
    for afraidOf in self:AfraidOfIterator() do
      self:ForgetEntity(afraidOf)
    end
  end
  function ENT:ForgetHostiles()
    if self:IsOmniscient() then return end
    for hostile in self:HostileIterator() do
      self:ForgetEntity(hostile)
    end
  end
  function ENT:ForgetNeutrals()
    if self:IsOmniscient() then return end
    local entities = ents.GetAll()
    for i = 1, #entities do
      local ent = entities[i]
      if IsValid(ent) and self:IsNeutral(ent) then
        self:ForgetEntity(ent)
      end
    end
  end
  function ENT:ForgetEnemy()
    if self:IsOmniscient() then return end
    if not self:HasEnemy() then return end
    self:ForgetEntity(self:GetEnemy())
  end

  function ENT:DetectedEntities()
    local thr
    if self:IsOmniscient() then
      thr = coroutine.create(function()
        local entities = ents.GetAll()
        for i = 1, #entities do
          local ent = entities[i]
          if not IsValid(ent) then continue end
          coroutine.yield(ent)
        end
      end)
    else
      thr = coroutine.create(function()
        for ent in pairs(self.DrG_Detected) do
          if not IsValid(ent) then continue end
          coroutine.yield(ent)
        end
      end)
    end
    return function()
      local _, res = coroutine.resume(thr)
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

  -- sight info

  local SightInfo = DrGBase.Class()

  function SightInfo:__new(nextbot, entity, flags)
    function self:GetNextbot()
      return nextbot
    end
    function self:GetEntity()
      return entity
    end
    function self:GetFlags()
      return flags
    end
  end

  function SightInfo.__index:IsFlagSet(flag)
    return bit.band(self:GetFlags(), flag) ~= 0
  end
  function SightInfo.__index:IsAbleToSee()
    return self:GetFlags() == SIGHT_TEST_PASSED_ALL
  end
  function SightInfo.__index:IsLineOfSightClear()
    return self:IsFlagSet(SIGHT_TEST_LOS)
  end
  function SightInfo.__index:IsCloseEnough()
    return self:IsFlagSet(SIGHT_TEST_RANGE)
  end
  function SightInfo.__index:IsInViewCone()
    return self:IsFlagSet(SIGHT_TEST_ANGLE)
  end
  function SightInfo.__index:IsLuminosityOk()
    return self:IsFlagSet(SIGHT_TEST_LUMINOSITY)
  end

  function SightInfo:__tostring()
    return "Nextbot = " .. tostring(self:GetNextbot()) .. "\n" ..
      "Entity = " .. tostring(self:GetEntity()) .. "\n" ..
      "AbleToSee = " .. tostring(self:IsAbleToSee()) .. "\n" ..
      "| LineOfSightClear = " .. tostring(self:IsLineOfSightClear()) .. "\n" ..
      "| CloseEnough = " .. tostring(self:IsCloseEnough()) .. "\n" ..
      "| InViewCone = " .. tostring(self:IsInViewCone()) .. "\n" ..
      "| LuminosityOk = " .. tostring(self:IsLuminosityOk())
  end

  -- update

  ENT.DrG_InSight = {}
  local OnSightDeprecation = DrGBase.Deprecation("ENT:OnSight(ent)", "ENT:OnEntitySight(ent, angle)")
  local OnLostSightDeprecation = DrGBase.Deprecation("ENT:OnLostSight(ent)", "ENT:OnEntitySightLost(ent, angle)")
  function ENT:UpdateSight(ent)
    if ent then
      if not IsValid(ent) then return end
      local res, angle = self:IsAbleToSee(ent)
      if res then
        if not self.DrG_InSight[ent] then
          self.DrG_InSight[ent] = true
          if isfunction(self.OnSight) then
            OnSightDeprecation()
            self:OnSight(ent)
          else
            self:OnEntitySight(ent, angle)
            self:ReactInThread(self.DoEntitySight, ent, angle)
          end
          if ent:IsPlayer() then ent:DrG_Send("DrG/PlayerSight", self) end
        else
          self:OnEntitySightKept(ent, angle)
          self:ReactInThread(self.DoEntitySightKept, ent, angle)
        end
      else
        if self.DrG_InSight[ent] then
          self.DrG_InSight[ent] = nil
          if isfunction(self.OnLostSight) then
            OnLostSightDeprecation()
            self:OnLostSight(ent)
          else
            self:OnEntitySightLost(ent, angle)
            self:ReactInThread(self.DoEntitySightLost, ent, angle)
          end
          if ent:IsPlayer() then ent:DrG_Send("DrG/PlayerSightLost", self) end
        else
          self:OnEntityNotInSight(ent, angle)
          self:ReactInThread(self.DoEntityNotInSight, ent, angle)
        end
      end
    else
      local updated = {}
      local function LocalUpdateSight(ent)
        if updated[ent] then return end
        updated[ent] = true
        self:UpdateSight(ent)
      end
      for ent in pairs(self.DrG_InSight) do LocalUpdateSight(ent) end
      for _, ply in ipairs(player.GetAll()) do LocalUpdateSight(ply) end
      for ally in self:AllyIterator() do LocalUpdateSight(ally) end
      for hostile in self:HostileIterator() do LocalUpdateSight(hostile) end
    end
  end

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

  function ENT:EntitySightAngle(ent)
    local eyepos = self:EyePos()
    local eyeangles = self:EyeAngles()
    return eyepos:DrG_Degrees(
      eyepos + eyeangles:Forward(),
      ent:WorldSpaceCenter()
    )
  end

  -- meta

  local nextbotMETA = FindMetaTable("NextBot")

  local old_IsAbleToSee = nextbotMETA.IsAbleToSee
  function nextbotMETA:IsAbleToSee(ent, useFOV, ...)
    if self.IsDrGNextbot then
      if not EnableSight:GetBool() then return false end
      if not IsValid(ent) then return false end
      if ent == self then return true end
      local flags = SIGHT_TEST_PASSED_ALL
      if not self:Visible(ent) then
        flags = flags - SIGHT_TEST_LOS
      end
      if self:EyePos():DistToSqr(ent:WorldSpaceCenter()) > self:GetMaxVisionRange()^2 then
        flags = flags - SIGHT_TEST_RANGE
      end
      local fov = self:GetFOV()
      if useFOV ~= false and fov < 360 then
        local angle = self:EntitySightAngle(ent)
        if angle > fov/2 then
          flags = flags - SIGHT_TEST_ANGLE
        end
      end
      if ent:IsPlayer() then
        local luminosity = ent:FlashlightIsOn() and 1 or ent:DrG_Luminosity()
        if luminosity < self:GetMinLuminosity() or luminosity > self:GetMaxLuminosity() then
          flags = flags - SIGHT_TEST_LUMINOSITY
        end
      end
      if isfunction(self.CustomSightTest) then
        local res = self:CustomSightTest(ent, SightInfo(self, ent, flags))
        if isbool(res) then return res end
      end
      return flags == SIGHT_TEST_PASSED_ALL
    else return old_IsAbleToSee(self, ent, useFOV, ...) end
  end

  local old_GetFOV = nextbotMETA.GetFOV
  function nextbotMETA:GetFOV(...)
    if self.IsDrGNextbot then
      return math.Clamp(self.SightFOV, 0, 360)
    else return old_GetFOV(self, ...) end
  end
  local old_SetFOV = nextbotMETA.SetFOV
  function nextbotMETA:SetFOV(fov, ...)
    if self.IsDrGNextbot then
      self.SightFOV = tonumber(fov)
    else return old_SetFOV(self, fov, ...) end
  end

  local old_GetMaxVisionRange = nextbotMETA.GetMaxVisionRange
  function nextbotMETA:GetMaxVisionRange(...)
    if self.IsDrGNextbot then
      return math.max(0, self.SightRange)
    else return old_GetMaxVisionRange(self, ...) end
  end
  local old_SetMaxVisionRange = nextbotMETA.SetMaxVisionRange
  function nextbotMETA:SetMaxVisionRange(range, ...)
    if self.IsDrGNextbot then
      self.SightRange = tonumber(range)
    else return old_SetMaxVisionRange(self, range, ...) end
  end

  -- hooks

  function ENT:OnEntitySight(_ent, _angle) end
  function ENT:OnEntitySightLost(_ent, _angle) end
  function ENT:OnEntitySightKept(ent, _angle) self:DetectEntity(ent, 30) end
  function ENT:OnEntityNotInSight(_ent, _angle) end

  -- Sounds --

  function ENT:IsDeaf()
    return not EnableHearing:GetBool() or self:GetHearingCoefficient() == 0
  end
  function ENT:GetHearingCoefficient()
    return math.Clamp(self.HearingCoefficient, 0, math.huge)
  end
  function ENT:SetHearingCoefficient(coeff)
    self.HearingCoefficient = coeff
  end

  function ENT:ListenTo(ent, listen)
    if not IsValid(ent) or ent == self then return end
    ent.DrG_Listening = ent.DrG_Listening or {}
    local rmv = "DrG/RemoveDrGNextbot"..self:GetCreationID().."FromListening"
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
    ent.DrG_Listening = ent.DrG_Listening or {}
    return ent.DrG_Listening[self] or false
  end

  -- hooks

  local OnSoundDeprecation = DrGBase.Deprecation("ENT:OnSound(entity, sound)", "ENT:OnEntitySound(ent, sound)")
  function ENT:OnEntitySound(ent, sound)
    if isfunction(self.OnSound) then
      OnSoundDeprecation()
      self:OnSound(ent, sound)
    else self:DetectEntity(ent) end
  end

  hook.Add("EntityEmitSound", "DrG/SoundDetection", function(sound)
    if not EnableHearing:GetBool() then return end
    local ent = sound.Entity
    if not istable(ent.DrG_Listening) then return end
    local pos = sound.Pos or ent:GetPos()
    local radius = math.pow(sound.SoundLevel/2, 2)*sound.Volume
    for nextbot in pairs(ent.DrG_Listening) do
      if not IsValid(nextbot) or not nextbot.IsDrGNextbot then continue end
      local mult = nextbot:VisibleVec(pos) and 1 or 0.5
      if (radius*nextbot:GetHearingCoefficient()*mult)^2 >= nextbot:GetRangeSquaredTo(pos) then
        nextbot:OnEntitySound(ent, sound)
        nextbot:ReactInThread(nextbot.DoEntitySound, ent, sound)
        if ent:IsPlayer() then ent:DrG_Send("DrG/PlayerSound", nextbot) end
      end
    end
  end)

  -- Other --

  function ENT:OnContact(ent)
    self:DetectEntity(ent)
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

  function ENT:OnEntitySight() end
  function ENT:OnEntitySightLost() end
  function ENT:OnEntitySightKept() end
  function ENT:OnEntityNotInSight() end
  function ENT:OnEntitySound() end

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
    if ent ~= LocalPlayer() then return false end
    return self.DrG_LocalPlayerInSight or false
  end

end