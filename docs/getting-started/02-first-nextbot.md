# Creating Your First NextBot

## Overview
This guide will walk you through creating a simple custom NextBot using DrGBase. We'll create a basic enemy NPC that patrols, detects players, and attacks them.

## File Structure

DrGBase NPCs are entities located in the `lua/entities/` directory:

```
garrysmod/addons/your_addon/
└── lua/
    └── entities/
        └── npc_example/
            └── shared.lua  (or just a single .lua file)
```

For simple NPCs, you can use a single `.lua` file instead of a folder.

## Basic Template

Create a file: `lua/entities/npc_example_npc.lua`

```lua
if not DrGBase then return end -- Safety check
ENT.Base = "drgbase_nextbot" -- Use DrGBase as base

-- Misc --
ENT.PrintName = "Example NPC"
ENT.Category = "My NPCs"
ENT.Models = {"models/player/kleiner.mdl"}
ENT.BloodColor = BLOOD_COLOR_RED

-- Stats --
ENT.SpawnHealth = 100

-- AI --
ENT.MeleeAttackRange = 50
ENT.RangeAttackRange = 0

-- Relationships --
ENT.Factions = {FACTION_COMBINE} -- Optional faction

-- Required at end --
AddCSLuaFile()
DrGBase.AddNextbot(ENT)
```

## Step-by-Step Example

Let's create a simple zombie-like NPC:

### Step 1: Create the File

Create: `lua/entities/npc_my_zombie.lua`

```lua
if not DrGBase then return end
ENT.Base = "drgbase_nextbot"

-- Basic Information --
ENT.PrintName = "My Zombie"
ENT.Category = "My NPCs"
ENT.Models = {"models/Zombie/Classic.mdl"}
ENT.BloodColor = BLOOD_COLOR_GREEN

-- Sounds --
ENT.OnDamageSounds = {"Zombie.Pain"}
ENT.OnDeathSounds = {"Zombie.Die"}

-- Stats --
ENT.SpawnHealth = 100

-- AI --
ENT.MeleeAttackRange = 30
ENT.RangeAttackRange = 0
ENT.ReachEnemyRange = 30

-- Relationships --
ENT.Factions = {FACTION_ZOMBIES}

-- Movement --
ENT.UseWalkframes = true
ENT.WalkSpeed = 50
ENT.RunSpeed = 100

-- Required --
AddCSLuaFile()
DrGBase.AddNextbot(ENT)
```

### Step 2: Add Server-Side Logic

Add this **after** the properties but **before** the `AddCSLuaFile()` line:

```lua
if SERVER then

    -- Initialize
    function ENT:CustomInitialize()
        self:SetDefaultRelationship(D_HT) -- Hostile to everyone
    end

    -- AI Behavior
    function ENT:OnMeleeAttack(enemy)
        -- Play attack animation
        self:EmitSound("Zombie.Attack")
        self:PlayActivityAndMove(ACT_MELEE_ATTACK1, 1, self.FaceEnemy)
    end

    -- Idle Behavior
    function ENT:OnIdle()
        -- Random patrol when idle
        self:AddPatrolPos(self:RandomPos(1500))
    end

    function ENT:OnReachedPatrol()
        -- Wait when reaching patrol point
        self:Wait(math.random(3, 7))
    end

end
```

### Step 3: Add Attack Logic

Add the attack damage code:

```lua
if SERVER then

    -- ... (previous code) ...

    -- Animation Events (for attacks)
    function ENT:OnAnimEvent()
        if self:IsAttacking() and self:GetCycle() > 0.3 then
            -- Deal damage
            self:Attack({
                damage = 10,
                type = DMG_SLASH,
                viewpunch = Angle(20, math.random(-10, 10), 0)
            }, function(self, hit)
                if #hit > 0 then
                    self:EmitSound("Zombie.AttackHit")
                else
                    self:EmitSound("Zombie.AttackMiss")
                end
            end)
        end
    end

end
```

## Complete Example

Here's the complete NPC code:

