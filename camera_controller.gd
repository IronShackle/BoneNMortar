# camera_controller.gd
extends Camera2D


@export var follow_speed: float = 8.0
@export var target_group: String = "player"
@export var fixed_mode: bool = false  ## If true, camera will not follow target and will stay fixed at initial position

var target: Node2D


func _ready() -> void:
	target = get_tree().get_first_node_in_group(target_group)
	
	if target:
		global_position = target.global_position
		if fixed_mode:
			target = null  # Disable following if fixed mode is enabled
	else:
		push_error("CameraController: No target found in group '%s'!" % target_group)


func _physics_process(delta: float) -> void:  # Changed from _process
	if not target:
		return
	
	global_position = global_position.lerp(target.global_position, follow_speed * delta) 