# Systems/Combat/Attacks/test_attack_2.gd
extends AttackBase


func _ready() -> void:
	attack_name = "Slash 2"
	damage = 12.0
	duration = 0.35
	
	# Slightly narrower arc
	shape_type = ShapePreset.ShapeType.ARC
	hitbox_radius = 50.0
	hitbox_angle = 100.0
	hitbox_lifetime = 0.15
	lunge_distance = 18.0