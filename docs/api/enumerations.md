# Enumerations

## Overview
DrGBase provides various enumerations (constants) for configuring NPC behavior, factions, and other settings.

**Source:** `lua/drgbase/enumerations.lua:1`

## Relationship Dispositions

Relationship types between entities.

```lua
D_HT  -- Hate
D_FR  -- Fear
D_LI  -- Like
D_NU  -- Neutral
D_ER  -- Error (unused)
```

### D_HT (Hate)

Value: `1`

Entities with this relationship will attack each other on sight.

**Usage:**
```lua
ENT.DefaultRelationship = D_HT  -- Hostile to everyone
self:SetRelationship(player.GetAll(), D_HT)  -- Hostile to players
```

**Behavior:**
- Attack on sight
- Chase until out of range
- Remember last known position

---

### D_FR (Fear)

Value: `2`

Entities will flee from targets with this relationship.

**Usage:**
```lua
self:SetRelationship(boss, D_FR)  -- Afraid of boss
ENT.DefaultRelationship = D_FR  -- Afraid of everything
```

**Behavior:**
- Flee when in range (`AvoidAfraidOfRange`)
- Watch from safe distance (`WatchAfraidOfRange`)
- May attack if cornered

---

### D_LI (Like)

Value: `3`

Entities are allies and will help each other.

**Usage:**
```lua
ENT.DefaultRelationship = D_LI  -- Friendly to everyone
self:SetRelationship(rebels, D_LI)  -- Ally with rebels
```

**Behavior:**
- Won't attack each other
- Share enemy information
- Defend allies when damaged

---

### D_NU (Neutral)

Value: `4`

Entities ignore each other unless provoked.

**Usage:**
```lua
ENT.DefaultRelationship = D_NU  -- Neutral to everyone
```

**Behavior:**
- Ignore by default
- May become hostile if damaged (based on `NeutralDamageTolerance`)

---

### D_ER (Error)

Value: `0`

Error state (unused in practice).

---

## Factions

Pre-defined faction constants for grouping NPCs.

### Half-Life 2 Factions

```lua
FACTION_REBELS      -- "FACTION_HL2_REBELS"
FACTION_COMBINE     -- "FACTION_HL2_COMBINE"
FACTION_ANIMALS     -- "FACTION_HL2_ANIMALS"
FACTION_ZOMBIES     -- "FACTION_HL2_ZOMBIES"
FACTION_ANTLIONS    -- "FACTION_HL2_ANTLIONS"
FACTION_GMAN        -- "FACTION_HL2_GMAN"
FACTION_BARNACLES   -- "FACTION_HL2_BARNACLES"
```

**Source:** `lua/drgbase/enumerations.lua:6`

#### FACTION_REBELS

Resistance fighters. Allies with players by default.

**Usage:**
```lua
ENT.Factions = {FACTION_REBELS}
ENT.DefaultRelationship = D_LI
```

**Compatible With:**
- Players
- Other rebels
- Friendly NPCs

---

#### FACTION_COMBINE

Combine military. Hostile to rebels and players.

**Usage:**
```lua
ENT.Factions = {FACTION_COMBINE}
ENT.DefaultRelationship = D_HT
```

---

#### FACTION_ZOMBIES

Zombies and headcrabs. Hostile to most entities.

**Usage:**
```lua
ENT.Factions = {FACTION_ZOMBIES}
ENT.DefaultRelationship = D_HT
```

---

#### FACTION_ANTLIONS

Antlion army. Typically hostile.

**Usage:**
```lua
ENT.Factions = {FACTION_ANTLIONS}
```

---

#### FACTION_ANIMALS

Wildlife (crows, seagulls, etc.). Usually neutral.

**Usage:**
```lua
ENT.Factions = {FACTION_ANIMALS}
ENT.DefaultRelationship = D_NU
```

---

#### FACTION_GMAN

G-Man faction. Special neutral faction.

---

#### FACTION_BARNACLES

Barnacle creatures.

