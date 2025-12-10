# enemy_spawner.gd
extends Node2D


@export var enemy_scene: PackedScene
@export var max_enemies: int = 5
@export var spawn_radius: float = 50.0
@export var activation_range: float = 400.0
@export var respawn_delay: float = 30.0

var owned_enemies: Array[Node] = []
var respawn_timer: float = 0.0
var is_player_in_range: bool = false
var has_spawned_initial: bool = false


func _ready() -> void:
	# Don't spawn immediately, wait for player to get close
	pass


func _process(delta: float) -> void:
	_check_player_proximity()
	_update_respawn_timer(delta)


func _check_player_proximity() -> void:
	var player = get_tree().get_first_node_in_group("player")
	
	if not player:
		return
	
	var distance = global_position.distance_to(player.global_position)
	var was_in_range = is_player_in_range
	is_player_in_range = distance < activation_range
	
	# Player just entered range
	if is_player_in_range and not was_in_range:
		if not has_spawned_initial:
			_spawn_batch()
			has_spawned_initial = true
	
	# Player just left range
	if not is_player_in_range and was_in_range:
		respawn_timer = respawn_delay


func _update_respawn_timer(delta: float) -> void:
	if is_player_in_range:
		return
	
	if respawn_timer > 0.0:
		respawn_timer -= delta
		
		if respawn_timer <= 0.0:
			_check_and_replenish()


func _check_and_replenish() -> void:
	# Clean up dead enemy references
	owned_enemies = owned_enemies.filter(func(e): return is_instance_valid(e))
	
	# Spawn missing enemies
	var enemies_to_spawn = max_enemies - owned_enemies.size()
	
	if enemies_to_spawn > 0:
		_spawn_batch()


func _spawn_batch() -> void:
	# Clean up dead enemy references first
	owned_enemies = owned_enemies.filter(func(e): return is_instance_valid(e))
	
	var enemies_to_spawn = max_enemies - owned_enemies.size()
	
	for i in range(enemies_to_spawn):
		_spawn_single_enemy()


func _spawn_single_enemy() -> void:
	if enemy_scene == null:
		push_error("EnemySpawner has no enemy_scene assigned!")
		return
	
	var enemy = enemy_scene.instantiate()
	
	# Random position within spawn radius
	var random_angle = randf_range(0, TAU)
	var random_distance = randf_range(0, spawn_radius)
	var spawn_offset = Vector2(cos(random_angle), sin(random_angle)) * random_distance
	
	enemy.global_position = global_position + spawn_offset
	
	# Track this enemy
	owned_enemies.append(enemy)
	
	# Connect to death signal if available
	if enemy.has_signal("died"):
		enemy.died.connect(_on_enemy_died.bind(enemy))
	
	get_tree().current_scene.add_child(enemy)


func _on_enemy_died(enemy: Node) -> void:
	owned_enemies.erase(enemy)
	
	# Start respawn timer if player not in range
	if not is_player_in_range and respawn_timer <= 0.0:
		respawn_timer = respawn_delay