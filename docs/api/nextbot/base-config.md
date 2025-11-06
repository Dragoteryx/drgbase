# Nextbot Base Configuration

All configurable properties for `drgbase_nextbot`.

**File:** `lua/entities/drgbase_nextbot/shared.lua` (621 lines)

## Basic Properties

### ENT.Base
```lua
ENT.Base = "drgbase_nextbot"
```
**Type:** string
**Description:** Base class to inherit from
**Options:** `"drgbase_nextbot"`, `"drgbase_nextbot_human"`, `"drgbase_nextbot_sprite"`

### ENT.PrintName
```lua
ENT.PrintName = "My NPC"
```
**Type:** string
**Description:** Display name in spawn menu

### ENT.Category
```lua
ENT.Category = "My NPCs"
```
**Type:** string
**Description:** Spawn menu category

### ENT.Spawnable
```lua
ENT.Spawnable = true
```
**Type:** boolean
**Description:** Can be spawned from menu

### ENT.AdminOnly
```lua
ENT.AdminOnly = false
```
**Type:** boolean
**Description:** Admin-only spawn

---

## Model & Appearance

### ENT.Models
```lua
ENT.Models = {"models/player.mdl"}
```
**Type:** table (array of strings)
**Description:** List of models (random selection on spawn)

### ENT.ModelScale
```lua
ENT.ModelScale = 1.0
```
**Type:** number
**Description:** Model scale multiplier

### ENT.CollisionBounds
```lua
ENT.CollisionBounds = Vector(20, 20, 72)
```
**Type:** Vector
**Description:** Collision box size (half-extents)

### ENT.BloodColor
```lua
ENT.BloodColor = BLOOD_COLOR_RED
```
**Type:** number
**Description:** Blood particle color

---

## Health & Status

### ENT.SpawnHealth
```lua
ENT.SpawnHealth = 100
```
**Type:** number
**Description:** Starting health

### ENT.HealthRegen
```lua
ENT.HealthRegen = 0
```
**Type:** number
**Description:** Health regenerated per tick

### ENT.MinPhysDamage
```lua
ENT.MinPhysDamage = 10
```
**Type:** number
**Description:** Minimum physics damage to register

### ENT.MinFallDamage
```lua
ENT.MinFallDamage = 10
```
**Type:** number
**Description:** Minimum fall damage to register

### ENT.RagdollOnDeath
```lua
ENT.RagdollOnDeath = true
```
**Type:** boolean
**Description:** Create ragdoll corpse on death

---

## Movement & Locomotion

<!-- TODO: Document all movement properties from movements.lua and locomotion.lua -->

### ENT.MoveSpeed
```lua
ENT.MoveSpeed = 250
```
**Type:** number
**Description:** Walking speed (units/second)

### ENT.RunSpeed
```lua
ENT.RunSpeed = 400
```
**Type:** number
**Description:** Running speed (units/second)

### ENT.MoveAcceleration
```lua
ENT.MoveAcceleration = 400
```
**Type:** number
**Description:** Acceleration rate

### ENT.MoveDeceleration
```lua
ENT.MoveDeceleration = 400
```
**Type:** number
**Description:** Deceleration rate

### ENT.JumpHeight
```lua
ENT.JumpHeight = 64
```
**Type:** number
**Description:** Jump height (units)

### ENT.StepHeight
```lua
ENT.StepHeight = 24
```
**Type:** number
**Description:** Maximum step height

### ENT.CanClimbLedges
```lua
ENT.CanClimbLedges = true
```
**Type:** boolean
**Description:** Can climb ledges

### ENT.CanClimbLadders
```lua
ENT.CanClimbLadders = true
```
**Type:** boolean
**Description:** Can climb ladders

---

## AI & Detection

<!-- TODO: Document all AI properties from ai.lua, detection.lua, awareness.lua -->

### ENT.VisionRange
```lua
ENT.VisionRange = 4000
```
**Type:** number
**Description:** Maximum vision distance (units)

### ENT.VisionFOV
```lua
ENT.VisionFOV = 90
```
**Type:** number
**Description:** Field of view angle (degrees)

### ENT.HearingMaxDistance
```lua
ENT.HearingMaxDistance = 2000
```
**Type:** number
**Description:** Maximum hearing distance (units)

### ENT.HearingMinVolume
```lua
ENT.HearingMinVolume = 60
```
**Type:** number
**Description:** Minimum sound volume to hear

---

## Combat & Weapons

<!-- TODO: Document all combat properties from weapons.lua -->

