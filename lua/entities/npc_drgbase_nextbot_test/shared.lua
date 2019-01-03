ENT.Base = "drgbase_nextbot" -- DO NOT TOUCH (obviously)
ENT.AdminOnly = false

ENT.Name = "DrGBase Test Nextbot"
ENT.Class = "npc_drgbase_nextbot_test"
ENT.Category = "DrGBase"
ENT.Models = {
  "models/player/police.mdl",
  "models/player/police_fem.mdl"
}
ENT.Skins = {1}
ENT.ModelScale = 1
ENT.Killicon = {
  icon = "HUD/killicons/default",
  color = Color(255, 80, 0, 255)
}
ENT.DeathAnimations = {}
ENT.RagdollOnDeath = true
ENT.RagdollCallback = function(ragdoll, dmg)
  ragdoll._DrGBaseTestNextbotRagdoll = true
  ragdoll:Timer_DrG(0, function()
    ragdoll:Ignite(300)
  end)
  local rand = math.random(3, 10)
  ragdoll:Timer_DrG(rand, function()
    ragdoll._DrGBaseTestNextbotRagdoll = false
    if not ragdoll:IsOnFire() then return end
    ragdoll:Explode_DrG({
      damage = rand*100,
      radius = rand*100
    })
  end)
end
ENT.AmbientSounds = {}
ENT.ParallelToGround = false

ENT.MaxHealth = 100
ENT.Range = 99999
ENT.Reach = 100
ENT.Omniscient = false
ENT.ForgetTime = 10

ENT.SightFOV = 150
ENT.SightRange = 6000
ENT.EyesBone = "ValveBiped.Bip01_Head1"
ENT.HearingRange = 250
ENT.HearingRangeBullets = 5000

ENT.PossessionEnabled = true
ENT.Possession = {
  distance = 100,
  offset = Vector(0, 0, 15),
  binds = {
    {
      bind = IN_ATTACK,
      onkeydown = function(self)
        self:Wave()
      end,
      coroutine = false
    },
    {
      bind = IN_ATTACK2,
      onkeydown = function(self)
        local dmg = DamageInfo()
        dmg:SetAttacker(self:GetPossessor())
        dmg:SetInflictor(self)
        dmg:SetDamage(self:Health())
        self:TakeDamageInfo(dmg)
      end,
      coroutine = false
    },
    {
      bind = IN_JUMP,
      onkeypressed = function(self)
        self:Jump(100)
      end,
      coroutine = true
    },
    {
      bind = IN_RELOAD,
      onkeydown = function(self)
        self:Reload()
      end
    }
  }
}

