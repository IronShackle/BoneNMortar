# ai/behaviors/chase_player_behavior.gd
extends AIBehavior
class_name ChasePlayerBehavior


var target: Node2D


func initialize(p_mob: MobBase) -> void:
	super(p_mob)
	target = mob.get_tree().get_first_node_in_group("player")


func get_move_direction() -> Vector2:
	if target:
		return (target.global_position - mob.global_position).normalized()
	return Vector2.ZERO
