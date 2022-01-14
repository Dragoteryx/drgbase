if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot" -- DO NOT TOUCH (obviously)

-- Misc --
ENT.PrintName = "Test Nextbot"
ENT.Category = "DrGBase"
ENT.Models = {"models/player/gman_high.mdl"}

-- AI --
ENT.BehaviourType = AI_BEHAV_BASE
ENT.RangeAttackRange = 0
ENT.MeleeAttackRange = 150
ENT.ReachEnemyRange = 50
ENT.AvoidEnemyRange = 25

-- Relationships --
ENT.DefaultRelationship = D_NU
ENT.Factions = {"FACTION_GMAN"}

-- Movements --
ENT.UseWalkframes = true

-- Animations --
ENT.WalkAnimation = ACT_HL2MP_WALK
ENT.RunAnimation = ACT_HL2MP_RUN_FAST
ENT.IdleAnimation = ACT_HL2MP_IDLE
ENT.JumpAnimation = ACT_HL2MP_JUMP_KNIFE

-- Crouching --
ENT.EnableCrouching = true
ENT.CrouchWalkAnimation = ACT_HL2MP_WALK_CROUCH
ENT.CrouchRunAnimation = ACT_HL2MP_WALK_CROUCH
ENT.CrouchIdleAnimation = ACT_HL2MP_IDLE_CROUCH

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
    self:AddAnimEventCycle("walk_all", {0.28, 0.78}, "drg.footstep")
    self:AddAnimEventCycle("cwalk_all", {0.28, 0.78}, "drg.footstep")
    self:AddAnimEventCycle("run_all_02", {0.28, 0.78}, "drg.footstep")
  end

  function ENT:DoMeleeAttack()
    if self:GetCooldown("RiseAndShine") > 0 then return end
    self:EmitSound("DrGBase.RiseAndShine")
    self:PlaySequence("gesture_wave")
    self:SetCooldown("RiseAndShine", 7)
  end

  function ENT:OnPossessionBinds(binds)
    if binds:WasPressed("IN_ATTACK") then
      self:DoMeleeAttack()
    end
  end

end

-- DO NOT TOUCH --
AddCSLuaFile()
DrGBase.AddNextbot(ENT)