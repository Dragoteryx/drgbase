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

In Garry's Mod, NPCs are defined as entities. Each NPC needs its own Lua file in the correct location for the game to recognize it.

**File Location:**
Create a new file in your addon at this path:
```
garrysmod/addons/your_addon/lua/entities/npc_custom_guarddog.lua
```

**Important notes:**
- The filename must start with `npc_` for proper entity recognition
- The filename becomes the entity's spawn name (e.g., `npc_custom_guarddog`)
- For addons, always place entities in `lua/entities/` folder
- The file contains all the NPC's configuration and behavior

## Step 2: Basic Setup

Every DrGBase NPC starts with this basic setup code:

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
```

**Line-by-line explanation:**

- `if not DrGBase then return end` - Prevents errors if DrGBase isn't installed. The file stops loading if DrGBase is missing.
- `ENT.Base = "drgbase_nextbot"` - Makes your NPC inherit from DrGBase's nextbot system. This gives you access to all DrGBase features. **Never change this!**
- `ENT.Type = "nextbot"` - Tells Garry's Mod this is a nextbot entity (as opposed to a weapon or other entity type)
- `ENT.PrintName = "Guard Dog"` - The display name shown in the spawn menu
- `ENT.Category = "My Custom NPCs"` - The spawn menu category where your NPC appears
- `ENT.Spawnable = true` - Allows the NPC to be spawned from the spawn menu
- `ENT.AdminOnly = false` - If `true`, only admins can spawn this NPC

## Step 3: Configure Appearance

Configure how your NPC looks and its physical size:

```lua
-- Model
ENT.Models = {"models/dog.mdl"}       -- Dog model from HL2

-- Size
ENT.ModelScale = 1.0
ENT.CollisionBounds = Vector(20, 20, 40)
```

**Explanation:**

- `ENT.Models = {"models/dog.mdl"}` - A table of model paths. DrGBase randomly picks one when the NPC spawns. Use multiple models for variety: `{"models/dog.mdl", "models/other_dog.mdl"}`
- `ENT.ModelScale = 1.0` - Model size multiplier. `1.0` is normal size, `2.0` doubles the size, `0.5` halves it. Can also be a range: `{0.8, 1.2}` for random variation
- `ENT.CollisionBounds = Vector(20, 20, 40)` - Defines the NPC's collision box (width_x, width_y, height). This affects how the NPC collides with the world. Set it to roughly match your model's size

**Tip:** To find a model's ideal collision bounds, spawn the NPC and use `developer 1` in console to see debug info.

## Step 4: Configure Health and Stats

Set your NPC's health and damage thresholds:

```lua
ENT.SpawnHealth = 75
ENT.HealthRegen = 0
ENT.MinPhysDamage = 10
ENT.MinFallDamage = 10
```

**Explanation:**

- `ENT.SpawnHealth = 75` - Starting health when spawned. Default is `100`. Lower values make the NPC easier to kill
- `ENT.HealthRegen = 0` - Health regenerated per second. Set to `1` or higher for regenerating NPCs
- `ENT.MinPhysDamage = 10` - Minimum physics damage (from props, vehicles) needed to hurt the NPC. Prevents minor bumps from dealing damage
- `ENT.MinFallDamage = 10` - Minimum fall damage needed to hurt the NPC. Higher values let the NPC fall from greater heights safely

## Step 5: Configure Movement

Control how your NPC moves around the world:

```lua
ENT.RunSpeed = 200                   -- Running speed
ENT.WalkSpeed = 100                  -- Walking speed
ENT.Acceleration = 400               -- How fast it accelerates
ENT.Deceleration = 400               -- How fast it stops
ENT.JumpHeight = 64                  -- Jump height
ENT.StepHeight = 24                  -- Max step height
```

**Explanation:**

- `ENT.RunSpeed = 200` - How fast the NPC runs (units per second). Default is `200`. Higher = faster
- `ENT.WalkSpeed = 100` - Walking speed when not in combat. Default is `100`
- `ENT.Acceleration = 400` - How quickly the NPC reaches full speed. Higher = snappier movement
- `ENT.Deceleration = 400` - How quickly the NPC stops. Higher = quicker stops
- `ENT.JumpHeight = 64` - How high the NPC can jump (units). Default is `50`. Affects pathfinding over obstacles
- `ENT.StepHeight = 24` - Maximum height the NPC can step up without jumping. Default is `20`

**Note:** DrGBase uses `RunSpeed` for combat/chasing and `WalkSpeed` for patrolling. The original code example showed `MoveSpeed` which doesn't exist - use `RunSpeed` and `WalkSpeed` instead.

## Step 6: Configure Combat

Define your NPC's attack capabilities:

```lua
ENT.MeleeAttackRange = 80            -- Attack range
ENT.MeleeAttackDamageMin = 10        -- Min damage
ENT.MeleeAttackDamageMax = 15        -- Max damage
ENT.MeleeAttackDelay = 1.0           -- Attack cooldown

