# ai/ai_behavior.gd
extends Resource
class_name AIBehavior


var mob: MobBase


func initialize(p_mob: MobBase) -> void:
	mob = p_mob


func get_move_direction() -> Vector2:
	return Vector2.ZERO