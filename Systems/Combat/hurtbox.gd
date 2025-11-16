# Systems/Combat/hurtbox.gd
class_name Hurtbox
extends Area2D

## Detects when hitboxes enter and emits signal for owner to handle

signal hit_by_hitbox(hitbox: Hitbox)

@export var team: String = "neutral"


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	if not area is Hitbox:
		return
	
	var hitbox = area as Hitbox
	
	# Don't get hit by same team attacks
	if hitbox.team == team:
		return
	
	# Let the owner decide what to do with this hit
	hit_by_hitbox.emit(hitbox)