# Possession System Functions

Player possession of NPCs.

**File:** `lua/entities/drgbase_nextbot/possession.lua` (420 lines)

## Overview

The possession system allows players to take direct control of NPCs, moving them around and using custom abilities. Players can possess NPCs by looking at them and pressing the use key (E), then control them with standard movement keys and custom key bindings.

The system includes:
- Multiple camera view presets
- Configurable movement modes (8-direction, 4-direction, forward-only, custom)
- Lock-on targeting system
- Custom key bindings for abilities
- Automatic ladder and ledge climbing
- Hooks for custom possession behavior

## Possession Control

### ENT:Possess(player)

Makes a player possess (take control of) the NPC.

**Parameters:**
- `player` (Player): The player entity to possess the NPC

**Realm:** Server

**Returns:** (string) Status message:
- `"ok"` - Successfully possessed
- `"disabled"` - Possession not enabled on this NPC
- `"already possessed"` - NPC is already possessed
- `"invalid"` - Invalid player entity
- `"not player"` - Entity is not a player
- `"not alive"` - Player is not alive
- `"in vehicle"` - Player is in a vehicle
- `"already possessing"` - Player is already possessing another NPC
- `"not allowed"` - `ENT:CanPossess()` hook returned false

**Example:**
```lua
-- Make a player possess this NPC
local result = npc:Possess(ply)
if result ~= "ok" then
    print("Cannot possess: " .. result)
end
```

**Source:** `lua/entities/drgbase_nextbot/possession.lua:267`

**Notes:**
- Player's camera follows the NPC
- Player becomes invisible and non-solid
- Player's flashlight is disabled
- Previous player position is saved for unpossession
- Calls `ENT:OnPossessed(player)` hook after success
- Respects `ENT:CanPossess(player)` hook

---

### ENT:Dispossess()

Releases the player from possession, returning control to them.

**Realm:** Server

**Returns:** (string) Status message:
- `"ok"` - Successfully dispossessed
- `"not possessed"` - NPC is not currently possessed
- `"not allowed"` - `ENT:CanDispossess()` hook returned false

**Example:**
```lua
-- Release the player from control
npc:Dispossess()
```

**Source:** `lua/entities/drgbase_nextbot/possession.lua:294`

**Notes:**
- Player is returned to their original position (unless `drgbase_possession_teleport` is enabled)
- Player becomes visible and solid again
- Flashlight is re-enabled
- Calls `ENT:OnDispossessed(player)` hook after success
- Respects `ENT:CanDispossess(player)` hook

---

### ENT:IsPossessed()

Checks if the NPC is currently being possessed by a player.

**Realm:** Shared

**Returns:** (boolean) True if possessed

**Example:**
```lua
if self:IsPossessed() then
    print("Currently under player control")
end
```

**Source:** `lua/entities/drgbase_nextbot/possession.lua:12`

**Notes:**
- Available on both client and server
- Returns true if a valid player is possessing

---

### ENT:GetPossessor()

Gets the player entity currently possessing the NPC.

**Realm:** Shared

**Returns:** (Player) The possessing player, or NULL if not possessed

**Example:**
```lua
local possessor = self:GetPossessor()
if IsValid(possessor) then
    print(possessor:Nick() .. " is controlling this NPC")
end
```

**Source:** `lua/entities/drgbase_nextbot/possession.lua:9`

**Notes:**
- Returns NULL entity if not possessed
- Networked to all clients
- Always check with `IsValid()` before using

## Possession Settings

### ENT:SetPossessionEnabled(enabled)

Enables or disables possession for this NPC at runtime.

**Parameters:**
- `enabled` (boolean): True to allow possession, false to disable

**Realm:** Server

**Returns:** nil

**Example:**
```lua
-- Enable possession
self:SetPossessionEnabled(true)

-- Disable possession (automatically dispossesses if currently possessed)
self:SetPossessionEnabled(false)
```

**Source:** `lua/entities/drgbase_nextbot/possession.lua:250`

**Notes:**
- If disabled while possessed, automatically dispossesses the player
- Set initially from `ENT.PossessionEnabled` property
- Must be enabled for players to possess this NPC

---

### ENT:IsPossessionEnabled()

Checks if possession is enabled for this NPC.

**Realm:** Shared

**Returns:** (boolean) True if possession is enabled

**Example:**
```lua
if self:IsPossessionEnabled() then
    print("This NPC can be possessed")
end
```

**Source:** `lua/entities/drgbase_nextbot/possession.lua:4`

