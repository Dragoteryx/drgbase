if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot" -- DO NOT TOUCH (obviously)

ENT.Name = "DrGBase Test Nextbot" -- name of the nextbot
ENT.Class = "npc_drg_nextbot_test" -- class of the nextbot
ENT.Category = "DrGBase" -- in which category does the nextbot appear?
ENT.Models = { -- list of models, add as many as you want
  "models/player/police.mdl",
  "models/player/police_fem.mdl"
}
ENT.Skins = {1} -- list of skins, add as many as you want
ENT.ModelScale = 1 -- model scale
ENT.Killicon = {
  icon = "HUD/killicons/default",
  color = Color(255, 80, 0, 255)
}

ENT.RagdollOnDeath = true -- whether or not the nextbot should ragdoll on death
ENT.EnableBodyMoveXY = false -- whether or not to use NEXTBOT:BodyMoveXY()
ENT.AmbientSounds = {}

ENT.MaxHealth = 100 -- how much health does the nextbot have on spawn?
ENT.HealthRegen = 0 -- how much health does the nextbot regen every second
ENT.Radius = 10000 -- the nextbot will ignore entities that are too far to prevent lag
ENT.Omniscient = false -- whether or not the nextbot needs to spot its targets to chase them
ENT.ForgetTime = 10 -- for how long does the nextbot chase targets after it has lost them
ENT.Flight = false -- whether or not the nextbot can fly
ENT.FlightMaxPitch = 45
ENT.FlightMinPitch = 45

ENT.Factions = { -- list of factions that the nextbot is in
  "DrGBase"
}
ENT.AlliedWithSelfFactions = true  -- whether or not the nextbot should be allied with its factions by default
ENT.KnowAlliesPosition = false -- whether or not the nextbot always knows the position of its allies
ENT.Frightening = true -- whether or not NPCs should be scared of the nextbot if it hates them
ENT.EnemyReach = 250 -- at what distance does the nextbot consider it has reached its enemy
ENT.KeepDistance = 125 -- if enemies get closer than this the nextbot will back away
ENT.AvoidRadius = 250 -- minimum distance to keep with entities the nextbot is scared of
ENT.AllyReach = 0 -- at what distance does the nextbot consider it has reached an ally

ENT.SightFOV = 150 -- field of view of the nextbot
ENT.SightRange = 6000 -- from how far can the nextbot see
ENT.EyeBone = "ValveBiped.Bip01_Head1"
ENT.HearingRange = 250 -- from how far can the nextbot hear normal sounds
ENT.HearingRangeBullets = 5000 -- from how far can the nextbot hear gunshots

ENT.PossessionEnabled = true -- whether or not you can possess this nextbot
ENT.Possession = {
  distance = 100,
  offset = Vector(0, 30, 20),
  binds = {
    {
      bind = IN_ATTACK,
      onkeypressed = function(self)
        DrGBase.Utils.Explosion(self:PossessorTrace().HitPos, {
          damage = self:Health(),
          owner = self
        })
      end,
      coroutine = false
    },
    {
      bind = IN_ATTACK2,
      onkeydown = function(self)
        self:Kill(self:GetPossessor())
      end,
      coroutine = false
    },
    {
      bind = IN_JUMP,
      onkeydown = function(self)
        self:QuickJump(100)
      end,
      coroutine = false
    }
  }
}

if SERVER then

  -- Misc --
  function ENT:CustomInitialize()
    self:SetDefaultRelationship(D_HT)
    self:SetPlayersRelationship(D_LI)
  end
  function ENT:CustomThink() end
  function ENT:CustomBehaviour() end
  function ENT:Use(ply)
    if self:IsEnemy(ply) then self:SetEntityRelationship(ply, D_LI)
    else self:SetEntityRelationship(ply, D_HT) end
  end

  -- AI --
  function ENT:OnStateChange(oldstate, newstate) end
  function ENT:OnAvoidEntity() end
  function ENT:OnPursueEnemy(enemy)
    return true
  end
  function ENT:EnemyInRange(enemy) end
  function ENT:FetchDestination()
    return self:RandomPos(1500)
  end
  function ENT:MovingToDestination(pos) end
  function ENT:ReachedDestination(pos)
    self:PlaySequenceAndWait("taunt_dance_base")
  end

  -- Movement --
  function ENT:GroundSpeed(state)
    if state == DRGBASE_STATE_AI_FIGHT or
    state == DRGBASE_STATE_AI_AVOID then return 200
    else return 100 end
  end
  function ENT:FlightSpeed() end

  -- Possession --
  function ENT:OnPossess(ply) end
  function ENT:OnDispossess(ply) end
  function ENT:PossessionGroundSpeed(sprint)
    if sprint then return 200
    else return 100 end
  end
  function ENT:PossessionFlightSpeed(sprint) end

  -- Animations --
  function ENT:SyncAnimation(speed, onground, flying, up, down)
    if not onground then return "jump_knife"
    elseif speed == 0 then return "idle_all_01"
    elseif speed < 120 then return "walk_all"
    else return "run_all_charging" end
  end

  -- Hooks --
  function ENT:OnSpawn()
    self:PlaySequenceAndWait("zombie_slump_rise_01")
  end
  function ENT:OnTakeDamage(dmg, lethal)
    if lethal then return end
    local sounds = {
      "npc/metropolice/pain1.wav",
      "npc/metropolice/pain2.wav",
      "npc/metropolice/pain3.wav",
      "npc/metropolice/pain4.wav"
    }
    self:EmitSound(sounds[math.random(#sounds)])
  end
  function ENT:AfterTakeDamage(dmg, delay)
    if delay > 0.05 then return end
    --self:PlaySequenceAndWait("reload_dual_original")
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
  function ENT:DoOnDeath(dmg, delay)
    local deaths = {
      "death_01", "death_02", "death_03", "death_04"
    }
    self:PlaySequenceAndWait(deaths[math.random(#deaths)])
  end
  --function ENT:OnFallDamage(zvelocity, waterlevel) end

  function ENT:OnPlayerContact(ply) end
  function ENT:OnNPCContact(npc) end
  function ENT:OnNextbotContact(nextbot) end
  function ENT:OnWeaponContact(weapon) end
  function ENT:OnPropContact(prop) end
  function ENT:OnDoorContact(door)
    return "open", 0, 2
  end
  function ENT:OnWeaponContact() end
  function ENT:OnWorldContact(world) end
  function ENT:OnOtherContact(ent) end
  function ENT:OnContactAny(ent) end

  function ENT:OnSpotEntity(ent) end
  function ENT:OnSeeEntity(ent) end
  function ENT:OnHearEntity(ent, sound) end
  function ENT:OnHearGunshot(ent, bullet) end

  function ENT:HandleStuck()
    self:SetPos(self:RandomPos(100))
    self:SetDestination(nil)
    return true
  end

else

  -- Misc --
  function ENT:CustomInitialize() end
  function ENT:CustomThink() end
  function ENT:CustomDraw() end

  -- Possession --
  function ENT:OnPossess(ply) end
  function ENT:OnDispossess(ply) end
  function ENT:PossessionHUD() end
  function ENT:PossessionRender() end

end

-- DO NOT TOUCH --
if SERVER then
  AddCSLuaFile("shared.lua")
end
DrGBase.Nextbot.Load({
  Name = ENT.Name,
  Class = ENT.Class,
  Category = ENT.Category,
  Killicon = ENT.Killicon
})
