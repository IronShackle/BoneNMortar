# Systems/Player/player_controller.gd
extends MobBase


var ability_manager: AbilityManager
var combo_manager: ComboManager

@onready var interaction_zone: Area2D = $InteractionZone


func _process(_delta: float) -> void:
	_check_interaction_input()


func get_movement_context(_delta: float) -> Dictionary:
	return {
		"input_direction": Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down"),
		"dodge_pressed": Input.is_action_just_pressed("dodge")
	}


func get_action_context(_delta: float) -> Dictionary:
	return {
		"attack_pressed": Input.is_action_just_pressed("attack"),
		"cast_primary": Input.is_action_pressed("cast_primary"),
		"dodge_pressed": Input.is_action_just_pressed("dodge"),
		"parry_pressed": Input.is_action_just_pressed("parry"),
		"parry_held": Input.is_action_pressed("parry")
	}


func _setup_mob_specific() -> void:
	ability_manager = AbilityManager.new(self)
	combo_manager = ComboManager.new(self)
	add_child(combo_manager)
	
	movement_machine.state_changed.connect(_on_movement_state_changed)


func _setup_movement_machine() -> void:
	var idle_state = IdleState.new(movement_machine, self)
	var run_state = RunState.new(movement_machine, self)
	var dodge_state = DodgeState.new(movement_machine, self)
	
	movement_machine.add_state("Idle", idle_state)
	movement_machine.add_state("Run", run_state)
	movement_machine.add_state("Dodge", dodge_state)
	
	movement_machine.set_initial_state("Idle")
	movement_machine.start()


func _setup_action_machine() -> void:
	var action_idle = ActionIdleState.new(action_machine, self)
	var action_casting = ActionCastingState.new(action_machine, self)
	var action_attacking = ActionAttackingState.new(action_machine, self)
	var parry_state = ParryState.new(action_machine, self)
	
	action_machine.add_state("ActionIdle", action_idle)
	action_machine.add_state("Casting", action_casting)
	action_machine.add_state("Attacking", action_attacking)
	action_machine.add_state("Parrying", parry_state)
	
	action_machine.set_initial_state("ActionIdle")
	action_machine.start()


func _on_movement_state_changed(old_state: String, new_state: String) -> void:
	if new_state == "Dodge":
		action_machine.set_transition_rule("ActionIdle", "Casting", false)
		action_machine.set_transition_rule("ActionIdle", "Attacking", false)
	elif old_state == "Dodge":
		action_machine.set_transition_rule("ActionIdle", "Casting", true)
		action_machine.set_transition_rule("ActionIdle", "Attacking", true)


func get_ability_manager() -> AbilityManager:
	return ability_manager


func get_combo_manager() -> ComboManager:
	return combo_manager


func has_mana(_cost: float) -> bool:
	return true


func consume_mana(_cost: float) -> void:
	pass


func _check_interaction_input() -> void:
	if Input.is_action_just_pressed("interact"):
		_try_interact()


func _try_interact() -> void:
	var interactable = _get_nearby_interactable()
	
	if interactable and interactable.can_interact():
		interactable.interact(self)


func _get_nearby_interactable() -> Interactable:
	if not interaction_zone:
		return null
	
	var overlapping_areas = interaction_zone.get_overlapping_areas()
	
	for area in overlapping_areas:
		if area is Interactable:
			return area
	
	return null
