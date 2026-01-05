# Systems/state_machine/States/Action/executing_ability_state.gd
class_name ExecutingAbilityState
extends State

## State for executing abilities (used by enemies)
## Executes ability and waits for completion signal


var mob: MobBase
var current_ability: AbilityBase = null
var has_executed: bool = false
var ability_complete: bool = false


func _init(p_state_machine, p_mob: MobBase) -> void:
	super(p_state_machine)
	mob = p_mob


func enter() -> void:
	has_executed = false
	ability_complete = false
	
	# Get the ability from ability manager
	if mob.has_method("get_ability_manager"):
		var ability_manager = mob.get_ability_manager()
		current_ability = ability_manager.get_primary_ability()
		
		if current_ability:
			# Connect to completion signal
			current_ability.ability_completed.connect(_on_ability_completed)
			print("[ExecutingAbility] Starting: %s" % current_ability.ability_name)
		else:
			push_error("ExecutingAbilityState entered but no primary ability!")


func update(_delta: float, _context: Dictionary) -> void:
	# Execute ability once on first update
	if not has_executed and current_ability:
		current_ability.execute()
		has_executed = true


func exit() -> void:
	# Disconnect signal
	if current_ability and current_ability.ability_completed.is_connected(_on_ability_completed):
		current_ability.ability_completed.disconnect(_on_ability_completed)
	
	current_ability = null
	has_executed = false
	ability_complete = false


func get_transition(_context: Dictionary) -> String:
	if ability_complete:
		return "ActionIdle"
	
	return ""


func _on_ability_completed() -> void:
	ability_complete = true
	print("[ExecutingAbility] Ability completed!")