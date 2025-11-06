# Base Configuration

## Overview
This document provides a complete reference of all ENT properties available for DrGBase NextBots. These properties are configured in your entity file to customize NPC behavior, appearance, and capabilities.

**Source:** `lua/entities/drgbase_nextbot/shared.lua:1`

## Required Properties

These properties **must** be set for every NextBot:

```lua
ENT.Base = "drgbase_nextbot"  -- Use DrGBase as base class
ENT.PrintName = "NPC Name"     -- Display name in spawn menu
ENT.Category = "Category Name" -- Spawn menu category
```

---

## Basic Information

### ENT.PrintName

**Type:** string
**Default:** `"Template"`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:7`

Display name shown in spawn menu and game.

**Example:**
```lua
ENT.PrintName = "Zombie"
ENT.PrintName = "Rebel Soldier"
```

---

### ENT.Category

**Type:** string
**Default:** `"Other"`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:8`

Spawn menu category for organization.

**Example:**
```lua
ENT.Category = "DrGBase"
ENT.Category = "My NPCs"
ENT.Category = "Half-Life 2"
```

---

### ENT.Models

**Type:** table (array of strings)
**Default:** `{"models/player/kleiner.mdl"}`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:9`

Model(s) to use. If multiple models provided, one is randomly selected on spawn.

**Example:**
```lua
-- Single model
ENT.Models = {"models/player/kleiner.mdl"}

-- Multiple models (random selection)
ENT.Models = {
    "models/zombie/classic.mdl",
    "models/zombie/fast.mdl",
    "models/zombie/poison.mdl"
}
```

---

### ENT.Skins

**Type:** table (array of numbers) or number
**Default:** `{0}`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:10`

Model skin(s) to use. If multiple provided, one is randomly selected.

**Example:**
```lua
ENT.Skins = {0}        -- Always use skin 0
ENT.Skins = {0, 1, 2}  -- Random skin
ENT.Skins = 1          -- Always use skin 1
```

---

### ENT.ModelScale

**Type:** number or table
**Default:** `1`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:11`

Model scale multiplier.

**Example:**
```lua
ENT.ModelScale = 1.0     -- Normal size
ENT.ModelScale = 0.5     -- Half size
ENT.ModelScale = 2.0     -- Double size
ENT.ModelScale = {0.8, 1.2}  -- Random scale between values
```

---

### ENT.CollisionBounds

**Type:** Vector
**Default:** `Vector(10, 10, 72)`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:12`

Collision box dimensions (width X, width Y, height Z).

**Example:**
```lua
ENT.CollisionBounds = Vector(10, 10, 72)  -- Human-sized
ENT.CollisionBounds = Vector(12, 12, 24)  -- Headcrab-sized
ENT.CollisionBounds = Vector(20, 20, 100) -- Large NPC
```

**Note:** Set to `nil` or `false` to use model bounds automatically.

---

### ENT.BloodColor

**Type:** number (enum)
**Default:** `BLOOD_COLOR_RED`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:13`

Blood particle color when damaged.

**Values:**
- `BLOOD_COLOR_RED` - Red blood (humans)
- `BLOOD_COLOR_GREEN` - Green blood (zombies, aliens)
- `BLOOD_COLOR_YELLOW` - Yellow blood (antlions)
- `BLOOD_COLOR_MECH` - Sparks (robots)
- `DONT_BLEED` - No blood

**Example:**
```lua
ENT.BloodColor = BLOOD_COLOR_RED    -- Human
ENT.BloodColor = BLOOD_COLOR_GREEN  -- Zombie
ENT.BloodColor = DONT_BLEED         -- Robot
```

---

### ENT.RagdollOnDeath

**Type:** boolean
**Default:** `true`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:14`

Spawn ragdoll corpse when killed.

**Example:**
```lua
ENT.RagdollOnDeath = true   -- Spawn ragdoll
ENT.RagdollOnDeath = false  -- No ragdoll (disappear)
```

---

## Stats

