# Quick Start Guide

## Understanding the Framework

### Core Concepts

#### Nextbots

**What are Nextbots?**

Nextbots are advanced NPCs in the Source engine that use navigation meshes for pathfinding instead of node graphs. They are more flexible and dynamic than traditional NPCs.

**How DrGBase Extends Them**

DrGBase builds on Source engine nextbots by providing:
- A comprehensive API for AI, movement, and combat
- Hook-based customization system
- Modular architecture with separate systems for AI, relationships, weapons, etc.
- Built-in support for factions, possession, and advanced behaviors
- Easy-to-configure properties instead of complex code

#### Base Classes

DrGBase provides several base classes to build upon:

**`drgbase_nextbot`** - The foundation for all NPCs
- Located in `lua/entities/drgbase_nextbot/`
- Provides core functionality: AI, movement, combat, relationships
- Use this for general-purpose NPCs (zombies, monsters, creatures)
- Configurable via `ENT.*` properties

**`drgbase_nextbot_human`** - For humanoid NPCs
- Extends `drgbase_nextbot`
- Adds weapon support, crouching, ladder climbing
- Pre-configured animations for human models
- Use this for soldiers, citizens, or any weapon-wielding NPCs

**`drgbase_nextbot_sprite`** - For 2D sprite-based NPCs
- Extends `drgbase_nextbot`
- Renders using 2D sprites instead of 3D models
- Supports directional animations (4-dir and 8-dir)
- Great for retro-style or stylized NPCs

**`drgbase_weapon`** - For custom weapons
- Located in `lua/weapons/drgbase_weapon/`
- SWEP base with primary/secondary fire modes
- Supports projectile firing
- Compatible with DrGBase NPCs

**`proj_drg_default`** - For projectiles
- Located in `lua/entities/proj_drg_default/`
- Physics-based projectile system
- Configurable damage, effects, and behaviors
- Can be fired by weapons or NPCs

#### Hook System

DrGBase uses a **hook-based architecture** where you override specific functions to customize behavior.

**How Hooks Work**

Hooks are predefined functions that are called at specific moments:
- `CustomInitialize()` - Called when the NPC spawns
- `OnMeleeAttack(enemy)` - Called when performing a melee attack
- `OnDeath(dmg, hitgroup)` - Called when the NPC dies
- `OnNewEnemy(enemy)` - Called when a new enemy is detected
- `OnIdle()` - Called when the NPC has nothing to do

**When Hooks Are Called**

The framework automatically calls these hooks at the appropriate times. You just need to define them in your NPC file:

```lua
function ENT:CustomInitialize()
    -- Runs once when spawned
    self:SetBodygroup(1, 1)
end

function ENT:OnMeleeAttack(enemy)
    -- Runs when attacking an enemy
    self:EmitSound("Zombie.Attack")
    self:PlayActivityAndMove(ACT_MELEE_ATTACK1, 1, self.FaceEnemy)
end
```

**How to Override Behavior**

Simply define the hook function in your NPC's file. If you don't define it, the base class provides default behavior (or does nothing).

#### Server-Client Architecture

DrGBase follows Garry's Mod's server-client model:

**What Runs on Server**
- All AI logic and decision-making
- Movement and pathfinding
- Combat and damage calculation
- Relationship and faction management
- Entity spawning and removal

**What Runs on Client**
- Rendering and visual effects
- UI elements (crosshairs, possession HUD)
- Debug visualization
- Sound playback (some sounds)

**How They Communicate**
- Networked variables (`SetNW2Int`, `GetNW2Bool`, etc.) sync data from server to clients
- The `net` library sends custom messages
- Most configuration properties are automatically replicated

## Framework Components

DrGBase is organized into distinct systems that work together. Here's a brief overview of each:

### AI System

**What It Does**

The AI system handles enemy detection, target selection, and behavioral decision-making.

**Key Capabilities**
- Automatic enemy detection based on relationships and visibility
- Target prioritization (closest, most dangerous, etc.)
- Multiple behavior types: `AI_BEHAV_BASE` (monsters), `AI_BEHAV_HUMAN` (soldiers)
- Memory system - NPCs remember entities they've seen
- Omniscient mode for debugging (see all entities)
- Configurable attack ranges and engagement distances

**Key Properties**
```lua
ENT.RangeAttackRange = 1500  -- Distance for ranged attacks
ENT.MeleeAttackRange = 50    -- Distance for melee attacks
ENT.SpotDuration = 30        -- How long to remember enemies
ENT.Omniscient = false       -- Can see all entities
```

