ENT.Base = "drgbase_nextbot"
ENT.IsDrGNextbotSprite = true

-- Sprite --
ENT.Size = 100

-- Animations --
DrGBase.IncludeFile("animations.lua")

-- Misc --

function ENT:GetSize()
  local min, max = self:GetCollisionBounds()
  return math.abs(max - min)
end

if SERVER then
  AddCSLuaFile()

  function ENT:_BaseInitialize()
    self:SetSize(self.Size)
  end

  -- Movements --

  function ENT:UpdateSpeed()
    local speed = self:OnUpdateSpeed()
    if isnumber(speed) then self:SetSpeed(math.Clamp(speed, 0, math.huge)) end
  end

  -- Misc --

  function ENT:SetSize(size)
    local half = size/2
    self:SetCollisionBounds(Vector(-half, -half, 0), Vector(half, half, size))
  end

  function ENT:IsAttacking()
    return self:IsAttack(self:GetSpriteAnim())
  end
  function ENT:IsAttack(anim)
    return self._DrGBaseAnimAttacks[anim] or false
  end
  function ENT:SetAttack(anim, attack)
    self._DrGBaseAnimAttacks[anim] = tobool(attack)
  end

  function ENT:SequenceAttack() end
  function ENT:SpriteAnimAttack(anim, cycle, attack, callback)
    if istable(anim) then
      for i, anim in ipairs(anim) do self:SetAttack(anim, true) end
    else self:SetAttack(anim, true) end
    self:SequenceEvent(seq, cycle, function(self)
      self:Attack(attack, callback)
    end)
  end

else

  function ENT:Draw()
    self:_BaseDraw()
    self:CustomDraw()
    if self:IsPossessedByLocalPlayer() then
      self:PossessionDraw()
    end
  end
  function ENT:_BaseDraw() end
  function ENT:CustomDraw() end
  function ENT:PossessionDraw() end

end
