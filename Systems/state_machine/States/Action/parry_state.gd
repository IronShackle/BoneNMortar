# Systems/state_machine/States/Action/parry_state.gd
class_name ParryState
extends State

## Action state for deflecting - active while button held


var mob: MobBase
var parry_component: ParryComponent


func _init(p_state_machine, p_mob: MobBase) -> void:
	super(p_state_machine)
	mob = p_mob


func enter() -> void:
	parry_component = mob.get_node_or_null("ParryComponent")
	if not parry_component:
		push_error("ParryState: Player missing ParryComponent!")
		return
	
	parry_component.start_deflect()


func update(_delta: float, _context: Dictionary) -> void:
	pass


func exit() -> void:
	if parry_component:
		parry_component.end_deflect()


func get_transition(context: Dictionary) -> String:
	# Exit when button released
	if not context.get("parry_held", false):
		return "ActionIdle"
	
	return ""