### Movement System

**What It Does**

Handles pathfinding, navigation, climbing, and locomotion.

**Key Capabilities**
- Automatic pathfinding using navigation mesh
- Ledge and ladder climbing
- Jumping over obstacles
- Patrol point system for idle behavior
- Speed control (walk/run)
- Support for flying/swimming NPCs

**Key Properties**
```lua
ENT.WalkSpeed = 100         -- Walking speed
ENT.RunSpeed = 200          -- Running speed
ENT.JumpHeight = 50         -- Jump power
ENT.ClimbLedges = false     -- Can climb ledges
ENT.ClimbLadders = false    -- Can climb ladders
```

### Combat System

**What It Does**

Manages melee attacks, ranged attacks, weapon handling, and damage.

**Key Capabilities**
- Melee attack system with customizable damage and timing
- Ranged attack system with projectiles or hitscan
- Weapon inventory for human NPCs
- Automatic aiming and targeting
- Attack animations and effects
- Damage dealing with viewpunch and knockback

**Key Properties**
```lua
ENT.UseWeapons = false           -- Can use weapons
ENT.Weapons = {"weapon_pistol"}  -- Starting weapons
ENT.DropWeaponOnDeath = false    -- Drop weapon on death
```

**Common Hooks**
```lua
function ENT:OnMeleeAttack(enemy)
    -- Custom melee behavior
end

function ENT:OnRangeAttack(enemy)
    -- Custom ranged behavior
end
```

### Relationship System

**What It Does**

Manages factions, enemy/ally relationships, and social behaviors.

**Key Capabilities**
- Faction-based relationships (zombies vs combine vs rebels)
- Per-entity relationship overrides
- Disposition system: Hate (D_HT), Like (D_LI), Neutral (D_NU), Fear (D_FR)
- Damage tolerance - allies can become hostile if damaged too much
- Relationship priorities (entity > class > model > faction)
- Compatible with Garry's Mod's faction system

**Key Properties**
```lua
ENT.Factions = {FACTION_ZOMBIES}     -- NPC's factions
ENT.DefaultRelationship = D_NU       -- Default to neutral
ENT.AllyDamageTolerance = 0.33       -- How much ally damage before hostile
```

**Faction Examples**
- `FACTION_ZOMBIES` - Zombie faction
- `FACTION_COMBINE` - Combine soldiers
- `FACTION_REBELS` - Resistance fighters
- `FACTION_PLAYERS` - Players

### Possession System

**What It Does**

Allows players to take direct control of NPCs.

**Key Capabilities**
- First-person or third-person camera control
- Custom key bindings for NPC abilities
- Lock-on targeting system
- Multiple camera views
- Movement modes: 1-directional, 4-directional, 8-directional
- Custom crosshairs and HUD

**Key Properties**
```lua
ENT.PossessionEnabled = true                  -- Can be possessed
ENT.PossessionMovement = POSSESSION_MOVE_8DIR -- 8-directional movement
ENT.PossessionViews = {                       -- Camera configuration
    {
        offset = Vector(0, 30, 20),
        distance = 100  -- Third-person view
    },
    {
        offset = Vector(0, 0, 0),
        distance = 0,   -- First-person view
        eyepos = true
    }
}
```

**Key Bindings Example**
```lua
ENT.PossessionBinds = {
    [IN_ATTACK] = {{
        coroutine = true,
        onkeydown = function(self)
            self:PrimaryFire()
        end
    }}
}
```

## Testing the Examples

DrGBase includes several example NPCs that demonstrate different features. Let's test them to understand how the framework works.

### Spawning Example NPCs

**Method 1: Using the Spawn Menu**

1. **Open the Spawn Menu** (Press Q)
2. **Navigate to the NPCs tab** (icon on the right side)
3. **Find the "DrGBase" category** (scroll down in the list)
4. **Click on an NPC to spawn it** where you're looking

**Method 2: Using the Console**

Open the console (~) and type:
```
ent_create npc_drg_zombie
```

**Available Example NPCs**

| NPC Name | Type | Description |
|----------|------|-------------|
| `npc_drg_zombie` | Melee | Basic zombie that attacks and releases a headcrab on death |
| `npc_drg_headcrab` | Leaping | Jumps at enemies, demonstrates leap attacks |
| `npc_drg_antlion` | Melee | Another melee example with different behavior |
| `npc_drg_testhuman` | Human | Humanoid NPC that can use weapons |
| `npc_drg_testnextbot` | Basic | Simple test NPC for debugging |
| `npc_drg_testsprite` | Sprite | 2D sprite-based NPC example |

