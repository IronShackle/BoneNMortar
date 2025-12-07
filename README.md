# Bone & Mortar - Current Systems Status

**Engine:** Godot 4.5  
**Genre:** Top-down 2D Action Game  
**Stage:** Early Prototype

---

## Working Systems

### Core Architecture

#### Dual State Machine System
Every character entity (player and enemies) uses two parallel state machines:
- **Movement Machine** - Controls physics and movement (Idle, Run, Dodge)
- **Action Machine** - Controls abilities and actions (ActionIdle, Casting)

This separation allows simultaneous control - you can dodge while maintaining action state without conflicts.

#### MobBase Entity System
Base class (`CharacterBody2D → MobBase`) for all controllable entities:
- Template method pattern for extensibility
- Virtual methods: `_setup_movement_machine()`, `_setup_action_machine()`, `_setup_mob_specific()`
- Context-based communication with state machines (dictionaries passed each frame)
- Component aggregation (MovementComponent, HealthComponent, etc.)

### Movement System

#### MovementComponent
Handles all physics and movement mechanics:
- **Acceleration/Deceleration** - Curve-based speed ramping for smooth feel
- **Dodge Mechanics** - Curve-driven dash with configurable distance and duration
- **Movement Modifiers** - Speed multipliers for spell effects (slowing during cast)
- **Friction System** - Natural deceleration when stopping

**Movement States:**
- `IdleState` - Standing still, applies friction
- `RunState` - Active movement with acceleration curves
- `DodgeState` - Quick dash with invulnerability potential (not yet implemented)

### Action System

#### Spell System
Component-based spell casting with auto-discovery:
- **SpellBase** - Base class for all spell implementations (extends Node)
- **SpellManager** - Manages spell slots and resource consumption (RefCounted)
- Auto-discovers spells attached under "Spells" container node
- Primary/secondary spell slots
- Cast time with movement speed modifiers
- Dodge-cancellable casting

**Implemented Spells:**
- **Shadow Flame** - Single-target projectile spell
- **Bone Splinters** - Cone AoE (logic placeholder, needs implementation)

**Action States:**
- `ActionIdleState` - Ready to cast, monitors for cast input
- `CastingState` - Actively casting, tracks elapsed time, applies movement modifier

### Combat System

#### Hitbox/Hurtbox Architecture
Signal-driven collision detection:
- **Hitbox (Area2D)** - Damage dealer, emits `hit_detected` signal
- **Hurtbox (Area2D)** - Damage receiver, emits `hit_by_hitbox` signal
- Team-based collision filtering (player/enemy/neutral)
- Owner entities respond to signals for damage application

#### Projectile System
Generic projectile with configurable properties:
- Speed, lifetime, damage, direction
- **Pierce Mechanics** - Tracks hits per entity, max hit count
- Circle collision shape with configurable radius
- Auto-despawn after lifetime or max hits

#### Health System
Damage, healing, and damage-over-time:
- **HealthComponent** - Signals for health changes, death
- **DoT Tracking** - Active damage-over-time effects with tick rate
- `lose_life()`, `gain_life()`, `apply_dot()` API
- Death signal integration with MobBase

### AI System (Partial Implementation)

#### AIController Component
Integrates AI behaviors with entities:
- Queries behavior for movement direction each frame
- **KNOWN BUG:** Resource sharing issue when multiple enemies share same behavior

#### Behaviors (Placeholder)
- **ChasePlayerBehavior** - Seeks player position
- **Base AIBehavior** - Resource-based (design needs rework)

**Note:** AI system currently has architectural issues and is being redesigned to use a state-machine-like approach with RefCounted behavior instances instead of Resources.

### Player Controller

#### Input System
WASD movement with mouse-aimed casting:
- Movement: WASD keys
- Primary spell: Left mouse button
- Secondary spell: Right mouse button (not yet equipped)
- Dodge: Spacebar

#### State Integration
- Dodge state blocks casting (transition rule)
- Movement state changes trigger action machine rule updates
- Smooth integration of movement and spell casting

---

## Systems In Progress / TODO

### High Priority
- [ ] **AI System Redesign** - Convert to behavior state machine with data-driven config
- [ ] Fix AI Controller resource sharing bug
- [ ] Implement damage application in combat (signals wired, logic needed)
- [ ] Mana system (interface defined, not implemented)

### Medium Priority
- [ ] Spell cooldown tracking (TODOs in SpellManager)
- [ ] Secondary spell slot usage
- [ ] Bone Splinters cone AoE implementation
- [ ] UI system (health bars, spell indicators, etc.)

### Low Priority / Future
- [ ] Audio system
- [ ] Multiple enemy types
- [ ] Minion recruitment system
- [ ] Save/load system

---

## Known Issues

1. **AI Resource Sharing Bug** - Multiple enemies with same AIBehavior Resource share state, causing all to use one enemy's position. Crashes when that enemy dies. Requires architectural redesign.

2. **Debug Print Statements** - Many `print()` statements present throughout codebase for development debugging.

3. **Temporary Scene Files** - `.tmp` scene files in repository need cleanup.

4. **Incomplete Damage System** - Hitbox/Hurtbox signals emit correctly, but damage application logic needs completion.

---

## Architecture Patterns

### State Machine Pattern
Generic, reusable implementation in `Systems/state_machine/`:
- States are `RefCounted` classes (no scene presence)
- Lifecycle: `enter()` → `update()` → `get_transition()` → `exit()`
- Transition rules for controlling valid state changes
- Signal emission on state changes

### Component Pattern
Functionality composed through child nodes:
- `MovementComponent` - Physics
- `HealthComponent` - Life/damage
- `AIController` - AI integration
- `SpellManager` - Spell management

### Template Method Pattern
`MobBase` defines algorithm structure, subclasses provide implementation:
- Virtual methods for state machine setup
- Context providers for per-frame data
- Extensible without modifying base class

### Strategy Pattern (AI - needs rework)
Currently attempting swappable AI behaviors via Resources (has issues).

---

## File Organization

```
BoneNMortar/
├── Systems/
│   ├── AI/                    # AI behavior system (needs redesign)
│   ├── Combat/                # Hitbox/Hurtbox, Spells, Health
│   ├── Movement/              # MovementComponent
│   ├── Player/                # PlayerController
│   └── state_machine/         # Generic state machine framework
├── mob_base.gd                # Base character class
├── enemy.gd                   # Enemy implementation
├── projectile.gd              # Projectile base
├── *.tscn                     # Scene files
└── CLAUDE.md                  # Comprehensive AI assistant guide
```

---

**Last Updated:** 2024-12-07
