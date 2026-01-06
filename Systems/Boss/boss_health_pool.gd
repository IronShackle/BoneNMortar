# Systems/Boss/boss_health_pool.gd
extends Node
class_name BossHealthPool

## Shared health pool for boss waves


signal health_changed(old_value: float, new_value: float)
signal health_depleted()
signal damage_taken(amount: float, source: Node)

var max_health: float = 100.0
var current_health: float = 100.0


## Set health for a new wave
func set_health(amount: float) -> void:
	max_health = amount
	current_health = amount
	print("[BossHealth] Set to %.1f" % amount)


## Deal damage to the boss
func take_damage(amount: float, source: Node = null) -> void:
	if current_health <= 0:
		return
	
	var old_health = current_health
	current_health = max(0.0, current_health - amount)
	
	health_changed.emit(old_health, current_health)
	damage_taken.emit(amount, source)
	
	print("[BossHealth] Took %.1f damage (%.1f / %.1f)" % [amount, current_health, max_health])
	
	if current_health <= 0:
		health_depleted.emit()


## Heal the boss
func heal(amount: float) -> void:
	var old_health = current_health
	current_health = min(max_health, current_health + amount)
	health_changed.emit(old_health, current_health)


## Get health percentage (0.0 - 1.0)
func get_health_percent() -> float:
	if max_health <= 0:
		return 0.0
	return current_health / max_health