### ENT.SpawnHealth

**Type:** number
**Default:** `100`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:18`

Starting health points.

**Example:**
```lua
ENT.SpawnHealth = 50   -- Weak NPC
ENT.SpawnHealth = 100  -- Standard
ENT.SpawnHealth = 500  -- Boss/Tank
```

**Note:** Multiplied by `drgbase_multiplier_health` ConVar.

---

### ENT.HealthRegen

**Type:** number
**Default:** `0`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:19`

Health regeneration per second.

**Example:**
```lua
ENT.HealthRegen = 0    -- No regeneration
ENT.HealthRegen = 1    -- 1 HP/second
ENT.HealthRegen = 5    -- 5 HP/second
```

---

### ENT.MinPhysDamage

**Type:** number
**Default:** `10`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:20`

Minimum physics damage threshold to take damage.

**Example:**
```lua
ENT.MinPhysDamage = 5   -- Takes damage from light impacts
ENT.MinPhysDamage = 10  -- Standard
ENT.MinPhysDamage = 50  -- Ignores most physics damage
```

---

### ENT.MinFallDamage

**Type:** number
**Default:** `10`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:21`

Minimum fall damage threshold to take damage.

**Example:**
```lua
ENT.MinFallDamage = 10   -- Standard
ENT.MinFallDamage = 100  -- Can fall from great heights
ENT.MinFallDamage = 0    -- Takes damage from any fall
```

---

## AI Configuration

### ENT.BehaviourType

**Type:** number (enum)
**Default:** `AI_BEHAV_BASE`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:26`

AI behavior mode.

**Values:**
- `AI_BEHAV_BASE` (1) - Standard NextBot AI
- `AI_BEHAV_HUMAN` (2) - Human AI with weapons
- `AI_BEHAV_CUSTOM` (0) - Custom AI (override `AIBehaviour()`)

**Example:**
```lua
ENT.BehaviourType = AI_BEHAV_BASE   -- Standard
ENT.BehaviourType = AI_BEHAV_HUMAN  -- Weapon support
ENT.BehaviourType = AI_BEHAV_CUSTOM -- Custom logic
```

---

### ENT.Omniscient

**Type:** boolean
**Default:** `false`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:27`

Can see through walls (ignores line-of-sight checks).

**Example:**
```lua
ENT.Omniscient = false  -- Normal vision
ENT.Omniscient = true   -- X-ray vision
```

---

### ENT.SpotDuration

**Type:** number
**Default:** `30`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:28`

Seconds to remember enemy position after losing sight.

**Example:**
```lua
ENT.SpotDuration = 10   -- Forgets quickly
ENT.SpotDuration = 30   -- Standard
ENT.SpotDuration = 60   -- Long memory
```

---

### ENT.MeleeAttackRange

**Type:** number
**Default:** `50`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:30`

Distance at which melee attacks trigger.

**Example:**
```lua
ENT.MeleeAttackRange = 30   -- Short reach (headcrab)
ENT.MeleeAttackRange = 50   -- Standard (zombie)
ENT.MeleeAttackRange = 100  -- Long reach (monster)
ENT.MeleeAttackRange = 0    -- Disable melee
```

---

### ENT.RangeAttackRange

**Type:** number
**Default:** `0`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:29`

Distance at which ranged attacks trigger. Set to 0 to disable.

**Example:**
```lua
ENT.RangeAttackRange = 0     -- No ranged attack
ENT.RangeAttackRange = 150   -- Short range (headcrab leap)
ENT.RangeAttackRange = 500   -- Medium range
ENT.RangeAttackRange = 1000  -- Long range (soldier)
```

---

### ENT.ReachEnemyRange

**Type:** number
**Default:** `50`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:31`

How close NPC tries to get to enemy before stopping chase.

**Example:**
```lua
ENT.ReachEnemyRange = 30   -- Get very close
ENT.ReachEnemyRange = 50   -- Standard
ENT.ReachEnemyRange = 200  -- Keep distance
```