ENT.RangeAttackRange = 0             -- No ranged attack
```

**Explanation:**

- `ENT.MeleeAttackRange = 80` - How close the NPC needs to be to melee attack (units). Default is `50`. When an enemy is within this range, the NPC will attack
- `ENT.MeleeAttackDamageMin = 10` - Minimum melee damage dealt per attack
- `ENT.MeleeAttackDamageMax = 15` - Maximum melee damage dealt per attack. Actual damage is random between min and max
- `ENT.MeleeAttackDelay = 1.0` - Cooldown between attacks (seconds). Lower = faster attacks
- `ENT.RangeAttackRange = 0` - Maximum range for ranged attacks (units). Set to `0` to disable ranged attacks. For ranged NPCs, set this to something like `500` or `1000`

**Note:** The damage properties (`MeleeAttackDamageMin/Max`) are not built-in DrGBase properties - you need to use them in your attack functions (see Step 10).

## Step 7: Configure AI

Set up your NPC's perception and awareness:

```lua
ENT.SightRange = 4000                -- How far it can see
ENT.SightFOV = 120                   -- Field of view (degrees)
ENT.HearingCoefficient = 1           -- Hearing sensitivity
```

**Explanation:**

- `ENT.SightRange = 4000` - Maximum sight distance (units). Default is `15000`. The NPC can only detect visible entities within this range
- `ENT.SightFOV = 120` - Field of view in degrees. Default is `150`. `180` = can see directly to sides, `360` = can see all around
- `ENT.HearingCoefficient = 1` - Hearing sensitivity multiplier. Default is `1`. Higher values make the NPC hear sounds from farther away. Set to `0` to make the NPC deaf

**Additional AI properties you may want to set:**
```lua
ENT.ReachEnemyRange = 50             -- How close to get to enemy before attacking
ENT.AvoidEnemyRange = 0              -- Distance to keep from enemy (for ranged NPCs)
```

**Note:** The original example used `VisionRange` and `VisionFOV` - the correct DrGBase properties are `SightRange` and `SightFOV`. `HearingMaxDistance` doesn't exist - use `HearingCoefficient` instead.

## Step 8: Set Up Faction

Factions determine who the NPC is friendly or hostile towards:

```lua
ENT.Factions = {FACTION_REBELS}      -- This NPC is part of the Rebels faction
```

**Explanation:**

- `ENT.Factions = {FACTION_REBELS}` - A table of factions this NPC belongs to. NPCs in the same faction are friendly to each other

**Built-in factions in DrGBase:**
- `FACTION_PLAYERS` - Friendly to players
- `FACTION_REBELS` - Rebel faction (like Alyx, Barney)
- `FACTION_COMBINE` - Combine faction (enemies of rebels)
- `FACTION_ZOMBIES` - Zombie/headcrab faction
- `FACTION_ANTLIONS` - Antlion faction
- `FACTION_NEUTRAL` - Neutral to everyone

**Examples:**
```lua
-- Friendly to players
ENT.Factions = {FACTION_PLAYERS}

-- Part of multiple factions
ENT.Factions = {FACTION_REBELS, FACTION_PLAYERS}

