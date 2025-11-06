# Movement System

## Overview
The DrGBase movement system handles pathfinding, locomotion, patrol, and speed control for NextBots.

**Sources:**
- `lua/entities/drgbase_nextbot/movements.lua:1`
- `lua/entities/drgbase_nextbot/path.lua:1`
- `lua/entities/drgbase_nextbot/patrol.lua:1`
- `lua/entities/drgbase_nextbot/locomotion.lua:1`

---

## Pathfinding

### ENT:FollowPath 🖥️

```lua
ENT:FollowPath(target, run)
```

Follow path to target entity or position.

**Parameters:**
- `target` (Entity/Vector) - Target to follow
- `run` (boolean, optional) - Force run speed

**Returns:**
- (string, optional) - Status: "reached", "unreachable", "stuck", or nil if in progress

**Realm:** 🖥️ SERVER

**Example:**
```lua
function ENT:OnChaseEnemy(enemy)
    local result = self:FollowPath(enemy)
    if result == "unreachable" then
        print("Can't reach enemy!")
    elseif result == "reached" then
        print("Reached enemy!")
    end
end
```

---

### ENT:StopPath 🖥️

```lua
ENT:StopPath()
```

Stop following current path.

**Realm:** 🖥️ SERVER

**Example:**
```lua
function ENT:OnDeath()
    self:StopPath()
end
```

---

### ENT:ComputePath 🖥️

```lua
ENT:ComputePath(position, generator)
```

Compute path to position.

**Parameters:**
- `position` (Vector) - Target position
- `generator` (function, optional) - Custom path cost function

**Returns:**
- (boolean) - True if path found

**Realm:** 🖥️ SERVER

**Source:** `lua/entities/drgbase_nextbot/path.lua:48`

---

### ENT:GetPath 🖥️

```lua
ENT:GetPath()
```

Get path object.

**Returns:**
- (PathFollower) - Path object

**Realm:** 🖥️ SERVER

**Source:** `lua/entities/drgbase_nextbot/path.lua:11`

---

### ENT:InvalidatePath 🖥️

```lua
ENT:InvalidatePath()
```

Invalidate current path (forces recompute on next update).

**Realm:** 🖥️ SERVER

**Source:** `lua/entities/drgbase_nextbot/path.lua:30`

---

## Speed & Movement State

### ENT:GetSpeed

```lua
ENT:GetSpeed()
```

Get current desired speed.

**Returns:**
- (number) - Speed in units/second

**Realm:** 🌐 SHARED

**Source:** `lua/entities/drgbase_nextbot/movements.lua:10`

---

### ENT:SetSpeed 🖥️

```lua
ENT:SetSpeed(speed)
```

Set desired speed.

**Parameters:**
- `speed` (number) - Speed in units/second

**Realm:** 🖥️ SERVER

**Example:**
```lua
self:SetSpeed(100)  -- Walk
self:SetSpeed(200)  -- Run
```

**Source:** `lua/entities/drgbase_nextbot/movements.lua:123`

---

### ENT:Speed

```lua
ENT:Speed(scale)
```

Get actual current speed.

**Parameters:**
- `scale` (boolean, optional) - Adjust for model scale

**Returns:**
- (number) - Current velocity magnitude

**Realm:** 🌐 SHARED

**Source:** `lua/entities/drgbase_nextbot/movements.lua:14`

---

### ENT:IsMoving

```lua
ENT:IsMoving()
```

Check if currently moving.

**Returns:**
- (boolean) - True if moving

**Realm:** 🌐 SHARED

**Source:** `lua/entities/drgbase_nextbot/movements.lua:46`

---

### ENT:IsRunning 🖥️

```lua
ENT:IsRunning()
```

Check if running (vs walking).

**Returns:**
- (boolean) - True if running

**Realm:** 🖥️ SERVER

**Source:** `lua/entities/drgbase_nextbot/movements.lua:127`

---

### ENT:IsMovingForward / Backward / Left / Right

```lua
ENT:IsMovingForward()
ENT:IsMovingBackward()
ENT:IsMovingLeft()
ENT:IsMovingRight()
```

Check movement direction.

**Returns:**
- (boolean) - True if moving in that direction

**Realm:** 🌐 SHARED

**Example:**
```lua
if self:IsMovingForward() then
    -- Play walk animation
end
```

**Source:** `lua/entities/drgbase_nextbot/movements.lua:55-66`

---

### ENT:IsTurning

```lua
ENT:IsTurning(precision)
```

Check if currently turning.

**Parameters:**
- `precision` (number, optional) - Rounding precision

**Returns:**
- (boolean) - True if turning

**Realm:** 🌐 SHARED

**Source:** `lua/entities/drgbase_nextbot/movements.lua:80`

---

### ENT:IsTurningLeft / IsTurningRight

```lua
ENT:IsTurningLeft(precision)
ENT:IsTurningRight(precision)
```

Check turning direction.

**Returns:**
- (boolean) - True if turning in that direction

**Realm:** 🌐 SHARED