**Notes:**
- Networked to clients
- Does not check if currently possessed, only if possession is allowed

---

### ENT.PossessionMovement

**Type:** Number (Property)

Sets the movement mode for possession control.

**Values:**
- `POSSESSION_MOVE_CUSTOM (0)` - Custom controls via `ENT:PossessionControls()` hook
- `POSSESSION_MOVE_8DIR (1)` - 8-directional (WASD + diagonals)
- `POSSESSION_MOVE_NSEW (1)` - Alias for 8DIR
- `POSSESSION_MOVE_COMPASS (1)` - Alias for 8DIR
- `POSSESSION_MOVE_1DIR (2)` - Forward-facing only (camera direction)
- `POSSESSION_MOVE_FORWARD (2)` - Alias for 1DIR
- `POSSESSION_MOVE_4DIR (3)` - 4-directional, no diagonals

**Default:** `POSSESSION_MOVE_1DIR`

**Example:**
```lua
-- In your NPC's shared.lua
ENT.PossessionMovement = POSSESSION_MOVE_8DIR  -- Standard WASD movement
```

**Source:**
- Property: `lua/entities/drgbase_nextbot/shared.lua:128`
- Enums: `lua/drgbase/enumerations.lua:18`

**Notes:**
- Set as a property in your NPC's shared.lua file
- Cannot be changed at runtime (property only)
- Different modes provide different control schemes:
  - **8DIR**: Player can move in 8 directions, NPC faces camera direction
  - **4DIR**: Only N/S/E/W, no diagonals, locks to one direction at a time
  - **1DIR**: NPC always moves toward camera direction
  - **CUSTOM**: You implement movement in `ENT:PossessionControls()` hook

## Lock-On System

The lock-on system allows the NPC to automatically face and track a target while possessed, useful for combat scenarios.

### ENT:PossessionGetLockedOn()

Gets the entity currently locked on to.

**Realm:** Shared

**Returns:** (Entity) The locked-on entity, or NULL if no lock-on

**Example:**
```lua
local target = self:PossessionGetLockedOn()
if IsValid(target) then
    print("Locked onto: " .. tostring(target))
end
```

**Source:** `lua/entities/drgbase_nextbot/possession.lua:40`

**Notes:**
- Returns NULL if not possessed or no target locked
- Networked to clients
- Target is automatically tracked by movement system

---

### ENT:PossessionLockOn(target)

Locks on to a target entity or clears the lock-on.

**Parameters:**
- `target` (Entity): Entity to lock on to, or NULL/nil to clear

**Realm:** Server

**Returns:** nil

**Example:**
```lua
-- Lock onto an enemy
local enemy = self:GetEnemy()
self:PossessionLockOn(enemy)

-- Clear lock-on
self:PossessionLockOn(NULL)
```

**Source:** `lua/entities/drgbase_nextbot/possession.lua:256`

**Notes:**
- Only works when NPC is possessed
- When locked on, NPC faces the target while moving
- `ENT:PossessorForward()` returns direction to locked target
- Lock-on is cleared when target becomes invalid

---

### ENT:PossessionFetchLockOn()

**Hook:** Finds and returns an entity to automatically lock onto.

**Realm:** Server

**Returns:** (Entity) Entity to lock onto, or nil for no lock

**Default Behavior:**
- Returns closest visible hostile entity
- Returns nil if no valid hostiles

**Example:**
```lua
-- Override to lock onto nearest NPC regardless of relationship
function ENT:PossessionFetchLockOn()
    local npcs = ents.FindByClass("npc_*")
    local closest = nil
    local closestDist = math.huge

    for _, npc in ipairs(npcs) do
        if npc ~= self and self:Visible(npc) then
            local dist = self:GetRangeTo(npc)
            if dist < closestDist then
                closest = npc
                closestDist = dist
            end
        end
    end

    return closest
end
```

**Source:** `lua/entities/drgbase_nextbot/possession.lua:341`

**Notes:**
- Called automatically by possession system
- Override to customize lock-on targeting behavior
- Return nil to disable automatic lock-on

---

## Camera Views

### ENT.PossessionViews

**Type:** Table (Property)

Defines camera positions for possession view. Players can cycle through views.

**Structure:**
```lua
{
    {
        offset = Vector(x, y, z),  -- Offset from camera origin
        distance = number,          -- Distance behind NPC
        eyepos = boolean,           -- Use eye position as origin (optional)
        bone = "bone_name",         -- Use bone position as origin (optional)
        auto = boolean,             -- Use automatic positioning (optional)
    },
    -- Additional view presets...
}
```

