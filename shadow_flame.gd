# spells/shadow_flame.gd
extends SpellBase

## Shoots a single projectile toward cursor


@export var projectile_scene: PackedScene
@export var projectile_damage: float = 25.0
@export var projectile_speed: float = 400.0
@export var projectile_lifetime: float = 3.0
@export var projectile_radius: float = 8.0
@export var projectile_max_hits: int = 1


func _init() -> void:
	spell_name = "Shadow Flame"
	mana_cost = 15.0
	cast_time = 0.1
	movement_modifier = 1.0
	can_dodge_cancel = true


func execute() -> void:
	if caster == null:
		push_error("Shadow Flame executed without caster!")
		return

	if projectile_scene == null:
		push_error("Shadow Flame has no projectile scene assigned!")
		return

	# Get aim direction
	var mouse_pos = caster.get_global_mouse_position()
	var spawn_pos = caster.global_position
	var aim_direction = (mouse_pos - spawn_pos).normalized()

	# Create projectile instance
	var projectile = projectile_scene.instantiate()

	# Configure projectile movement
	projectile.speed = projectile_speed
	projectile.lifetime = projectile_lifetime
	projectile.direction = aim_direction
	projectile.global_position = spawn_pos

	# Configure projectile max hits
	projectile.max_hits = projectile_max_hits
	
	# Get hitbox
	var hitbox = projectile.get_node("Hitbox") as Hitbox

	if hitbox == null:
		push_error("Projectile is missing Hitbox child node!")
		projectile.queue_free()
		return

	# Configure hitbox data
	hitbox.team = "player"
	hitbox.damage = projectile_damage
	hitbox.set_circle_shape(projectile_radius)

	# Spawn it into the world
	caster.get_tree().current_scene.add_child(projectile)
