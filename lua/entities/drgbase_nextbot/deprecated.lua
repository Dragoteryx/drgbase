-- AI --

ENT.HadEnemy = DrGBase.Deprecated("ENT:HadEnemy()", "ENT:HasEnemy()", function(self)
  return self:HasEnemy()
end)

if SERVER then

  -- Coroutine --

  ENT.YieldCoroutine = DrGBase.Deprecated("ENT:YieldCoroutine(cancellable)", "ENT:YieldThread(cancellable)", function(self, cancellable)
    return self:YieldThread(cancellable)
  end)

  -- AI --

  -- Animations --

  ENT.PlayClimbSequence = DrGBase.Deprecated(
    "ENT:PlayClimbSequence(sequence, height, rate, fn)", "ENT:PlaySequencAndClimb(sequence, options, fn)",
    function(self, sequences, height, rate, fn)
      return self:PlaySequenceAndClimb(sequences, {
        height = height, rate = rate
      }, fn)
    end
  )

  -- Movements --

  -- Detection --

  ENT.HasSpotted = DrGBase.Deprecated("ENT:HasSpotted(entity)", "ENT:HasDetected(entity)", function(self, ent)
    return self:HasDetected(ent)
  end)
  ENT.HasLost = DrGBase.Deprecated("ENT:HasLost(entity)", "ENT:HasForgotten(entity)", function(self, ent)
    return self:HasForgotten(ent)
  end)

  ENT.SpotEntity = DrGBase.Deprecated("ENT:SpotEntity(entity)", "ENT:DetectEntity(entity, recent)", function(self, ent)
    return self:DetectEntity(ent, self.SpotDuration or 30)
  end)
  ENT.LoseEntity = DrGBase.Deprecated("ENT:LoseEntity(entity)", "ENT:ForgetEntity(entity)", function(self, ent)
    return self:ForgetEntity(ent)
  end)

  -- Possession --

  ENT.Possess = DrGBase.Deprecated("ENT:Possess(player)", "ENT:SetPossessor(player | NULL)", function(self, ply)
    return self:SetPossessor(ply)
  end)
  ENT.Dispossess = DrGBase.Deprecated("ENT:Dispossess()", "ENT:StopPossession()", function(self)
    return self:StopPossession()
  end)

  -- Misc --

end