# Relationships & Factions

## Overview
DrGBase uses a sophisticated relationship system to determine how NPCs interact with each other, players, and other entities. This guide explains how to configure relationships and use factions.

**Source:** `lua/entities/drgbase_nextbot/relationships.lua:1`

## Relationship Types

### Disposition Values

```lua
D_HT  -- Hate: Attack on sight
D_FR  -- Fear: Flee from
D_LI  -- Like: Ally with
D_NU  -- Neutral: Ignore
D_ER  -- Error: (unused)
```

### Relationship Behaviors

| Disposition | Behavior | Example |
|-------------|----------|---------|
| `D_HT` | Attacks target on sight | Zombie vs Player |
| `D_FR` | Flees from target | Citizen vs Zombie |
| `D_LI` | Helps and defends | Rebels with each other |
| `D_NU` | Ignores unless provoked | Most NPCs vs props |

## Default Relationship

The `DefaultRelationship` property sets the base relationship with all entities:

```lua
-- Hostile to everyone
ENT.DefaultRelationship = D_HT

-- Neutral to everyone
ENT.DefaultRelationship = D_NU

-- Friendly to everyone
ENT.DefaultRelationship = D_LI

-- Afraid of everyone
ENT.DefaultRelationship = D_FR
```

**Common Patterns:**

```lua
-- Hostile NPC (attacks players)
ENT.DefaultRelationship = D_HT

-- Passive NPC (ignores unless attacked)
ENT.DefaultRelationship = D_NU

-- Friendly NPC (helps players)
ENT.DefaultRelationship = D_LI
```

## Factions

Factions are groups of NPCs that share relationships. NPCs in the same faction are typically allies.

### Built-in Factions

**Source:** `lua/drgbase/enumerations.lua:6`

```lua
-- Half-Life 2
FACTION_REBELS      -- Resistance fighters
FACTION_COMBINE     -- Combine soldiers
FACTION_ANIMALS     -- Wildlife (crows, seagulls)
FACTION_ZOMBIES     -- Zombies & headcrabs
FACTION_ANTLIONS    -- Antlion army
FACTION_GMAN        -- G-Man (neutral)
FACTION_BARNACLES   -- Barnacles

-- Half-Life 1
FACTION_XEN_ARMY     -- Alien army (Vortigaunts, Grunts)
FACTION_XEN_WILDLIFE -- Xen creatures (Headcrabs, Houndeyes)
FACTION_HECU         -- Military soldiers
```

### Using Factions

```lua
-- Single faction
ENT.Factions = {FACTION_ZOMBIES}

-- Multiple factions
ENT.Factions = {FACTION_COMBINE, FACTION_HECU}

-- No faction
ENT.Factions = {}
```

### Creating Custom Factions

```lua
-- Define faction globally (in autorun or shared file)
FACTION_CUSTOM_ROBOTS = "FACTION_CUSTOM_ROBOTS"

-- Use in NPC
ENT.Factions = {FACTION_CUSTOM_ROBOTS}
```

## Relationship Examples

### Example 1: Hostile Zombie

```lua
ENT.PrintName = "Zombie"
ENT.DefaultRelationship = D_HT  -- Attacks everyone
ENT.Factions = {FACTION_ZOMBIES}  -- Friendly to other zombies
```

**Result:**
- Attacks players and most NPCs
- Allies with other zombies (same faction)
- Other zombies won't attack it

### Example 2: Rebel Soldier

```lua
ENT.PrintName = "Rebel"
ENT.DefaultRelationship = D_LI   -- Friendly to everyone
ENT.Factions = {FACTION_REBELS}  -- Part of rebel faction
```

**Result:**
- Friendly to players by default
- Allies with other rebels
- Will defend against hostile NPCs

### Example 3: Wild Animal

```lua
ENT.PrintName = "Crow"
ENT.DefaultRelationship = D_NU    -- Ignores everyone
ENT.Factions = {FACTION_ANIMALS}  -- Wildlife faction
```

**Result:**
- Ignores players and NPCs
- Neutral with other animals
- Flees if attacked (through `NeutralDamageTolerance`)

### Example 4: Multi-Faction Alliance

```lua
ENT.PrintName = "Combine Guard"
ENT.DefaultRelationship = D_HT       -- Hostile to non-allies
ENT.Factions = {FACTION_COMBINE, FACTION_HECU}  -- Two factions
```

**Result:**
- Attacks players and rebels
- Allies with Combine AND HECU faction members
- Coordinate with multiple allied groups

## Damage Tolerance

Damage tolerance controls when relationships change based on damage taken.

### Properties

```lua
ENT.AllyDamageTolerance = 0.33      -- 33% health lost
ENT.AfraidDamageTolerance = 0.33
ENT.NeutralDamageTolerance = 0.33
```

### How It Works

When an NPC is damaged by another entity:
1. Calculate damage as percentage of max health
2. Compare to tolerance threshold
3. Change relationship if threshold exceeded

**Example:**

```lua
-- NPC has 100 health, tolerance is 0.33
-- Takes 40 damage (40% of health)
-- 40% > 33%, so relationship changes

-- Ally -> Hate (betrayed!)
-- Afraid -> Hate (fight back!)
-- Neutral -> Hate (provoked!)
```

### Use Cases

```lua
-- Quick to anger
ENT.AllyDamageTolerance = 0.1    -- 10% damage = betrayal
ENT.NeutralDamageTolerance = 0.1  -- 10% damage = aggro

-- Very forgiving
ENT.AllyDamageTolerance = 0.9    -- Ignore most ally damage
ENT.NeutralDamageTolerance = 0.5  -- Takes a lot to anger

-- Cowardly
ENT.AfraidDamageTolerance = 0.1   -- Quickly becomes hostile when afraid
```

