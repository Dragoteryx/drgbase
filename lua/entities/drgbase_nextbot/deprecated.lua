local function Deprecated(nextbot, oldFunction, newFunction)
  if not GetConVar("developer"):GetBool() then return end
  ErrorNoHalt(nextbot, " Deprecation: 'ENT:" + oldFunction + "' is deprecated, you should use 'ENT:" + newFunction + "' instead", "\n")
end

-- AI --

function ENT:HadEnemy()
  Deprecated(self, "HadEnemy()", "HasEnemy()")
  return self:HasEnemy()
end

if SERVER then

  -- AI --

  -- Animations --

  -- Movements --

  -- Detection --

  function ENT:HasSpotted(ent)
    Deprecated(self, "HasSpotted(entity)", "HasDetected(entity)")
    return self:HasDetected(ent)
  end
  function ENT:HasLost(ent)
    Deprecated(self, "HasLost(entity)", "HasForgotten(entity)")
    return self:HasForgotten(ent)
  end

  function ENT:SpotEntity(ent)
    Deprecated(self, "SpotEntity(entity)", "DetectEntity(entity, recent)")
    return self:DetectEntity(ent, self.SpotDuration or 30)
  end
  function ENT:LoseEntity(ent)
    Deprecated(self, "LoseEntity(entity)", "ForgetEntity(entity)")
    return self:ForgetEntity(ent)
  end

  -- Possession --

  function ENT:Possess(ply)
    Deprecated(self, "Possess(player)", "SetPossessor(player | NULL)")
    return self:SetPossessor(ply)
  end
  function ENT:Dispossess()
    Deprecated(self, "Dispossess()", "StopPossession()")
    return self:StopPossession()
  end

  -- Misc --

end