# Combat System

## Overview
The DrGBase combat system handles weapons, attacks, damage, and combat behaviors.

**Source:** `lua/entities/drgbase_nextbot/weapons.lua:1`

---

## Attack Functions

### ENT:Attack 🖥️

```lua
ENT:Attack(data, callback)
```

Deal melee damage in front of NPC.

**Parameters:**
- `data` (table) - Attack parameters
  - `damage` (number) - Damage amount
  - `type` (number) - Damage type (DMG_SLASH, DMG_CLUB, etc.)
  - `range` (number, optional) - Attack range (default: MeleeAttackRange)
  - `viewpunch` (Angle, optional) - Camera punch for hit players
  - `force` (number, optional) - Knockback force
- `callback` (function, optional) - Called with (self, hitEntities) after attack

**Realm:** 🖥️ SERVER

**Example:**
```lua
function ENT:OnMeleeAttack(enemy)
    self:PlayActivityAndMove(ACT_MELEE_ATTACK1, 1, self.FaceEnemy)
    -- Deal damage during animation
    if self:GetCycle() > 0.3 then
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
```

---

### ENT:IsAttacking

```lua
ENT:IsAttacking()
```

Check if currently attacking.

**Returns:**
- (boolean) - True if attack animation playing

**Realm:** 🌐 SHARED

---

## Weapon System

### ENT:HasWeapon

```lua
ENT:HasWeapon(class)
```

Check if has weapon.

**Parameters:**
- `class` (string, optional) - Weapon class to check for specific weapon

**Returns:**
- (boolean) - True if has weapon

**Realm:** 🌐 SHARED

**Example:**
```lua
if self:HasWeapon() then
    -- Has any weapon
end

if self:HasWeapon("weapon_ar2") then
    -- Has specific weapon
end
```

**Source:** `lua/entities/drgbase_nextbot/weapons.lua:12`

---

### ENT:GetWeapon / ENT:GetActiveWeapon

```lua
ENT:GetWeapon(class)
```

Get weapon entity.

**Parameters:**
- `class` (string, optional) - Specific weapon class

**Returns:**
- (Entity) - Weapon entity, or NULL

**Realm:** 🌐 SHARED

**Example:**
```lua
local weapon = self:GetWeapon()
if IsValid(weapon) then
    print("Holding:", weapon:GetClass())
end
```

**Source:** `lua/entities/drgbase_nextbot/weapons.lua:7`

---

### ENT:GetWeapons 🖥️

```lua
ENT:GetWeapons()
```

Get all weapons.

**Returns:**
- (table) - Table of weapon entities (indexed by class name)

**Realm:** 🖥️ SERVER

**Source:** `lua/entities/drgbase_nextbot/weapons.lua:19`

---

### ENT:GetWeaponCount

```lua
ENT:GetWeaponCount()
```

Get number of weapons.

**Returns:**
- (number) - Weapon count

**Realm:** 🌐 SHARED

**Source:** `lua/entities/drgbase_nextbot/weapons.lua:22`

---

### ENT:PickupWeapon 🖥️

```lua
ENT:PickupWeapon(weapon)
```

Pick up weapon entity.

**Parameters:**
- `weapon` (Entity) - Weapon to pick up

**Realm:** 🖥️ SERVER

**Example:**
```lua
function ENT:OnContact(ent)
    if ent:IsWeapon() then
        self:PickupWeapon(ent)
    end
end
```

---

### ENT:DropWeapon 🖥️

```lua
ENT:DropWeapon(class)
```

Drop weapon.

**Parameters:**
- `class` (string, optional) - Weapon class to drop (default: active weapon)

**Realm:** 🖥️ SERVER

**Example:**
```lua
function ENT:OnDeath()
    if self.DropWeaponOnDeath then
        self:DropWeapon()
    end
end
```

---

## Weapon Actions

### ENT:PrimaryFire 🖥️

```lua
ENT:PrimaryFire()
```

Fire weapon (primary attack).

**Realm:** 🖥️ SERVER

**Example:**
```lua
function ENT:OnRangeAttack(enemy, weapon)
    if self:IsInSight(enemy) then
        self:PrimaryFire()
    end
end
```

---

### ENT:SecondaryFire 🖥️

```lua
ENT:SecondaryFire()
```

