# AI System

## Overview
The DrGBase AI system consists of three interconnected components: AI behavior, detection (senses), and awareness (memory). This document covers all AI-related functions and properties.

**Sources:**
- `lua/entities/drgbase_nextbot/ai.lua:1`
- `lua/entities/drgbase_nextbot/detection.lua:1`
- `lua/entities/drgbase_nextbot/awareness.lua:1`

---

## Enemy Management

### ENT:GetEnemy

```lua
ENT:GetEnemy()
```

Get current enemy entity.

**Returns:**
- (Entity) - Current enemy, or NULL if none

**Realm:** 🌐 SHARED

**Example:**
```lua
local enemy = self:GetEnemy()
if IsValid(enemy) then
    print("Current enemy:", enemy)
end
```

**Source:** `lua/entities/drgbase_nextbot/ai.lua:12`

---

### ENT:HasEnemy / ENT:HaveEnemy

```lua
ENT:HasEnemy()
```

Check if NPC has a current enemy.

**Returns:**
- (boolean) - True if has enemy

**Realm:** 🌐 SHARED

**Example:**
```lua
if self:HasEnemy() then
    self:ChaseEnemy()
end
```

**Source:** `lua/entities/drgbase_nextbot/ai.lua:15`

---

### ENT:HadEnemy

```lua
ENT:HadEnemy()
```

Check if NPC has ever had an enemy (even if lost now).

**Returns:**
- (boolean) - True if has had enemy before

**Realm:** 🌐 SHARED

**Source:** `lua/entities/drgbase_nextbot/ai.lua:21`

---

### ENT:SetEnemy 🖥️

```lua
ENT:SetEnemy(enemy)
```

Set current enemy entity.

**Parameters:**
- `enemy` (Entity) - Entity to set as enemy (or NULL to clear)

**Realm:** 🖥️ SERVER

**Example:**
```lua
function ENT:CustomThink()
    local player = Entity(1)
    if IsValid(player) then
        self:SetEnemy(player)
    end
end
```

**Source:** `lua/entities/drgbase_nextbot/ai.lua:85`

---

### ENT:SetNemesis 🖥️

```lua
ENT:SetNemesis(nemesis)
```

Set permanent enemy (nemesis). NPC will not change enemy until nemesis is invalid.

**Parameters:**
- `nemesis` (Entity) - Entity to set as nemesis

**Realm:** 🖥️ SERVER

**Example:**
```lua
-- Set player as permanent enemy
function ENT:OnDeath(dmg)
    local attacker = dmg:GetAttacker()
    if attacker:IsPlayer() then
        -- Tell allies to hunt this player
        for _, ally in ipairs(self:GetAllies()) do
            ally:SetNemesis(attacker)
        end
    end
end
```

**Source:** `lua/entities/drgbase_nextbot/ai.lua:89`

---

### ENT:GetNemesis

```lua
ENT:GetNemesis()
```

Get nemesis enemy.

**Returns:**
- (Entity) - Nemesis entity, or NULL

**Realm:** 🌐 SHARED

**Source:** `lua/entities/drgbase_nextbot/ai.lua:25`

---

### ENT:HasNemesis / ENT:HaveNemesis

```lua
ENT:HasNemesis()
```

Check if has nemesis.

**Returns:**
- (boolean) - True if has nemesis

**Realm:** 🌐 SHARED

**Source:** `lua/entities/drgbase_nextbot/ai.lua:30`

---

### ENT:FetchEnemy 🖥️

```lua
ENT:FetchEnemy()
```

Search for best enemy target from all visible hostiles.

**Returns:**
- (Entity) - Best enemy candidate

**Realm:** 🖥️ SERVER

**Selection Criteria:**
1. Highest priority (from `GetPriority()`)
2. If equal priority, closest distance

**Example:**
```lua
function ENT:OnUpdateEnemy()
    -- Override enemy selection
    return self:FetchEnemy()
end
```

**Source:** `lua/entities/drgbase_nextbot/ai.lua:128`

---

### ENT:UpdateEnemy 🖥️

```lua
ENT:UpdateEnemy()
```

Update current enemy (called automatically).

**Returns:**
- (Entity) - Updated enemy

**Realm:** 🖥️ SERVER

**Behavior:**
- Keeps nemesis if set
- Calls `OnUpdateEnemy()` hook
- Clears enemy if out of range
- Clears feared enemies if out of watch range

**Source:** `lua/entities/drgbase_nextbot/ai.lua:101`