**Example:**
```lua
ENT.PossessionViews = {
    -- Third person view
    {
        offset = Vector(0, 30, 20),
        distance = 100
    },
    -- Close follow cam
    {
        offset = Vector(0, 0, 50),
        distance = 80
    },
    -- Eye level view
    {
        eyepos = true,
        offset = Vector(0, 0, 0),
        distance = 0
    }
}
```

**Source:** `lua/entities/drgbase_nextbot/shared.lua:129`

**Notes:**
- Empty table disables view cycling
- Offsets are relative to chosen origin point
- Distance is how far back the camera pulls
- Players cycle views with a default keybind

---

### ENT:CurrentViewPreset()

Gets the current active view preset.

**Realm:** Shared

**Returns:**
- `index` (number): View index (or -1 if none)
- `preset` (table): View preset table (or nil)

**Example:**
```lua
local idx, view = self:CurrentViewPreset()
if idx ~= -1 then
    print("Using view preset " .. idx)
end
```

**Source:** `lua/entities/drgbase_nextbot/possession.lua:20`

---

### ENT:CycleViewPresets()

Cycles to the next camera view preset.

**Realm:** Shared (networked if called on client)

**Returns:** nil

**Example:**
```lua
-- Bind to a key to manually cycle views
function ENT:OnPossessionKeyPress()
    self:CycleViewPresets()
end
```

**Source:** `lua/entities/drgbase_nextbot/possession.lua:26`

**Notes:**
- Wraps around to first view after last
- Does nothing if no views configured

---

## Possession Bindings

### ENT.PossessionBinds

**Type:** Table (Property)

Maps keys to custom actions while possessed. Supports multiple callbacks per key.

**Structure:**
```lua
{
    [KEY_CONSTANT] = {
        {
            coroutine = boolean,           -- Run in coroutine (default: false)
            client = boolean,              -- Run on client (default: false)
            onkeydown = function(self, ply),      -- Held down
            onkeyup = function(self, ply),        -- Not pressed
            onkeypressed = function(self, ply),   -- Just pressed
            onkeydownlast = function(self, ply),  -- Down last tick
            onkeyreleased = function(self, ply),  -- Just released
            onbuttondown = function(self, ply),   -- Button down (uses DrG_ButtonDown)
            onbuttonup = function(self, ply),     -- Button up
            onbuttonpressed = function(self, ply),   -- Button pressed
            onbuttonreleased = function(self, ply),  -- Button released
        },
        -- Multiple bindings per key allowed
    },
    ["convar_name"] = { ... }  -- Can also use ConVar names instead of KEY constants
}
```

**Example:**
```lua
ENT.PossessionBinds = {
    -- Primary attack
    [IN_ATTACK] = {{
        coroutine = true,
        onkeydown = function(self, ply)
            self:EmitSound("Zombie.Attack")
            self:PlayActivityAndMove(ACT_MELEE_ATTACK1, 1, self.PossessionFaceForward)
        end
    }},

    -- Jump
    [IN_JUMP] = {{
        coroutine = false,
        onkeypressed = function(self, ply)
            if self:IsOnGround() then
                self:Jump(100)
            end
        end
    }},

    -- Special ability on custom key
    ["drgbase_special_ability"] = {{  -- ConVar name
        onkeydown = function(self, ply)
            self:SpecialAbility()
        end
    }}
}
```

**Source:** `lua/entities/drgbase_nextbot/shared.lua:130`

**Available Key Constants:**
- `IN_ATTACK`, `IN_ATTACK2`, `IN_ATTACK3` - Mouse buttons
- `IN_JUMP`, `IN_DUCK`, `IN_FORWARD`, `IN_BACK`, `IN_MOVELEFT`, `IN_MOVERIGHT`
- `IN_RELOAD`, `IN_SPEED`, `IN_WALK`, `IN_USE`
- `KEY_*` constants (e.g., `KEY_E`, `KEY_R`)

**Callback Types:**
- **onkeydown** - Called every tick while key is held
- **onkeyup** - Called every tick while key is NOT held
- **onkeypressed** - Called once when key is first pressed
- **onkeyreleased** - Called once when key is released
- **onkeydownlast** - Called if key was down on previous tick
- **onbutton*** - Alternative input system using DrG_Button functions

**Notes:**
- `coroutine = true` allows yielding (required for `PlayActivityAndMove`, `PauseCoroutine`, etc.)
- Multiple bindings can share the same key
- ConVar names let players rebind keys
- Client-side bindings run on client (useful for visual effects)

---

## Helper Functions

