# Understanding NextBot Properties

## Overview
DrGBase NextBots are configured through ENT properties set in your entity file. This guide explains the core properties and how to use them effectively.

**Source:** `lua/entities/drgbase_nextbot/shared.lua:1`

## Property Categories

Properties are organized into logical categories:
1. **Basic Info** - Identity and appearance
2. **Stats** - Health and damage
3. **AI** - Behavior and combat
4. **Relationships** - Factions and disposition
5. **Detection** - Vision and hearing
6. **Movement** - Speed and locomotion
7. **Animations** - Visual appearance
8. **Sounds** - Audio feedback
9. **Special Features** - Advanced capabilities

## 1. Basic Information

### Required Properties

```lua
ENT.Base = "drgbase_nextbot"  -- Must be set to use DrGBase
ENT.PrintName = "My NPC"      -- Display name in spawn menu
ENT.Category = "My NPCs"      -- Spawn menu category
```

### Model & Appearance

```lua
-- Single model
ENT.Models = {"models/player/kleiner.mdl"}

-- Multiple models (random selection)
ENT.Models = {
    "models/zombie/classic.mdl",
    "models/zombie/fast.mdl",
    "models/zombie/poison.mdl"
}

-- Model scaling
ENT.ModelScale = 1.0           -- Single scale
ENT.ModelScale = {0.8, 1.2}    -- Random scale between values

-- Skins
ENT.Skins = {0}                -- Single skin
ENT.Skins = {0, 1, 2}          -- Random skin

-- Collision & Blood
ENT.CollisionBounds = Vector(10, 10, 72)  -- Width, width, height
ENT.BloodColor = BLOOD_COLOR_RED          -- Blood type
ENT.RagdollOnDeath = true                 -- Spawn ragdoll on death
```

**Blood Colors:**
- `BLOOD_COLOR_RED` - Humans, rebels
- `BLOOD_COLOR_GREEN` - Zombies, aliens
- `BLOOD_COLOR_YELLOW` - Antlions
- `DONT_BLEED` - Robots, machines

## 2. Stats

```lua
-- Health
ENT.SpawnHealth = 100      -- Starting health
ENT.HealthRegen = 0        -- Health per second regeneration

-- Damage Thresholds
ENT.MinPhysDamage = 10     -- Minimum physics damage to take damage
ENT.MinFallDamage = 10     -- Minimum fall damage to take damage
```

**Examples:**
```lua
-- Tank NPC
ENT.SpawnHealth = 500
ENT.MinPhysDamage = 50
ENT.MinFallDamage = 100

-- Fragile NPC
ENT.SpawnHealth = 25
ENT.MinPhysDamage = 5
ENT.MinFallDamage = 5

-- Regenerating NPC
ENT.SpawnHealth = 100
ENT.HealthRegen = 2  -- Regains 2 HP per second
```

## 3. AI Configuration

### Behavior Type

```lua
ENT.BehaviourType = AI_BEHAV_BASE  -- Default AI
```

**Behavior Types:**
- `AI_BEHAV_BASE` - Standard NextBot AI (default)
- `AI_BEHAV_HUMAN` - Human-like AI with weapon support
- `AI_BEHAV_CUSTOM` - Custom AI (override `AIBehaviour()`)

### Combat Ranges

```lua
-- Attack Ranges
ENT.MeleeAttackRange = 50       -- Melee attack distance
ENT.RangeAttackRange = 0        -- Ranged attack distance (0 = disabled)
ENT.ReachEnemyRange = 50        -- How close to chase enemy

-- Defensive Ranges
ENT.AvoidEnemyRange = 0         -- Distance to keep from hated enemies (0 = disabled)
ENT.AvoidAfraidOfRange = 500    -- Distance to flee from feared enemies
ENT.WatchAfraidOfRange = 750    -- Distance to watch feared enemies from
```

**Example Configurations:**

```lua
-- Melee NPC (Zombie)
ENT.MeleeAttackRange = 30
ENT.RangeAttackRange = 0
ENT.ReachEnemyRange = 30
ENT.AvoidEnemyRange = 0

-- Ranged NPC (Soldier)
ENT.MeleeAttackRange = 0
ENT.RangeAttackRange = 1000
ENT.ReachEnemyRange = 500
ENT.AvoidEnemyRange = 100

-- Leaping NPC (Headcrab)
ENT.MeleeAttackRange = 0
ENT.RangeAttackRange = 150
ENT.ReachEnemyRange = 125
ENT.AvoidEnemyRange = 100

-- Cowardly NPC
ENT.MeleeAttackRange = 50
ENT.RangeAttackRange = 0
ENT.ReachEnemyRange = 50
ENT.AvoidEnemyRange = 0
ENT.AvoidAfraidOfRange = 1000  -- Flee from feared enemies
```

