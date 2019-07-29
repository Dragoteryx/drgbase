
-- Convars --

local AllOmniscient = CreateConVar("drgbase_ai_omniscient", "0", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})

-- Getters/setters --

function ENT:IsOmniscient()
  return AllOmniscient:GetBool() or self:GetNW2Bool("DrGBaseOmniscient")
end

function ENT:GetSpotDuration()
  return self:GetNW2Float("DrGBaseSpotDuration")
end

function ENT:GetSpotted()
  local entities = {}
  for i, ent in ipairs(ents.GetAll()) do
    if self:HasSpotted(ent) then table.insert(entities, ent) end
  end
  return entities
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
  self._DrGBaseLastTimeSpotted = {}
  self._DrGBaseLastKnownPos = {}
  self:SetSpotDuration(self.SpotDuration)
end

if SERVER then

  -- Getters/setters --

  function ENT:SetOmniscient(omniscient)
    self:SetNW2Bool("DrGBaseOmniscient", omniscient)
  end

  function ENT:SetSpotDuration(duration)
    self:SetNW2Float("DrGBaseSpotDuration", duration)
  end

  function ENT:LastTimeSpotted(ent)
    return self._DrGBaseLastTimeSpotted[ent] or -1
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
    if ent:IsPlayer() and not ent:Alive() then return end
    if ent:IsPlayer() and GetConVar("ai_ignoreplayers"):GetBool() then return end
    if self:GetSpotDuration() == 0 then return end
    local spotted = self:HasSpotted(ent)
    self._DrGBaseLastTimeSpotted[ent] = CurTime()
    self._DrGBaseSpotted[ent] = true
    self:UpdateKnownPosition(ent)
    if not spotted then
      self:OnSpotted(ent)
      self:NetMessage("DrGBaseHasSpotted", ent)
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
    self:NetMessage("DrGBaseHasLost", ent)
    timer.Remove(self:_SpotTimerName(ent))
    self._DrGBaseSpotted[ent] = false
    self:OnLost(ent)
  end
  function ENT:_SpotTimerName(ent)
    return "DrGBaseNB"..self:GetCreationID().."SpotENT"..ent:GetCreationID()
  end

  function ENT:AlertAllies(ent, spotted)
    if not self:HasSpotted(ent) then return end
    for ally in self:AllyIterator(spotted) do
      if not ally.IsDrGNextbot then continue end
      ally:SpotEntity(ent)
    end
  end

  -- Handlers --

  cvars.AddChangeCallback("ai_ignoreplayers", function(name, old, new)
    for i, nextbot in ipairs(DrGBase.GetNextbots()) do
      if tobool(new) then
        for h, ply in ipairs(player.GetAll()) do
          nextbot:LoseEntity(ply)
        end
      end
      nextbot:UpdateAI()
    end
  end, "DrGBaseIgnorePlayers")

  hook.Add("PostPlayerDeath", "DrGBaseForgetPlayerDeath", function(ply)
    for i, nextbot in ipairs(DrGBase.GetNextbots()) do
      nextbot:LoseEntity(ply)
      nextbot:UpdateAI()
    end
  end)

else

  -- Getters/setters --

  function ENT:HasSpottedLocalPlayer()
    return self:HasSpotted(LocalPlayer())
  end
  function ENT:HasLostLocalPlayer()
    return self:HasLost(LocalPlayer())
  end

end
