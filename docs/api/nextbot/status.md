# Status & Health Functions

Health management and status effects.

**File:** `lua/entities/drgbase_nextbot/status.lua` (205 lines)

## Overview

The status system provides comprehensive health management, regeneration, and invulnerability features for DrGBase NPCs. It extends Garry's Mod's built-in health system with networking support and additional functionality like health regeneration and god mode.

## Health Management

### ENT:SetHealth(health[, clamp])

Sets the NPC's current health.

**Parameters:**
- `health` (number): The new health value
- `clamp` (boolean, optional): If true, clamps health between 0 and max health

**Realm:** Server

**Returns:** nil

**Example:**
```lua
function ENT:CustomInitialize()
    self:SetHealth(150)        -- Set to 150
    self:SetHealth(999, true)  -- Set to max health (clamped)
end
```

**Source:** `lua/entities/drgbase_nextbot/status.lua:143`

**Notes:**
- Cannot set health on dead NPCs
- Automatically updates networked health variable
- Without clamp, can exceed max health

---

### ENT:Health()

Gets the NPC's current health value.

**Realm:** Shared

**Returns:** (number) Current health

**Example:**
```lua
if self:Health() < self:GetMaxHealth() * 0.5 then
    print("NPC at half health!")
end
```

**Source:** `lua/entities/drgbase_nextbot/status.lua:178`

**Notes:**
- Networked from server to clients
- Returns actual health value on server
- Returns synced value on client

---

### ENT:GetMaxHealth()

Gets the NPC's maximum health value.

**Realm:** Shared

**Returns:** (number) Maximum health

**Example:**
```lua
local healthPercent = self:Health() / self:GetMaxHealth()
print("Health at " .. (healthPercent * 100) .. "%")
```

**Source:** `lua/entities/drgbase_nextbot/status.lua:185`

**Notes:**
- Networked to clients automatically
- Set initially from `ENT.SpawnHealth` property

---

### ENT:SetMaxHealth(maxHealth)

Sets the NPC's maximum health value.

**Parameters:**
- `maxHealth` (number): The new maximum health

**Realm:** Server

**Returns:** nil

**Example:**
```lua
function ENT:CustomInitialize()
    self:SetMaxHealth(200)
    self:SetHealth(200)  -- Fill to new max
end
```

**Source:** `lua/entities/drgbase_nextbot/status.lua:155`

**Notes:**
- Does not automatically adjust current health
- Networked to clients

---

### ENT:AddHealth(amount)

Adds health to the NPC, clamped to max health.

**Parameters:**
- `amount` (number): Amount of health to add

**Realm:** Server

**Returns:** nil

**Example:**
```lua
function ENT:OnHealthPickup()
    self:AddHealth(25)  -- Heal 25 HP
end
```

**Source:** `lua/entities/drgbase_nextbot/status.lua:91`

**Notes:**
- Automatically clamped to max health
- Cannot exceed maximum health value

---

### ENT:RemoveHealth(amount)

Removes health from the NPC.

**Parameters:**
- `amount` (number): Amount of health to remove

**Realm:** Server

**Returns:** nil

**Example:**
```lua
function ENT:OnToxicDamage()
    self:RemoveHealth(5)  -- Take 5 damage
end
```

**Source:** `lua/entities/drgbase_nextbot/status.lua:94`

**Notes:**
- Triggers damage hooks normally
- Can kill the NPC if health reaches 0

---

### ENT:ScaleHealth(scale)

Multiplies both current and max health by a scale factor.

**Parameters:**
- `scale` (number): Scale multiplier (clamped to 0 or higher)

**Realm:** Server

**Returns:** nil

**Example:**
```lua
-- Make NPC twice as tough
self:ScaleHealth(2.0)

-- Reduce health to 50%
self:ScaleHealth(0.5)
```

**Source:** `lua/entities/drgbase_nextbot/status.lua:98`

**Notes:**
- Scales both current and maximum health
- Useful for difficulty scaling
- Cannot scale below 0

---

### ENT:RegenHealth(targetHealth, duration[, callback])

