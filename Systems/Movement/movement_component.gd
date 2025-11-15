# systems/movement/movement_component.gd
extends Node
class_name MovementComponent

## Handles all movement physics - velocity, acceleration, dodge mechanics


@export_group("Movement Settings")
@export var move_speed: float = 200.0
@export var acceleration_rate: float = 3.0
@export var deceleration_rate: float = 4.0

@export_group("Dodge Settings")
@export var dodge_distance: float = 120.0
@export var dodge_duration: float = 0.3

@export_group("Movement Curves")
@export var acceleration_curve: Curve
@export var deceleration_curve: Curve
@export var dodge_curve: Curve

var character_body: CharacterBody2D

# Internal state
var current_speed_progress: float = 0.0
var last_move_direction: Vector2 = Vector2.RIGHT
var movement_modifier: float = 1.0


func _ready() -> void:
	# Get parent CharacterBody2D
	if get_parent() is CharacterBody2D:
		character_body = get_parent()
	else:
		push_error("MovementComponent must be child of CharacterBody2D")
	
	# Create default curves if not set
	if acceleration_curve == null:
		acceleration_curve = _create_default_acceleration_curve()
	if deceleration_curve == null:
		deceleration_curve = _create_default_deceleration_curve()
	if dodge_curve == null:
		dodge_curve = _create_default_dodge_curve()


## Apply movement in a direction with acceleration
func move_in_direction(direction: Vector2, delta: float) -> void:
	if direction.length() > 0.1:
		last_move_direction = direction.normalized()
		
		current_speed_progress = min(current_speed_progress + (delta * acceleration_rate), 1.0)
		var curve_value = acceleration_curve.sample(current_speed_progress)
		var effective_speed = move_speed * movement_modifier
		character_body.velocity = direction.normalized() * effective_speed * curve_value
	else:
		apply_friction(delta)
	
	character_body.move_and_slide()


## Apply friction to slow down
func apply_friction(delta: float) -> void:
	var friction = 2000.0
	character_body.velocity = character_body.velocity.move_toward(Vector2.ZERO, friction * delta)
	current_speed_progress = character_body.velocity.length() / move_speed
	character_body.move_and_slide()


## Execute a dodge dash
func dodge(direction: Vector2, progress: float, delta: float) -> void:
	var dodge_dir = direction if direction.length() > 0.1 else last_move_direction
	
	var start_pos = character_body.global_position
	var target_pos = start_pos + (dodge_dir.normalized() * dodge_distance)
	
	var curve_value = dodge_curve.sample(progress)
	var current_target = start_pos.lerp(target_pos, curve_value)
	
	character_body.velocity = (current_target - character_body.global_position) / delta
	character_body.move_and_slide()


## Stop all movement immediately
func stop() -> void:
	character_body.velocity = Vector2.ZERO
	current_speed_progress = 0.0


## Get last direction the character moved
func get_last_direction() -> Vector2:
	return last_move_direction


## Set movement speed multiplier (for spell effects)
func set_movement_modifier(modifier: float) -> void:
	movement_modifier = modifier


## Reset movement modifier to normal
func reset_movement_modifier() -> void:
	movement_modifier = 1.0


# Default curve creation
func _create_default_acceleration_curve() -> Curve:
	var curve = Curve.new()
	curve.add_point(Vector2(0.0, 0.0))
	curve.add_point(Vector2(1.0, 1.0))
	curve.set_point_left_tangent(0, 0.0)
	curve.set_point_right_tangent(0, 1.5)
	return curve


func _create_default_deceleration_curve() -> Curve:
	var curve = Curve.new()
	curve.add_point(Vector2(0.0, 0.0))
	curve.add_point(Vector2(1.0, 1.0))
	curve.set_point_left_tangent(1, 0.5)
	curve.set_point_right_tangent(1, 0.0)
	return curve


func _create_default_dodge_curve() -> Curve:
	var curve = Curve.new()
	curve.add_point(Vector2(0.0, 0.0))
	curve.add_point(Vector2(1.0, 1.0))
	curve.set_point_left_tangent(0, 0.0)
	curve.set_point_right_tangent(0, 2.0)
	curve.set_point_left_tangent(1, 0.5)
	curve.set_point_right_tangent(1, 0.0)
	return curve