# Architecture Overview

## High-Level Architecture

<!-- TODO: Describe the overall architecture -->
<!-- Include:
- Layered architecture (Core → Base → Custom)
- Module-based design
- Event-driven system
- Network architecture
-->

## Component Relationships

<!-- TODO: Diagram and explain component relationships -->

### Core Layer
<!-- DrGBase global, utilities, helpers -->

### Base Layer
<!-- drgbase_nextbot, drgbase_weapon, proj_drg_default -->

### Extension Layer
<!-- Custom NPCs, weapons, projectiles -->

### Support Layer
<!-- Tools, spawners, UI -->

## System Components

<!-- TODO: List and describe major components -->

### 1. Core Framework (`drgbase/`)
- **Purpose:** <!-- Core functionality -->
- **Key Files:** <!-- List important files -->
- **Responsibilities:** <!-- What it handles -->

### 2. Entity System (`entities/`)
- **Purpose:** <!-- Entity management -->
- **Key Files:** <!-- List base entities -->
- **Responsibilities:** <!-- What it handles -->

### 3. Weapon System (`weapons/`)
- **Purpose:** <!-- Weapon management -->
- **Key Files:** <!-- List base weapons -->
- **Responsibilities:** <!-- What it handles -->

### 4. Metatable Extensions (`drgbase/meta/`)
- **Purpose:** <!-- Extend engine metatables -->
- **Key Files:** <!-- List extension files -->
- **Responsibilities:** <!-- What it handles -->

### 5. Utility Modules (`drgbase/modules/`)
- **Purpose:** <!-- Helper functions -->
- **Key Files:** <!-- List modules -->
- **Responsibilities:** <!-- What it handles -->

## Data Flow

<!-- TODO: Explain data flow through the system -->

### Initialization Flow

```
Autorun
  ↓
Core Modules Load
  ↓
Metatable Extensions
  ↓
Utility Modules
  ↓
Base Entities Register
  ↓
Custom Entities Inherit & Register
  ↓
System Ready
```

### Runtime Flow

```
Entity Spawns
  ↓
Initialize() Called
  ↓
Think() Loop Begins
  ↓
Hook System Processes Events
  ↓
AI/Movement/Combat Systems Update
  ↓
Network State Synced to Clients
```

### Event Flow

```
Game Event (e.g., Take Damage)
  ↓
Engine Calls Hook
  ↓
DrGBase Processes
  ↓
Custom Hook Called
  ↓
Result Returned to Engine
```

## Execution Lifecycle

<!-- TODO: Explain entity lifecycle -->

### Nextbot Lifecycle

1. **Spawn**
   - `ENT:Initialize()`
   - `ENT:CustomInitialize()`
   - Resources loaded
   - Network vars initialized

2. **Active**
   - `ENT:Think()` - Every tick
   - `ENT:CustomThink()` - Per-entity logic
   - AI updates
   - Movement updates
   - Combat system updates

3. **Events**
   - `ENT:OnTakeDamage()`
   - `ENT:OnNewEnemy()`
   - `ENT:OnMeleeAttack()`
   - Custom hooks

4. **Death**
   - `ENT:OnDeath()`
   - Ragdoll creation
   - Cleanup
   - `ENT:OnRemove()`

### Weapon Lifecycle

<!-- TODO: Document weapon lifecycle -->

### Projectile Lifecycle

<!-- TODO: Document projectile lifecycle -->

## Threading Model

<!-- TODO: Explain threading/coroutine usage -->

### Think Loop
- Runs on server every tick
- Updates AI, movement, combat

### Coroutines
- Used for complex behaviors
- Non-blocking operations
- Sequential action execution

### Network Updates
- Automatic state synchronization
- Manual network messages for events

## Memory Management

<!-- TODO: Explain memory management patterns -->

### Entity References
<!-- How entities reference each other -->

### Cleanup
<!-- When and how cleanup occurs -->

### Resource Management
<!-- Precaching and resource loading -->

## Performance Considerations

<!-- TODO: Performance architecture notes -->

### Update Frequency
<!-- What runs every tick vs less frequently -->

### Network Optimization
<!-- How network traffic is minimized -->

### Computational Optimization
<!-- Expensive operations and caching -->

## Extension Points

<!-- TODO: Where/how developers can extend the system -->

### Hook System
<!-- All available hooks -->

### Custom Modules
<!-- Adding custom modules -->

### Metatable Extensions
<!-- Extending existing metatables -->

## Dependencies

<!-- TODO: List dependencies -->

### Required
- Garry's Mod (Source Engine)
- Lua 5.1+

### Optional
<!-- Any optional dependencies -->

---

**Next:** [File Structure](./02-file-structure.md)
