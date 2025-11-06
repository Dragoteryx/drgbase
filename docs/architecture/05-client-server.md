# Client-Server Architecture

## Realm Separation

<!-- TODO: Explain client-server separation in Source engine -->

## Server-Side (SERVER realm)

<!-- TODO: What runs on server -->

### Server Responsibilities
- AI logic and decision making
- Pathfinding calculations
- Damage calculations
- Health management
- Spawn control
- Physics simulation authority

### Server-Only Files
<!-- Files with sv_ prefix -->

## Client-Side (CLIENT realm)

<!-- TODO: What runs on client -->

### Client Responsibilities
- Rendering and visual effects
- UI and HUD
- Sound playback (client-side)
- Animations (prediction)
- Input handling
- Camera control

### Client-Only Files
<!-- Files with cl_ prefix -->

## Shared Code (Both realms)

<!-- TODO: What runs on both -->

### Shared Responsibilities
- Entity configuration
- Constants and enumerations
- Utility functions
- Structure definitions

## Network Communication

<!-- TODO: How client and server communicate -->

### Network Variables (NW2)

```lua
-- Server sets
self:SetNW2Int("Health", 100)

-- Client reads
local health = self:GetNW2Int("Health")
```

<!-- Document all NW2 vars used -->

### Network Messages

```lua
-- Server sends
net.Start("DrG_ChatMessage")
    net.WriteString("Message")
net.Send(ply)

-- Client receives
net.Receive("DrG_ChatMessage", function()
    local msg = net.ReadString()
end)
```

<!-- Document all network messages -->

### DrGBase Network System

```lua
-- Custom network functions
net.DrG_Send(name, ...)
net.DrG_Receive(name, callback)
```

## State Synchronization

<!-- TODO: How state is kept in sync -->

### Automatic Sync
<!-- NW2 variables -->

### Manual Sync
<!-- Network messages -->

### Prediction
<!-- Client-side prediction -->

## Performance Considerations

<!-- TODO: Network performance best practices -->

### Minimize Network Traffic
<!-- Best practices -->

### Update Frequency
<!-- What updates every tick vs less often -->

## Debugging

<!-- TODO: Debugging client-server issues -->

### Console Commands
```
sv_showimpacts 1
cl_showpos 1
net_graph 1
```

### Common Issues
<!-- Desync problems -->
<!-- Network message errors -->

---

**Previous:** [Module System](./04-module-system.md) | **Next:** [Design Patterns](./06-design-patterns.md)