### Observing Behavior

Now that you've spawned some NPCs, observe these behaviors:

**AI Detection**
- NPCs will detect you if you're in their line of sight
- Watch for them to turn toward you when spotted
- They remember your position even if you break line of sight
- Use `noclip` (console command) to observe without being detected

**Movement and Pathfinding**
- NPCs use the navigation mesh to find paths
- They automatically navigate around obstacles
- Watch them jump over small obstacles
- They can climb ladders (human NPCs) and ledges (if enabled)
- When idle, they patrol to random nearby locations

**Attack Behaviors**
- **Melee NPCs** (zombie, antlion):
  - Chase enemies until within `MeleeAttackRange`
  - Play attack animation
  - Deal damage at specific animation frame
- **Ranged NPCs** (human with weapon):
  - Maintain distance (`AvoidEnemyRange`)
  - Aim at target
  - Fire weapon with spread and recoil
- Watch for attack sounds and effects

**Faction Relationships**
- Spawn different NPCs to see faction interactions:
  - `npc_drg_zombie` (FACTION_ZOMBIES) vs `npc_manhack` (FACTION_COMBINE) = hostile
  - NPCs of the same faction ignore each other
  - Spawn a zombie and a citizen to watch them fight
- Use developer tools (below) to change factions

**Health and Damage**
- Attack NPCs to observe damage reactions
- They play hurt sounds and animations
- On death, they may become ragdolls or trigger special effects
- The zombie spawns a headcrab when killed (unless shot in head)

**Idle Behavior**
- When no enemies are present, NPCs patrol
- They move to random points within their patrol radius
- Some NPCs play idle sounds periodically
- You can customize idle behavior via `OnIdle()` hook

### Using Developer Tools

DrGBase includes several tools accessible via the Toolgun. These are invaluable for debugging and testing.

**Accessing the Tools**

1. Equip the Toolgun (press Q, click "Weapon" tab)
2. Look in the top-right corner for the tool menu
3. Find the "DrGBase" category
4. Select the tool you want

#### Info Tool (`drgbase_tool_info`)

Displays detailed information about an NPC in real-time.

**How to Use:**
- **Left Click** on an NPC to select it and view its info
- **Right Click** to cycle through different info pages:
  - **Status**: Health, state, current target
  - **AI**: Enemy, behavior, attack ranges
  - **Possession**: Possession status, controls
  - **Movement**: Speed, position, path
  - **Animation**: Current animation, sequence
  - **Viewcam**: Camera showing NPC's view
- **Reload** to deselect

**Use Case:** Understanding what the NPC is "thinking" and why it's behaving a certain way.

#### Faction Tool (`drgbase_tool_faction`)

Changes an NPC's factions.

**How to Use:**
1. Open the tool's options panel (bottom-left)
2. Add factions to the list (e.g., `FACTION_ZOMBIES`, `FACTION_COMBINE`)
3. **Left Click** on an NPC to assign those factions
4. **Right Click** to remove factions from an NPC

**Use Case:** Testing faction-based relationships, making NPCs fight or cooperate.

**Common Factions:**
```
FACTION_ZOMBIES
FACTION_COMBINE
FACTION_REBELS
FACTION_ANTLIONS
FACTION_PLAYERS
```

#### Relationship Tool (`drgbase_tool_relationship_simple`)

Sets direct relationships between NPCs or groups.

**How to Use:**
1. Select a relationship type in the options panel:
   - **Like** (D_LI) - Allies, won't attack each other
   - **Hate** (D_HT) - Enemies, will attack on sight
   - **Fear** (D_FR) - Will run away
   - **Ignore** (D_NU) - Neutral, ignore each other
2. **Left Click** on NPCs to select them (can select multiple)
3. **Right Click** on target NPC to set relationship
4. Hold **Shift + Right Click** to set relationships between all selected NPCs

**Use Case:** Creating specific enemy/ally pairings without changing factions.

#### AI Control Tools

**Disable AI Tool** (`drgbase_tool_disableai`)
- **Left Click** to toggle AI on/off for an NPC
- Frozen NPCs won't move or attack
- Great for setting up scenes or testing

**Omniscient Tool** (`drgbase_tool_omniscient`)
- **Left Click** to toggle omniscient mode
- NPC can see all entities regardless of line of sight
- Useful for testing AI targeting logic

