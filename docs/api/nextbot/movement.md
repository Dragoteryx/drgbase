# Movement & Locomotion Functions

Movement control, pathfinding, and locomotion.

**Files:**
- `lua/entities/drgbase_nextbot/movements.lua` (702 lines)
- `lua/entities/drgbase_nextbot/locomotion.lua` (106 lines)

---

## Basic Movement

### ENT:MoveToPos(pos, options)

Moves the NPC to a target position.

**Realm:** 🔴 SERVER

**Parameters:**
- `pos` (Vector) - Target position
- `options` (table, optional) - Movement options
  - `run` (boolean) - Run instead of walk
  - `tolerance` (number) - Goal tolerance distance
  <!-- TODO: Document all options -->

**Returns:**
- `boolean` - True if path was successfully started

**Example:**
```lua
self:MoveToPos(targetPos, {run = true})
```

---

### ENT:StopMoving()

Stops all movement.

**Realm:** 🔴 SERVER

**Parameters:** None

**Returns:** None

---

### ENT:IsMoving()

Checks if NPC is currently moving.

**Realm:** 🔴 SERVER

**Parameters:** None

**Returns:**
- `boolean` - True if moving

---

### ENT:FaceTowards(pos)

Rotates to face a position.

**Realm:** 🔴 SERVER

**Parameters:**
- `pos` (Vector) - Position to face

**Returns:** None

---

## Speed Control

### ENT:SetMoveSpeed(speed)

Sets movement speed.

**Realm:** 🔴 SERVER

**Parameters:**
- `speed` (number) - Speed in units/second

**Returns:** None

---

### ENT:GetMoveSpeed()

Gets current movement speed.

**Realm:** 🔴 SERVER

**Parameters:** None

**Returns:**
- `number` - Current speed

---

### ENT:SetRunSpeed(speed)

Sets running speed.

**Realm:** 🔴 SERVER

**Parameters:**
- `speed` (number) - Run speed in units/second

**Returns:** None

---

## Jump & Climb

### ENT:Jump()

Makes the NPC jump.

**Realm:** 🔴 SERVER

**Parameters:** None

**Returns:**
- `boolean` - True if jump was executed

---

### ENT:CanJump()

Checks if NPC can jump.

**Realm:** 🔴 SERVER

**Parameters:** None

**Returns:**
- `boolean` - True if can jump

---

### ENT:ClimbLedge(ledgePos)

Climbs a ledge.

**Realm:** 🔴 SERVER

**Parameters:**
- `ledgePos` (Vector) - Ledge position

**Returns:**
- `boolean` - True if climb started

<!-- TODO: Document ledge climbing system -->

---

### ENT:ClimbLadder(ladder)

Climbs a ladder.

**Realm:** 🔴 SERVER

**Parameters:**
- `ladder` (Entity) - Ladder entity

**Returns:**
- `boolean` - True if climb started

<!-- TODO: Document ladder climbing system -->

---

## Ground & Air

### ENT:IsOnGround()

Checks if NPC is on ground.

**Realm:** 🔴 SERVER

**Parameters:** None

**Returns:**
- `boolean` - True if on ground

---

### ENT:GetGroundEntity()

Gets the entity NPC is standing on.

**Realm:** 🔴 SERVER

**Parameters:** None

**Returns:**
- `Entity` - Ground entity, or nil

---

## Flying Movement

<!-- TODO: Document flying movement functions -->

### ENT:SetFlying(enabled)

Enables or disables flying mode.

**Realm:** 🔴 SERVER

**Parameters:**
- `enabled` (boolean) - Enable flying

**Returns:** None

---

### ENT:IsFlying()

Checks if in flying mode.

**Realm:** 🔴 SERVER

**Parameters:** None

**Returns:**
- `boolean` - True if flying

---

## Movement State

### ENT:SetMovementState(state)

Sets movement state (walk/run/idle).

**Realm:** 🔴 SERVER

**Parameters:**
- `state` (number) - Movement state

**Returns:** None

---

### ENT:GetMovementState()

Gets current movement state.

**Realm:** 🔴 SERVER

**Parameters:** None

**Returns:**
- `number` - Current movement state

---

## Rotation & Turning

### ENT:SetYawRate(rate)

Sets turning speed.

**Realm:** 🔴 SERVER

**Parameters:**
- `rate` (number) - Degrees per second

**Returns:** None

---

### ENT:GetYawRate()

Gets turning speed.

**Realm:** 🔴 SERVER

**Parameters:** None

**Returns:**
- `number` - Yaw rate

---

## Collision

### ENT:SetCollisionBounds(mins, maxs)

Sets collision bounds.

**Realm:** 🔴 SERVER

**Parameters:**
- `mins` (Vector) - Minimum bounds
- `maxs` (Vector) - Maximum bounds

**Returns:** None

---

### ENT:GetCollisionBounds()

Gets collision bounds.

**Realm:** 🔴 SERVER

**Parameters:** None

**Returns:**
- `Vector` - mins
- `Vector` - maxs

---

## Advanced Movement

<!-- TODO: Document advanced movement functions -->

---

## Related Hooks

- `ENT:OnMovementComplete()` - Called when movement finishes
- `ENT:OnMovementFailed()` - Called when movement fails
- `ENT:OnLanded()` - Called when landing after jump/fall
- `ENT:OnClimbStart()` - Called when climbing starts

---

## See Also

- [Path Functions](./path.md)
- [Patrol Functions](./patrol.md)
- [Movement System Guide](../../systems/movement/README.md)