---

## AI State

### ENT:IsAIDisabled

```lua
ENT:IsAIDisabled()
```

Check if AI is disabled.

**Returns:**
- (boolean) - True if AI disabled

**Realm:** 🌐 SHARED

**Note:** AI is disabled when possessed or by `ai_disabled` ConVar.

**Source:** `lua/entities/drgbase_nextbot/ai.lua:8`

---

### ENT:SetAIDisabled 🖥️

```lua
ENT:SetAIDisabled(disabled)
```

Enable or disable AI.

**Parameters:**
- `disabled` (boolean) - True to disable AI

**Realm:** 🖥️ SERVER

**Example:**
```lua
self:SetAIDisabled(true)   -- Disable AI
self:SetAIDisabled(false)  -- Enable AI
```

**Source:** `lua/entities/drgbase_nextbot/ai.lua:71`

---

### ENT:DisableAI 🖥️

```lua
ENT:DisableAI()
```

Disable AI (shortcut for `SetAIDisabled(true)`).

**Realm:** 🖥️ SERVER

**Source:** `lua/entities/drgbase_nextbot/ai.lua:78`

---

### ENT:EnableAI 🖥️

```lua
ENT:EnableAI()
```

Enable AI (shortcut for `SetAIDisabled(false)`).

**Realm:** 🖥️ SERVER

**Source:** `lua/entities/drgbase_nextbot/ai.lua:81`

---

## Detection & Vision

### ENT:IsInSight 🖥️

```lua
ENT:IsInSight(entity)
```

Check if entity is in field of view and visible.

**Parameters:**
- `entity` (Entity) - Entity to check

**Returns:**
- (boolean) - True if in sight

**Realm:** 🖥️ SERVER

**Checks:**
1. Not blind
2. Within sight range
3. Within FOV
4. Within luminosity range (for players)
5. Line of sight (not blocked)

**Example:**
```lua
if self:IsInSight(enemy) then
    self:PrimaryFire()
end
```

**Source:** `lua/entities/drgbase_nextbot/detection.lua:74`

---

### ENT:Visible 🖥️

```lua
ENT:Visible(entity)
```

Check if entity is visible (line of sight only, ignores FOV).

**Parameters:**
- `entity` (Entity) - Entity to check

**Returns:**
- (boolean) - True if visible (unobstructed)

**Realm:** 🖥️ SERVER

**Note:** This function is provided by Source engine. Use `IsInSight()` for full vision check.

---

### ENT:WasInSight

```lua
ENT:WasInSight(entity)
```

Check if entity was in sight last frame.

**Parameters:**
- `entity` (Entity) - Entity to check

**Returns:**
- (boolean) - True if was in sight

**Realm:** 🌐 SHARED

**Example:**
```lua
-- Client-side debug
if self:WasInSight(LocalPlayer()) then
    -- Draw indicator
end
```

---

### ENT:GetInSight 🖥️

```lua
ENT:GetInSight(disposition, spotted)
```

Get all entities in sight with given disposition.

**Parameters:**
- `disposition` (number/table, optional) - Relationship type(s)
- `spotted` (boolean, optional) - Only include spotted entities

**Returns:**
- (table) - Array of entities

**Realm:** 🖥️ SERVER

**Example:**
```lua
-- Get all enemies in sight
local enemies = self:GetEnemiesInSight()
for i, enemy in ipairs(enemies) do
    print("Can see:", enemy)
end

-- Get all entities in sight
local all = self:GetInSight()
```

**Source:** `lua/entities/drgbase_nextbot/detection.lua:97`

---

### ENT:GetEnemiesInSight 🖥️

```lua
ENT:GetEnemiesInSight(spotted)
```

Get all hated enemies in sight.

**Returns:**
- (table) - Array of enemy entities

**Realm:** 🖥️ SERVER

**Source:** `lua/entities/drgbase_nextbot/detection.lua:115`

---

### ENT:GetAlliesInSight 🖥️

```lua
ENT:GetAlliesInSight(spotted)
```

Get all allies in sight.

**Returns:**
- (table) - Array of ally entities

**Realm:** 🖥️ SERVER

**Source:** `lua/entities/drgbase_nextbot/detection.lua:112`

---

### ENT:GetHostilesInSight 🖥️

```lua
ENT:GetHostilesInSight(spotted)
```

Get all hostile entities (hated + feared) in sight.

**Returns:**
- (table) - Array of hostile entities

