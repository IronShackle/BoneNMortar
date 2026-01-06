class_name PrintEffect
extends AltarEffect

## An altar effect that prints a message when executed  
@export var message: String = "What!"

func execute(_player: Node2D) -> void:
    print(message) 

