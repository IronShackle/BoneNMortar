extends Node
class_name HealthComponent

## Manages health, damage, healing, and damage-over-time effects for entities
## Designed to be attached as a child node to MobBase entities

## Signals
signal health_changed(old_value: float, new_value: float)
signal life_lost(amount: float, source: Node)
signal life_gained(amount: float)
signal died()

## Export variables
@export var max_health: float = 100.0
@export var start_at_max: bool = true
@export var dot_tick_rate: float = 1.0  ## How often DoT effects tick (in seconds)

## Current health value
var current_health: float = 0.0

## Internal DoT tracking
var _active_dots: Array[DotEffect] = []
var _dot_timer: float = 0.0

## Inner class for tracking individual DoT effects
class DotEffect:
	var damage_per_tick: float
	var remaining_duration: float
	var source: Node

	func _init(damage: float, duration: float, src: Node = null):
		damage_per_tick = damage
		remaining_duration = duration
		source = src


func _ready() -> void:
	if start_at_max:
		current_health = max_health
	_dot_timer = 0.0


func _process(delta: float) -> void:
	if _active_dots.is_empty():
		return

	_dot_timer += delta

	# Process DoT ticks based on tick rate
	if _dot_timer >= dot_tick_rate:
		_dot_timer -= dot_tick_rate
		_process_dot_tick()


## Process a single DoT tick for all active effects
func _process_dot_tick() -> void:
	var dots_to_remove: Array[int] = []

	for i in range(_active_dots.size()):
		var dot = _active_dots[i]

		# Apply DoT damage
		lose_life(dot.damage_per_tick, dot.source)

		# Reduce remaining duration
		dot.remaining_duration -= dot_tick_rate

		# Mark for removal if expired
		if dot.remaining_duration <= 0:
			dots_to_remove.append(i)

	# Remove expired DoTs (iterate backwards to maintain indices)
	for i in range(dots_to_remove.size() - 1, -1, -1):
		_active_dots.remove_at(dots_to_remove[i])


## Reduce health by the specified amount
func lose_life(amount: float, source: Node = null) -> void:
	# Can't lose life if already dead
	if current_health <= 0:
		return

	var old_health = current_health
	current_health = max(0.0, current_health - amount)

	# Emit signals
	life_lost.emit(amount, source)
	health_changed.emit(old_health, current_health)

	# Check for death
	if current_health <= 0:
		died.emit()


## Increase health by the specified amount
func gain_life(amount: float) -> void:
	# Can't gain life if dead
	if current_health <= 0:
		return

	var old_health = current_health
	current_health = min(max_health, current_health + amount)

	# Emit signals
	life_gained.emit(amount)
	health_changed.emit(old_health, current_health)


## Apply a damage-over-time effect
## Multiple DoTs stack (additive)
func apply_dot(damage_per_tick: float, duration: float, source: Node = null) -> void:
	var new_dot = DotEffect.new(damage_per_tick, duration, source)
	_active_dots.append(new_dot)


## Clear all DoT effects from a specific source
func clear_dots_from_source(source: Node) -> void:
	var dots_to_remove: Array[int] = []

	for i in range(_active_dots.size()):
		if _active_dots[i].source == source:
			dots_to_remove.append(i)

	# Remove in reverse order to maintain indices
	for i in range(dots_to_remove.size() - 1, -1, -1):
		_active_dots.remove_at(dots_to_remove[i])


## Clear all active DoT effects
func clear_all_dots() -> void:
	_active_dots.clear()


## Check if entity is alive
func is_alive() -> bool:
	return current_health > 0


## Get health as a percentage (0.0 to 1.0)
func get_health_percent() -> float:
	if max_health <= 0:
		return 0.0
	return clamp(current_health / max_health, 0.0, 1.0)
