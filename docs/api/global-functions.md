# Global Functions

## Overview
DrGBase provides global functions accessible through the `DrGBase` table. These functions are used for framework operations, utilities, and NPC registration.

## Core Functions

### DrGBase.Print

```lua
DrGBase.Print(message, options)
```

Print a message with DrGBase formatting.

**Parameters:**
- `message` (string) - Message to print
- `options` (table, optional) - Print options
  - `chat` (boolean) - Print to chat instead of console
  - `player` (Player) - Target player (SERVER only)
  - `title` (Color) - Title color
  - `color` (Color) - Message color

**Realm:** 🌐 SHARED

**Example:**
```lua
DrGBase.Print("Hello World!")
DrGBase.Print("Server message", {chat = true, color = Color(0, 255, 0)})
DrGBase.Print("Player message", {player = ply, chat = true})
```

**Source:** `lua/autorun/drgbase.lua:6`

---

### DrGBase.Info

```lua
DrGBase.Info(message, options)
```

Print an info message (green title).

**Parameters:**
- `message` (string) - Message to print
- `options` (table, optional) - Print options

**Realm:** 🌐 SHARED

**Example:**
```lua
DrGBase.Info("NPC spawned successfully!")
```

**Source:** `lua/autorun/drgbase.lua:34`

---

### DrGBase.Error

```lua
DrGBase.Error(message, options)
```

Print an error message (red text).

**Parameters:**
- `message` (string) - Error message
- `options` (table, optional) - Print options

**Realm:** 🌐 SHARED

**Example:**
```lua
DrGBase.Error("Failed to load NPC!")
```

**Source:** `lua/autorun/drgbase.lua:39`

---

### DrGBase.ErrorInfo

```lua
DrGBase.ErrorInfo(message, options)
```

Print an error with info formatting (green title, red text).

**Parameters:**
- `message` (string) - Message
- `options` (table, optional) - Print options

**Realm:** 🌐 SHARED

**Source:** `lua/autorun/drgbase.lua:44`

---

## File Management

### DrGBase.IncludeFile

```lua
DrGBase.IncludeFile(fileName)
```

Include a Lua file with automatic realm handling.

**Parameters:**
- `fileName` (string) - Path to Lua file

**Returns:**
- (any) - Return value from included file

**Realm:** 🌐 SHARED

**Behavior:**
- Files starting with `sv_` are SERVER only
- Files starting with `cl_` are CLIENT only
- Other files are SHARED (AddCSLuaFile called automatically)

**Example:**
```lua
DrGBase.IncludeFile("drgbase/weapons.lua")
DrGBase.IncludeFile("entities/my_npc/sv_logic.lua")
```

**Source:** `lua/autorun/drgbase.lua:70`

---

### DrGBase.IncludeFiles

```lua
DrGBase.IncludeFiles(fileNames)
```

Include multiple Lua files.

**Parameters:**
- `fileNames` (table) - Array of file paths

**Returns:**
- (table) - Table mapping file names to return values

**Realm:** 🌐 SHARED

**Example:**
```lua
DrGBase.IncludeFiles({
    "drgbase/weapons.lua",
    "drgbase/possession.lua"
})
```

**Source:** `lua/autorun/drgbase.lua:82`

---

### DrGBase.IncludeFolder

```lua
DrGBase.IncludeFolder(folder)
```

Include all Lua files in a folder.

**Parameters:**
- `folder` (string) - Folder path relative to lua/

**Returns:**
- (table) - Table mapping file names to return values

**Realm:** 🌐 SHARED

**Example:**
```lua
DrGBase.IncludeFolder("drgbase/meta")
```

**Source:** `lua/autorun/drgbase.lua:89`

---

### DrGBase.RecursiveInclude

```lua
DrGBase.RecursiveInclude(folder)
```

Recursively include all Lua files in folder and subfolders.

**Parameters:**
- `folder` (string) - Root folder path

**Returns:**
- (table) - Table mapping all file paths to return values

