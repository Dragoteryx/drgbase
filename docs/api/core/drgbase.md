# DrGBase Global API

Global `DrGBase` table functions and properties.

## Registration Functions

### DrGBase.AddNextbot(ENT)

Registers a nextbot entity with the framework.

**Realm:** 🟣 SHARED

**Parameters:**
- `ENT` (table) - Entity table with nextbot definition

**Returns:** None

**Example:**
```lua
if not DrGBase then return end
ENT.Base = "drgbase_nextbot"
-- ... entity definition ...
AddCSLuaFile()
DrGBase.AddNextbot(ENT)
```

**Usage:** <!-- TODO: Detailed usage information -->

---

### DrGBase.AddWeapon(SWEP)

Registers a weapon with the framework.

**Realm:** 🟣 SHARED

**Parameters:**
- `SWEP` (table) - Weapon table definition

**Returns:** None

**Example:**
```lua
SWEP.IsDrGWeapon = true
-- ... weapon definition ...
DrGBase.AddWeapon(SWEP)
```

**Usage:** <!-- TODO: Detailed usage information -->

---

### DrGBase.AddSpawner(ENT)

Registers a spawner entity.

**Realm:** 🟣 SHARED

**Parameters:**
- `ENT` (table) - Spawner entity table

**Returns:** None

**Example:**
```lua
-- TODO: Example
```

---

## File Inclusion Functions

### DrGBase.IncludeFile(fileName)

Intelligently includes a Lua file with realm detection.

**Realm:** 🟣 SHARED

**Parameters:**
- `fileName` (string) - File path relative to lua/

**Returns:** None

**Behavior:**
- Files prefixed with `sv_` only run on server
- Files prefixed with `cl_` are sent to client and run there
- Files with no prefix are shared (sent to client and run on both)

**Example:**
```lua
DrGBase.IncludeFile("drgbase/mymodule.lua")      -- Shared
DrGBase.IncludeFile("drgbase/sv_server.lua")     -- Server only
DrGBase.IncludeFile("drgbase/cl_client.lua")     -- Client only
```

---

### DrGBase.IncludeFolder(folder)

Includes all Lua files in a folder.

**Realm:** 🟣 SHARED

**Parameters:**
- `folder` (string) - Folder path relative to lua/

**Returns:** None

**Example:**
```lua
DrGBase.IncludeFolder("drgbase/meta")
```

---

### DrGBase.RecursiveInclude(folder)

Recursively includes all Lua files in a folder and subfolders.

**Realm:** 🟣 SHARED

**Parameters:**
- `folder` (string) - Folder path relative to lua/

**Returns:** None

**Example:**
```lua
DrGBase.RecursiveInclude("drgbase")
```

---

## Output Functions

### DrGBase.Print(msg, options)

Prints a formatted message to console.

**Realm:** 🟣 SHARED

**Parameters:**
- `msg` (string) - Message to print
- `options` (table, optional) - Formatting options
  - `color` (Color) - Text color
  - `prefix` (string) - Prefix for message
  - etc. <!-- TODO: Document all options -->

**Returns:** None

**Example:**
```lua
DrGBase.Print("Hello World", {color = Color(255, 0, 0)})
```

---

### DrGBase.Info(...)

Prints an info message.

**Realm:** 🟣 SHARED

**Parameters:**
- `...` - Variable arguments to print

**Returns:** None

**Example:**
```lua
DrGBase.Info("Loading module:", moduleName)
```

---

### DrGBase.Error(...)

Prints an error message.

**Realm:** 🟣 SHARED

**Parameters:**
- `...` - Variable arguments to print

**Returns:** None

**Example:**
```lua
DrGBase.Error("Failed to load:", fileName)
```

---

### DrGBase.ErrorInfo(...)

Prints detailed error information.

**Realm:** 🟣 SHARED

**Parameters:**
- `...` - Variable arguments to print

**Returns:** None

**Example:**
```lua
DrGBase.ErrorInfo("Invalid parameter:", param)
```

---

## Global Properties

### DrGBase.Version

<!-- TODO: If version property exists, document it -->

---

## See Also

- [Entity Helpers](./entity-helpers.md)
- [Enumerations](./enumerations.md)