### ENT.MeleeAttackRange
```lua
ENT.MeleeAttackRange = 80
```
**Type:** number
**Description:** Melee attack range (units)

### ENT.MeleeAttackDamageMin
```lua
ENT.MeleeAttackDamageMin = 10
```
**Type:** number
**Description:** Minimum melee damage

### ENT.MeleeAttackDamageMax
```lua
ENT.MeleeAttackDamageMax = 15
```
**Type:** number
**Description:** Maximum melee damage

### ENT.MeleeAttackDelay
```lua
ENT.MeleeAttackDelay = 1.0
```
**Type:** number
**Description:** Cooldown between melee attacks (seconds)

### ENT.RangeAttackRange
```lua
ENT.RangeAttackRange = 1000
```
**Type:** number
**Description:** Ranged attack distance (units)

### ENT.RangeAttackMinDistance
```lua
ENT.RangeAttackMinDistance = 100
```
**Type:** number
**Description:** Minimum distance for ranged attack

---

## Relationships & Factions

<!-- TODO: Document all relationship properties from relationships.lua -->

### ENT.Faction
```lua
ENT.Faction = FACTION_REBELS
```
**Type:** number
**Description:** Primary faction

### ENT.Factions
```lua
ENT.Factions = {FACTION_REBELS}
```
**Type:** table (array of numbers)
**Description:** All factions this NPC belongs to

### ENT.DefaultRelationship
```lua
ENT.DefaultRelationship = D_NU
```
**Type:** number
**Description:** Default relationship to unknown entities
**Options:** `D_LI` (like), `D_HT` (hate), `D_FR` (fear), `D_NU` (neutral)

---

## Animations

<!-- TODO: Document all animation properties from animations.lua -->

### ENT.IdleAnimation
```lua
ENT.IdleAnimation = ACT_IDLE
```
**Type:** number or string
**Description:** Idle animation activity

### ENT.WalkAnimation
```lua
ENT.WalkAnimation = ACT_WALK
```
**Type:** number or string
**Description:** Walking animation

### ENT.RunAnimation
```lua
ENT.RunAnimation = ACT_RUN
```
**Type:** number or string
**Description:** Running animation

### ENT.JumpAnimation
```lua
ENT.JumpAnimation = ACT_JUMP
```
**Type:** number or string
**Description:** Jump animation

### ENT.AttackAnimation
```lua
ENT.AttackAnimation = ACT_MELEE_ATTACK1
```
**Type:** number or string
**Description:** Attack animation

---

## Possession

<!-- TODO: Document all possession properties from possession.lua -->

### ENT.CanBePossessed
```lua
ENT.CanBePossessed = true
```
**Type:** boolean
**Description:** Allow player possession

### ENT.PossessionMoveMode
```lua
ENT.PossessionMoveMode = POSSESSION_MOVE_8DIR
```
**Type:** number
**Description:** Movement mode when possessed
**Options:** `POSSESSION_MOVE_8DIR`, `POSSESSION_MOVE_1DIR`, `POSSESSION_MOVE_4DIR`

---

## Patrol

<!-- TODO: Document all patrol properties from patrol.lua -->

### ENT.PatrolEnabled
```lua
ENT.PatrolEnabled = true
```
**Type:** boolean
**Description:** Enable patrol behavior

### ENT.PatrolRadius
```lua
ENT.PatrolRadius = 1000
```
**Type:** number
**Description:** Patrol area radius (units)

---

## Sounds

<!-- TODO: Document all sound properties -->

### ENT.IdleSounds
```lua
ENT.IdleSounds = {}
```
**Type:** table
**Description:** Idle sound files

### ENT.AttackSounds
```lua
ENT.AttackSounds = {}
```
**Type:** table
**Description:** Attack sound files

### ENT.PainSounds
```lua
ENT.PainSounds = {}
```
**Type:** table
**Description:** Pain sound files

### ENT.DeathSounds
```lua
ENT.DeathSounds = {}
```
**Type:** table
**Description:** Death sound files

---

## Complete Property List

<!-- TODO: Create comprehensive table of ALL properties -->

| Property | Type | Default | Description | File |
|----------|------|---------|-------------|------|
| `SpawnHealth` | number | 100 | Starting health | status.lua |
| `MoveSpeed` | number | 250 | Walk speed | movements.lua |
| ... | ... | ... | ... | ... |

---

## See Also

- [AI Functions](./ai.md)
- [Movement Functions](./movement.md)
- [Hooks](./hooks.md)
