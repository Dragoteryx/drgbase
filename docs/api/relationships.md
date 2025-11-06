# Relationships

## Overview
The DrGBase relationship system manages how NPCs interact with each other, players, and other entities through dispositions, factions, and priorities.

**Source:** `lua/entities/drgbase_nextbot/relationships.lua:1`

---

## Dispositions

Relationship types that determine NPC behavior toward entities.

### Values

```lua
D_HT  -- Hate (1): Attack on sight
D_FR  -- Fear (2): Flee from
D_LI  -- Like (3): Ally with
D_NU  -- Neutral (4): Ignore
D_ER  -- Error (0): Invalid
```

**See:** `lua/drgbase/enumerations.lua:37`

---

## Getting Relationships

### ENT:GetRelationship

```lua
ENT:GetRelationship(entity)
```

Get relationship disposition toward entity.

**Parameters:**
- `entity` (Entity) - Target entity

**Returns:**
- (number) - Disposition (D_HT, D_FR, D_LI, D_NU)

**Realm:** 🖥️ SERVER

**Example:**
```lua
local rel = self:GetRelationship(player)
if rel == D_HT then
    print("Enemy!")
elseif rel == D_LI then
    print("Ally!")
end
```

---

### ENT:GetDefaultRelationship

```lua
ENT:GetDefaultRelationship()
```

Get default relationship for all entities.

**Returns:**
- (number) - Default disposition

**Realm:** 🖥️ SERVER

---

### ENT:GetPriority

```lua
ENT:GetPriority(entity)
```

Get target priority for entity (higher = more important).

**Parameters:**
- `entity` (Entity) - Target entity

**Returns:**
- (number) - Priority value (default: 1)

**Realm:** 🖥️ SERVER

**Example:**
```lua
-- Boss has higher priority
local priority = self:GetPriority(entity)
if priority > 10 then
    print("High priority target!")
end
```

---

## Setting Relationships

### ENT:SetRelationship 🖥️

```lua
ENT:SetRelationship(target, disposition, priority)
```

Set relationship with entity/entities.

**Parameters:**
- `target` (Entity/table/string) - Entity, table of entities, class name, or "player"
- `disposition` (number) - Relationship (D_HT, D_FR, D_LI, D_NU)
- `priority` (number, optional) - Target priority (default: 1)

**Realm:** 🖥️ SERVER

**Examples:**
```lua
-- Hostile to specific player
self:SetRelationship(ply, D_HT)

-- Hostile to all players
self:SetRelationship("player", D_HT)

-- Hostile to all players with high priority
self:SetRelationship("player", D_HT, 10)

-- Friendly to specific NPC
self:SetRelationship(npc, D_LI)

-- Hostile to NPC class
self:SetRelationship("npc_zombie", D_HT)

-- Set relationship for multiple entities
self:SetRelationship(player.GetAll(), D_HT)
```

---

### ENT:SetDefaultRelationship 🖥️

```lua
ENT:SetDefaultRelationship(disposition)
```

Set default relationship for all entities.

**Parameters:**
- `disposition` (number) - Default disposition

**Realm:** 🖥️ SERVER

**Example:**
```lua
function ENT:CustomInitialize()
    self:SetDefaultRelationship(D_HT)  -- Hostile to everything
end
```

---

## Relationship Checks

### ENT:IsAlly

```lua
ENT:IsAlly(entity)
```

Check if entity is an ally (D_LI).

**Parameters:**
- `entity` (Entity) - Entity to check

**Returns:**
- (boolean) - True if ally

**Realm:** 🖥️ SERVER

---

### ENT:IsEnemy

```lua
ENT:IsEnemy(entity)
```

Check if entity is an enemy (D_HT).

**Parameters:**
- `entity` (Entity) - Entity to check

**Returns:**
- (boolean) - True if enemy

**Realm:** 🖥️ SERVER

---

### ENT:IsAfraidOf

```lua
ENT:IsAfraidOf(entity)
```

Check if afraid of entity (D_FR).

**Parameters:**
- `entity` (Entity) - Entity to check

**Returns:**
- (boolean) - True if afraid

**Realm:** 🖥️ SERVER

---

