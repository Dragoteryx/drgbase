local function Deprecated(nextbot, oldFunction, newFunction)
  if not GetConVar("developer"):GetBool() then return end
  ErrorNoHalt(nextbot, " Deprecation: 'ENT:" + oldFunction + "' is deprecated, you should use 'ENT:" + newFunction + "' instead", "\n")
end

-- AI --

function ENT:HadEnemy()
  Deprecated(self, "HadEnemy", "HasEnemy")
  return self:HasEnemy()
end

if SERVER then

  -- AI --

  -- Animations --

  -- Movements --

  -- Possession --

  function ENT:Possess(ply)
    Deprecated(self, "Possess(player)", "SetPossessor(player | NULL)")
    self:SetPossessor(ply)
  end
  function ENT:Dispossess()
    Deprecated(self, "Dispossess()", "StopPossession()")
    self:StopPossession()
  end

  -- Misc --

end