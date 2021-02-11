if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot" -- DO NOT TOUCH (obviously)

-- Misc --
ENT.PrintName = "Test Nextbot"
ENT.Category = "DrGBase"
ENT.Models = {"models/player/gman_high.mdl"}

-- AI --
ENT.BehaviourType = AI_BEHAV_BASE
ENT.RangeAttackRange = 100
ENT.MeleeAttackRange = 0
ENT.ReachEnemyRange = 50
ENT.AvoidEnemyRange = 25

-- Relationships --
ENT.DefaultRelationship = D_NU
ENT.Factions = {"FACTION_GMAN"}

-- Animations --
ENT.WalkAnimation = ACT_HL2MP_WALK
ENT.RunAnimation = ACT_HL2MP_RUN_FAST
ENT.IdleAnimation = ACT_HL2MP_IDLE
ENT.JumpAnimation = ACT_HL2MP_JUMP_KNIFE

-- Movements --
ENT.WalkSpeed = -1
ENT.RunSpeed = 300

-- Climbing --
ENT.ClimbLedges = true
ENT.ClimbProps = true
ENT.ClimbLedgesMaxHeight = math.huge
ENT.ClimbLadders = true
ENT.ClimbSpeed = 60
ENT.ClimbUpAnimation = ACT_ZOMBIE_CLIMB_UP
ENT.ClimbOffset = Vector(-14, 0, 0)

-- Detection --
ENT.EyeBone = "ValveBiped.Bip01_Head1"
ENT.EyeOffset = Vector(5, 0, 2.5)

-- Possession --
ENT.PossessionEnabled = true
ENT.PossessionMove = POSSESSION_MOVE_8DIR
ENT.PossessionViews = {
  {auto = true},
  {
    offset = Vector(5, 0, 0),
    eyepos = true
  }
}

if SERVER then

  sound.Add({
    name = "DrGBase.RiseAndShine",
    sound = "vo/gman_misc/gman_riseshine.wav",
    channel = CHAN_VOICE,
    level = 60
  })

  function ENT:Initialize()
    self:SetPlayersRelationship(D_HT)
    self:AddAnimEventCycle("walk_all", 0.28, "StepLeft")
    self:AddAnimEventCycle("run_all_02", 0.28, "StepLeft")
    self:AddAnimEventCycle("walk_all", 0.78, "StepRight")
    self:AddAnimEventCycle("run_all_02", 0.78, "StepRight")
  end

  function ENT:Use()
    print("use", CurTime())
    self:AddGestureSequence(self:LookupSequence("gesture_wave"))
  end

  function ENT:OnPossessionBinds(binds)
    if binds:WasPressed("IN_ATTACK") then
      print(self:PlaySequence("gesture_wave"))
    end
  end

  function ENT:OnAnimEvent(event)
    if event == "StepLeft" or event == "StepRight" then self:EmitFootstep() end
  end

end

-- DO NOT TOUCH --
AddCSLuaFile()
DrGBase.AddNextbot(ENT)