Fire weapon (secondary attack).

**Realm:** 🖥️ SERVER

---

### ENT:Reload 🖥️

```lua
ENT:Reload()
```

Reload weapon.

**Realm:** 🖥️ SERVER

**Example:**
```lua
function ENT:CustomThink()
    if self:IsWeaponPrimaryEmpty() then
        self:Reload()
    end
end
```

---

### ENT:IsReloadingWeapon

```lua
ENT:IsReloadingWeapon()
```

Check if reloading.

**Returns:**
- (boolean) - True if reloading

**Realm:** 🌐 SHARED

**Source:** `lua/entities/drgbase_nextbot/weapons.lua:30`

---

### ENT:IsWeaponPrimaryEmpty 🖥️

```lua
ENT:IsWeaponPrimaryEmpty()
```

Check if weapon primary ammo is empty.

**Returns:**
- (boolean) - True if empty

**Realm:** 🖥️ SERVER

---

## Aiming

### ENT:GetShootPos

```lua
ENT:GetShootPos(class)
```

Get position where shots originate.

**Parameters:**
- `class` (string, optional) - Weapon class

**Returns:**
- (Vector) - Shoot position

**Realm:** 🌐 SHARED

**Source:** `lua/entities/drgbase_nextbot/weapons.lua:35`

---

### ENT:GetAimVector

```lua
ENT:GetAimVector(class)
```

Get aim direction vector.

**Parameters:**
- `class` (string, optional) - Weapon class

**Returns:**
- (Vector) - Normalized aim direction

**Realm:** 🌐 SHARED

**Source:** `lua/entities/drgbase_nextbot/weapons.lua:49`

---

## Damage Hooks

### ENT:OnTakeDamage 🖥️

```lua
function ENT:OnTakeDamage(dmg, hitgroup)
```

Called when NPC takes damage.

**Parameters:**
- `dmg` (CTakeDamageInfo) - Damage info
- `hitgroup` (number) - Hit body part

**Returns:**
- (number, optional) - Damage multiplier (2 = double damage, 0.5 = half, 0 = no damage)

**Realm:** 🖥️ SERVER

**Example:**
```lua
function ENT:OnTakeDamage(dmg)
    local attacker = dmg:GetAttacker()

    -- Double damage from crowbar
    if IsValid(attacker) and attacker:IsPlayer() then
        local weapon = attacker:GetActiveWeapon()
        if IsValid(weapon) and weapon:GetClass() == "weapon_crowbar" then
            return 2  -- 2x damage
        end
    end

    -- Headshot bonus
    if hitgroup == HITGROUP_HEAD then
        return 3  -- 3x damage
    end
end
```

---

### ENT:OnDeath 🖥️

```lua
function ENT:OnDeath(dmg, hitgroup)
```

Called when NPC dies.

**Parameters:**
- `dmg` (CTakeDamageInfo) - Killing blow damage
- `hitgroup` (number) - Hit body part

**Realm:** 🖥️ SERVER

**Example:**
```lua
function ENT:OnDeath(dmg, hitgroup)
    -- Spawn item on death
    local item = ents.Create("item_healthkit")
    item:SetPos(self:GetPos())
    item:Spawn()

    -- Special death for headshots
    if hitgroup == HITGROUP_HEAD then
        self:EmitSound("headshot.wav")
    end
end
```

---

### ENT:OnDealtDamage 🖥️

```lua
function ENT:OnDealtDamage(target, dmg)
```

Called when NPC deals damage.

**Parameters:**
- `target` (Entity) - Entity that was damaged
- `dmg` (CTakeDamageInfo) - Damage info

**Realm:** 🖥️ SERVER

**Example:**
```lua
function ENT:OnDealtDamage(target, dmg)
    if target:IsPlayer() then
        print("Damaged player for", dmg:GetDamage(), "HP")
    end
end
```

---

## Combat Hooks

### ENT:OnMeleeAttack 🖥️

```lua
function ENT:OnMeleeAttack(enemy, weapon)
```

Called when in melee range of enemy.

**Parameters:**
- `enemy` (Entity) - Enemy to attack
- `weapon` (Entity) - Current weapon

**Returns:**
- (boolean, optional) - True to override default behavior, false to prevent attack

**Realm:** 🖥️ SERVER