-- Hostile to everyone by default
ENT.Factions = {}
```

**Additional setup (optional):**
You can also set default relationships in the `CustomInitialize` function (see Step 10):
```lua
self:SetDefaultRelationship(D_HT)  -- D_HT = Hate everyone not in your faction
```

## Step 9: Add Animations

Configure which animations play for different actions:

```lua
ENT.IdleAnimation = ACT_IDLE
ENT.WalkAnimation = ACT_WALK
ENT.RunAnimation = ACT_RUN
ENT.JumpAnimation = ACT_JUMP
```

**Explanation:**

- `ENT.IdleAnimation = ACT_IDLE` - Animation played when standing still
- `ENT.WalkAnimation = ACT_WALK` - Animation played when walking (patrolling)
- `ENT.RunAnimation = ACT_RUN` - Animation played when running (chasing enemies)
- `ENT.JumpAnimation = ACT_JUMP` - Animation played when jumping

**Animation Activities:**
DrGBase uses Garry's Mod activity constants (ACT_*). Common ones include:
- `ACT_IDLE` - Standing idle
- `ACT_WALK` - Walking
- `ACT_RUN` - Running
- `ACT_JUMP` - Jumping
- `ACT_MELEE_ATTACK1` - Melee attack (use in `OnMeleeAttack` function)
- `ACT_RANGE_ATTACK1` - Ranged attack (use in `OnRangeAttack` function)

**Note:** Attack animations are not set as properties - they're played in your attack functions (see Step 10).

**For models without certain animations:**
Some models only have walk animations. Use:
```lua
ENT.UseWalkframes = true  -- Use walk animation for running too
ENT.RunAnimation = ACT_WALK
```

## Step 10: Add Server-Side Logic

Server-side code handles NPC behavior, combat, and events. Wrap it in `if SERVER then`:

```lua
if SERVER then

    function ENT:CustomInitialize()
        -- Called when NPC spawns
        -- Set up initial state here
        self:SetDefaultRelationship(D_HT)  -- Hate everyone not in faction
    end

    function ENT:OnMeleeAttack(enemy)
        -- Called when the NPC decides to melee attack
        -- Play attack animation and deal damage here

        self:EmitSound("NPC_Dog.Angry")
        self:PlayActivityAndMove(ACT_MELEE_ATTACK1, 1, self.FaceEnemy)
    end

    function ENT:OnAnimEvent()
        -- Called during animations (like attack animations)
        -- Use this to deal damage at the right moment in the animation

        if self:IsAttacking() and self:GetCycle() > 0.3 then
            self:Attack({
                damage = math.random(10, 15),
                type = DMG_SLASH,
                viewpunch = Angle(5, math.random(-10, 10), 0)
            }, function(self, hit)
                if #hit > 0 then
                    self:EmitSound("NPC_Dog.AttackHit")
                else
                    self:EmitSound("NPC_Dog.AttackMiss")
                end
            end)
        end
    end

    function ENT:OnTakeDamage(dmg)
        -- Called when taking damage
        -- Return true to allow damage, false to block it
        -- Return a number to multiply damage (e.g., 2 for double damage)

        return true  -- Allow damage normally
    end

    function ENT:OnDeath(dmg, hitgroup)
        -- Called when the NPC dies
        -- dmg = DamageInfo object
        -- hitgroup = body part hit (HITGROUP_HEAD, etc.)

        self:EmitSound("NPC_Dog.Die")
    end

    function ENT:OnNewEnemy(enemy)
        -- Called when a new enemy is detected
        self:EmitSound("NPC_Dog.Alert")
    end

