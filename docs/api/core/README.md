# Core Framework API

Global DrGBase functions and core utilities.

## Files

- **[drgbase.md](./drgbase.md)** - DrGBase global table and main functions
- **[entity-helpers.md](./entity-helpers.md)** - Entity utility functions
- **[enumerations.md](./enumerations.md)** - Constants and enumerations
- **[colors.md](./colors.md)** - Color definitions

## DrGBase Global Functions

### Registration
<!-- TODO: Document registration functions -->
- `DrGBase.AddNextbot(ENT)` - Register a nextbot entity
- `DrGBase.AddWeapon(SWEP)` - Register a weapon
- `DrGBase.AddSpawner(ENT)` - Register a spawner

### File Inclusion
<!-- TODO: Document file inclusion -->
- `DrGBase.IncludeFile(fileName)` - Include a single file
- `DrGBase.IncludeFolder(folder)` - Include all files in folder
- `DrGBase.RecursiveInclude(folder)` - Recursively include folder

### Output
<!-- TODO: Document output functions -->
- `DrGBase.Print(msg, options)` - Print formatted message
- `DrGBase.Info(...)` - Print info message
- `DrGBase.Error(...)` - Print error message
- `DrGBase.ErrorInfo(...)` - Print error with info

---

See individual files for detailed documentation.