**Note:** Should typically match attack ranges.

---

### ENT.AvoidEnemyRange

**Type:** number
**Default:** `0`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:32`

Distance to keep from hated enemies (for ranged combat). Set to 0 to disable.

**Example:**
```lua
ENT.AvoidEnemyRange = 0    -- Don't avoid
ENT.AvoidEnemyRange = 100  -- Keep 100 units away
ENT.AvoidEnemyRange = 200  -- Stay far back
```

---

### ENT.AvoidAfraidOfRange

**Type:** number
**Default:** `500`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:33`

Distance to flee from feared enemies.

**Example:**
```lua
ENT.AvoidAfraidOfRange = 300   -- Flee if within 300 units
ENT.AvoidAfraidOfRange = 500   -- Standard
ENT.AvoidAfraidOfRange = 1000  -- Very cowardly
```

---

### ENT.WatchAfraidOfRange

**Type:** number
**Default:** `750`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:34`

Distance to watch feared enemies from (after fleeing).

**Example:**
```lua
ENT.WatchAfraidOfRange = 750   -- Standard
ENT.WatchAfraidOfRange = 1000  -- Watch from afar
```

---

## Relationships

### ENT.DefaultRelationship

**Type:** number (enum)
**Default:** `D_NU` (Neutral)
**Source:** `lua/entities/drgbase_nextbot/shared.lua:38`

Default relationship with all entities.

**Values:**
- `D_HT` (1) - Hate (attack)
- `D_FR` (2) - Fear (flee)
- `D_LI` (3) - Like (ally)
- `D_NU` (4) - Neutral (ignore)

**Example:**
```lua
ENT.DefaultRelationship = D_HT  -- Hostile to everyone
ENT.DefaultRelationship = D_NU  -- Neutral to everyone
ENT.DefaultRelationship = D_LI  -- Friendly to everyone
```

---

### ENT.Factions

**Type:** table (array of strings)
**Default:** `{}`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:39`

Factions this NPC belongs to. NPCs in same faction are allies.

**Example:**
```lua
ENT.Factions = {}  -- No faction
ENT.Factions = {FACTION_ZOMBIES}  -- Zombie faction
ENT.Factions = {FACTION_COMBINE, FACTION_HECU}  -- Multiple factions
```

**Available Factions:**
- `FACTION_REBELS`, `FACTION_COMBINE`, `FACTION_ZOMBIES`
- `FACTION_ANTLIONS`, `FACTION_ANIMALS`
- `FACTION_XEN_ARMY`, `FACTION_XEN_WILDLIFE`, `FACTION_HECU`
- See `enumerations.lua:6` for full list

---

### ENT.Frightening

**Type:** boolean
**Default:** `false`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:40`

Whether this NPC frightens neutral/friendly NPCs.

**Example:**
```lua
ENT.Frightening = false  -- Normal NPC
ENT.Frightening = true   -- Scary boss/monster
```

---

### ENT.AllyDamageTolerance

**Type:** number (0-1)
**Default:** `0.33`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:41`

Percentage of health damage from ally before becoming hostile.

**Example:**
```lua
ENT.AllyDamageTolerance = 0.1   -- Quick to anger (10%)
ENT.AllyDamageTolerance = 0.33  -- Standard (33%)
ENT.AllyDamageTolerance = 0.9   -- Very forgiving (90%)
```

---

### ENT.AfraidDamageTolerance

**Type:** number (0-1)
**Default:** `0.33`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:42`

Percentage of health damage from feared entity before fighting back.

---

### ENT.NeutralDamageTolerance

**Type:** number (0-1)
**Default:** `0.33`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:43`

Percentage of health damage from neutral entity before becoming hostile.

**Example:**
```lua
ENT.NeutralDamageTolerance = 0.01  -- Any damage provokes
ENT.NeutralDamageTolerance = 0.5   -- Tolerant
```

---

## Detection & Senses

### ENT.EyeBone

