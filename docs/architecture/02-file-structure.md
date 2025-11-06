# File Structure

## Complete Directory Tree

<!-- TODO: Provide complete annotated directory tree -->

```
drgbase/
├── lua/
│   ├── autorun/
│   │   └── drgbase.lua                      # Main entry point
│   │
│   ├── drgbase/                             # Core framework
│   │   ├── colors.lua                       # Color definitions
│   │   ├── dpanels.lua                      # UI panel utilities
│   │   ├── enumerations.lua                 # Constants & enums
│   │   ├── entity_helpers.lua               # Entity utility functions
│   │   ├── misc.lua                         # Miscellaneous utilities
│   │   ├── nextbots.lua                     # Nextbot registration
│   │   ├── nodegraph.lua                    # Node graph utilities
│   │   ├── particles.lua                    # Particle effects
│   │   ├── possession.lua                   # Possession mechanics
│   │   ├── resources.lua                    # Resource management
│   │   ├── spawners.lua                     # Spawner system
│   │   ├── spawnmenu.lua                    # Spawn menu integration
│   │   ├── weapons.lua                      # Weapon registry
│   │   ├── wrappers.lua                     # Entity wrappers
│   │   │
│   │   ├── meta/                            # Metatable extensions
│   │   │   ├── entity.lua                   # Entity extensions
│   │   │   ├── npc.lua                      # NPC extensions
│   │   │   ├── phys.lua                     # Physics extensions
│   │   │   ├── player.lua                   # Player extensions
│   │   │   └── vector.lua                   # Vector extensions
│   │   │
│   │   └── modules/                         # Utility modules
│   │       ├── coroutine.lua                # Coroutine helpers
│   │       ├── debugoverlay.lua             # Debug visualization
│   │       ├── math.lua                     # Math extensions
│   │       ├── navmesh.lua                  # Navigation helpers
│   │       ├── net.lua                      # Networking system
│   │       ├── render.lua                   # Rendering helpers
│   │       ├── string.lua                   # String extensions
│   │       ├── table.lua                    # Table extensions
│   │       ├── timer.lua                    # Timer system
│   │       └── util.lua                     # Utility functions
│   │
│   ├── entities/
│   │   ├── drgbase_entity.lua               # Base entity
│   │   │
│   │   ├── drgbase_nextbot/                 # Base nextbot (6,238 lines)
│   │   │   ├── shared.lua                   # Base config (621 lines)
│   │   │   ├── ai.lua                       # AI system (187 lines)
│   │   │   ├── animations.lua               # Animations (552 lines)
│   │   │   ├── awareness.lua                # Awareness (262 lines)
│   │   │   ├── behaviours.lua               # Behaviors (152 lines)
│   │   │   ├── blank.lua                    # Template (30 lines)
│   │   │   ├── detection.lua                # Detection (244 lines)
│   │   │   ├── hooks.lua                    # Hooks (300 lines)
│   │   │   ├── inventory.lua                # Inventory (30 lines)
│   │   │   ├── locomotion.lua               # Locomotion (106 lines)
│   │   │   ├── misc.lua                     # Misc (675 lines)
│   │   │   ├── movements.lua                # Movement (702 lines)
│   │   │   ├── path.lua                     # Pathfinding (158 lines)
│   │   │   ├── patrol.lua                   # Patrol (226 lines)
│   │   │   ├── possession.lua               # Possession (420 lines)
│   │   │   ├── relationships.lua            # Relationships (831 lines)
│   │   │   ├── status.lua                   # Health (205 lines)
│   │   │   └── weapons.lua                  # Weapons (537 lines)
│   │   │
│   │   ├── drgbase_nextbot_human/           # Human variant
│   │   ├── drgbase_nextbot_sprite/          # Sprite variant
│   │   │
│   │   ├── proj_drg_default/                # Base projectile
│   │   │
│   │   ├── npc_drg_*.lua                    # Example NPCs
│   │   ├── proj_drg_*.lua                   # Example projectiles
│   │   └── spwn_drg_*.lua                   # Spawner entities
│   │
│   ├── weapons/
│   │   ├── drgbase_weapon/                  # Base weapon
│   │   │   ├── shared.lua
│   │   │   ├── primary.lua
│   │   │   ├── secondary.lua
│   │   │   ├── misc.lua
│   │   │   └── meta.lua
│   │   │
│   │   ├── drgbase_possession.lua           # Possession weapon
│   │   ├── drgbase_possessor.lua            # Possessor weapon
│   │   ├── weapon_drg_*.lua                 # Example weapons
│   │   │
│   │   └── gmod_tool/stools/                # Developer tools
│   │       └── drgbase_tool_*.lua
│   │
│   └── effects/
│       └── drg_blood_explosion.lua          # Blood effect
│
├── materials/
│   ├── entities/                            # Entity icons
│   ├── drgbase/                             # Framework materials
│   └── weapons/                             # Weapon icons
│
└── particles/
    └── drgbase.pcf                          # Particle definitions
```