end
```

**Function explanations:**

- **`CustomInitialize()`** - Called once when spawned. Use for initial setup like setting relationships, bodygroups, etc.

- **`OnMeleeAttack(enemy)`** - Called when NPC is ready to melee attack. Play attack animation here using `self:PlayActivityAndMove()`.

- **`OnAnimEvent()`** - Called repeatedly during animations. Check `self:IsAttacking()` and animation cycle to deal damage at the right moment. Use `self:Attack()` to damage entities in front of the NPC.

- **`OnTakeDamage(dmg)`** - Called when damaged. Return `true` to allow damage, `false` to block, or a number to multiply damage.

- **`OnDeath(dmg, hitgroup)`** - Called when killed. Play death sounds or spawn items here.

- **`OnNewEnemy(enemy)`** - Called when a new enemy is detected. Play alert sounds here.

**Important methods:**
- `self:EmitSound(sound)` - Play a sound
- `self:PlayActivityAndMove(activity, speed, callback)` - Play animation and continue moving
- `self:Attack(data, callback)` - Damage entities in melee range
- `self:IsAttacking()` - Returns true if attack animation is playing
- `self:FaceEnemy` - Callback that makes NPC face their enemy

## Step 11: Register the Entity

At the very end of your file, add these two essential lines:

```lua
-- Add this at the end of the file
AddCSLuaFile()
DrGBase.AddNextbot(ENT)
```

**Explanation:**

- `AddCSLuaFile()` - Tells the server to send this file to clients. Required for proper client-server synchronization. **Must come first!**

- `DrGBase.AddNextbot(ENT)` - Registers your NPC with DrGBase and Garry's Mod. This makes your NPC appear in the spawn menu and initializes all DrGBase systems.

**Important:** These must be the **last two lines** of your file. Do not add any code after them.

## Step 12: Testing

Now let's test your NPC to ensure everything works correctly.

### Load Your Addon

1. **Place the file** in your addon at the correct path:
   ```
   garrysmod/addons/your_addon/lua/entities/npc_custom_guarddog.lua
   ```

2. **Restart Garry's Mod** or reload Lua files:
   - Full restart (safest method)
   - OR use console: `lua_openscript autorun/drgbase.lua` (may not work for all cases)

3. **Check console for errors**:
   - Press `` ` `` (tilde key) to open console
   - Look for any red error messages
   - DrGBase should print: `[DrGBase] Include file 'entities/npc_custom_guarddog.lua'` (or similar)

### Spawn Your NPC

1. **Open spawn menu** - Press `Q`
2. **Click the NPCs tab** (third icon from left)
3. **Find your category** - Scroll to "My Custom NPCs"
4. **Spawn your NPC** - Click on "Guard Dog" icon and left-click in the world to spawn

### Test Behavior

Here's what to test to ensure your NPC works correctly:

**Basic Functionality:**
- ✓ **Does it spawn without errors?** - Check console for red text
- ✓ **Does it have the correct model?** - Should use the dog model
- ✓ **Does it collide properly?** - Try walking into it

**AI and Detection:**
- ✓ **Does it detect enemies?** - Spawn a zombie (`npc_zombie`) nearby. Your Guard Dog should notice it within a few seconds if it's in view range
- ✓ **Does it chase enemies?** - It should run toward the zombie
- ✓ **Does it patrol when idle?** - Leave it alone and watch if it wanders around

**Combat:**
- ✓ **Does it attack?** - It should play attack animation when close to enemy
- ✓ **Does it deal damage?** - Enemy should take damage (check enemy health)
- ✓ **Does it play sounds?** - Listen for bark/growl sounds during attack

**Relationships:**
- ✓ **Is it friendly to rebels?** - Spawn `npc_alyx` or `npc_barney` - should not attack them
- ✓ **Is it hostile to zombies?** - Spawn `npc_zombie` - should attack
- ✓ **Is it friendly to players?** - Walk near it - should not attack you

**Health and Death:**
- ✓ **Can it take damage?** - Shoot it with a weapon
- ✓ **Does it die at 0 health?** - Deal enough damage to kill it
- ✓ **Does it play death sound?** - Listen when it dies
- ✓ **Does it create ragdoll?** - Body should ragdoll on death (if `RagdollOnDeath = true`)

### Debug Tips

Enable debug visualization:
```
developer 1
```

This shows:
- Collision bounds (wireframe box)
- Current activity/animation
- Target information
- Path visualization

