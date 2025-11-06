# Configuration & ConVars

DrGBase provides extensive ConVars (console variables) for server-wide configuration, debugging, and performance tuning.

## Server ConVars

### AI & Detection System

#### `drgbase_ai_radius`
- **Default:** `5000`
- **Description:** Maximum distance (in units) at which NPCs can detect and process AI for entities. NPCs won't consider entities beyond this radius for enemy detection or awareness.
- **Usage:** Lower values improve performance on large servers but reduce NPC awareness range. Higher values allow NPCs to detect threats from further away.
- **Recommended:** 3000-5000 for most servers, 8000+ for singleplayer/testing

#### `drgbase_ai_sight`
- **Default:** `1` (enabled)
- **Description:** Global toggle for the vision/sight system. When disabled, all NPCs become completely blind and cannot use their vision to detect entities.
- **Usage:** Disable for testing hearing-only AI behavior or to improve performance in specific scenarios.

#### `drgbase_ai_hearing`
- **Default:** `1` (enabled)
- **Description:** Global toggle for the hearing system. When disabled, all NPCs become completely deaf and cannot detect sound events.
- **Usage:** Disable for testing vision-only AI behavior or to reduce AI processing load.

#### `drgbase_ai_omniscient`
- **Default:** `0` (disabled)
- **Description:** Makes all NPCs omniscient - they instantly know about all entities in range without needing to see or hear them. Bypasses normal detection systems.
- **Usage:** Enable for testing, debugging, or creating NPCs that should always know where players are (like in horror games).
- **Warning:** Significantly changes gameplay balance.

#### `drgbase_ai_patrol`
- **Default:** `1` (enabled)
- **Description:** Global toggle for the patrol system. When disabled, NPCs won't follow patrol paths even if configured to do so.
- **Usage:** Disable if you don't use patrol paths to save minor processing overhead.

### Possession System

#### `drgbase_possession_enable`
- **Default:** `1` (enabled)
- **Description:** Enables or disables the possession system globally. When enabled, players can right-click NPCs with the context menu and select "Possess" to take control.
- **Usage:** Disable on roleplay servers where possession would break immersion, or on competitive servers where it would be unfair.

#### `drgbase_possession_allow_lockon`
- **Default:** `1` (enabled)
- **Description:** Allows players to use the lock-on targeting system while possessing NPCs. Lock-on automatically aims the camera at nearby enemies.
- **Usage:** Disable to make possession more challenging, or if you find the lock-on mechanic too powerful.

#### `drgbase_possession_targetall`
- **Default:** `1` (enabled)
- **Description:** When enabled, the lock-on system can target all entities. When disabled, it only targets hostile entities.
- **Usage:** Disable to make lock-on only work on enemies, improving tactical gameplay.

### Weapon System

#### `drgbase_give_weapons`
- **Default:** `1` (enabled)
- **Description:** Allows players to give weapons to NPCs using the context menu or weapon system.
- **Usage:** Disable on servers where you don't want players modifying NPC loadouts, or for balance reasons.

### Performance & Optimization

#### `drgbase_precache_models`
- **Default:** `1` (enabled)
- **Description:** Precaches all NPC models when the server starts, reducing stutter when NPCs first spawn.
- **Performance Impact:** Increases initial loading time but eliminates mid-game stuttering. Recommended to keep enabled unless you have severe startup performance issues.

#### `drgbase_precache_sounds`
- **Default:** `1` (enabled)
- **Description:** Precaches all NPC sounds when the server starts, reducing audio lag when sounds first play.
- **Performance Impact:** Similar to model precaching - longer initial load but smoother gameplay. Keep enabled for best experience.

#### `drgbase_projectile_tickrate`
- **Default:** `-1` (every tick)
- **Description:** Controls how often projectiles update their physics and movement.
- **Values:**
  - `-1`: Update every server tick (most accurate, highest performance cost)
  - `0`: Use Think function (standard update rate)
  - Positive number: Update every N seconds (e.g., `0.033` for ~30 updates/sec)
- **Usage:** Increase value to improve performance on servers with many projectiles, at the cost of accuracy.

