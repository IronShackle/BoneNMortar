# Systems/Boss/Behaviors/behavior_base.gd
extends Node
class_name BehaviorBase

## Base class for boss part behaviors


signal behavior_completed()

@export var duration: float = 5.0  ## How long this behavior runs (0 = until manually stopped)

var boss_part: BossPart
var elapsed_time: float = 0.0
var is_running: bool = false


func _ready() -> void:
	# Get parent boss part
	boss_part = get_parent().get_parent() as BossPart
	set_process(false)


func start_behavior() -> void:
	elapsed_time = 0.0
	is_running = true
	set_process(true)
	_on_start()


func end_behavior() -> void:
	is_running = false
	set_process(false)
	_on_end()


func _process(delta: float) -> void:
	if not is_running:
		return
	
	elapsed_time += delta
	_on_update(delta)
	
	# Check duration
	if duration > 0 and elapsed_time >= duration:
		end_behavior()
		behavior_completed.emit()


## Override in subclasses
func _on_start() -> void:
	pass


func _on_update(_delta: float) -> void:
	pass


func _on_end() -> void:
	pass