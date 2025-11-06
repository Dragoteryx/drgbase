# Installation

## Requirements

### Game Requirements
- **Garry's Mod** - Latest stable version recommended
- The addon is compatible with both single-player and multiplayer (dedicated servers)

### Dependencies
- **No external dependencies** - DrGBase is a standalone framework that doesn't require any additional addons
- All required assets (models, materials, particles) are included

### System Requirements
- **Server**: Any system capable of running a Garry's Mod server
- **Client**: Standard Garry's Mod client requirements
- **Lua Environment**: Server and client-side Lua support (standard with Garry's Mod)

## Installation Methods

### Method 1: Steam Workshop

**Recommended for most users** - This is the easiest method and ensures automatic updates.

1. **Find DrGBase on Steam Workshop**
   - Open the Steam Workshop in your web browser
   - Search for "DrGBase" or navigate directly to the DrGBase Workshop page
   - This addon is currently available on the Steam Workshop

2. **Subscribe to the addon**
   - Click the green "Subscribe" button on the Workshop page
   - Steam will automatically download the addon to your Garry's Mod addons folder

3. **Launch Garry's Mod**
   - Start Garry's Mod (single-player or multiplayer)
   - The addon will load automatically on startup

4. **Verify installation**
   - See the "Verifying Installation" section below to confirm DrGBase loaded correctly

### Method 2: Manual Installation

**For users who want to install without Steam Workshop** - Useful for offline servers or custom setups.

1. **Download the addon**
   - Visit the DrGBase GitHub repository: `https://github.com/[repository]/drgbase`
   - Click on "Code" → "Download ZIP"
   - Alternatively, download a specific release from the Releases page

2. **Extract the files**
   - Extract the downloaded ZIP file
   - You should see a folder containing: `lua/`, `materials/`, `particles/`, and `README.md`

3. **Install to Garry's Mod**
   - Navigate to your Garry's Mod installation directory:
     - **Windows**: `C:\Program Files (x86)\Steam\steamapps\common\GarrysMod\garrysmod\addons\`
     - **Linux**: `~/.steam/steam/steamapps/common/GarrysMod/garrysmod/addons/`
     - **macOS**: `~/Library/Application Support/Steam/steamapps/common/GarrysMod/garrysmod/addons/`
   - Create a new folder named `drgbase` inside the `addons/` directory
   - Copy all extracted files into this new folder

4. **Verify folder structure**
   - Your installation should look like this:
     ```
     garrysmod/addons/drgbase/
     ├── lua/
     ├── materials/
     ├── particles/
     └── README.md
     ```

5. **Restart Garry's Mod**
   - If the game is running, restart it completely
   - If running a dedicated server, restart the server

### Method 3: Git Clone (Developers)

**For developers and contributors** - Allows you to easily pull updates and contribute changes.

1. **Navigate to your addons directory**
   ```bash
   cd path/to/GarrysMod/garrysmod/addons/
   ```

2. **Clone the repository**
   ```bash
   git clone https://github.com/[repository]/drgbase.git drgbase
   ```

   Replace `[repository]` with the actual GitHub username/organization.

3. **Keep the addon updated**
   ```bash
   cd drgbase
   git pull origin main
   ```

4. **Switch to development branch (optional)**
   ```bash
   git checkout develop
   ```

**Benefits of this method:**
- Easy to update with `git pull`
- Can contribute changes back to the project
- Can switch between different branches/versions
- Full version history available

## Verifying Installation

After installing DrGBase, follow these steps to confirm it loaded correctly:

### 1. Check Console Output

1. **Open the console** in Garry's Mod:
   - Press the `~` key (backtick/tilde) to open the developer console
   - If the console doesn't open, enable it in Options → Keyboard → Advanced → "Enable Developer Console"

2. **Look for DrGBase messages**:

   You should see output similar to this during game startup:

   ```
   [DrGBase] Include folder 'drgbase'.
   [DrGBase] Include file 'drgbase/colors.lua'.
   [DrGBase] Include file 'drgbase/entity_helpers.lua'.
   [DrGBase] Include file 'drgbase/enumerations.lua'.
   [DrGBase] Include folder 'drgbase/meta'.
   [DrGBase] Include file 'drgbase/meta/entity.lua'.
   [DrGBase] Include file 'drgbase/meta/npc.lua'.
   ...
   [DrGBase] Nextbot 'npc_drg_zombie': loaded.
   [DrGBase] Nextbot 'npc_drg_headcrab': loaded.
   [DrGBase] Nextbot 'npc_drg_antlion': loaded.
   ...
   ```

   On the **client side**, you should also see:
   ```
   [DrGBase] Hi! :)
   ```

   **Note**: The exact number of files and nextbots may vary depending on the version.

### 2. Check Spawn Menu

1. **Open the spawn menu**:
   - Press `Q` to open the spawn menu

2. **Verify NPCs tab**:
   - Click on the "NPCs" tab at the top
   - Look for a "DrGBase" category in the list
   - You should see example NPCs including:
     - Zombie
     - Headcrab
     - Antlion
     - Test NPCs (TestNextbot, TestHuman, TestSprite)

3. **Verify DrGBase tab**:
   - Look for a "DrGBase" tab icon in the spawn menu toolbar (near the top)
   - This tab provides additional DrGBase-specific content and tools

### 3. Test Spawning an NPC

1. **Spawn a test NPC**:
   - In the spawn menu NPCs tab, find "Zombie" under the DrGBase category
   - Click on it to select
   - Left-click on the ground in the game world to spawn

2. **Verify NPC behavior**:
   - The zombie should spawn and become active
   - It should move, detect threats, and respond to damage
   - Try shooting it to verify combat behavior works

### 4. Check Developer Tools

1. **Open the spawn menu** (press `Q`)
2. **Click on "DrGBase" tab** (if visible in the toolbar)
3. Alternatively, navigate to the **Tools tab** → **DrGBase** section
4. You should see DrGBase tools including:
   - Info Tool
   - Damage Tool
   - Godmode Tool
   - Faction Tool
   - Relationship Tool
   - And others

### 5. Verify Settings Menu

1. Open spawn menu (press `Q`)
2. Navigate to: **Utilities** → **DrGBase** → **Nextbot Settings**
3. You should see configuration options for:
   - AI Settings (detection, omniscience, sight, hearing, patrol)
   - Possession settings
   - Misc settings (health multiplier, damage multipliers, ragdolls, pathfinding)

## Troubleshooting

### Issue: DrGBase not loading

**Symptoms**: No DrGBase messages in console, no DrGBase category in spawn menu

**Possible causes and solutions**:

1. **Incorrect installation location**
   - **Solution**: Verify files are in `garrysmod/addons/drgbase/` (not nested in another folder)
   - The `lua/` folder should be directly inside `drgbase/`, not in a subfolder

2. **Addon not enabled (Workshop installation)**
   - **Solution**: Check Steam Workshop subscriptions, ensure DrGBase is subscribed
   - Try unsubscribing and re-subscribing

3. **File permissions (Linux servers)**
   - **Solution**: Ensure the server has read permissions for all DrGBase files
   - Run: `chmod -R 755 garrysmod/addons/drgbase/`

4. **Conflicting addon**
   - **Solution**: Temporarily disable other addons to identify conflicts
   - Check console for Lua errors that mention DrGBase

### Issue: NPCs not appearing in spawn menu

**Symptoms**: DrGBase loads but no NPCs visible, or some NPCs missing

**Possible causes and solutions**:

1. **Spawn menu cache issue**
   - **Solution**: Restart Garry's Mod completely
   - Clear spawn menu cache: delete `garrysmod/cache/` folder (it will regenerate)

2. **Missing entity files**
   - **Solution**: Verify all files in `lua/entities/npc_drg_*` exist
   - Reinstall the addon using one of the methods above

3. **Console errors during NPC registration**
   - **Solution**: Check console for errors mentioning specific NPCs
   - Look for model precaching errors or Lua syntax errors

4. **NPCs disabled by ConVar**
   - **Solution**: Some NPCs may have `Spawnable = false` in their code
   - Check console output to see which NPCs loaded: `[DrGBase] Nextbot 'npc_drg_*': loaded.`

### Issue: Console errors on load

**Symptoms**: Red error messages in console mentioning DrGBase

**Common error messages and fixes**:

1. **`[ERROR] lua/autorun/drgbase.lua:XXX: attempt to call field 'XXX' (a nil value)`**
   - **Cause**: Corrupted or incomplete installation
   - **Solution**: Reinstall DrGBase completely (delete old folder first)

2. **`[ERROR] Model 'models/XXX.mdl' not found`**
   - **Cause**: Missing game content (Counter-Strike: Source, Half-Life 2, etc.)
   - **Solution**: Mount required games in Garry's Mod:
     - Open spawn menu → Options → "Mount games"
     - Enable Half-Life 2, Counter-Strike: Source, etc.

3. **`[ERROR] Lua module 'XXX' not found`**
   - **Cause**: Server missing required Lua modules (rare)
   - **Solution**: This shouldn't happen with DrGBase as it has no external dependencies
   - Verify your Garry's Mod installation is complete

4. **`[ERROR] addons/drgbase/lua/entities/XXX.lua:YYY: unexpected symbol`**
   - **Cause**: Corrupted file download
   - **Solution**: Redownload and reinstall DrGBase

### Issue: Missing models/materials

**Symptoms**: NPCs appear as "ERROR" models, missing textures

**Possible causes and solutions**:

1. **Game content not mounted**
   - **Cause**: DrGBase uses standard Source engine models (HL2, CSS, etc.)
   - **Solution**: Install and mount required Source games:
     - Open spawn menu → Options
     - Navigate to "Mount games" section
     - Check boxes for: Half-Life 2, Half-Life 2: Episode One, Half-Life 2: Episode Two
     - These games must be owned and installed on Steam

2. **Missing materials folder**
   - **Cause**: Incomplete installation
   - **Solution**: Verify `materials/` folder exists in `addons/drgbase/`
   - Reinstall if missing

3. **Custom content for specific NPCs**
   - **Cause**: Some custom NPCs may require additional content packs
   - **Solution**: Check the NPC's documentation for content requirements
   - DrGBase default NPCs only use standard HL2 models

### Issue: NPCs spawn but don't move or react

**Symptoms**: NPCs spawn but appear frozen or don't detect enemies

**Possible causes and solutions**:

1. **AI disabled globally**
   - **Solution**: Check console variable: `ai_disabled`
   - Set it to 0: type `ai_disabled 0` in console

2. **DrGBase AI disabled**
   - **Solution**: Check ConVar `drgbase_ai_sight` and `drgbase_ai_hearing`
   - Enable with: `drgbase_ai_sight 1` and `drgbase_ai_hearing 1`

3. **No navigation mesh**
   - **Cause**: Map doesn't have nav mesh, affects pathfinding
   - **Solution**: Generate nav mesh with: `nav_generate` in console (takes time)
   - Or use a map with pre-generated nav mesh

4. **Server lag**
   - **Cause**: Too many NPCs or poor server performance
   - **Solution**: Reduce NPC count, check server tick rate

### Issue: Server crash on NPC spawn

**Symptoms**: Server crashes or freezes when spawning DrGBase NPCs

**Possible causes and solutions**:

1. **Outdated Garry's Mod version**
   - **Solution**: Update Garry's Mod to the latest version
   - Run `SteamCMD` update for dedicated servers

2. **Memory issues**
   - **Solution**: Increase server memory allocation
   - Reduce number of NPCs or other entities

3. **Conflicting addon**
   - **Solution**: Test with DrGBase only (disable other addons)
   - Check console/server logs for error details

4. **Corrupted model cache**
   - **Solution**: Delete model cache: `garrysmod/cache/modelsounds.cache`
   - Restart server to regenerate

### Getting Additional Help

If you continue experiencing issues:

1. **Check the console** for specific error messages
2. **Enable Lua error display**: `lua_log_sv 1` (server) or `lua_log_cl 1` (client)
3. **Review server logs**: `garrysmod/console.log`
4. **Visit the DrGBase GitHub issues page** to report bugs or ask questions
5. **Provide details**: Garry's Mod version, error messages, addon list, reproduction steps

## File Structure After Installation

After successful installation, your DrGBase directory should have the following structure:

```
garrysmod/addons/drgbase/
├── lua/
│   ├── autorun/
│   │   └── drgbase.lua              # Main initialization file
│   ├── drgbase/                      # Core framework modules
│   │   ├── colors.lua
│   │   ├── entity_helpers.lua
│   │   ├── enumerations.lua
│   │   ├── nextbots.lua             # Nextbot registration system
│   │   ├── possession.lua           # Possession system
│   │   ├── spawners.lua             # Spawner system
│   │   ├── spawnmenu.lua            # Spawn menu integration
│   │   ├── weapons.lua              # Weapon management
│   │   ├── resources.lua            # Resource management
│   │   ├── nodegraph.lua            # Navigation system
│   │   ├── meta/                    # Metatable extensions
│   │   │   ├── entity.lua
│   │   │   ├── npc.lua
│   │   │   ├── player.lua
│   │   │   ├── phys.lua
│   │   │   └── vector.lua
│   │   └── modules/                 # Utility modules
│   │       ├── coroutine.lua
│   │       ├── debugoverlay.lua
│   │       ├── math.lua
│   │       ├── navmesh.lua
│   │       ├── net.lua
│   │       ├── string.lua
│   │       ├── table.lua
│   │       ├── util.lua
│   │       └── ...
│   ├── entities/                     # Entity definitions
│   │   ├── drgbase_nextbot/         # Base nextbot class
│   │   │   ├── shared.lua           # Base configuration
│   │   │   ├── ai.lua
│   │   │   ├── animations.lua
│   │   │   ├── awareness.lua
│   │   │   ├── detection.lua
│   │   │   ├── movements.lua
│   │   │   ├── path.lua
│   │   │   ├── patrol.lua
│   │   │   ├── possession.lua
│   │   │   ├── relationships.lua
│   │   │   ├── status.lua
│   │   │   ├── weapons.lua
│   │   │   └── ...
│   │   ├── npc_drg_zombie.lua       # Example: Zombie NPC
│   │   ├── npc_drg_headcrab.lua     # Example: Headcrab NPC
│   │   ├── npc_drg_antlion.lua      # Example: Antlion NPC
│   │   ├── proj_drg_default/        # Base projectile class
│   │   ├── spwn_drg_default/        # Base spawner class
│   │   └── ...
│   └── weapons/                      # Weapon definitions
│       ├── drgbase_weapon/          # Base weapon class
│       ├── gmod_tool/stools/        # Developer tools
│       │   ├── drgbase_tool_info.lua
│       │   ├── drgbase_tool_damage.lua
│       │   ├── drgbase_tool_faction.lua
│       │   └── ...
│       └── weapon_drg_*.lua         # Example weapons
├── materials/
│   ├── drgbase/                     # DrGBase UI icons and materials
│   │   └── icon16.png
│   └── entities/                    # Entity icons for spawn menu
│       ├── npc_drg_zombie.png
│       ├── npc_drg_headcrab.png
│       └── ...
├── particles/                        # Particle effect definitions
└── README.md                         # Basic readme file
```

**Key directories:**
- `lua/autorun/drgbase.lua` - First file loaded, initializes the framework
- `lua/drgbase/` - Core framework code and utilities
- `lua/entities/drgbase_nextbot/` - Base nextbot class (inherited by all DrGBase NPCs)
- `lua/entities/npc_drg_*/` - Example NPC implementations
- `materials/entities/` - Spawn menu icons for NPCs

## Server Configuration

### Dedicated Server Setup

If you're running a dedicated Garry's Mod server, follow these additional steps:

#### Method 1: Workshop Collection (Recommended)

1. **Create a Workshop Collection**:
   - Visit the Steam Workshop and create a new collection
   - Add DrGBase to the collection
   - Note the collection ID from the URL

2. **Configure server.cfg**:
   ```
   // Add to server.cfg or autoexec.cfg
   host_workshop_collection "YOUR_COLLECTION_ID"
   ```

3. **Restart the server**:
   - The server will automatically download and load DrGBase from the Workshop

#### Method 2: Manual Installation on Server

1. **Upload files to server**:
   - Upload the entire `drgbase` folder to `garrysmod/addons/` on your server
   - Ensure file permissions are correct (755 for directories, 644 for files)

2. **Generate resource list** (if using FastDL):
   - DrGBase automatically adds resources via `resource.AddFile()` calls
   - Materials are sent to clients automatically
   - No additional FastDL configuration needed for DrGBase core files

### Server ConVars

You can configure DrGBase behavior on your server using these ConVars in `server.cfg`:

```
// AI Configuration
drgbase_ai_sight 1                    // Enable/disable sight detection (0 or 1)
drgbase_ai_hearing 1                  // Enable/disable sound detection (0 or 1)
drgbase_ai_patrol 1                   // Enable/disable patrol behavior (0 or 1)
drgbase_ai_omniscient 0               // NPCs know player position without seeing (0 or 1)
drgbase_ai_radius 5000                // Maximum detection range (default: 5000)

