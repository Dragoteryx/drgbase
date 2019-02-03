
function ENT:IsWeaponReady()
  return self:HasWeapon() and self:GetDrGVar("DrGBaseWeaponReady")
end

if SERVER then

  function ENT:ToggleWeaponReady(bool)
    if bool == nil then self:ToggleWeaponReady(not self:IsWeaponReady())
    elseif bool then self:SetDrGVar("DrGBaseWeaponReady", true)
    else self:SetDrGVar("DrGBaseWeaponReady", false) end
  end

else



end
