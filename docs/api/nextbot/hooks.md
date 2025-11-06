# Nextbot Hooks & Callbacks

All available hooks for customizing nextbot behavior.

**File:** `lua/entities/drgbase_nextbot/hooks.lua` (300 lines)

---

## Initialization & Lifecycle

### ENT:CustomInitialize()

Called after the NPC spawns and base initialization completes.

**Realm:** 🔴 SERVER

**Parameters:** None

**Returns:** None

**Example:**
```lua
function ENT:CustomInitialize()
    self:SetHealth(200)
    self:GiveWeapon("weapon_ar2")
    self:SetFaction(FACTION_COMBINE)
end
```

**When Called:** After `ENT:Initialize()`, all base systems are ready

---

### ENT:CustomThink()

Called every tick for custom logic.

**Realm:** 🔴 SERVER

**Parameters:** None

**Returns:** None

**Example:**
```lua
function ENT:CustomThink()
    -- Custom AI logic
    if self:HasEnemy() then
        -- Combat behavior
    else
        -- Idle behavior
    end
end
```

**When Called:** Every server tick

---

### ENT:OnRemove()

Called when entity is removed.

**Realm:** 🔴 SERVER

**Parameters:** None

**Returns:** None

**Example:**
```lua
function ENT:OnRemove()
    -- Cleanup
    self:EmitSound("NPC.Death")
end
```

---

## Combat Hooks

### ENT:OnMeleeAttack(enemy)

Called when performing a melee attack.

**Realm:** 🔴 SERVER

**Parameters:**
- `enemy` (Entity) - Target enemy

**Returns:** None

**Example:**
```lua
function ENT:OnMeleeAttack(enemy)
    local dmg = DamageInfo()
    dmg:SetAttacker(self)
    dmg:SetInflictor(self)
    dmg:SetDamage(math.random(10, 20))
    dmg:SetDamageType(DMG_SLASH)
    enemy:TakeDamageInfo(dmg)

    self:EmitSound("NPC.Melee")
end
```

---

### ENT:OnRangeAttack(enemy)

Called when performing a ranged attack.

**Realm:** 🔴 SERVER

**Parameters:**
- `enemy` (Entity) - Target enemy

**Returns:** None

**Example:**
```lua
function ENT:OnRangeAttack(enemy)
    self:FireProjectile("proj_drg_grenade", self:GetShootPos(), self:GetAimVector():Angle())
    self:EmitSound("Weapon.Fire")
end
```

---

### ENT:OnTakeDamage(dmg)

Called when NPC takes damage.

**Realm:** 🔴 SERVER

**Parameters:**
- `dmg` (CTakeDamageInfo) - Damage info

**Returns:**
- `boolean` - Return false to prevent damage

**Example:**
```lua
function ENT:OnTakeDamage(dmg)
    -- Modify damage
    if dmg:IsBulletDamage() then
        dmg:ScaleDamage(0.5)  -- Half bullet damage
    end

    -- Play pain sound
    if math.random() < 0.3 then
        self:EmitSound("NPC.Pain")
    end

    -- Return true to allow damage
    return true
end
```

---

### ENT:OnDeath(dmg, delay, hitgroup)

Called when NPC dies.

**Realm:** 🔴 SERVER

**Parameters:**
- `dmg` (CTakeDamageInfo) - Fatal damage info
- `delay` (number) - Delay before ragdoll creation
- `hitgroup` (number) - Hitgroup that was hit

**Returns:** None

**Example:**
```lua
function ENT:OnDeath(dmg, delay, hitgroup)
    self:EmitSound("NPC.Death")

    -- Spawn headcrab on zombie death
    if self:GetClass() == "npc_drg_zombie" then
        timer.Simple(0.1, function()
            local crab = ents.Create("npc_drg_headcrab")
            crab:SetPos(self:GetPos())
            crab:Spawn()
        end)
    end

    -- Drop weapon
    if IsValid(self:GetActiveWeapon()) then
        self:GetActiveWeapon():Drop()
    end
end
```

---

### ENT:OnKilled(attacker, inflictor)

Called when NPC is killed by an attacker.

**Realm:** 🔴 SERVER

**Parameters:**
- `attacker` (Entity) - Entity that killed this NPC
- `inflictor` (Entity) - Weapon/entity that inflicted death

**Returns:** None

---

## AI Hooks

### ENT:OnNewEnemy(enemy)

Called when a new enemy is acquired.

**Realm:** 🔴 SERVER

**Parameters:**
- `enemy` (Entity) - New enemy

**Returns:** None

**Example:**
```lua
function ENT:OnNewEnemy(enemy)
    self:EmitSound("NPC.Alert")
    self:PlayAnimation(ACT_SIGNAL_GROUP)
end
```

---

### ENT:OnLostEnemy(enemy)

Called when enemy is lost.

**Realm:** 🔴 SERVER

**Parameters:**
- `enemy` (Entity) - Lost enemy

**Returns:** None

---

### ENT:OnEnemyVisible(enemy)

Called when enemy becomes visible.

**Realm:** 🔴 SERVER

**Parameters:**
- `enemy` (Entity) - Visible enemy

**Returns:** None

---

### ENT:OnEnemyInvisible(enemy)

Called when enemy becomes invisible.

**Realm:** 🔴 SERVER

**Parameters:**
- `enemy` (Entity) - Now-invisible enemy

**Returns:** None

---

### ENT:OnHearSound(sound)

Called when NPC hears a sound.

**Realm:** 🔴 SERVER

