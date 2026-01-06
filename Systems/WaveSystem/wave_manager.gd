# Systems/WaveSystem/wave_manager.gd
extends Node
class_name WaveManager

## Manages wave progression and intermissions


signal wave_started(wave_number: int)
signal wave_ended(wave_number: int)
signal all_waves_completed()
signal intermission_started()

@export var boss_root: Node2D
@export var intermission_trigger_scene: PackedScene  ## Scene to spawn between waves
@export var intermission_spawn_position: Vector2 = Vector2.ZERO

var current_wave_index: int = -1
var waves: Array[WaveBase] = []
var current_wave: WaveBase = null
var is_in_intermission: bool = false
var intermission_trigger: Node = null


func _ready() -> void:
	# Discover wave nodes
	for child in get_children():
		if child is WaveBase:
			waves.append(child)
	
	print("[WaveManager] Discovered %d waves" % waves.size())


## Start the first wave (call this to begin the encounter)
func start_encounter() -> void:
	current_wave_index = -1
	start_next_wave()


## Start the next wave in sequence
func start_next_wave() -> void:
	current_wave_index += 1
	
	if current_wave_index >= waves.size():
		all_waves_completed.emit()
		print("[WaveManager] All waves completed!")
		return
	
	is_in_intermission = false
	current_wave = waves[current_wave_index]
	current_wave.wave_completed.connect(_on_wave_completed, CONNECT_ONE_SHOT)
	current_wave.start_wave(boss_root, self)
	
	wave_started.emit(current_wave_index + 1)


## Called when current wave's health is depleted
func _on_wave_completed() -> void:
	var completed_index = current_wave_index
	current_wave.end_wave()
	current_wave = null
	
	wave_ended.emit(completed_index + 1)
	
	# Start intermission
	_start_intermission()


## Spawn intermission trigger for player to interact with
func _start_intermission() -> void:
	is_in_intermission = true
	intermission_started.emit()
	
	if intermission_trigger_scene:
		intermission_trigger = intermission_trigger_scene.instantiate()
		intermission_trigger.global_position = intermission_spawn_position
		
		# Connect to interaction
		if intermission_trigger.has_signal("interacted"):
			intermission_trigger.interacted.connect(_on_intermission_trigger_interacted)
		elif intermission_trigger is Interactable:
			# Hook into existing interact system
			pass
		
		get_tree().current_scene.add_child(intermission_trigger)
		print("[WaveManager] Intermission started - waiting for player")
	else:
		# No trigger scene, just start next wave immediately
		start_next_wave()


## Called when player interacts with intermission trigger
func _on_intermission_trigger_interacted() -> void:
	if intermission_trigger:
		intermission_trigger.queue_free()
		intermission_trigger = null
	
	start_next_wave()


## Get current wave number (1-indexed for display)
func get_current_wave_number() -> int:
	return current_wave_index + 1


## Get total wave count
func get_total_waves() -> int:
	return waves.size()