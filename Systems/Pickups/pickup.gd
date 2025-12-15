# pickup.gd
extends Area2D
class_name Pickup

## Base class for collectible pickups that float toward the player


@export var magnetic_range: float = 100.0
@export var magnetic_speed: float = 300.0

var is_magnetic: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	if is_magnetic:
		_move_toward_player(delta)
	else:
		_check_magnetic_activation()


func _check_magnetic_activation() -> void:
	var player = get_tree().get_first_node_in_group("player")
	
	if not player:
		return
	
	var distance = global_position.distance_to(player.global_position)
	
	if distance < magnetic_range:
		is_magnetic = true


func _move_toward_player(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	
	if not player:
		return
	
	var direction = (player.global_position - global_position).normalized()
	global_position += direction * magnetic_speed * delta


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_on_collected(body)


## Virtual method - override in subclasses
func _on_collected(_player: Node2D) -> void:
	pass