### ENT:IsNeutral

```lua
ENT:IsNeutral(entity)
```

Check if neutral toward entity (D_NU).

**Parameters:**
- `entity` (Entity) - Entity to check

**Returns:**
- (boolean) - True if neutral

**Realm:** 🖥️ SERVER

---

## Factions

### ENT:JoinFaction 🖥️

```lua
ENT:JoinFaction(faction)
```

Join a faction.

**Parameters:**
- `faction` (string) - Faction name

**Realm:** 🖥️ SERVER

**Example:**
```lua
self:JoinFaction(FACTION_REBELS)
self:JoinFaction("FACTION_CUSTOM_ROBOTS")
```

---

### ENT:JoinFactions 🖥️

```lua
ENT:JoinFactions(factions)
```

Join multiple factions.

**Parameters:**
- `factions` (table) - Array of faction names

**Realm:** 🖥️ SERVER

**Example:**
```lua
self:JoinFactions({FACTION_COMBINE, FACTION_HECU})
```

---

### ENT:LeaveFaction 🖥️

```lua
ENT:LeaveFaction(faction)
```

Leave a faction.

**Parameters:**
- `faction` (string) - Faction name

**Realm:** 🖥️ SERVER

---

### ENT:IsInFaction

```lua
ENT:IsInFaction(faction)
```

Check if in faction.

**Parameters:**
- `faction` (string) - Faction name

**Returns:**
- (boolean) - True if in faction

**Realm:** 🖥️ SERVER

---

### ENT:GetFactions

```lua
ENT:GetFactions()
```

Get all factions NPC belongs to.

**Returns:**
- (table) - Array of faction names

**Realm:** 🖥️ SERVER

---

### ENT:SharesFactionWith

```lua
ENT:SharesFactionWith(entity)
```

Check if shares any faction with entity.

**Parameters:**
- `entity` (Entity) - Entity to check

**Returns:**
- (boolean) - True if shares faction

**Realm:** 🖥️ SERVER

**Example:**
```lua
if self:SharesFactionWith(npc) then
    print("Same faction!")
end
```

---

## Entity Iterators

### ENT:EntityIterator 🖥️

```lua
ENT:EntityIterator(disposition, spotted)
```

Get iterator for entities with given disposition.

**Parameters:**
- `disposition` (number) - Disposition to filter (D_HT, D_LI, etc.)
- `spotted` (boolean, optional) - Only include spotted entities

**Returns:**
- (function) - Iterator function

**Realm:** 🖥️ SERVER

**Example:**
```lua
-- Iterate over all enemies
for enemy in self:EntityIterator(D_HT) do
    print("Enemy:", enemy)
end

-- Iterate over spotted enemies
for enemy in self:EntityIterator(D_HT, true) do
    print("Spotted enemy:", enemy)
end
```

---

### ENT:AllyIterator 🖥️

```lua
ENT:AllyIterator(spotted)
```

Get iterator for allies.

**Returns:**
- (function) - Iterator function

**Realm:** 🖥️ SERVER

---

### ENT:EnemyIterator 🖥️

```lua
ENT:EnemyIterator(spotted)
```

Get iterator for enemies.

**Returns:**
- (function) - Iterator function

**Realm:** 🖥️ SERVER

---

### ENT:AfraidOfIterator 🖥️

```lua
ENT:AfraidOfIterator(spotted)
```

Get iterator for feared entities.

**Returns:**
- (function) - Iterator function

**Realm:** 🖥️ SERVER

---

### ENT:HostileIterator 🖥️

```lua
ENT:HostileIterator(spotted)
```

Get iterator for hostile entities (enemies + feared).

**Returns:**
- (function) - Iterator function

**Realm:** 🖥️ SERVER

---

## Getting Entity Lists

### ENT:GetAllies 🖥️

```lua
ENT:GetAllies(spotted)
```

Get all allies.

**Parameters:**
- `spotted` (boolean, optional) - Only include spotted

**Returns:**
- (table) - Array of ally entities

**Realm:** 🖥️ SERVER

---

### ENT:GetEnemies 🖥️

```lua
ENT:GetEnemies(spotted)
```

Get all enemies.