Regenerates health to a target value over time.

**Parameters:**
- `targetHealth` (number): Health value to reach (clamped to max health)
- `duration` (number): Time in seconds (0 = instant)
- `callback` (function, optional): Called each tick with `(self, currentHealth)`. Return true to stop.

**Realm:** Server (Coroutine)

**Returns:** nil

**Example:**
```lua
-- Heal to 100 HP over 5 seconds
self:RegenHealth(100, 5)

-- Instant heal
self:RegenHealth(self:GetMaxHealth(), 0)

-- Heal with callback
self:RegenHealth(100, 10, function(self, hp)
    if self:IsPossessed() then
        return true  -- Cancel if possessed
    end
end)
```

**Source:** `lua/entities/drgbase_nextbot/status.lua:76`

**Notes:**
- Uses coroutines - must be called from coroutine context
- Temporarily modifies health regen rate
- Restores original regen rate after completion
- Does not regen if already at or above target

## Regeneration

### ENT:SetHealthRegen(amount)

Sets the passive health regeneration rate per second.

**Parameters:**
- `amount` (number): Health regenerated per second (can be negative for damage)

**Realm:** Server

**Returns:** nil

**Example:**
```lua
function ENT:CustomInitialize()
    self:SetHealthRegen(2)   -- Regen 2 HP per second
    self:SetHealthRegen(-1)  -- Take 1 damage per second
end
```

**Source:** `lua/entities/drgbase_nextbot/status.lua:50`

**Notes:**
- Positive values regenerate health
- Negative values deal damage over time
- Networked to clients
- Applied automatically in think cycle
- Initial value set from `ENT.HealthRegen` property

---

### ENT:GetHealthRegen()

Gets the current health regeneration rate.

**Realm:** Shared

**Returns:** (number) Health regenerated per second

**Example:**
```lua
local regenRate = self:GetHealthRegen()
if regenRate > 0 then
    print("Regenerating " .. regenRate .. " HP/sec")
end
```

**Source:** `lua/entities/drgbase_nextbot/status.lua:4`

**Notes:**
- Returns networked value
- Can be positive (regen) or negative (damage)

---

## God Mode

### ENT:SetGodMode(enabled)

Enables or disables god mode (invulnerability).

**Parameters:**
- `enabled` (boolean): True to enable, false to disable

**Realm:** Server

**Returns:** nil

**Example:**
```lua
-- Make invulnerable
self:SetGodMode(true)

-- Remove invulnerability
self:SetGodMode(false)
```

**Source:** `lua/entities/drgbase_nextbot/status.lua:64`

**Notes:**
- Prevents all damage when enabled
- Networked to clients
- See also `ENT:EnableGodMode()` and `ENT:DisableGodMode()` shortcuts

---

### ENT:EnableGodMode()

Convenience function to enable god mode.

**Realm:** Server

**Returns:** nil

**Example:**
```lua
function ENT:OnBossPhaseStart()
    self:EnableGodMode()
end
```

**Source:** `lua/entities/drgbase_nextbot/status.lua:67`

**Notes:**
- Equivalent to `ENT:SetGodMode(true)`

---

### ENT:DisableGodMode()

Convenience function to disable god mode.

**Realm:** Server

**Returns:** nil

**Example:**
```lua
function ENT:OnBossPhaseEnd()
    self:DisableGodMode()
end
```

**Source:** `lua/entities/drgbase_nextbot/status.lua:70`

**Notes:**
- Equivalent to `ENT:SetGodMode(false)`

---

### ENT:GetGodMode()

Checks if god mode is currently enabled.

**Realm:** Shared

**Returns:** (boolean) True if god mode is active

**Example:**
```lua
if not self:GetGodMode() then
    -- NPC can take damage
end
```

**Source:** `lua/entities/drgbase_nextbot/status.lua:36`

**Notes:**
- Returns networked value
- Available on both client and server

## Additional Status Functions

The status.lua file also provides several other useful functions:

### ENT:IsAlive() / ENT:Alive()

Checks if the NPC is alive (not dead or dying).

