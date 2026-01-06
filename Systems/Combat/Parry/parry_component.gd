# Systems/Combat/Parry/parry_component.gd
extends Node
class_name ParryComponent

## Manages deflect mechanics - reflects projectiles while held


signal deflect_started()
signal deflect_ended()
signal projectile_deflected()

@export var parry_zone: Area2D  ## Reference to the deflect detection zone
@export var visual_indicator: Node2D  ## Visual feedback node
@export var movement_speed_multiplier: float = 0.5  ## Movement speed while deflecting (1.0 = full speed)

var is_deflecting: bool = false
var player: Node2D
var reflected_projectiles: Array[int] = []  ## Track reflected projectiles by instance ID
var stored_max_speed: float = 0.0  ## Store original max_speed


func _ready() -> void:
	player = get_parent()
	
	if not parry_zone:
		parry_zone = player.get_node_or_null("ParryZone")
		if not parry_zone:
			push_error("ParryComponent: No ParryZone found!")
	
	# Hide visual initially
	if visual_indicator:
		visual_indicator.visible = false


func _process(_delta: float) -> void:
	if is_deflecting:
		_check_and_reflect_projectiles()


## Start deflecting
func start_deflect() -> void:
	if is_deflecting:
		return
	
	is_deflecting = true
	reflected_projectiles.clear()
	
	# Reduce movement speed
	var movement = player.get_node_or_null("MovementComponent") as MovementComponent
	if movement:
		stored_max_speed = movement.max_speed
		movement.max_speed = stored_max_speed * movement_speed_multiplier
	
	if visual_indicator:
		visual_indicator.visible = true
	
	deflect_started.emit()
	print("[Deflect] Started")


## Stop deflecting
func end_deflect() -> void:
	if not is_deflecting:
		return
	
	is_deflecting = false
	reflected_projectiles.clear()
	
	# Restore movement speed
	var movement = player.get_node_or_null("MovementComponent") as MovementComponent
	if movement and stored_max_speed > 0.0:
		movement.max_speed = stored_max_speed
	
	if visual_indicator:
		visual_indicator.visible = false
	
	deflect_ended.emit()
	print("[Deflect] Ended")


## Check parry zone for projectiles and reflect them
func _check_and_reflect_projectiles() -> void:
	if not parry_zone:
		return
	
	var overlapping_areas = parry_zone.get_overlapping_areas()
	
	for area in overlapping_areas:
		if area is Hitbox:
			var projectile = area.get_parent()
			if projectile is Projectile:
				var projectile_id = projectile.get_instance_id()
				
				# Only reflect each projectile once
				if not reflected_projectiles.has(projectile_id):
					_reflect_projectile(projectile)
					reflected_projectiles.append(projectile_id)
					projectile_deflected.emit()


## Reflect a single projectile toward mouse
func _reflect_projectile(projectile: Projectile) -> void:
	var mouse_pos = player.get_global_mouse_position()
	var new_direction = (mouse_pos - projectile.global_position).normalized()
	
	projectile.direction = new_direction
	
	if projectile.has_node("Hitbox"):
		var hitbox = projectile.get_node("Hitbox") as Hitbox
		if hitbox:
			hitbox.team = "player"
	
	print("[Deflect] Reflected projectile!")


## Query if currently deflecting
func is_deflect_active() -> bool:
	return is_deflecting