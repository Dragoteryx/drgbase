# Configuration & ConVars

DrGBase provides several ConVars (console variables) for configuration and tuning.

## Server ConVars

### AI Configuration

<!-- TODO: Document AI-related convars -->

#### `drgbase_ai_radius`
- **Default:** `5000`
- **Description:** <!-- Explain detection radius -->
- **Usage:** <!-- When to change this -->

### Possession System

<!-- TODO: Document possession convars -->

#### `drgbase_possession_enable`
- **Default:** `1`
- **Description:** <!-- Explain possession system toggle -->
- **Usage:** <!-- When to disable -->

#### `drgbase_possession_allow_lockon`
- **Default:** `1`
- **Description:** <!-- Explain lock-on system -->
- **Usage:** <!-- When to disable -->

#### `drgbase_possession_lockon_speed`
- **Default:** `0.05`
- **Description:** <!-- Explain lock-on rotation speed -->
- **Range:** <!-- Min/max values -->

### Weapon System

<!-- TODO: Document weapon convars -->

#### `drgbase_give_weapons`
- **Default:** `1`
- **Description:** <!-- Explain weapon giving -->
- **Usage:** <!-- When to disable -->

### Performance & Optimization

<!-- TODO: Document performance convars -->

#### `drgbase_precache_models`
- **Default:** `1`
- **Description:** <!-- Explain model precaching -->
- **Performance Impact:** <!-- When to disable -->

#### `drgbase_precache_sounds`
- **Default:** `1`
- **Description:** <!-- Explain sound precaching -->
- **Performance Impact:** <!-- When to disable -->

#### `drgbase_projectile_tickrate`
- **Default:** `-1`
- **Description:** <!-- Explain projectile update rate -->
- **Values:** <!-- -1 = every tick, 0 = think, positive = interval -->

## Client ConVars

### Debug & Visualization

<!-- TODO: Document debug convars -->

#### `drgbase_debug_traces`
- **Default:** `0`
- **Description:** <!-- Explain trace visualization -->
- **Usage:** <!-- For debugging line of sight -->

#### `drgbase_debug_relationships`
- **Default:** `0`
- **Description:** <!-- Explain relationship debugging -->
- **Usage:** <!-- For debugging faction issues -->

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

<!-- TODO: Provide recommended configs for different scenarios -->

### High Performance Server

```
drgbase_ai_radius 3000
drgbase_precache_models 1
drgbase_precache_sounds 1
drgbase_projectile_tickrate 2
```

### Single Player / Testing

```
drgbase_ai_radius 8000
drgbase_debug_traces 1
drgbase_debug_relationships 1
```

### Roleplay Server

```
drgbase_possession_enable 0
drgbase_give_weapons 0
```

### Sandbox / Creative

```
drgbase_possession_enable 1
drgbase_possession_allow_lockon 1
drgbase_give_weapons 1
```

## Per-NPC Configuration

<!-- TODO: Explain NPC-level configuration -->

Many settings can be configured per-NPC in the entity definition:

```lua
ENT.SpawnHealth = 100              -- Health
ENT.MoveSpeed = 250                -- Movement speed
ENT.VisionRange = 4000             -- Vision distance
ENT.MeleeAttackRange = 80          -- Attack range
-- etc.
```

See the [API Reference](../api/README.md) for all available entity properties.

## Runtime Configuration

<!-- TODO: Explain runtime changes -->

### Using Developer Tools

<!-- How to change settings on spawned NPCs -->

### Via Properties Menu

<!-- How to use context menu properties -->

### Via Console Commands

<!-- Any special console commands -->

## Performance Tuning

<!-- TODO: Performance recommendations -->

### Large Servers

<!-- Recommendations for 20+ players -->

### Many NPCs

<!-- Recommendations for 50+ NPCs -->

### Low-End Hardware

<!-- Recommendations for optimization -->

## Troubleshooting

<!-- TODO: Common configuration issues -->

### ConVar Not Taking Effect

<!-- Possible causes -->

### Performance Issues

<!-- Configuration changes to improve performance -->

### NPCs Not Detecting Players

<!-- Check AI radius and detection settings -->

---

**Previous:** [Your First NPC](./04-first-npc.md) | **Next:** [Architecture Overview](../architecture/README.md)
