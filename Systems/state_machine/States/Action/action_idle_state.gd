# Systems/state_machine/States/Action/action_idle_state.gd
class_name ActionIdleState
extends State


var mob: MobBase


func _init(p_state_machine, p_mob: MobBase) -> void:
	super(p_state_machine)
	mob = p_mob


func get_transition(context: Dictionary) -> String:

	if context.get("parry_pressed", false):
		return "Parrying"

	# Check for attack input
	if context.get("attack_pressed", false):
		if mob.has_method("get_combo_manager"):
			var combo_manager = mob.get_combo_manager()
			
			if combo_manager and combo_manager.try_attack():
				return "Attacking"
	
	# Check for ability execution (used by enemies)
	if context.get("execute_ability", false):
		if mob.has_method("get_ability_manager"):
			var ability_manager = mob.get_ability_manager()
			var ability = ability_manager.get_primary_ability()
			
			if ability:
				return "ExecutingAbility"
	
	# Legacy ability casting support (player spells)
	if context.get("cast_primary", false):
		if mob.has_method("get_ability_manager"):
			var ability_manager = mob.get_ability_manager()
			var ability = ability_manager.get_primary_ability()
			
			if ability and ability_manager.can_cast(ability):
				var casting_state = state_machine.states.get("Casting")
				if casting_state:
					casting_state.set_ability(ability)
					return "Casting"
	
	return ""
