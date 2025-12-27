# Systems/state_machine/States/Action/action_idle_state.gd
class_name ActionIdleState
extends State


var mob: MobBase


func _init(p_state_machine, p_mob: MobBase) -> void:
	super(p_state_machine)
	mob = p_mob


func get_transition(context: Dictionary) -> String:
	# Check for attack input
	if context.get("attack_pressed", false):
		if mob.has_method("get_combo_manager"):
			var combo_manager = mob.get_combo_manager()
			
			if combo_manager and combo_manager.try_attack():
				return "Attacking"
	
	# Legacy spell casting support
	if context.get("cast_primary", false):
		if mob.has_method("get_spell_manager"):
			var spell_manager = mob.get_spell_manager()
			var spell = spell_manager.get_primary_spell()
			
			if spell and spell_manager.can_cast(spell):
				var casting_state = state_machine.states.get("Casting")
				if casting_state:
					casting_state.set_spell(spell)
					return "Casting"
	
	return ""