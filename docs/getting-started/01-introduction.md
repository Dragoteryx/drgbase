# Introduction to DrGBase

## What is DrGBase?

DrGBase is a powerful and comprehensive **nextbot framework** for Garry's Mod that provides developers with a complete toolkit for creating custom AI-driven NPCs. Built on top of Garry's Mod's native nextbot system, DrGBase extends the base functionality with a rich set of features, hooks, and utilities that dramatically simplify NPC development while enabling sophisticated behaviors that would otherwise require hundreds of lines of custom code.

At its core, DrGBase is designed to be both **beginner-friendly** and **highly extensible**. You can create a functional NPC with just a few lines of configuration, or dive deep into the framework's extensive API to build complex AI systems with custom behaviors, advanced pathfinding, faction-based relationships, and more.

The framework handles the tedious aspects of nextbot development—movement, pathfinding, animations, sound synchronization, network replication, and physics—allowing you to focus on what makes your NPCs unique.

## Key Features

DrGBase provides a comprehensive suite of features that cover every aspect of NPC development:

### **Advanced AI System**
- **Smart Detection**: Vision-based detection with configurable FOV, range, and line-of-sight checking
- **Sound Awareness**: NPCs can hear and respond to sounds in their environment
- **Entity Awareness**: Persistent memory system that tracks known entities and their last known positions
- **Enemy Selection**: Intelligent target prioritization based on threat level, distance, and relationship
- **Behavior Types**: Pre-built behavior patterns (base, human, custom) for different NPC types

### **Sophisticated Movement & Pathfinding**
- **Automatic Navigation**: Built-in pathfinding using Garry's Mod's navmesh system
- **Climbing System**: NPCs can climb ledges, props, and ladders with configurable height limits
- **Jump & Leap**: Smart jumping over obstacles and leaping at enemies
- **Patrol System**: Easy-to-configure patrol routes with search and sound investigation behaviors
- **Movement Animations**: Automatic walk/run animation synchronization with movement speed

### **Combat & Weapons**
- **Melee Attacks**: Configurable melee attack system with damage, range, and timing controls
- **Ranged Attacks**: Support for projectile and hitscan weapons
- **Weapon Management**: NPCs can equip, switch, and drop weapons
- **Custom Projectiles**: Full projectile entity system with physics and custom behaviors
- **Attack Animations**: Synchronized attack animations with damage dealing at specific frames

### **Faction & Relationship System**
- **Pre-defined Factions**: Built-in factions (Rebels, Combine, Zombies, Antlions, etc.)
- **Custom Factions**: Create your own faction hierarchies
- **Dynamic Relationships**: Set relationships by entity, class, model, or faction
- **Disposition System**: Five relationship levels (Error, Hate, Fear, Like, Neutral)
- **Damage Tolerance**: NPCs remember friendly fire and can turn hostile

### **Possession System**
- **Player Control**: Players can possess and directly control NPCs
- **Camera Views**: Multiple camera angles with customizable positioning
- **Control Bindings**: Map keyboard/mouse inputs to custom NPC actions
- **Movement Modes**: Different movement styles (8-direction, forward-only, 4-direction)
- **UI Integration**: Optional crosshair and possession prompts

### **Animation & Sounds**
- **Activity System**: Use Garry's Mod activities (ACT_WALK, ACT_RUN, etc.)
- **Sequence Control**: Direct sequence playback with speed control
- **Gesture Layers**: Play gestures on top of movement animations
- **Sound Events**: Hook sounds to spawn, idle, damage, death, and custom events
- **Footstep System**: Automatic footstep sound playback
- **Sprite NPCs**: Special support for 2D sprite-based NPCs

### **Developer Tools**
- **Info Tool**: Inspect NPC properties, relationships, and state in real-time
- **Relationship Tool**: Modify NPC relationships on the fly
- **AI Tools**: Debug pathfinding, view detection ranges, and test behaviors
- **Faction Editor**: Manage faction relationships visually
- **Damage Testing**: Test NPC damage responses and hitboxes

