# Projectile Base API

API reference for `proj_drg_default`.

**Base Class:** `entities/proj_drg_default/`

## Files

- **[base-config.md](./base-config.md)** - Projectile properties
- **[functions.md](./functions.md)** - Projectile functions

## Quick Reference

```lua
ENT.Base = "proj_drg_default"
ENT.PrintName = "My Projectile"

ENT.ProjectileSpeed = 1000
ENT.ProjectileDamage = 50
ENT.ProjectileRadius = 200

function ENT:OnCollide(data)
    -- Handle collision
    self:Explode()
end
```

See [Creating Projectiles Guide](../../guides/creating-projectiles.md)
