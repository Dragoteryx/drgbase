# Quick Start Guide

## Understanding the Framework

### Core Concepts

<!-- TODO: Explain fundamental concepts -->

#### Nextbots
<!-- What are nextbots in Source engine -->
<!-- How DrGBase extends them -->

#### Base Classes
<!-- drgbase_nextbot -->
<!-- drgbase_nextbot_human -->
<!-- drgbase_nextbot_sprite -->
<!-- drgbase_weapon -->
<!-- proj_drg_default -->

#### Hook System
<!-- How hooks work in DrGBase -->
<!-- When hooks are called -->
<!-- How to override behavior -->

#### Server-Client Architecture
<!-- What runs on server -->
<!-- What runs on client -->
<!-- How they communicate -->

## Framework Components

<!-- TODO: Brief overview of each major component -->

### AI System
<!-- Brief description -->
<!-- Key capabilities -->

### Movement System
<!-- Brief description -->
<!-- Key capabilities -->

### Combat System
<!-- Brief description -->
<!-- Key capabilities -->

### Relationship System
<!-- Brief description -->
<!-- Key capabilities -->

### Possession System
<!-- Brief description -->
<!-- Key capabilities -->

## Testing the Examples

<!-- TODO: Guide users through testing example NPCs -->

### Spawning Example NPCs

1. **Open the Spawn Menu** (Press Q)
2. **Navigate to NPCs tab**
3. **Find the DrGBase category**
4. **Spawn NPCs:**
   - `npc_drg_zombie` - Basic melee NPC
   - `npc_drg_headcrab` - Jumping NPC
   - `npc_drg_antlion` - Another example
   - `npc_drg_testhuman` - Human-like NPC

### Observing Behavior

<!-- TODO: What to look for when testing -->
<!-- - AI detection -->
<!-- - Movement and pathfinding -->
<!-- - Attack behaviors -->
<!-- - Faction relationships -->

### Using Developer Tools

<!-- TODO: How to use the included tools -->

#### Info Tool
<!-- How to inspect NPC state -->

#### Faction Tool
<!-- How to change factions -->

#### Relationship Tool
<!-- How to set relationships -->

#### AI Control Tools
<!-- Disable AI, omniscient mode, etc. -->

## Basic Configuration

<!-- TODO: Essential configuration options -->

### Server ConVars

```lua
drgbase_ai_radius 5000              -- Detection radius
drgbase_possession_enable 1         -- Enable possession
drgbase_give_weapons 1              -- Allow giving weapons
```

### Client ConVars

```lua
drgbase_possession_allow_lockon 1   -- Allow lock-on
drgbase_debug_traces 0              -- Debug visualization
```

## Understanding the File Structure

<!-- TODO: Brief overview of important directories -->

```
drgbase/
├── lua/
│   ├── autorun/
│   │   └── drgbase.lua           # Entry point
│   ├── drgbase/                  # Core modules
│   ├── entities/
│   │   ├── drgbase_nextbot/      # Base nextbot
│   │   ├── npc_drg_zombie.lua    # Example NPC
│   │   └── ...
│   └── weapons/
│       ├── drgbase_weapon/       # Base weapon
│       └── ...
```

## Common Tasks

<!-- TODO: Quick reference for common operations -->

### Spawning an NPC via Console

```lua
ent_create npc_drg_zombie
```

### Possessing an NPC

<!-- Steps to possess an NPC -->
1. Equip possession weapon
2. Aim at NPC
3. Primary fire
4. Control the NPC

### Giving a Weapon to an NPC

<!-- Using the property menu or console -->

### Setting Relationships

<!-- Using tools or console commands -->

## What's Next?

Now that you understand the basics:
1. **Create Your First NPC** - Follow the detailed guide
2. **Explore the Systems** - Learn about each component in depth
3. **Study the API** - Reference documentation for all functions
4. **Learn Best Practices** - Optimize and organize your code

---

**Previous:** [Installation](./02-installation.md) | **Next:** [Your First NPC](./04-first-npc.md)
