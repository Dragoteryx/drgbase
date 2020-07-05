-- Convars --

local AllOmniscient = CreateConVar("drgbase_ai_omniscient", "0", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})

-- Getters/setters --

function ENT:IsOmniscient()
  return AllOmniscient:GetBool() or self:GetNW2Bool("DrGBaseOmniscient", tobool(self.Omniscient))
end

-- Hooks --

function ENT:OnSpotEntity() end
function ENT:OnLoseEntity() end

if SERVER then
  util.AddNetworkString("DrGBaseNextbotPlayerAwareness")

  ENT._DrGBaseSpotted = {}

  local function SpotTimerName(self, ent)
    return "DrGBaseNB"..self:GetCreationID().."SpotENT"..ent:GetCreationID()
  end

  -- Getters/setters --

  function ENT:SetOmniscient(omniscient)
    self:SetNW2Bool("DrGBaseOmniscient", tobool(omniscient))
  end

  function ENT:GetSpotDuration()
    return self.SpotDuration
  end
  function ENT:SetSpotDuration(duration)
    self.SpotDuration = tonumber(duration)
  end

  function ENT:HasSpotted(ent)
    if not IsValid(ent) then return false end
    if ent == self then return true end
    if self:IsOmniscient() then return true end
    return self._DrGBaseSpotted[ent] or false
  end
  function ENT:HasLost(ent)
    if not IsValid(ent) then return false end
    if ent == self then return false end
    if self:IsOmniscient() then return false end
    return self._DrGBaseSpotted[ent] == false
  end

  -- Util --

  function ENT:SpotEntity(ent)
    if not IsValid(ent) then return end
    if ent:IsPlayer() and not ent:Alive() then return end
    if ent:IsPlayer() and GetConVar("ai_ignoreplayers"):GetBool() then return end
    if self:GetSpotDuration() <= 0 then return end
    local spotted = self:HasSpotted(ent)
    self._DrGBaseSpotted[ent] = true
    local disp = self:GetRelationship(ent)
    if disp == D_LI or disp == D_HT or disp == D_FR then
      self._DrGBaseRelationshipCachesSpotted[disp][ent] = true
    end
    if spotted then
      self:OnSpotEntity(ent)
      self:ReactInCoroutine(self.OnSpottedEntity, ent)
      if ent:IsPlayer() then
        net.Start("DrGBaseNextbotPlayerAwareness")
        net.WriteEntity(self)
        net.WriteBit(true)
        net.Send(ent)
      end
    end
    local timerName = SpotTimerName(self, ent)
    timer.Remove(timerName)
    timer.Create(timerName, self:GetSpotDuration(), 1, function()
      if not IsValid(self) or not IsValid(ent) then return end
      self:LoseEntity(ent)
    end)
  end
  function ENT:LoseEntity(ent)
    if not IsValid(ent) then return end
    if not self:HasSpotted(ent) then return end
    if self:HasLost(ent) then return end
    if ent:IsPlayer() then
      net.Start("DrGBaseNextbotPlayerAwareness")
      net.WriteEntity(self)
      net.WriteBit(false)
      net.Send(ent)
    end
    timer.Remove(SpotTimerName(self, ent))
    self._DrGBaseSpotted[ent] = false
    local disp = self:GetRelationship(ent)
    if disp == D_LI or disp == D_HT or disp == D_FR then
      self._DrGBaseRelationshipCachesSpotted[disp][ent] = nil
    end
    self:OnLoseEntity(ent)
    self:ReactInCoroutine(self.OnLostEntity, ent)
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
    else self:OnLoseEntity(ply) end
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

  function ENT:HasSpottedLocalPlayer()
    if self:IsOmniscient() then return true end
    return self._DrGBaseLocalPlayerAwareness == 1
  end
  function ENT:HasLostLocalPlayer()
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