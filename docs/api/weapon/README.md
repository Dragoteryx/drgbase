# Weapon Base API

API reference for `drgbase_weapon`.

**Base Class:** `weapons/drgbase_weapon/`

## Files

- **[base-config.md](./base-config.md)** - Weapon properties and configuration
- **[primary.md](./primary.md)** - Primary attack system
- **[secondary.md](./secondary.md)** - Secondary attack system
- **[functions.md](./functions.md)** - Weapon functions and hooks

## Quick Reference

```lua
SWEP.IsDrGWeapon = true
SWEP.PrintName = "My Weapon"
SWEP.Category = "DrGBase"

function SWEP:CustomInitialize()
    -- Setup
end

function SWEP:CustomPrimaryAttack()
    -- Primary fire
end

function SWEP:CustomSecondaryAttack()
    -- Secondary fire
end

DrGBase.AddWeapon(SWEP)
```

See [Creating Weapons Guide](../../guides/creating-weapons.md)