## Complete Code Example

Here's the complete, working code for your Guard Dog NPC. Copy this into `lua/entities/npc_custom_guarddog.lua`:

```lua
if not DrGBase then return end

-- Base setup
ENT.Base = "drgbase_nextbot"
ENT.Type = "nextbot"
ENT.PrintName = "Guard Dog"
ENT.Category = "My Custom NPCs"
ENT.Spawnable = true
ENT.AdminOnly = false

-- Model and appearance
ENT.Models = {"models/dog.mdl"}
ENT.ModelScale = 1.0
ENT.CollisionBounds = Vector(20, 20, 40)

-- Health and stats
ENT.SpawnHealth = 75
ENT.HealthRegen = 0
ENT.MinPhysDamage = 10
ENT.MinFallDamage = 10

-- Movement
ENT.RunSpeed = 200
ENT.WalkSpeed = 100
ENT.Acceleration = 400
ENT.Deceleration = 400
ENT.JumpHeight = 64
ENT.StepHeight = 24

-- Combat
ENT.MeleeAttackRange = 80
ENT.RangeAttackRange = 0

-- AI and detection
ENT.SightRange = 4000
ENT.SightFOV = 120
ENT.HearingCoefficient = 1
ENT.ReachEnemyRange = 50
ENT.AvoidEnemyRange = 0

-- Faction
ENT.Factions = {FACTION_REBELS}

-- Animations
ENT.IdleAnimation = ACT_IDLE
ENT.WalkAnimation = ACT_WALK
ENT.RunAnimation = ACT_RUN
ENT.JumpAnimation = ACT_JUMP

-- Server-side behavior
if SERVER then

    function ENT:CustomInitialize()
        self:SetDefaultRelationship(D_HT)
    end

    function ENT:OnMeleeAttack(enemy)
        self:EmitSound("NPC_Dog.Angry")
        self:PlayActivityAndMove(ACT_MELEE_ATTACK1, 1, self.FaceEnemy)
    end

    function ENT:OnAnimEvent()
        if self:IsAttacking() and self:GetCycle() > 0.3 then
            self:Attack({
                damage = math.random(10, 15),
                type = DMG_SLASH,
                viewpunch = Angle(5, math.random(-10, 10), 0)
            }, function(self, hit)
                if #hit > 0 then
                    self:EmitSound("NPC_Dog.AttackHit")
                else
                    self:EmitSound("NPC_Dog.AttackMiss")
                end
            end)
        end
    end

    function ENT:OnTakeDamage(dmg)
        return true
    end

    function ENT:OnDeath(dmg, hitgroup)
        self:EmitSound("NPC_Dog.Die")
    end

    function ENT:OnNewEnemy(enemy)
        self:EmitSound("NPC_Dog.Alert")
    end

end

-- Register entity (must be last)
AddCSLuaFile()
DrGBase.AddNextbot(ENT)
```

## Common Issues

Here are solutions to common problems you might encounter:

### NPC Doesn't Appear in Spawn Menu

**Possible causes:**

1. **DrGBase not installed** - The `if not DrGBase then return end` check prevents the file from loading
   - Solution: Install DrGBase from the Steam Workshop

2. **Wrong file location** - File must be in `lua/entities/` folder
   - Solution: Check your file path is exactly: `garrysmod/addons/your_addon/lua/entities/npc_custom_guarddog.lua`

3. **Missing registration** - Forgot `AddCSLuaFile()` or `DrGBase.AddNextbot(ENT)`
   - Solution: Add both lines at the end of your file

4. **Lua errors preventing load** - Syntax errors in your code
   - Solution: Check console for red error messages. Common errors include missing `end`, unmatched quotes, or typos

5. **Category name issue** - Empty or invalid category
   - Solution: Make sure `ENT.Category` is set to a non-empty string

### NPC Spawns But Doesn't Move

**Possible causes:**

1. **Movement speed set to 0 or too low**
   - Solution: Set `ENT.RunSpeed = 200` and `ENT.WalkSpeed = 100`

