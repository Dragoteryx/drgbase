if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot" -- DO NOT TOUCH (obviously)

-- Misc --
ENT.AnimationType = DRGBASE_ANIMTYPE_BODYMOVEXY

-- Relationships --
ENT.CommunicateWithAllies = true
ENT.EnemyReach = 1500
ENT.EnemyStop = 750
ENT.EnemyAvoid = 375

-- Detection --
ENT.EyeBone = "ValveBiped.Bip01_Head1"
ENT.EyeOffset = Vector(5, 0, 2.5)
ENT.EyeAngle = Angle(75, 0, 0)

-- Weapons --
ENT.UseWeapons = true
ENT.DropWeaponOnDeath = true

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

-- Human --
ENT.RunSpeed = 200
ENT.WalkSpeed = 100
ENT.CrouchSpeed = 50

function ENT:IsSprinting()
  return self:Speed() > self.WalkSpeed*1.1
end
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
  function ENT:OnPursueEnemy(enemy)
    local stop = self.EnemyStop or self.EnemyReach
    self:FollowEntity(enemy, {
      maxage = 0.5, draw = GetConVar("developer"):GetBool()
    }, function()
      if self:IsPossessed() then return "possession" end
      if self:CoroutineCallbacks() then return "callbacks" end
      if not IsValid(enemy) then return "invalid" end
      if self:InRange(enemy, stop) then return "keepdistance" end
      if IsValid(enemy) and self:InRange(enemy, self.EnemyReach) and
      self:LineOfSight(enemy, 360, math.huge) then
        self:EnemyInRange(enemy)
      end
    end)
    return true
  end
  function ENT:EnemyInRange(enemy)
    if math.random(50) == 1 then self:SetDrGVar("DrGBaseCrouching", true) end
    if not self._DrGBaseReadyToFire then return end
    if not self:HasWeapon() then return end
    self.loco:FaceTowards(enemy:GetPos())
    if not self:CanSeeEntity(enemy) then return end
    self:WeaponPrimary()
  end

  -- Movement --
  function ENT:GroundSpeed(state)
    if self:IsCrouching() then return self.CrouchSpeed
    elseif state == DRGBASE_STATE_AI_FIGHT or
    state == DRGBASE_STATE_AI_AVOID then return self.RunSpeed
    else return self.WalkSpeed end
  end

  -- Possession --
  function ENT:PossessionGroundSpeed(sprint)
    if self:IsCrouching() then return self.CrouchSpeed
    elseif sprint then return self.RunSpeed
    else return self.WalkSpeed end
  end

  -- Animations --
  local passives = {
    ["ar2"] = true,
    ["smg"] = true,
    ["shotgun"] = true
  }
  local defaults = {
    ["pistol"] = true,
    ["revolver"] = true,
    ["melee"] = true,
    ["fist"] = true,
    ["knife"] = true,
    ["duel"] = true
  }
  function ENT:SyncAnimation(speed, onground, flying)
    local holdtype = self:HasWeapon() and self:GetActiveWeapon():GetHoldType() or "normal"
    if not self._DrGBaseReadyToFire then
      if defaults[holdtype] then holdtype = "normal"
      elseif passives[holdtype] then holdtype = "passive" end
    end
    if not self:HasWeapon() or holdtype == "normal" then
      if not onground then return "jump_knife"
      elseif self:IsCrouching() then
        if speed > 0 then return "cwalk_all"
        else return "cidle_all" end
      elseif speed > 120 then return "run_all_01"
      elseif speed > 0 then return "walk_all"
      else return "idle_all_01" end
    else
      if holdtype == "grenade" then holdtype = "melee"
      elseif holdtype == "smg" then holdtype = "smg1" end
      if not onground then return "jump_"..holdtype
      elseif self:IsCrouching() then
        if speed > 0 then return "cwalk_"..holdtype
        else return "cidle_"..holdtype end
      elseif speed > 120 then return "run_"..holdtype
      elseif speed > 0 then return "walk_"..holdtype
      else return "idle_"..holdtype end
    end
  end

end

-- DO NOT TOUCH --
if SERVER then
  AddCSLuaFile("shared.lua")
end
