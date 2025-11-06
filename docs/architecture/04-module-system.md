# Module System

## Overview

<!-- TODO: Explain the module system architecture -->

## Core Modules

<!-- TODO: Document each core module -->

### colors.lua
- **Purpose:** <!-- Color definitions for UI -->
- **Exports:** <!-- Global color tables -->
- **Dependencies:** <!-- None -->

### dpanels.lua
- **Purpose:** <!-- DPanel utilities -->
- **Exports:** <!-- Panel helper functions -->
- **Dependencies:** <!-- Client-side only -->

### enumerations.lua
- **Purpose:** <!-- Constants and enumerations -->
- **Exports:** <!-- FACTION_*, D_*, etc. -->
- **Dependencies:** <!-- None -->

### entity_helpers.lua
- **Purpose:** <!-- Entity utility functions -->
- **Exports:** <!-- Helper functions -->
- **Dependencies:** <!-- None -->

### misc.lua
- **Purpose:** <!-- Miscellaneous utilities -->
- **Exports:** <!-- Various helper functions -->
- **Dependencies:** <!-- Multiple -->

### nextbots.lua
- **Purpose:** <!-- Nextbot registration system -->
- **Exports:** <!-- DrGBase.AddNextbot() -->
- **Dependencies:** <!-- entity_helpers, spawnmenu -->

### nodegraph.lua
- **Purpose:** <!-- AI node graph utilities -->
- **Exports:** <!-- Node graph functions -->
- **Dependencies:** <!-- Server-side only -->

### particles.lua
- **Purpose:** <!-- Particle effect system -->
- **Exports:** <!-- Particle management -->
- **Dependencies:** <!-- Resource system -->

### possession.lua
- **Purpose:** <!-- Possession mechanics -->
- **Exports:** <!-- Possession functions -->
- **Dependencies:** <!-- Networking, weapons -->

### resources.lua
- **Purpose:** <!-- Resource management and precaching -->
- **Exports:** <!-- Resource.Add() equivalents -->
- **Dependencies:** <!-- None -->

### spawners.lua
- **Purpose:** <!-- NPC spawner system -->
- **Exports:** <!-- DrGBase.AddSpawner() -->
- **Dependencies:** <!-- Entity system -->

### spawnmenu.lua
- **Purpose:** <!-- Spawn menu integration -->
- **Exports:** <!-- Spawn menu hooks -->
- **Dependencies:** <!-- Client-side only -->

### weapons.lua
- **Purpose:** <!-- Weapon registry -->
- **Exports:** <!-- DrGBase.AddWeapon() -->
- **Dependencies:** <!-- None -->

### wrappers.lua
- **Purpose:** <!-- Entity wrapper classes -->
- **Exports:** <!-- Wrapper functions -->
- **Dependencies:** <!-- Entity system -->

## Metatable Extensions

<!-- TODO: Document metatable extension modules -->

### entity.lua

**Extended Methods:**
<!-- List all ENT: methods added -->

### npc.lua

**Extended Methods:**
<!-- List all NPC: methods added -->

### player.lua

**Extended Methods:**
<!-- List all Player: methods added -->

### phys.lua

**Extended Methods:**
<!-- List all PhysObj: methods added -->

### vector.lua

**Extended Methods:**
<!-- List all Vector: methods added -->

## Utility Modules

<!-- TODO: Document utility modules -->

### coroutine.lua
- **Purpose:** <!-- Coroutine management helpers -->
- **Key Functions:** <!-- List functions -->

### debugoverlay.lua
- **Purpose:** <!-- Debug visualization -->
- **Key Functions:** <!-- List functions -->

### math.lua
- **Purpose:** <!-- Math function extensions -->
- **Key Functions:** <!-- List functions -->

### navmesh.lua
- **Purpose:** <!-- Navigation mesh helpers -->
- **Key Functions:** <!-- List functions -->

### net.lua
- **Purpose:** <!-- Networking system -->
- **Key Functions:** <!-- List functions -->

### render.lua
- **Purpose:** <!-- Rendering helpers -->
- **Key Functions:** <!-- List functions -->

### string.lua
- **Purpose:** <!-- String extensions -->
- **Key Functions:** <!-- List functions -->

### table.lua
- **Purpose:** <!-- Table extensions -->
- **Key Functions:** <!-- List functions -->

### timer.lua
- **Purpose:** <!-- Timer management -->
- **Key Functions:** <!-- List functions -->

### util.lua
- **Purpose:** <!-- Utility functions -->
- **Key Functions:** <!-- List functions -->

## Module Communication

<!-- TODO: How modules interact -->

### Direct Function Calls

<!-- Modules call each other directly -->

### Hook System

<!-- Modules communicate via hooks -->

### Global State

<!-- Shared via DrGBase table -->

## Adding Custom Modules

<!-- TODO: Guide for adding your own modules -->

### Module Template

```lua
-- my_module.lua
if not DrGBase then return end

-- Module code here

-- Export functions to DrGBase table
DrGBase.MyFunction = function()
    -- ...
end
```

### Integration

<!-- How to integrate custom modules -->

---

**Previous:** [Initialization System](./03-initialization.md) | **Next:** [Client-Server Architecture](./05-client-server.md)