2. **No enemies to chase** - NPC is idle
   - Solution: Spawn an enemy (like `npc_zombie`) nearby to trigger chase behavior

3. **Patrolling disabled by ConVar**
   - Solution: Run `drgbase_ai_patrol 1` in console

4. **Stuck on geometry** - Collision issues
   - Solution: Spawn NPC in open area. Adjust `ENT.CollisionBounds` or `ENT.StepHeight`

5. **NavMesh not generated** - For complex pathfinding
   - Solution: In single-player, open console and type `nav_generate`. This can take a few minutes

### NPC Doesn't Attack

**Possible causes:**

1. **No enemies detected** - NPC can't see or hasn't found an enemy
   - Solution: Make sure enemy is within `SightRange` and `SightFOV`. Spawn enemy directly in front of NPC

2. **Wrong faction relationships** - NPC thinks enemy is friendly
   - Solution: Check that NPC and enemy have different factions. Add `self:SetDefaultRelationship(D_HT)` in `CustomInitialize()`

3. **Attack range set to 0**
   - Solution: Set `ENT.MeleeAttackRange = 80` (or appropriate value)

4. **Missing attack function** - No `OnMeleeAttack` function defined
   - Solution: Add the `OnMeleeAttack` function from the complete example

### Errors in Console

**Common errors and fixes:**

**Error:** `attempt to call field 'AddNextbot' (a nil value)`
- **Cause:** DrGBase not loaded or not installed
- **Fix:** Install DrGBase, ensure it loads before your addon

**Error:** `'}' expected near...`
- **Cause:** Missing closing brace or `end` keyword
- **Fix:** Count your `function`/`end`, `if`/`end`, and `{`/`}` pairs. They must match

**Error:** `attempt to index field 'Models' (a nil value)`
- **Cause:** Trying to use an ENT property before it's defined
- **Fix:** Define all ENT properties at the top of the file, before any functions

**Error:** `bad argument #1 to 'EmitSound'`
- **Cause:** Invalid sound path or sound doesn't exist
- **Fix:** Use valid sound names. Test with known sounds like `"NPC_Dog.Angry"` or remove sound lines temporarily

**Error:** `BaseClass is nil`
- **Cause:** `ENT.Base` is set incorrectly or DrGBase base entity not found
- **Fix:** Make sure `ENT.Base = "drgbase_nextbot"` and DrGBase is installed

### NPC Plays Wrong Animations

**Possible causes:**

1. **Model doesn't have the activity** - Not all models have all activities
   - Solution: Use `developer 1` to see what animations are available. Try different ACT_ constants

2. **Using sequences instead of activities**
   - Solution: Use ACT_ constants (activities) not sequence names. Example: `ACT_WALK` not `"walk_all"`

3. **Animation rate too fast/slow**
   - Solution: Adjust animation rate properties like `ENT.WalkAnimRate = 1` (default is 1)

### NPC Takes No Damage

**Possible causes:**

1. **OnTakeDamage returns false** - Blocking all damage
   - Solution: Make sure `OnTakeDamage` returns `true` or remove the function entirely

2. **God mode enabled**
   - Solution: This is unlikely for DrGBase NPCs, but check if you've set any invincibility flags

### Performance Issues (Lag)

**Possible causes:**

1. **Too many NPCs** - Each NPC uses CPU for AI
   - Solution: Reduce number of NPCs. DrGBase is optimized but still requires processing

2. **Sight range too high** - NPCs checking too many entities
   - Solution: Reduce `ENT.SightRange` to reasonable values (1000-5000)

3. **No NavMesh** - Pathfinding recalculating constantly
   - Solution: Generate a NavMesh with `nav_generate` (single-player only)

## Next Steps

Now that you've created your first NPC:
1. **Customize further** - Add unique behaviors
2. **Learn about hooks** - Override more functionality
3. **Study the examples** - See more complex implementations
4. **Explore the API** - Discover all available functions

---

**Previous:** [Quick Start Guide](./03-quick-start.md) | **Next:** [Configuration & ConVars](./05-configuration.md)
