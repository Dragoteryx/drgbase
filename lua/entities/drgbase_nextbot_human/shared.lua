if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot" -- DO NOT TOUCH (obviously)

-- Stats --
ENT.FallDamage = true

-- AI --
ENT.EnemyReach = 1500
ENT.EnemyStop = 750
ENT.EnemyAvoid = 375
ENT.AttackAfraid = true

-- Movements/animations --
DrGBase.IncludeFile("animations.lua")
DrGBase.IncludeFile("movements.lua")
ENT.WalkSpeed = 100
ENT.WalkAnimRate = 1
ENT.RunSpeed = 200
ENT.RunAnimRate = 1
ENT.CrouchSpeed = 50
ENT.CrouchWalkAnimRate = 1
ENT.CrouchIdleAnimRate = 1
ENT.IdleAnimRate = 1

-- Climbing --
ENT.ClimbLadders = true
ENT.ClimbSpeed = 100
ENT.ClimbUpAnimation = ACT_ZOMBIE_CLIMB_UP
ENT.ClimbOffset = Vector(-14, 0, 0)

-- Weapons --
DrGBase.IncludeFile("weapons.lua")
ENT.UseWeapons = true
ENT.DropWeaponOnDeath = true
ENT.AcceptPlayerWeapons = true

-- Detection --
ENT.EyeBone = "ValveBiped.Bip01_Head1"
ENT.EyeOffset = Vector(5, 0, 2.5)

-- Possession --
ENT.PossessionEnabled = true
ENT.PossessionViews = {
  {
    offset = Vector(0, 30, 20),
    distance = 100
  },
  {
    offset = Vector(7.5, 0, 2.5),
    distance = 0,
    eyepos = true
  }
}
ENT.PossessionBinds = {
  {
    bind = IN_DUCK,
    coroutine = false,
    onkeypressed = function(self)
      self:ToggleCrouching()
    end
  },
  {
    bind = IN_JUMP,
    coroutine = false,
    onkeydown = function(self)
      if not self:IsOnGround() then return end
      self:EmitFootstep()
      self:QuickJump()
    end
  },
  {
    bind = IN_RELOAD,
    coroutine = false,
    onkeypressed = function(self)
      if not self:HasWeapon() then return end
      self:ToggleWeaponHolstered()
    end
  },
  {
    bind = IN_ATTACK,
    coroutine = false,
    onkeydown = function(self)
      if not self:HasWeapon() then return end
      if self:IsWeaponPrimaryEmpty() then
        self:WeaponReload(self:GetReloadAnimation())
      else self:WeaponPrimaryFire(self:GetShootAnimation()) end
    end
  },
  {
    bind = IN_ATTACK2,
    coroutine = false,
    onkeydown = function(self)
      if not self:HasWeapon() then return end
      if self:IsWeaponSecondaryEmpty() then
        self:WeaponReload(self:GetReloadAnimation())
      else self:WeaponSecondaryFire(self:GetShootAnimation()) end
    end
  }
}

-- Other --
DrGBase.IncludeFile("misc.lua")

if SERVER then

  -- Setup --

  function ENT:_BaseInitialize()
    self.loco:SetJumpHeight(100)
    local walks = {
      self.RunAnimations,
      self.WalkAnimations,
      self.CrouchWalkAnimations
    }
    for i, walk in ipairs(walks) do
      for holdtype, act in pairs(walk) do
        self:DefineSequenceCallback(self:SelectRandomSequence(act), {0.28, 0.78}, function(self)
          self:EmitFootstep()
        end)
      end
    end
  end
  function ENT:_BaseThink()
    if not self:IsPossessed() then
      if self:IsMoving() then self:SetCrouching(false) end
      if self:HasEnemy() then
        local enemy = self:GetEnemy()
        self:UnholsterWeapon()
        if self:IsInSight(enemy) then
          self:AimAt(enemy)
        else self:AimAt() end
      elseif self:HasWeapon() then
        self:HolsterWeapon()
        if not self:IsWeaponPrimaryFull() then
          self:WeaponReload()
        end
      end
    else
      local tr = self:PossessorTrace()
      self:LookAt(tr.HitPos)
      if self:HasWeapon() and not self:IsWeaponHolstered() then
        self:AimAt(tr.HitPos)
      else self:AimAt() end
    end
  end

  -- AI --

  function ENT:EnemyInRange(enemy)
    if not self:IsMoving() then self:FaceTowardsEntity(enemy)end
    if math.random(50) == 1 then self:SetCrouching(true) end
    if not self:HasWeapon() then return end
    if not self:IsInSight(enemy) then return end
    local tr = util.TraceLine({
        start = self:GetShootPos(),
        endpos = self:GetShootPos() + self:GetAimVector()*999999999,
        filter = {self, self:GetWeapon()}
      })
    if IsValid(tr.Entity) and self:IsAlly(tr.Entity) then return end
    if self:IsWeaponPrimaryEmpty() then
      self:WeaponReload(self:GetReloadAnimation())
    else self:WeaponPrimaryFire(self:GetShootAnimation()) end
  end

  -- Misc --

  function ENT:OnLandOnGround()
    self:EmitFootstep()
  end
  function ENT:WhileClimbing(ladder, left, down)
    if IsValid(ladder) then
      self:EmitSlotSound("DrGBaseLadderClimbing", 0.3, "player/footsteps/ladder"..math.random(4)..".wav")
    end
    return not down and left < 112.5
  end
  function ENT:OnStopClimbing(ladder, down)
    if down then return end
    local footstep = false
    self:PlayAnimationAndMoveAbsolute(ACT_ZOMBIE_CLIMB_END, self.ClimbAnimRate, function(cycle)
      if cycle >= 0.875 and not footstep then
        footstep = true
        self:EmitFootstep()
      end
      if cycle > 0.5 or not IsValid(ladder) then return end
      self:EmitSlotSound("DrGBaseLadderClimbing", 0.3, "player/footsteps/ladder"..math.random(4)..".wav")
    end)
  end

else



end

-- DO NOT TOUCH --
if SERVER then
  AddCSLuaFile("shared.lua")
end
