# Enumerations

Constants and enumerations used throughout DrGBase.

**File:** `lua/drgbase/enumerations.lua`

## Factions

### Rebel & Resistance Factions

#### FACTION_REBELS
- **Value:** <!-- TODO -->
- **Description:** Half-Life 2 rebel faction
- **Enemies:** Combine, Zombies
- **Allies:** Players (by default)

#### FACTION_REFUGEES
- **Value:** <!-- TODO -->
- **Description:** Refugee faction

### Combine Factions

#### FACTION_COMBINE
- **Value:** <!-- TODO -->
- **Description:** Half-Life 2 Combine forces
- **Enemies:** Rebels, Players (by default)
- **Allies:** Other Combine units

#### FACTION_OVERWATCH
- **Value:** <!-- TODO -->
- **Description:** Combine Overwatch units

### Zombie Factions

#### FACTION_ZOMBIES
- **Value:** <!-- TODO -->
- **Description:** Zombie faction
- **Enemies:** Most living creatures
- **Behavior:** Hostile to non-zombies

### Xen Factions

#### FACTION_XEN_ARMY
- **Value:** <!-- TODO -->
- **Description:** Xen military units

#### FACTION_XEN_WILDLIFE
- **Value:** <!-- TODO -->
- **Description:** Xen wildlife/creatures

### Animal Factions

#### FACTION_ANIMALS
- **Value:** <!-- TODO -->
- **Description:** Animal creatures
- **Behavior:** Neutral or defensive

#### FACTION_ANTLIONS
- **Value:** <!-- TODO -->
- **Description:** Antlion faction

#### FACTION_BARNACLES
- **Value:** <!-- TODO -->
- **Description:** Barnacle faction

### Military Factions

#### FACTION_HECU
- **Value:** <!-- TODO -->
- **Description:** Hazardous Environment Combat Unit (Marines)

### Special Factions

#### FACTION_GMAN
- **Value:** <!-- TODO -->
- **Description:** G-Man faction
- **Behavior:** Special entity

---

## Relationship Dispositions

### D_LI (Like)
- **Value:** <!-- TODO -->
- **Description:** Friendly relationship
- **Behavior:** Will not attack, may help

### D_HT (Hate)
- **Value:** <!-- TODO -->
- **Description:** Hostile relationship
- **Behavior:** Will attack on sight

### D_FR (Fear)
- **Value:** <!-- TODO -->
- **Description:** Fearful relationship
- **Behavior:** Will flee from entity

### D_NU (Neutral)
- **Value:** <!-- TODO -->
- **Description:** Neutral relationship
- **Behavior:** Ignores entity unless provoked

### D_ER (Error)
- **Value:** <!-- TODO -->
- **Description:** Error/undefined relationship

---

## Possession Modes

### POSSESSION_MOVE_8DIR
- **Value:** <!-- TODO -->
- **Description:** 8-directional movement (WASD + diagonals)

### POSSESSION_MOVE_1DIR
- **Value:** <!-- TODO -->
- **Description:** Forward-only movement (W key)

### POSSESSION_MOVE_4DIR
- **Value:** <!-- TODO -->
- **Description:** 4-direction movement (WASD, no diagonals)

---

## Movement Types

### MOVE_MODE_WALK
- **Value:** <!-- TODO -->
- **Description:** Ground-based walking movement

### MOVE_MODE_FLY
- **Value:** <!-- TODO -->
- **Description:** Flying movement mode

---

## States

<!-- TODO: Document all state enumerations -->

### AI States

#### STATE_IDLE
- **Description:** NPC is idle

#### STATE_ALERT
- **Description:** NPC is alert

#### STATE_COMBAT
- **Description:** NPC is in combat

### Movement States

#### MOVEMENT_IDLE
- **Description:** Not moving

#### MOVEMENT_WALK
- **Description:** Walking

#### MOVEMENT_RUN
- **Description:** Running

---

## Animation Events

<!-- TODO: Document animation event constants -->

---

## Damage Types

<!-- TODO: Document any custom damage type constants -->

---

## Trace Masks

<!-- TODO: Document any custom trace masks -->

---

## See Also

- [Relationship System](../../systems/relationships/README.md)
- [Faction Guide](../../guides/factions.md)