### ENT:IsPossessor(ent)

Checks if a specific entity is the possessor.

**Parameters:**
- `ent` (Entity): Entity to check

**Realm:** Shared

**Returns:** (boolean) True if ent is possessing this NPC

**Source:** `lua/entities/drgbase_nextbot/possession.lua:15`

---

### ENT:IsPossessedByLocalPlayer()

Client-side check if local player is possessing this NPC.

**Realm:** Client

**Returns:** (boolean) True if local player is possessing

**Source:** `lua/entities/drgbase_nextbot/possession.lua:381`

---

### ENT:PossessorView()

Gets the camera position and angles for the possessed view.

**Realm:** Shared

**Returns:**
- `position` (Vector): Camera position
- `angles` (Angle): Camera angles

**Source:** `lua/entities/drgbase_nextbot/possession.lua:47`

---

### ENT:PossessorTrace([options])

Performs a trace from the possessor's viewpoint.

**Parameters:**
- `options` (table, optional): Trace options (same as util.TraceLine)

**Realm:** Shared

**Returns:** (table) Trace result

**Example:**
```lua
local tr = self:PossessorTrace()
print("Looking at: " .. tostring(tr.Entity))
```

**Source:** `lua/entities/drgbase_nextbot/possession.lua:83`

---

### ENT:PossessorNormal()

Gets the forward direction vector of possessor's camera.

**Realm:** Shared

**Returns:** (Vector) Forward direction (not normalized)

**Source:** `lua/entities/drgbase_nextbot/possession.lua:92`

---

### ENT:PossessorForward()

Gets the forward movement direction, accounting for lock-on.

**Realm:** Shared

**Returns:** (Vector) Normalized forward direction

**Source:** `lua/entities/drgbase_nextbot/possession.lua:97`

**Notes:**
- If locked onto target, returns direction to target (Z set to 0)
- Otherwise returns camera forward with Z set to 0

---

### ENT:PossessorRight()

Gets the right movement direction.

**Realm:** Shared

**Returns:** (Vector) Normalized right direction

**Source:** `lua/entities/drgbase_nextbot/possession.lua:111`

---

### ENT:PossessorUp()

Gets the up direction vector.

**Realm:** Shared

**Returns:** (Vector) Up vector (always `Vector(0, 0, 1)`)

**Source:** `lua/entities/drgbase_nextbot/possession.lua:118`

---

## Movement Functions

### ENT:PossessionFaceForward()

Makes the NPC face the possessor's look direction or locked target.

**Realm:** Server

**Returns:** nil

**Source:** `lua/entities/drgbase_nextbot/possession.lua:314`

---

### ENT:PossessionMoveForward()

Moves the NPC forward relative to possessor direction.

**Realm:** Server

**Returns:** nil

**Source:** `lua/entities/drgbase_nextbot/possession.lua:322`

---

### ENT:PossessionMoveBackward()

Moves the NPC backward relative to possessor direction.

**Realm:** Server

**Returns:** nil

**Source:** `lua/entities/drgbase_nextbot/possession.lua:325`

---

### ENT:PossessionMoveRight()

Moves the NPC right relative to possessor direction.

**Realm:** Server

**Returns:** nil

**Source:** `lua/entities/drgbase_nextbot/possession.lua:328`

---

### ENT:PossessionMoveLeft()

Moves the NPC left relative to possessor direction.

**Realm:** Server

**Returns:** nil

**Source:** `lua/entities/drgbase_nextbot/possession.lua:331`

---

## Hooks

### ENT:CanPossess(player)

**Hook:** Check if a player is allowed to possess this NPC.

**Parameters:**
- `player` (Player): The player attempting possession

**Realm:** Server

**Returns:** (boolean) True to allow, false to deny

**Default:** Returns true

**Example:**
```lua
function ENT:CanPossess(player)
    -- Only admins can possess boss NPCs
    return player:IsAdmin()
end
```

**Source:** `lua/entities/drgbase_nextbot/possession.lua:337`

---

### ENT:CanDispossess(player)

**Hook:** Check if dispossession is allowed.

**Parameters:**
- `player` (Player): The player being dispossessed

**Realm:** Server

**Returns:** (boolean) True to allow, false to deny

**Default:** Returns true

**Example:**
```lua
function ENT:CanDispossess(player)
    -- Can't exit during combat
    return not self:HasEnemy()
end
```

**Source:** `lua/entities/drgbase_nextbot/possession.lua:338`

---

### ENT:OnPossessed(player)

**Hook:** Called when a player successfully possesses this NPC.

