
-- Getters/setters --

function ENT:GetWeapon()
  return self:GetNW2Entity("DrGBaseWeapon")
end

-- Functions --

-- Hooks --

function ENT:OnWeaponChange() end

-- Handlers --

function ENT:_InitWeapons()
  if SERVER then

  else

  end
  self:SetNWVarProxy("DrGBaseWeapon", function(self, name, old, new)
    if old ~= new then self:OnWeaponChange(old, new) end
  end)
end

if SERVER then

  -- Getters/setters --

  -- Functions --

  -- Hooks --

  function ENT:ShouldPickupWeapon() end
  function ENT:ShouldDropWeapon() end

  -- Handlers --

else

  -- Getters/setters --

  -- Functions --

  -- Hooks --

  -- Handlers --

end