**Parameters:**
- `spotted` (boolean, optional) - Only include spotted

**Returns:**
- (table) - Array of enemy entities

**Realm:** 🖥️ SERVER

---

### ENT:GetAfraidOf 🖥️

```lua
ENT:GetAfraidOf(spotted)
```

Get all feared entities.

**Parameters:**
- `spotted` (boolean, optional) - Only include spotted

**Returns:**
- (table) - Array of feared entities

**Realm:** 🖥️ SERVER

---

### ENT:GetHostiles 🖥️

```lua
ENT:GetHostiles(spotted)
```

Get all hostile entities (enemies + feared).

**Parameters:**
- `spotted` (boolean, optional) - Only include spotted

**Returns:**
- (table) - Array of hostile entities

**Realm:** 🖥️ SERVER

---

## Frightening

### ENT:IsFrightening

```lua
ENT:IsFrightening()
```

Check if this NPC frightens others.

**Returns:**
- (boolean) - True if frightening

**Realm:** 🌐 SHARED

**Source:** `lua/entities/drgbase_nextbot/relationships.lua:8`

---

## Update Functions

### ENT:UpdateRelationships 🖥️

```lua
ENT:UpdateRelationships()
```

Update all relationship caches (called automatically).

**Realm:** 🖥️ SERVER

---

## Built-in Factions

Defined in `lua/drgbase/enumerations.lua:6`:

```lua
-- Half-Life 2
FACTION_REBELS
FACTION_COMBINE
FACTION_ZOMBIES
FACTION_ANTLIONS
FACTION_ANIMALS
FACTION_GMAN
FACTION_BARNACLES

-- Half-Life 1
FACTION_XEN_ARMY
FACTION_XEN_WILDLIFE
FACTION_HECU

-- Other
FACTION_SANIC
```

---

## Default NPC Factions

DrGBase automatically assigns these Source engine NPCs to factions:

**Combine:**
- npc_combine_s, npc_hunter, npc_helicopter
- npc_manhack, npc_turret_ceiling, npc_cscanner
- npc_combinedropship, npc_combinegunship
- npc_combine_camera

**Rebels:**
- npc_monk, npc_citizen, npc_barney, npc_alyx
- npc_dog, npc_eli, npc_kleiner, npc_magnusson
- npc_mossman

**Zombies:**
- npc_zombie, npc_zombie_torso, npc_poisonzombie
- npc_fastzombie, npc_zombine, npc_headcrab
- npc_headcrab_fast, npc_headcrab_poison, npc_headcrab_black

**Antlions:**
- npc_antlion, npc_antlionguard, npc_antlion_worker

**Animals:**
- npc_crow, npc_pigeon, npc_seagull

**Source:** `lua/entities/drgbase_nextbot/relationships.lua:87`

---

## Custom Factions

```lua
-- Define globally (in autorun or shared file)
FACTION_MY_ROBOTS = "FACTION_CUSTOM_ROBOTS"

-- Use in NPC
ENT.Factions = {FACTION_MY_ROBOTS}

-- Or join at runtime
function ENT:CustomInitialize()
    self:JoinFaction(FACTION_MY_ROBOTS)
end
```

---

## Relationship Priority

Priority determines target selection when multiple enemies are available:

- Higher priority = more important target
- Default priority: 1
- Useful for bosses, VIPs, or special targets

**Example:**
```lua
-- Make bosses high priority
self:SetRelationship("npc_boss", D_HT, 100)

-- Players are medium priority
self:SetRelationship("player", D_HT, 10)

-- Regular NPCs are low priority
self:SetRelationship("npc_zombie", D_HT, 1)
```

---

## ConVars

### drgbase_debug_relationships

**Default:** `0`
**Type:** ConVar

Enable relationship debugging.

**Usage:**
```
drgbase_debug_relationships 1  -- Enable debug output
```

**Source:** `lua/entities/drgbase_nextbot/relationships.lua:4`

---

## See Also

- **[AI System](ai-system.md)** - Enemy targeting
- **[Getting Started: Relationships](../getting-started/04-relationships-factions.md)** - Beginner guide
- **[Enumerations](enumerations.md)** - Faction constants