**No Target Tool** (`drgbase_tool_notarget`)
- **Left Click** to toggle "no target" mode
- NPCs won't consider this entity as an enemy
- Like the `notarget` cheat but per-entity

**God Mode Tool** (`drgbase_tool_godmode`)
- **Left Click** to toggle invincibility
- NPC takes no damage
- Useful for long-term behavior testing

#### Other Useful Tools

**Damage Tool** (`drgbase_tool_damage`)
- Quickly damage NPCs for testing
- Adjustable damage amount

**Mover Tool** (`drgbase_tool_mover`)
- Move NPCs without picking them up
- Preserves their state

**Scale Tool** (`drgbase_tool_scale`)
- Change NPC size on the fly
- Test different scales

## Basic Configuration

DrGBase can be configured via console variables (ConVars). Here are the most important ones:

### Server ConVars

These affect server-side behavior and are replicated to clients:

```lua
-- AI System
drgbase_ai_radius 5000                  -- Max distance for enemy detection
drgbase_ai_sight 1                      -- Enable/disable vision system
drgbase_ai_hearing 1                    -- Enable/disable sound detection
drgbase_ai_omniscient 0                 -- All NPCs see everything (debug)
drgbase_ai_patrol 1                     -- Enable idle patrol behavior

-- Combat
drgbase_multiplier_health 1             -- Multiply all NPC health
drgbase_multiplier_damage_players 1     -- Multiply damage to players
drgbase_multiplier_damage_npc 1         -- Multiply damage to NPCs
drgbase_remove_dead 0                   -- Remove corpses (-1=never, 0=no, >0=seconds)

-- Movement
drgbase_multiplier_speed 1              -- Multiply all NPC speeds
drgbase_compute_delay 0.1               -- Path recomputation delay
drgbase_avoid_obstacles 1               -- Enable obstacle avoidance

-- Weapons & Possession
drgbase_give_weapons 1                  -- Allow players to give weapons to NPCs
drgbase_possession_enable 1             -- Enable possession system
drgbase_possession_targetall 1          -- Possession targets all entities

-- Ragdolls
drgbase_remove_ragdolls -1              -- Remove ragdolls (-1=never, 0=instant, >0=seconds)
drgbase_ragdoll_fadeout 3               -- Fade time before removal
drgbase_ragdoll_collisions_disabled 0   -- Disable ragdoll collisions

-- Performance
drgbase_precache_models 1               -- Precache models on load
drgbase_precache_sounds 1               -- Precache sounds on load
drgbase_projectile_tickrate -1          -- Projectile physics rate (-1=auto)
```

### Client ConVars

These affect client-side rendering and UI:

```lua
-- Possession
drgbase_possession_allow_lockon 1       -- Enable lock-on targeting

-- Debug Visualization
drgbase_debug_traces 0                  -- Show trace lines
drgbase_debug_trajectories 0            -- Show projectile trajectories
drgbase_debug_relationships 0           -- Show relationship info
drgbase_debug_animations 0              -- Show animation debug info

-- Nodegraph (Advanced)
drgbase_nodegraph_display 0             -- Show custom nodegraph
drgbase_nodegraph_distance 1500         -- Display distance
drgbase_nodegraph_type 2                -- Display type
drgbase_nodegraph_transparent 0         -- Transparent display

-- Other
drgbase_update_luminosity 1             -- Update player luminosity (for stealth)
```

### Setting ConVars

**In Console:**
```
drgbase_ai_radius 10000
```

**In Server Config (server.cfg):**
```
sbox_godmode 0
drgbase_multiplier_health 2
drgbase_ai_radius 7500
```

**In Lua (for addon developers):**
```lua
GetConVar("drgbase_ai_radius"):SetInt(10000)
```

## Understanding the File Structure

Here's an overview of DrGBase's directory structure:

```
garrysmod/addons/drgbase/
├── lua/
│   ├── autorun/
│   │   └── drgbase.lua                  # Entry point - loads everything
│   │
│   ├── drgbase/                         # Core framework modules
│   │   ├── modules/                     # Utility modules (math, string, etc.)
│   │   ├── meta/                        # Metatable extensions
│   │   ├── colors.lua                   # Color definitions
│   │   ├── entity_helpers.lua           # Entity helper functions
│   │   ├── enumerations.lua             # Faction/disposition constants
│   │   ├── nextbots.lua                 # Nextbot registration
│   │   ├── possession.lua               # Possession system
│   │   ├── weapons.lua                  # Weapon system
│   │   └── ...
│   │
│   ├── entities/
│   │   ├── drgbase_nextbot/             # Base nextbot class
│   │   │   ├── shared.lua               # Shared properties
│   │   │   ├── ai.lua                   # AI system
│   │   │   ├── movements.lua            # Movement system
│   │   │   ├── weapons.lua              # Combat system
│   │   │   ├── relationships.lua        # Faction/relationship system
│   │   │   ├── animations.lua           # Animation system
│   │   │   ├── detection.lua            # Vision/hearing
│   │   │   ├── awareness.lua            # Entity memory
│   │   │   ├── possession.lua           # Possession integration
│   │   │   └── ...
│   │   │
│   │   ├── drgbase_nextbot_human/       # Human NPC base
│   │   ├── drgbase_nextbot_sprite/      # Sprite NPC base
│   │   │
│   │   ├── npc_drg_zombie.lua           # Example: Zombie NPC
│   │   ├── npc_drg_headcrab.lua         # Example: Headcrab
│   │   ├── npc_drg_testhuman.lua        # Example: Human
│   │   │
│   │   └── proj_drg_default/            # Base projectile class
│   │
│   └── weapons/
│       ├── drgbase_weapon/              # Base weapon class
│       │   ├── shared.lua               # Shared properties
│       │   ├── primary.lua              # Primary fire
│       │   ├── secondary.lua            # Secondary fire
│       │   └── misc.lua                 # Utilities
│       │
│       └── weapon_drg_*/                # Example weapons
│
└── materials/, models/, sound/          # Assets
```

**Key Files for NPC Creation:**
- `lua/entities/drgbase_nextbot/shared.lua` - All configurable properties
- `lua/entities/npc_drg_zombie.lua` - Simple NPC example to copy from

## Common Tasks

Quick reference for frequent operations:

### Spawning an NPC via Console

```lua
ent_create npc_drg_zombie
```

Or spawn where you're looking:
```lua
ent_create npc_drg_zombie eyetrace
```

### Possessing an NPC

**Method 1: Using the Possession Tool**
1. Open spawn menu (Q)
2. Go to "Weapons" tab
3. Find "DrGBase Possession" in the DrGBase category
4. Equip the weapon
5. Aim at an NPC with `PossessionEnabled = true`
6. Left-click to possess
7. Use WASD to move, Mouse to look
8. Right-click to change camera view (if multiple views defined)
9. Left-click again to dispossess

**Method 2: Via Console**
```lua
drgbase_possess
```
While looking at an NPC.

### Giving a Weapon to an NPC

**Using the Property Menu (Context Menu):**
1. Hold C (context menu)
2. Right-click on a human NPC
3. Click "Give Weapon"
4. Select weapon from the list

**Using Console:**
```lua
-- Select the NPC first, then:
lua_run Entity(1):GiveWeapon("weapon_pistol")
```

**Via Code:**
```lua
local npc = ents.Create("npc_drg_testhuman")
npc:Spawn()
npc:GiveWeapon("weapon_smg1")  -- Give SMG after spawning
```

### Setting Relationships

**Using the Relationship Tool:**
1. Equip Toolgun
2. Select "DrGBase" → "Relationship (Simple)" tool
3. Choose relationship type (Like/Hate/Fear/Ignore)
4. Left-click NPCs to select them
5. Right-click target to apply relationship

**Using Console:**
```lua
-- Make entity 1 hate entity 2
lua_run Entity(1):AddEntityRelationship(Entity(2), D_HT)

-- Make all zombies hate all combine
lua_run for _, npc in ipairs(ents.FindByClass("npc_drg_*")) do npc:AddFactionRelationship(FACTION_COMBINE, D_HT) end
```

### Changing Factions

**Using the Faction Tool:**
1. Equip Toolgun
2. Select "DrGBase" → "Faction" tool
3. Add factions in the options panel
4. Left-click on NPC to assign factions

**Via Console:**
```lua
lua_run Entity(1):SetFactions({FACTION_ZOMBIES, FACTION_ANTLIONS})
```

## What's Next?

Now that you understand the basics:
1. **Create Your First NPC** - Follow the detailed guide
2. **Explore the Systems** - Learn about each component in depth
3. **Study the API** - Reference documentation for all functions
4. **Learn Best Practices** - Optimize and organize your code

---

**Previous:** [Installation](./02-installation.md) | **Next:** [Your First NPC](./04-first-npc.md)
