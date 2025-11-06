# API Reference

Complete API reference for all DrGBase functions, hooks, and properties.

## Organization

The API is organized by component type:

### [Core Framework](./core/README.md)
Global DrGBase functions and utilities

### [Nextbot Base](./nextbot/README.md)
All functions and properties for `drgbase_nextbot`

### [Weapon Base](./weapon/README.md)
All functions and properties for `drgbase_weapon`

### [Projectile Base](./projectile/README.md)
All functions and properties for `proj_drg_default`

### [Metatable Extensions](./meta/README.md)
Extensions to Entity, Player, NPC, PhysObj, and Vector

### [Utility Modules](./modules/README.md)
Helper functions and utilities

## Quick Function Finder

### Most Common Functions

#### Creating NPCs
- `DrGBase.AddNextbot(ENT)` - Register a nextbot
- `ENT:CustomInitialize()` - Initialize your NPC
- `ENT:SetEnemy(ent)` - Set current enemy
- `ENT:MoveToPos(pos)` - Move to position

#### Combat
- `ENT:OnMeleeAttack(enemy)` - Handle melee attack
- `ENT:OnRangeAttack(enemy)` - Handle ranged attack
- `ENT:OnTakeDamage(dmg)` - Handle damage
- `ENT:OnDeath(dmg, delay, hitgroup)` - Handle death

#### AI & Detection
- `ENT:GetEnemy()` - Get current enemy
- `ENT:IsEnemyVisible()` - Check line of sight
- `ENT:FindEnemies()` - Find potential enemies
- `ENT:SetRelationship(ent, disposition)` - Set relationship

#### Movement
- `ENT:MoveToPos(pos)` - Move to position
- `ENT:StopMoving()` - Stop movement
- `ENT:IsMoving()` - Check if moving
- `ENT:Jump()` - Make entity jump

#### Animation
- `ENT:PlayAnimation(seq)` - Play animation
- `ENT:SetAnimation(anim)` - Set animation
- `ENT:GetAnimation()` - Get current animation

## Convention Guide

### Function Naming

- **Set**(value) - Sets a value
- **Get**(void) - Gets a value
- **Is**(void) - Boolean check
- **On**(args) - Hook/callback
- **Custom**(args) - Extension point
- **Find**(args) - Search operation
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

### Realms

- 🔴 **SERVER** - Server-side only
- 🔵 **CLIENT** - Client-side only
- 🟣 **SHARED** - Both realms

## Navigation

- Browse by [Component Type](#organization)
- Search by function name (Ctrl+F)
- See [Examples](../examples/README.md) for usage
- Check [Guides](../guides/README.md) for tutorials

---

**See also:**
- [Core Systems Documentation](../systems/README.md)
- [Architecture Guide](../architecture/README.md)
- [Examples](../examples/README.md)
