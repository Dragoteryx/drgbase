
-- Getters/setters --

function ENT:IsOmniscient()
  return self:GetNW2Bool("DrGBaseOmniscient")
end

function ENT:GetSpotDuration()
  return self:GetNW2Float("DrGBaseSpotDuration")
end

function ENT:HasSpotted(ent)
  if not IsValid(ent) then return false end
  if self:IsOmniscient() then return true end
  return self._DrGBaseSpotted[ent] or false
end
function ENT:HasLost(ent)
  if not IsValid(ent) then return false end
  if self:IsOmniscient() then return false end
  return self._DrGBaseSpotted[ent] == false
end

-- Hooks --

function ENT:OnSpotted() end
function ENT:OnLost() end

-- Handlers --

function ENT:_InitAwareness()
  self._DrGBaseSpotted = {}
  if CLIENT then return end
  self:SetOmniscient(self.Omniscient)
  self._DrGBaseLastTime = {}
  self._DrGBaseLastKnownPos = {}
  self:SetSpotDuration(self.SpotDuration)
end

if SERVER then
  util.AddNetworkString("DrGBaseSpottedEntity")
  util.AddNetworkString("DrGBaseLostEntity")

  -- Getters/setters --

  function ENT:SetOmniscient(omniscient)
    self:SetNW2Bool("DrGBaseOmniscient", omniscient)
  end

  function ENT:SetSpotDuration(duration)
    self:SetNW2Float("DrGBaseSpotDuration", duration)
  end

  function ENT:LastTimeSpotted(ent)
    return self._DrGBaseLastTime[ent] or -1
  end
  function ENT:LastKnownPosition(ent)
    return self._DrGBaseLastKnownPos[ent]
  end
  function ENT:UpdateKnownPosition(ent, pos)
    pos = isvector(pos) and pos or ent:GetPos()
    self._DrGBaseLastKnownPos[ent] = pos
  end

  -- Functions --

  function ENT:SpotEntity(ent)
    if not IsValid(ent) then return end
    if self:IsIgnored(ent) then return end
    if self:GetSpotDuration() == 0 then return end
    local spotted = self:HasSpotted(ent)
    self._DrGBaseLastTime[ent] = CurTime()
    self._DrGBaseSpotted[ent] = true
    self:UpdateKnownPosition(ent)
    if not spotted then
      self:OnSpotted(ent)
      net.Start("DrGBaseSpottedEntity")
      net.WriteEntity(self)
      net.WriteEntity(ent)
      net.Broadcast()
      self:UpdateEnemy()
    end
    local timerName = self:_SpotTimerName(ent)
    timer.Remove(timerName)
    if self:GetSpotDuration() <= 0 then return end
    timer.Create(timerName, self:GetSpotDuration(), 1, function()
      if not IsValid(self) or not IsValid(ent) then return end
      self:LoseEntity(ent)
    end)
  end
  function ENT:LoseEntity(ent)
    if not IsValid(ent) then return end
    if not self:HasSpotted(ent) then return end
    if self:HasLost(ent) then return end
    timer.Remove(self:_SpotTimerName(ent))
    self._DrGBaseSpotted[ent] = false
    self:OnLost(ent)
    net.Start("DrGBaseLostEntity")
    net.WriteEntity(self)
    net.WriteEntity(ent)
    net.Broadcast()
    self:UpdateEnemy()
  end
  function ENT:_SpotTimerName(ent)
    return "DrGBaseNB"..self:GetCreationID().."SpotENT"..ent:GetCreationID()
  end

  -- Handlers --

  cvars.AddChangeCallback("ai_ignoreplayers", function(name, old, new)
    for i, nextbot in ipairs(DrGBase.GetNextbots()) do
      if tobool(new) then
        for h, ply in ipairs(player.GetAll()) do
          nextbot:LoseEntity(ply)
        end
      end
      nextbot:UpdateEnemy()
    end
  end, "DrGBaseIgnorePlayers")

  hook.Add("PostPlayerDeath", "DrGBaseForgetPlayerDeath", function(ply)
    for i, nextbot in ipairs(DrGBase.GetNextbots()) do
      nextbot:LoseEntity(ply)
      nextbot:UpdateEnemy()
    end
  end)

else

  -- Handlers --

  net.Receive("DrGBaseSpottedEntity", function()
    local nextbot = net.ReadEntity()
    local ent = net.ReadEntity()
    if not IsValid(nextbot) then return end
    if not istable(nextbot._DrGBaseSpotted) then return end
    if not IsValid(ent) then return end
    nextbot._DrGBaseSpotted[ent] = true
    nextbot:OnSpotted(ent)
  end)
  net.Receive("DrGBaseLostEntity", function()
    local nextbot = net.ReadEntity()
    local ent = net.ReadEntity()
    if not IsValid(nextbot) then return end
    if not istable(nextbot._DrGBaseSpotted) then return end
    if not IsValid(ent) then return end
    nextbot._DrGBaseSpotted[ent] = false
    nextbot:OnLost(ent)
  end)

end
