-- ConVars --

local AllOmniscient = DrGBase.ConVar("drgbase_ai_omniscient", "0")
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

  net.DrG_DefineCallback("DrG/IsAbleToSee", function(self, ent, useFOV)
    if not IsValid(self) or not IsValid(ent) then return false end
    return self:IsAbleToSee(ent, useFOV)
  end)

  function ENT:IsBlind()
    return GetConVar("nb_blind"):GetBool() or self:GetFOV() <= 0 or self:GetMaxVisionRange() <= 0
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
      --for _, ply in ipairs(player.GetAll()) do LocalUpdateSight(ply) end
      for ally in self:AllyIterator() do LocalUpdateSight(ally) end
      for hostile in self:HostileIterator() do LocalUpdateSight(hostile) end
    end
  end

  -- meta

  local nextbotMETA = FindMetaTable("NextBot")

  local old_IsAbleToSee = nextbotMETA.IsAbleToSee
  function nextbotMETA:IsAbleToSee(ent, useFOV, ...)
    if self.IsDrGNextbot then
      if not IsValid(ent) then return false end
      if ent == self then return true end
      if self:GetRangeSquaredTo(ent) <= self:GetMaxVisionRange()^2 then
        local res = self:Visible(ent)
        local angle = -1
        if res and useFOV ~= false then
          local eyepos = self:EyePos()
          local eyeangles = self:EyeAngles()
          angle = (eyepos + eyeangles:Forward()):DrG_Degrees(ent:WorldSpaceCenter(), eyepos)
          if angle > self:GetFOV()/2 then res = false end
        end
        return res, angle
      else return false, -1 end
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
      self.SightFOV = fov
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
      self.SightRange = range
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

  function ENT:OnEntitySound(ent)
    self:DetectEntity(ent)
  end

  hook.Add("EntityEmitSound", "DrG/SoundDetection", function(sound)
    local ent = sound.Entity
    if not istable(ent.DrG_Listening) then return end
    local pos = sound.Pos or ent:GetPos()
    local distance = math.pow(sound.SoundLevel/2, 2)*sound.Volume
    for nextbot in pairs(ent.DrG_Listening) do
      if not IsValid(nextbot) or not nextbot.IsDrGNextbot then continue end
      local mult = nextbot:VisibleVec(pos) and 1 or 0.5
      if (distance*nextbot:GetHearingCoefficient()*mult)^2 >= nextbot:GetRangeSquaredTo(pos) then
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

  function ENT:HasDetectedLocalPlayer()
    if self:IsOmniscient() then return true end
    return self.DrG_LocalPlayerDetected == true
  end
  function ENT:HasForgottenLocalPlayer()
    if self:IsOmniscient() then return false end
    return self.DrG_LocalPlayerDetected == false
  end

  function ENT:IsAbleToSeeLocalPlayer()
    return self.DrG_LocalPlayerInSight or false
  end

  function ENT:IsAbleToSee(ent, useFOV, fn)
    if isfunction(useFOV) then return self:IsAbleToSee(ent, true, useFOV) end
    if not isfunction(fn) then return end
    net.DrG_RunCallback("DrG/IsAbleToSee", function(inSight)
      if not IsValid(self) then return end
      if IsValid(ent) then fn(self, inSight)
      else fn(self, false) end
    end, self, ent, tobool(useFOV))
  end

end