// Combat Configuration
drgbase_multiplier_health 1.0         // Health multiplier for all NPCs (0.1 - 10)
drgbase_multiplier_damage_players 1.0 // Damage multiplier vs players (0.1 - 10)
drgbase_multiplier_damage_npc 1.0     // Damage multiplier vs NPCs (0.1 - 10)
drgbase_multiplier_speed 1.0          // Movement speed multiplier (0.1 - 10)

// Possession System
drgbase_possession_enable 1           // Enable possession system (0 or 1)
drgbase_possession_allow_lockon 1     // Enable lock-on targeting (0 or 1)

// Weapon System
drgbase_give_weapons 1                // Allow players to give weapons to NPCs (0 or 1)

// Optimization
drgbase_precache_models 1             // Precache NPC models on load (0 or 1)
drgbase_precache_sounds 1             // Precache NPC sounds on load (0 or 1)
drgbase_remove_ragdolls -1            // Remove ragdolls after N seconds (-1 = never)
drgbase_ragdoll_fadeout 0             // Ragdoll fadeout time in seconds
drgbase_remove_dead 0                 // Also remove dead nextbots with ragdolls (0 or 1)
drgbase_ragdoll_collisions_disabled 0 // Disable ragdoll collisions (0 or 1)

// Pathfinding
drgbase_compute_delay 0.1             // Path computation delay (0.01 - 3 seconds)
drgbase_avoid_obstacles 1             // Avoid obstacles during pathfinding (0 or 1)

