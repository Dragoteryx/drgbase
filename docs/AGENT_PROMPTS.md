# Agent Prompts for Parallel Documentation Work

Use these prompts to assign work to agents. Each prompt is self-contained with all necessary instructions.

---

## AGENT PROMPT 1: Getting Started Documentation

**Task:** Complete the "Getting Started" section of DrGBase documentation (5 files)

**Context:** You are documenting the DrGBase Garry's Mod addon, a nextbot framework for creating AI-driven NPCs. Your task is to write beginner-friendly documentation.

**Files to Complete:**
- `/home/user/drgbase-base/docs/getting-started/01-introduction.md`
- `/home/user/drgbase-base/docs/getting-started/02-installation.md`
- `/home/user/drgbase-base/docs/getting-started/03-quick-start.md`
- `/home/user/drgbase-base/docs/getting-started/04-first-npc.md`
- `/home/user/drgbase-base/docs/getting-started/05-configuration.md`

**Source Files to Read:**
- `README.md`
- `lua/autorun/drgbase.lua`
- `lua/entities/npc_drg_zombie.lua`
- `lua/entities/drgbase_nextbot/shared.lua`

**Instructions:**
1. Read each documentation file and identify all `<!-- TODO: ... -->` comments
2. Read the source files listed above to understand the framework
3. Fill in all TODO sections with clear, beginner-friendly content
4. For 04-first-npc.md, complete the full tutorial with working code
5. For 05-configuration.md, search the codebase for all `CreateConVar` calls and document them
6. Test any code examples you provide
7. Remove TODO comments when sections are complete

**Specific Tasks:**
- **01-introduction.md**: Explain what DrGBase is, key features, use cases, when to use it
- **02-installation.md**: Installation methods, verification, troubleshooting
- **03-quick-start.md**: Core concepts, component overview, testing examples
- **04-first-npc.md**: Complete tutorial with line-by-line explanations
- **05-configuration.md**: Document ALL ConVars with defaults and usage

**Quality Requirements:**
- Write for beginners with no DrGBase experience
- Include working code examples
- Provide clear explanations of concepts
- Test examples before documenting

**Deliverable:** Commit completed files with message: "Complete Getting Started documentation"

---

## AGENT PROMPT 2: Core API Documentation (DrGBase Global)

**Task:** Document the core DrGBase API (4 files)

**Context:** You are documenting the global DrGBase API functions and core utilities used throughout the framework.

**Files to Complete:**
- `/home/user/drgbase-base/docs/api/core/drgbase.md`
- `/home/user/drgbase-base/docs/api/core/entity-helpers.md`
- `/home/user/drgbase-base/docs/api/core/enumerations.md`
- `/home/user/drgbase-base/docs/api/core/colors.md`

**Source Files to Read:**
- `lua/autorun/drgbase.lua`
- `lua/drgbase/entity_helpers.lua`
- `lua/drgbase/enumerations.lua`
- `lua/drgbase/colors.lua`

**Instructions:**
1. Read each source file thoroughly
2. Find all function definitions (`function DrGBase.*`, `function ENT:*`, etc.)
3. For each function, document:
   - Full function signature
   - Each parameter (name, type, description, optional?)
   - Return values (type, description)
   - Detailed behavior description
   - Code example
   - Realm (SERVER/CLIENT/SHARED)
4. For enumerations.md, list ALL constants with their numeric values
5. For colors.md, list all color definitions with RGB values
6. Fill in all TODO sections
7. Remove TODO comments when complete

**API Documentation Format:**
```markdown
### FunctionName(param1, param2)

**Realm:** 🔴 SERVER

**Parameters:**
- `param1` (type) - Description
- `param2` (type, optional) - Description

**Returns:**
- `type` - Description

**Description:**
Detailed explanation of what this function does...

**Example:**
\`\`\`lua
-- Example code here
\`\`\`
```

**Quality Requirements:**
- Document EVERY function found
- Provide accurate parameter types
- Include realistic code examples
- Test examples before documenting
- Note any side effects or important behavior

**Deliverable:** Commit completed files with message: "Complete Core API documentation"

---

## AGENT PROMPT 3: Nextbot Base Configuration

**Task:** Document ALL configurable properties for drgbase_nextbot (1 large file)

**Context:** This is the most important reference document - it lists every property that can be set on a DrGBase nextbot entity.