---

### Half-Life 1 Factions

```lua
FACTION_XEN_ARMY      -- "FACTION_HL_XEN_ARMY"
FACTION_XEN_WILDLIFE  -- "FACTION_HL_XEN_WILDLIFE"
FACTION_HECU          -- "FACTION_HL_HECU"
FACTION_SANIC         -- "FACTION_SHITTY_SANIC_CLONES"
```

**Source:** `lua/drgbase/enumerations.lua:13`

#### FACTION_XEN_ARMY

Xen military (Alien Grunts, Controllers, Vortigaunts).

---

#### FACTION_XEN_WILDLIFE

Xen creatures (Headcrabs, Houndeyes, Bullsquids).

---

#### FACTION_HECU

Military soldiers (HECU Marines).

---

### Creating Custom Factions

```lua
-- Define globally
FACTION_MY_ROBOTS = "FACTION_CUSTOM_ROBOTS"

-- Use in NPC
ENT.Factions = {FACTION_MY_ROBOTS}
```

**Note:** Faction strings must be unique to avoid conflicts.

---

## AI Behavior Types

NPC AI modes.

```lua
AI_BEHAV_CUSTOM  -- 0
AI_BEHAV_BASE    -- 1
AI_BEHAV_HUMAN   -- 2
```

**Source:** `lua/drgbase/enumerations.lua:26`

### AI_BEHAV_BASE

Value: `1`

Standard NextBot AI behavior.

**Features:**
- Automatic enemy handling
- Patrol system
- Melee and ranged attacks
- No weapon support

**Usage:**
```lua
ENT.BehaviourType = AI_BEHAV_BASE
```

---

### AI_BEHAV_HUMAN

Value: `2`

Human-like AI with weapon support.

**Features:**
- All features of BASE
- Weapon handling
- Ammo management
- Reload behavior

**Usage:**
```lua
ENT.BehaviourType = AI_BEHAV_HUMAN
ENT.UseWeapons = true
ENT.Weapons = {"weapon_smg1", "weapon_ar2"}
```

**Requirements:**
- `ENT.UseWeapons = true`
- `ENT.Weapons` table configured

---

### AI_BEHAV_CUSTOM

Value: `0`

Custom AI behavior (override `AIBehaviour()`).

**Usage:**
```lua
ENT.BehaviourType = AI_BEHAV_CUSTOM

if SERVER then
    function ENT:AIBehaviour()
        while true do
            -- Custom AI loop
            if self:HasEnemy() then
                self:ChaseEnemy()
            else
                self:Patrol()
            end
            self:YieldCoroutine(true)
        end
    end
end
```

**Note:** You must implement the entire AI loop.

---

## Possession Movement Types

Player control modes when possessing NPCs.

```lua
POSSESSION_MOVE_CUSTOM   -- 0
POSSESSION_MOVE_8DIR     -- 1
POSSESSION_MOVE_NSEW     -- 1
POSSESSION_MOVE_COMPASS  -- 1
POSSESSION_MOVE_1DIR     -- 2
POSSESSION_MOVE_FORWARD  -- 2
POSSESSION_MOVE_4DIR     -- 3
```

**Source:** `lua/drgbase/enumerations.lua:18`

### POSSESSION_MOVE_8DIR / NSEW / COMPASS

Value: `1`

Eight-directional movement (WASD + diagonals).

**Usage:**
```lua
ENT.PossessionMovement = POSSESSION_MOVE_8DIR
```

**Controls:**
- W = North
- A = West
- S = South
- D = East
- Combinations = Diagonals (NW, NE, SW, SE)

---

### POSSESSION_MOVE_1DIR / FORWARD

Value: `2`

Forward-only movement.

**Usage:**
```lua
ENT.PossessionMovement = POSSESSION_MOVE_1DIR
```

**Controls:**
- W = Move forward
- A/D = Turn left/right
- S = Move backward

---

### POSSESSION_MOVE_4DIR

Value: `3`

