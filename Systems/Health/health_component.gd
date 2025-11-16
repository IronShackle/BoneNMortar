# Systems/Health/health_component.gd
class_name HealthComponent
extends Node

## Handles health, damage, healing, and damage-over-time effects


signal health_changed(old_value: float, new_value: float)
signal life_lost(amount: float, source: Node)
signal life_gained(amount: float)
signal died()


@export_group("Health Settings")
@export var max_health: float = 100.0
@export var start_at_max: bool = true

@export_group("Damage Over Time Settings")
@export var dot_tick_rate: float = 1.0

var current_health: float
var active_dots: Array[DotEffect] = []
var dot_timer: float = 0.0


func _ready() -> void:
	if start_at_max:
		current_health = max_health


func _process(delta: float) -> void:
	if active_dots.is_empty():
		return
	
	dot_timer += delta
	
	while dot_timer >= dot_tick_rate:
		dot_timer -= dot_tick_rate
		_process_dot_tick()


func lose_life(amount: float, source: Node = null) -> void:
	if current_health <= 0:
		return
	
	var old_health = current_health
	current_health = max(0, current_health - amount)
	
	if old_health != current_health:
		health_changed.emit(old_health, current_health)
		life_lost.emit(amount, source)
	
	if current_health <= 0:
		died.emit()


func gain_life(amount: float) -> void:
	if current_health <= 0:
		return
	
	var old_health = current_health
	current_health = min(max_health, current_health + amount)
	
	if old_health != current_health:
		health_changed.emit(old_health, current_health)
		life_gained.emit(amount)


func apply_dot(damage_per_tick: float, duration: float, source: Node = null, dot_type: String = "generic") -> void:
    var dot = DotEffect.new()
    dot.damage_per_tick = damage_per_tick
    dot.remaining_duration = duration
    dot.source = source
    dot.type = dot_type
    active_dots.append(dot)


func clear_dots_from_source(source: Node) -> void:
	active_dots = active_dots.filter(func(dot): return dot.source != source)


func clear_all_dots() -> void:
	active_dots.clear()


func is_alive() -> bool:
	return current_health > 0


func get_health_percent() -> float:
	return current_health / max_health if max_health > 0 else 0.0


func _process_dot_tick() -> void:
	for dot in active_dots:
		lose_life(dot.damage_per_tick, dot.source)
		dot.remaining_duration -= dot_tick_rate
		
		# Stop processing if we died
		if not is_alive():
			break
	
	# Remove expired dots
	active_dots = active_dots.filter(func(dot): return dot.remaining_duration > 0)


## Inner class for DoT tracking
class DotEffect:
	var damage_per_tick: float
	var remaining_duration: float
	var source: Node
	var type: String = "generic"