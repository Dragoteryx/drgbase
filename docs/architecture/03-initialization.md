# Initialization System

## Entry Point

The DrGBase framework initializes through `lua/autorun/drgbase.lua`.

<!-- TODO: Explain autorun system -->

## Initialization Sequence

<!-- TODO: Document complete initialization sequence -->

### Phase 1: Global Setup

```lua
-- Create global table
DrGBase = DrGBase or {}

-- Setup print functions
DrGBase.Print()
DrGBase.Info()
DrGBase.Error()
DrGBase.ErrorInfo()
```

### Phase 2: Include System Setup

```lua
-- Define file inclusion functions
DrGBase.IncludeFile(fileName)
DrGBase.IncludeFolder(folder)
DrGBase.RecursiveInclude(folder)
```

### Phase 3: Core Modules

```lua
-- Load core functionality
drgbase/colors.lua
drgbase/enumerations.lua
drgbase/entity_helpers.lua
drgbase/misc.lua
-- etc.
```

### Phase 4: Metatable Extensions

```lua
-- Extend engine metatables
drgbase/meta/entity.lua
drgbase/meta/npc.lua
drgbase/meta/player.lua
drgbase/meta/phys.lua
drgbase/meta/vector.lua
```

### Phase 5: Utility Modules

```lua
-- Load utility modules
drgbase/modules/coroutine.lua
drgbase/modules/math.lua
drgbase/modules/net.lua
-- etc.
```

### Phase 6: Systems Initialization

```lua
-- Load system modules
drgbase/nextbots.lua       -- Nextbot registry
drgbase/weapons.lua         -- Weapon registry
drgbase/spawners.lua        -- Spawner system
drgbase/possession.lua      -- Possession system
drgbase/spawnmenu.lua       -- Spawn menu integration
```

### Phase 7: Base Entities

<!-- Garry's Mod automatically loads entities/ after autorun -->

### Phase 8: Network Setup

<!-- TODO: Document network initialization -->

## Load Order Dependencies

<!-- TODO: Explain dependencies between modules -->

### Critical Dependencies

```
enumerations.lua → (required by many modules)
    ↓
entity_helpers.lua → (required by nextbots)
    ↓
meta extensions → (required by systems)
    ↓
core systems → (required by bases)
    ↓
base entities → (required by custom entities)
```

### Module Dependencies

<!-- TODO: Document module-to-module dependencies -->

## File Inclusion System

<!-- TODO: Explain IncludeFile, IncludeFolder, RecursiveInclude -->

### DrGBase.IncludeFile(fileName)

<!-- How it works -->
<!-- Realm detection (sv_, cl_) -->
<!-- AddCSLuaFile handling -->
<!-- include() vs AddCSLuaFile() -->

```lua
-- Server-only file
DrGBase.IncludeFile("sv_myfile.lua")  -- Only runs on server

-- Client-only file
DrGBase.IncludeFile("cl_myfile.lua")  -- Sent to client, runs there

-- Shared file
DrGBase.IncludeFile("sh_myfile.lua")  -- Runs on both, sent to client
```

### DrGBase.IncludeFolder(folder)

<!-- How it works -->
<!-- Order of inclusion -->

### DrGBase.RecursiveInclude(folder)

<!-- Recursive inclusion -->
<!-- Use cases -->

## Realm Handling

<!-- TODO: Explain server vs client initialization -->

### Server Initialization

<!-- What happens server-side -->

### Client Initialization

<!-- What happens client-side -->

### Shared Initialization

<!-- What runs on both -->

## Network String Registration

<!-- TODO: Document network message setup -->

```lua
if SERVER then
    util.AddNetworkString("DrG_ChatMessage")
    -- etc.
end
```

## Entity Registration

<!-- TODO: Explain how entities register themselves -->

### Nextbots

```lua
AddCSLuaFile()
DrGBase.AddNextbot(ENT)
```

### Weapons

```lua
DrGBase.AddWeapon(SWEP)
```

### Spawners

```lua
DrGBase.AddSpawner(ENT)
```

## Initialization Hooks

<!-- TODO: Document hooks called during init -->

### Framework Hooks

- `Initialize`
- `PostInit`
- Custom initialization hooks

### Entity Hooks

- `ENT:Initialize()`
- `ENT:CustomInitialize()`

## Precaching

<!-- TODO: Explain precaching system -->

### Model Precaching

```lua
util.PrecacheModel(model)
```

### Sound Precaching

```lua
util.PrecacheSound(sound)
```

### ConVar Control

```lua
drgbase_precache_models 1
drgbase_precache_sounds 1
```

## Debugging Initialization

<!-- TODO: How to debug loading issues -->

### Console Output

<!-- What to look for -->

### Common Issues

<!-- Loading errors -->
<!-- Missing dependencies -->
<!-- Order problems -->

## Lazy Loading

<!-- TODO: Any lazy-loaded components? -->

## Hot Reloading

<!-- TODO: Reloading during development -->

### lua_openscript

```lua
lua_openscript_cl autorun/drgbase.lua
```

### Caveats

<!-- What doesn't hot-reload well -->

---

**Previous:** [File Structure](./02-file-structure.md) | **Next:** [Module System](./04-module-system.md)