**Realm:** Shared

**Returns:** (boolean) True if alive

**Source:** `lua/entities/drgbase_nextbot/status.lua:25`

---

### ENT:IsDead()

Checks if the NPC is dead or dying.

**Realm:** Shared

**Returns:** (boolean) True if dead or dying

**Source:** `lua/entities/drgbase_nextbot/status.lua:21`

---

### ENT:IsDying()

Checks if the NPC is in the dying state.

**Realm:** Shared

**Returns:** (boolean) True if currently dying

**Source:** `lua/entities/drgbase_nextbot/status.lua:18`

---

### ENT:IsDown() / ENT:IsDowned()

Checks if the NPC is in a downed state (ragdolled/incapacitated).

**Realm:** Shared

**Returns:** (boolean) True if downed

**Source:** `lua/entities/drgbase_nextbot/status.lua:12`

---

### ENT:GetScale()

Gets the NPC's current size scale multiplier.

**Realm:** Shared

**Returns:** (number) Scale multiplier (1.0 = normal size)

**Source:** `lua/entities/drgbase_nextbot/status.lua:8`

---

### ENT:SetScale(scale[, delta])

Sets the NPC's size scale.

**Parameters:**
- `scale` (number): Scale multiplier (1.0 = normal size)
- `delta` (number, optional): Time to smoothly transition

**Realm:** Server

**Returns:** nil

**Example:**
```lua
self:SetScale(2.0, 1)  -- Grow to 2x size over 1 second
self:SetScale(0.5)     -- Shrink to half size instantly
```

**Source:** `lua/entities/drgbase_nextbot/status.lua:54`

**Notes:**
- Also updates collision bounds and movement speed
- Multiplied with `ENT.ModelScale` property

---

### ENT:Scale(multiplier[, delta])

Multiplies the current scale by a value.

**Parameters:**
- `multiplier` (number): Value to multiply scale by
- `delta` (number, optional): Transition time

**Realm:** Server

**Returns:** nil

**Example:**
```lua
self:Scale(2.0, 1)  -- Double current size over 1 second
```

**Source:** `lua/entities/drgbase_nextbot/status.lua:60`

---

## Hooks

### ENT:OnHealthChange(oldHealth, newHealth)

Called when the NPC's health value changes.

**Parameters:**
- `oldHealth` (number): Previous health value
- `newHealth` (number): New health value

**Realm:** Server

**Example:**
```lua
function ENT:OnHealthChange(oldHealth, newHealth)
    if newHealth < oldHealth then
        print("Took damage!")
    end
end
```

**Source:** `lua/entities/drgbase_nextbot/status.lua:127`

---

## Status Effects

DrGBase does not include a built-in status effect system (like burning, poison, slow, etc.). The framework provides the core health management, but you can implement your own status effect system by:

1. Using `ENT:SetHealthRegen()` for damage/healing over time
2. Creating custom properties to track effect states
3. Implementing effects in `ENT:CustomThink()` or coroutines
4. Using the animation and model systems for visual effects

**Example Custom Status Effect:**
```lua
function ENT:ApplyPoison(duration)
    self._PoisonEndTime = CurTime() + duration
    self:SetHealthRegen(-5)  -- 5 damage per second
end

function ENT:CustomThink()
    if self._PoisonEndTime and CurTime() > self._PoisonEndTime then
        self._PoisonEndTime = nil
        self:SetHealthRegen(0)
    end
end
```

---

## Related Configuration

These properties in your NPC's shared.lua configure the status system:

```lua
ENT.SpawnHealth = 100      -- Initial and maximum health
ENT.HealthRegen = 0        -- Health regeneration per second
ENT.MinPhysDamage = 10     -- Minimum physics damage threshold
ENT.MinFallDamage = 10     -- Minimum fall damage threshold
```

See [Base Configuration](../base-configuration.md#health--status)

---

## See Also

- **[Damage System](damage.md)** - Damage handling and calculations
- **[Base Configuration](../base-configuration.md)** - Health properties
- **[Hooks Reference](hooks.md)** - Health-related event hooks