**Files to Complete:**
- `/home/user/drgbase-base/docs/api/nextbot/base-config.md`

**Source Files to Read:**
- `lua/entities/drgbase_nextbot/shared.lua` (621 lines)
- `lua/entities/drgbase_nextbot/movements.lua`
- `lua/entities/drgbase_nextbot/animations.lua`
- `lua/entities/drgbase_nextbot/weapons.lua`
- `lua/entities/drgbase_nextbot/relationships.lua`
- `lua/entities/drgbase_nextbot/ai.lua`
- `lua/entities/drgbase_nextbot/detection.lua`
- `lua/entities/drgbase_nextbot/patrol.lua`
- `lua/entities/drgbase_nextbot/possession.lua`
- `lua/entities/drgbase_nextbot/status.lua`

**Instructions:**
1. Search ALL listed files for `ENT.*` property definitions
2. Look for default values being set (e.g., `ENT.SpawnHealth = 100`)
3. Document EVERY property found
4. Organize by category (Model, Health, Movement, Combat, AI, etc.)
5. Complete the "Complete Property List" table at the bottom
6. For each property document:
   - Property name
   - Type (number, string, boolean, table, Vector, Angle)
   - Default value
   - Description (what it does, when to use it)
   - Source file it's defined in
7. Add examples for each major category
8. Fill in all TODO sections

**Table Format:**
```markdown
| Property | Type | Default | Description | File |
|----------|------|---------|-------------|------|
| SpawnHealth | number | 100 | Starting health | status.lua |
```

**Quality Requirements:**
- Find EVERY property (expect 100+)
- Accurate default values
- Clear descriptions
- Organized by category
- Complete table with all properties

**Deliverable:** Commit completed file with message: "Complete Nextbot base configuration documentation - [X] properties documented"

---

## AGENT PROMPT 4: Nextbot AI System API

**Task:** Document the AI, detection, and awareness systems (3 files)

**Context:** Document how the AI system works including enemy detection, awareness, and decision making.

**Files to Complete:**
- `/home/user/drgbase-base/docs/api/nextbot/ai.md`
- `/home/user/drgbase-base/docs/api/nextbot/detection.md`
- `/home/user/drgbase-base/docs/api/nextbot/awareness.md`

**Source Files to Read:**
- `lua/entities/drgbase_nextbot/ai.lua` (187 lines)
- `lua/entities/drgbase_nextbot/detection.lua` (244 lines)
- `lua/entities/drgbase_nextbot/awareness.lua` (262 lines)

**Instructions:**
1. Read each source file line by line
2. Find all `function ENT:*` definitions
3. Document each function using the API format (see Agent Prompt 2)
4. Fill in all TODO sections with implementation details
5. Explain how systems interact (detection → awareness → AI decisions)
6. Provide examples of customizing AI behavior

**Specific Focus:**
- **ai.md**: Enemy management, AI state, target selection, enemy tracking
- **detection.md**: Vision system (FOV, range, LOS), sound detection
- **awareness.md**: Entity perception, memory, awareness vs detection difference

**Quality Requirements:**
- Document all functions
- Explain HOW the AI works, not just WHAT functions exist
- Provide practical examples
- Explain detection logic and filters

**Deliverable:** Commit completed files with message: "Complete AI system API documentation"

---

## AGENT PROMPT 5: Nextbot Movement & Navigation API

**Task:** Document movement, pathfinding, and patrol systems (3 files)

**Context:** Document how NPCs move, pathfind, and patrol.

**Files to Complete:**
- `/home/user/drgbase-base/docs/api/nextbot/movement.md`
- `/home/user/drgbase-base/docs/api/nextbot/path.md`
- `/home/user/drgbase-base/docs/api/nextbot/patrol.md`

**Source Files to Read:**
- `lua/entities/drgbase_nextbot/movements.lua` (702 lines)
- `lua/entities/drgbase_nextbot/locomotion.lua` (106 lines)
- `lua/entities/drgbase_nextbot/path.lua` (158 lines)
- `lua/entities/drgbase_nextbot/patrol.lua` (226 lines)

**Instructions:**
1. Find all movement-related functions
2. Document using standard API format
3. Explain movement control, speed, jumping, climbing
4. Document pathfinding system
5. Document patrol point management
6. Fill in all TODO sections
7. Provide examples for common movement scenarios