**Example:**
```lua
function ENT:OnMeleeAttack(enemy)
    self:EmitSound("Zombie.Attack")
    self:PlayActivityAndMove(ACT_MELEE_ATTACK1, 1, self.FaceEnemy)
end
```

---

### ENT:OnRangeAttack 🖥️

```lua
function ENT:OnRangeAttack(enemy, weapon)
```

Called when in ranged attack range of enemy.

**Parameters:**
- `enemy` (Entity) - Enemy to attack
- `weapon` (Entity) - Current weapon

**Returns:**
- (boolean, optional) - True to override default behavior

**Realm:** 🖥️ SERVER

**Example:**
```lua
function ENT:OnRangeAttack(enemy)
    -- Headcrab leap
    self:HeadcrabLeap(enemy:EyePos() - Vector(0, 0, 10))
end
```

---

## Weapon Hooks

### ENT:OnPickupWeapon

```lua
function ENT:OnPickupWeapon(weapon, class)
```

Called when picking up weapon.

**Parameters:**
- `weapon` (Entity) - Weapon entity
- `class` (string) - Weapon class

**Realm:** 🌐 SHARED

**Source:** `lua/entities/drgbase_nextbot/weapons.lua:68`

---

### ENT:OnDropWeapon

```lua
function ENT:OnDropWeapon(weapon, class)
```

Called when dropping weapon.

**Parameters:**
- `weapon` (Entity) - Weapon entity (may be NULL if already removed)
- `class` (string) - Weapon class

**Realm:** 🌐 SHARED

**Source:** `lua/entities/drgbase_nextbot/weapons.lua:69`

---

### ENT:OnWeaponChange

```lua
function ENT:OnWeaponChange(oldWeapon, newWeapon)
```

Called when active weapon changes.

**Parameters:**
- `oldWeapon` (Entity) - Previous weapon
- `newWeapon` (Entity) - New weapon

**Returns:**
- (boolean, optional) - True to prevent automatic range adjustment

**Realm:** 🌐 SHARED

**Source:** `lua/entities/drgbase_nextbot/weapons.lua:67`

---

### ENT:OnAimAtEntity

```lua
function ENT:OnAimAtEntity(entity)
```

Called to determine aim point on entity.

**Parameters:**
- `entity` (Entity) - Target entity

**Returns:**
- (Vector, optional) - Custom aim position (default: WorldSpaceCenter)

**Realm:** 🌐 SHARED

**Example:**
```lua
function ENT:OnAimAtEntity(entity)
    -- Always aim for the head
    if entity:IsPlayer() or entity:IsNPC() then
        local headBone = entity:LookupBone("ValveBiped.Bip01_Head1")
        if headBone then
            return entity:GetBonePosition(headBone)
        end
    end
end
```

**Source:** `lua/entities/drgbase_nextbot/weapons.lua:70`

---

## Damage Types

Common damage type enums (from Source engine):

```lua
DMG_GENERIC          -- Generic damage
DMG_CRUSH            -- Crushing damage
DMG_BULLET           -- Bullet damage
DMG_SLASH            -- Slashing/cutting
DMG_BURN             -- Fire damage
DMG_VEHICLE          -- Vehicle collision
DMG_FALL             -- Fall damage
DMG_BLAST            -- Explosive
DMG_CLUB             -- Blunt damage
DMG_SHOCK            -- Electric
DMG_SONIC            -- Sonic damage
DMG_ENERGYBEAM       -- Energy beam
DMG_POISON           -- Poison
DMG_ACID             -- Acid
```

---

## Hit Groups

Body part enums for hit detection:

```lua
HITGROUP_GENERIC     -- Generic
HITGROUP_HEAD        -- Head
HITGROUP_CHEST       -- Chest
HITGROUP_STOMACH     -- Stomach
HITGROUP_LEFTARM     -- Left arm
HITGROUP_RIGHTARM    -- Right arm
HITGROUP_LEFTLEG     -- Left leg
HITGROUP_RIGHTLEG    -- Right leg
HITGROUP_GEAR        -- Gear/equipment
```

---

## See Also

- **[AI System](ai-system.md)** - Enemy targeting
- **[Base Configuration](base-configuration.md)** - Combat properties
- **[Getting Started](../getting-started/05-advanced-features.md)** - Weapon setup
