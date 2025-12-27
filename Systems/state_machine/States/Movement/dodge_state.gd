# Systems/state_machine/States/Movement/dodge_state.gd
class_name DodgeState
extends State


var mob: MobBase
var elapsed_time: float = 0.0


func _init(p_state_machine, p_mob: MobBase) -> void:
	super(p_state_machine)
	mob = p_mob


func enter() -> void:
	elapsed_time = 0.0
	
	var movement = mob.get_movement_component()
	var input_dir = Vector2.ZERO
	
	if mob.has_method("get_movement_context"):
		var context = mob.get_movement_context(0.0)
		input_dir = context.get("input_direction", Vector2.ZERO)
	
	movement.start_dodge(input_dir)


func update(delta: float, _context: Dictionary) -> void:
	elapsed_time += delta


func exit() -> void:
	pass


func get_transition(_context: Dictionary) -> String:
	var movement = mob.get_movement_component()
	
	if elapsed_time >= movement.dodge_duration:
		return "Idle"
	
	return ""
