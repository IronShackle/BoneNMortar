# spells/shadow_flame.gd
extends SpellBase

## Shoots a single projectile toward cursor


@export var projectile_scene: PackedScene


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
	
	# Configure projectile
	projectile.speed = 400.0
	projectile.lifetime = 3.0
	projectile.damage = 25.0
	projectile.direction = aim_direction
	projectile.global_position = spawn_pos
	projectile.set_collision_radius(8.0)
	
	# Spawn it into the world
	caster.get_tree().current_scene.add_child(projectile)
	
	print("Shadow Flame projectile spawned!")
