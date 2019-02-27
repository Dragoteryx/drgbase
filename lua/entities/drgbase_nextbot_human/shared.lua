if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot" -- DO NOT TOUCH (obviously)

-- Misc --
ENT.FootstepSounds = true

-- Stats --
ENT.FallDamage = true

-- Movements --
ENT.CrouchSpeed = 50

-- Climbing --
ENT.ClimbLadders = true
ENT.ClimbAnimation = ACT_ZOMBIE_CLIMB_UP

-- AI --
ENT.EnemyReach = 1500
ENT.EnemyStop = 750
ENT.EnemyAvoid = 375
ENT.AttackScared = true

-- Weapons --
ENT.UseWeapons = true
ENT.DropWeaponOnDeath = true
ENT.AcceptPlayerWeapons = true

-- Grenades --
ENT.GrenadeThrowChance = 0.0075
ENT.MaxGrenadeThrow = 800
ENT.GrenadeThrowDelay = 5
ENT.GrenadeClass = "npc_grenade_frag"
ENT.GrenadeCallback = function(grenade, init)
  if not init then grenade:Fire("SetTimer", 3) end
end

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
      self:QuickJump(50)
    end
  },
  {
    bind = IN_ATTACK,
    coroutine = false,
    onkeydown = function(self)
      if not self:HasWeapon() then return end
      if not self:IsWeaponReady() then return end
      if not self:CanWeaponPrimary() then return end
      if not self:WeaponPrimary(self:GetShootAnimation()) then self:WeaponReload(self:GetReloadAnimation()) end
    end
  },
  {
    bind = IN_ATTACK2,
    coroutine = false,
    onkeydown = function(self)
      if not self:IsWeaponReady() then return end
      self:ThrowGrenade()
    end
  },
  {
    bind = IN_RELOAD,
    coroutine = false,
    onkeypressed = function(self)
      if not self:HasWeapon() then return end
      self:ToggleWeaponReady()
    end,
  }
}

DrGBase.IncludeFile("animations.lua")
DrGBase.IncludeFile("misc.lua")
DrGBase.IncludeFile("movement.lua")
DrGBase.IncludeFile("weapons.lua")