### Movement System

#### `drgbase_compute_delay`
- **Default:** `0.1` (seconds)
- **Description:** Delay between pathfinding computations. NPCs recalculate their path to targets at this interval.
- **Usage:** Increase for better performance but less responsive pathfinding. Decrease for more reactive NPCs but higher CPU usage.
- **Recommended:** 0.05-0.2 depending on server load

#### `drgbase_avoid_obstacles`
- **Default:** `1` (enabled)
- **Description:** Enables obstacle avoidance system for NPC movement.
- **Usage:** Disable if you experience pathfinding issues or want simpler movement behavior.

#### `drgbase_multiplier_speed`
- **Default:** `1.0`
- **Description:** Global multiplier for all NPC movement speeds. Affects walk, run, and sprint speeds.
- **Usage:** Set to 0.5 for slower NPCs, 2.0 for faster NPCs, etc. Useful for difficulty adjustment or testing.

### Damage & Health System

#### `drgbase_multiplier_damage_players`
- **Default:** `1.0`
- **Description:** Multiplies all damage dealt TO players by NPCs.
- **Usage:** Reduce for easier gameplay (0.5 = half damage), increase for harder gameplay (2.0 = double damage).

#### `drgbase_multiplier_damage_npc`
- **Default:** `1.0`
- **Description:** Multiplies all damage dealt TO NPCs (by players and other NPCs).
- **Usage:** Increase to make NPCs easier to kill, decrease to make them tankier.

#### `drgbase_multiplier_health`
- **Default:** `1.0`
- **Description:** Multiplies the spawn health of all NPCs globally.
- **Usage:** Set to 2.0 to double all NPC health, 0.5 to halve it, etc. Useful for quick difficulty adjustments.

#### `drgbase_remove_dead`
- **Default:** `0` (disabled)
- **Description:** Removes dead NPCs immediately instead of creating ragdolls.
- **Usage:** Enable to reduce entity count and improve performance on servers with many NPCs dying frequently.

### Ragdoll System

#### `drgbase_ragdoll_collisions_disabled`
- **Default:** `0` (disabled)
- **Description:** Disables collisions for NPC ragdolls. When enabled, ragdolls won't collide with the world or other entities.
- **Usage:** Enable to improve performance when many NPCs die, or to prevent ragdoll physics from causing issues.

#### `drgbase_remove_ragdolls`
- **Default:** `-1` (never)
- **Description:** Automatically removes ragdolls after the specified number of seconds. `-1` means ragdolls persist until manually removed or map cleanup.
- **Values:**
  - `-1`: Never auto-remove
  - `0`: Remove immediately
  - Positive number: Remove after N seconds (e.g., `30` for 30 seconds)
- **Usage:** Set to 10-30 seconds to keep servers clean and improve performance in high-combat scenarios.

#### `drgbase_ragdoll_fadeout`
- **Default:** `3` (seconds)
- **Description:** Duration of the fade-out effect before ragdolls are removed. Only applies if `drgbase_remove_ragdolls` is set.
- **Usage:** Lower for quicker cleanup, higher for more natural-looking removal.

### Player System

#### `drgbase_update_luminosity`
- **Default:** `1` (enabled)
- **Description:** Enables the player luminosity system, which tracks how bright the area around each player is. NPCs use this for stealth detection - players in darker areas are harder to detect.
- **Usage:** Disable if you don't want light-based stealth mechanics, or to save minor performance overhead.

### Debug & Visualization

#### `drgbase_debug_traces`
- **Default:** `0` (disabled)
- **Description:** Visualizes trace lines used for line-of-sight checks and detection. Shows red/green lines indicating what NPCs can or cannot see.
- **Usage:** Enable when debugging why NPCs can't see certain targets, or when troubleshooting vision issues.

#### `drgbase_debug_relationships`
- **Default:** `0` (disabled)
- **Description:** Prints detailed relationship and faction information to console when NPCs evaluate targets.
- **Usage:** Enable when debugging faction systems, relationship priorities, or unexpected targeting behavior.

