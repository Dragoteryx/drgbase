-- Convars --

local EnablePatrol = DrGBase.ConVar("drgbase_ai_patrol", "1")

-- Getters --

function ENT:IsAIDisabled()
  return GetConVar("ai_disabled"):GetBool() or self:GetNW2Bool("DrGBaseAIDisabled") or (SERVER and not self:IsInWorld())
end

if SERVER then

  function ENT:SetAIDisabled(disabled)
    self:SetNW2Bool("DrGBaseAIDisabled", tobool(disabled))
  end
  function ENT:DisableAI()
    self:SetAIDisabled(true)
  end
  function ENT:EnableAI()
    self:SetAIDisabled(false)
  end

  -- Hooks --

  function ENT:DoOnSpawn(...) return self:OnSpawn(...) end
  function ENT:OnSpawn() end

  function ENT:DoOnIdle(...) return self:OnIdle(...) end
  function ENT:OnIdle() end

  function ENT:DoOnEnemy(enemy)

  end
  function ENT:DoOnNoEnemy()
    if false then
      self:Patrol()
    else self:DoOnIdle() end
  end

  function ENT:ShouldRun()
    return self:HasEnemy() and self:HasDetectedRecently(self:GetEnemy())
  end

  -- Internal --

  function ENT:AIBehaviour()
    if self:HasEnemy() then
      self:DoOnEnemy(self:GetEnemy())
    else self:DoOnNoEnemy() end
  end

  -- refresh sight/enemy
  coroutine.DrG_Create(function()
    while true do
      local nextbots = DrGBase.GetNextbots()
      if #nextbots > 0 then
        for i = 1, #nextbots do
          local nextbot = nextbots[i]
          if not IsValid(nextbot) then continue end
          nextbot:UpdateHostileSight()
          nextbot:UpdateEnemy()
          coroutine.yield()
        end
      else coroutine.yield() end
    end
  end)
end