if SERVER then

  -- Misc --
  function ENT:_BaseInitialize()
    self._DrGBaseGrenadeThrowDelay = 0
    self:SetDrGVar("DrGBaseCrouching", false)
    self:DefineHitGroup(HITGROUP_HEAD, {
      "ValveBiped.Bip01_Neck1",
      "ValveBiped.Bip01_Head1",
      "ValveBiped.forward"
    })
    self:DefineHitGroup(HITGROUP_CHEST, {
      "ValveBiped.Bip01_L_Clavicle",
      "ValveBiped.Bip01_R_Clavicle",
      "ValveBiped.Bip01_Spine2",
      "ValveBiped.Bip01_Spine4"
    })
    self:DefineHitGroup(HITGROUP_STOMACH, {
      "ValveBiped.Bip01_Spine",
      "ValveBiped.Bip01_Spine1",
      "ValveBiped.Bip01_Pelvis"
    })
    self:DefineHitGroup(HITGROUP_LEFTARM, {
      "ValveBiped.Bip01_L_UpperArm",
      "ValveBiped.Bip01_L_Forearm",
      "ValveBiped.Bip01_L_Hand",
      "ValveBiped.Anim_Attachment_LH",
      "ValveBiped.Bip01_L_Finger4",
      "ValveBiped.Bip01_L_Finger41",
      "ValveBiped.Bip01_L_Finger42",
      "ValveBiped.Bip01_L_Finger3",
      "ValveBiped.Bip01_L_Finger31",
      "ValveBiped.Bip01_L_Finger32",
      "ValveBiped.Bip01_L_Finger2",
      "ValveBiped.Bip01_L_Finger21",
      "ValveBiped.Bip01_L_Finger22",
      "ValveBiped.Bip01_L_Finger1",
      "ValveBiped.Bip01_L_Finger11",
      "ValveBiped.Bip01_L_Finger12",
      "ValveBiped.Bip01_L_Finger0",
      "ValveBiped.Bip01_L_Finger01",
      "ValveBiped.Bip01_L_Finger02"
    })
    self:DefineHitGroup(HITGROUP_RIGHTARM, {
      "ValveBiped.Bip01_R_UpperArm",
      "ValveBiped.Bip01_R_Forearm",
      "ValveBiped.Bip01_R_Hand",
      "ValveBiped.Anim_Attachment_RH",
      "ValveBiped.Bip01_R_Finger4",
      "ValveBiped.Bip01_R_Finger41",
      "ValveBiped.Bip01_R_Finger42",
      "ValveBiped.Bip01_R_Finger3",
      "ValveBiped.Bip01_R_Finger31",
      "ValveBiped.Bip01_R_Finger32",
      "ValveBiped.Bip01_R_Finger2",
      "ValveBiped.Bip01_R_Finger21",
      "ValveBiped.Bip01_R_Finger22",
      "ValveBiped.Bip01_R_Finger1",
      "ValveBiped.Bip01_R_Finger11",
      "ValveBiped.Bip01_R_Finger12",
      "ValveBiped.Bip01_R_Finger0",
      "ValveBiped.Bip01_R_Finger01",
      "ValveBiped.Bip01_R_Finger02"
    })
    self:DefineHitGroup(HITGROUP_LEFTLEG, {
      "ValveBiped.Bip01_L_Thigh",
      "ValveBiped.Bip01_L_Calf",
      "ValveBiped.Bip01_L_Foot",
      "ValveBiped.Bip01_L_Toe0"
    })
    self:DefineHitGroup(HITGROUP_RIGHTLEG, {
      "ValveBiped.Bip01_R_Thigh",
      "ValveBiped.Bip01_R_Calf",
      "ValveBiped.Bip01_R_Foot",
      "ValveBiped.Bip01_R_Toe0"
    })
    self:DefineHitGroup(HITGROUP_GEAR, {
      "ValveBiped.Bip01_Pelvis"
    })
  end
  function ENT:_BaseThink()
    if not self:IsPossessed() then
      if self:IsMoving() then self:ToggleCrouching(false) end
      if self:GetEnemy() ~= nil then
        local enemy = self:GetEnemy()
        self:ToggleWeaponReady(true)
        if IsValid(enemy) and self:CanSeeEntity(enemy) then
          self:AimAt(enemy:WorldSpaceCenter())
        else self:AimAt() end
      else
        self:ToggleWeaponReady(false)
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
    if math.random(50) == 1 then self:ToggleCrouching(true) end
    if not self._DrGBaseThrowingGrenade and self.GrenadeThrowChance > 0 and
    self.GrenadeThrowChance <= 1 and math.random(1/self.GrenadeThrowChance) == 1 then
      self:FaceEntity(enemy)
      self:ThrowGrenade(enemy:GetPos())
    elseif self:CanWeaponPrimary() then
      self:FaceTowardsEntity(enemy)
      local tr = util.TraceLine({
        start = self:GetShootPos(),
        endpos = self:GetShootPos() + self:GetAimVector()*999999999,
        filter = {self, self:GetWeapon()}
      })
      if IsValid(tr.Entity) and tr.Entity:EntIndex() ~= enemy:EntIndex() and self:IsAlly(tr.Entity) then return end
      if not self:CanSeeEntity(enemy) then return end
      if not self:WeaponPrimary(self:GetShootAnimation()) then self:WeaponReload(self:GetReloadAnimation()) end
    end
  end

  -- Hooks
  function ENT:OnStartClimbing()
    return 112.5
  end
  function ENT:WhileClimbing(ladder, state, data)
    if not IsValid(ladder) then return end
    self:EmitSlottedSound("DrGBaseLadderClimbing", 0.3, "player/footsteps/ladder"..math.random(4)..".wav")
  end
  function ENT:OnStopClimbing()
    self:PlayAnimationAndMoveAbsolute(ACT_ZOMBIE_CLIMB_END, self.ClimbAnimRate, function(cycle)
      if cycle > 0.5 then return end
      self:EmitSlottedSound("DrGBaseLadderClimbing", 0.3, "player/footsteps/ladder"..math.random(4)..".wav")
    end)
  end

else

  function ENT:_BaseInitialize()
    local walks = {
      self.RunAnimations,
      self.WalkAnimations,
      self.CrouchWalkAnimations
    }
    for i, walk in ipairs(walks) do
      for holdtype, act in pairs(walk) do
        self:AddSequenceCallback(self:SelectRandomSequence(act), {0.28, 0.78}, function()
          if not self.FootstepSounds then return end
          self:EmitFootstep()
        end)
      end
    end
  end

end

-- DO NOT TOUCH --
if SERVER then
  AddCSLuaFile("shared.lua")
end