Four-directional movement relative to camera.

**Usage:**
```lua
ENT.PossessionMovement = POSSESSION_MOVE_4DIR
```

**Controls:**
- W = Toward camera
- S = Away from camera
- A = Left relative to camera
- D = Right relative to camera

---

### POSSESSION_MOVE_CUSTOM

Value: `0`

Custom movement (implement your own).

**Usage:**
```lua
ENT.PossessionMovement = POSSESSION_MOVE_CUSTOM

if SERVER then
    function ENT:PossessionMove(possessor, cmd)
        -- Custom movement code
        local forward = cmd:GetForwardMove()
        local side = cmd:GetSideMove()
        -- ...
    end
end
```

---

## Patrol Types

Patrol behavior modes.

```lua
PATROL_POS     -- 0
PATROL_SEARCH  -- 100
PATROL_SOUND   -- 200
```

**Source:** `lua/drgbase/enumerations.lua:30`

### PATROL_POS

Value: `0`

Standard position patrol.

**Usage:**
```lua
self:AddPatrolPos(Vector(100, 200, 0))
```

---

### PATROL_SEARCH

Value: `100`

Search patrol (investigate area).

**Usage:**
```lua
self:AddPatrolPos(lastKnownEnemyPos, PATROL_SEARCH)
```

---

### PATROL_SOUND

Value: `200`

Sound investigation patrol.

**Usage:**
```lua
self:AddPatrolPos(soundOrigin, PATROL_SOUND)
```

---

## Node Types

Navmesh node types (for advanced pathfinding).

```lua
NODE_TYPE_GROUND  -- 2
NODE_TYPE_AIR     -- 3
NODE_TYPE_CLIMB   -- 4
NODE_TYPE_WATER   -- 5
```

**Source:** `lua/drgbase/enumerations.lua:1`

---

## Input Buttons

Additional input button not in GMod by default.

```lua
IN_ATTACK3  -- 33554432
```

**Source:** `lua/drgbase/enumerations.lua:34`

**Usage:**
```lua
ENT.PossessionBinds = {
    [IN_ATTACK3] = {{
        onkeydown = function(self)
            -- Special attack
        end
    }}
}
```

---

## Material Types

Used for footsteps and surface detection (from GMod engine).

Common material types:
```lua
MAT_CONCRETE
MAT_METAL
MAT_DIRT
MAT_WOOD
MAT_FLESH
MAT_SAND
MAT_GRASS
MAT_SNOW
MAT_TILE
MAT_GLASS
```

**Usage:**
```lua
ENT.Footsteps = {
    [MAT_CONCRETE] = {"player/footsteps/concrete1.wav"},
    [MAT_METAL] = {"player/footsteps/metal1.wav"}
}
```

---

## Blood Colors

Blood particle colors (from GMod engine).

```lua
BLOOD_COLOR_RED       -- Red blood (humans)
BLOOD_COLOR_YELLOW    -- Yellow blood (antlions)
BLOOD_COLOR_GREEN     -- Green blood (zombies, aliens)
BLOOD_COLOR_MECH      -- Sparks (robots)
DONT_BLEED            -- No blood
```

**Usage:**
```lua
ENT.BloodColor = BLOOD_COLOR_GREEN
```

---

## Damage Types

Damage type flags (from GMod engine).

Common types:
```lua
DMG_GENERIC
DMG_CRUSH
DMG_BULLET
DMG_SLASH
DMG_CLUB
DMG_BURN
DMG_VEHICLE
DMG_FALL
DMG_BLAST
DMG_SHOCK
DMG_SONIC
DMG_ENERGYBEAM
DMG_POISON
DMG_ACID
```

**Usage:**
```lua
self:Attack({
    damage = 10,
    type = DMG_SLASH
})
```

---

## See Also

- **[Global Functions](global-functions.md)** - DrGBase.* functions
- **[Entity Functions](entity-functions.md)** - ENT methods
- **[Base Configuration](base-configuration.md)** - Properties reference
