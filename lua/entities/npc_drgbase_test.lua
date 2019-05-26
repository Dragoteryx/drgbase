if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot" -- DO NOT TOUCH (obviously)

-- Misc --
ENT.Name = "DrGBase Test Nextbot"
ENT.Class = "npc_drgbase_test"
ENT.Category = "DrGBase"
ENT.Models = {"models/player/gman_high.mdl"}

-- Movements/animations --
ENT.WalkAnimation = ACT_HL2MP_WALK
ENT.RunAnimation = ACT_HL2MP_RUN
ENT.IdleAnimation = ACT_HL2MP_IDLE
ENT.JumpAnimation = ACT_HL2MP_JUMP_KNIFE

-- Climbing --
ENT.ClimbLadders = true
ENT.ClimbSpeed = 100
ENT.ClimbUpAnimation = ACT_ZOMBIE_CLIMB_UP
ENT.ClimbOffset = Vector(-14, 0, 0)

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
    bind = IN_JUMP,
    coroutine = true,
    onkeydown = function(self)
      self:QuickJump(100)
    end
  }
}

if SERVER then
  DrGBase.GetBehaviourTree("DefaultAI"):Print()

  sound.Add({
    name = "DrGBaseRiseAndShine",
    sound = "vo/gman_misc/gman_riseshine.wav",
    channel = CHAN_VOICE,
    level = 60
  })

  function ENT:CustomInitialize()
    self:SetPlayersRelationship(D_HT)
    self:DefineSequenceCallback({
      self:SelectRandomSequence(self.RunAnimation),
      self:SelectRandomSequence(self.WalkAnimation)
    }, {0.3, 0.8}, function()
      self:EmitFootstep()
    end)
  end

  function ENT:Use()
    self:SpotEntity(Entity(1))
  end

  function ENT:CustomThink()
    --print(#DrGBase.GetNextbots())
    print(self:GetAwarenessLevel(Entity(1)))
  end

  function ENT:InAttackRange(enemy)
    self:FaceTowards(enemy)
    --self:PlayAnimation("gesture_wave")
    self:EmitSlotSound("riseandshine", 7, "DrGBaseRiseAndShine")
  end

  function ENT:OnIdle()
    self:PlaySequenceAndWait("menu_gman")
    self:AddPatrolPos(self:RandomPos(15000))
  end

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
      self:EmitSlotSound("DrGBaseLadderClimbing", 0.5, "player/footsteps/ladder"..math.random(4)..".wav")
    end)
  end

  function ENT:OnDeath(dmg)
    return dmg:GetDamageForce():Length() < 10000
  end
  function ENT:DoOnDeath(dmg)
    local deaths = {
      "death_01", "death_02", "death_03", "death_04"
    }
    self:PlaySequenceAndWait(deaths[math.random(#deaths)])
  end

end

-- DO NOT TOUCH --
AddCSLuaFile()
DrGBase.AddNextbot(ENT)
