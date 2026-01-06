# Systems/Boss/Behaviors/horizontal_sweep.gd
extends BehaviorBase
class_name HorizontalSweepBehavior

## Moves the boss part left and right


@export var sweep_distance: float = 200.0  ## Distance from center to each side
@export var sweep_speed: float = 100.0
@export var center_position: Vector2 = Vector2.ZERO

var direction: int = 1  ## 1 = right, -1 = left
var start_x: float = 0.0


func _on_start() -> void:
	if center_position == Vector2.ZERO and boss_part:
		center_position = boss_part.start_position
	
	start_x = center_position.x


func _on_update(delta: float) -> void:
	if not boss_part:
		return
	
	# Move horizontally
	boss_part.global_position.x += sweep_speed * direction * delta
	
	# Check bounds and reverse
	if boss_part.global_position.x >= start_x + sweep_distance:
		direction = -1
	elif boss_part.global_position.x <= start_x - sweep_distance:
		direction = 1


func _on_end() -> void:
	direction = 1