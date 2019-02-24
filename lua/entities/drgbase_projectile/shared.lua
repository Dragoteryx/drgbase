ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.IsDrGProjectile = true

ENT.PrintName = "Projectile"
ENT.Category = "DrGBase"

DrGBase.IncludeFile("meta.lua")

function ENT:ScreenShake(amplitude, frequency, duration, radius)
  return util.ScreenShake(self:GetPos(), amplitude, frequency, duration, radius)
end

if SERVER then
  AddCSLuaFile("shared.lua")

  function ENT:Initialize()
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
      phys:Wake()
    end
  end
  function ENT:Think()
    return self:ProjThink()
  end
  function ENT:ProjThink() end

  -- Collisions --

  function ENT:PhysicsCollide(data)
    if not data.HitEntity:IsWorld() then return end
    if not self:ProjFilter(data.HitEntity) then return end
    self:ProjContact(data.HitEntity)
  end
  function ENT:Touch(ent)
    if ent:IsWeapon() and IsValid(ent:GetOwner()) then
      local owner = ent:GetOwner()
      if not self:ProjFilter(owner) then return end
      self:ProjContact(owner)
    elseif self:ProjFilter(ent) then self:ProjContact(ent) end
  end
  function ENT:ProjFilter(ent)
    if ent:IsWorld() then return true end
    if not IsValid(ent) then return false end
    if not IsValid(self._DrGBaseNextbotOwner) then return true end
    return self._DrGBaseNextbotOwner:EntIndex() ~= ent:EntIndex() and not self._DrGBaseNextbotOwner:IsAlly(ent)
  end
  function ENT:ProjContact() end

  -- Misc --

  function ENT:Use(activator, caller, useType, value)
    return self:ProjUse(activator, caller, useType, value)
  end
  function ENT:ProjUse() end
  function ENT:OnTakeDamage(dmg)
    return self:ProjDamage(dmg)
  end
  function ENT:ProjDamage() end
  function ENT:OnRemove()
    self:ProjRemove()
  end
  function ENT:ProjRemove() end

  -- Helpers --

  function ENT:ParabolicTrajectory(pos, options)
    local phys = self:GetPhysicsObject()
    if not IsValid(phys) then return Vector(0, 0, 0)
    else return phys:DrG_ParabolicTrajectory(pos, options) end
  end

  function ENT:DirectTrajectory(pos, options)
    local phys = self:GetPhysicsObject()
    if not IsValid(phys) then return Vector(0, 0, 0)
    else return phys:DrG_DirectTrajectory(pos, options) end
  end

  function ENT:DealDamage(ent, value, type)
    local dmg = DamageInfo()
    dmg:SetDamage(value)
    dmg:SetDamageForce(self:GetVelocity())
    dmg:SetDamageType(type or DMG_DIRECT)
    if IsValid(self:GetOwner()) then
      dmg:SetAttacker(self:GetOwner())
    else dmg:SetAttacker(game.GetWorld()) end
    dmg:SetInflictor(self)
    ent:TakeDamageInfo(dmg)
  end

else

  function ENT:Draw()
    self:DrawModel()
  end

end
