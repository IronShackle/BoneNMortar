# projectiles/projectile.gd
extends Area2D
class_name Projectile

## Generic projectile that can be configured by spells


# Properties that spells can set
var speed: float = 300.0
var lifetime: float = 5.0
var damage: float = 10.0
var direction: Vector2 = Vector2.RIGHT

# Internal tracking
var time_alive: float = 0.0


func _ready() -> void:
	# Start moving in the set direction
	pass


func _physics_process(delta: float) -> void:
	# Move forward
	global_position += direction.normalized() * speed * delta
	
	# Track lifetime
	time_alive += delta
	if time_alive >= lifetime:
		queue_free()  # Despawn after lifetime


#Methods to set collision shape
func set_collision_radius(radius: float) -> void:
	var shape = CircleShape2D.new()
	shape.radius = radius
	$CollisionShape2D.shape = shape


func set_collision_rect(size: Vector2) -> void:
	var shape = RectangleShape2D.new()
	shape.size = size
	$CollisionShape2D.shape = shape


func set_collision_capsule(radius: float, height: float) -> void:
	var shape = CapsuleShape2D.new()
	shape.radius = radius
	shape.height = height
	$CollisionShape2D.shape = shape

#Method to set sprite/animation
func set_animation(sprite_frames: SpriteFrames, animation_name: String = "default") -> void:
	$AnimatedSprite2D.sprite_frames = sprite_frames
	$AnimatedSprite2D.play(animation_name)
