# Advanced Features

## Overview
This guide covers advanced DrGBase features including weapons, possession, custom AI, and special abilities. These features allow you to create more complex and unique NPCs.

## Weapons System

### Enabling Weapons

```lua
ENT.UseWeapons = true
ENT.Weapons = {"weapon_smg1", "weapon_ar2"}
ENT.DropWeaponOnDeath = true
ENT.AcceptPlayerWeapons = true
```

**Source:** `lua/entities/drgbase_nextbot/weapons.lua:1`

### Weapon Properties

| Property | Type | Description |
|----------|------|-------------|
| `UseWeapons` | boolean | Enable weapon system |
| `Weapons` | table | List of weapon classes to randomly equip |
| `DropWeaponOnDeath` | boolean | Drop weapon when killed |
| `AcceptPlayerWeapons` | boolean | Can pick up player weapons |

### Example: Armed Soldier

```lua
ENT.PrintName = "Soldier"
ENT.BehaviourType = AI_BEHAV_HUMAN  -- Required for weapons!

ENT.UseWeapons = true
ENT.Weapons = {"weapon_smg1", "weapon_ar2", "weapon_shotgun"}
ENT.DropWeaponOnDeath = true

-- Combat ranges for ranged NPC
ENT.MeleeAttackRange = 0
ENT.RangeAttackRange = 1000
ENT.ReachEnemyRange = 500

if SERVER then
    function ENT:CustomInitialize()
        self:SetDefaultRelationship(D_HT)
    end

    function ENT:OnRangeAttack(enemy, weapon)
        -- Custom weapon behavior
        self:FaceTowards(enemy)
        if self:IsInSight(enemy) then
            self:PrimaryFire()
        end
    end
end
```

### Weapon Functions

```lua
-- Check weapon state
self:HasWeapon()              -- Has any weapon
self:GetWeapon()              -- Get current weapon entity
self:IsWeaponPrimaryEmpty()   -- Primary ammo empty

-- Weapon actions
self:PrimaryFire()            -- Fire weapon
self:SecondaryFire()          -- Secondary fire
self:Reload()                 -- Reload weapon

-- Weapon management
self:PickupWeapon(weapon)     -- Pick up weapon entity
self:DropWeapon()             -- Drop current weapon
```

### Weapon Hooks

```lua
function ENT:OnPickupWeapon(weapon, class)
    -- Called when NPC picks up weapon
    print("Picked up:", class)
end

function ENT:OnDropWeapon(weapon, class)
    -- Called when NPC drops weapon
    print("Dropped:", class)
end
```

## Possession System

Possession allows players to control NPCs directly.

**Source:** `lua/entities/drgbase_nextbot/possession.lua:1`

### Enabling Possession

```lua
ENT.PossessionEnabled = true
ENT.PossessionPrompt = true
ENT.PossessionCrosshair = false
ENT.PossessionMovement = POSSESSION_MOVE_8DIR
ENT.PossessionViews = {
    {
        offset = Vector(0, 30, 20),
        distance = 100
    }
}
ENT.PossessionBinds = {}
```

### Movement Types

```lua
-- Movement modes
POSSESSION_MOVE_8DIR      -- 8-direction (WASD + diagonals)
POSSESSION_MOVE_NSEW      -- 4-direction (North/South/East/West)
POSSESSION_MOVE_COMPASS   -- Same as NSEW
POSSESSION_MOVE_1DIR      -- Forward only (W = forward)
POSSESSION_MOVE_FORWARD   -- Same as 1DIR
POSSESSION_MOVE_4DIR      -- 4-direction relative to camera
POSSESSION_MOVE_CUSTOM    -- Custom movement (override functions)
```

**Source:** `lua/drgbase/enumerations.lua:18`

### Camera Views

```lua
ENT.PossessionViews = {
    -- Third person view
    {
        offset = Vector(0, 30, 20),  -- Offset from NPC
        distance = 100,               -- Distance from NPC
    },
    -- First person view
    {
        offset = Vector(0, 0, 0),
        distance = 0,
        eyepos = true,  -- Use eye position
    }
}
```

### Key Bindings