**Realm:** 🌐 SHARED

**Example:**
```lua
DrGBase.RecursiveInclude("drgbase")
```

**Source:** `lua/autorun/drgbase.lua:97`

---

## NextBot Registration

### DrGBase.AddNextbot

```lua
DrGBase.AddNextbot(ENT)
```

Register a NextBot entity with DrGBase.

**Parameters:**
- `ENT` (table) - Entity table

**Returns:**
- (boolean) - True if successful, false if invalid

**Realm:** 🌐 SHARED

**Behavior:**
- Precaches models and sounds
- Registers with spawn menu
- Adds to DrGBase nextbot list
- Sets up killicon (CLIENT)

**Required ENT Properties:**
- `ENT.PrintName` - Display name
- `ENT.Category` - Spawn menu category
- `ENT.Folder` - Entity folder path (automatic)

**Example:**
```lua
if not DrGBase then return end
ENT.Base = "drgbase_nextbot"
ENT.PrintName = "My NPC"
ENT.Category = "My NPCs"

-- ... properties ...

AddCSLuaFile()
DrGBase.AddNextbot(ENT)  -- Register NPC
```

**Source:** `lua/drgbase/nextbots.lua:48`

---

### DrGBase.AddNextbotMixins

```lua
DrGBase.AddNextbotMixins(ENT)
```

Add internal hook mixins to NextBot (called automatically).

**Parameters:**
- `ENT` (table) - Entity table

**Realm:** 🖥️ SERVER

**Note:** This is an internal function. You don't need to call this directly.

**Source:** `lua/drgbase/nextbots.lua:6`

---

### DrGBase.GetNextbots

```lua
DrGBase.GetNextbots()
```

Get all spawned DrGBase NextBots.

**Returns:**
- (table) - Array of NextBot entities

**Realm:** 🖥️ SERVER

**Example:**
```lua
local nextbots = DrGBase.GetNextbots()
for i, npc in ipairs(nextbots) do
    print(npc:GetClass(), npc:Health())
end
```

**Source:** `lua/drgbase/nextbots.lua:137`

---

## Utility Functions

### DrGBase.IsTarget

```lua
DrGBase.IsTarget(entity)
```

Check if entity can be targeted by NPCs.

**Parameters:**
- `entity` (Entity) - Entity to check

**Returns:**
- (boolean) - True if valid target

**Realm:** 🖥️ SERVER

**Valid Targets:**
- Players
- NPCs
- NextBots
- Entities with `DrGBase_Target = true`

**Blacklisted:**
- `npc_bullseye`
- `npc_grenade_frag`
- `npc_tripmine`
- etc. (see source)

**Example:**
```lua
if DrGBase.IsTarget(entity) then
    self:SetEnemy(entity)
end
```

**Source:** `lua/drgbase/misc.lua:51`

---

### DrGBase.CanAttack

```lua
DrGBase.CanAttack(entity)
```

Check if entity can be attacked.

**Parameters:**
- `entity` (Entity) - Entity to check

**Returns:**
- (boolean) - True if can attack

**Realm:** 🖥️ SERVER

**Example:**
```lua
if DrGBase.CanAttack(target) then
    self:Attack({damage = 10})
end
```

**Source:** `lua/drgbase/misc.lua:64`

---

### DrGBase.IsMeleeWeapon

```lua
DrGBase.IsMeleeWeapon(weapon)
```

Check if weapon is melee.

**Parameters:**
- `weapon` (Weapon) - Weapon entity

**Returns:**
- (boolean) - True if melee weapon

**Realm:** 🌐 SHARED

**Detection Methods:**
- Hold type contains "melee", "fist", "knife"
- `weapon.DrGBase_Melee = true`

**Example:**
```lua
local weapon = self:GetWeapon()
if DrGBase.IsMeleeWeapon(weapon) then
    -- Melee attack logic
end
```

**Source:** `lua/drgbase/misc.lua:10`

---

