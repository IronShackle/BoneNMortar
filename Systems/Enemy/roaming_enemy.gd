# Systems/AI/basic_enemy.gd
extends MobBase


enum AIState { IDLE, ROAMING, PAUSED }

@export_group("AI Behavior")
@export var detection_range: float = 300.0
@export var roam_speed_multiplier: float = 0.5  # Slower than full speed
@export var pause_duration_min: float = 0.5
@export var pause_duration_max: float = 1.5
@export var roam_duration_min: float = 0.8
@export var roam_duration_max: float = 2.0

@export_group("Drops")
@export var soul_pickup_scene: PackedScene

var ai_state: AIState = AIState.IDLE
var state_timer: float = 0.0
var current_direction: Vector2 = Vector2.ZERO


func _ready() -> void:
	super._ready()
	_enter_state(AIState.PAUSED)


func get_movement_context(_delta: float) -> Dictionary:
	_update_ai(_delta)
	
	var direction = Vector2.ZERO
	if ai_state == AIState.ROAMING:
		direction = current_direction
	
	return {"input_direction": direction}


func _update_ai(delta: float) -> void:
	state_timer -= delta
	
	var player = get_tree().get_first_node_in_group("player")
	var player_in_range = false
	
	if player:
		var distance = global_position.distance_to(player.global_position)
		player_in_range = distance < detection_range
	
	# If player not in range, stay idle
	if not player_in_range:
		if ai_state != AIState.IDLE:
			_enter_state(AIState.IDLE)
		return
	
	# Player is in range - cycle between roaming and pausing
	if state_timer <= 0:
		match ai_state:
			AIState.IDLE:
				_enter_state(AIState.ROAMING)
			AIState.ROAMING:
				_enter_state(AIState.PAUSED)
			AIState.PAUSED:
				_enter_state(AIState.ROAMING)


func _enter_state(new_state: AIState) -> void:
	ai_state = new_state
	
	match new_state:
		AIState.IDLE:
			current_direction = Vector2.ZERO
			state_timer = 0.0
		
		AIState.ROAMING:
			_pick_roam_direction()
			state_timer = randf_range(roam_duration_min, roam_duration_max)
		
		AIState.PAUSED:
			current_direction = Vector2.ZERO
			state_timer = randf_range(pause_duration_min, pause_duration_max)


func _pick_roam_direction() -> void:
	var player = get_tree().get_first_node_in_group("player")
	
	if not player:
		current_direction = Vector2.ZERO
		return
	
	# General direction toward player with some randomness
	var to_player = (player.global_position - global_position).normalized()
	var random_offset = Vector2(randf_range(-0.4, 0.4), randf_range(-0.4, 0.4))
	current_direction = (to_player + random_offset).normalized() * roam_speed_multiplier


func get_action_context(_delta: float) -> Dictionary:
	return {}


func _setup_movement_machine() -> void:
	var idle_state = IdleState.new(movement_machine, self)
	var run_state = RunState.new(movement_machine, self)
	
	movement_machine.add_state("Idle", idle_state)
	movement_machine.add_state("Run", run_state)
	
	movement_machine.set_initial_state("Idle")
	movement_machine.start()


func _setup_action_machine() -> void:
	var action_idle = ActionIdleState.new(action_machine, self)
	
	action_machine.add_state("ActionIdle", action_idle)
	
	action_machine.set_initial_state("ActionIdle")
	action_machine.start()


func _on_death() -> void:
	call_deferred("_spawn_soul_pickup")
	died.emit()
	queue_free()


func _spawn_soul_pickup() -> void:
	if soul_pickup_scene == null:
		return
	
	var pickup = soul_pickup_scene.instantiate()
	pickup.global_position = global_position
	get_tree().current_scene.add_child(pickup)