**Type:** string
**Default:** `""`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:48`

Bone name for eye position. Empty string uses model origin.

**Example:**
```lua
ENT.EyeBone = ""  -- Use model origin
ENT.EyeBone = "ValveBiped.Bip01_Head1"  -- Human head
ENT.EyeBone = "ValveBiped.Bip01_Spine4"  -- Zombie chest
```

**Tip:** Use `ENT:PrintBones()` to see available bones.

---

### ENT.EyeOffset

**Type:** Vector
**Default:** `Vector(0, 0, 0)`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:49`

Offset from eye bone position.

**Example:**
```lua
ENT.EyeOffset = Vector(0, 0, 0)     -- No offset
ENT.EyeOffset = Vector(7.5, 0, 5)   -- Forward and up
ENT.EyeOffset = Vector(0, 0, 64)    -- High offset
```

---

### ENT.EyeAngle

**Type:** Angle
**Default:** `Angle(0, 0, 0)`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:50`

Eye angle offset for vision direction.

**Example:**
```lua
ENT.EyeAngle = Angle(0, 0, 0)      -- Forward
ENT.EyeAngle = Angle(10, 0, 0)     -- Slightly down
ENT.EyeAngle = Angle(-10, 0, 0)    -- Slightly up
```

---

### ENT.SightFOV

**Type:** number
**Default:** `150`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:51`

Field of view (degrees). Actually stored as cosine internally.

**Example:**
```lua
ENT.SightFOV = 90    -- Narrow (focused)
ENT.SightFOV = 150   -- Standard
ENT.SightFOV = 180   -- Wide
ENT.SightFOV = 360   -- Can see behind
```

---

### ENT.SightRange

**Type:** number
**Default:** `15000`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:52`

Maximum sight distance in units.

**Example:**
```lua
ENT.SightRange = 1000   -- Nearsighted
ENT.SightRange = 5000   -- Standard
ENT.SightRange = 15000  -- Far sight
```

---

### ENT.MinLuminosity

**Type:** number (0-1)
**Default:** `0`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:53`

Minimum light level to see (0 = darkness, 1 = bright).

**Example:**
```lua
-- Can only see in darkness
ENT.MinLuminosity = 0
ENT.MaxLuminosity = 0.3

-- Can only see in light
ENT.MinLuminosity = 0.7
ENT.MaxLuminosity = 1
```

---

### ENT.MaxLuminosity

**Type:** number (0-1)
**Default:** `1`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:54`

Maximum light level to see.

---

### ENT.HearingCoefficient

**Type:** number
**Default:** `1`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:55`

Hearing sensitivity (0-1, higher = better hearing).

**Example:**
```lua
ENT.HearingCoefficient = 0    -- Deaf
ENT.HearingCoefficient = 0.5  -- Poor hearing
ENT.HearingCoefficient = 1    -- Normal
ENT.HearingCoefficient = 2    -- Enhanced hearing
```

---

## Locomotion

### ENT.Acceleration

**Type:** number
**Default:** `1000`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:60`

Speed up rate (units/second²).

---

### ENT.Deceleration

**Type:** number
**Default:** `1000`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:61`

Slow down rate (units/second²).

---

### ENT.JumpHeight

**Type:** number
**Default:** `50`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:62`

Maximum jump height in units.

**Example:**
```lua
ENT.JumpHeight = 0     -- Cannot jump
ENT.JumpHeight = 50    -- Standard jump
ENT.JumpHeight = 100   -- High jump
```

---

### ENT.StepHeight

**Type:** number
**Default:** `20`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:63`

Maximum step-up height.

---

### ENT.MaxYawRate

**Type:** number
**Default:** `250`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:64`

Turn speed in degrees per second.

**Example:**
```lua
ENT.MaxYawRate = 100   -- Slow turning
ENT.MaxYawRate = 250   -- Standard
ENT.MaxYawRate = 500   -- Fast turning
```

---

### ENT.DeathDropHeight

**Type:** number
**Default:** `200`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:65`

Fall height that causes instant death.

---

## Movement & Speed