### DrGBase.CreateProjectile

```lua
DrGBase.CreateProjectile(model, binds)
```

Create a DrGBase projectile.

**Parameters:**
- `model` (string/table) - Model path or table of models
- `binds` (table) - Hook functions
  - `Init(proj)` - Initialize
  - `Think(proj)` - Think hook
  - `Contact(proj, ent)` - On contact
  - `Use(proj, activator)` - On use
  - `DealtDamage(proj, target, dmg)` - Damage dealt
  - `TakeDamage(proj, dmg)` - Take damage
  - `Remove(proj)` - On remove

**Returns:**
- (Entity) - Projectile entity

**Realm:** 🖥️ SERVER

**Example:**
```lua
local proj = DrGBase.CreateProjectile("models/weapons/w_grenade.mdl", {
    Init = function(self)
        self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
    end,
    Contact = function(self, ent)
        local dmg = DamageInfo()
        dmg:SetDamage(50)
        dmg:SetAttacker(self:GetOwner())
        ent:TakeDamageInfo(dmg)
        self:Remove()
    end
})
proj:SetPos(self:GetPos() + Vector(0, 0, 50))
proj:SetOwner(self)
proj:GetPhysicsObject():SetVelocity(self:GetForward() * 1000)
```

**Source:** `lua/drgbase/misc.lua:20`

---

### DrGBase.Blind

```lua
DrGBase.Blind()
```

Create a blind effect data object.

**Returns:**
- (BlindData) - Blind data object with methods:
  - `:SetDuration(seconds)` - Set blind duration
  - `:GetDuration()` - Get duration
  - `:ScaleDuration(scale)` - Scale duration
  - `:SetAttacker(ent)` - Set attacker
  - `:GetAttacker()` - Get attacker
  - `:SetInflictor(ent)` - Set inflictor
  - `:GetInflictor()` - Get inflictor

**Realm:** 🖥️ SERVER

**Example:**
```lua
local blind = DrGBase.Blind()
blind:SetDuration(5)  -- 5 seconds
blind:SetAttacker(self)

-- Apply to player
player:DrG_Blind(blind)
```

**Source:** `lua/drgbase/misc.lua:108`

---

### DrGBase.Material (CLIENT)

```lua
DrGBase.Material(name, ...)
```

Get cached material (creates and caches if not exists).

**Parameters:**
- `name` (string) - Material path
- `...` (any) - Additional Material() arguments

**Returns:**
- (IMaterial) - Material object

**Realm:** 💻 CLIENT

**Example:**
```lua
local mat = DrGBase.Material("sprites/glow04_noz")
render.SetMaterial(mat)
```

**Source:** `lua/drgbase/misc.lua:117`

---

## Constants

### DrGBase.Icon

```lua
DrGBase.Icon = "drgbase/icon16.png"
```

DrGBase icon path.

**Realm:** 🌐 SHARED

**Source:** `lua/autorun/drgbase.lua:2`

---

### DrGBase.DefaultFootsteps

```lua
DrGBase.DefaultFootsteps
```

Table of default footstep sounds per material type.

**Realm:** 🌐 SHARED

**Example:**
```lua
local footsteps = DrGBase.DefaultFootsteps[MAT_CONCRETE]
self:EmitSound(footsteps[math.random(#footsteps)])
```

**Source:** `lua/drgbase/nextbots.lua:141`

---

## Color Constants

Defined in `lua/drgbase/colors.lua`:

```lua
DrGBase.CLR_WHITE   -- White
DrGBase.CLR_RED     -- Red
DrGBase.CLR_GREEN   -- Green
DrGBase.CLR_BLUE    -- Blue
DrGBase.CLR_CYAN    -- Cyan
DrGBase.CLR_ORANGE  -- Orange
```

---

## See Also

- **[Enumerations](enumerations.md)** - Constants and enums
- **[Entity Functions](entity-functions.md)** - ENT methods
- **[Utilities](utilities.md)** - Helper functions
