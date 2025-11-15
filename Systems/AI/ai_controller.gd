# ai/ai_controller.gd
extends Node
class_name AIController


@export var ai_behavior: AIBehavior

var mob: MobBase


func _ready() -> void:
	mob = get_parent()
	if ai_behavior:
		ai_behavior.initialize(mob)


func get_move_direction() -> Vector2:
	if ai_behavior:
		return ai_behavior.get_move_direction()
	return Vector2.ZERO