# altar_base.gd
class_name AltarBase
extends Interactable

## Altar that holds and executes effects


@export var uses_remaining: int = 3

var effect: AltarEffect = null


func _ready() -> void:
	_discover_effect()


func _discover_effect() -> void:
	for child in get_children():
		if child is AltarEffect:
			effect = child
			return


func can_interact() -> bool:
	return uses_remaining > 0 and effect != null


func interact(player: Node2D) -> void:
	if not can_interact():
		return
	
	uses_remaining -= 1
	effect.execute(player)
	
	print("Altar used. Uses remaining: %d" % uses_remaining)