```lua
ENT.PossessionBinds = {
    [IN_ATTACK] = {{
        coroutine = true,
        onkeydown = function(self)
            -- Called when attack key pressed
            self:EmitSound("Zombie.Attack")
            self:PlayActivityAndMove(ACT_MELEE_ATTACK1, 1, self.PossessionFaceForward)
        end
    }},
    [IN_ATTACK2] = {{
        onkeydown = function(self)
            -- Secondary attack
        end,
        onkeyup = function(self)
            -- Released
        end
    }},
    [IN_RELOAD] = {{
        onkeydown = function(self)
            -- Reload action
        end
    }}
}
```

**Available Keys:**
- `IN_ATTACK` - Left mouse / Primary attack
- `IN_ATTACK2` - Right mouse / Secondary attack
- `IN_RELOAD` - R key
- `IN_USE` - E key
- `IN_JUMP` - Space
- `IN_DUCK` - Ctrl
- `IN_SPEED` - Shift
- `IN_ATTACK3` - Custom key (33554432)

### Example: Possessable Zombie

```lua
ENT.PrintName = "Zombie"

ENT.PossessionEnabled = true
ENT.PossessionPrompt = true
ENT.PossessionMovement = POSSESSION_MOVE_8DIR
ENT.PossessionViews = {
    {
        offset = Vector(0, 30, 20),
        distance = 100
    },
    {
        offset = Vector(7.5, 0, 5),
        distance = 0,
        eyepos = true
    }
}
ENT.PossessionBinds = {
    [IN_ATTACK] = {{
        coroutine = true,
        onkeydown = function(self)
            self:EmitSound("Zombie.Attack")
            self:PlayActivityAndMove(ACT_MELEE_ATTACK1, 1, self.PossessionFaceForward)
        end
    }}
}
```

### Possession Functions

```lua
-- Check possession state
self:IsPossessed()              -- Is currently possessed
self:GetPossessor()             -- Get possessing player

-- Possession control
self:Possess(player)            -- Player possesses NPC
self:Dispossess()               -- Release possession

-- Utilities
self:PossessorTrace()           -- Trace where possessor is looking
self:IsPossessedByLocalPlayer() -- CLIENT: Is local player possessing
```

### Possession Hooks

```lua
function ENT:OnPossess(ply)
    -- Called when player starts possessing
    print(ply:Nick(), "is now controlling", self:GetClass())
end

function ENT:OnDispossess(ply)
    -- Called when player stops possessing
end

function ENT:PossessionThink(possessor)
    -- Called every tick while possessed
    -- Return delay for next think
    return 0.1
end
```

## Custom AI Behaviors

### Behavior Types

```lua
-- Standard AI
ENT.BehaviourType = AI_BEHAV_BASE

-- Human AI (with weapons)
ENT.BehaviourType = AI_BEHAV_HUMAN

-- Custom AI
ENT.BehaviourType = AI_BEHAV_CUSTOM
```

**Source:** `lua/drgbase/enumerations.lua:26`

### Custom AI Example

```lua
ENT.BehaviourType = AI_BEHAV_CUSTOM

if SERVER then
    function ENT:AIBehaviour()
        -- Custom AI loop
        while true do
            if self:HasEnemy() then
                -- Attack behavior
                local enemy = self:GetEnemy()
                if self:IsInRange(enemy, 100) then
                    self:Attack({damage = 10, type = DMG_SLASH})
                else
                    self:FollowPath(enemy)
                end
            else
                -- Idle behavior
                self:AddPatrolPos(self:RandomPos(1000))
                self:Wait(5)
            end

            self:YieldCoroutine(true)
        end
    end
end
```

### AI Hooks

```lua
-- Enemy hooks
function ENT:OnNewEnemy(enemy) end
function ENT:OnLoseEnemy(enemy) end
function ENT:OnChaseEnemy(enemy) end
function ENT:OnAvoidEnemy(enemy) end
function ENT:OnIdleEnemy(enemy) end

-- Combat hooks
function ENT:OnMeleeAttack(enemy) end
function ENT:OnRangeAttack(enemy) end

-- Patrol hooks
function ENT:OnIdle() end
function ENT:OnPatrolling(pos, patrol) end
function ENT:OnReachedPatrol(pos, patrol) end
function ENT:OnPatrolUnreachable(pos, patrol) end
```

## Coroutine System

DrGBase uses coroutines for complex behaviors.

### Coroutine Functions

