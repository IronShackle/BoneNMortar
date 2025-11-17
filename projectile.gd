extends Node2D
class_name Projectile

## Generic projectile that can be configured by spells

# Properties that spells can set
var speed: float = 300.0
var lifetime: float = 5.0
var damage: float = 10.0
var direction: Vector2 = Vector2.RIGHT

## Pierce mechanics
@export var max_hits: int = 1  ## Maximum entities this projectile can hit (0 = infinite)
@export var pierce_enabled: bool = false  ## Convenience flag to enable piercing

# Internal tracking
var time_alive: float = 0.0
var hits_remaining: int = 1  ## Runtime counter for remaining hits
var entities_hit: Array[Node] = []  ## Track entities we've already hit


func _ready() -> void:
	# Initialize pierce system
	if pierce_enabled and max_hits == 1:
		max_hits = 999999  # Effectively infinite if pierce enabled but no max set

	hits_remaining = max_hits if max_hits > 0 else 999999
	print("[Projectile] Ready! max_hits: ", max_hits, " hits_remaining: ", hits_remaining)

	# Connect to Hitbox for hit detection
	if has_node("Hitbox"):
		var hitbox = get_node("Hitbox") as Hitbox
		if hitbox:
			hitbox.hit_detected.connect(_on_hitbox_hit_detected)
			print("[Projectile] Connected to Hitbox hit_detected signal")
		else:
			print("[Projectile] ERROR: Hitbox node exists but failed to cast to Hitbox type!")
	else:
		print("[Projectile] ERROR: No Hitbox node found!")


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


func _on_hitbox_hit_detected(_hurtbox: Hurtbox, owner_entity: Node) -> void:
	## Called when our Hitbox detects a Hurtbox collision
	print("[Projectile] _on_hitbox_hit_detected called! Owner: ", owner_entity.name)

	# Prevent hitting the same entity twice
	if owner_entity in entities_hit:
		print("[Projectile] Already hit this entity, ignoring")
		return

	# Register this hit
	entities_hit.append(owner_entity)
	print("[Projectile] Registered hit on ", owner_entity.name)

	# Decrement remaining hits
	if max_hits > 0:  # Only decrement if not infinite pierce
		hits_remaining -= 1
		print("[Projectile] Decremented hits_remaining to ", hits_remaining)

	# Despawn if we've exhausted our hits
	if hits_remaining <= 0:
		print("[Projectile] Hits exhausted, despawning")
		queue_free()
	else:
		print("[Projectile] Continuing with ", hits_remaining, " hits remaining")