**Quality Requirements:**
- Document all movement functions
- Explain difference between locomotion and movement
- Provide pathfinding examples
- Document climb and jump mechanics

**Deliverable:** Commit completed files with message: "Complete movement and navigation API documentation"

---

## AGENT PROMPT 6: Nextbot Combat & Weapons API

**Task:** Document the combat and weapon systems (1 file)

**Context:** Document how NPCs fight, use weapons, and deal damage.

**Files to Complete:**
- `/home/user/drgbase-base/docs/api/nextbot/weapons.md`

**Source Files to Read:**
- `lua/entities/drgbase_nextbot/weapons.lua` (537 lines)

**Instructions:**
1. Read weapons.lua thoroughly (it's large)
2. Find all combat-related functions
3. Document weapon management (give, remove, switch)
4. Document melee attack system
5. Document ranged attack system
6. Document projectile firing
7. Document attack timing and cooldowns
8. Explain damage dealing
9. Fill in all TODO sections
10. Provide combat examples

**Quality Requirements:**
- Document all weapon functions
- Explain melee vs ranged attack flow
- Provide attack customization examples
- Document projectile usage

**Deliverable:** Commit completed file with message: "Complete combat and weapons API documentation"

---

## AGENT PROMPT 7: Nextbot Relationships & Factions API

**Task:** Document the relationship and faction systems (1 file)

**Context:** Document how NPCs relate to each other, factions, and the relationship priority system.

**Files to Complete:**
- `/home/user/drgbase-base/docs/api/nextbot/relationships.md`

**Source Files to Read:**
- `lua/entities/drgbase_nextbot/relationships.lua` (831 lines - LARGEST FILE)

**Instructions:**
1. Read relationships.lua carefully (it's the largest file)
2. Find all relationship-related functions
3. Document faction management
4. Document relationship types (entity, class, model, faction)
5. Explain relationship priority system (this is important!)
6. Document damage tolerance
7. Fill in all TODO sections
8. Provide comprehensive faction examples

**Quality Requirements:**
- Document all relationship functions
- Explain priority system clearly
- Provide multiple faction examples
- Explain when to use each relationship type

**Deliverable:** Commit completed file with message: "Complete relationships and factions API documentation"

---

## AGENT PROMPT 8: Nextbot Animation & Status API

**Task:** Document animation and status/health systems (2 files)

**Context:** Document animation control and health management.

**Files to Complete:**
- `/home/user/drgbase-base/docs/api/nextbot/animation.md`
- `/home/user/drgbase-base/docs/api/nextbot/status.md`

**Source Files to Read:**
- `lua/entities/drgbase_nextbot/animations.lua` (552 lines)
- `lua/entities/drgbase_nextbot/status.lua` (205 lines)

**Instructions:**
1. Document all animation functions
2. Explain sequences vs activities
3. Document pose parameters
4. Document animation events
5. Document gestures/layers
6. Document health management functions
7. Document regeneration system
8. Fill in all TODO sections

**Quality Requirements:**
- Clear explanation of animation systems
- Health system examples
- Animation event documentation

**Deliverable:** Commit completed files with message: "Complete animation and status API documentation"

---

## AGENT PROMPT 9: Weapon & Projectile Base API

**Task:** Document the weapon and projectile base classes (6 files)

**Context:** Document how to create custom weapons and projectiles.

**Files to Complete:**
- `/home/user/drgbase-base/docs/api/weapon/base-config.md`
- `/home/user/drgbase-base/docs/api/weapon/primary.md`
- `/home/user/drgbase-base/docs/api/weapon/secondary.md`
- `/home/user/drgbase-base/docs/api/weapon/functions.md`
- `/home/user/drgbase-base/docs/api/projectile/base-config.md`
- `/home/user/drgbase-base/docs/api/projectile/functions.md`

**Source Files to Read:**
- `lua/weapons/drgbase_weapon/shared.lua`
- `lua/weapons/drgbase_weapon/primary.lua`
- `lua/weapons/drgbase_weapon/secondary.lua`
- `lua/weapons/drgbase_weapon/misc.lua`
- `lua/weapons/drgbase_weapon/meta.lua`
- `lua/entities/proj_drg_default/shared.lua`
- `lua/entities/proj_drg_default/meta.lua`
- `lua/weapons/weapon_drg_ar2/shared.lua` (example)
- `lua/entities/proj_drg_grenade.lua` (example)

**Instructions:**
1. Document all SWEP.* properties for weapons
2. Document all weapon functions
3. Document primary/secondary attack systems
4. Document all ENT.* properties for projectiles
5. Document projectile functions and hooks
6. Fill in all TODO sections
7. Provide working examples

**Quality Requirements:**
- Complete weapon property reference
- Complete projectile property reference
- Working examples of custom weapons and projectiles

**Deliverable:** Commit completed files with message: "Complete weapon and projectile API documentation"

---

## AGENT PROMPT 10: Metatable Extensions & Utility Modules

**Task:** Document metatable extensions and utility modules (15 files)

**Context:** Document helper functions added to engine metatables and utility modules.

**Files to Complete:**
Metatable Extensions (5 files):
- `/home/user/drgbase-base/docs/api/meta/entity.md`
- `/home/user/drgbase-base/docs/api/meta/npc.md`
- `/home/user/drgbase-base/docs/api/meta/player.md`
- `/home/user/drgbase-base/docs/api/meta/physobj.md`
- `/home/user/drgbase-base/docs/api/meta/vector.md`

Utility Modules (10 files):
- `/home/user/drgbase-base/docs/api/modules/coroutine.md`
- `/home/user/drgbase-base/docs/api/modules/debugoverlay.md`
- `/home/user/drgbase-base/docs/api/modules/math.md`
- `/home/user/drgbase-base/docs/api/modules/navmesh.md`
- `/home/user/drgbase-base/docs/api/modules/net.md`
- `/home/user/drgbase-base/docs/api/modules/render.md`
- `/home/user/drgbase-base/docs/api/modules/string.md`
- `/home/user/drgbase-base/docs/api/modules/table.md`
- `/home/user/drgbase-base/docs/api/modules/timer.md`
- `/home/user/drgbase-base/docs/api/modules/util.md`

**Source Files to Read:**
- All files in `lua/drgbase/meta/`
- All files in `lua/drgbase/modules/`

**Instructions:**
1. For metatable extensions, find all `function META:*` definitions
2. For utility modules, find all exported functions
3. Document each using standard API format
4. Pay special attention to net.md - document the networking system in detail
5. Provide usage examples for each

**Quality Requirements:**
- Document all extensions and utilities
- Clear examples for each
- Detailed networking documentation

**Deliverable:** Commit completed files with message: "Complete metatable and utility module documentation"

---

## AGENT PROMPT 11: Systems Documentation

**Task:** Write comprehensive system guides (10 files)

**Context:** Write high-level documentation explaining how each major system works architecturally.

**Files to Complete:**
- `/home/user/drgbase-base/docs/systems/ai/README.md`
- `/home/user/drgbase-base/docs/systems/movement/README.md`
- `/home/user/drgbase-base/docs/systems/combat/README.md`
- `/home/user/drgbase-base/docs/systems/animation/README.md`
- `/home/user/drgbase-base/docs/systems/relationships/README.md`
- `/home/user/drgbase-base/docs/systems/possession/README.md`
- `/home/user/drgbase-base/docs/systems/status/README.md`
- `/home/user/drgbase-base/docs/systems/networking/README.md`
- `/home/user/drgbase-base/docs/systems/spawners/README.md`
- `/home/user/drgbase-base/docs/systems/resources/README.md`

**Source Files to Read:**
- Same as previous API documentation tasks
- Plus: `lua/drgbase/spawners.lua`, `lua/drgbase/resources.lua`, `lua/entities/spwn_drg_default.lua`

**Instructions:**
1. This is HIGHER-LEVEL than API docs - explain concepts, not just functions
2. For each system, write about:
   - How the system works architecturally
   - Key components and their interactions
   - Data flow through the system
   - Configuration options
   - Usage patterns and examples
   - Best practices
3. Fill in all TODO sections
4. Include diagrams or diagram descriptions where helpful

**Quality Requirements:**
- Focus on understanding, not just reference
- Explain the "why" and "how", not just "what"
- Multiple examples for each system
- Clear architecture explanations

**Deliverable:** Commit completed files with message: "Complete systems documentation"

---

## AGENT PROMPT 12: Tutorial Guides

**Task:** Write step-by-step tutorial guides (11 files)

**Context:** Write practical tutorials for common development tasks.

**Files to Complete:**
- `/home/user/drgbase-base/docs/guides/creating-npcs.md`
- `/home/user/drgbase-base/docs/guides/creating-weapons.md`
- `/home/user/drgbase-base/docs/guides/creating-projectiles.md`
- `/home/user/drgbase-base/docs/guides/factions.md`
- `/home/user/drgbase-base/docs/guides/possession.md`
- `/home/user/drgbase-base/docs/guides/animations.md`
- `/home/user/drgbase-base/docs/guides/pathfinding.md`
- `/home/user/drgbase-base/docs/guides/sound-effects.md`
- `/home/user/drgbase-base/docs/guides/debugging.md`
- `/home/user/drgbase-base/docs/guides/optimization.md`
- `/home/user/drgbase-base/docs/guides/spawners.md`

**Source Files to Study:**
- `lua/entities/npc_drg_zombie.lua`
- `lua/entities/npc_drg_headcrab.lua`
- `lua/entities/npc_drg_antlion.lua`
- `lua/weapons/weapon_drg_ar2/shared.lua`
- `lua/entities/proj_drg_grenade.lua`
- All tool files in `lua/weapons/gmod_tool/stools/`

**Instructions:**
1. Write step-by-step tutorials
2. Use working code from examples
3. Explain WHY, not just WHAT
4. Include troubleshooting sections
5. Add tips and best practices
6. Fill in all TODO sections
7. Test all code examples

**Quality Requirements:**
- Clear step-by-step instructions
- Working, tested code examples
- Explanations of concepts
- Troubleshooting help

**Deliverable:** Commit completed files with message: "Complete tutorial guides"

---

## AGENT PROMPT 13: Code Examples

**Task:** Create complete, working code examples (9 files)

**Context:** Write full, tested code examples for common scenarios.

**Files to Complete:**
- `/home/user/drgbase-base/docs/examples/simple-melee-npc.md`
- `/home/user/drgbase-base/docs/examples/ranged-npc.md`
- `/home/user/drgbase-base/docs/examples/flying-npc.md`
- `/home/user/drgbase-base/docs/examples/sprite-npc.md`
- `/home/user/drgbase-base/docs/examples/boss-npc.md`
- `/home/user/drgbase-base/docs/examples/custom-weapon.md`
- `/home/user/drgbase-base/docs/examples/custom-projectile.md`
- `/home/user/drgbase-base/docs/examples/advanced-ai.md`
- `/home/user/drgbase-base/docs/examples/faction-system.md`

**Source Files to Study:**
- All example NPCs in `lua/entities/npc_drg_*.lua`
- All example weapons and projectiles

**Instructions:**
1. Create COMPLETE, WORKING code for each example
2. Add line-by-line explanations
3. Include variations and customization options
4. TEST that examples actually work
5. Make examples ready to copy-paste
6. Fill in all TODO sections

**Quality Requirements:**
- Complete, working code
- Fully explained
- Tested in-game
- Ready to use

**Deliverable:** Commit completed files with message: "Complete code examples"

---

## AGENT PROMPT 14: Developer Tools & Best Practices

**Task:** Document developer tools and best practices (13 files)

**Context:** Document the included developer tools and write best practice guides.

**Files to Complete:**
Tools (7 files):
- `/home/user/drgbase-base/docs/tools/01-overview.md`
- `/home/user/drgbase-base/docs/tools/02-info-tool.md`
- `/home/user/drgbase-base/docs/tools/03-damage-tool.md`
- `/home/user/drgbase-base/docs/tools/04-faction-tool.md`
- `/home/user/drgbase-base/docs/tools/05-relationship-tool.md`
- `/home/user/drgbase-base/docs/tools/06-ai-tools.md`
- `/home/user/drgbase-base/docs/tools/07-entity-tools.md`

Best Practices (6 files):
- `/home/user/drgbase-base/docs/best-practices/01-code-organization.md`
- `/home/user/drgbase-base/docs/best-practices/02-performance.md`
- `/home/user/drgbase-base/docs/best-practices/03-networking.md`
- `/home/user/drgbase-base/docs/best-practices/04-security.md`
- `/home/user/drgbase-base/docs/best-practices/05-testing.md`
- `/home/user/drgbase-base/docs/best-practices/06-common-pitfalls.md`

**Source Files to Read:**
- All files in `lua/weapons/gmod_tool/stools/drgbase_tool_*.lua`

**Instructions:**
**For Tools:**
1. Document what each tool does
2. Document how to use (left/right click, options)
3. Provide usage examples
4. Explain when to use each tool

**For Best Practices:**
1. Write comprehensive best practice guides
2. Include DO and DON'T examples
3. Document common mistakes
4. Provide optimization tips
5. Document testing strategies

**Quality Requirements:**
- Complete tool documentation
- Practical best practices with examples
- Clear do/don't comparisons

**Deliverable:** Commit completed files with message: "Complete tools and best practices documentation"

---

## AGENT PROMPT 15: Reference Documentation

**Task:** Create quick reference tables (6 files)

**Context:** Create comprehensive reference tables for quick lookup.

**Files to Complete:**
- `/home/user/drgbase-base/docs/reference/convars.md`
- `/home/user/drgbase-base/docs/reference/hooks.md`
- `/home/user/drgbase-base/docs/reference/network-messages.md`
- `/home/user/drgbase-base/docs/reference/enums.md`
- `/home/user/drgbase-base/docs/reference/activities.md`
- `/home/user/drgbase-base/docs/reference/anim-events.md`

**Instructions:**
1. **convars.md**: Search codebase for all `CreateConVar` calls, list in table format
2. **hooks.md**: Compile list of all hooks from hooks.md API documentation
3. **network-messages.md**: Search for all `util.AddNetworkString` calls
4. **enums.md**: Compile from enumerations.md API documentation
5. **activities.md**: List common Source engine activity IDs used in DrGBase
6. **anim-events.md**: List animation events and their uses

**Table Format:**
```markdown
| Name | Default | Description | Realm |
|------|---------|-------------|-------|
| drgbase_ai_radius | 5000 | Detection radius | Server |
```

**Quality Requirements:**
- Complete reference tables
- Easy to scan and search
- Accurate information

**Deliverable:** Commit completed files with message: "Complete reference documentation"

---

## AGENT PROMPT 16: Architecture Documentation

**Task:** Complete architecture and design documentation (6 files)

**Context:** Explain the framework's architecture and design patterns.

**Files to Complete:**
- `/home/user/drgbase-base/docs/architecture/01-overview.md`
- `/home/user/drgbase-base/docs/architecture/02-file-structure.md`
- `/home/user/drgbase-base/docs/architecture/03-initialization.md`
- `/home/user/drgbase-base/docs/architecture/04-module-system.md`
- `/home/user/drgbase-base/docs/architecture/05-client-server.md`
- `/home/user/drgbase-base/docs/architecture/06-design-patterns.md`

**Source Files to Read:**
- `lua/autorun/drgbase.lua`
- Overall codebase structure
- All module files

**Instructions:**
1. Fill in architectural explanations
2. Create ASCII diagrams or describe diagrams
3. Explain load order and dependencies
4. Document design patterns used
5. Explain client-server separation
6. Document data flow
7. Fill in all TODO sections

**Quality Requirements:**
- Clear architectural explanations
- Diagrams where helpful
- Design pattern examples

**Deliverable:** Commit completed files with message: "Complete architecture documentation"

---

## General Instructions for All Agents

### Before Starting:
1. Read the relevant source files completely
2. Understand the context of what you're documenting
3. Look at existing completed documentation for style reference

### While Working:
1. Test all code examples
2. Use consistent terminology
3. Cross-reference related documentation
4. Add "See Also" sections
5. Remove TODO comments as you complete sections

### Quality Checklist:
- [ ] All TODO comments addressed or removed
- [ ] Code examples tested and working
- [ ] Cross-references accurate
- [ ] Consistent terminology
- [ ] No placeholder text
- [ ] Examples use realistic scenarios
- [ ] Functions documented with parameters and returns

### Commit Message Format:
```
<Category>: <What was completed>

- Bullet point details
- What was documented
- Any notable additions
```

Example:
```
API: Complete nextbot base configuration documentation

- Documented 127 ENT properties
- Created comprehensive property table
- Added examples for each category
- Cross-referenced related documentation
```

---

**These prompts are ready to be distributed to agents for parallel work!**
