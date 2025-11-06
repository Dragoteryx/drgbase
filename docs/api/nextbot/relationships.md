# Relationship & Faction Functions

Relationship management and faction system.

**File:** `lua/entities/drgbase_nextbot/relationships.lua` (831 lines)

---

## Faction Management

### ENT:SetFaction(faction)

Sets the NPC's primary faction.

**Realm:** 🔴 SERVER

**Parameters:**
- `faction` (number) - Faction ID (FACTION_*)

**Returns:** None

**Example:**
```lua
self:SetFaction(FACTION_REBELS)
```

---

### ENT:GetFaction()

Gets primary faction.

**Realm:** 🔴 SERVER

**Parameters:** None

**Returns:**
- `number` - Faction ID

---

### ENT:GetFactions()

Gets all factions NPC belongs to.

**Realm:** 🔴 SERVER

**Parameters:** None

**Returns:**
- `table` - Array of faction IDs

---

### ENT:AddFaction(faction)

Adds NPC to a faction.

**Realm:** 🔴 SERVER

**Parameters:**
- `faction` (number) - Faction ID to add

**Returns:** None

---

### ENT:RemoveFaction(faction)

Removes NPC from a faction.

**Realm:** 🔴 SERVER

**Parameters:**
- `faction` (number) - Faction ID to remove

**Returns:** None

---

### ENT:HasFaction(faction)

Checks if NPC is in a faction.

**Realm:** 🔴 SERVER

**Parameters:**
- `faction` (number) - Faction ID

**Returns:**
- `boolean` - True if in faction

---

## Relationship Management

### ENT:SetRelationship(entity, disposition, priority)

Sets relationship to a specific entity.

**Realm:** 🔴 SERVER

**Parameters:**
- `entity` (Entity) - Target entity
- `disposition` (number) - Relationship type (D_LI, D_HT, D_FR, D_NU)
- `priority` (number, optional) - Relationship priority

**Returns:** None

**Example:**
```lua
-- Make NPC like a specific player
self:SetRelationship(player, D_LI)

-- Make NPC hate an entity
self:SetRelationship(enemy, D_HT, 99)
```

<!-- TODO: Document priority system -->

---

### ENT:GetRelationship(entity)

Gets relationship to an entity.

**Realm:** 🔴 SERVER

**Parameters:**
- `entity` (Entity) - Target entity

**Returns:**
- `number` - Disposition (D_LI, D_HT, D_FR, D_NU, D_ER)

**Example:**
```lua
local rel = self:GetRelationship(player)
if rel == D_HT then
    -- Player is enemy
elseif rel == D_LI then
    -- Player is friend
end
```

---

### ENT:RemoveRelationship(entity)

Removes specific relationship.

**Realm:** 🔴 SERVER

**Parameters:**
- `entity` (Entity) - Entity to remove relationship with

**Returns:** None

---

### ENT:ClearRelationships()

Clears all relationships.

**Realm:** 🔴 SERVER

**Parameters:** None

**Returns:** None

---

## Class & Model Relationships

### ENT:SetClassRelationship(class, disposition)

Sets relationship to all entities of a class.

**Realm:** 🔴 SERVER

**Parameters:**
- `class` (string) - Entity class name
- `disposition` (number) - Disposition

**Returns:** None

**Example:**
```lua
-- Hate all zombies
self:SetClassRelationship("npc_zombie", D_HT)
```

---

### ENT:GetClassRelationship(class)

Gets relationship to a class.

**Realm:** 🔴 SERVER

**Parameters:**
- `class` (string) - Entity class

**Returns:**
- `number` - Disposition

---

### ENT:SetModelRelationship(model, disposition)

Sets relationship to all entities with a model.

**Realm:** 🔴 SERVER

**Parameters:**
- `model` (string) - Model path
- `disposition` (number) - Disposition

**Returns:** None

---

### ENT:GetModelRelationship(model)

Gets relationship to a model.

**Realm:** 🔴 SERVER

**Parameters:**
- `model` (string) - Model path

**Returns:**
- `number` - Disposition

---

## Faction Relationships

### ENT:SetFactionRelationship(faction, disposition)

Sets relationship to all members of a faction.

**Realm:** 🔴 SERVER

**Parameters:**
- `faction` (number) - Faction ID
- `disposition` (number) - Disposition

**Returns:** None

**Example:**
```lua
-- Hate all Combine
self:SetFactionRelationship(FACTION_COMBINE, D_HT)

-- Like all Rebels
self:SetFactionRelationship(FACTION_REBELS, D_LI)
```

---

### ENT:GetFactionRelationship(faction)

Gets relationship to a faction.

**Realm:** 🔴 SERVER

**Parameters:**
- `faction` (number) - Faction ID

**Returns:**
- `number` - Disposition

---

## Enemy Determination

### ENT:IsEnemy(entity)

Checks if entity is an enemy.

**Realm:** 🔴 SERVER

**Parameters:**
- `entity` (Entity) - Entity to check

**Returns:**
- `boolean` - True if enemy (D_HT or D_FR)

**Example:**
```lua
if self:IsEnemy(ent) then
    self:SetEnemy(ent)
end
```

---

### ENT:IsFriend(entity)

Checks if entity is a friend.

**Realm:** 🔴 SERVER

**Parameters:**
- `entity` (Entity) - Entity to check

**Returns:**
- `boolean` - True if friend (D_LI)

---

### ENT:IsNeutral(entity)

Checks if entity is neutral.

**Realm:** 🔴 SERVER

**Parameters:**
- `entity` (Entity) - Entity to check

**Returns:**
- `boolean` - True if neutral (D_NU)

---

## Damage Tolerance

### ENT:SetDamageTolerance(entity, amount)

Sets how much damage entity can deal before becoming enemy.

**Realm:** 🔴 SERVER

**Parameters:**
- `entity` (Entity) - Entity
- `amount` (number) - Damage threshold

**Returns:** None

**Description:**
<!-- TODO: Explain damage tolerance system -->

---

## Relationship Priority

<!-- TODO: Document relationship priority system -->

### Priority Levels

1. Entity-specific relationships (highest)
2. Class-specific relationships
3. Model-specific relationships
4. Faction relationships
5. Default relationship (lowest)

---

## Related Hooks

- `ENT:OnRelationshipChanged(entity, oldDisp, newDisp)` - When relationship changes
- `ENT:OnFactionChanged(oldFaction, newFaction)` - When faction changes

---

## See Also

- [Enumerations](../core/enumerations.md) - Faction and disposition constants
- [AI Functions](./ai.md) - Enemy management
- [Faction Guide](../../guides/factions.md)
- [Relationship System](../../systems/relationships/README.md)
