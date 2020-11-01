-- ConVars --

local EnableRoam = DrGBase.ConVar("drgbase_ai_roam", "1")

-- Getters --

function ENT:IsAIDisabled()
  return GetConVar("ai_disabled"):GetBool() or self:GetNW2Bool("DrG/AIDisabled") or (SERVER and not self:IsInWorld())
end

if SERVER then

  function ENT:SetAIDisabled(disabled)
    self:SetNW2Bool("DrG/AIDisabled", tobool(disabled))
  end
  function ENT:DisableAI()
    self:SetAIDisabled(true)
  end
  function ENT:EnableAI()
    self:SetAIDisabled(false)
  end

  -- Hooks --

  function ENT:AIBehaviour()
    if self:HasEnemy() then
      self:DoHandleEnemy(self:GetEnemy())
    else self:DoPassive() end
  end

  function ENT:DoPassive()
    if #self.DrG_RoamTo > 0 and EnableRoam:GetBool() then
      local pos = self.DrG_RoamTo[1]
      local res = self:DoRoam(pos)
      if isbool(res) then
        if res then self:DoRoamReached(pos)
        else self:DoRoamUnreachable(pos) end
        table.remove(self.DrG_RoamTo, 1)
      end
    else self:DoIdle() end
  end

  local OnPatrolDeprecation = DrGBase.Deprecation("ENT:OnPatrol()", "ENT:DoRoam()")
  function ENT:DoRoam(pos)
    if isfunction(self.OnPatrol) then -- backwards compatibility
      OnPatrolDeprecation()
      return self:OnPatrol(pos)
    else
      return self:GoTo(pos, function(self)
        if self:HasEnemy() then return "enemy" end
        if self:IsPossessed() then return "possessed" end
      end)
    end
  end

  ENT.DrG_RoamTo = {}
  function ENT:RoamTo(pos)
    table.insert(self.DrG_RoamTo, pos)
  end
  function ENT:RoamAtRandom(min, max)
    if not EnableRoam:GetBool() then return end
    self:RoamTo(self:RandomPos(min, max))
  end

  local OnIdleDeprecation = DrGBase.Deprecation("ENT:OnIdle()", "ENT:DoIdle()")
  function ENT:DoIdle(...)
    if isfunction(self.OnIdle) then -- backwards compatibility
      OnIdleDeprecation()
      self:OnIdle(...)
    else self:RoamAtRandom(1500) end
  end

  function ENT:ShouldRun()
    return self:HasEnemy() and self:HasDetectedRecently(self:GetEnemy())
  end

end