#### `drgbase_debug_trajectories`
- **Default:** `0` (disabled)
- **Description:** Visualizes projectile trajectory predictions and physics calculations.
- **Usage:** Enable when debugging projectile weapons, aiming, or ballistic calculations.

#### `drgbase_debug_animations`
- **Default:** `0` (disabled)
- **Description:** Prints animation state changes and sequence information to console.
- **Usage:** Enable when debugging animation issues, gesture layers, or sequence transitions.

#### `drgbase_nodegraph_display`
- **Default:** `0` (disabled)
- **Description:** Displays the navigation nodegraph as wireframe boxes in the world. **Requires `developer 1` to be set.**
- **Usage:** Enable when creating or debugging custom navigation nodes, or troubleshooting pathfinding.

#### `drgbase_nodegraph_distance`
- **Default:** `1500` (units)
- **Description:** Maximum distance from your crosshair position to display nodegraph nodes.
- **Usage:** Increase to see more nodes at once, decrease for less visual clutter.

#### `drgbase_nodegraph_type`
- **Default:** `2` (climb)
- **Description:** Which type of nodes to display.
- **Values:**
  - `0`: Ground nodes (green)
  - `1`: Air nodes (cyan)
  - `2`: Climb nodes (purple)
  - `3`: Water nodes (blue)
- **Usage:** Change based on which node type you're working with or debugging.

#### `drgbase_nodegraph_transparent`
- **Default:** `0` (opaque)
- **Description:** Renders nodegraph visualization with transparency, allowing you to see through nodes.
- **Usage:** Enable when nodes are obscuring your view or when you need to see what's behind them.

## Client ConVars

Client ConVars are set per-player and stored in their client-side configuration.

### Possession Controls

These ConVars define which keys control possession mode. Set them to key codes (e.g., `KEY_E`, `KEY_V`) or use `bind` commands.

#### `drgbase_possession_exit`
- **Default:** `KEY_E` (E key)
- **Description:** Key to exit possession mode and return to normal player control.
- **Usage:** Change if E conflicts with other binds or personal preference.

#### `drgbase_possession_view`
- **Default:** `KEY_V` (V key)
- **Description:** Key to cycle through camera view presets while possessing an NPC.
- **Usage:** Cycle through first-person, third-person, and other custom camera positions.

#### `drgbase_possession_climb`
- **Default:** `KEY_C` (C key)
- **Description:** Key to make possessed NPC climb (if climbing is enabled for that NPC).
- **Usage:** Used in combination with movement keys to climb walls or obstacles.

#### `drgbase_possession_lockon`
- **Default:** `KEY_L` (L key)
- **Description:** Key to toggle lock-on targeting while possessing. Automatically aims at the nearest valid target.
- **Usage:** Press to lock onto enemies, press again to cycle targets or unlock.

#### `drgbase_possession_lockon_speed`
- **Default:** `0.05`
- **Description:** Camera rotation speed when locked onto a target. This is a lerp factor (0.0-1.0), where higher values make the camera snap faster.
- **Range:** `0.01` (very slow) to `1.0` (instant)
- **Usage:** Decrease for smoother camera movement, increase for more responsive targeting.

#### `drgbase_possession_teleport`
- **Default:** `0` (disabled)
- **Description:** **Developer option.** Enables teleporting while in possession mode.
- **Usage:** For testing and development only. Not recommended for normal gameplay.

### Client Debug Options

#### `drgbase_navmesh_error`
- **Default:** `1` (enabled)
- **Description:** Shows error messages when navigation mesh (navmesh) issues are detected.
- **Usage:** Disable if navmesh warnings are spamming your console on maps with incomplete navmeshes.

#### `drgbase_display_collisions`
- **Default:** `0` (disabled)
- **Description:** Displays collision bounds as wireframe boxes around NPCs.
- **Usage:** Enable when debugging collision issues or hull sizes.

#### `drgbase_display_sight`
- **Default:** `0` (disabled)
- **Description:** Displays vision cones and sight ranges for NPCs.
- **Usage:** Enable to visualize what NPCs can see, useful for understanding detection mechanics.