### ENT.UseWalkframes

**Type:** boolean
**Default:** `false`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:69`

Use animation speed instead of WalkSpeed/RunSpeed.

**Example:**
```lua
ENT.UseWalkframes = false  -- Use WalkSpeed/RunSpeed
ENT.UseWalkframes = true   -- Use animation speed
```

---

### ENT.WalkSpeed

**Type:** number
**Default:** `100`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:70`

Walking speed in units/second.

---

### ENT.RunSpeed

**Type:** number
**Default:** `200`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:71`

Running speed (when chasing enemy) in units/second.

---

## Climbing

All climbing properties default to disabled. Enable by setting the main property to `true`.

### ENT.ClimbLedges

**Type:** boolean
**Default:** `false`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:74`

Can climb up ledges.

---

### ENT.ClimbLedgesMaxHeight

**Type:** number
**Default:** `math.huge`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:75`

Maximum ledge height to climb.

---

### ENT.ClimbLedgesMinHeight

**Type:** number
**Default:** `0`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:76`

Minimum ledge height to climb.

---

### ENT.LedgeDetectionDistance

**Type:** number
**Default:** `20`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:77`

Distance to detect ledges ahead.

---

### ENT.ClimbProps

**Type:** boolean
**Default:** `false`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:78`

Can climb on props.

---

### ENT.ClimbLadders

**Type:** boolean
**Default:** `false`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:79`

Can use ladders (master enable).

---

### ENT.ClimbLaddersUp

**Type:** boolean
**Default:** `true`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:80`

Can climb ladders upward.

---

### ENT.LaddersUpDistance

**Type:** number
**Default:** `20`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:81`

Distance to detect ladders.

---

### ENT.ClimbLaddersUpMaxHeight / MinHeight

**Type:** number
**Default:** `math.huge` / `0`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:82-83`

Height range for ladder climbing.

---

### ENT.ClimbLaddersDown

**Type:** boolean
**Default:** `false`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:84`

Can climb ladders downward.

---

### ENT.LaddersDownDistance

**Type:** number
**Default:** `20`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:85`

Distance to detect downward ladders.

---

### ENT.ClimbSpeed

**Type:** number
**Default:** `60`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:88`

Climbing speed.

---

### ENT.ClimbUpAnimation / ClimbDownAnimation

**Type:** number (ACT enum)
**Default:** `ACT_CLIMB_UP` / `ACT_CLIMB_DOWN`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:89-90`

Climbing animations.

---

### ENT.ClimbAnimRate

**Type:** number
**Default:** `1`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:91`

Climb animation playback speed.

---

### ENT.ClimbOffset

**Type:** Vector
**Default:** `Vector(0, 0, 0)`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:92`

Position offset while climbing.

---

## Animations

### ENT.WalkAnimation

**Type:** number (ACT enum)
**Default:** `ACT_WALK`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:96`

Walking animation.

---

### ENT.WalkAnimRate

**Type:** number
**Default:** `1`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:97`

Walk animation playback speed.

---

### ENT.RunAnimation

**Type:** number (ACT enum)
**Default:** `ACT_RUN`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:98`

Running animation.

---

### ENT.RunAnimRate

**Type:** number
**Default:** `1`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:99`

Run animation playback speed.

---

### ENT.IdleAnimation

**Type:** number (ACT enum)
**Default:** `ACT_IDLE`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:100`

Idle/standing animation.

---

### ENT.IdleAnimRate

**Type:** number
**Default:** `1`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:101`

Idle animation playback speed.

---

### ENT.JumpAnimation

**Type:** number (ACT enum)
**Default:** `ACT_JUMP`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:102`

Jump animation.

---

### ENT.JumpAnimRate

**Type:** number
**Default:** `1`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:103`

Jump animation playback speed.

---

## Sounds

### ENT.OnSpawnSounds

