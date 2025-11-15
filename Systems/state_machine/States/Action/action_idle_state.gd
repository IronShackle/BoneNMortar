# systems/state_machine/states/action/action_idle_state.gd
class_name ActionIdleState
extends State


var mob: MobBase


func _init(p_state_machine, p_mob: MobBase) -> void:
	super(p_state_machine)
	mob = p_mob


func get_transition(context: Dictionary) -> String:
	if context.get("cast_primary", false):
		# Only players have spell manager
		if mob.has_method("get_spell_manager"):
			var spell_manager = mob.get_spell_manager()
			var spell = spell_manager.get_primary_spell()
			
			if spell and spell_manager.can_cast(spell):
				var casting_state = state_machine.states.get("Casting")
				if casting_state:
					casting_state.set_spell(spell)
					return "Casting"
	
	return ""
