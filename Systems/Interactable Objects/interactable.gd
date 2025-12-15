# interactable.gd - Base class for all interactables
class_name Interactable
extends Area2D

## Base class for all interactable objects


@export var interaction_prompt: String = "Interact"


func can_interact() -> bool:
	return true


func interact(_player: Node2D) -> void:
	pass