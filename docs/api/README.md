# DrGBase API Reference

Complete API reference for all DrGBase functions, hooks, and properties.

## Quick Start

### Creating an NPC

```lua
if not DrGBase then return end
ENT.Base = "drgbase_nextbot"

ENT.PrintName = "My NPC"
ENT.Category = "My NPCs"
ENT.Models = {"models/player/kleiner.mdl"}
ENT.SpawnHealth = 100

if SERVER then
    function ENT:CustomInitialize()
        self:SetDefaultRelationship(D_HT)
    end

    function ENT:OnMeleeAttack(enemy)
        self:Attack({damage = 10, type = DMG_SLASH})
    end
end

AddCSLuaFile()
DrGBase.AddNextbot(ENT)
```

### Common Functions

```lua
-- Detection
self:HasEnemy()                  -- Has current enemy
self:GetEnemy()                  -- Get enemy entity
self:Visible(ent)                -- Can see entity

-- Movement
self:FollowPath(target)          -- Follow to position/entity
self:AddPatrolPos(pos)           -- Add patrol point
self:RandomPos(radius)           -- Random nearby position

-- Combat
self:Attack(data, callback)      -- Deal melee damage
self:SetEnemy(ent)               -- Set enemy target

-- Relationships
self:GetRelationship(ent)        -- Get disposition towards entity
self:SetRelationship(ent, disp)  -- Set relationship

-- Animations
self:PlayActivityAndMove(act)    -- Play animation while moving
self:PlaySequence(seq)           -- Play sequence
```

---

## Organization

The API is organized in two ways for easy navigation:

### By Component Type

Detailed reference for each DrGBase component:

- **[Core Framework](./core/README.md)** - Global DrGBase functions and utilities
- **[Nextbot Base](./nextbot/README.md)** - All functions and properties for `drgbase_nextbot`
- **[Weapon Base](./weapon/README.md)** - All functions and properties for `drgbase_weapon`
- **[Projectile Base](./projectile/README.md)** - All functions and properties for `proj_drg_default`
- **[Metatable Extensions](./meta/README.md)** - Extensions to Entity, Player, NPC, PhysObj, and Vector
- **[Utility Modules](./modules/README.md)** - Helper functions and utilities

### By System/Topic

Quick access to specific systems:

- **[Global Functions](global-functions.md)** - DrGBase.* functions
- **[Enumerations](enumerations.md)** - Constants, factions, and enums
- **[Base Configuration](base-configuration.md)** - All ENT properties
- **[AI System](ai-system.md)** - AI behavior, detection, awareness
- **[Movement System](movement-system.md)** - Locomotion, pathfinding, patrol
- **[Combat System](combat-system.md)** - Weapons, attacks, damage
- **[Relationships](relationships.md)** - Factions, dispositions

---

## Quick Function Finder

### Most Common Functions

#### Creating NPCs
- `DrGBase.AddNextbot(ENT)` - Register a nextbot
- `ENT:CustomInitialize()` - Initialize your NPC
- `ENT:SetEnemy(ent)` - Set current enemy
- `ENT:FollowPath(target)` - Follow to position/entity

#### Combat
- `ENT:OnMeleeAttack(enemy)` - Handle melee attack
- `ENT:OnRangeAttack(enemy)` - Handle ranged attack
- `ENT:OnTakeDamage(dmg)` - Handle damage
- `ENT:OnDeath(dmg, hitgroup)` - Handle death
- `ENT:Attack(data)` - Deal melee damage

#### AI & Detection
- `ENT:GetEnemy()` - Get current enemy
- `ENT:HasEnemy()` - Check if has enemy
- `ENT:Visible(ent)` - Line of sight check
- `ENT:IsInSight(ent)` - Field of view check
- `ENT:SetRelationship(ent, disposition)` - Set relationship
- `ENT:FetchEnemy()` - Find best enemy target

#### Movement
- `ENT:FollowPath(target)` - Move to position/entity
- `ENT:StopPath()` - Stop movement
- `ENT:IsMoving()` - Check if moving
- `ENT:Jump()` - Make entity jump
- `ENT:AddPatrolPos(pos)` - Add patrol point
- `ENT:RandomPos(radius)` - Random nearby position

#### Animation
- `ENT:PlayActivityAndMove(act)` - Play animation while moving
- `ENT:PlaySequence(seq)` - Play sequence
- `ENT:PlayAnimation(seq)` - Play animation
- `ENT:SetAnimation(anim)` - Set animation
- `ENT:GetAnimation()` - Get current animation

---

## Convention Guide

### Function Naming

- **Set**(value) - Sets a value
- **Get**(void) - Gets a value
- **Is**(void) - Boolean check
- **Has**(void) - Boolean ownership/existence check
- **On**(args) - Hook/callback
- **Custom**(args) - Extension point
- **Fetch**(args) - Search/find operation
- **Add**(args) - Add item
- **Remove**(args) - Remove item

### Return Values

- `true/false` - Boolean success/failure
- `nil` - No value or not found
- `table` - Collection of results
- `Entity` - Entity reference
- `number` - Numeric value
- `string` - String value

### Parameters

- **ent** - Entity
- **ply** - Player
- **pos** - Vector position
- **ang** - Angle
- **dmg** - CTakeDamageInfo
- **tbl** - Table
- **class** - String class name
- **disp** - Disposition (D_HT, D_LI, D_FR, D_NU)

### Realms

Functions are marked with realm availability:

- 🔴 **SERVER** / 🖥️ **SERVER** - Server-side only
- 🔵 **CLIENT** / 💻 **CLIENT** - Client-side only
- 🟣 **SHARED** / 🌐 **SHARED** - Available on both

---

## Essential Properties

Quick reference for essential ENT properties:

```lua
-- Identity
ENT.PrintName = "NPC Name"
ENT.Category = "Category"
ENT.Models = {"models/path.mdl"}

-- Stats
ENT.SpawnHealth = 100
ENT.HealthRegen = 0

-- AI
ENT.BehaviourType = AI_BEHAV_BASE
ENT.MeleeAttackRange = 50
ENT.RangeAttackRange = 0

-- Relationships
ENT.DefaultRelationship = D_NU
ENT.Factions = {}

-- Movement
ENT.WalkSpeed = 100
ENT.RunSpeed = 200
```

See **[Base Configuration](base-configuration.md)** for complete property documentation.

---

## Getting Help

- **Check Examples**: See `lua/entities/npc_drg_*` for working examples
- **Console Errors**: Look for Lua errors in red text
- **Debug Commands**: Use `developer 1` for detailed output
- **Search Function**: Use Ctrl+F to search by function name
- **Community**: Ask in DrGBase discussion forums

---

## External Resources

- **Garry's Mod Wiki**: https://wiki.facepunch.com/gmod/
- **Activity List**: https://wiki.facepunch.com/gmod/Enums/ACT
- **Damage Types**: https://wiki.facepunch.com/gmod/Enums/DMG

---

## Navigation

- **[Getting Started](../getting-started/)** - New to DrGBase?
- **[Guides](../guides/)** - Detailed tutorials
- **[Examples](../examples/)** - Complete NPC examples
- **[Core Systems](../systems/)** - System documentation
- **[Architecture](../architecture/)** - Framework design
- **[Best Practices](../best-practices/)** - Coding guidelines

---

**Quick Links:**
- Browse by [Component Type](#by-component-type)
- Browse by [System/Topic](#by-systemtopic)
- [Quick Function Finder](#quick-function-finder)
- [Convention Guide](#convention-guide)
