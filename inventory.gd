# Systems/Inventory/inventory.gd
extends Node
class_name Inventory


var soul_count: int = 0


func add_souls(amount: int) -> void:
	soul_count += amount
	print("Souls collected: +%d (Total: %d)" % [amount, soul_count])


func get_soul_count() -> int:
	return soul_count