if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot" -- DO NOT TOUCH (obviously)

-- Misc --
ENT.PrintName = "Test Nextbot"
ENT.Category = "DrGBase"
ENT.Models = {"models/player/gman_high.mdl"}

-- AI --
ENT.RangeAttackRange = 100
ENT.MeleeAttackRange = 0
ENT.ReachEnemyRange = 100
ENT.AvoidEnemyRange = 25

-- Movements/animations --
ENT.WalkAnimation = ACT_HL2MP_WALK
ENT.RunAnimation = ACT_HL2MP_RUN_FAST
ENT.RunSpeed = 300
ENT.IdleAnimation = ACT_HL2MP_IDLE
ENT.JumpAnimation = ACT_HL2MP_JUMP_KNIFE

-- Detection --
ENT.EyeBone = "ValveBiped.Bip01_Head1"
ENT.EyeOffset = Vector(5, 0, 2.5)

-- Possession --
ENT.PossessionEnabled = true
ENT.PossessionMovement = POSSESSION_MOVE_NSEW
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
  [IN_JUMP] = {
    {
      coroutine = false,
      onkeydown = function(self)
        self:Jump(100)
      end
    }
  },
  [IN_ATTACK] = {
    {
      coroutine = false,
      onkeydown = function(self)
        self:PlaySequence("gesture_wave")
      end
    }
  },
  [IN_ATTACK2] = {
    {
      coroutine = false,
      onkeydown = function(self)
        self:EmitSlotSound("riseandshine", 7, "DrGBase.RiseAndShine")
      end
    }
  }
}

if SERVER then

  sound.Add({
    name = "DrGBase.RiseAndShine",
    sound = "vo/gman_misc/gman_riseshine.wav",
    channel = CHAN_VOICE,
    level = 60
  })

  function ENT:CustomInitialize()
    self:SetDefaultRelationship(D_HT)
    self:SetSelfClassRelationship(D_LI)
    self:SetPlayersRelationship(D_HT, 2)
    for i, walk in ipairs({
      self.RunAnimation,
      self.WalkAnimation
    }) do
      self:SequenceEvent(self:SelectRandomSequence(walk), {0.28, 0.78}, function(self)
        self:EmitFootstep()
      end)
    end
  end

  function ENT:OnRangeAttack(enemy)
    if self:IsMoving() then return end
    self:FaceTowards(enemy)
    self:PlaySequence("gesture_wave")
    self:EmitSlotSound("riseandshine", 7, "DrGBase.RiseAndShine")
  end

  function ENT:OnReachedPatrol()
    self:PlaySequenceAndWait("menu_gman")
  end
  function ENT:OnIdle()
    self:AddPatrolPos(self:RandomPos(1500))
  end

  function ENT:OnDeath(dmg)
    if self:IsClimbing() then return end
    local deaths = {
      "death_01", "death_02", "death_03", "death_04"
    }
    self:PlaySequenceAndWait(deaths[math.random(#deaths)])
  end

  function ENT:OnRemove()
    self:StopSound("DrGBase.RiseAndShine")
  end

end

-- DO NOT TOUCH --
AddCSLuaFile()
DrGBase.AddNextbot(ENT)
