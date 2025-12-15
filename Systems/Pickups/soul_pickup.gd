# soul_pickup.gd
extends Pickup
class_name SoulPickup

## Collectible soul resource dropped by enemies


@export var soul_amount: int = 1


func _on_collected(player: Node2D) -> void:
	var inventory = player.get_node("Inventory")
	
	if inventory and inventory is Inventory:
		inventory.add_souls(soul_amount)
		queue_free()
	else:
		push_error("Player is missing Inventory component!")