#### `drgbase_adjust_ragdoll_attachments`
- **Default:** `0` (disabled)
- **Description:** **Developer option.** Adjusts attachment point positions on ragdolls.
- **Usage:** For advanced ragdoll setup and debugging only.

## Setting ConVars

### In Console

```
drgbase_ai_radius 8000
```

### In server.cfg

```
// DrGBase Configuration
drgbase_ai_radius 5000
drgbase_possession_enable 1
drgbase_give_weapons 1
```

### Via Lua

```lua
RunConsoleCommand("drgbase_ai_radius", "5000")
```

### Via RCON

```
rcon drgbase_ai_radius 5000
```

## Recommended Configurations

Below are recommended ConVar configurations for different server types and scenarios.

### High Performance / Large Server (20+ players)

Optimized for servers with many players and NPCs, prioritizing performance over visual fidelity:

```
// AI Performance
drgbase_ai_radius 3000
drgbase_compute_delay 0.15
drgbase_avoid_obstacles 1

// Precaching
drgbase_precache_models 1
drgbase_precache_sounds 1

// Ragdoll Cleanup
drgbase_remove_ragdolls 15
drgbase_ragdoll_fadeout 2
drgbase_ragdoll_collisions_disabled 1

// Projectiles
drgbase_projectile_tickrate 0.033

// Other
drgbase_update_luminosity 0
```

### Single Player / Testing / Development

Maximum features enabled for testing and debugging:

```
// AI - Extended Range
drgbase_ai_radius 8000
drgbase_compute_delay 0.05

// Debug Visualization
drgbase_debug_traces 1
drgbase_debug_relationships 1
drgbase_debug_animations 0
developer 1
drgbase_nodegraph_display 0  // Enable when needed

// Possession
drgbase_possession_enable 1
drgbase_possession_allow_lockon 1

// No Performance Limits
drgbase_projectile_tickrate -1
drgbase_ragdoll_collisions_disabled 0
```

### Roleplay / Serious RP Server

Balanced for immersive roleplay with limited exploits:

```
// Disable Gamey Features
drgbase_possession_enable 0
drgbase_give_weapons 0

// Standard AI
drgbase_ai_radius 4000
drgbase_ai_sight 1
drgbase_ai_hearing 1

// Balanced Difficulty
drgbase_multiplier_health 1.0
drgbase_multiplier_damage_players 1.0
drgbase_multiplier_speed 1.0

// Ragdoll Persistence
drgbase_remove_ragdolls 60
drgbase_ragdoll_fadeout 5
```

### Sandbox / Creative / Fun Server

All features enabled for maximum player freedom:

```
// Full Features
drgbase_possession_enable 1
drgbase_possession_allow_lockon 1
drgbase_possession_targetall 1
drgbase_give_weapons 1

// Standard AI
drgbase_ai_radius 5000
drgbase_ai_patrol 1

// Auto Cleanup
drgbase_remove_ragdolls 30
drgbase_ragdoll_fadeout 3
```

### PvE / Cooperative / Survival

Challenging NPC encounters for cooperative gameplay:

```
// Increased Difficulty
drgbase_multiplier_health 1.5
drgbase_multiplier_damage_players 1.25
drgbase_multiplier_damage_npc 0.8
drgbase_multiplier_speed 1.1

// Extended AI Range
drgbase_ai_radius 6000
drgbase_compute_delay 0.08

// Stealth Mechanics
drgbase_update_luminosity 1

// Possession for Fun
drgbase_possession_enable 1
drgbase_possession_allow_lockon 0  // More challenging
```

### Low-End Hardware / Optimization

Minimum settings for older servers or limited hardware:

```
// Reduced AI Load
drgbase_ai_radius 2500
drgbase_compute_delay 0.2
drgbase_ai_patrol 0

// Aggressive Cleanup
drgbase_remove_dead 1
drgbase_remove_ragdolls 5
drgbase_ragdoll_collisions_disabled 1

// Performance
drgbase_projectile_tickrate 0.05
drgbase_update_luminosity 0
drgbase_avoid_obstacles 0
```

## Per-NPC Configuration