**Parameters:**
- `sound` (table) - Sound information table

**Returns:** None

**Example:**
```lua
function ENT:OnHearSound(sound)
    if sound.type == "danger" then
        self:FaceTowards(sound.pos)
    end
end
```

---

## Movement Hooks

### ENT:OnMovementComplete()

Called when pathfinding movement completes.

**Realm:** 🔴 SERVER

**Parameters:** None

**Returns:** None

---

### ENT:OnMovementFailed()

Called when pathfinding fails.

**Realm:** 🔴 SERVER

**Parameters:** None

**Returns:** None

---

### ENT:OnLanded()

Called when NPC lands after jump or fall.

**Realm:** 🔴 SERVER

**Parameters:** None

**Returns:** None

**Example:**
```lua
function ENT:OnLanded()
    self:EmitSound("NPC.Land")
    -- Create dust effect
end
```

---

### ENT:OnClimbStart()

Called when climbing starts.

**Realm:** 🔴 SERVER

**Parameters:** None

**Returns:** None

---

### ENT:OnClimbEnd()

Called when climbing ends.

**Realm:** 🔴 SERVER

**Parameters:** None

**Returns:** None

---

## Animation Hooks

### ENT:OnAnimationStart(anim)

Called when animation starts playing.

**Realm:** 🟣 SHARED

**Parameters:**
- `anim` (number) - Animation/sequence ID

**Returns:** None

---

### ENT:OnAnimationComplete(anim)

Called when animation finishes.

**Realm:** 🟣 SHARED

**Parameters:**
- `anim` (number) - Animation/sequence ID

**Returns:** None

---

### ENT:OnAnimEvent(event, options)

Called for animation events.

**Realm:** 🔴 SERVER

**Parameters:**
- `event` (number) - Event ID
- `options` (string) - Event options

**Returns:**
- `boolean` - Return true if handled

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

---

## Relationship Hooks

### ENT:OnRelationshipChanged(entity, oldDisp, newDisp)

Called when relationship changes.

**Realm:** 🔴 SERVER

**Parameters:**
- `entity` (Entity) - Entity relationship changed with
- `oldDisp` (number) - Old disposition
- `newDisp` (number) - New disposition

**Returns:** None

---

### ENT:OnFactionChanged(oldFaction, newFaction)

Called when faction changes.

**Realm:** 🔴 SERVER

**Parameters:**
- `oldFaction` (number) - Old faction
- `newFaction` (number) - New faction

**Returns:** None

---

## Possession Hooks

### ENT:OnPossessed(player)

Called when player possesses this NPC.

**Realm:** 🔴 SERVER

**Parameters:**
- `player` (Player) - Possessing player

**Returns:** None

**Example:**
```lua
function ENT:OnPossessed(player)
    self:EmitSound("NPC.Possess")
    -- Disable AI during possession
    self:SetAIEnabled(false)
end
```

---

### ENT:OnUnpossessed(player)

Called when possession ends.

**Realm:** 🔴 SERVER

**Parameters:**
- `player` (Player) - Player who was possessing

**Returns:** None

**Example:**
```lua
function ENT:OnUnpossessed(player)
    -- Re-enable AI
    self:SetAIEnabled(true)
end
```

---

### ENT:OnPossessionThink()

Called every tick while possessed.

**Realm:** 🔴 SERVER

**Parameters:** None

**Returns:** None

**Example:**
```lua
function ENT:OnPossessionThink()
    local possessor = self:GetPossessor()
    if not IsValid(possessor) then return end

    -- Custom possession behavior
    if possessor:KeyDown(IN_ATTACK) then
        -- Special attack
    end
end
```

---

## Weapon Hooks

### ENT:OnWeaponEquipped(weapon)

Called when weapon is equipped.

**Realm:** 🔴 SERVER

**Parameters:**
- `weapon` (Entity) - Equipped weapon

**Returns:** None

---

### ENT:OnWeaponRemoved(weapon)

Called when weapon is removed.

**Realm:** 🔴 SERVER

**Parameters:**
- `weapon` (Entity) - Removed weapon

**Returns:** None

---

## Collision Hooks

### ENT:OnTouch(entity)

Called when NPC touches another entity.

**Realm:** 🔴 SERVER

**Parameters:**
- `entity` (Entity) - Touched entity

**Returns:** None

**Example:**
```lua
function ENT:OnTouch(entity)
    if self:IsEnemy(entity) then
        -- Deal contact damage
        self:DealDamage(entity, 10, DMG_CRUSH)
    end
end
```

---

## Utility Hooks

### ENT:OnSpotCreated(spot)

Called when NPC finds a spot (cover, patrol, etc.).

**Realm:** 🔴 SERVER

**Parameters:**
- `spot` (Vector) - Spot position

**Returns:** None

---

## Hook Usage Tips

1. **Always check validity** - Use `IsValid()` on entities
2. **Return values matter** - Some hooks expect return values
3. **Don't block** - Avoid long operations in hooks
4. **Use timers** - For delayed actions
5. **Call parent** - If extending base behavior

**Example of calling parent:**
```lua
function ENT:CustomInitialize()
    -- Call parent if exists
    if self.BaseClass.CustomInitialize then
        self.BaseClass.CustomInitialize(self)
    end

    -- Your custom code
    self:SetHealth(200)
end
```

---

## See Also

- [Base Configuration](./base-config.md)
- [Creating NPCs Guide](../../guides/creating-npcs.md)
- [Examples](../../examples/README.md)
