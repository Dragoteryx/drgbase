
-- Getters/setters --

function ENT:GetActiveWeapon()
  return self:GetNW2Entity("DrGBaseWeapon")
end
function ENT:GetWeapon(class)
  if isstring(class) then
    return self._DrGBaseWeapons[class] or NULL
  else return self:GetActiveWeapon() end
end
function ENT:HasWeapon(class)
  return IsValid(self:GetWeapon(class))
end
function ENT:HaveWeapon(class)
  return self:HasWeapon(class)
end

function ENT:GetWeapons()
  return table.DrG_Copy(self._DrGBaseWeapons)
end
function ENT:GetWeaponCount()
  return table.Count(self._DrGBaseWeapons)
end

-- Functions --

-- Hooks --

function ENT:OnPickupWeapon() end
function ENT:OnDropWeapon() end

-- Handlers --

function ENT:_InitWeapons()
  self._DrGBaseWeapons = {}
  if CLIENT then return end
  if self.UseWeapons then
    if isstring(self.Equipment) and self.AcceptPlayerWeapons and
    GetConVar("drgbase_give_weapons"):GetBool() then
      self:GiveWeapon(self.Equipment)
    elseif #self.Weapons > 0 then
      self:GiveWeapon(self.Weapons[math.random(#self.Weapons)])
    end
  end
end

if SERVER then

  -- Misc --

  local function IsWeapon(ent)
    return isentity(ent) and IsValid(ent) and ent:IsWeapon()
  end

  -- Getters/setters --

  function ENT:SetActiveWeapon(weapon)
    if not IsWeapon(weapon) then return false end
    if self._DrGBaseWeapons[weapon:GetClass()] ~= weapon then return false end
    local active = self:GetActiveWeapon()
    if IsValid(active) then active:SetNoDraw(true) end
    weapon:SetNoDraw(false)
    self:SetNW2Entity("DrGBaseWeapon", weapon)
    return true
  end

  -- Functions --

  function ENT:GiveWeapon(class)
    local weapon = ents.Create(class)
    if not IsValid(weapon) then return NULL end
    if IsWeapon(weapon) then
      weapon:Spawn()
      if not self:PickupWeapon(weapon) then
        weapon:Remove()
        return NULL
      else return weapon end
    else
      weapon:Remove()
      return NULL
    end
  end
  function ENT:PickupWeapon(weapon)
    if not IsWeapon(weapon) then return false end
    if self:HasWeapon(weapon:GetClass()) then return false end
    weapon:SetMoveType(MOVETYPE_NONE)
    weapon:SetOwner(self)
  	weapon:SetParent(self)
  	weapon:AddEffects(EF_BONEMERGE)
    self._DrGBaseWeapons[weapon:GetClass()] = weapon
    self:OnPickupWeapon(weapon, weapon:GetClass())
    self:NetMessage("DrGBasePickupWeapon", weapon)
    if IsValid(self:GetActiveWeapon()) then
      weapon:SetNoDraw(true)
    else self:SetActiveWeapon(weapon) end
    return true
  end

  function ENT:RemoveWeapon(weapon)
    weapon = self:DropWeapon(weapon or self:GetActiveWeapon())
    if IsValid(weapon) then
      weapon:Remove()
      return weapon
    else return NULL end
  end
  function ENT:DropWeapon(weapon)
    if weapon == nil then weapon = self:GetActiveWeapon() end
    if isstring(weapon) then weapon = self:GetWeapon(weapon) end
    if not IsWeapon(weapon) then return NULL end
    if self._DrGBaseWeapons[weapon:GetClass()] ~= weapon then return NULL end
    local active = self:GetActiveWeapon()
    weapon:SetOwner(NULL)
    weapon:SetParent(NULL)
    weapon:RemoveEffects(EF_BONEMERGE)
    weapon:SetMoveType(MOVETYPE_VPHYSICS)
    weapon:SetPos(self:WorldSpaceCenter())
    self._DrGBaseWeapons[weapon:GetClass()] = nil
    self:OnDropWeapon(weapon, weapon:GetClass())
    self:NetMessage("DrGBaseDropWeapon", weapon:GetClass())
    if active == weapon then self:SwitchWeapon() end
    weapon:SetNoDraw(false)
    return weapon
  end

  function ENT:SelectWeapon(class)
    local weapon = self:GetWeapon(class)
    if not IsValid(weapon) then return NULL end
    self:SetActiveWeapon(weapon)
    return weapon
  end
  function ENT:SwitchWeapon(class)
    local weapon = table.DrG_Fetch(self._DrGBaseWeapons, function(weap1, weap2)
      if not IsValid(weap1) then return false end
      if not IsValid(weap2) then return true end
      local res = self:OnSwitchWeapon(weap1, weap2)
      if isbool(res) then return res end
      return weap1:GetWeight() > weap2:GetWeight()
    end)
    if not IsValid(weapon) then return NULL end
    self:SetActiveWeapon(weapon)
    return weapon
  end

  -- Hooks --

  function ENT:OnSwitchWeapon() end

  -- Handlers --

  hook.Add("PlayerCanPickupWeapon", "DrGBaseNextbotWeaponPlayerPickup", function(ply, weapon)
    if IsValid(weapon:GetOwner()) and weapon:GetOwner().IsDrGNextbot then return false end
  end)

else

  -- Getters/setters --

  -- Functions --

  -- Hooks --

  -- Handlers --

end
