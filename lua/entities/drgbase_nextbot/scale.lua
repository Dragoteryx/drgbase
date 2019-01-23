
function ENT:GetScale()
  return self:GetDrGVar("DrGBaseScale")
end

function ENT:InRange(ent, dist)
  return self:GetPos():DistToSqr(ent:GetPos()) <= math.pow(dist*self:GetScale(), 2)
end

if SERVER then

  function ENT:SetScale(scale)
    self:SetDrGVar("DrGBaseScale", scale)
    self:SetModelScale(self.ModelScale*scale)
  end

  function ENT:Scale(mult)
    self:SetScale(self:GetScale()*mult)
  end

else



end
