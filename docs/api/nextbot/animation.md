# Animation System Functions

Animation control, sequences, and activities.

**File:** `lua/entities/drgbase_nextbot/animations.lua` (552 lines)

---

## Playing Animations

### ENT:PlayAnimation(anim, ...params)

Plays an animation sequence or activity.

**Realm:** 🟣 SHARED

**Parameters:**
- `anim` (string or number) - Sequence name or activity ID
- `...params` - Additional parameters

**Returns:**
- `number` - Animation duration

**Example:**
```lua
self:PlayAnimation(ACT_RELOAD)
self:PlayAnimation("idle_all_01")
```

<!-- TODO: Document all parameters and options -->

---

### ENT:SetAnimation(anim)

Sets the current animation.

**Realm:** 🟣 SHARED

**Parameters:**
- `anim` (string or number) - Animation to set

**Returns:** None

---

### ENT:GetAnimation()

Gets current animation.

**Realm:** 🟣 SHARED

**Parameters:** None

**Returns:**
- `number` - Current animation/sequence

---

## Sequences

### ENT:LookupSequence(name)

Looks up sequence ID by name.

**Realm:** 🟣 SHARED

**Parameters:**
- `name` (string) - Sequence name

**Returns:**
- `number` - Sequence ID, or -1 if not found

---

### ENT:GetSequence()

Gets current sequence ID.

**Realm:** 🟣 SHARED

**Parameters:** None

**Returns:**
- `number` - Current sequence

---

### ENT:SetSequence(seq)

Sets sequence by ID.

**Realm:** 🟣 SHARED

**Parameters:**
- `seq` (number) - Sequence ID

**Returns:** None

---

## Activities

### ENT:SelectWeightedSequence(activity)

Selects a random weighted sequence for an activity.

**Realm:** 🟣 SHARED

**Parameters:**
- `activity` (number) - Activity ID

**Returns:**
- `number` - Selected sequence ID

---

### ENT:GetActivity()

Gets current activity.

**Realm:** 🟣 SHARED

**Parameters:** None

**Returns:**
- `number` - Current activity

---

## Animation Events

### ENT:OnAnimEvent(event, options)

Handles animation events.

**Realm:** 🔴 SERVER

**Parameters:**
- `event` (number) - Event ID
- `options` (string) - Event options

**Returns:**
- `boolean` - True if handled

**Example:**
```lua
function ENT:OnAnimEvent(event, options)
    if event == AE_CL_PLAYSOUND then
        self:EmitSound(options)
        return true
    end
    return false
end
```

<!-- TODO: Document common animation events -->

---

## Pose Parameters

### ENT:SetPoseParameter(name, value)

Sets a pose parameter.

**Realm:** 🟣 SHARED

**Parameters:**
- `name` (string) - Parameter name
- `value` (number) - Parameter value

**Returns:** None

**Example:**
```lua
self:SetPoseParameter("aim_pitch", 45)
```

---

### ENT:GetPoseParameter(name)

Gets pose parameter value.

**Realm:** 🟣 SHARED

**Parameters:**
- `name` (string) - Parameter name

**Returns:**
- `number` - Parameter value

---

## Gestures & Layers

<!-- TODO: Document gesture/layer functions -->

### ENT:AddGesture(activity)

Adds a gesture animation.

**Realm:** 🟣 SHARED

**Parameters:**
- `activity` (number) - Gesture activity

**Returns:**
- `number` - Gesture ID

---

### ENT:RemoveGesture(gesture)

Removes a gesture.

**Realm:** 🟣 SHARED

**Parameters:**
- `gesture` (number) - Gesture ID

**Returns:** None

---

## Animation Speed

### ENT:SetPlaybackRate(rate)

Sets animation playback speed.

**Realm:** 🟣 SHARED

**Parameters:**
- `rate` (number) - Playback multiplier (1.0 = normal)

**Returns:** None

---

### ENT:GetPlaybackRate()

Gets playback rate.

**Realm:** 🟣 SHARED

**Parameters:** None

**Returns:**
- `number` - Current playback rate

---

## Animation Blending

<!-- TODO: Document animation blending -->

---

## Sprite Animations

<!-- TODO: Document sprite animation system for drgbase_nextbot_sprite -->

---

## Related Hooks

- `ENT:OnAnimationStart(anim)` - Called when animation starts
- `ENT:OnAnimationComplete(anim)` - Called when animation completes
- `ENT:OnAnimEvent(event, options)` - Called for animation events

---

## See Also

- [Base Configuration](./base-config.md) - Animation properties
- [Animation System Guide](../../systems/animation/README.md)
- [Animation Events Reference](../../reference/anim-events.md)
