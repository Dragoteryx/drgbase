# DrGBase API Reference

## Overview
This directory contains complete API documentation for DrGBase NextBots. The API is divided into logical sections for easy navigation.

## Documentation Structure

### Core API
- **[Global Functions](global-functions.md)** - DrGBase.* functions
- **[Entity Functions](entity-functions.md)** - ENT:* methods
- **[Enumerations](enumerations.md)** - Constants and enums

### Systems
- **[AI System](ai-system.md)** - AI behavior, detection, awareness
- **[Movement System](movement-system.md)** - Locomotion, pathfinding, patrol
- **[Combat System](combat-system.md)** - Weapons, attacks, damage
- **[Relationships](relationships.md)** - Factions, dispositions

### Specialized
- **[Animations](animations.md)** - Animation control
- **[Sounds](sounds.md)** - Audio system
- **[Possession](possession.md)** - Player control system
- **[Utilities](utilities.md)** - Helper functions

## Quick Reference

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

## Realm Indicators

Functions are marked with realm availability:

- **🖥️ SERVER** - Server-side only
- **💻 CLIENT** - Client-side only
- **🌐 SHARED** - Available on both

## Function Categories

### Initialization
- `ENT:CustomInitialize()` 🖥️ - Called on spawn
- `ENT:CustomThink()` 🌐 - Called periodically
- `ENT:_BaseInitialize()` 🌐 - Internal initialization

### AI & Behavior
- `ENT:AIBehaviour()` 🖥️ - Custom AI loop
- `ENT:HandleEnemy()` 🖥️ - Enemy handling
- `ENT:OnIdle()` 🖥️ - Idle behavior

### Combat
- `ENT:OnMeleeAttack(enemy)` 🖥️ - Melee attack hook
- `ENT:OnRangeAttack(enemy)` 🖥️ - Ranged attack hook
- `ENT:Attack(data)` 🖥️ - Deal damage

### Events
- `ENT:OnDeath(dmg, hitgroup)` 🖥️ - Death hook
- `ENT:OnTakeDamage(dmg)` 🖥️ - Damage hook
- `ENT:OnNewEnemy(enemy)` 🖥️ - New enemy spotted

### Movement
- `ENT:FollowPath(target)` 🖥️ - Pathfinding
- `ENT:StopPath()` 🖥️ - Stop following path
- `ENT:FaceTo(pos)` 🖥️ - Face direction

### Detection
- `ENT:Visible(ent)` 🖥️ - Line of sight check
- `ENT:IsInSight(ent)` 🖥️ - Field of view check
- `ENT:IsInRange(ent, range)` 🖥️ - Distance check

## Property Reference

See **[Base Configuration](base-configuration.md)** for complete property documentation.

### Essential Properties

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

## Getting Help

- **Check Examples**: See `lua/entities/npc_drg_*` for working examples
- **Console Errors**: Look for Lua errors in red text
- **Debug Commands**: Use `developer 1` for detailed output
- **Community**: Ask in DrGBase discussion forums

## External Resources

- **Garry's Mod Wiki**: https://wiki.facepunch.com/gmod/
- **Activity List**: https://wiki.facepunch.com/gmod/Enums/ACT
- **Damage Types**: https://wiki.facepunch.com/gmod/Enums/DMG

---

## Navigation

- [Getting Started](../getting-started/) - New to DrGBase?
- [Guides](../guides/) - Detailed tutorials
- [Examples](../examples/) - Complete NPC examples