While ConVars control global settings, most NPC behavior is configured per-entity in the NPC's Lua file. These properties override or work alongside the global ConVars.

### Common Per-NPC Properties

Here are the most frequently configured properties for individual NPCs:

#### Basic Stats
```lua
ENT.SpawnHealth = 100              -- Starting health
ENT.HealthRegen = 0                -- Health regeneration per second
ENT.BloodColor = BLOOD_COLOR_RED   -- Blood color
ENT.ModelScale = 1                 -- Model size multiplier
```

#### Movement
```lua
ENT.WalkSpeed = 100                -- Walking speed
ENT.RunSpeed = 200                 -- Running speed
ENT.Acceleration = 1000            -- How fast it speeds up
ENT.Deceleration = 1000            -- How fast it slows down
ENT.JumpHeight = 50                -- Jump height
ENT.StepHeight = 20                -- Max step-up height
ENT.MaxYawRate = 250               -- Turning speed
```

#### Detection & Awareness
```lua
ENT.SightFOV = 150                 -- Field of view (degrees)
ENT.SightRange = 15000             -- Vision distance
ENT.HearingCoefficient = 1         -- Hearing sensitivity (0=deaf, 1=normal)
ENT.Omniscient = false             -- Always aware of all entities
ENT.SpotDuration = 30              -- How long to remember spotted entities
ENT.MinLuminosity = 0              -- Min light level to see targets (stealth)
ENT.MaxLuminosity = 1              -- Max light level to see targets
```

#### Combat
```lua
ENT.MeleeAttackRange = 50          -- Melee attack range
ENT.RangeAttackRange = 0           -- Ranged attack range (0=disabled)
ENT.ReachEnemyRange = 50           -- How close to get to enemy
ENT.AvoidEnemyRange = 0            -- Keep this distance from enemy
```

#### Factions & Relationships
```lua
ENT.DefaultRelationship = D_NU    -- Default disposition (D_HT, D_FR, D_LI, D_NU)
ENT.Factions = {FACTION_COMBINE}   -- Factions this NPC belongs to
ENT.Frightening = false            -- Makes neutral NPCs afraid
```

#### Animations
```lua
ENT.WalkAnimation = ACT_WALK       -- Walking animation
ENT.RunAnimation = ACT_RUN         -- Running animation
ENT.IdleAnimation = ACT_IDLE       -- Idle animation
ENT.JumpAnimation = ACT_JUMP       -- Jumping animation
```

#### Possession
```lua
ENT.PossessionEnabled = false      -- Allow possession of this NPC
ENT.PossessionMovement = POSSESSION_MOVE_1DIR  -- Movement mode
ENT.PossessionViews = {}           -- Camera positions
```

### Example: Custom Zombie Configuration

```lua
-- Create a tough, slow zombie
ENT.Base = "drgbase_nextbot"
ENT.PrintName = "Tank Zombie"

-- High health, slow speed
ENT.SpawnHealth = 300
ENT.WalkSpeed = 50
ENT.RunSpeed = 80

-- Limited vision but good hearing
ENT.SightFOV = 90
ENT.SightRange = 3000
ENT.HearingCoefficient = 1.5

-- Strong melee attack
ENT.MeleeAttackRange = 80
ENT.ReachEnemyRange = 70

-- Hostile to players
ENT.DefaultRelationship = D_HT
ENT.Factions = {FACTION_ZOMBIE}
```

### Property Priority

When both ConVars and entity properties affect behavior:
1. **Entity properties** define the NPC's base values
2. **ConVar multipliers** scale those values (e.g., `drgbase_multiplier_health`)
3. **ConVar toggles** can override entity settings (e.g., `drgbase_ai_sight` disables vision even if the NPC has `SightRange` set)

Example:
```lua
-- Entity definition
ENT.SpawnHealth = 100
ENT.RunSpeed = 200

-- With server settings:
drgbase_multiplier_health 2.0
drgbase_multiplier_speed 1.5

-- Actual in-game values:
-- Health: 100 * 2.0 = 200
-- Speed: 200 * 1.5 = 300
```