### **Extensible Architecture**
- **Hook System**: Over 50 hooks for customizing every aspect of behavior
- **Modular Design**: Each system (AI, movement, weapons, etc.) is self-contained
- **Metatable Extensions**: Extended Entity, Player, NPC, Vector, and PhysObj metatables
- **Server-Client Sync**: Automatic network replication of critical data
- **ConVar Configuration**: Global configuration options with console variables
- **Resource Management**: Automatic precaching of models, sounds, and particles

## What Can You Build?

DrGBase is flexible enough to support a wide variety of NPC types and use cases:

### **Custom Enemy NPCs**
Create unique enemies with custom models, sounds, and behaviors. From simple melee zombies to complex ranged combatants with advanced tactics, DrGBase handles the foundation so you can focus on making your enemies feel unique.

### **Friendly Allies & Companions**
Build NPCs that fight alongside players, follow them around, or provide assistance. The faction system makes it easy to set up ally relationships, and the possession system can even let players directly control their companions when needed.

### **Boss Encounters**
Combine high health pools, multiple attack patterns, and custom AI behaviors to create challenging boss fights. Use hooks to implement phase transitions, special abilities, and unique mechanics.

### **Faction-Based Combat**
Set up complex faction dynamics where multiple groups have different relationships with each other and the player. Create scenarios where zombies fight combine soldiers while antlions attack both.

### **Flying NPCs**
The movement system supports airborne NPCs with customizable flight patterns, altitude control, and aerial attacks. Perfect for creating flying enemies or creatures.

### **Sprite-Based NPCs**
Special support for 2D sprite NPCs that always face the camera, useful for retro-style enemies or projectiles.

### **Interactive Creatures**
Build NPCs that respond to the environment, investigate sounds, patrol areas, and react dynamically to player actions. The awareness system makes NPCs feel alive and responsive.

### **Game Mode AI**
Use DrGBase as the AI foundation for custom game modes. Whether it's wave-based survival, tower defense, or competitive AI battles, the framework handles the heavy lifting.

### **Custom Weapons & Projectiles**
DrGBase includes a weapon system for NPCs, allowing you to create custom weapons with unique firing patterns, projectiles with special physics, and complex combat behaviors.

## When to Use DrGBase

DrGBase is the ideal choice when:

### **You Need Complex AI Behaviors**
If your NPCs need to navigate environments, detect and track enemies, investigate sounds, patrol areas, or make tactical decisions, DrGBase provides all these systems out of the box. No need to write pathfinding or detection code from scratch.

### **You Want Rapid Prototyping**
Get a functional NPC up and running in minutes, not hours. The framework's configuration-based approach means you can create basic NPCs with just property declarations, then iterate and add complexity as needed.

### **You Need Faction Management**
If your addon involves multiple factions with complex relationships—allies, enemies, neutrals—DrGBase's relationship system handles all the logic for you. NPCs automatically know who to attack and who to ignore based on faction membership.

### **You Value Extensibility**
DrGBase's hook system lets you customize behavior at every level. Start with the defaults, override only what you need, and keep your code clean and maintainable.

### **You Want Player Interaction**
The possession system is unique to DrGBase—players can take direct control of any NPC with possession enabled. Perfect for companion systems, vehicle-like NPCs, or testing NPC perspectives.

### **You're Building on Existing Examples**
DrGBase includes several example NPCs (zombies, headcrabs, antlions) that you can use as starting points or references. Learning from working code accelerates development.

### **You Need Developer Tools**
The included suite of developer tools makes debugging and testing NPCs much easier. Inspect relationships, visualize detection ranges, and modify behaviors in real-time without restarting the game.

## When NOT to Use DrGBase

While DrGBase is powerful and flexible, there are situations where simpler alternatives might be more appropriate:

### **Static or Non-Interactive Entities**
If you just need a prop, decoration, or static entity that doesn't move or have AI, use a regular `sent_base` entity. DrGBase's systems would be unnecessary overhead.

### **Pure Vehicle Entities**
For vehicles that players drive, use Garry's Mod's vehicle system (`vehicle_base`). While DrGBase's possession system can simulate vehicle-like control, it's designed for NPCs first and foremost.

