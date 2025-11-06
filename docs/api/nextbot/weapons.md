# Weapon System Functions

NPC weapon management and combat functions.

**File:** `lua/entities/drgbase_nextbot/weapons.lua` (537 lines)

---

## Weapon Management

### ENT:GiveWeapon(weaponClass)

Gives a weapon to the NPC.

**Realm:** 🔴 SERVER

**Parameters:**
- `weaponClass` (string) - Weapon class name

**Returns:**
- `Entity` - Weapon entity, or nil if failed

**Example:**
```lua
self:GiveWeapon("weapon_pistol")
```

---

### ENT:RemoveWeapon(weapon)

Removes a weapon from NPC.

**Realm:** 🔴 SERVER

**Parameters:**
- `weapon` (Entity or string) - Weapon entity or class name

**Returns:**
- `boolean` - True if removed

---

### ENT:StripWeapons()

Removes all weapons.

**Realm:** 🔴 SERVER

**Parameters:** None

**Returns:** None

---

### ENT:GetActiveWeapon()

Gets currently equipped weapon.

**Realm:** 🟣 SHARED

**Parameters:** None

**Returns:**
- `Entity` - Active weapon, or NULL

**Example:**
```lua
local weapon = self:GetActiveWeapon()
if IsValid(weapon) then
    -- Use weapon
end
```

---

### ENT:GetWeapons()

Gets all weapons carried by NPC.

**Realm:** 🟣 SHARED

**Parameters:** None

**Returns:**
- `table` - Array of weapon entities

---

### ENT:SwitchToWeapon(weapon)

Switches to a specific weapon.

**Realm:** 🔴 SERVER

**Parameters:**
- `weapon` (Entity) - Weapon to switch to

**Returns:**
- `boolean` - True if switched

---

## Melee Attacks

### ENT:OnMeleeAttack(enemy)

Called when performing a melee attack.

**Realm:** 🔴 SERVER

**Parameters:**
- `enemy` (Entity) - Target enemy

**Returns:** None (override to implement custom behavior)

**Example:**
```lua
function ENT:OnMeleeAttack(enemy)
    if not IsValid(enemy) then return end

    local dmg = DamageInfo()
    dmg:SetAttacker(self)
    dmg:SetInflictor(self)
    dmg:SetDamage(self.MeleeAttackDamageMin)
    dmg:SetDamageType(DMG_SLASH)

    enemy:TakeDamageInfo(dmg)
    self:EmitSound("NPC.AttackSound")
end
```

---

### ENT:PerformMeleeAttack()

Executes a melee attack.

**Realm:** 🔴 SERVER

**Parameters:** None

**Returns:**
- `boolean` - True if attack was performed

---

### ENT:CanMeleeAttack(enemy)

Checks if can perform melee attack.

**Realm:** 🔴 SERVER

**Parameters:**
- `enemy` (Entity, optional) - Target to check (defaults to current enemy)

**Returns:**
- `boolean` - True if can attack

---

## Ranged Attacks

### ENT:OnRangeAttack(enemy)

Called when performing a ranged attack.

**Realm:** 🔴 SERVER

**Parameters:**
- `enemy` (Entity) - Target enemy

**Returns:** None (override to implement custom behavior)

**Example:**
```lua
function ENT:OnRangeAttack(enemy)
    if not IsValid(enemy) then return end

    -- Fire projectile
    self:FireProjectile("proj_drg_grenade", self:GetShootPos(), self:GetAimVector():Angle())
    self:EmitSound("Weapon.Fire")
end
```

---

### ENT:PerformRangeAttack()

Executes a ranged attack.

**Realm:** 🔴 SERVER

**Parameters:** None

**Returns:**
- `boolean` - True if attack was performed

---

### ENT:CanRangeAttack(enemy)

Checks if can perform ranged attack.

**Realm:** 🔴 SERVER

**Parameters:**
- `enemy` (Entity, optional) - Target to check

**Returns:**
- `boolean` - True if can attack

---

## Projectiles

### ENT:FireProjectile(class, pos, ang, options)

Fires a projectile.

**Realm:** 🔴 SERVER

**Parameters:**
- `class` (string) - Projectile class name
- `pos` (Vector) - Spawn position
- `ang` (Angle) - Spawn angle
- `options` (table, optional) - Additional options

**Returns:**
- `Entity` - Projectile entity

**Example:**
```lua
local proj = self:FireProjectile("proj_drg_grenade", self:GetShootPos(), self:GetAimVector():Angle())
```

<!-- TODO: Document options table -->

---

## Attack Timing

### ENT:GetNextMeleeAttackTime()

Gets time of next allowed melee attack.

**Realm:** 🔴 SERVER

**Parameters:** None

**Returns:**
- `number` - CurTime() when next attack allowed

---

### ENT:GetNextRangeAttackTime()

Gets time of next allowed ranged attack.

**Realm:** 🔴 SERVER

**Parameters:** None

**Returns:**
- `number` - CurTime() when next attack allowed

---

### ENT:SetNextMeleeAttackTime(time)

Sets next melee attack time.

**Realm:** 🔴 SERVER

**Parameters:**
- `time` (number) - CurTime() + delay

**Returns:** None

---

### ENT:SetNextRangeAttackTime(time)

Sets next ranged attack time.

**Realm:** 🔴 SERVER

**Parameters:**
- `time` (number) - CurTime() + delay

**Returns:** None

---

## Aim & Targeting

### ENT:GetShootPos()

Gets position to shoot from.

**Realm:** 🟣 SHARED

**Parameters:** None

**Returns:**
- `Vector` - Shoot position

---

### ENT:GetAimVector()

Gets aim direction vector.

**Realm:** 🔴 SERVER

**Parameters:** None

**Returns:**
- `Vector` - Aim direction (normalized)

---

### ENT:AimAtTarget(target)

Aims at a target.

**Realm:** 🔴 SERVER

**Parameters:**
- `target` (Entity or Vector) - Target to aim at

**Returns:** None

---

## Damage Dealing

### ENT:DealDamage(target, damage, damageType)

Deals damage to a target.

**Realm:** 🔴 SERVER

**Parameters:**
- `target` (Entity) - Entity to damage
- `damage` (number) - Damage amount
- `damageType` (number, optional) - Damage type flags

**Returns:**
- `boolean` - True if damage was dealt

---

## Related Hooks

- `ENT:OnMeleeAttack(enemy)` - Melee attack hook
- `ENT:OnRangeAttack(enemy)` - Ranged attack hook
- `ENT:OnWeaponEquipped(weapon)` - When weapon equipped
- `ENT:OnWeaponRemoved(weapon)` - When weapon removed

---

## See Also

- [Base Configuration](./base-config.md) - Combat properties
- [Weapon Base API](../weapon/README.md)
- [Projectile API](../projectile/README.md)
- [Combat System Guide](../../systems/combat/README.md)
