# Systems/state_machine/States/Action/attacking_state.gd
class_name ActionAttackingState
extends State

## State for active melee attacks


var mob: MobBase
var combo_manager: ComboManager


func _init(p_state_machine, p_mob: MobBase) -> void:
	super(p_state_machine)
	mob = p_mob


func enter() -> void:
	if mob.has_method("get_combo_manager"):
		combo_manager = mob.get_combo_manager()
	
	# Lock movement if attack requires it
	if combo_manager and combo_manager.is_movement_locked():
		var movement = mob.get_movement_component()
		movement.set_movement_modifier(0.0)


func update(_delta: float, context: Dictionary) -> void:
	# Buffer attack input
	if context.get("attack_pressed", false):
		if combo_manager:
			combo_manager.try_attack()  # Will buffer if attacking


func exit() -> void:
	# Restore movement
	var movement = mob.get_movement_component()
	movement.reset_movement_modifier()
	combo_manager = null


func get_transition(context: Dictionary) -> String:
	# Check for dodge cancel
	if context.get("dodge_pressed", false):
		if combo_manager and combo_manager.try_cancel():
			return "ActionIdle"
	
	# Return to idle when attack finishes
	if combo_manager == null or not combo_manager.is_attacking:
		return "ActionIdle"
	
	return ""