### AI Behavior

```lua
ENT.Omniscient = false      -- Can see through walls
ENT.SpotDuration = 30       -- Seconds to remember enemy location
```

## 4. Relationships

```lua
-- Default relationship with all entities
ENT.DefaultRelationship = D_NU  -- Neutral

-- Factions (optional)
ENT.Factions = {FACTION_COMBINE}

-- Frightening to others
ENT.Frightening = false

-- Damage tolerance before relationship changes
ENT.AllyDamageTolerance = 0.33      -- 33% health
ENT.AfraidDamageTolerance = 0.33
ENT.NeutralDamageTolerance = 0.33
```

**Relationship Types:**
- `D_HT` - Hate (attack on sight)
- `D_FR` - Fear (flee from)
- `D_LI` - Like (ally)
- `D_NU` - Neutral (ignore)
- `D_ER` - Error (unused)

**Factions:**
```lua
FACTION_REBELS      -- Resistance
FACTION_COMBINE     -- Combine soldiers
FACTION_ZOMBIES     -- Zombies & headcrabs
FACTION_ANTLIONS    -- Antlions
FACTION_ANIMALS     -- Wildlife
-- See lua/drgbase/enumerations.lua:6 for full list
```

**Example:**
```lua
-- Hostile zombie
ENT.DefaultRelationship = D_HT
ENT.Factions = {FACTION_ZOMBIES}

-- Friendly NPC
ENT.DefaultRelationship = D_LI
ENT.Factions = {FACTION_REBELS}

-- Frightening boss
ENT.Frightening = true  -- Others fear this NPC
```

## 5. Detection

### Vision

```lua
-- Eye Position
ENT.EyeBone = "ValveBiped.Bip01_Head1"  -- Bone name
ENT.EyeOffset = Vector(0, 0, 0)         -- Offset from bone
ENT.EyeAngle = Angle(0, 0, 0)           -- Eye angle offset

-- Sight Properties
ENT.SightFOV = 150          -- Field of view (degrees, -1 to 1 cos)
ENT.SightRange = 15000      -- Maximum sight distance

-- Light Sensitivity
ENT.MinLuminosity = 0       -- Minimum light to see (0-1)
ENT.MaxLuminosity = 1       -- Maximum light to see (0-1)
```

**FOV Examples:**
```lua
ENT.SightFOV = 180   -- Wide vision (most NPCs)
ENT.SightFOV = 150   -- Normal vision
ENT.SightFOV = 90    -- Narrow vision (focused)
ENT.SightFOV = 360   -- Can see behind (360 degrees)
```

**Light Sensitivity:**
```lua
-- Can only see in darkness
ENT.MinLuminosity = 0
ENT.MaxLuminosity = 0.3

-- Can only see in light
ENT.MinLuminosity = 0.7
ENT.MaxLuminosity = 1

-- Can see in any light
ENT.MinLuminosity = 0
ENT.MaxLuminosity = 1
```

### Hearing

```lua
ENT.HearingCoefficient = 1  -- Hearing sensitivity (0-1, higher = better)
```

## 6. Movement

### Speed

```lua
ENT.WalkSpeed = 100   -- Walking speed (default locomotion)
ENT.RunSpeed = 200    -- Running speed (when chasing enemy)

-- Animation-based speed
ENT.UseWalkframes = false  -- Use animation speed instead
```

**When to use `UseWalkframes`:**
- `false` - Speed defined by `WalkSpeed`/`RunSpeed` (most NPCs)
- `true` - Speed defined by animation (for animated models)

### Locomotion

```lua
ENT.Acceleration = 1000    -- Speed up rate
ENT.Deceleration = 1000    -- Slow down rate
ENT.JumpHeight = 50        -- Jump ability
ENT.StepHeight = 20        -- Maximum step height
ENT.MaxYawRate = 250       -- Turn speed (degrees/second)
ENT.DeathDropHeight = 200  -- Fall height for instant death
```

### Climbing

```lua
-- Ledges
ENT.ClimbLedges = false              -- Can climb ledges
ENT.ClimbLedgesMaxHeight = math.huge -- Maximum ledge height
ENT.ClimbLedgesMinHeight = 0         -- Minimum ledge height
ENT.LedgeDetectionDistance = 20      -- Ledge detection range

-- Props
ENT.ClimbProps = false               -- Can climb on props

-- Ladders
ENT.ClimbLadders = false             -- Can use ladders
ENT.ClimbLaddersUp = true            -- Can climb up
ENT.ClimbLaddersDown = false         -- Can climb down
ENT.LaddersUpDistance = 20           -- Ladder detection range
ENT.ClimbLaddersUpMaxHeight = math.huge
ENT.ClimbLaddersUpMinHeight = 0

-- Climb Settings
ENT.ClimbSpeed = 60                       -- Climbing speed
ENT.ClimbUpAnimation = ACT_CLIMB_UP       -- Climb animation
ENT.ClimbDownAnimation = ACT_CLIMB_DOWN
ENT.ClimbAnimRate = 1
ENT.ClimbOffset = Vector(0, 0, 0)
```

