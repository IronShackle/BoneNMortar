# Systems/Boss/boss_part.gd
extends Node2D
class_name BossPart

## Base class for boss parts (masks, core, etc.)


signal activated()
signal deactivated()

@export var start_position: Vector2 = Vector2.ZERO  ## Position when active
@export var inactive_position: Vector2 = Vector2(0, -500)  ## Position when inactive

var is_active: bool = false
var hurtbox: Hurtbox
var boss_health_pool: BossHealthPool


func _ready() -> void:
	# Start inactive
	global_position = inactive_position
	visible = false
	
	# Find hurtbox if present
	hurtbox = get_node_or_null("Hurtbox")
	if hurtbox:
		hurtbox.hit_by_hitbox.connect(_on_hit_by_hitbox)
	
	# Find boss health pool (parent should be BossRoot)
	var boss_root = get_parent()
	if boss_root:
		boss_health_pool = boss_root.get_node_or_null("BossHealthPool")


func activate() -> void:
	if is_active:
		return
	
	is_active = true
	global_position = start_position
	visible = true
	activated.emit()
	
	print("[BossPart] %s activated" % name)


func deactivate() -> void:
	if not is_active:
		return
	
	is_active = false
	global_position = inactive_position
	visible = false
	
	# Stop behavior manager if present
	var behavior_manager = get_node_or_null("BehaviorManager")
	if behavior_manager:
		behavior_manager.stop()
	
	deactivated.emit()
	
	print("[BossPart] %s deactivated" % name)


func _on_hit_by_hitbox(hitbox: Hitbox) -> void:
	if not is_active:
		return
	
	if boss_health_pool:
		boss_health_pool.take_damage(hitbox.damage, hitbox.get_parent())
		print("[BossPart] %s took %.1f damage" % [name, hitbox.damage])