### **Extremely Simple NPCs**
If your NPC literally just stands still or follows a single animation loop with no AI, you might not need DrGBase's full feature set. A basic scripted entity could suffice.

### **When You Need Direct SNPCs**
If you specifically need Source Engine NPCs (SNPCs) for compatibility with existing systems or mods, DrGBase won't help—it's built on nextbots, not SNPCs. However, nextbots are generally more flexible and performant than SNPCs for custom AI.

### **Very Small Addons with Size Constraints**
DrGBase is a framework with many features. If you're extremely concerned about file size and only need one very simple NPC, the framework might be more than you need (though the benefits usually outweigh the size cost).

**That said**, even for simple cases, DrGBase can save development time and provide a foundation for future expansion. Most developers find the benefits worth using it even for straightforward NPCs.

## Framework Philosophy

DrGBase is built around several core design principles that guide its development and usage:

### **Configuration Over Code**
Wherever possible, DrGBase favors configuration properties over writing code. Want to change movement speed? Set `ENT.RunSpeed`. Need to adjust detection range? Set `ENT.SightRange`. This approach makes NPCs quick to create and easy to understand at a glance.

### **Hooks for Customization**
When you do need custom behavior, DrGBase provides hooks at every key point. Rather than forcing you to override entire systems, you can hook into specific events (`OnDeath`, `OnMeleeAttack`, `OnNewEnemy`, etc.) and add your custom logic while keeping the base functionality intact.

### **Modular by Design**
Each major system (AI, movement, weapons, relationships, etc.) is implemented in its own file and can be understood independently. This modularity makes the codebase maintainable and helps developers learn one system at a time.

### **Server Authoritative, Client Aware**
Following Source Engine best practices, DrGBase maintains authority on the server while syncing necessary data to clients. This prevents cheating while keeping clients informed for visual feedback, UI, and prediction.

### **Performance Conscious**
The framework uses think delays, caching, and efficient algorithms to minimize performance impact. NPCs are designed to scale well—you can have many DrGBase NPCs active without significant performance degradation.

### **Fail Gracefully**
DrGBase includes extensive error checking and fallback behavior. Invalid configurations won't crash the game; instead, they'll log warnings and use sensible defaults. This makes development more forgiving and debugging easier.

### **Convention with Flexibility**
DrGBase provides sensible defaults and conventions (faction names, relationship types, behavior patterns) that work well together. But if you need something different, every convention can be overridden or extended.

### **Learning from Examples**
The framework includes multiple example NPCs that demonstrate different capabilities. These examples serve as both learning tools and starting points for your own creations.

### **Developer Experience Matters**
From the included debug tools to clear naming conventions, DrGBase prioritizes making the development experience smooth. The goal is to let you build what you imagine without fighting the framework.

## Community and Support

### **GitHub Repository**
The DrGBase source code is hosted on GitHub. You can browse the code, report issues, and contribute improvements.

- **Repository**: Check the remote repository for the latest source code
- **Issue Tracker**: Report bugs, request features, or ask questions via GitHub Issues
- **Contributions**: Pull requests are welcome for bug fixes, improvements, and new features

### **Getting Help**

When you need assistance:

1. **Check the Documentation**: This documentation covers most common scenarios and questions
2. **Study the Examples**: The included example NPCs (zombie, headcrab, antlion, sprite) demonstrate many techniques
3. **Use the Developer Tools**: The built-in info and debug tools can help diagnose issues
4. **Report Issues**: If you find a bug, report it on the GitHub issue tracker with:
   - Steps to reproduce the problem
   - Expected vs actual behavior
   - Any console errors or warnings
   - Your DrGBase version

### **Best Practices for Questions**

When asking for help:
- Provide relevant code snippets
- Include error messages or console output
- Explain what you're trying to achieve
- Mention what you've already tried
- Keep questions specific and focused

### **Workshop & Distribution**
DrGBase is available on the Steam Workshop for easy installation. Check the workshop page for update notifications and community discussions.

---

**Next:** [Installation](./02-installation.md)
