# Design Patterns

## Inheritance Pattern

<!-- TODO: Explain inheritance system -->

### Entity Inheritance

```lua
ENT.Base = "drgbase_nextbot"
```

<!-- How inheritance works -->
<!-- Method override -->
<!-- Calling parent methods -->

### Multi-Level Inheritance

```
drgbase_nextbot
    ↓
drgbase_nextbot_human
    ↓
Your Custom Human NPC
```

## Hook System Pattern

<!-- TODO: Explain hook-based customization -->

### Framework Hooks

```lua
function ENT:CustomInitialize()
    -- Called after Initialize()
end

function ENT:OnTakeDamage(dmg)
    -- Handle damage
    return true  -- Allow damage
end

function ENT:OnDeath(dmg, delay, hitgroup)
    -- Handle death
end
```

<!-- List all available hooks -->

### Hook Flow

```
Engine Event → Base Method → Custom Hook → Return to Engine
```

## Registry Pattern

<!-- TODO: Explain registration system -->

### Nextbot Registry

```lua
DrGBase.AddNextbot(ENT)
```

<!-- How entities register -->
<!-- What registration does -->

### Weapon Registry

```lua
DrGBase.AddWeapon(SWEP)
```

### Spawner Registry

```lua
DrGBase.AddSpawner(ENT)
```

## Factory Pattern

<!-- TODO: Explain entity creation -->

### Entity Creation

```lua
local npc = ents.Create("npc_drg_zombie")
npc:Spawn()
```

### Projectile Creation

```lua
self:FireProjectile("proj_drg_grenade", pos, ang)
```

## Observer Pattern

<!-- TODO: Explain event system -->

### Event Notifications

```lua
function ENT:OnNewEnemy(ent)
    -- Notified when new enemy detected
end

function ENT:OnLostEnemy(ent)
    -- Notified when enemy lost
end
```

<!-- How observers are notified -->

## State Pattern

<!-- TODO: Explain state management -->

### Behavior States

```lua
ENT:SetState(STATE_IDLE)
ENT:SetState(STATE_ALERT)
ENT:SetState(STATE_COMBAT)
```

<!-- How states are managed -->

### Movement States

```lua
ENT:SetMovementState(MOVEMENT_WALK)
ENT:SetMovementState(MOVEMENT_RUN)
```

## Strategy Pattern

<!-- TODO: Explain behavior strategies -->

### Movement Strategies

```lua
ENT:SetMoveMode(MOVE_MODE_WALK)
ENT:SetMoveMode(MOVE_MODE_FLY)
```

### Attack Strategies

```lua
function ENT:OnMeleeAttack(enemy)
    -- Melee strategy
end

function ENT:OnRangeAttack(enemy)
    -- Range strategy
end
```

## Singleton Pattern

<!-- TODO: Explain singletons -->

### Global Framework Table

```lua
DrGBase = DrGBase or {}
```

<!-- Only one instance -->
<!-- Global access -->

## Template Method Pattern

<!-- TODO: Explain template methods -->

### Think Template

```lua
function ENT:Think()
    -- Framework template logic
    self:CustomThink()  -- Extension point
    return true
end
```

### Initialize Template

```lua
function ENT:Initialize()
    -- Framework setup
    self:CustomInitialize()  -- Extension point
end
```

## Decorator Pattern

<!-- TODO: Explain decorators -->

### Metatable Extensions

```lua
-- Decorating Entity metatable
function ENT:FindInCone(...)
    -- Extended functionality
end
```

## Facade Pattern

<!-- TODO: Explain facades -->

### Simplified Interfaces

```lua
-- Complex pathfinding wrapped in simple interface
ENT:MoveToPos(pos)

-- Instead of:
-- path = Path("Follow")
-- path:SetMinLookAheadDistance(300)
-- path:SetGoalTolerance(20)
-- path:Compute(self, pos)
-- etc.
```

## Module Pattern

<!-- TODO: Explain module organization -->

### Encapsulation

```lua
-- Module encapsulates related functionality
-- Exports only public interface
```

## Best Practices

<!-- TODO: Pattern usage best practices -->

### When to Use Inheritance
<!-- Guidelines -->

### When to Use Hooks
<!-- Guidelines -->

### When to Use Composition
<!-- Guidelines -->

---

**Previous:** [Client-Server Architecture](./05-client-server.md) | **Next:** [Core Systems](../../systems/README.md)