**Realm:** 🖥️ SERVER

**Source:** `lua/entities/drgbase_nextbot/detection.lua:121`

---

### ENT:GetAfraidOfInSight 🖥️

```lua
ENT:GetAfraidOfInSight(spotted)
```

Get all feared entities in sight.

**Returns:**
- (table) - Array of feared entities

**Realm:** 🖥️ SERVER

**Source:** `lua/entities/drgbase_nextbot/detection.lua:118`

---

### ENT:GetNeutralInSight 🖥️

```lua
ENT:GetNeutralInSight(spotted)
```

Get all neutral entities in sight.

**Returns:**
- (table) - Array of neutral entities

**Realm:** 🖥️ SERVER

**Source:** `lua/entities/drgbase_nextbot/detection.lua:124`

---

## Vision Properties

### ENT:GetSightFOV

```lua
ENT:GetSightFOV()
```

Get field of view in degrees.

**Returns:**
- (number) - FOV in degrees

**Realm:** 🌐 SHARED

---

### ENT:SetSightFOV 🖥️

```lua
ENT:SetSightFOV(degrees)
```

Set field of view.

**Parameters:**
- `degrees` (number) - FOV in degrees (0-360)

**Realm:** 🖥️ SERVER

**Example:**
```lua
self:SetSightFOV(90)   -- Narrow vision
self:SetSightFOV(180)  -- Wide vision
self:SetSightFOV(360)  -- See behind
```

**Source:** `lua/entities/drgbase_nextbot/detection.lua:51`

---

### ENT:GetSightRange

```lua
ENT:GetSightRange()
```

Get maximum sight distance.

**Returns:**
- (number) - Range in units

**Realm:** 🌐 SHARED

---

### ENT:SetSightRange 🖥️

```lua
ENT:SetSightRange(range)
```

Set maximum sight distance.

**Parameters:**
- `range` (number) - Distance in units

**Realm:** 🖥️ SERVER

**Source:** `lua/entities/drgbase_nextbot/detection.lua:56`

---

### ENT:GetSightLuminosityRange

```lua
ENT:GetSightLuminosityRange()
```

Get light level range for vision.

**Returns:**
- (number, number) - Min and max luminosity (0-1)

**Realm:** 🌐 SHARED

---

### ENT:SetSightLuminosityRange 🖥️

```lua
ENT:SetSightLuminosityRange(min, max)
```

Set light level range.

**Parameters:**
- `min` (number) - Minimum luminosity (0-1)
- `max` (number) - Maximum luminosity (0-1)

**Realm:** 🖥️ SERVER

**Example:**
```lua
-- Can only see in darkness
self:SetSightLuminosityRange(0, 0.3)

-- Can only see in bright light
self:SetSightLuminosityRange(0.7, 1)
```

**Source:** `lua/entities/drgbase_nextbot/detection.lua:60`

---

### ENT:IsBlind

```lua
ENT:IsBlind()
```

Check if NPC is blind.

**Returns:**
- (boolean) - True if blind

**Realm:** 🌐 SHARED

**Blind Conditions:**
- FOV is 0
- Sight range is 0
- Blind effect active (`GetCooldown("DrGBaseBlind")`)
- `drgbase_ai_sight` ConVar is 0

**Source:** `lua/entities/drgbase_nextbot/detection.lua:18`

---

## Hearing

### ENT:GetHearingCoefficient

```lua
ENT:GetHearingCoefficient()
```

Get hearing sensitivity.

**Returns:**
- (number) - Hearing coefficient (0-1+)

**Realm:** 🌐 SHARED

---

### ENT:SetHearingCoefficient 🖥️

```lua
ENT:SetHearingCoefficient(coefficient)
```

Set hearing sensitivity.

**Parameters:**
- `coefficient` (number) - Hearing sensitivity (0 = deaf, 1 = normal, 2+ = enhanced)

**Realm:** 🖥️ SERVER

**Example:**
```lua
self:SetHearingCoefficient(0)    -- Deaf
self:SetHearingCoefficient(1)    -- Normal hearing
self:SetHearingCoefficient(2)    -- Enhanced hearing
```

**Source:** `lua/entities/drgbase_nextbot/detection.lua:67`

---

### ENT:IsDeaf

```lua
ENT:IsDeaf()
```

Check if NPC is deaf.

**Returns:**
- (boolean) - True if deaf

**Realm:** 🌐 SHARED

