if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot" -- DO NOT TOUCH (obviously)

-- Misc --
ENT.AnimationType = DRGBASE_ANIMTYPE_BODYMOVEXY

-- Movements --
ENT.CrouchSpeed = 50

-- Climbing --
ENT.ClimbLadders = true
ENT.ClimbSpeed = 100
ENT.ClimbAnimRate = 1
ENT.StopClimbing = 105
ENT.StopClimbAnimation = ACT_ZOMBIE_CLIMB_END

-- Relationships --
ENT.CommunicateWithAllies = true
ENT.EnemyReach = 1500
ENT.EnemyStop = 750
ENT.EnemyAvoid = 375
ENT.AttackScared = true

-- Weapons --
ENT.UseWeapons = true
ENT.DropWeaponOnDeath = true

-- Detection --
ENT.EyeBone = "ValveBiped.Bip01_Head1"
ENT.EyeOffset = Vector(5, 0, 2.5)
ENT.EyeAngle = Angle(75, 0, 0)

-- Possession --
ENT.PossessionEnabled = true
ENT.PossessionViews = {
  {
    offset = Vector(0, 30, 20),
    distance = 100
  },
  {
    offset = Vector(7.5, 0, 0),
    distance = 0,
    eyepos = true
  }
}
ENT.PossessionBinds = {
  {
    bind = IN_DUCK,
    coroutine = false,
    onkeydown = function(self)
      self:SetDrGVar("DrGBaseCrouching", true)
    end,
    onkeyup = function(self)
      self:SetDrGVar("DrGBaseCrouching", false)
    end
  },
  {
    bind = IN_JUMP,
    coroutine = true,
    onkeydown = function(self)
      self:QuickJump(100)
    end
  },
  {
    bind = IN_ATTACK,
    coroutine = false,
    onkeydown = function(self)
      if not self._DrGBaseReadyToFire then return end
      if not self:HasWeapon() then return end
      self:WeaponPrimary()
    end
  },
  {
    bind = IN_RELOAD,
    coroutine = false,
    onkeypressed = function(self)
      if not self:HasWeapon() then return end
      self:WeaponReload()
    end
  },
  {
    bind = IN_ATTACK2,
    coroutine = false,
    onkeypressed = function(self)
      self._DrGBaseReadyToFire = not self._DrGBaseReadyToFire
    end
  }
}

DrGBase.IncludeFile("animations.lua")
DrGBase.IncludeFile("weapons.lua")

function ENT:IsCrouching()
  return self:GetDrGVar("DrGBaseCrouching")
end
function ENT:Crouching()
  return self:IsCrouching()
end

if SERVER then

  -- Misc --
  function ENT:_BaseInitialize()
    self._DrGBaseReadyToFire = false
    self:SetDrGVar("DrGBaseCrouching", false)
  end
  function ENT:_BaseThink()
    if not self:IsPossessed() then
      if self:IsMoving() then self:SetDrGVar("DrGBaseCrouching", false) end
      if self:HaveEnemy() then
        self._DrGBaseReadyToFire = true
        if self:CanSeeEntity(self:GetEnemy()) then
          self:AimAt(self:GetEnemy():WorldSpaceCenter())
        else self:AimAt() end
      else
        self._DrGBaseReadyToFire = false
        self:AimAt()
      end
    else
      local tr = self:PossessorTrace()
      self:AimAt(tr.HitPos)
    end
  end
  function ENT:Use(ply, ent) end

  -- AI --
  function ENT:OnStateChange(oldstate, newstate)
    if oldstate == DRGBASE_STATE_AI_FIGHT then self:Idle(1) end
  end
  function ENT:EnemyInRange(enemy)
    if math.random(50) == 1 then self:SetDrGVar("DrGBaseCrouching", true) end
    if not self._DrGBaseReadyToFire then return end
    if not self:HasWeapon() then return end
    self.loco:FaceTowards(enemy:GetPos())
    if not self:CanSeeEntity(enemy) then return end
    local tr = util.TraceLine({
      start = self:GetShootPos(),
      endpos = self:GetShootPos() + self:GetAimVector()*999999999,
      filter = {self, self:GetWeapon()}
    })
    if IsValid(tr.Entity) and tr.Entity:EntIndex() == enemy:EntIndex() then
      self:WeaponPrimary()
    end
  end

  -- Movement --
  function ENT:GroundSpeed(sprint)
    if self:IsCrouching() then
      if sprint then return self.WalkSpeed
      else return self.CrouchSpeed end
    elseif sprint then return self.RunSpeed
    else return self.WalkSpeed end
  end
  
  -- Hooks
  function ENT:WhileClimbing(left, ladder)
    if IsValid(ladder) then
      self:EmitSlottedSound("DrGBaseLadderClimbing", 0.3, "player/footsteps/ladder"..math.random(4)..".wav")
    end
  end

end

-- DO NOT TOUCH --
if SERVER then
  AddCSLuaFile("shared.lua")
end