**Source:** `lua/entities/drgbase_nextbot/movements.lua:83-90`

---

## Facing & Orientation

### ENT:FaceTo 🖥️

```lua
ENT:FaceTo(position)
```

Face direction instantly.

**Parameters:**
- `position` (Vector) - Position to face

**Realm:** 🖥️ SERVER

**Example:**
```lua
self:FaceTo(enemy:GetPos())
```

---

### ENT:FaceTowards 🖥️

```lua
ENT:FaceTowards(target, speed)
```

Turn towards target over time.

**Parameters:**
- `target` (Entity/Vector) - Target to face
- `speed` (number, optional) - Turn speed multiplier

**Realm:** 🖥️ SERVER

**Example:**
```lua
function ENT:CustomThink()
    if self:HasEnemy() then
        self:FaceTowards(self:GetEnemy())
    end
end
```

---

## Climbing

### ENT:IsClimbing

```lua
ENT:IsClimbing()
```

Check if currently climbing.

**Returns:**
- (boolean) - True if climbing

**Realm:** 🌐 SHARED

**Source:** `lua/entities/drgbase_nextbot/movements.lua:92`

---

### ENT:IsClimbingUp / IsClimbingDown

```lua
ENT:IsClimbingUp()
ENT:IsClimbingDown()
```

Check climbing direction.

**Returns:**
- (boolean) - True if climbing in that direction

**Realm:** 🌐 SHARED

**Source:** `lua/entities/drgbase_nextbot/movements.lua:95-100`

---

### ENT:IsClimbingLadder 🖥️

```lua
ENT:IsClimbingLadder(ladder)
```

Check if climbing ladder.

**Parameters:**
- `ladder` (Entity, optional) - Specific ladder to check

**Returns:**
- (boolean) - True if climbing ladder
- (Entity, optional) - Ladder entity if climbing

**Realm:** 🖥️ SERVER

**Source:** `lua/entities/drgbase_nextbot/movements.lua:137`

---

### ENT:IsClimbingLedge 🖥️

```lua
ENT:IsClimbingLedge()
```

Check if climbing ledge (not ladder).

**Returns:**
- (boolean) - True if climbing ledge

**Realm:** 🖥️ SERVER

**Source:** `lua/entities/drgbase_nextbot/movements.lua:145`

---

## Patrol System

### ENT:AddPatrolPos 🖥️

```lua
ENT:AddPatrolPos(position, type, run)
```

Add patrol point.

**Parameters:**
- `position` (Vector) - Target position
- `type` (number, optional) - Patrol type (PATROL_POS, PATROL_SEARCH, PATROL_SOUND)
- `run` (boolean, optional) - Run to position

**Realm:** 🖥️ SERVER

**Example:**
```lua
function ENT:OnIdle()
    -- Random patrol
    self:AddPatrolPos(self:RandomPos(1500))
end

function ENT:OnLoseEnemy(enemy)
    -- Search last known position
    local lastPos = self:GetLastKnownPos(enemy)
    self:AddPatrolPos(lastPos, PATROL_SEARCH)
end
```

---

### ENT:HasPatrol 🖥️

```lua
ENT:HasPatrol()
```

Check if has patrol points.

**Returns:**
- (boolean) - True if has patrol

**Realm:** 🖥️ SERVER

---

### ENT:GetPatrol 🖥️

```lua
ENT:GetPatrol()
```

Get next patrol point.

**Returns:**
- (table) - Patrol object, or nil

**Realm:** 🖥️ SERVER

---

### ENT:RemovePatrol 🖥️

```lua
ENT:RemovePatrol(patrol)
```

Remove patrol point.

**Parameters:**
- `patrol` (table) - Patrol object to remove

**Realm:** 🖥️ SERVER

---

## Jumping & Leaping

### ENT:Jump 🖥️

```lua
ENT:Jump()
```

Jump upward.

**Realm:** 🖥️ SERVER

**Example:**
```lua
function ENT:OnReachedPatrol()
    self:Jump()  -- Celebratory jump
end
```

---

### ENT:Leap 🖥️

```lua
ENT:Leap(target, speed)
```

Leap toward target.

**Parameters:**
- `target` (Vector) - Target position
- `speed` (number) - Leap velocity

**Realm:** 🖥️ SERVER

**Example:**
```lua
function ENT:OnRangeAttack(enemy)
    -- Headcrab-style leap
    self:Leap(enemy:GetPos() + Vector(0, 0, 30), 500)
end
```

---

## Distance & Range

### ENT:GetRangeTo

```lua
ENT:GetRangeTo(target)
```

Get distance to target.

**Parameters:**
- `target` (Entity/Vector) - Target

**Returns:**
- (number) - Distance in units

**Realm:** 🌐 SHARED

**Example:**
```lua
local dist = self:GetRangeTo(enemy)
if dist < 100 then
    self:Attack()
end
```

---

### ENT:GetRangeSquaredTo

```lua
ENT:GetRangeSquaredTo(target)
```

Get squared distance (faster, no square root).

**Parameters:**
- `target` (Entity/Vector) - Target

