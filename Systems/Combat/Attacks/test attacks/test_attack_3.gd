# Systems/Combat/Attacks/test_attack_3.gd
extends AttackBase


func _ready() -> void:
	attack_name = "Stab"
	damage = 20.0
	duration = 0.5
	
	# Triangle poke
	shape_type = ShapePreset.ShapeType.TRIANGLE
	hitbox_size = Vector2(60, 25)  # Long and narrow
	hitbox_lifetime = 0.2
	lunge_distance = 30.0