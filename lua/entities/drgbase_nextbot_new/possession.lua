function ENT:GetPossessor()
  return self:GetNW2Entity("DrGBasePossessor")
end
function ENT:IsPossessed()
  return IsValid(self:GetPossessor())
end

if SERVER then

  -- Setters --

  function ENT:SetPossessor(ply)
    if isentity(ply) and IsValid(ply) and IsPlayer(ply) then
      
    else
      
    end
    return self
  end
  function ENT:StopPossession()
    return self:SetPossessor(nil)
  end

  -- Hooks --

  -- Internal --

  function ENT:_DrGBasePossessedBehaviour()
    
  end

else

  function ENT:IsPossessedByLocalPlayer()
    return self:GetPossessor() == LocalPlayer()
  end

end