# Systems/Enemy/melee_flail_enemy.gd - CORRECTED VERSION
extends MobBase
class_name MeleeFlailEnemy

enum AIState { IDLE, ROAMING, CHASING, ATTACKING, COOLDOWN }

@export_group("AI Behavior")
@export var detection_range: float = 300.0
@export var attack_range: float = 80.0
@export var attack_cooldown: float = 3.0
@export var roam_speed_multiplier: float = 0.5

@export_group("Attack Selection")
@export var attack_weights: Dictionary = {
	"QuickSlash": 70,
	"FlailCharge": 30
}

@export_group("Roaming Behavior")
@export var pause_duration_min: float = 0.5
@export var pause_duration_max: float = 1.5
@export var roam_duration_min: float = 0.8
@export var roam_duration_max: float = 2.0

@export_group("Drops")
@export var soul_pickup_scene: PackedScene

var ai_state: AIState = AIState.IDLE
var state_timer: float = 0.0
var current_direction: Vector2 = Vector2.ZERO
var cooldown_timer: float = 0.0

var current_attack: AbilityBase = null
var available_abilities: Dictionary = {}


func _ready() -> void:
	super._ready()
	_discover_abilities()
	_enter_state(AIState.IDLE)


func _discover_abilities() -> void:
	if has_node("Abilities"):
		for child in $Abilities.get_children():
			if child is AbilityBase:
				child.set_caster(self)
				available_abilities[child.name] = child
				print("[MeleeEnemy] Discovered ability: %s" % child.name)


func get_movement_context(_delta: float) -> Dictionary:
	_update_ai(_delta)
	
	var direction = Vector2.ZERO
	
	match ai_state:
		AIState.ROAMING:
			direction = current_direction
		AIState.CHASING:
			direction = _get_chase_direction()
	
	return {"input_direction": direction}


func get_action_context(_delta: float) -> Dictionary:
	return {
		"execute_ability": ai_state == AIState.ATTACKING
	}


func _update_ai(delta: float) -> void:
	state_timer -= delta
	cooldown_timer -= delta
	
	# Update current ability if executing
	if current_attack and current_attack.is_executing:
		current_attack.update(delta)
	
	var player = get_tree().get_first_node_in_group("player")
	var player_in_range = false
	var player_distance = INF
	
	if player:
		player_distance = global_position.distance_to(player.global_position)
		player_in_range = player_distance < detection_range
	
	match ai_state:
		AIState.IDLE:
			if player_in_range:
				_enter_state(AIState.CHASING)
			elif state_timer <= 0:
				_enter_state(AIState.ROAMING)
		
		AIState.ROAMING:
			if player_in_range:
				_enter_state(AIState.CHASING)
			elif state_timer <= 0:
				_enter_state(AIState.IDLE)
		
		AIState.CHASING:
			if not player_in_range:
				_enter_state(AIState.IDLE)
			# Check BOTH range AND cooldown before attacking
			elif player_distance < attack_range and cooldown_timer <= 0:
				_enter_state(AIState.ATTACKING)
		
		AIState.ATTACKING:
			# Attack executes automatically, wait for completion
			if current_attack and not current_attack.is_executing:
				# Go straight back to CHASING (or IDLE if player left)
				if player_in_range:
					_enter_state(AIState.CHASING)
				else:
					_enter_state(AIState.IDLE)


func _enter_state(new_state: AIState) -> void:
	ai_state = new_state
	
	match new_state:
		AIState.IDLE:
			current_direction = Vector2.ZERO
			state_timer = randf_range(pause_duration_min, pause_duration_max)
		
		AIState.ROAMING:
			_pick_roam_direction()
			state_timer = randf_range(roam_duration_min, roam_duration_max)
		
		AIState.CHASING:
			current_direction = Vector2.ZERO
			# Don't reset anything - just start chasing
		
		AIState.ATTACKING:
			current_direction = Vector2.ZERO
			var attack_name = _choose_attack()
			current_attack = available_abilities.get(attack_name)
			
			if current_attack:
				current_attack.execute()
				# Start cooldown immediately when attack begins
				cooldown_timer = attack_cooldown
				print("[MeleeEnemy] Executing: %s (cooldown started)" % attack_name)
			else:
				print("[MeleeEnemy] ERROR: Attack '%s' not found!" % attack_name)
				_enter_state(AIState.CHASING)


func _choose_attack() -> String:
	var total_weight = 0
	for weight in attack_weights.values():
		total_weight += weight
	
	var roll = randf() * total_weight
	var current_weight = 0
	
	for attack_name in attack_weights.keys():
		current_weight += attack_weights[attack_name]
		if roll <= current_weight:
			return attack_name
	
	return "QuickSlash"  # Fallback


func _pick_roam_direction() -> void:
	var player = get_tree().get_first_node_in_group("player")
	
	if not player:
		current_direction = Vector2.ZERO
		return
	
	var to_player = (player.global_position - global_position).normalized()
	var random_offset = Vector2(randf_range(-0.4, 0.4), randf_range(-0.4, 0.4))
	current_direction = (to_player + random_offset).normalized() * roam_speed_multiplier


func _get_chase_direction() -> Vector2:
	var player = get_tree().get_first_node_in_group("player")
	
	if not player:
		return Vector2.ZERO
	
	return (player.global_position - global_position).normalized()


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


func has_mana(_cost: float) -> bool:
	return true


func consume_mana(_cost: float) -> void:
	pass


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