## 7. Animations

```lua
-- Movement Animations
ENT.WalkAnimation = ACT_WALK
ENT.WalkAnimRate = 1
ENT.RunAnimation = ACT_RUN
ENT.RunAnimRate = 1
ENT.IdleAnimation = ACT_IDLE
ENT.IdleAnimRate = 1
ENT.JumpAnimation = ACT_JUMP
ENT.JumpAnimRate = 1
```

**Common Activities:**
- `ACT_IDLE` - Standing still
- `ACT_WALK` - Walking
- `ACT_RUN` - Running
- `ACT_JUMP` - Jumping
- `ACT_MELEE_ATTACK1` - Melee attack
- `ACT_RANGE_ATTACK1` - Ranged attack
- See GMod wiki for full list

## 8. Sounds

```lua
-- Sound Tables (random selection)
ENT.OnSpawnSounds = {}           -- Play on spawn
ENT.OnIdleSounds = {}            -- Play periodically
ENT.OnDamageSounds = {}          -- Play when damaged
ENT.OnDeathSounds = {}           -- Play on death
ENT.OnDownedSounds = {}          -- Play when downed
ENT.Footsteps = {}               -- Custom footstep sounds

-- Sound Settings
ENT.IdleSoundDelay = 2           -- Seconds between idle sounds
ENT.DamageSoundDelay = 0.25      -- Seconds between damage sounds
ENT.ClientIdleSounds = false     -- Play idle sounds on client
```

**Example:**
```lua
ENT.OnSpawnSounds = {"npc/zombie/zombie_voice_idle1.wav"}
ENT.OnIdleSounds = {
    "npc/zombie/zombie_voice_idle1.wav",
    "npc/zombie/zombie_voice_idle2.wav",
    "npc/zombie/zombie_voice_idle3.wav"
}
ENT.OnDamageSounds = {"npc/zombie/zombie_pain1.wav", "npc/zombie/zombie_pain2.wav"}
ENT.OnDeathSounds = {"npc/zombie/zombie_die1.wav", "npc/zombie/zombie_die2.wav"}
```

## 9. Special Features

### Weapons

```lua
ENT.UseWeapons = false           -- Can use weapons
ENT.Weapons = {}                 -- Weapon list
ENT.DropWeaponOnDeath = false    -- Drop weapon on death
ENT.AcceptPlayerWeapons = true   -- Can pick up player weapons
```

**Example:**
```lua
ENT.UseWeapons = true
ENT.Weapons = {"weapon_smg1", "weapon_ar2"}
ENT.DropWeaponOnDeath = true
```

### Possession

```lua
ENT.PossessionEnabled = false        -- Players can possess
ENT.PossessionPrompt = true          -- Show possession prompt
ENT.PossessionCrosshair = false      -- Show crosshair
ENT.PossessionMovement = POSSESSION_MOVE_1DIR
ENT.PossessionViews = {}             -- Camera views
ENT.PossessionBinds = {}             -- Key bindings
```

## Property Precedence

Properties are applied in this order:
1. **Base class** (`drgbase_nextbot`)
2. **Your ENT properties** (override base)
3. **Runtime changes** (in hooks like `CustomInitialize()`)

## Best Practices

### Organization

```lua
-- Group related properties together
-- Add comments for clarity

-- === Basic Info ===
ENT.PrintName = "My NPC"
ENT.Category = "My NPCs"

-- === Stats ===
ENT.SpawnHealth = 100

-- === AI ===
ENT.MeleeAttackRange = 50
```

### Common Patterns

```lua
-- Melee NPC
ENT.MeleeAttackRange = 50
ENT.RangeAttackRange = 0

-- Ranged NPC
ENT.MeleeAttackRange = 0
ENT.RangeAttackRange = 1000

-- Mixed NPC
ENT.MeleeAttackRange = 50
ENT.RangeAttackRange = 500
```

### Testing Properties

```lua
-- Print property in console
function ENT:CustomInitialize()
    print("Spawn Health:", self.SpawnHealth)
    print("Melee Range:", self.MeleeAttackRange)
end
```

## Next Steps

- **[Relationships & Factions](04-relationships-factions.md)** - Set up NPC relationships
- **[Advanced Features](05-advanced-features.md)** - Weapons, possession, custom AI
- **[API Reference](../api/)** - Full property documentation

---

**Previous:** [Creating Your First NextBot](02-first-nextbot.md) | **Next:** [Relationships & Factions](04-relationships-factions.md)
