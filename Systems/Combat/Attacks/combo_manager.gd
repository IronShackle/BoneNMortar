# Systems/Combat/Attacks/combo_manager.gd
extends Node
class_name ComboManager

## Manages melee combo chains, attack slots, and input buffering


signal combo_reset()
signal attack_executed(attack: AttackBase, combo_index: int)


@export_group("Combo Settings")
@export var combo_window: float = 1.0  ## Seconds before combo resets
@export var attacks: Array[AttackBase] = []  ## Attack chain slots

var combo_index: int = 0
var combo_timer: float = 0.0
var is_attacking: bool = false
var input_buffered: bool = false

var caster: Node2D
var current_attack: AttackBase = null


func _init(p_caster: Node2D) -> void:
	caster = p_caster


func _ready() -> void:
	_discover_attacks()


func _process(delta: float) -> void:
	if combo_timer > 0.0:
		combo_timer -= delta
		
		if combo_timer <= 0.0:
			_reset_combo()


## Discover attack nodes attached to caster
func _discover_attacks() -> void:
	attacks.clear()
	
	# Check for Attacks container first
	if caster.has_node("Attacks"):
		for child in caster.get_node("Attacks").get_children():
			if child is AttackBase:
				child.set_caster(caster)
				attacks.append(child)
				print("Discovered attack: %s" % child.attack_name)
	
	if attacks.is_empty():
		push_warning("ComboManager: No attacks discovered!")


## Try to execute the next attack in the combo
func try_attack() -> bool:
	if is_attacking:
		# Buffer the input
		input_buffered = true
		return false
	
	if attacks.is_empty():
		return false
	
	_execute_current_attack()
	return true


## Execute the attack at current combo index
func _execute_current_attack() -> void:
	current_attack = attacks[combo_index]
	is_attacking = true
	input_buffered = false
	
	# Connect to attack finished signal
	if not current_attack.attack_finished.is_connected(_on_attack_finished):
		current_attack.attack_finished.connect(_on_attack_finished)
	
	current_attack.execute()
	attack_executed.emit(current_attack, combo_index)
	
	# Advance combo index (wrap at end)
	combo_index = (combo_index + 1) % attacks.size()
	
	# Reset combo timer
	combo_timer = combo_window


## Called when current attack finishes
func _on_attack_finished() -> void:
	is_attacking = false
	current_attack = null
	
	# Check for buffered input
	if input_buffered:
		input_buffered = false
		_execute_current_attack()


## Reset combo to beginning
func _reset_combo() -> void:
	combo_index = 0
	combo_timer = 0.0
	input_buffered = false
	combo_reset.emit()


## Clear buffered input (called on dodge)
func clear_buffer() -> void:
	input_buffered = false


## Cancel current attack if possible (returns true if cancelled)
func try_cancel() -> bool:
	if not is_attacking or current_attack == null:
		return true  # Nothing to cancel
	
	if current_attack.can_dodge_cancel:
		current_attack.cancel()
		is_attacking = false
		current_attack = null
		clear_buffer()
		return true
	
	return false


## Check if movement should be locked
func is_movement_locked() -> bool:
	if not is_attacking or current_attack == null:
		return false
	
	return current_attack.movement_locked


## Get current attack (for external queries)
func get_current_attack() -> AttackBase:
	return current_attack


## Add an attack to the chain
func add_attack(attack: AttackBase) -> void:
	attack.set_caster(caster)
	attacks.append(attack)


## Remove an attack from the chain
func remove_attack(attack: AttackBase) -> void:
	attacks.erase(attack)
	
	# Clamp combo index if needed
	if combo_index >= attacks.size():
		combo_index = 0


## Clear all attacks
func clear_attacks() -> void:
	attacks.clear()
	_reset_combo()