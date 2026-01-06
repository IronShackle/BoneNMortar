# Systems/Enemy/static_shooter.gd
extends MobBase
class_name StaticShooter

## Stationary enemy that shoots projectiles at intervals


@export_group("Shooting")
@export var projectile_scene: PackedScene
@export var shoot_interval: float = 2.0  ## Time between shots
@export var aim_at_player: bool = true  ## If true, aim at player. If false, use shoot_direction
@export var shoot_direction: Vector2 = Vector2.RIGHT  ## Direction to shoot (if aim_at_player is false)
@export var projectile_speed: float = 200.0
@export var projectile_damage: float = 10.0
@export var projectile_lifetime: float = 5.0

var shoot_timer: float = 0.0


func _ready() -> void:
	super._ready()
	shoot_timer = shoot_interval  # Shoot immediately on spawn


func _process(delta: float) -> void:
	shoot_timer -= delta
	
	if shoot_timer <= 0.0:
		_shoot_projectile()
		shoot_timer = shoot_interval


func _shoot_projectile() -> void:
	if projectile_scene == null:
		push_error("StaticShooter: No projectile_scene assigned!")
		return
	
	var projectile = projectile_scene.instantiate()
	
	# Determine shoot direction
	var direction = shoot_direction
	if aim_at_player:
		direction = _get_direction_to_player()
	
	# Configure projectile
	projectile.speed = projectile_speed
	projectile.lifetime = projectile_lifetime
	projectile.direction = direction.normalized()
	projectile.global_position = global_position
	
	# Configure hitbox
	if projectile.has_node("Hitbox"):
		var hitbox = projectile.get_node("Hitbox") as Hitbox
		if hitbox:
			hitbox.team = "enemy"
			hitbox.damage = projectile_damage
	
	# Spawn into world
	get_tree().current_scene.add_child(projectile)
	
	print("[StaticShooter] Fired projectile")


func _get_direction_to_player() -> Vector2:
	var player = get_tree().get_first_node_in_group("player")
	
	if not player:
		return shoot_direction  # Fallback if no player found
	
	return (player.global_position - global_position).normalized()


func get_movement_context(_delta: float) -> Dictionary:
	return {"input_direction": Vector2.ZERO}


func get_action_context(_delta: float) -> Dictionary:
	return {}


func _setup_movement_machine() -> void:
	var idle_state = IdleState.new(movement_machine, self)
	
	movement_machine.add_state("Idle", idle_state)
	movement_machine.set_initial_state("Idle")
	movement_machine.start()


func _setup_action_machine() -> void:
	var action_idle = ActionIdleState.new(action_machine, self)
	
	action_machine.add_state("ActionIdle", action_idle)
	action_machine.set_initial_state("ActionIdle")
	action_machine.start()
