function ENT:GetPossessor()
  return self:GetNW2Entity("DrG/Possessor")
end
function ENT:IsPossessed()
  return IsValid(self:GetPossessor())
end

if SERVER then

  -- Setters --

  function ENT:SetPossessor(ply)
    if IsValid(ply) and ply:IsPlayer() then

    else

    end
  end
  function ENT:StopPossession()
    return self:SetPossessor(nil)
  end

  -- Hooks --

  -- Internal --

  function ENT:DrG_PossessedBehaviour(thr)

  end

else

  function ENT:IsPossessedByLocalPlayer()
    return self:GetPossessor() == LocalPlayer()
  end

end