See the [Base Configuration API](../api/nextbot/base-config.md) for a complete list of all configurable properties.

## Runtime Configuration

You can modify NPC behavior at runtime (while the server is running) using various methods.

### Using Developer Tools

DrGBase includes several STool (Sandbox Tool) addons for runtime NPC configuration:

1. **DrGBase Info Tool** - View NPC properties and stats
2. **DrGBase Faction Tool** - Change NPC factions on the fly
3. **DrGBase Relationship Tool** - Modify relationships between entities
4. **DrGBase AI Tools** - Adjust AI behavior in real-time

Access these via the Tool Gun → DrGBase category.

### Via Properties Menu

Right-click NPCs with the context menu (C key by default) to access:
- **Possess** - Take control of the NPC (if possession is enabled)
- **Edit** - Modify spawn properties (requires admin permissions)

### Via Lua Console

You can modify spawned NPCs directly using Lua:

```lua
-- Find an NPC
local npc = player.GetAll()[1]:GetEyeTrace().Entity

-- Change properties at runtime
if npc.IsDrGNextbot then
    npc:SetSpeed(300)           -- Change movement speed
    npc:SetHealth(500)          -- Change health
    npc:AddFaction(FACTION_REBELS)  -- Add to faction
    npc:SetRelationship(Entity(1), D_LI) -- Like a specific entity
end
```

### Via Console Commands

Change ConVars at any time via console or RCON:
```
drgbase_ai_radius 6000
drgbase_multiplier_health 1.5
```

**Note:** Some ConVars (like precaching) only take effect on server restart or map change.

## Performance Tuning

### Large Servers (20+ players)

**Primary bottlenecks:** AI processing, network bandwidth, entity count

**Recommendations:**
- Reduce `drgbase_ai_radius` to 2500-3500
- Increase `drgbase_compute_delay` to 0.15-0.2
- Enable ragdoll auto-removal: `drgbase_remove_ragdolls 15`
- Disable ragdoll collisions: `drgbase_ragdoll_collisions_disabled 1`
- Consider reducing `drgbase_projectile_tickrate` if using many projectiles

**Expected impact:** 30-40% reduction in AI processing overhead

### Many NPCs (50+ active)

**Primary bottlenecks:** Pathfinding, detection checks, Think functions

