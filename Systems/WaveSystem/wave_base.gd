# Systems/WaveSystem/wave_base.gd
extends Node
class_name WaveBase

## Base class for wave definitions - extend this for each wave


signal wave_completed()

@export_group("Health")
@export var boss_health: float = 100.0

@export_group("Active Parts")
@export var activate_mask_a: bool = false
@export var activate_mask_b: bool = false
@export var activate_core: bool = false

@export_group("Mask A")
## Comma-separated behavior names (e.g., "HorizontalSweep,ShootAtPlayer")
@export var mask_a_behaviors_string: String = ""
## Comma-separated weights matching behaviors (e.g., "2,1") - leave empty for equal weights
@export var mask_a_weights_string: String = ""

@export_group("Mask B")
@export var mask_b_behaviors_string: String = ""
@export var mask_b_weights_string: String = ""

@export_group("Core")
@export var core_behaviors_string: String = ""
@export var core_weights_string: String = ""

var is_active: bool = false
var boss_root: Node2D
var wave_manager: Node


func start_wave(p_boss_root: Node2D, p_wave_manager: Node) -> void:
	boss_root = p_boss_root
	wave_manager = p_wave_manager
	is_active = true
	
	# Set boss health for this wave
	var health_pool = boss_root.get_node_or_null("BossHealthPool")
	if health_pool:
		health_pool.set_health(boss_health)
		health_pool.health_depleted.connect(_on_health_depleted)
	
	# Activate parts
	_activate_parts()
	
	# Start behaviors
	_start_behaviors()
	
	print("[Wave] Started: %s" % name)


func end_wave() -> void:
	is_active = false
	
	# Disconnect health signal
	var health_pool = boss_root.get_node_or_null("BossHealthPool")
	if health_pool and health_pool.health_depleted.is_connected(_on_health_depleted):
		health_pool.health_depleted.disconnect(_on_health_depleted)
	
	# Deactivate parts
	_deactivate_parts()
	
	# Stop behaviors
	_stop_behaviors()
	
	print("[Wave] Ended: %s" % name)


func _activate_parts() -> void:
	if activate_mask_a and boss_root.has_node("MaskA"):
		boss_root.get_node("MaskA").activate()
	if activate_mask_b and boss_root.has_node("MaskB"):
		boss_root.get_node("MaskB").activate()
	if activate_core and boss_root.has_node("Core"):
		boss_root.get_node("Core").activate()


func _deactivate_parts() -> void:
	if boss_root.has_node("MaskA"):
		boss_root.get_node("MaskA").deactivate()
	if boss_root.has_node("MaskB"):
		boss_root.get_node("MaskB").deactivate()
	if boss_root.has_node("Core"):
		boss_root.get_node("Core").deactivate()


func _start_behaviors() -> void:
	if activate_mask_a and boss_root.has_node("MaskA"):
		var behavior_manager = boss_root.get_node("MaskA").get_node_or_null("BehaviorManager")
		if behavior_manager:
			var behaviors = _parse_behaviors(mask_a_behaviors_string)
			var weights = _parse_weights(mask_a_weights_string, behaviors)
			behavior_manager.set_available_behaviors(behaviors, weights)
			behavior_manager.start()
	
	if activate_mask_b and boss_root.has_node("MaskB"):
		var behavior_manager = boss_root.get_node("MaskB").get_node_or_null("BehaviorManager")
		if behavior_manager:
			var behaviors = _parse_behaviors(mask_b_behaviors_string)
			var weights = _parse_weights(mask_b_weights_string, behaviors)
			behavior_manager.set_available_behaviors(behaviors, weights)
			behavior_manager.start()
	
	if activate_core and boss_root.has_node("Core"):
		var behavior_manager = boss_root.get_node("Core").get_node_or_null("BehaviorManager")
		if behavior_manager:
			var behaviors = _parse_behaviors(core_behaviors_string)
			var weights = _parse_weights(core_weights_string, behaviors)
			behavior_manager.set_available_behaviors(behaviors, weights)
			behavior_manager.start()


func _stop_behaviors() -> void:
	if boss_root.has_node("MaskA"):
		var behavior_manager = boss_root.get_node("MaskA").get_node_or_null("BehaviorManager")
		if behavior_manager:
			behavior_manager.stop()
	
	if boss_root.has_node("MaskB"):
		var behavior_manager = boss_root.get_node("MaskB").get_node_or_null("BehaviorManager")
		if behavior_manager:
			behavior_manager.stop()
	
	if boss_root.has_node("Core"):
		var behavior_manager = boss_root.get_node("Core").get_node_or_null("BehaviorManager")
		if behavior_manager:
			behavior_manager.stop()


func _parse_behaviors(behaviors_string: String) -> Array[String]:
	var result: Array[String] = []
	
	if behaviors_string.strip_edges().is_empty():
		return result
	
	var split = behaviors_string.split(",")
	for behavior in split:
		var trimmed = behavior.strip_edges()
		if not trimmed.is_empty():
			result.append(trimmed)
	
	return result


func _parse_weights(weights_string: String, behaviors: Array[String]) -> Dictionary:
	var result: Dictionary = {}
	
	if weights_string.strip_edges().is_empty():
		# Default all weights to 1
		for behavior in behaviors:
			result[behavior] = 1.0
		return result
	
	var split = weights_string.split(",")
	for i in range(behaviors.size()):
		if i < split.size():
			result[behaviors[i]] = float(split[i].strip_edges())
		else:
			result[behaviors[i]] = 1.0
	
	return result


func _on_health_depleted() -> void:
	wave_completed.emit()