// Debug (Development only)
drgbase_debug_relationships 0         // Debug relationship system (0 or 1)
drgbase_debug_traces 0                // Debug trace lines (0 or 1)
drgbase_debug_trajectories 0          // Debug projectile trajectories (0 or 1)
```

### FastDL Configuration (Optional)

If you're using FastDL for faster downloads:

1. **DrGBase resources are automatically registered**
   - The framework uses `resource.AddFile()` for all materials
   - No manual resource list needed

2. **Set up FastDL server** (if not already configured):
   ```
   sv_downloadurl "http://your-fastdl-server.com/garrysmod/"
   sv_allowdownload 1
   sv_allowupload 1
   ```

3. **Upload materials to FastDL**:
   - Copy `materials/` and `particles/` folders to your FastDL server
   - Maintain the same directory structure

### Workshop Setup for Custom Addons

If you're developing custom NPCs using DrGBase:

1. **Ensure DrGBase is a dependency**:
   - Add DrGBase to your addon's Workshop dependencies
   - Players will automatically download DrGBase when they subscribe to your addon

2. **In your addon.json** (if creating custom addon):
   ```json
   {
       "title": "My Custom NPCs",
       "type": "gamemode",
       "tags": ["fun", "roleplay"],
       "dependencies": ["DRGBASE_WORKSHOP_ID"]
   }
   ```

## Next Steps

Once installation is verified:
1. Test the example NPCs
2. Explore the developer tools
3. Read the Quick Start guide

---

**Previous:** [Introduction](./01-introduction.md) | **Next:** [Quick Start Guide](./03-quick-start.md)
