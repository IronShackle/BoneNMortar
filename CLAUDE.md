# CLAUDE.md - AI Assistant Guide for BoneNMortar

**Last Updated**: 2025-11-15
**Project**: Project: DotScape (BoneNMortar)
**Engine**: Godot 4.5
**Type**: Top-down 2D action game with spell-casting mechanics

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Technology Stack](#technology-stack)
3. [Architecture Overview](#architecture-overview)
4. [Code Organization](#code-organization)
5. [Naming Conventions](#naming-conventions)
6. [Key Design Patterns](#key-design-patterns)
7. [Core Systems](#core-systems)
8. [Development Workflows](#development-workflows)
9. [Common Tasks and Patterns](#common-tasks-and-patterns)
10. [Important Constraints](#important-constraints)
11. [Testing Guidelines](#testing-guidelines)
12. [Git Workflow](#git-workflow)

---

## Project Overview

**BoneNMortar** (working title: "Project: DotScape") is an early-stage top-down 2D action game prototype featuring:

- Spell-casting combat system
- AI-controlled enemies
- Dual state machine architecture for sophisticated character behavior
- Component-based entity design
- Pixel art visual style

**Current Development Stage**: Early prototype/proof-of-concept
- Core systems implemented (movement, state machines, spells, AI)
- Basic enemy AI with chase behavior
- Two spell implementations (Bone Splinters, Shadow Flame)
- No polished gameplay loop yet
- Missing: combat damage systems, health, UI, multiple levels

---

## Technology Stack

### Primary Technologies

- **Engine**: Godot 4.5 (Forward Plus renderer)
- **Language**: GDScript (Godot's native scripting language)
- **Version Control**: Git

### Configuration Files

- `project.godot` - Main Godot project configuration
- `.editorconfig` - Editor formatting (UTF-8, consistent style)
- `.gitignore` - Godot-specific ignores (`.godot/`, `/android/`, etc.)
- `.gitattributes` - Line ending normalization (LF)

### No External Dependencies

- Pure vanilla Godot project (no third-party plugins)
- No package managers (npm, pip, cargo, etc.)
- All game logic is self-contained

---

## Architecture Overview

### Inheritance Hierarchy

```
CharacterBody2D
  └─ MobBase (mob_base.gd)
      ├─ PlayerController (Systems/Player/player_controller.gd)
      └─ Enemy (enemy.gd)

RefCounted
  └─ State (Systems/state_machine/state.gd)
      ├─ Movement States
      │   ├─ IdleState
      │   ├─ RunState
      │   └─ DodgeState
      └─ Action States
          ├─ ActionIdleState
          └─ CastingState

Node
  └─ SpellBase (Systems/Spells/spell_base.gd)
      ├─ BoneSplinters (Systems/Spells/Bone Splinters/bone_splinters.gd)
      └─ ShadowFlame (shadow_flame.gd)

Resource
  └─ AIBehavior (Systems/AI/ai_behavior.gd)
      └─ ChasePlayerBehavior (Systems/AI/Behaviors/chase_player_behavior.gd)

Area2D
  └─ Projectile (projectile.gd)
```

### Dual State Machine Architecture

**Every character entity (MobBase) has TWO parallel state machines:**

1. **Movement Machine** - Controls physics and movement behavior
   - States: Idle, Run, Dodge
   - Processes: Movement input, velocity, dodge mechanics

2. **Action Machine** - Controls actions and abilities
   - States: ActionIdle, Casting
   - Processes: Spell casting, ability usage

**Key Design Decision**: Separation allows simultaneous control of movement and actions. For example, dodging can disable casting without affecting movement state.

### Component-Based Design

Characters are composed of modular components:

- `MovementComponent` - Physics, velocity, acceleration/deceleration
- `AIController` - AI behavior integration (enemies only)
- `SpellManager` - Spell slot management and resource consumption
- `StateMachine` (x2) - Movement and action state management

---

## Code Organization

### Directory Structure

```
BoneNMortar/
├── Systems/                          # All game systems (organized by functionality)
│   ├── AI/                          # AI behavior system
│   │   ├── ai_behavior.gd          # Base AIBehavior resource class
│   │   ├── ai_controller.gd        # AI controller component
│   │   └── Behaviors/              # Specific AI behavior implementations
│   │       └── chase_player_behavior.gd
│   ├── Movement/                    # Movement system
│   │   └── movement_component.gd   # Physics and movement logic
│   ├── Player/                      # Player-specific logic
│   │   └── player_controller.gd    # Player input and control
│   ├── Spells/                      # Spell system
│   │   ├── spell_base.gd           # Base spell class
│   │   ├── spell_manager.gd        # Spell slot management
│   │   └── Bone Splinters/         # Individual spell implementations
│   │       └── bone_splinters.gd
│   └── state_machine/               # Generic state machine framework
│       ├── state_machine.gd        # StateMachine node
│       ├── state.gd                # Base State class
│       └── States/                 # State implementations
│           ├── Action/             # Action states
│           │   ├── action_idle_state.gd
│           │   └── casting_state.gd
│           └── Movement/           # Movement states
│               ├── idle_state.gd
│               ├── run_state.gd
│               └── dodge_state.gd
├── Game Dev Assets/                 # Art assets (sprites, tilesets)
│   ├── Knight 2D Pixel Art/        # Character sprites
│   └── Pixel Art Top Down - Basic v1.2.2/  # Tilesets and props
├── mob_base.gd                      # Base class for all characters
├── enemy.gd                         # Enemy implementation
├── projectile.gd                    # Projectile base class
├── shadow_flame.gd                  # Shadow Flame spell
├── game.tscn                        # Main game scene
├── Player.tscn                      # Player scene
├── MobBase.tscn                     # MobBase scene template
├── Basic_Enemy.tscn                 # Enemy scene
├── Projectile_Base.tscn             # Projectile scene template
├── shadow_flame.tscn                # Shadow Flame scene
├── project.godot                    # Godot project configuration
└── icon.svg                         # Project icon
```

### File Organization Principles

1. **System-based organization**: Code grouped by game system (`/Systems/AI/`, `/Systems/Movement/`)
2. **Separation of concerns**: Each system has its own directory
3. **Behavior folders**: Related behaviors grouped together (`/AI/Behaviors/`)
4. **State folders**: States organized by type (`/States/Action/`, `/States/Movement/`)
5. **Root-level for base classes**: Core base classes like `mob_base.gd`, `enemy.gd` at root

---

## Naming Conventions

### Files
- **Format**: `snake_case`
- **Examples**: `mob_base.gd`, `player_controller.gd`, `chase_player_behavior.gd`

### Classes
- **Format**: `PascalCase`
- **Examples**: `MobBase`, `StateMachine`, `SpellManager`, `AIController`
- **Declaration**: Use `class_name` for global accessibility

### Variables
- **Format**: `snake_case`
- **Examples**: `current_state`, `movement_machine`, `primary_spell`
- **Member variables**: No prefix (not `m_variable` or `_variable`)

### Functions
- **Format**: `snake_case`
- **Examples**: `get_movement_component()`, `set_initial_state()`, `_setup_movement_machine()`
- **Private/Virtual**: Prefix with `_` (e.g., `_setup_movement_machine()`)

### Signals
- **Format**: `snake_case`
- **Examples**: `state_changed`, `spell_cast`

### Constants
- **Format**: Not currently used in codebase, but prefer `SCREAMING_SNAKE_CASE`

### Scene Files
- **Format**: `PascalCase` or descriptive names
- **Examples**: `Player.tscn`, `MobBase.tscn`, `game.tscn`, `Projectile_Base.tscn`

---

## Key Design Patterns

### 1. State Machine Pattern (Core Architecture)

**Location**: `Systems/state_machine/state_machine.gd`

**Purpose**: Manages entity behavior through discrete states with controlled transitions.

**Key Features**:
- Generic, reusable implementation
- State lifecycle: `enter()` → `update()` → `exit()`
- Transition rules for controlling valid state changes
- Signal emission on state changes

**Usage Example**:
```gdscript
func _setup_movement_machine() -> void:
    var idle_state = IdleState.new(movement_machine, self)
    var run_state = RunState.new(movement_machine, self)

    movement_machine.add_state("Idle", idle_state)
    movement_machine.add_state("Run", run_state)
    movement_machine.set_initial_state("Idle")
    movement_machine.start()
```

### 2. Template Method Pattern

**Location**: `mob_base.gd`

**Purpose**: Base class defines algorithm structure; subclasses provide implementation.

**Virtual Methods**:
```gdscript
# Override these in subclasses
func _setup_movement_machine() -> void
func _setup_action_machine() -> void
func _setup_mob_specific() -> void
func get_movement_context(delta: float) -> Dictionary
func get_action_context(delta: float) -> Dictionary
```

**Pattern**: `MobBase` calls these in `_ready()` and `_physics_process()`, subclasses customize behavior.

### 3. Strategy Pattern

**Location**: `Systems/AI/ai_behavior.gd` and subclasses

**Purpose**: Encapsulate AI behaviors as swappable Resources.

**Usage**: Enemy assigns an `AIBehavior` resource (e.g., `ChasePlayerBehavior`), which determines movement logic without changing enemy code.

### 4. Component-Based Architecture

**Purpose**: Composition over inheritance for modular functionality.

**Components**:
- `MovementComponent` - Physics and movement
- `AIController` - AI integration
- `SpellManager` - Spell management

**Pattern**: Attach components as child nodes, access via `@onready` or `get_node()`

### 5. Context Pattern

**Location**: State machines

**Purpose**: Pass contextual data to states without tight coupling.

**Implementation**:
```gdscript
func get_movement_context(delta: float) -> Dictionary:
    return {
        "input_direction": Input.get_vector(...),
        "dodge_pressed": Input.is_action_just_pressed("dodge")
    }

# States read from context
var input_direction = context.get("input_direction", Vector2.ZERO)
```

---

## Core Systems

### 1. State Machine System

**Files**:
- `Systems/state_machine/state_machine.gd` - StateMachine node
- `Systems/state_machine/state.gd` - Base State class

**Responsibilities**:
- Maintain current state
- Process state updates
- Handle state transitions
- Enforce transition rules

**Key Methods**:
```gdscript
add_state(state_name: String, state: State) -> void
set_transition_rule(from_state: String, to_state: String, allowed: bool) -> void
set_initial_state(state_name: String) -> void
start() -> void
update(delta: float, context: Dictionary) -> void
transition_to(new_state_name: String) -> void
```

**Signals**:
- `state_changed(old_state: String, new_state: String)`

### 2. Movement System

**Files**:
- `Systems/Movement/movement_component.gd`

**Responsibilities**:
- Physics calculations (velocity, acceleration, friction)
- Dodge mechanics with customizable curves
- Movement state integration

**Key Properties**:
```gdscript
@export var max_speed: float
@export var acceleration: float
@export var friction: float
@export var dodge_speed: float
@export var dodge_duration: float
@export var dodge_curve: Curve
```

**Key Methods**:
```gdscript
move(character: CharacterBody2D, direction: Vector2, delta: float) -> void
start_dodge(direction: Vector2) -> void
update_dodge(character: CharacterBody2D, delta: float) -> bool
apply_friction(character: CharacterBody2D, delta: float) -> void
```

### 3. Spell System

**Files**:
- `Systems/Spells/spell_base.gd` - Base spell class
- `Systems/Spells/spell_manager.gd` - Spell slot management

**Architecture**:
- `SpellBase` - Inheritance-based spell implementation
- `SpellManager` - Aggregates spells, manages slots

**SpellBase Properties**:
```gdscript
@export var spell_name: String
@export var mana_cost: float
@export var cast_time: float
@export var movement_speed_modifier: float  # 0.0-1.0 multiplier
```

**SpellManager Features**:
- Auto-discovers spell nodes under caster
- Primary/secondary spell slots
- Mana cost validation (via caster's `has_mana()`/`consume_mana()`)
- Future: Cooldown tracking (TODO)

**Adding New Spells**:
1. Create new script extending `SpellBase`
2. Override `execute(caster: Node2D, target_position: Vector2)` method
3. Attach spell node to caster under "Spells" container
4. SpellManager auto-discovers and makes available

### 4. AI System

**Files**:
- `Systems/AI/ai_behavior.gd` - Base AIBehavior resource
- `Systems/AI/ai_controller.gd` - AIController component
- `Systems/AI/Behaviors/*.gd` - Specific behaviors

**Architecture**:
- `AIBehavior` (Resource) - Defines behavior logic
- `AIController` (Node) - Integrates behavior with entity

**Current Behaviors**:
- `ChasePlayerBehavior` - Simple player-following behavior

**Creating New Behaviors**:
1. Extend `AIBehavior` (Resource class)
2. Override `get_movement_direction(entity: Node2D) -> Vector2`
3. Assign behavior to `AIController.behavior` property

### 5. Character System (MobBase)

**File**: `mob_base.gd`

**Purpose**: Base class for all controllable entities (players, enemies)

**Architecture**:
```gdscript
CharacterBody2D (Godot built-in)
  └─ MobBase
      ├─ MovementComponent (child node)
      ├─ MovementMachine (child node)
      └─ ActionMachine (child node)
```

**Lifecycle**:
```
_ready()
  └─ _setup_movement_machine()  # Subclass implements
  └─ _setup_action_machine()    # Subclass implements
  └─ _setup_mob_specific()      # Subclass implements

_physics_process(delta)
  └─ get_movement_context(delta)  # Subclass implements
  └─ get_action_context(delta)    # Subclass implements
  └─ movement_machine.update()
  └─ action_machine.update()
```

**Subclass Responsibilities**:
- Implement context providers (`get_movement_context()`, `get_action_context()`)
- Set up state machines with appropriate states
- Add mob-specific components (AI, spells, etc.)

---

## Development Workflows

### Setting Up Godot

1. **Install Godot 4.5+**
   - Download from https://godotengine.org/
   - Ensure version 4.5 or later (project uses config_version=5)

2. **Open Project**
   - Open Godot, click "Import"
   - Navigate to `/home/user/BoneNMortar/project.godot`
   - Click "Import & Edit"

3. **Run Game**
   - Press F5 or click "Run Project" button
   - Main scene (`game.tscn`) will launch

### Development Environment

- **Editor**: Godot Editor (primary IDE)
- **Optional**: External text editor with GDScript support
  - VS Code + godot-tools extension
  - `.editorconfig` ensures consistent formatting

### No Build System Required

- Godot handles compilation automatically
- No Makefile, CMake, or similar tools
- Export system used for final builds (not configured yet)

### No CI/CD

- No automated testing or deployment pipelines
- Manual testing in Godot Editor

---

## Common Tasks and Patterns

### Adding a New State

1. **Create state file** in appropriate directory:
   - Movement states: `Systems/state_machine/States/Movement/`
   - Action states: `Systems/state_machine/States/Action/`

2. **Extend State base class**:
```gdscript
# Systems/state_machine/States/Movement/sprint_state.gd
extends State
class_name SprintState

func enter() -> void:
    print("Entering Sprint state")

func update(delta: float, context: Dictionary) -> void:
    var input_direction = context.get("input_direction", Vector2.ZERO)
    # Sprint logic here

func get_transition(context: Dictionary) -> String:
    if context.get("input_direction") == Vector2.ZERO:
        return "Idle"
    if context.get("sprint_released"):
        return "Run"
    return ""

func exit() -> void:
    print("Exiting Sprint state")
```

3. **Add to state machine** in character's setup:
```gdscript
func _setup_movement_machine() -> void:
    var sprint_state = SprintState.new(movement_machine, self)
    movement_machine.add_state("Sprint", sprint_state)
    # ... add other states and transitions
```

### Adding a New Spell

1. **Create spell directory**: `Systems/Spells/[Spell Name]/`

2. **Create spell script**:
```gdscript
# Systems/Spells/Fireball/fireball.gd
extends SpellBase
class_name Fireball

func _ready() -> void:
    spell_name = "Fireball"
    mana_cost = 30.0
    cast_time = 0.8
    movement_speed_modifier = 0.5

func execute(caster: Node2D, target_position: Vector2) -> void:
    print("Casting Fireball!")
    # Spawn projectile, apply effects, etc.
    var projectile = preload("res://Projectile_Base.tscn").instantiate()
    # Configure and add to scene
```

3. **Attach to caster**: Add as child node in scene or dynamically

4. **SpellManager auto-discovers** and makes available

### Adding a New AI Behavior

1. **Create behavior file**: `Systems/AI/Behaviors/[behavior_name].gd`

2. **Extend AIBehavior**:
```gdscript
# Systems/AI/Behaviors/patrol_behavior.gd
extends AIBehavior
class_name PatrolBehavior

@export var patrol_points: Array[Vector2] = []
var current_point_index: int = 0

func get_movement_direction(entity: Node2D) -> Vector2:
    if patrol_points.is_empty():
        return Vector2.ZERO

    var target = patrol_points[current_point_index]
    var direction = (target - entity.global_position).normalized()

    if entity.global_position.distance_to(target) < 10.0:
        current_point_index = (current_point_index + 1) % patrol_points.size()

    return direction
```

3. **Assign to enemy**: Set `AIController.behavior` property in editor or code

### Modifying Input Mappings

**Location**: `project.godot` (lines 18-62)

**Current Mappings**:
- WASD - Movement (`ui_left`, `ui_right`, `ui_up`, `ui_down`)
- Left Mouse Button - Primary spell (`cast_primary`)
- Right Mouse Button - Secondary spell (`cast_secondary`)
- Spacebar - Dodge (`dodge`)

**To Modify**:
1. Open Godot Editor
2. Project → Project Settings → Input Map
3. Modify existing or add new actions
4. Update corresponding code in `player_controller.gd`

### Working with Scenes

**Scene Structure**:
```
game.tscn (Main Scene)
  └─ (Contains player, enemies, level geometry)

Player.tscn
  └─ PlayerController (CharacterBody2D)
      ├─ MovementComponent
      ├─ MovementMachine
      ├─ ActionMachine
      ├─ Spells (Node container)
      │   ├─ BoneSplinters
      │   └─ ShadowFlame
      └─ Sprite2D / CollisionShape2D

Basic_Enemy.tscn
  └─ Enemy (CharacterBody2D)
      ├─ MovementComponent
      ├─ MovementMachine
      ├─ ActionMachine
      ├─ AIController
      └─ Sprite2D / CollisionShape2D
```

**Best Practices**:
- Keep scene hierarchy shallow (max 3-4 levels deep)
- Use `@onready` for node references
- Prefer scene inheritance for variants (not currently used)

---

## Important Constraints

### 1. Godot-Specific Constraints

**File Extensions**:
- Scripts: `.gd` (GDScript)
- Scenes: `.tscn` (text-based scene format)
- Resources: `.tres` (text-based resource format)
- Imported assets: `.import` (auto-generated, never commit manually)

**Scene UIDs**:
- Godot 4+ uses UIDs for stable references
- `.uid` files track these (19 files in project)
- Never manually edit `.uid` files
- These files MUST be committed to Git

**Node References**:
- Use `@onready` for child nodes: `@onready var component = $Component`
- Use `get_node()` for dynamic access: `get_node("Path/To/Node")`
- Avoid hard-coded node paths when possible

**Resource vs. Node**:
- **Resource** - Data-only, no scene presence (e.g., `AIBehavior`, `SpellManager`)
- **Node** - Scene entity with lifecycle (e.g., `SpellBase`, `StateMachine`)
- Choose based on whether it needs scene tree access

### 2. State Machine Constraints

**Transition Rules**:
- States can block transitions to other states
- Use `set_transition_rule(from, to, allowed)` to control
- Example: Dodge state blocks casting

**Context Dictionaries**:
- Pass data via dictionaries, not direct state access
- States should not directly call entity methods (use context)
- Keeps states decoupled and reusable

**State Ownership**:
- Each state machine owns its states
- Don't share state instances between machines
- Create new state instances for each machine

### 3. Current Limitations (TODOs)

**Missing Systems**:
- Health and damage system (referenced but not implemented)
- Mana system (interface defined, not implemented: `has_mana()`, `consume_mana()`)
- Cooldown tracking (TODO comments in `spell_manager.gd`)
- UI system (no HUD, menus, etc.)
- Audio system (no sound or music)

**Code TODOs**:
- `Systems/Spells/spell_manager.gd:97` - Add cooldown tracking
- `Systems/Spells/spell_manager.gd:104` - Start cooldown on cast
- Enemy damage detection not implemented

**Known Issues**:
- Debug print statements present (should be removed for production)
- Temporary `.tmp` scene files in repository (3 files - cleanup needed)
- Missing validation in some spell execution paths

### 4. Performance Considerations

**Pixel Art Rendering**:
- Texture filter set to "nearest-neighbor" (no blur)
- Configured in `project.godot:66` (`default_texture_filter=0`)

**Physics**:
- All characters use `CharacterBody2D` (kinematic physics)
- Projectiles use `Area2D` (no physics, just collision detection)

---

## Testing Guidelines

### Current State: No Automated Testing

**No testing infrastructure**:
- No unit tests
- No integration tests
- No testing frameworks (GUT, WAT, etc.)

**Testing is manual**:
1. Run game in Godot Editor (F5)
2. Manually verify functionality
3. Use `print()` statements for debugging

### Recommended Testing Approach (Future)

**If implementing tests**:
1. Install GUT (Godot Unit Testing): https://github.com/bitwes/Gut
2. Create `tests/` directory
3. Write test scripts extending `GutTest`
4. Focus testing on:
   - State machine transitions
   - Component behavior (MovementComponent, SpellManager)
   - AI behavior logic

**Example Test Structure**:
```gdscript
# tests/test_state_machine.gd
extends GutTest

func test_state_transition():
    var sm = StateMachine.new()
    var state1 = State.new(sm, null)
    var state2 = State.new(sm, null)
    sm.add_state("State1", state1)
    sm.add_state("State2", state2)
    sm.set_initial_state("State1")
    sm.start()

    sm.transition_to("State2")
    assert_eq(sm.current_state_name, "State2")
```

---

## Git Workflow

### Branch Strategy

**Development Branches**:
- Branch naming: `claude/claude-md-[unique-id]`
- Example: `claude/claude-md-mi0nehwmuk7noemi-01YPE36DHQm8c5wCR1tW8otZ`

**Important**: All work should be done on designated feature branches, NOT main.

### Git Operations

**Pushing Changes**:
```bash
# Always use -u flag for first push
git push -u origin <branch-name>

# Branch MUST start with 'claude/' and end with session ID
# Otherwise push will fail with 403 error
```

**Retrying on Network Errors**:
- Retry up to 4 times with exponential backoff (2s, 4s, 8s, 16s)
- Applies to: push, fetch, pull

**Fetching/Pulling**:
```bash
# Prefer specific branch fetching
git fetch origin <branch-name>

# For pulls
git pull origin <branch-name>
```

### Commit Guidelines

**Commit Messages**:
- Concise, descriptive (focus on "why" not just "what")
- 1-2 sentences
- Examples:
  - "Add dodge mechanic to movement system for enhanced player mobility"
  - "Refactor state machine to support transition rules"
  - "Fix spell manager not discovering spells in Spells container"

**Before Committing**:
1. Check status: `git status`
2. Review changes: `git diff`
3. Stage relevant files: `git add <files>`
4. Commit: `git commit -m "message"`

**Do NOT Commit**:
- `.godot/` directory (auto-generated)
- `/android/` builds
- `.import` files (usually auto-generated, but `.uid` files should be committed)
- Temporary files (`.tmp`, `.swp`, etc.)

### Pull Request Workflow

**When creating PRs**:
1. Ensure all changes are committed and pushed
2. Run basic manual tests
3. Create PR with:
   - Clear title describing changes
   - Summary of what was added/changed
   - Test plan (manual testing steps)

**GitHub CLI not available** - User must create PR manually via GitHub web interface.

---

## Additional Notes for AI Assistants

### Code Reading Strategies

**Finding Functionality**:
1. **System-based search**: Look in `/Systems/[SystemName]/` first
2. **Base classes**: Check root-level files (`mob_base.gd`, etc.)
3. **State implementations**: Check `/Systems/state_machine/States/`

**Understanding Flow**:
1. Start with `mob_base.gd` - understand lifecycle
2. Follow to specific implementation (`player_controller.gd`, `enemy.gd`)
3. Examine states to see behavior logic
4. Check components for low-level functionality

### Modifying Code

**Always Prefer**:
- Editing existing files over creating new ones
- Using established patterns (state machine, components)
- Following existing naming conventions
- Adding to existing systems rather than creating parallel systems

**When Adding Features**:
1. Identify which system(s) it belongs to
2. Check for existing similar functionality
3. Extend base classes or create new components
4. Maintain separation of concerns
5. Use context dictionaries for state machine communication

### Common Pitfalls

1. **Don't bypass state machines** - All behavior should flow through states
2. **Don't tightly couple states to entities** - Use context dictionaries
3. **Don't create parallel implementations** - Extend existing systems
4. **Don't ignore virtual methods** - Override base class methods properly
5. **Don't forget @onready** - Node references need initialization timing

### Documentation Style

**In-Code Documentation**:
- Use `##` for doc comments (Godot standard)
- Document class purpose, not obvious details
- Explain "why" in comments, not "what"

**Example**:
```gdscript
## Manages equipped spells and spell slots
class_name SpellManager

## Discover all spell nodes attached to the caster
func _discover_spells() -> void:
    # Check for Spells container first
    # Fallback to searching all children if no container
```

---

## Quick Reference

### File Paths

| System | Path |
|--------|------|
| State Machine | `Systems/state_machine/state_machine.gd` |
| Movement Component | `Systems/Movement/movement_component.gd` |
| Player Controller | `Systems/Player/player_controller.gd` |
| AI System | `Systems/AI/ai_controller.gd` |
| Spell System | `Systems/Spells/spell_manager.gd` |
| Base Character | `mob_base.gd` |
| Enemy | `enemy.gd` |

### Key Classes

| Class | Purpose | Type |
|-------|---------|------|
| `MobBase` | Base for all characters | CharacterBody2D |
| `StateMachine` | Generic state machine | Node |
| `State` | Base state class | RefCounted |
| `MovementComponent` | Physics and movement | Node |
| `SpellManager` | Spell slot management | RefCounted |
| `SpellBase` | Base spell class | Node |
| `AIBehavior` | Base AI behavior | Resource |
| `AIController` | AI integration | Node |

### Input Actions

| Action | Key/Button | Purpose |
|--------|------------|---------|
| `ui_left` | A | Move left |
| `ui_right` | D | Move right |
| `ui_up` | W | Move up |
| `ui_down` | S | Move down |
| `cast_primary` | Left Mouse | Cast primary spell |
| `cast_secondary` | Right Mouse | Cast secondary spell |
| `dodge` | Spacebar | Dodge roll |

---

**End of CLAUDE.md**
