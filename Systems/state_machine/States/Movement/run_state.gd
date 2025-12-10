# systems/state_machine/states/movement/run_state.gd
class_name RunState
extends State


var mob: MobBase


func _init(p_state_machine, p_mob: MobBase) -> void:
	super(p_state_machine)
	mob = p_mob




func update(delta: float, context: Dictionary) -> void:
	var input_dir = context.get("input_direction", Vector2.ZERO)
	var movement = mob.get_movement_component()
	
	if input_dir.length() > 0.1:
		movement.move_in_direction(input_dir, delta)
	else:
		movement.apply_friction(delta)


func get_transition(context: Dictionary) -> String:
	var input_dir = context.get("input_direction", Vector2.ZERO)
	
	if context.get("dodge_pressed", false):
		return "Dodge"
	
	if input_dir.length() < 0.1:
		return "Idle"
	
	return ""