**Returns:**
- (number) - Squared distance

**Realm:** 🌐 SHARED

**Note:** Use for performance when comparing distances.

---

### ENT:IsInRange

```lua
ENT:IsInRange(target, range)
```

Check if target within range.

**Parameters:**
- `target` (Entity/Vector) - Target
- `range` (number) - Distance threshold

**Returns:**
- (boolean) - True if within range

**Realm:** 🌐 SHARED

**Example:**
```lua
if self:IsInRange(enemy, self.MeleeAttackRange) then
    self:OnMeleeAttack(enemy)
end
```

---

## Position Utilities

### ENT:RandomPos 🖥️

```lua
ENT:RandomPos(min, max)
```

Get random reachable position near NPC.

**Parameters:**
- `min` (number) - Minimum distance (or max if second param omitted)
- `max` (number, optional) - Maximum distance

**Returns:**
- (Vector) - Random position

**Realm:** 🖥️ SERVER

**Example:**
```lua
-- Random position within 1000 units
local pos = self:RandomPos(1000)
self:AddPatrolPos(pos)

-- Random position between 500-1500 units
local pos = self:RandomPos(500, 1500)
```

**Source:** `lua/drgbase/entity_helpers.lua:99`

---

## Movement Hooks

### ENT:OnReachedPatrol

```lua
function ENT:OnReachedPatrol(position, patrol)
```

Called when patrol point reached.

**Parameters:**
- `position` (Vector) - Patrol position
- `patrol` (table) - Patrol object

**Realm:** 🖥️ SERVER

**Example:**
```lua
function ENT:OnReachedPatrol()
    self:Wait(math.random(3, 7))  -- Wait before next patrol
end
```

---

### ENT:OnPatrolling

```lua
function ENT:OnPatrolling(position, patrol)
```

Called while patrolling to position.

**Parameters:**
- `position` (Vector) - Patrol position
- `patrol` (table) - Patrol object

**Returns:**
- (boolean, optional) - True to mark as reached, false as unreachable

**Realm:** 🖥️ SERVER

---

### ENT:OnPatrolUnreachable

```lua
function ENT:OnPatrolUnreachable(position, patrol)
```

Called when patrol point unreachable.

**Parameters:**
- `position` (Vector) - Patrol position
- `patrol` (table) - Patrol object

**Realm:** 🖥️ SERVER

---

### ENT:OnChaseEnemy

```lua
function ENT:OnChaseEnemy(enemy)
```

Called when chasing enemy.

**Parameters:**
- `enemy` (Entity) - Enemy being chased

**Returns:**
- (boolean, optional) - True to override default chase behavior

**Realm:** 🖥️ SERVER

**Example:**
```lua
function ENT:OnChaseEnemy(enemy)
    -- Custom chase: jump periodically
    if CurTime() > (self._nextJump or 0) then
        self:Jump()
        self._nextJump = CurTime() + 2
    end
    -- Don't override default chase
end
```

---

### ENT:OnAvoidEnemy

```lua
function ENT:OnAvoidEnemy(enemy)
```

Called when avoiding enemy (ranged combat).

**Parameters:**
- `enemy` (Entity) - Enemy being avoided

**Returns:**
- (boolean, optional) - True to override default avoidance

**Realm:** 🖥️ SERVER

---

### ENT:OnIdle

```lua
function ENT:OnIdle()
```

Called when NPC is idle (no enemy, no patrol).

**Realm:** 🖥️ SERVER

**Example:**
```lua
function ENT:OnIdle()
    -- Wander randomly
    self:AddPatrolPos(self:RandomPos(1500))
end
```

---

## ConVars

### drgbase_multiplier_speed

**Default:** `1`
**Type:** Replicated

Global speed multiplier for all DrGBase NPCs.

**Usage:**
```
drgbase_multiplier_speed 2  -- Double all NPC speed
drgbase_multiplier_speed 0.5  -- Half speed
```

**Source:** `lua/entities/drgbase_nextbot/movements.lua:6`

---

### drgbase_avoid_obstacles

**Default:** `1`
**Type:** Replicated

Enable/disable obstacle avoidance.

**Usage:**
```
drgbase_avoid_obstacles 0  -- Disable avoidance
```

**Source:** `lua/entities/drgbase_nextbot/movements.lua:5`

---

### drgbase_compute_delay

**Default:** `0.1`
**Type:** Replicated

Delay between path recomputes (seconds).

**Usage:**
```
drgbase_compute_delay 0.5  -- Slower updates
```

**Source:** `lua/entities/drgbase_nextbot/movements.lua:4`

---

### drgbase_ai_patrol

**Default:** `1`
**Type:** Replicated

Enable/disable patrol AI.

**Usage:**
```
drgbase_ai_patrol 0  -- Disable all patrol behavior
```

---

## See Also

- **[AI System](ai-system.md)** - Enemy detection and targeting
- **[Base Configuration](base-configuration.md)** - Movement properties
- **[Getting Started](../getting-started/02-first-nextbot.md)** - Movement examples