## Frightening NPCs

```lua
ENT.Frightening = true
```

When `Frightening = true`, other NPCs with `D_NU` or `D_LI` relationship will fear this NPC.

**Example:**

```lua
-- Scary boss monster
ENT.PrintName = "Gargantua"
ENT.DefaultRelationship = D_HT
ENT.Frightening = true
ENT.SpawnHealth = 1000
```

**Result:**
- Neutral NPCs flee from this NPC
- Allied NPCs may flee (if afraid)
- Creates boss-like encounters

## Setting Relationships at Runtime

### In CustomInitialize

```lua
function ENT:CustomInitialize()
    -- Override default for players
    self:SetRelationship(player.GetAll(), D_HT)

    -- Friendly to a specific NPC
    local friendNPC = ents.FindByClass("npc_drg_zombie")[1]
    if IsValid(friendNPC) then
        self:SetRelationship(friendNPC, D_LI)
    end
end
```

### Based on Conditions

```lua
function ENT:CustomThink()
    -- Become hostile at low health
    if self:Health() < self:GetMaxHealth() * 0.25 then
        self:SetDefaultRelationship(D_HT)
    end
end
```

## Advanced Relationship Patterns

### Faction War

```lua
-- Rebel NPC
ENT.DefaultRelationship = D_HT  -- Hostile to non-faction
ENT.Factions = {FACTION_REBELS}

-- Combine NPC
ENT.DefaultRelationship = D_HT  -- Hostile to non-faction
ENT.Factions = {FACTION_COMBINE}
```

**Result:** Rebels and Combine attack each other on sight

### Neutral Mediator

```lua
ENT.DefaultRelationship = D_NU  -- Neutral to all
ENT.Factions = {}               -- No faction
ENT.NeutralDamageTolerance = 0.9  -- Very forgiving
```

**Result:** Ignores combat, won't attack unless heavily damaged

### Protective Ally

```lua
ENT.DefaultRelationship = D_LI    -- Friendly to all
ENT.Factions = {FACTION_REBELS}
ENT.AllyDamageTolerance = 0.05   -- Defend allies aggressively
```

**Result:** Helps everyone, quickly retaliates when allies are hurt

### Paranoid NPC

```lua
ENT.DefaultRelationship = D_NU      -- Starts neutral
ENT.NeutralDamageTolerance = 0.01   -- Any damage = hostile
```

**Result:** Ignores entities until touched, then attacks

## Relationship Hooks

### OnNewEnemy

```lua
function ENT:OnNewEnemy(enemy)
    -- Called when NPC spots a new enemy
    self:EmitSound("npc/zombie/zombie_alert.wav")
    -- Alert nearby allies
end
```

### OnAllyEnemy

```lua
function ENT:OnAllyEnemy(enemy)
    -- Called when fighting with an ally against same enemy
    -- Coordinate attacks, share tactics
end
```

### OnLoseEnemy

```lua
function ENT:OnLoseEnemy(enemy)
    -- Called when NPC loses sight of enemy
    -- Return to patrol, go on alert
end
```

## Debugging Relationships

### Console Commands

```lua
-- Show relationship info in console
function ENT:CustomThink()
    local enemy = self:GetEnemy()
    if IsValid(enemy) then
        print("Enemy:", enemy)
        print("Relationship:", self:GetRelationship(enemy))
        print("Visible:", self:Visible(enemy))
    end
end
```

### Visual Debugging

```lua
-- Draw relationship lines (CLIENT)
function ENT:CustomDraw()
    local enemy = self:GetEnemy()
    if IsValid(enemy) then
        local relationship = self:GetRelationship(enemy)
        local color = Color(255, 0, 0)  -- Red = hostile
        if relationship == D_LI then color = Color(0, 255, 0) end  -- Green = ally
        if relationship == D_NU then color = Color(255, 255, 0) end  -- Yellow = neutral
        if relationship == D_FR then color = Color(255, 165, 0) end  -- Orange = fear

        render.DrawLine(self:EyePos(), enemy:EyePos(), color, false)
    end
end
```

## Common Issues

### NPCs Don't Attack Each Other

**Problem:** NPCs with different factions don't fight

**Solution:** Set `DefaultRelationship = D_HT` on both NPCs

```lua
-- Both NPCs need hostile default
ENT.DefaultRelationship = D_HT
```

### NPCs Attack Allies

**Problem:** Same faction NPCs attack each other

**Solution:** Ensure both NPCs share the same faction

```lua
-- Both NPCs must have exact same faction
ENT.Factions = {FACTION_COMBINE}  -- Not FACTION_HECU
```

### NPC Won't Retaliate

**Problem:** NPC takes damage but doesn't fight back

**Solution:** Check damage tolerance

```lua
-- Lower tolerance = easier to anger
ENT.NeutralDamageTolerance = 0.1
```

## Best Practices

1. **Use factions for groups** - Don't rely solely on DefaultRelationship
2. **Test relationships** - Spawn multiple NPCs to verify behavior
3. **Consider tolerance** - Balance damage forgiveness for gameplay
4. **Document custom factions** - Comment faction purpose and members

## Next Steps

- **[Advanced Features](05-advanced-features.md)** - Weapons, possession, behaviors
- **[API: Relationships](../api/relationships.md)** - Full relationship API
- **[Guide: Creating Factions](../guides/creating-factions.md)** - Detailed faction system

---

**Previous:** [Understanding Properties](03-understanding-properties.md) | **Next:** [Advanced Features](05-advanced-features.md)
