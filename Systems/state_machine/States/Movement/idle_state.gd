# systems/state_machine/states/movement/idle_state.gd
class_name IdleState
extends State


var mob: MobBase


func _init(p_state_machine, p_mob: MobBase) -> void:
	super(p_state_machine)
	mob = p_mob

	


func update(_delta: float, _context: Dictionary) -> void:
	var movement = mob.get_movement_component()
	movement.apply_friction(_delta)


func get_transition(_context: Dictionary) -> String:
	var input_dir = _context.get("input_direction", Vector2.ZERO)
	
	if _context.get("dodge_pressed", false):
		return "Dodge"
	
	if input_dir.length() > 0.1:
		return "Run"
	
	return ""