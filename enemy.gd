# enemy/enemy.gd
extends MobBase


@onready var ai_controller: AIController = $AIController


func get_movement_context(_delta: float) -> Dictionary:
	# AI provides direction instead of input
	var direction = Vector2.ZERO
	if ai_controller:
		direction = ai_controller.get_move_direction()
	
	return {
		"input_direction": direction,
		"dodge_pressed": false  # Enemies don't dodge for now
	}


func get_action_context(_delta: float) -> Dictionary:
	return {}  # Enemies don't have actions yet


func _setup_movement_machine() -> void:
	var idle_state = IdleState.new(movement_machine, self)
	var run_state = RunState.new(movement_machine, self)
	
	movement_machine.add_state("Idle", idle_state)
	movement_machine.add_state("Run", run_state)
	
	movement_machine.set_initial_state("Run")
	movement_machine.start()


func _setup_action_machine() -> void:
	var action_idle = ActionIdleState.new(action_machine, self)
	
	action_machine.add_state("ActionIdle", action_idle)
	
	action_machine.set_initial_state("ActionIdle")
	action_machine.start()