if SERVER then -- Server-side --

  function ENT:Initialize_DrG()
    self._Used = {}
    self._WaveDelay = 0
    self._ReloadDelay = 0
    self:GiveWeapon("weapon_ar2")
  end
  function ENT:Think_DrG()
    if not self:IsPossessed() and math.random(1, 1000) == 1 then
      self:Reload()
    end
  end
  function ENT:Use_DrG(ply)
    if self._Used[ply:GetCreationID()] == nil then self._Used[ply:GetCreationID()] = false end
    self._Used[ply:GetCreationID()] = not self._Used[ply:GetCreationID()]
    self:RefreshTargetPriorities(ply)
  end
  function ENT:OnRemove_DrG() end
  function ENT:SpawnedBy(ply) end

  function ENT:Wave()
    if CurTime() < self._WaveDelay then return true end
    self._WaveDelay = CurTime()+2
    self:PlayGesture("gesture_wave")
    return true
  end

  function ENT:Reload()
    if CurTime() < self._ReloadDelay then return end
    self._ReloadDelay = CurTime()+2.5
    self:PlayGesture("reload_ar2")
    self:EmitSound("weapons/ar2/npc_ar2_reload.wav")
  end

  -- Target
  function ENT:FollowTarget(target) end
  function ENT:ReachedTarget(target)
    if not target._DrGBaseTestNextbotRagdoll then return self:Wave() end
  end

  -- No target
  function ENT:FetchDestination()
    return self:RandomPos(1500)
  end
  function ENT:MovingToDestination(destination) end
  function ENT:ReachedDestination(destination, reached) end

  -- Interactions
  function ENT:FetchNPCRelationship(npc)
    return D_HT
  end
  function ENT:FetchTargetPriority(ent)
    if ent._DrGBaseTestNextbotRagdoll then return 1 end
    if self._Used[ent:GetCreationID()] then return 1 end
  end
  function ENT:OnSeeEntity(ent) end
  function ENT:OnHearEntity(ent, sound) end
  --function ENT:OnHearBullet(ent, bullet) end
  function ENT:OnSpotEntity(ent) end

  -- Possession
  function ENT:OnPossess(ply) end
  function ENT:OnDispossess(ply) end
  function ENT:PossessionGroundSpeed(sprint)
    if sprint then return 300
    else return 100 end
  end

  -- State / stuff --
  function ENT:OnStateChange(oldstate, newstate) end
  function ENT:GroundSpeed(state)
    if state == DRGBASE_NEXTBOT_STATE_TARGET then return 300
    elseif state == DRGBASE_NEXTBOT_STATE_DESTINATION then return 100 end
  end
  function ENT:IdleDuration()
    return math.random(3, 10)
  end
  function ENT:CanOpenDoor(door, contact)
    return true
  end
  function ENT:CloseDoor(door)
    return 2
  end
  function ENT:CanBreakDoor(door, contact) end
  function ENT:BreakDoorDelay(door) end
  function ENT:OnFallDamage(zvelocity, waterlevel)
    if zvelocity > 700 then return zvelocity/20/(waterlevel+1) end
  end

  -- Sounds and animations
  function ENT:SyncAnimation(speed, onground)
    if not onground then return "jump_ar2"
    elseif speed <= 1 then return "idle_passive"
    elseif speed <= 110 then return "walk_passive"
    else return "run_ar2"
    end
  end
  function ENT:OnSyncedAnimation(sequence, rate) end

  -- Hooks
  function ENT:PhysgunPickup_DrG(ply) end
  function ENT:PhysgunDrop_DrG(ply) end
  function ENT:OnContact_DrG(ent) end
  function ENT:OnIgnite_DrG() end
  function ENT:OnInjured_DrG(dmg, fatal)
    if fatal then return end
    local sounds = {
      "npc/metropolice/pain1.wav",
      "npc/metropolice/pain2.wav",
      "npc/metropolice/pain3.wav",
      "npc/metropolice/pain4.wav"
    }
    self:EmitSound(sounds[math.random(#sounds)])
  end
  function ENT:OnKilled_DrG(dmg)
    local sounds = {
      "npc/metropolice/die1.wav",
      "npc/metropolice/die2.wav",
      "npc/metropolice/die3.wav",
      "npc/metropolice/die4.wav"
    }
    self:EmitSound(sounds[math.random(#sounds)])
  end
  function ENT:OnLandOnGround_DrG(ent) end
  function ENT:OnLeaveGround_DrG(ent) end
  function ENT:OnNavAreaChanged_DrG(oldarea, newarea) end
  function ENT:OnOtherKilled_DrG(ent, dmg) end
  function ENT:OnStuck_DrG() end
  function ENT:OnUnStuck_DrG() end
  function ENT:NoNavmesh() end

else -- Client-side --

  function ENT:Initialize_DrG() end
  function ENT:Think_DrG() end
  function ENT:OnRemove_DrG() end

  function ENT:FollowTarget(target) end
  function ENT:ReachedTarget(target) end
  function ENT:MovingToDestination(destination) end
  function ENT:ReachedDestination(destination, reached) end

  function ENT:OnPossess() end
  function ENT:OnDispossess() end
  function ENT:OnStateChange(oldstate, newstate) end

  function ENT:PhysgunPickup_DrG(ply) end
  function ENT:PhysgunDrop_DrG(ply) end
  function ENT:NoNavmesh() end

end

-- DO NOT TOUCH --
if SERVER then
  AddCSLuaFile("shared.lua")
end
DrGBase.Nextbot.Load({
  Name = ENT.Name,
  Class = ENT.Class,
  Category = ENT.Category,
  Killicon = ENT.Killicon,
  AdminOnly = ENT.AdminOnly
})
