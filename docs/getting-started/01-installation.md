# Installation

## Overview
DrGBase is a Garry's Mod addon framework for creating custom NextBots (NPCs) with advanced AI capabilities. This guide will help you install and set up DrGBase.

## Requirements
- **Garry's Mod** - The game itself
- **Working Navmesh** - DrGBase NextBots require a navmesh to navigate the map
- **(Optional) Workshop Subscription** - If installing from Steam Workshop

## Installation Methods

### Method 1: Steam Workshop (Recommended)
1. Subscribe to DrGBase on the Steam Workshop
2. Garry's Mod will automatically download and install the addon
3. Restart Garry's Mod to load the addon

### Method 2: Manual Installation
1. Download the DrGBase addon files
2. Extract the contents to your `garrysmod/addons/` directory
3. The folder structure should look like:
   ```
   garrysmod/
   └── addons/
       └── drgbase/
           ├── lua/
           ├── materials/
           └── particles/
   ```
4. Restart Garry's Mod

## Verifying Installation

### Console Check
When DrGBase loads successfully, you should see messages in the console:
```
[DrGBase] Include file 'drgbase/...'
[DrGBase] Hi! :)
```

### Spawn Menu Check
1. Open the spawn menu (Q key by default)
2. Navigate to the **NPCs** tab
3. You should see a **DrGBase** category with example NPCs:
   - Zombie
   - Headcrab
   - TestNextbot
   - TestHuman
   - etc.

### Testing
1. Load a map with a navmesh (most official maps have one)
2. Spawn a DrGBase NPC (e.g., "Zombie") from the spawn menu
3. The NPC should:
   - Spawn correctly
   - Stand idle or patrol
   - React to the player when approached

## Generating a Navmesh

DrGBase NPCs **require a navmesh** to navigate the map. If you see a warning about missing navmesh:

### Single Player
Run this command in the console:
```
nav_generate
```

### Multiplayer (Server Owners)
Run this command in the **server console**:
```
nav_generate
```

**Note:** Navmesh generation can take several minutes depending on map size.

### Disabling Navmesh Warning
If you don't want to see the navmesh warning:
```
drgbase_navmesh_error 0
```

## Configuration (ConVars)

DrGBase provides several console variables (ConVars) for configuration:

| ConVar | Default | Description |
|--------|---------|-------------|
| `drgbase_precache_models` | 1 | Precache NPC models on load |
| `drgbase_precache_sounds` | 1 | Precache NPC sounds on load |
| `drgbase_multiplier_health` | 1 | Global health multiplier for all NPCs |
| `drgbase_ai_patrol` | 1 | Enable/disable patrol AI behavior |
| `drgbase_navmesh_error` | 1 | Show navmesh warning messages |

### Setting ConVars
```lua
-- In console:
drgbase_multiplier_health 2  -- Double all NPC health

-- In Lua (server-side):
GetConVar("drgbase_multiplier_health"):SetFloat(2)
```

## Troubleshooting

### NPCs Don't Spawn
- **Check console for errors** - Look for Lua errors in red
- **Verify installation** - Make sure all files are in the correct location
- **Check addon conflicts** - Disable other NPC addons temporarily

### NPCs Don't Move
- **Generate a navmesh** - Run `nav_generate` command
- **Check if map has navmesh** - Run `nav_edit 1` to see navmesh visualization
- **Verify patrol is enabled** - Check `drgbase_ai_patrol` is set to 1

### Console Errors
- **Missing DrGBase** - If you see "DrGBase not found" errors, reinstall the addon
- **File errors** - Verify all Lua files are present and not corrupted
- **Network errors** - May occur on servers; check file consistency

### NPCs Act Strangely
- **Check AI settings** - Some NPCs may have custom AI behaviors
- **Verify relationships** - NPCs use faction and relationship systems
- **Test with default NPCs** - Try spawning example NPCs (Zombie, Headcrab) first

## Next Steps

Now that DrGBase is installed, you can:
- **[Create Your First NPC](02-first-nextbot.md)** - Build a simple custom NPC
- **[Explore Examples](../examples/)** - Study the included example NPCs
- **[Learn the API](../api/)** - Understand DrGBase functions and properties

## Additional Resources

- **Example NPCs**: Located in `lua/entities/npc_drg_*`
- **Base Code**: Located in `lua/entities/drgbase_nextbot/`
- **Core Functions**: Located in `lua/drgbase/`

---

**Next:** [Creating Your First NextBot](02-first-nextbot.md)
