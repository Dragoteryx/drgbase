
if SERVER then

  function ENT:_InitMemory(ent)
    self._DrGBaseMemory[ent:GetCreationID()] = self._DrGBaseMemory[ent:GetCreationID()] or {
      time = -1, pos = Vector(0, 0, 0), incr = 0, lost = false
    }
    return self._DrGBaseMemory[ent:GetCreationID()]
  end

  -- Setters --

  function ENT:SpotEntity(ent)
    if self:IsPossessed() then return end
    if not IsValid(ent) then return end
    local spotted = self:_InitMemory(ent)
    local curr = spotted.incr + 1
    spotted.incr = curr
    spotted.pos = ent:GetPos()
    spotted.lost = false
    if not self:HasSpottedEntity(ent) or self:HasLostEntity(ent) then
      spotted.time = CurTime()
      self:_Debug("spotted entity '"..ent:GetClass().."' ("..ent:EntIndex()..").", "drgbase_debug_ai")
      self:OnSpotEntity(ent)
    else spotted.time = CurTime() end
    self:Timer(self.PursueTime, function()
      if not IsValid(ent) then return end
      if spotted.incr ~= curr then return end
      if not self:HasLostEntity(ent) then return end
      self:_Debug("lost entity '"..ent:GetClass().."' ("..ent:EntIndex()..").", "drgbase_debug_ai")
      self:OnLoseEntity(ent)
    end)
    self:Timer(self.PursueTime + self.SearchTime, function()
      if not IsValid(ent) then return end
      if spotted.incr ~= curr then return end
      if self:HasSpottedEntity(ent) then return end
      self:_Debug("forgot entity '"..ent:GetClass().."' ("..ent:EntIndex()..").", "drgbase_debug_ai")
      self:OnForgetEntity(ent)
    end)
  end
  function ENT:OnSpotEntity() end

  function ENT:LoseEntity(ent)
    if not IsValid(ent) then return end
    local spotted = self:_InitMemory(ent)
    if not self:HasLostEntity(ent) then
      spotted.incr = spotted.incr + 1
      spotted.time = CurTime() + self.PursueTime
      self:_Debug("lost entity '"..ent:GetClass().."' ("..ent:EntIndex()..").", "drgbase_debug_ai")
      self:OnLoseEntity(ent)
    end
  end
  function ENT:OnLoseEntity() end

  function ENT:ForgetEntity(ent)
    if not IsValid(ent) then return end
    local spotted = self:_InitMemory(ent)
    if self:HasSpottedEntity(ent) then
      spotted.incr = spotted.incr + 1
      spotted.time = -1
      self:_Debug("forgot entity '"..ent:GetClass().."' ("..ent:EntIndex()..").", "drgbase_debug_ai")
      self:OnForgetEntity(ent)
    end
  end
  function ENT:OnForgetEntity() end

  -- Getters --

  function ENT:HasSpottedEntity(ent)
    if not IsValid(ent) then return false end
    local spotted = self:_InitMemory(ent)
    if spotted.time < 0 then return false end
    return CurTime() < spotted.time + self.PursueTime + self.SearchTime
  end

  function ENT:HasLostEntity(ent)
    if not IsValid(ent) then return true end
    if not self:HasSpottedEntity(ent) then return true end
    local spotted = self:_InitMemory(ent)
    return CurTime() >= spotted.time + self.PursueTime
  end

  -- Hooks --

  hook.Add("PostPlayerDeath", "DrGBaseNextbotPostPlayerDeathForget", function(ply)
    for i, ent in ipairs(DrGBase.Nextbots.GetAll()) do ent:ForgetEntity(ply) end
  end)

  -- Aliases --

  function ENT:UpdateEnemyMemory(ent, pos)
    self:SpotEntity(ent)
  end

  function ENT:ClearEnemyMemory()
    if not self:HasEnemy() then return end
    self:ForgetEntity(self:GetEnemy())
  end

else



end
