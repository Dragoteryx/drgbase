# Architecture

Understanding DrGBase's architecture will help you build better addons and troubleshoot issues effectively.

## Contents

1. **[Overview](./01-overview.md)**
   - High-level architecture
   - Component relationships
   - Data flow
   - Execution lifecycle

2. **[File Structure](./02-file-structure.md)**
   - Directory organization
   - File naming conventions
   - Module locations
   - Base classes

3. **[Initialization System](./03-initialization.md)**
   - Autorun entry point
   - Load order
   - Module initialization
   - Dependency management

4. **[Module System](./04-module-system.md)**
   - Core modules
   - Utility modules
   - Metatable extensions
   - Module communication

5. **[Client-Server Architecture](./05-client-server.md)**
   - Realm separation
   - Network communication
   - State synchronization
   - Shared code

6. **[Design Patterns](./06-design-patterns.md)**
   - Inheritance pattern
   - Hook system
   - Registry pattern
   - Factory pattern
   - Observer pattern

## Architecture Diagrams

<!-- TODO: Add architecture diagrams -->

### Component Diagram
<!-- High-level component relationships -->

### Data Flow Diagram
<!-- How data flows through the system -->

### Class Hierarchy
<!-- Entity/weapon inheritance structure -->

## Quick Reference

### Load Order

1. `autorun/drgbase.lua` - Entry point
2. Core modules (`drgbase/*.lua`)
3. Metatable extensions (`drgbase/meta/*.lua`)
4. Utility modules (`drgbase/modules/*.lua`)
5. Base entities (`entities/drgbase_*/`)
6. Custom entities inherit from bases

### Key Files

- **Entry Point:** `lua/autorun/drgbase.lua`
- **Base Nextbot:** `lua/entities/drgbase_nextbot/shared.lua`
- **Base Weapon:** `lua/weapons/drgbase_weapon/shared.lua`
- **Networking:** `lua/drgbase/modules/net.lua`
- **AI System:** `lua/entities/drgbase_nextbot/ai.lua`

---

**For Implementation Details:** See [Core Systems](../systems/README.md)
**For API Details:** See [API Reference](../api/README.md)
