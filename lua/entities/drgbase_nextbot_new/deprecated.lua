local function Deprecated(self, oldFunction, newFunction)
  if not GetConVar("developer"):GetBool() then return end
  ErrorNoHalt(self, " Deprecation: 'ENT:" + oldFunction + "' is deprecated, you should use 'ENT:" + newFunction + "' instead", "\n")
end

if SERVER then

  -- AI --

  -- Animations --

  -- Movements --

  -- Possession --

  function ENT:Possess(ply)
    Deprecated(self, "Possess", "SetPossessor")
    self:SetPossessor(ply)
  end
  function ENT:Dispossess()
    Deprecated(self, "Dispossess", "StopPossession")
    self:StopPossession()
  end

  -- Misc --

end