**Source:** `lua/entities/drgbase_nextbot/detection.lua:27`

---

## Awareness & Memory

### ENT:HasSpotted 🖥️

```lua
ENT:HasSpotted(entity, absolute)
```

Check if NPC has spotted an entity.

**Parameters:**
- `entity` (Entity) - Entity to check
- `absolute` (boolean, optional) - Ignore omniscient mode

**Returns:**
- (boolean) - True if spotted

**Realm:** 🖥️ SERVER

**Note:** Omniscient NPCs are considered to have spotted all entities.

**Example:**
```lua
if self:HasSpotted(player) then
    print("Player spotted!")
end
```

**Source:** `lua/entities/drgbase_nextbot/awareness.lua:43`

---

### ENT:HasLost 🖥️

```lua
ENT:HasLost(entity, absolute)
```

Check if NPC has lost sight of an entity (was spotted, but not anymore).

**Parameters:**
- `entity` (Entity) - Entity to check
- `absolute` (boolean, optional) - Ignore omniscient mode

**Returns:**
- (boolean) - True if lost

**Realm:** 🖥️ SERVER

**Source:** `lua/entities/drgbase_nextbot/awareness.lua:49`

---

### ENT:GetSpotted 🖥️

```lua
ENT:GetSpotted()
```

Get all spotted entities.

**Returns:**
- (table) - Array of spotted entities

**Realm:** 🖥️ SERVER

**Source:** `lua/entities/drgbase_nextbot/awareness.lua:84`

---

### ENT:SpottedEntities 🖥️

```lua
ENT:SpottedEntities()
```

Get iterator for spotted entities.

**Returns:**
- (function) - Iterator function

**Realm:** 🖥️ SERVER

**Example:**
```lua
for entity in self:SpottedEntities() do
    print("Spotted:", entity)
end
```

**Source:** `lua/entities/drgbase_nextbot/awareness.lua:66`

---

### ENT:GetLost 🖥️

```lua
ENT:GetLost()
```

Get all lost entities (were spotted, but lost now).

**Returns:**
- (table) - Array of lost entities

**Realm:** 🖥️ SERVER

**Source:** `lua/entities/drgbase_nextbot/awareness.lua:91`

---

### ENT:LostEntities 🖥️

```lua
ENT:LostEntities()
```

Get iterator for lost entities.

**Returns:**
- (function) - Iterator function

**Realm:** 🖥️ SERVER

**Source:** `lua/entities/drgbase_nextbot/awareness.lua:75`

---

### ENT:LastTimeSpotted 🖥️

```lua
ENT:LastTimeSpotted(entity)
```

Get time when entity was last spotted.

**Parameters:**
- `entity` (Entity) - Entity to check

**Returns:**
- (number) - Time (CurTime) when last spotted, or -1

**Realm:** 🖥️ SERVER

**Example:**
```lua
local lastTime = self:LastTimeSpotted(enemy)
if CurTime() - lastTime < 5 then
    -- Spotted within last 5 seconds
end
```

**Source:** `lua/entities/drgbase_nextbot/awareness.lua:99`

---

### ENT:IsOmniscient

```lua
ENT:IsOmniscient()
```

Check if NPC can see through walls.

**Returns:**
- (boolean) - True if omniscient

**Realm:** 🌐 SHARED

**Source:** `lua/entities/drgbase_nextbot/awareness.lua:8`

---

### ENT:SetOmniscient 🖥️

```lua
ENT:SetOmniscient(omniscient)
```

Set omniscient mode.

**Parameters:**
- `omniscient` (boolean) - True for X-ray vision

**Realm:** 🖥️ SERVER

**Example:**
```lua
self:SetOmniscient(true)  -- Can see through walls
```

**Source:** `lua/entities/drgbase_nextbot/awareness.lua:36`

---

### ENT:GetSpotDuration

```lua
ENT:GetSpotDuration()
```

Get duration to remember spotted entities after losing sight.

**Returns:**
- (number) - Duration in seconds

**Realm:** 🌐 SHARED

---

### ENT:SetSpotDuration 🖥️

```lua
ENT:SetSpotDuration(duration)
```

Set spot memory duration.

**Parameters:**
- `duration` (number) - Seconds to remember

**Realm:** 🖥️ SERVER

**Example:**
```lua
self:SetSpotDuration(10)  -- Forgets after 10 seconds
self:SetSpotDuration(60)  -- Long memory
```

