# Nextbot Base API

Complete API reference for `drgbase_nextbot` and its variants.

**Base Class:** `entities/drgbase_nextbot/`

## API Files

### Configuration & Properties
- **[base-config.md](./base-config.md)** - All ENT properties and configuration options

### Core Systems
- **[ai.md](./ai.md)** - AI system functions (187 lines)
- **[movement.md](./movement.md)** - Movement and locomotion functions (702 lines)
- **[animation.md](./animation.md)** - Animation system functions (552 lines)
- **[weapons.md](./weapons.md)** - Weapon system functions (537 lines)
- **[relationships.md](./relationships.md)** - Relationship and faction functions (831 lines)

### Detection & Awareness
- **[detection.md](./detection.md)** - Detection system functions (244 lines)
- **[awareness.md](./awareness.md)** - Awareness and perception functions (262 lines)

### Navigation
- **[path.md](./path.md)** - Pathfinding functions (158 lines)
- **[patrol.md](./patrol.md)** - Patrol system functions (226 lines)

### Status & Combat
- **[status.md](./status.md)** - Health and status functions (205 lines)

### Special Systems
- **[possession.md](./possession.md)** - Possession system functions (420 lines)

### Hooks & Events
- **[hooks.md](./hooks.md)** - All available hooks and callbacks (300 lines)

## Quick Reference

### Essential Functions

#### Initialization
```lua
function ENT:CustomInitialize()
    -- Called after spawning
end
```

#### AI & Enemies
```lua
ENT:SetEnemy(ent)              -- Set current enemy
ENT:GetEnemy()                 -- Get current enemy
ENT:FindEnemies()              -- Find potential enemies
ENT:IsEnemyVisible()           -- Check line of sight
```

#### Movement
```lua
ENT:MoveToPos(pos)             -- Move to position
ENT:StopMoving()               -- Stop movement
ENT:IsMoving()                 -- Check if moving
ENT:Jump()                     -- Jump
```

#### Combat
```lua
ENT:OnMeleeAttack(enemy)       -- Handle melee attack
ENT:OnRangeAttack(enemy)       -- Handle ranged attack
ENT:OnTakeDamage(dmg)          -- Handle damage
```

#### Relationships
```lua
ENT:SetRelationship(ent, disp) -- Set relationship
ENT:GetRelationship(ent)       -- Get relationship
ENT:SetFaction(faction)        -- Set faction
```

### Common Properties

#### Model & Appearance
```lua
ENT.Models = {"models/player.mdl"}
ENT.ModelScale = 1.0
ENT.CollisionBounds = Vector(20, 20, 72)
```

#### Health & Stats
```lua
ENT.SpawnHealth = 100
ENT.HealthRegen = 0
ENT.MinPhysDamage = 10
ENT.MinFallDamage = 10
```

#### Movement
```lua
ENT.MoveSpeed = 250
ENT.MoveAcceleration = 400
ENT.JumpHeight = 64
ENT.StepHeight = 24
```

#### Combat
```lua
ENT.MeleeAttackRange = 80
ENT.MeleeAttackDamageMin = 10
ENT.MeleeAttackDamageMax = 15
ENT.RangeAttackRange = 1000
```

#### AI
```lua
ENT.VisionRange = 4000
ENT.VisionFOV = 90
ENT.HearingMaxDistance = 2000
```

#### Faction
```lua
ENT.Faction = FACTION_REBELS
ENT.Factions = {FACTION_REBELS}
```

## By Category

### [Configuration](./base-config.md)
All ENT.* properties that can be set

### [AI & Detection](./ai.md)
Enemy management, detection, awareness

### [Movement & Navigation](./movement.md)
Walking, running, pathfinding, jumping

### [Combat](./weapons.md)
Attacking, damage, weapons

### [Relationships](./relationships.md)
Factions, relationships, enemy determination

### [Animation](./animation.md)
Sequences, activities, gestures

### [Hooks & Callbacks](./hooks.md)
All customization points

## Variants

### drgbase_nextbot_human
- Extends `drgbase_nextbot`
- Human-specific animations
- Humanoid movement
- See [Human Variant Guide](../../guides/human-variant.md)

### drgbase_nextbot_sprite
- Extends `drgbase_nextbot`
- Sprite-based rendering
- 2D animations
- See [Sprite Variant Guide](../../guides/sprite-variant.md)

## See Also

- [Creating NPCs Guide](../../guides/creating-npcs.md)
- [AI System Documentation](../../systems/ai/README.md)
- [Movement System Documentation](../../systems/movement/README.md)
