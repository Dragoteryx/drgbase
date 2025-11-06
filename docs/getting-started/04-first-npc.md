# Your First NPC

This tutorial will guide you through creating a simple but functional custom NPC using DrGBase.

## Overview

We'll create a custom NPC called "Guard Dog" that:
- Has basic AI and detection
- Can patrol areas
- Attacks enemies with melee
- Uses custom sounds
- Has appropriate relationships

## Step 1: Create the File

<!-- TODO: Explain file creation and location -->

Create a new file in your addon:
```
garrysmod/addons/your_addon/lua/entities/npc_custom_guarddog.lua
```

## Step 2: Basic Setup

<!-- TODO: Provide and explain basic setup code -->

```lua
-- Check if DrGBase is installed
if not DrGBase then return end

-- Define entity properties
ENT.Base = "drgbase_nextbot"          -- Inherit from DrGBase nextbot
ENT.Type = "nextbot"
ENT.PrintName = "Guard Dog"
ENT.Category = "My Custom NPCs"
ENT.Spawnable = true
ENT.AdminOnly = false

-- TODO: Explain each line -->
```

## Step 3: Configure Appearance

<!-- TODO: Model and visual configuration -->

```lua
-- Model
ENT.Models = {"models/dog.mdl"}       -- Dog model from HL2

-- Size
ENT.ModelScale = 1.0
ENT.CollisionBounds = Vector(20, 20, 40)

-- TODO: Explain model selection and collision bounds -->
```

## Step 4: Configure Health and Stats

<!-- TODO: Health and basic stats -->

```lua
ENT.SpawnHealth = 75
ENT.HealthRegen = 0
ENT.MinPhysDamage = 10
ENT.MinFallDamage = 10

-- TODO: Explain each stat -->
```

## Step 5: Configure Movement

<!-- TODO: Movement configuration -->

```lua
ENT.MoveSpeed = 200                   -- Walking speed
ENT.MoveAcceleration = 400           -- How fast it accelerates
ENT.MoveDeceleration = 400           -- How fast it stops
ENT.JumpHeight = 64                  -- Jump height
ENT.StepHeight = 24                  -- Max step height

-- TODO: Explain movement values -->
```

## Step 6: Configure Combat

<!-- TODO: Combat configuration -->

```lua
ENT.MeleeAttackRange = 80            -- Attack range
ENT.MeleeAttackDamageMin = 10        -- Min damage
ENT.MeleeAttackDamageMax = 15        -- Max damage
ENT.MeleeAttackDelay = 1.0           -- Attack cooldown

ENT.RangeAttackRange = 0             -- No ranged attack

-- TODO: Explain combat settings -->
```

## Step 7: Configure AI

<!-- TODO: AI configuration -->

```lua
ENT.VisionRange = 4000               -- How far it can see
ENT.VisionFOV = 120                  -- Field of view (degrees)
ENT.HearingMaxDistance = 2000        -- How far it can hear

-- TODO: Explain AI perception -->
```

## Step 8: Set Up Faction

<!-- TODO: Faction configuration -->

```lua
ENT.Faction = FACTION_REBELS         -- Friendly to rebels
ENT.Factions = {FACTION_REBELS}

-- TODO: Explain factions -->
```

## Step 9: Add Animations

<!-- TODO: Animation configuration -->

```lua
ENT.IdleAnimation = ACT_IDLE
ENT.WalkAnimation = ACT_WALK
ENT.RunAnimation = ACT_RUN
ENT.JumpAnimation = ACT_JUMP
ENT.AttackAnimation = ACT_MELEE_ATTACK1

-- TODO: Explain animations -->
```

## Step 10: Add Server-Side Logic

<!-- TODO: Server-side code -->

```lua
if SERVER then

    function ENT:CustomInitialize()
        -- Called when NPC spawns
        -- TODO: Explain initialization
    end

    function ENT:OnMeleeAttack(enemy)
        -- Called when attacking
        -- TODO: Explain attack handling

        self:EmitSound("NPC_Dog.Angry")
    end

    function ENT:OnTakeDamage(dmg)
        -- Called when taking damage
        -- TODO: Explain damage handling

        return true  -- Allow damage
    end

    function ENT:OnDeath(dmg, delay, hitgroup)
        -- Called on death
        -- TODO: Explain death handling

        self:EmitSound("NPC_Dog.Die")
    end

end
```

## Step 11: Register the Entity

<!-- TODO: Explain registration -->

```lua
-- Add this at the end of the file
AddCSLuaFile()
DrGBase.AddNextbot(ENT)
```

## Step 12: Testing

<!-- TODO: Testing steps -->

### Load Your Addon

1. Place the file in your addon
2. Restart Garry's Mod or reload lua (`lua_openscript_cl autorun/drgbase.lua`)
3. Check console for errors

### Spawn Your NPC

1. Open spawn menu (Q)
2. Find "My Custom NPCs" category
3. Spawn "Guard Dog"

### Test Behavior

<!-- TODO: What to test -->
- Does it detect enemies?
- Does it move and attack?
- Does it play sounds?
- Does it respect relationships?

## Complete Code Example

<!-- TODO: Provide complete working example -->

```lua
if not DrGBase then return end

ENT.Base = "drgbase_nextbot"
ENT.Type = "nextbot"
ENT.PrintName = "Guard Dog"
ENT.Category = "My Custom NPCs"
ENT.Spawnable = true
ENT.AdminOnly = false

-- Model
ENT.Models = {"models/dog.mdl"}

-- Stats
ENT.SpawnHealth = 75
ENT.MoveSpeed = 200
ENT.MeleeAttackRange = 80
ENT.MeleeAttackDamageMin = 10
ENT.MeleeAttackDamageMax = 15

-- Faction
ENT.Faction = FACTION_REBELS

if SERVER then
    function ENT:OnMeleeAttack(enemy)
        self:EmitSound("NPC_Dog.Angry")
    end
end

AddCSLuaFile()
DrGBase.AddNextbot(ENT)
```

## Common Issues

<!-- TODO: Troubleshooting -->

### NPC Doesn't Appear in Spawn Menu
<!-- Solution -->

### NPC Spawns But Doesn't Move
<!-- Solution -->

### Errors in Console
<!-- Common errors and fixes -->

## Next Steps

Now that you've created your first NPC:
1. **Customize further** - Add unique behaviors
2. **Learn about hooks** - Override more functionality
3. **Study the examples** - See more complex implementations
4. **Explore the API** - Discover all available functions

---

**Previous:** [Quick Start Guide](./03-quick-start.md) | **Next:** [Configuration & ConVars](./05-configuration.md)