**Parameters:**
- `player` (Player): The possessing player

**Realm:** Shared

**Example:**
```lua
function ENT:OnPossessed(player)
    self:EmitSound("npc/scanner/scanner_talk1.wav")
    if SERVER then
        self:SetHealthRegen(5)  -- Regen while possessed
    end
end
```

**Source:** `lua/entities/drgbase_nextbot/possession.lua:124`

---

### ENT:OnDispossessed(player)

**Hook:** Called when a player is released from possession.

**Parameters:**
- `player` (Player): The previously possessing player

**Realm:** Shared

**Example:**
```lua
function ENT:OnDispossessed(player)
    if SERVER then
        self:SetHealthRegen(0)
    end
end
```

**Source:** `lua/entities/drgbase_nextbot/possession.lua:125`

---

### ENT:OnPossession()

**Hook:** Called every think tick while possessed (coroutine context).

**Realm:** Server (Coroutine)

**Returns:** (boolean) Return true to skip default movement handling

**Example:**
```lua
function ENT:OnPossession()
    -- Custom logic each tick
    if self:Health() < 50 then
        self:SetHealthRegen(2)
    end
    return false  -- Don't skip default movement
end
```

**Source:** `lua/entities/drgbase_nextbot/possession.lua:339`

---

### ENT:PossessionControls(forward, backward, right, left)

**Hook:** Custom movement controls when `PossessionMovement = POSSESSION_MOVE_CUSTOM`.

**Parameters:**
- `forward` (boolean): W key pressed
- `backward` (boolean): S key pressed
- `right` (boolean): D key pressed
- `left` (boolean): A key pressed

**Realm:** Server

**Example:**
```lua
ENT.PossessionMovement = POSSESSION_MOVE_CUSTOM

function ENT:PossessionControls(forward, backward, right, left)
    -- Custom tank controls: forward/back and left/right to turn
    if forward then
        self:Approach(self:GetPos() + self:GetForward() * 100)
    end
    if left then
        self:SetAngles(self:GetAngles() + Angle(0, 5, 0))
    end
end
```

**Source:** `lua/entities/drgbase_nextbot/possession.lua:340`

---

### ENT:PossessionHUD()

**Hook (Client):** Custom HUD rendering while possessing this NPC.

**Realm:** Client

**Returns:** (boolean) Return true to skip default HUD

**Example:**
```lua
function ENT:PossessionHUD()
    -- Draw custom health bar
    draw.SimpleText(
        "Health: " .. self:Health(),
        "DermaDefault",
        ScrW() / 2, ScrH() - 50,
        Color(255, 255, 255),
        TEXT_ALIGN_CENTER
    )
    return false  -- Show default HUD too
end
```

**Source:** `lua/entities/drgbase_nextbot/possession.lua:389`

---

### ENT:PossessionRender()

**Hook (Client):** Custom screen space effects while possessing.

**Realm:** Client

**Example:**
```lua
function ENT:PossessionRender()
    -- Apply vignette effect
    DrawMotionBlur(0.1, 0.8, 0.01)
end
```

**Source:** `lua/entities/drgbase_nextbot/possession.lua:400`

---

### ENT:PossessionHalos()

**Hook (Client):** Draw halos around entities while possessing.

**Realm:** Client

**Example:**
```lua
function ENT:PossessionHalos()
    local enemies = self:GetNearbyEnemies(1000)
    halo.Add(enemies, Color(255, 0, 0), 2, 2, 2, true, true)
end
```

**Source:** `lua/entities/drgbase_nextbot/possession.lua:409`

---

## Related Configuration

Properties that configure possession:

```lua
ENT.PossessionEnabled = false              -- Enable possession
ENT.PossessionPrompt = true                -- Show "Press E to possess" hint
ENT.PossessionCrosshair = false            -- Show crosshair while possessed
ENT.PossessionMovement = POSSESSION_MOVE_1DIR  -- Movement mode
ENT.PossessionViews = {}                   -- Camera view presets
ENT.PossessionBinds = {}                   -- Key bindings
```

See [Base Configuration](../base-configuration.md#possession)

---

## Client ConVars

- `drgbase_possession_teleport` (0/1) - Teleport to NPC on dispossess instead of returning to start position

---

## See Also

- **[Player Extensions](../core/player-extensions.md)** - Player possession helper functions
- **[Base Configuration](../base-configuration.md)** - Possession properties
- **[Possession Guide](../../guides/possession.md)** - Complete possession tutorial

---

See [Possession Guide](../../guides/possession.md)
