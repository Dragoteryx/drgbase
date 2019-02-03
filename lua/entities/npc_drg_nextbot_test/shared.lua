if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot" -- DO NOT TOUCH (obviously)

-- Misc --
ENT.Name = "DrGBase Test Nextbot"
ENT.Class = "npc_drg_nextbot_test"
ENT.Category = "DrGBase"
ENT.Models = {
  "models/player/police.mdl",
  "models/player/police_fem.mdl"
}
ENT.AnimationType = DRGBASE_ANIMTYPE_BODYMOVEXY

-- Stats --
ENT.FallDamage = true

-- Movements --
ENT.RunAnimation = ACT_HL2MP_RUN
ENT.WalkAnimation = ACT_HL2MP_WALK
ENT.IdleAnimation = ACT_HL2MP_IDLE
ENT.JumpAnimation = ACT_HL2MP_JUMP_KNIFE

-- Relationships --
ENT.Factions = {}
ENT.EnemyReach = 250
ENT.EnemyStop = 125
ENT.EnemyAvoid = 50

-- Detection --
ENT.EyeBone = "ValveBiped.Bip01_Head1"
ENT.EyeOffset = Vector(5, 0, 2.5)
ENT.EyeAngle = Angle(75, 0, 0)

-- Climbing --
ENT.ClimbLadders = true
ENT.ClimbAnimation = ACT_ZOMBIE_CLIMB_UP
ENT.StartClimbAnimation = ACT_ZOMBIE_CLIMB_START
ENT.StopClimb = 112.5
ENT.StopClimbAnimation = ACT_ZOMBIE_CLIMB_END

-- Possession --
ENT.PossessionEnabled = true
ENT.PossessionViews = {
  {
    offset = Vector(0, 0, 20),
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
    bind = IN_ATTACK,
    coroutine = false,
    onkeydown = function(self)
      self:PlayAnimation(ACT_GMOD_GESTURE_DISAGREE)
    end
  },
  {
    bind = IN_ATTACK2,
    coroutine = false,
    onkeydown = function(self)
      self:PlayAnimation(ACT_GMOD_TAUNT_SALUTE)
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
    bind = IN_RELOAD,
    coroutine = true,
    onkeypressed = function(self)
      self:PlayAnimationAndMove(self.StopClimbAnimation)
    end
  }
}

if SERVER then

  -- Misc --
  function ENT:CustomInitialize()
    self:SetDefaultRelationship(D_HT)
  end

  -- AI --
  function ENT:EnemyInRange(enemy)
    self.loco:FaceTowards(enemy:GetPos())
    self:PlayAnimation(ACT_GMOD_GESTURE_DISAGREE)
  end
  function ENT:FetchDestination()
    return self:RandomPos(1500)
  end
  function ENT:ReachedDestination(pos)
    self:PlayAnimationAndWait("taunt_dance_base")
  end

  -- Possession --
  function ENT:PossessionThink(ply, tr)
    self:LookAt(tr.HitPos)
  end

  -- Hooks --
  function ENT:OnSpawn()

  end
  function ENT:OnTakeDamage(dmg, hitgroups, bone)
    local sounds = {
      "npc/metropolice/pain1.wav",
      "npc/metropolice/pain2.wav",
      "npc/metropolice/pain3.wav",
      "npc/metropolice/pain4.wav"
    }
    self:EmitSound(sounds[math.random(#sounds)])
  end
  function ENT:OnDeath(dmg)
    local sounds = {
      "npc/metropolice/die1.wav",
      "npc/metropolice/die2.wav",
      "npc/metropolice/die3.wav",
      "npc/metropolice/die4.wav"
    }
    self:EmitSound(sounds[math.random(#sounds)])
    return dmg:GetDamageForce():Length() < 10000
  end
  function ENT:DoOnDeath(dmg)
    local deaths = {
      "death_01", "death_02", "death_03", "death_04"
    }
    self:PlaySequenceAndWait(deaths[math.random(#deaths)])
  end
  function ENT:OnDoorContact(door)
    return "open", 0, 2
  end

end

-- DO NOT TOUCH --
if SERVER then
  AddCSLuaFile("shared.lua")
end
DrGBase.Nextbots.Load({
  Name = ENT.Name,
  Class = ENT.Class,
  Category = ENT.Category,
  Killicon = ENT.Killicon
})