**Recommendations:**
- Lower `drgbase_ai_radius` to 2000-3000 (NPCs beyond this won't process AI)
- Increase `drgbase_compute_delay` to 0.2-0.3 for slower path recalculation
- Disable features you don't use:
  - `drgbase_ai_patrol 0` if not using patrol paths
  - `drgbase_update_luminosity 0` if not using stealth mechanics
- Use `drgbase_remove_dead 1` to immediately clean up dead NPCs
- Stagger NPC spawning instead of spawning all at once

**Expected impact:** 40-50% reduction in NPC overhead, allowing ~2x more NPCs

### Low-End Hardware

**Primary bottlenecks:** CPU single-thread performance, RAM

**Recommendations:**
- Aggressive AI reduction:
  - `drgbase_ai_radius 2000`
  - `drgbase_compute_delay 0.25`
  - `drgbase_avoid_obstacles 0`
- Immediate cleanup:
  - `drgbase_remove_dead 1`
  - `drgbase_remove_ragdolls 3`
  - `drgbase_ragdoll_collisions_disabled 1`
- Disable unused systems:
  - `drgbase_ai_patrol 0`
  - `drgbase_update_luminosity 0`
- Limit projectile update rate: `drgbase_projectile_tickrate 0.05`

**Expected impact:** 50-60% overall performance improvement

### Monitoring Performance

Use these console commands to check performance:

```
net_graph 1              // Show FPS, latency, packet loss
developer 1              // Enable developer mode
showconsole              // Open console
lua_openscript_cl        // Client-side Lua errors
lua_openscript           // Server-side Lua errors
```

Check entity count:
```lua
lua_run PrintTable(ents.GetAll())
lua_run print(#ents.GetAll())
```

## Troubleshooting

### ConVar Not Taking Effect

**Possible causes:**

1. **ConVar requires restart/map change**
   - Precaching ConVars (`drgbase_precache_*`) only work on server startup
   - **Solution:** Restart server or change map

2. **Replicated ConVar not updated on clients**
   - Some ConVars need to sync to clients
   - **Solution:** Reconnect clients or wait for auto-sync

3. **NPC property overrides ConVar**
   - Individual NPCs may have properties that override globals
   - **Solution:** Check NPC's Lua file for conflicting settings

4. **ConVar has wrong type**
   - Setting `drgbase_ai_sight "true"` instead of `drgbase_ai_sight 1`
   - **Solution:** Use numeric values (0/1) for boolean ConVars

**Verification:**
```
// Check current value
drgbase_ai_radius
// Force set value
drgbase_ai_radius 5000
```

### Performance Issues

**Symptom:** Server lag, low FPS, stuttering

**Diagnostics:**
1. Check entity count: `lua_run print(#ents.GetAll())`
   - Over 1000 entities may cause issues
2. Check NPC count: `lua_run print(#ents.FindByClass("drgbase_nextbot"))`
   - Over 50 active NPCs requires optimization
3. Check ragdoll count: `lua_run print(#ents.FindByClass("prop_ragdoll"))`
   - Old ragdolls accumulating? Enable auto-removal

**Solutions:**
1. Reduce AI radius: `drgbase_ai_radius 2500`
2. Enable ragdoll cleanup: `drgbase_remove_ragdolls 15`
3. Increase compute delay: `drgbase_compute_delay 0.2`
4. Check for infinite loops in custom NPC code

### NPCs Not Detecting Players

**Symptom:** NPCs don't react to nearby players

**Diagnostics:**
1. Check if player is within AI radius:
   - Default is 5000 units (~260 feet)
   - Enable debug: `drgbase_debug_relationships 1`
2. Check if vision is disabled: `drgbase_ai_sight 1`
3. Check if hearing is disabled: `drgbase_ai_hearing 1`
4. Check NPC's sight properties in Lua file:
   ```lua
   ENT.SightFOV = 150      -- Must be > 0
   ENT.SightRange = 15000  -- Must be > 0
   ```

**Solutions:**
1. Increase AI radius: `drgbase_ai_radius 8000`
2. Enable vision: `drgbase_ai_sight 1`
3. Enable debug traces: `drgbase_debug_traces 1` to see line-of-sight checks
4. Check if NPC and player have line of sight (no walls blocking)
5. Verify NPC's relationship with players:
   ```lua
   lua_run print(Entity(1):GetRelationship(player.GetAll()[1]))
   ```
   Should return `D_HT` (hate) for hostile NPCs

### NPCs Stuck or Not Moving

**Symptom:** NPCs don't move or pathfind to targets

**Diagnostics:**
1. Check if navmesh exists for the map
   - NPCs need `navmesh` files to pathfind
2. Check if obstacle avoidance is causing issues
3. Enable nodegraph display (if using custom nodes):
   ```
   developer 1
   drgbase_nodegraph_display 1
   ```

**Solutions:**
1. Generate navmesh: `nav_generate` (requires map permissions)
2. Disable obstacle avoidance: `drgbase_avoid_obstacles 0`
3. Check NPC's movement speed isn't zero
4. Verify path computation isn't too delayed: `drgbase_compute_delay 0.1`

### Possession Not Working

**Symptom:** Can't possess NPCs or possession controls don't work

**Diagnostics:**
1. Check if possession is globally enabled: `drgbase_possession_enable 1`
2. Check if NPC allows possession:
   ```lua
   ENT.PossessionEnabled = true
   ENT.PossessionViews = {Vector(0,0,50)}  -- Must have views defined
   ```
3. Check if you're in a vehicle (possession disabled in vehicles)

**Solutions:**
1. Enable globally: `drgbase_possession_enable 1`
2. Add possession views to NPC definition
3. Exit vehicle before attempting possession
4. Verify NPC is alive and not already possessed

---

**Previous:** [Your First NPC](./04-first-npc.md) | **Next:** [Architecture Overview](../architecture/README.md)
