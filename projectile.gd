extends Node2D
class_name Projectile

## Generic projectile that can be configured by spells

# Properties that spells can set
var speed: float = 300.0
var lifetime: float = 5.0
var damage: float = 10.0
var direction: Vector2 = Vector2.RIGHT

# Internal tracking
var time_alive: float = 0.0



func _physics_process(delta: float) -> void:
	# Move forward
	global_position += direction.normalized() * speed * delta
	
	# Track lifetime
	time_alive += delta
	if time_alive >= lifetime:
		queue_free()  # Despawn after lifetime


func set_collision_radius(radius: float) -> void:
	var shape = CircleShape2D.new()
	shape.radius = radius
	
	if has_node("Hitbox/CollisionShape2D"):
		$Hitbox/CollisionShape2D.shape = shape


func _on_hit_hurtbox(hurtbox: Hurtbox) -> void:
	# Deal damage to whatever has the hurtbox
	hurtbox.damage(damage)
	
	# Destroy projectile on hit
	queue_free()
