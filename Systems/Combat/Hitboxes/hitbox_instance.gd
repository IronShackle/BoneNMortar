# Systems/Combat/Hitboxes/hitbox_instance.gd
class_name HitboxInstance
extends Area2D

## Runtime hitbox that detects overlaps and emits hit signals


signal hit_landed(hurtbox: Hurtbox)


@export var debug_draw: bool = true
@export var debug_color: Color = Color(1.0, 0.2, 0.2, 0.4)

var team: String = "neutral"
var lifetime: float = 0.1
var life_timer: float = 0.0
var hit_targets: Dictionary = {}

# Store shape info for drawing
var _shape_type: ShapePreset.ShapeType
var _radius: float
var _angle: float
var _size: Vector2


func initialize(
	p_team: String,
	p_lifetime: float,
	shape_type: ShapePreset.ShapeType,
	radius: float,
	angle: float,
	size: Vector2
) -> void:
	team = p_team
	lifetime = p_lifetime
	life_timer = 0.0
	hit_targets.clear()
	
	# Store for drawing
	_shape_type = shape_type
	_radius = radius
	_angle = angle
	_size = size
	
	# Generate collision shape
	ShapePreset.apply_shape(self, shape_type, radius, angle, size)
	
	# Configure collision
	collision_layer = 0
	collision_mask = 1
	
	monitoring = true
	set_process(true)
	queue_redraw()


func _process(delta: float) -> void:
	life_timer += delta
	
	if life_timer >= lifetime:
		_despawn()
		return
	
	_check_overlaps()


func _check_overlaps() -> void:
	var overlapping = get_overlapping_areas()
	
	for area in overlapping:
		if not area is Hurtbox:
			continue
		
		var hurtbox = area as Hurtbox
		
		if hurtbox.team == team:
			continue
		
		var hurtbox_id = hurtbox.get_instance_id()
		if hit_targets.has(hurtbox_id):
			continue
		
		hit_targets[hurtbox_id] = true
		hit_landed.emit(hurtbox)


func _despawn() -> void:
	set_process(false)
	monitoring = false
	queue_free()


func _draw() -> void:
	if not debug_draw:
		return
	
	match _shape_type:
		ShapePreset.ShapeType.CIRCLE:
			_draw_circle()
		ShapePreset.ShapeType.ARC:
			_draw_arc()
		ShapePreset.ShapeType.TRIANGLE:
			_draw_triangle()


func _draw_circle() -> void:
	draw_circle(Vector2.ZERO, _radius, debug_color)
	draw_arc(Vector2.ZERO, _radius, 0, TAU, 32, debug_color.lightened(0.3), 2.0)


func _draw_arc() -> void:
	var points = PackedVector2Array()
	var half_angle = deg_to_rad(_angle / 2.0)
	var segments = maxi(3, ceili(_angle / 10.0))
	
	points.append(Vector2.ZERO)
	
	for i in range(segments + 1):
		var t = float(i) / float(segments)
		var current_angle = -half_angle + (t * deg_to_rad(_angle))
		var point = Vector2(cos(current_angle), sin(current_angle)) * _radius
		points.append(point)
	
	draw_colored_polygon(points, debug_color)
	
	# Draw outline
	var outline_color = debug_color.lightened(0.3)
	for i in range(points.size()):
		var next_i = (i + 1) % points.size()
		draw_line(points[i], points[next_i], outline_color, 2.0)


func _draw_triangle() -> void:
	var points = PackedVector2Array()
	
	points.append(Vector2(0, -_size.y / 2.0))
	points.append(Vector2(_size.x, 0))
	points.append(Vector2(0, _size.y / 2.0))
	
	draw_colored_polygon(points, debug_color)
	
	# Draw outline
	var outline_color = debug_color.lightened(0.3)
	for i in range(points.size()):
		var next_i = (i + 1) % points.size()
		draw_line(points[i], points[next_i], outline_color, 2.0)