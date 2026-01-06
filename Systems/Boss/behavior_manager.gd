# Systems/Boss/behavior_manager.gd
extends Node
class_name BehaviorManager

## Manages and cycles through behaviors on a boss part


signal behavior_started(behavior_name: String)
signal behavior_ended(behavior_name: String)

@export var default_behavior_duration: float = 5.0  ## Fallback if behavior doesn't specify

var available_behaviors: Array[String] = []
var behavior_weights: Dictionary = {}
var current_behavior: Node = null
var is_running: bool = false


func set_available_behaviors(behaviors: Array[String], weights: Dictionary = {}) -> void:
	available_behaviors = behaviors
	behavior_weights = weights


func start() -> void:
	if is_running:
		return
	
	is_running = true
	_pick_next_behavior()


func stop() -> void:
	is_running = false
	
	if current_behavior and current_behavior.has_method("end_behavior"):
		current_behavior.end_behavior()
	
	current_behavior = null


func _pick_next_behavior() -> void:
	if not is_running or available_behaviors.is_empty():
		return
	
	var behavior_name = _weighted_random_pick()
	var behavior_node = get_node_or_null(behavior_name)
	
	if not behavior_node:
		push_error("[BehaviorManager] Behavior node '%s' not found!" % behavior_name)
		return
	
	current_behavior = behavior_node
	
	if current_behavior.has_signal("behavior_completed"):
		current_behavior.behavior_completed.connect(_on_behavior_completed, CONNECT_ONE_SHOT)
	
	if current_behavior.has_method("start_behavior"):
		current_behavior.start_behavior()
	
	behavior_started.emit(behavior_name)
	print("[BehaviorManager] Started behavior: %s" % behavior_name)


func _weighted_random_pick() -> String:
	if available_behaviors.size() == 1:
		return available_behaviors[0]
	
	# Calculate total weight
	var total_weight = 0.0
	for behavior_name in available_behaviors:
		total_weight += behavior_weights.get(behavior_name, 1.0)
	
	# Pick random weighted
	var roll = randf() * total_weight
	var current_weight = 0.0
	
	for behavior_name in available_behaviors:
		current_weight += behavior_weights.get(behavior_name, 1.0)
		if roll <= current_weight:
			return behavior_name
	
	return available_behaviors[0]


func _on_behavior_completed() -> void:
	var old_behavior = current_behavior.name if current_behavior else "None"
	behavior_ended.emit(old_behavior)
	current_behavior = null
	
	# Pick next behavior
	_pick_next_behavior()