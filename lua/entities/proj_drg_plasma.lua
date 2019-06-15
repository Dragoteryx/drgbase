if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "proj_drg_default"

-- Misc --
ENT.PrintName = "Plasma Ball"
ENT.Category = "DrGBase"
ENT.AdminOnly = true
ENT.Spawnable = true

-- Projectile --
ENT.Gravity = false
ENT.Physgun = false
ENT.Gravgun = true

if SERVER then
  AddCSLuaFile()

  function ENT:CustomInitialize()
    self:ParticleEffect("drg_plasma_ball", true)
    self:DynamicLight(Color(150, 255, 0), 300, 0.1)
    self:SetNoDraw(true)
    self:FilterOwner(false)
  end

  function ENT:CustomThink()
    local velocity = self:GetVelocity()
    self:SetVelocity(velocity:GetNormalized()*500)
  end

  function ENT:OnContact(ent)
    if isnumber(self._LastContact) and CurTime() < self._LastContact + 0.1 then return end
    self._LastContact = CurTime()
    if ent:GetClass() == self:GetClass() then
      -- nice explosion
    else
      self:EmitSound("weapons/stunstick/stunstick_fleshhit1.wav")
      self:DealDamage(ent, ent:Health(), DMG_SHOCK)
    end
  end

end
