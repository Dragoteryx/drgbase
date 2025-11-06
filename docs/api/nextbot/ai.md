# AI System Functions

AI management, enemy handling, and decision making.

**File:** `lua/entities/drgbase_nextbot/ai.lua` (187 lines)

---

## Enemy Management

### ENT:SetEnemy(ent)

Sets the current enemy target.

**Realm:** 🔴 SERVER

**Parameters:**
- `ent` (Entity) - Entity to set as enemy (nil to clear)

**Returns:** None

**Example:**
```lua
function ENT:CustomInitialize()
    -- Set specific enemy
    self:SetEnemy(targetPlayer)
end
```

<!-- TODO: Document behavior, triggers, hooks called -->

---

### ENT:GetEnemy()

Gets the current enemy.

**Realm:** 🔴 SERVER

**Parameters:** None

**Returns:**
- `Entity` - Current enemy, or nil if none

**Example:**
```lua
local enemy = self:GetEnemy()
if IsValid(enemy) then
    -- Attack enemy
end
```

---

### ENT:HasEnemy()

Checks if NPC has an enemy.

**Realm:** 🔴 SERVER

**Parameters:** None

**Returns:**
- `boolean` - True if has valid enemy

---

### ENT:ClearEnemy()

Clears the current enemy.

**Realm:** 🔴 SERVER

**Parameters:** None

**Returns:** None

---

### ENT:FindEnemies()

Searches for potential enemies.

**Realm:** 🔴 SERVER

**Parameters:** None

**Returns:**
- `table` - Array of potential enemy entities

**Description:**
<!-- TODO: Describe detection logic, range, filters -->

---

### ENT:IsEnemyVisible(ent)

Checks if entity has line of sight to enemy.

**Realm:** 🔴 SERVER

**Parameters:**
- `ent` (Entity, optional) - Entity to check (defaults to current enemy)

**Returns:**
- `boolean` - True if visible

---

## AI State

### ENT:SetAIEnabled(enabled)

Enables or disables AI.

**Realm:** 🔴 SERVER

**Parameters:**
- `enabled` (boolean) - Enable or disable AI

**Returns:** None

---

### ENT:IsAIEnabled()

Checks if AI is enabled.

**Realm:** 🔴 SERVER

**Parameters:** None

**Returns:**
- `boolean` - True if AI is enabled

---

### ENT:SetOmniscient(enabled)

Enables omniscient mode (sees all enemies).

**Realm:** 🔴 SERVER

**Parameters:**
- `enabled` (boolean) - Enable or disable omniscient mode

**Returns:** None

---

## Target Selection

<!-- TODO: Document target selection functions -->

### ENT:SelectBestEnemy()

Selects the best enemy from available targets.

**Realm:** 🔴 SERVER

**Returns:**
- `Entity` - Best enemy target

**Description:**
<!-- TODO: Document selection criteria -->

---

### ENT:GetEnemyPriority(ent)

Gets priority score for potential enemy.

**Realm:** 🔴 SERVER

**Parameters:**
- `ent` (Entity) - Entity to evaluate

**Returns:**
- `number` - Priority score (higher = better target)

---

## Enemy Tracking

<!-- TODO: Document enemy tracking functions -->

### ENT:RememberEnemy(ent)

Remembers an enemy even if not currently visible.

**Realm:** 🔴 SERVER

**Parameters:**
- `ent` (Entity) - Enemy to remember

**Returns:** None

---

### ENT:ForgetEnemy(ent)

Forgets a remembered enemy.

**Realm:** 🔴 SERVER

**Parameters:**
- `ent` (Entity) - Enemy to forget

**Returns:** None

---

## Behavior Modifiers

<!-- TODO: Document behavior modifier functions -->

---

## Related Hooks

- `ENT:OnNewEnemy(ent)` - Called when new enemy is acquired
- `ENT:OnLostEnemy(ent)` - Called when enemy is lost
- `ENT:OnEnemyVisible(ent)` - Called when enemy becomes visible

See [Hooks Documentation](./hooks.md) for details.

---

## See Also

- [Detection System](./detection.md)
- [Awareness System](./awareness.md)
- [Relationship System](./relationships.md)
- [AI System Guide](../../systems/ai/README.md)
