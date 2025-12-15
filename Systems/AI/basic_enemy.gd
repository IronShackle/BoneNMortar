# enemy.gd
extends MobBase


enum AIState { ROAMING, CHASING, RETURNING }

@export var chase_range: float = 200.0
@export var disengage_range: float = 400.0
@export var roam_radius: float = 100.0
@export var soul_pickup_scene: PackedScene  # Assign SoulPickup scene here

var spawn_position: Vector2
var ai_state: AIState = AIState.ROAMING

var roam_timer: float = 0.0
var roam_wait_time: float = 2.0
var roam_direction: Vector2 = Vector2.ZERO


func _ready() -> void:
	super._ready()
	spawn_position = global_position


func get_movement_context(_delta: float) -> Dictionary:
	_update_ai_state()
	_update_roaming(_delta)
	
	match ai_state:
		AIState.ROAMING:
			return {"input_direction": roam_direction}
		AIState.CHASING:
			return {"input_direction": _get_chase_direction()}
		AIState.RETURNING:
			return {"input_direction": _get_return_direction()}
	
	return {"input_direction": Vector2.ZERO}


func _update_ai_state() -> void:
	var player = get_tree().get_first_node_in_group("player")
	
	if not player:
		return
	
	var to_player = global_position.distance_to(player.global_position)
	var from_spawn = global_position.distance_to(spawn_position)
	
	match ai_state:
		AIState.ROAMING:
			if to_player < chase_range:
				ai_state = AIState.CHASING
		
		AIState.CHASING:
			if to_player > disengage_range:
				ai_state = AIState.RETURNING
		
		AIState.RETURNING:
			if from_spawn < 10.0:
				ai_state = AIState.ROAMING


func _update_roaming(delta: float) -> void:
	if ai_state != AIState.ROAMING:
		return
	
	var from_spawn = global_position.distance_to(spawn_position)
	
	if from_spawn > roam_radius:
		roam_direction = (spawn_position - global_position).normalized()
		return
	
	roam_timer -= delta
	
	if roam_timer <= 0.0:
		roam_timer = roam_wait_time
		
		if randf() > 0.5:
			roam_direction = Vector2.ZERO
		else:
			var random_angle = randf_range(0, TAU)
			roam_direction = Vector2(cos(random_angle), sin(random_angle))


func _get_chase_direction() -> Vector2:
	var player = get_tree().get_first_node_in_group("player")
	
	if not player:
		return Vector2.ZERO
	
	return (player.global_position - global_position).normalized()


func _get_return_direction() -> Vector2:
	return (spawn_position - global_position).normalized()


func get_action_context(_delta: float) -> Dictionary:
	return {}


func _setup_movement_machine() -> void:
	var idle_state = IdleState.new(movement_machine, self)
	var run_state = RunState.new(movement_machine, self)
	
	movement_machine.add_state("Idle", idle_state)
	movement_machine.add_state("Run", run_state)
	
	movement_machine.set_initial_state("Run")
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