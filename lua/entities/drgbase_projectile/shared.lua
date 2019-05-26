ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.IsDrGProjectile = true

ENT.PrintName = "Projectile"
ENT.Category = "DrGBase"

DrGBase.IncludeFile("meta.lua")

function ENT:Timer(duration, callback)
  timer.Simple(duration, function()
    if IsValid(self) then callback(self) end
  end)
end
function ENT:LoopTimer(delay, callback)
  timer.DrG_Loop(delay, function()
    if not IsValid(self) then return false end
    return callback(self)
  end)
end

function ENT:ScreenShake(amplitude, frequency, duration, radius)
  return util.ScreenShake(self:GetPos(), amplitude, frequency, duration, radius)
end

if SERVER then
  AddCSLuaFile()

  function ENT:Initialize()
    self:SetModel("models/props_junk/watermelon01.mdl")
    self._DrGBaseFilterOwner = true -- whether or not the default filter bypasses the owner
    self._DrGBaseFilterAllies = true -- whether or not the default filter bypasses allies
    self:CustomInitialize()
  end
  function ENT:CustomInitialize() end

  function ENT:Think()
    self:CustomThink()
    self:NextThink(CurTime())
    return true
  end
  function ENT:CustomThink() end

  -- Collisions --

  function ENT:PhysicsCollide(data)
    if not data.HitEntity:IsWorld() then return end
    if not self:ProjFilter(data.HitEntity) then return end
    self:CustomContact(data.HitEntity)
  end
  function ENT:Touch(ent)
    if ent:IsWeapon() and IsValid(ent:GetOwner()) then
      local owner = ent:GetOwner()
      if not self:ProjFilter(owner) then return end
      self:CustomContact(owner)
    elseif self:ProjFilter(ent) then self:CustomContact(ent) end
  end
  function ENT:CustomContact() end

  -- Filter --

  function ENT:ProjFilter(ent)
    if not ent:IsWorld() and not IsValid(ent) then return false end
    local owner = self:GetOwner()
    if IsValid(owner) then
      if self:FilterOwner() and owner == ent then return false end
      if self:FilterAllies() and owner:IsAlly(ent) then return false end
    end
    return self:CustomFilter(ent) or false
  end
  function ENT:CustomFilter(ent)
    return true
  end

  -- Misc --

  function ENT:Use(activator, caller, useType, value)
    self:CustomUse(activator, caller, useType, value)
  end
  function ENT:CustomUse() end

  function ENT:OnTakeDamage(dmg)
    self:CustomDamage(dmg)
  end
  function ENT:CustomDamage() end

  function ENT:OnRemove()
    self:CustomRemove()
  end
  function ENT:CustomRemove() end

  -- Setters --

  function ENT:FilterOwner(bool)
    if bool == nil then return self._DrGBaseFilterOwner
    else self._DrGBaseFilterOwner = tobool(bool) end
  end

  function ENT:FilterAllies(bool)
    if bool == nil then return self._DrGBaseFilterAllies
    else self._DrGBaseFilterAllies = tobool(bool) end
  end

  -- Helpers --

  function ENT:ThrowAt(target, options)
    local phys = self:GetPhysicsObject()
    if not IsValid(phys) then return Vector(0, 0, 0) end
    if isentity(target) then
      local vec, info = math.DrG_BallisticTrajectory(self:GetPos(), target:WorldSpaceCenter(), options)
      return self:ThrowAt(target:WorldSpaceCenter() + target:GetVelocity()*info.duration, options)
    else return phys:DrG_BallisticTrajectory(target, options) end
  end

  function ENT:DealDamage(ent, value, type)
    local dmg = DamageInfo()
    dmg:SetDamage(value)
    dmg:SetDamageForce(self:GetVelocity())
    dmg:SetDamageType(type or DMG_DIRECT)
    if IsValid(self:GetOwner()) then
      dmg:SetAttacker(self:GetOwner())
    else dmg:SetAttacker(self) end
    dmg:SetInflictor(self)
    ent:TakeDamageInfo(dmg)
  end

else

  function ENT:Initialize()
    if self._DrGBaseInitialized then return end
    self._DrGBaseInitialized = true
    self:CustomInitialize()
  end
  function ENT:CustomInitialize() end

  function ENT:Think()
    self:Initialize()
    self:CustomThink()
  end
  function ENT:CustomThink() end

  function ENT:Draw()
    self:DrawModel()
    self:CustomDraw()
  end
  function ENT:CustomDraw() end

end
