# systems/state_machine/states/movement/dodge_state.gd
class_name DodgeState
extends State


var mob: MobBase
var elapsed_time: float = 0.0
var dodge_direction: Vector2 = Vector2.ZERO


func _init(p_state_machine, p_mob: MobBase) -> void:
	super(p_state_machine)
	mob = p_mob


func enter() -> void:
	elapsed_time = 0.0
	
	var movement = mob.get_movement_component()
	dodge_direction = movement.get_last_direction()
	
	print("ENTERED DODGE STATE - direction: %s" % dodge_direction)


func update(_delta: float, _context: Dictionary) -> void:
	var movement = mob.get_movement_component()
	elapsed_time += _delta
	
	var progress = elapsed_time / movement.dodge_duration
	movement.dodge(dodge_direction, progress, _delta)


func exit() -> void:
	var movement = mob.get_movement_component()
	movement.stop()


func get_transition(_context: Dictionary) -> String:
	var movement = mob.get_movement_component()
	
	if elapsed_time >= movement.dodge_duration:
		return "Idle"
	
	return ""
