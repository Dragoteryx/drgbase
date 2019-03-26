-- Getters/setters --

function ENT:IsOmniscient()
  return self:GetNW2Bool("DrGBaseOmniscient")
end

-- Functions --

-- Hooks --

-- Handlers --

function ENT:_InitMemory(ent)
  if CLIENT then return end
  if ent == nil then
    self._DrGBaseMemory = {}
    self:SetPursueTime(self.PursueTime)
    self:SetSearchTime(self.SearchTime)
    self:SetOmniscient(self.Omniscient)
  else
    local crea = ent:GetCreationID()
    self._DrGBaseMemory[crea] = self._DrGBaseMemory[crea] or {
      time = -1, pos = ent:GetPos(), incr = 0
    }
    return self._DrGBaseMemory[crea]
  end
end

if SERVER then

  -- Getters/setters --

  function ENT:SetOmniscient(bool)
    self:SetNW2Bool("DrGBaseOmniscient", bool)
  end

  function ENT:GetPursueTime()
    return self._DrGBasePursueTime
  end
  function ENT:SetPursueTime(time)
    self._DrGBasePursueTime = time
  end

  function ENT:GetSearchTime()
    return self._DrGBaseSearchTime
  end
  function ENT:SetSearchTime(time)
    self._DrGBaseSearchTime = time
  end

  function ENT:HasSpottedEntity(ent)
    if not IsValid(ent) then return false end
    if self:IsOmniscient() then return true end
    local spotted = self:_InitMemory(ent)
    if spotted.time < 0 then return false end
    return CurTime() < spotted.time + self:GetPursueTime() + self:GetSearchTime()
  end
  function ENT:HasLostEntity(ent)
    if not IsValid(ent) then return true end
    if self:IsOmniscient() then return false end
    if not self:HasSpottedEntity(ent) then return true end
    local spotted = self:_InitMemory(ent)
    return CurTime() >= spotted.time + self:GetPursueTime()
  end

  -- Functions --

  function ENT:SpotEntity(ent)
    if not IsValid(ent) then return end
    if ent:IsPlayer() and (not ent:Alive() or GetConVar("ai_ignoreplayers"):GetBool()) then return end
    local spotted = self:_InitMemory(ent)
    local curr = spotted.incr + 1
    spotted.incr = curr
    spotted.pos = ent:GetPos()
    spotted.lost = false
    if not self:HasSpottedEntity(ent) or self:HasLostEntity(ent) then
      spotted.time = CurTime()
      self:OnSpotEntity(ent)
    else spotted.time = CurTime() end
    self:Timer(self:GetPursueTime(), function()
      if not IsValid(ent) then return end
      if spotted.incr ~= curr then return end
      if not self:HasLostEntity(ent) then return end
      self:OnLostEntity(ent)
    end)
    self:Timer(self:GetPursueTime() + self:GetSearchTime(), function()
      if not IsValid(ent) then return end
      if spotted.incr ~= curr then return end
      if self:HasSpottedEntity(ent) then return end
      self:OnForgetEntity(ent)
    end)
  end
  function ENT:SpotAllEntities(callback)
    if callback == nil then callback = function() end end
    for i, ent in ipairs(ents.GetAll()) do
      if callback(ent) == false then continue end
      self:SpotEntity(ent)
    end
  end

  function ENT:LoseEntity(ent)
    if not IsValid(ent) then return end
    local spotted = self:_InitMemory(ent)
    if not self:HasLostEntity(ent) then
      spotted.incr = spotted.incr + 1
      spotted.time = CurTime() + self:GetPursueTime()
      self:OnLostEntity(ent)
    end
  end
  function ENT:LoseAllEntities(callback)
    if callback == nil then callback = function() end end
    for i, ent in ipairs(ents.GetAll()) do
      if callback(ent) == false then continue end
      self:LoseEntity(ent)
    end
  end

  function ENT:ForgetEntity(ent)
    if not IsValid(ent) then return end
    local spotted = self:_InitMemory(ent)
    if self:HasSpottedEntity(ent) then
      spotted.incr = spotted.incr + 1
      spotted.time = -1
      self:OnForgetEntity(ent)
    end
  end
  function ENT:ForgetAllEntities(callback)
    if callback == nil then callback = function() end end
    for i, ent in ipairs(ents.GetAll()) do
      if callback(ent) == false then continue end
      self:ForgetEntity(ent)
    end
  end

  -- Hooks --

  function ENT:OnSpotEntity() end
  function ENT:OnLostEntity() end
  function ENT:OnForgetEntity() end

  -- Handlers --

  hook.Add("PostPlayerDeath", "DrGBaseNextbotPostPlayerDeathForget", function(ply)
    for i, nextbot in ipairs(DrGBase.Nextbots.GetAll()) do nextbot:ForgetEntity(ply) end
  end)

  cvars.AddChangeCallback("ai_ignoreplayers", function(name, old, new)
    if not tobool(new) then return end
    for i, nextbot in ipairs(DrGBase.Nextbots.GetAll()) do
      nextbot:ForgetAllEntities(function(ent)
        return ent:IsPlayer()
      end)
    end
  end)

else

  -- Getters --

  -- Setters --

  -- Functions --

  -- Hooks --

  -- Handlers --

end