**Source:** `lua/entities/drgbase_nextbot/awareness.lua:39`

---

## AI Hooks

### ENT:OnNewEnemy

```lua
function ENT:OnNewEnemy(enemy)
```

Called when NPC spots a new enemy for the first time.

**Parameters:**
- `enemy` (Entity) - The new enemy

**Realm:** 🖥️ SERVER

**Example:**
```lua
function ENT:OnNewEnemy(enemy)
    self:EmitSound("npc/zombie/zombie_alert.wav")
    -- Alert nearby allies
end
```

**Source:** `lua/entities/drgbase_nextbot/ai.lua:44`

---

### ENT:OnEnemyChange

```lua
function ENT:OnEnemyChange(oldEnemy, newEnemy)
```

Called when enemy changes.

**Parameters:**
- `oldEnemy` (Entity) - Previous enemy
- `newEnemy` (Entity) - New enemy

**Realm:** 🖥️ SERVER

**Source:** `lua/entities/drgbase_nextbot/ai.lua:45`

---

### ENT:OnLastEnemy

```lua
function ENT:OnLastEnemy(enemy)
```

Called when NPC loses its last enemy.

**Parameters:**
- `enemy` (Entity) - The lost enemy

**Realm:** 🖥️ SERVER

**Example:**
```lua
function ENT:OnLastEnemy(enemy)
    -- Return to patrol
    self:AddPatrolPos(self:RandomPos(1000))
end
```

**Source:** `lua/entities/drgbase_nextbot/ai.lua:46`

---

### ENT:OnUpdateEnemy

```lua
function ENT:OnUpdateEnemy()
```

Called to select enemy. Return entity to override default selection.

**Returns:**
- (Entity, optional) - Enemy to use, or nil for default

**Realm:** 🖥️ SERVER

**Example:**
```lua
function ENT:OnUpdateEnemy()
    -- Always target closest player
    local closest = nil
    local closestDist = math.huge
    for _, ply in ipairs(player.GetAll()) do
        local dist = self:GetRangeTo(ply)
        if dist < closestDist then
            closest = ply
            closestDist = dist
        end
    end
    return closest
end
```

---

### ENT:OnFetchEnemy

```lua
function ENT:OnFetchEnemy(enemy1, enemy2)
```

Called to compare two enemy candidates. Return true to prefer enemy1.

**Parameters:**
- `enemy1` (Entity) - First candidate
- `enemy2` (Entity) - Second candidate

**Returns:**
- (boolean, optional) - True to prefer enemy1, false for enemy2, nil for default

**Realm:** 🖥️ SERVER

**Default Behavior:**
1. Higher priority preferred
2. If equal priority, closer enemy preferred

**Example:**
```lua
function ENT:OnFetchEnemy(enemy1, enemy2)
    -- Always prefer players over NPCs
    if enemy1:IsPlayer() and not enemy2:IsPlayer() then
        return true
    elseif enemy2:IsPlayer() and not enemy1:IsPlayer() then
        return false
    end
    -- Otherwise use default
end
```

---

## ConVars

### drgbase_ai_radius

**Default:** `5000`
**Type:** Replicated

Maximum distance to consider entities as potential enemies.

**Usage:**
```
drgbase_ai_radius 10000  -- Increase search radius
```

**Source:** `lua/entities/drgbase_nextbot/ai.lua:4`

---

### drgbase_ai_sight

**Default:** `1`
**Type:** Replicated

Enable/disable vision for all DrGBase NPCs.

**Usage:**
```
drgbase_ai_sight 0  -- Blind all NPCs
```

**Source:** `lua/entities/drgbase_nextbot/detection.lua:4`

---

### drgbase_ai_hearing

**Default:** `1`
**Type:** Replicated

Enable/disable hearing for all DrGBase NPCs.

**Usage:**
```
drgbase_ai_hearing 0  -- Deafen all NPCs
```

**Source:** `lua/entities/drgbase_nextbot/detection.lua:5`

---

### drgbase_ai_omniscient

**Default:** `0`
**Type:** Replicated

Make all NPCs omniscient (see through walls).

**Usage:**
```
drgbase_ai_omniscient 1  -- X-ray vision for all
```

**Source:** `lua/entities/drgbase_nextbot/awareness.lua:4`

---

## See Also

- **[Movement System](movement-system.md)** - Pathfinding and locomotion
- **[Relationships](relationships.md)** - Entity relationships
- **[Base Configuration](base-configuration.md)** - AI properties