```lua
-- Wait functions
self:Wait(seconds)                    -- Wait duration
self:PauseCoroutine(duration)         -- Pause coroutine
self:YieldCoroutine(interruptible)    -- Yield control
self:ResumeCoroutine()                -- Resume from pause

-- Callbacks
self:CallInCoroutine(func, ...)       -- Call function in coroutine
self:ReactInCoroutine(func, ...)      -- High-priority callback
```

### Example: Complex Attack

```lua
function ENT:OnMeleeAttack(enemy)
    -- Wind up
    self:PlaySequence("attack_windup")
    self:Wait(0.5)

    -- Strike
    self:EmitSound("npc/zombie/zombie_attack.wav")
    self:PlayActivityAndMove(ACT_MELEE_ATTACK1, 1, self.FaceEnemy)

    -- Cooldown
    self:Wait(2)
end
```

### Example: Leap Attack

```lua
function ENT:HeadcrabLeap(targetPos)
    -- Broadcast animation
    self:PlaySequence("jumpattack_broadcast")
    self:PauseCoroutine(0.5)

    -- Leap
    self:EmitSound("NPC_Headcrab.Attack")
    self:Leap(targetPos, 400)
    self.CanBite = true

    -- Wait for landing
    self:Wait(1)
    self.CanBite = false
end
```

## Special Abilities

### Leaping

```lua
-- Leap to position
self:Leap(targetPos, speed)

-- Example
function ENT:OnRangeAttack(enemy)
    local targetPos = enemy:GetPos() + Vector(0, 0, 50)
    self:Leap(targetPos, 500)
end
```

### Climbing

```lua
-- Enable climbing
ENT.ClimbLedges = true
ENT.ClimbLedgesMaxHeight = 100
ENT.ClimbLedgesMinHeight = 20
ENT.ClimbSpeed = 60
```

### Custom Footsteps

```lua
ENT.Footsteps = {
    [MAT_CONCRETE] = {
        "player/footsteps/concrete1.wav",
        "player/footsteps/concrete2.wav"
    },
    [MAT_METAL] = {
        "player/footsteps/metal1.wav",
        "player/footsteps/metal2.wav"
    }
}
```

## Utility Functions

### Movement

```lua
-- Path following
self:FollowPath(target)          -- Follow to entity or position
self:StopPath()                  -- Stop following path

-- Facing
self:FaceTo(pos)                 -- Face position instantly
self:FaceTowards(target)         -- Turn towards target over time

-- Position utilities
self:RandomPos(radius)           -- Random position nearby
self:GetPos():DrG_Away(otherPos) -- Position away from target
```

### Detection

```lua
-- Visibility
self:Visible(ent)                -- Can see entity
self:IsInSight(ent)              -- Entity in field of view
self:IsInRange(ent, range)       -- Entity within range

-- Enemy management
self:HasEnemy()                  -- Has current enemy
self:GetEnemy()                  -- Get current enemy
self:SetEnemy(ent)               -- Set enemy
```

### Combat

```lua
-- Attack function
self:Attack({
    damage = 10,
    type = DMG_SLASH,
    viewpunch = Angle(20, 0, 0),
    range = self.MeleeAttackRange
}, callback)

-- Check state
self:IsAttacking()               -- Currently attacking
```

## Performance Tips

1. **Use coroutines for delays** - Don't use timers excessively
2. **Limit think operations** - Return delay from CustomThink
3. **Cache frequently accessed data** - Store in variables
4. **Use event hooks** - Don't poll in Think functions

```lua
-- Good: Use coroutine
function ENT:OnMeleeAttack(enemy)
    self:PlayAnimation(ACT_MELEE_ATTACK1)
    self:Wait(1)
    self:Attack({damage = 10})
end

-- Bad: Use timer
function ENT:OnMeleeAttack(enemy)
    self:PlayAnimation(ACT_MELEE_ATTACK1)
    timer.Simple(1, function()
        if IsValid(self) then
            self:Attack({damage = 10})
        end
    end)
end
```

## Next Steps

- **[API Reference](../api/)** - Complete function documentation
- **[Guides](../guides/)** - Detailed tutorials
- **[Examples](../examples/)** - Study complex NPCs

---

**Previous:** [Relationships & Factions](04-relationships-factions.md) | **Next:** [API Reference](../api/README.md)