## File Naming Conventions

<!-- TODO: Explain naming conventions -->

### Prefix System

#### Entity Files
- `drgbase_` - Framework base classes
- `npc_drg_` - Example/included NPCs
- `proj_drg_` - Example projectiles
- `spwn_drg_` - Spawner entities

#### Tool Files
- `drgbase_tool_` - Developer tools

#### Weapon Files
- `drgbase_` - Framework weapons
- `weapon_drg_` - Example weapons

### Realm Prefixes

Files can use realm prefixes in their names:
- `sv_*.lua` - Server-only files
- `cl_*.lua` - Client-only files
- No prefix - Shared files

The framework's `IncludeFile()` function handles these automatically.

## Module Organization

<!-- TODO: Explain how modules are organized -->

### Core Modules (`drgbase/`)

Each module handles a specific aspect:

| File | Purpose | Size |
|------|---------|------|
| `colors.lua` | Color definitions for UI | <!-- TODO --> |
| `dpanels.lua` | DPanel utilities | <!-- TODO --> |
| `enumerations.lua` | Constants & enums | <!-- TODO --> |
| `entity_helpers.lua` | Entity utilities | <!-- TODO --> |
| `misc.lua` | Misc functions | <!-- TODO --> |
| `nextbots.lua` | Nextbot registration | <!-- TODO --> |
| `nodegraph.lua` | AI node graphs | <!-- TODO --> |
| `particles.lua` | Particle system | <!-- TODO --> |
| `possession.lua` | Possession system | <!-- TODO --> |
| `resources.lua` | Resource loading | <!-- TODO --> |
| `spawners.lua` | Spawner system | <!-- TODO --> |
| `spawnmenu.lua` | Spawn menu integration | <!-- TODO --> |
| `weapons.lua` | Weapon registry | <!-- TODO --> |
| `wrappers.lua` | Entity wrappers | <!-- TODO --> |

### Metatable Extensions (`drgbase/meta/`)

<!-- TODO: Document metatable extensions -->

### Utility Modules (`drgbase/modules/`)

<!-- TODO: Document utility modules -->

## Base Classes

<!-- TODO: Explain base class structure -->

### Nextbot Hierarchy

```
drgbase_nextbot (base)
├── drgbase_nextbot_human
├── drgbase_nextbot_sprite
└── Custom NPCs (your addons)
```

### Weapon Hierarchy

```
drgbase_weapon (base)
└── Custom Weapons (your addons)
```

### Projectile Hierarchy

```
proj_drg_default (base)
└── Custom Projectiles (your addons)
```

## File Sizes & Complexity

<!-- TODO: Provide metrics -->

### Largest Files

1. `relationships.lua` - 831 lines
2. `movements.lua` - 702 lines
3. `misc.lua` - 675 lines
4. `shared.lua` - 621 lines
5. `animations.lua` - 552 lines
6. `weapons.lua` - 537 lines

### System Totals

- **Total Codebase:** ~8,000+ lines
- **Base Nextbot:** 6,238 lines
- **Core Framework:** <!-- TODO -->
- **Utility Modules:** <!-- TODO -->

## Adding Your Own Files

<!-- TODO: Guide for adding custom files -->

### Custom Addon Structure

```
your_addon/
├── lua/
│   ├── entities/
│   │   └── npc_your_custom.lua
│   └── weapons/
│       └── weapon_your_custom.lua
└── materials/
    └── entities/
        └── npc_your_custom.png
```

### Integration Points

<!-- Where your code interfaces with DrGBase -->

---

**Previous:** [Overview](./01-overview.md) | **Next:** [Initialization System](./03-initialization.md)
