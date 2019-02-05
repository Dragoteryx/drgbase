if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot" -- DO NOT TOUCH (obviously)

-- Misc --
ENT.Name = "DrGBase Test Nextbot"
ENT.Class = "npc_drg_nextbot_test"
ENT.Category = "DrGBase"
ENT.Models = {
  "models/player/gman_high.mdl"
}
ENT.AnimationType = DRGBASE_ANIMTYPE_BODYMOVEXY

-- Stats --
ENT.FallDamage = true

-- Movements --
ENT.RunAnimation = ACT_HL2MP_RUN
ENT.WalkAnimation = ACT_HL2MP_WALK
ENT.IdleAnimation = "menu_gman"
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
ENT.StopClimb = 112.5
ENT.StopClimbAnimation = ACT_ZOMBIE_CLIMB_END

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
    bind = IN_ATTACK,
    coroutine = false,
    onkeydown = function(self)
      -- some stuff should go there I guess
    end
  },
  {
    bind = IN_ATTACK2,
    coroutine = false,
    onkeydown = function(self)
      self:PlayAnimation(ACT_GMOD_GESTURE_DISAGREE)
    end
  },
  {
    bind = IN_JUMP,
    coroutine = true,
    onkeydown = function(self)
      self:QuickJump(100)
    end
  }
}

if SERVER then

  -- Misc --
  function ENT:CustomInitialize()
    self:SetDefaultRelationship(D_NU)
    self:SetPlayersRelationship(D_HT)
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
    self:Idle(math.random(3, 7))
  end

  -- Possession --
  function ENT:PossessionThink(ply, tr)
    self:LookAt(tr.HitPos)
  end

  -- Hooks --
  function ENT:OnTakeDamage(dmg)
    if IsValid(dmg:GetAttacker()) then return self:HasSpottedEntity(dmg:GetAttacker()) end
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