```lua
if not DrGBase then return end
ENT.Base = "drgbase_nextbot"

-- Basic Information --
ENT.PrintName = "My Zombie"
ENT.Category = "My NPCs"
ENT.Models = {"models/Zombie/Classic.mdl"}
ENT.BloodColor = BLOOD_COLOR_GREEN

-- Sounds --
ENT.OnDamageSounds = {"Zombie.Pain"}
ENT.OnDeathSounds = {"Zombie.Die"}

-- Stats --
ENT.SpawnHealth = 100

-- AI --
ENT.MeleeAttackRange = 30
ENT.RangeAttackRange = 0
ENT.ReachEnemyRange = 30

-- Relationships --
ENT.Factions = {FACTION_ZOMBIES}

-- Movement --
ENT.UseWalkframes = true
ENT.WalkSpeed = 50
ENT.RunSpeed = 100

if SERVER then

    function ENT:CustomInitialize()
        self:SetDefaultRelationship(D_HT)
    end

    function ENT:OnMeleeAttack(enemy)
        self:EmitSound("Zombie.Attack")
        self:PlayActivityAndMove(ACT_MELEE_ATTACK1, 1, self.FaceEnemy)
    end

    function ENT:OnIdle()
        self:AddPatrolPos(self:RandomPos(1500))
    end

    function ENT:OnReachedPatrol()
        self:Wait(math.random(3, 7))
    end

    function ENT:OnAnimEvent()
        if self:IsAttacking() and self:GetCycle() > 0.3 then
            self:Attack({
                damage = 10,
                type = DMG_SLASH,
                viewpunch = Angle(20, math.random(-10, 10), 0)
            }, function(self, hit)
                if #hit > 0 then
                    self:EmitSound("Zombie.AttackHit")
                else
                    self:EmitSound("Zombie.AttackMiss")
                end
            end)
        end
    end

    function ENT:OnNewEnemy()
        self:EmitSound("Zombie.Alert")
    end

end

AddCSLuaFile()
DrGBase.AddNextbot(ENT)
```

## Testing Your NPC

1. **Reload Lua** (singleplayer):
   ```
   lua_openscript_cl lua/entities/npc_my_zombie.lua
   ```
   Or restart Garry's Mod

2. **Spawn the NPC**:
   - Open spawn menu (Q)
   - Go to NPCs tab
   - Look for "My NPCs" category
   - Click on "My Zombie"

3. **Test Behaviors**:
   - NPC should patrol when idle
   - NPC should chase and attack the player
   - NPC should play sounds and animations

## Common Properties

### Required Properties

```lua
ENT.Base = "drgbase_nextbot"  -- Always required
ENT.PrintName = "NPC Name"    -- Display name
ENT.Category = "Category"     -- Spawn menu category
```

### Essential Properties

```lua
-- Models & Appearance
ENT.Models = {"model/path.mdl"}
ENT.BloodColor = BLOOD_COLOR_RED

-- Health
ENT.SpawnHealth = 100

-- Combat Ranges
ENT.MeleeAttackRange = 50    -- Melee attack distance
ENT.RangeAttackRange = 0     -- Ranged attack distance (0 = disabled)
ENT.ReachEnemyRange = 50     -- How close to get to enemy

-- Movement
ENT.WalkSpeed = 100
ENT.RunSpeed = 200
```

## Essential Hooks

### Initialization

```lua
function ENT:CustomInitialize()
    -- Called when NPC spawns
    -- Set up initial state
end
```

### AI Hooks

```lua
function ENT:OnMeleeAttack(enemy)
    -- Called when in melee range
    -- Play animation, deal damage
end

function ENT:OnRangeAttack(enemy)
    -- Called when in range attack range
    -- Fire weapon, shoot projectile
end

function ENT:OnIdle()
    -- Called when NPC has nothing to do
    -- Add patrol points, play idle animations
end
```

### Event Hooks

```lua
function ENT:OnDeath(dmg, hitgroup)
    -- Called when NPC dies
    -- Spawn items, trigger events
end

function ENT:OnNewEnemy(enemy)
    -- Called when NPC spots a new enemy
    -- Play alert sound, alert allies
end
```

## Debugging Tips

### Console Commands

```lua
-- Show collision bounds
drgbase_display_collisions 1

-- Show sight visualization
drgbase_display_sight 1

-- Enable developer mode
developer 1
```

### Print Debugging

```lua
function ENT:CustomThink()
    print("Position:", self:GetPos())
    print("Enemy:", self:GetEnemy())
    print("Has Patrol:", self:HasPatrol())
end
```

### Common Issues

| Issue | Solution |
|-------|----------|
| NPC doesn't spawn | Check console for errors; verify `AddCSLuaFile()` and `DrGBase.AddNextbot(ENT)` |
| NPC doesn't move | Generate navmesh with `nav_generate` |
| NPC doesn't attack | Check attack ranges; verify enemy relationship |
| Animations don't play | Verify model has required activities; check animation properties |

## Next Steps

- **[Understanding Properties](03-understanding-properties.md)** - Learn about all available ENT properties
- **[AI Behaviors](../guides/ai-behaviors.md)** - Create complex AI behaviors
- **[Relationships](../api/relationships.md)** - Set up factions and relationships
- **[Weapons](../api/weapons.md)** - Give NPCs weapons

## Examples to Study

Check out these example NPCs in `lua/entities/`:
- `npc_drg_zombie.lua` - Simple melee NPC
- `npc_drg_headcrab.lua` - Leaping attack NPC
- `npc_drg_testnextbot.lua` - Basic test NPC

---

**Previous:** [Installation](01-installation.md) | **Next:** [Understanding Properties](03-understanding-properties.md)
