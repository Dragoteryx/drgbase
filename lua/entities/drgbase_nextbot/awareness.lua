
-- Getters/setters --

function ENT:IsOmniscient()
  return self:GetNW2Bool("DrGBaseOmniscient")
end

-- Functions --

-- Hooks --

-- Handlers --

function ENT:_InitAwareness()
  if CLIENT then return end
  self:SetOmniscient(self.Omniscient)
  self._DrGBaseAwareness = {}
  self:SetSpottedAwarenessDecrease(self.SpottedAwarenessDecrease)
  self:SetLostAwarenessDecrease(self.LostAwarenessDecrease)
  self:SetAwarenessDecreaseDelay(self.AwarenessDecreaseDelay)
end

if SERVER then

  -- Awareness class --

  local Awareness = {}
  Awareness.__index = Awareness
  function Awareness:New(nextbot, ent)
    local aware = {}
    aware._nextbot = nextbot
    aware._ent = ent
    aware._level = 0
    aware._callbacks = {}
    aware._spotted = false
    aware._decreasedelay = 0
    setmetatable(aware, self)
    aware:Init()
    return aware
  end
  function Awareness:GetLevel()
    return self._level
  end
  function Awareness:SetLevel(level)
    if level > 1 then level = 1 end
    if level < 0 then level = 0 end
    local old = self._level
    if level > old then self._decreasedelay = CurTime() end
    self._level = level
    if not IsValid(self._nextbot) or not IsValid(self._ent) then return end
    for str, act in pairs(self._callbacks) do
      if level < act.min or level > act.max then continue end
      act.callback(old, level)
    end
  end
  function Awareness:AddCallback(str, min, max, callback)
    self._callbacks[str] = {
      min = min, max = max,
      callback = callback
    }
  end
  function Awareness:RemoveCallback(str)
    self._callbacks[str] = nil
  end
  function Awareness:IncreaseLevel(incr)
    self:SetLevel(self:GetLevel() + incr)
  end
  function Awareness:DecreaseLevel(decr)
    self:SetLevel(self:GetLevel() - decr)
  end
  function Awareness:Init()
    coroutine.DrG_Create(function()
      while IsValid(self._nextbot) and IsValid(self._ent) do
        if CurTime() > self._decreasedelay + self._nextbot:GetAwarenessDecreaseDelay() then
          if self:Spotted() then
            self:DecreaseLevel(1/(self._nextbot:GetSpottedAwarenessDecrease()/5))
          else
            self:DecreaseLevel(1/(self._nextbot:GetLostAwarenessDecrease()/5))
          end
        end
        coroutine.wait(0.2)
      end
    end)
  end
  function Awareness:GetNextbot()
    return self._nextbot
  end
  function Awareness:GetEntity()
    return self._ent
  end
  function Awareness:Spotted()
    return self._spotted
  end

  -- Getters/setters --

  function ENT:SetOmniscient(omniscient)
    return self:SetNW2Bool("DrGBaseOmniscient", omniscient)
  end

  function ENT:_GetAwareness(ent)
    local crea = ent:GetCreationID()
    if not self._DrGBaseAwareness[crea] then
      local awareness = Awareness:New(self, ent)
      awareness:AddCallback("DrGBaseOnSpotEntity", 1, 1, function(old, new)
        if not awareness:Spotted() then
          awareness._spotted = true
          self:OnSpotEntity(ent)
          if self:IsEnemy(ent) then self:RefreshEnemy() end
          self:UpdateBehaviourTree()
        end
      end)
      awareness:AddCallback("DrGBaseOnLostEntity", 0, 0, function(old, new)
        if awareness:Spotted() then
          awareness._spotted = false
          self:OnLostEntity(ent)
          self:UpdateBehaviourTree()
        end
      end)
      self._DrGBaseAwareness[crea] = awareness
      return awareness
    else return self._DrGBaseAwareness[crea] end
  end

  function ENT:GetAwarenessLevel(ent)
    if self:IsOmniscient() then return 1 end
    return self:_GetAwareness(ent):GetLevel()
  end
  function ENT:SetAwarenessLevel(ent, level)
    if ent:IsPlayer() and (GetConVar("ai_ignoreplayers"):GetBool() or not ent:Alive()) and level > 0 then
      return self:SetAwarenessLevel(ent, 0)
    end
    self:_GetAwareness(ent):SetLevel(level)
  end

  function ENT:HasSpottedEntity(ent)
    return self:IsOmniscient() or self:_GetAwareness(ent):Spotted()
  end
  function ENT:HasLostEntity(ent)
    return not self:HasSpottedEntity(ent)
  end

  function ENT:GetSpottedAwarenessDecrease()
    return self._DrGBaseSpottedAwarenessDecrease
  end
  function ENT:SetSpottedAwarenessDecrease(decr)
    self._DrGBaseSpottedAwarenessDecrease = decr
  end

  function ENT:GetLostAwarenessDecrease()
    return self._DrGBaseLostAwarenessDecrease
  end
  function ENT:SetLostAwarenessDecrease(decr)
    self._DrGBaseLostAwarenessDecrease = decr
  end

  function ENT:GetAwarenessDecreaseDelay()
    return self._DrGBaseAwarenessDecreaseDelay
  end
  function ENT:SetAwarenessDecreaseDelay(delay)
    if delay < 0.25 then delay = 0.25 end
    self._DrGBaseAwarenessDecreaseDelay = delay
  end

  -- Functions --

  function ENT:IncreaseAwarenessLevel(ent, incr)
    self:_GetAwareness(ent):IncreaseLevel(incr)
  end
  function ENT:DecreaseAwarenessLevel(ent, decr)
    self:_GetAwareness(ent):DecreaseLevel(decr)
  end

  function ENT:SpotEntity(ent)
    self:SetAwarenessLevel(ent, 1)
  end
  function ENT:LoseEntity(ent)
    self:SetAwarenessLevel(ent, 0)
  end

  -- Hooks --

  function ENT:OnSpotEntity() end
  function ENT:OnLostEntity() end

  -- Handlers --

  hook.Add("PostPlayerDeath", "DrGBaseForgetDeadPlayers", function(ply)
    for i, nextbot in ipairs(DrGBase.GetNextbots()) do
      nextbot:LoseEntity(ply)
    end
  end)

else

  -- Getters/setters --

  -- Functions --

  -- Hooks --

  -- Handlers --

end