**Type:** table (array of strings)
**Default:** `{}`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:106`

Sounds played when NPC spawns. One randomly selected.

**Example:**
```lua
ENT.OnSpawnSounds = {"npc/zombie/zombie_voice_idle1.wav"}
```

---

### ENT.OnIdleSounds

**Type:** table (array of strings)
**Default:** `{}`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:107`

Sounds played periodically when idle.

---

### ENT.IdleSoundDelay

**Type:** number
**Default:** `2`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:108`

Seconds between idle sounds.

---

### ENT.ClientIdleSounds

**Type:** boolean
**Default:** `false`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:109`

Play idle sounds on client instead of server.

---

### ENT.OnDamageSounds

**Type:** table (array of strings)
**Default:** `{}`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:110`

Sounds played when damaged.

---

### ENT.DamageSoundDelay

**Type:** number
**Default:** `0.25`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:111`

Minimum seconds between damage sounds.

---

### ENT.OnDeathSounds

**Type:** table (array of strings)
**Default:** `{}`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:112`

Sounds played on death.

---

### ENT.OnDownedSounds

**Type:** table (array of strings)
**Default:** `{}`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:113`

Sounds played when downed (if downed system used).

---

### ENT.Footsteps

**Type:** table
**Default:** `{}`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:114`

Custom footstep sounds per material type.

**Example:**
```lua
ENT.Footsteps = {
    [MAT_CONCRETE] = {"player/footsteps/concrete1.wav"},
    [MAT_METAL] = {"player/footsteps/metal1.wav"}
}
```

---

## Weapons

### ENT.UseWeapons

**Type:** boolean
**Default:** `false`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:118`

Enable weapon system.

**Requires:** `BehaviourType = AI_BEHAV_HUMAN`

---

### ENT.Weapons

**Type:** table (array of strings)
**Default:** `{}`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:119`

Weapon classes to randomly equip on spawn.

**Example:**
```lua
ENT.Weapons = {"weapon_smg1", "weapon_ar2", "weapon_shotgun"}
```

---

### ENT.DropWeaponOnDeath

**Type:** boolean
**Default:** `false`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:120`

Drop weapon when killed.

---

### ENT.AcceptPlayerWeapons

**Type:** boolean
**Default:** `true`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:121`

Can pick up player-dropped weapons.

---

## Possession

### ENT.PossessionEnabled

**Type:** boolean
**Default:** `false`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:125`

Players can possess this NPC.

---

### ENT.PossessionPrompt

**Type:** boolean
**Default:** `true`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:126`

Show possession prompt when looking at NPC.

---

### ENT.PossessionCrosshair

**Type:** boolean
**Default:** `false`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:127`

Show crosshair when possessed.

---

### ENT.PossessionMovement

**Type:** number (enum)
**Default:** `POSSESSION_MOVE_1DIR`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:128`

Movement control mode.

**Values:**
- `POSSESSION_MOVE_8DIR` - 8-directional
- `POSSESSION_MOVE_1DIR` - Forward only
- `POSSESSION_MOVE_4DIR` - 4-direction relative to camera
- `POSSESSION_MOVE_CUSTOM` - Custom

---

### ENT.PossessionViews

**Type:** table
**Default:** `{}`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:129`

Camera views array.

**Example:**
```lua
ENT.PossessionViews = {
    {
        offset = Vector(0, 30, 20),
        distance = 100
    },
    {
        offset = Vector(0, 0, 0),
        distance = 0,
        eyepos = true
    }
}
```

---

### ENT.PossessionBinds

**Type:** table
**Default:** `{}`
**Source:** `lua/entities/drgbase_nextbot/shared.lua:130`

Key bindings for possessed actions.

**Example:**
```lua
ENT.PossessionBinds = {
    [IN_ATTACK] = {{
        coroutine = true,
        onkeydown = function(self)
            self:Attack({damage = 10})
        end
    }}
}
```

---

## See Also

- **[Entity Functions](entity-functions.md)** - Methods for runtime control
- **[Getting Started](../getting-started/03-understanding-properties.md)** - Property usage guide
- **[Examples](../examples/)** - Real-world configurations
