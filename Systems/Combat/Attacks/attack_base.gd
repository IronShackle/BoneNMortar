# Systems/Combat/Attacks/attack_base.gd
extends Node
class_name AttackBase

## Base class for all attack nodes in a combo chain


signal attack_started()
signal attack_finished()


@export_group("Attack Properties")
@export var attack_name: String = "Unnamed Attack"
@export var damage: float = 10.0
@export var duration: float = 0.4
@export var movement_locked: bool = true
@export var can_dodge_cancel: bool = true
@export var knockback_force: float = 150.0

@export_group("Hitbox Shape")
@export var shape_type: ShapePreset.ShapeType = ShapePreset.ShapeType.ARC
@export var hitbox_radius: float = 40.0
@export var hitbox_angle: float = 90.0
@export var hitbox_size: Vector2 = Vector2(50, 30)
@export var hitbox_offset: Vector2 = Vector2.ZERO
@export var hitbox_lifetime: float = 0.15

@export_group("Movement")
@export var lunge_distance: float = 20.0

var is_active: bool = false
var caster: Node2D
var attack_direction: Vector2 = Vector2.RIGHT


func execute() -> void:
	if is_active:
		return
	
	is_active = true
	attack_started.emit()
	
	_capture_aim_direction()
	_apply_lunge()
	_spawn_hitbox()
	
	var timer = get_tree().create_timer(duration)
	timer.timeout.connect(_on_attack_finished)


func _capture_aim_direction() -> void:
	if caster == null:
		return
	
	var mouse_pos = caster.get_global_mouse_position()
	var to_mouse = (mouse_pos - caster.global_position).normalized()
	
	if to_mouse.length() < 0.1:
		attack_direction = Vector2.RIGHT
	else:
		attack_direction = _snap_direction_to_45(to_mouse)


func _snap_direction_to_45(direction: Vector2) -> Vector2:
	if direction.length() < 0.1:
		return Vector2.RIGHT
	
	var angle = direction.angle()
	var degrees = rad_to_deg(angle)
	var snapped_degrees = round(degrees / 45.0) * 45.0
	
	return Vector2.from_angle(deg_to_rad(snapped_degrees))


func _apply_lunge() -> void:
	if caster == null or lunge_distance <= 0:
		return
	
	var movement = caster.get_node_or_null("MovementComponent") as MovementComponent
	if movement:
		movement.apply_impulse(attack_direction * lunge_distance)


func _spawn_hitbox() -> void:
	if caster == null:
		return
	
	var hitbox = HitboxInstance.new()
	caster.get_tree().current_scene.add_child(hitbox)
	
	hitbox.global_position = caster.global_position + hitbox_offset.rotated(attack_direction.angle())
	hitbox.rotation = attack_direction.angle()
	
	var team = "neutral"
	var caster_hurtbox = caster.get_node_or_null("Hurtbox") as Hurtbox
	if caster_hurtbox:
		team = caster_hurtbox.team
	
	hitbox.initialize(
		team,
		hitbox_lifetime,
		shape_type,
		hitbox_radius,
		hitbox_angle,
		hitbox_size
	)
	
	hitbox.hit_landed.connect(_on_hitbox_hit)


func _on_hitbox_hit(hurtbox: Hurtbox) -> void:
	var target = hurtbox.get_parent()
	if target == null:
		return
	
	var health = target.get_node_or_null("HealthComponent") as HealthComponent
	if health:
		health.lose_life(damage, caster)
	
	if knockback_force > 0:
		var movement = target.get_node_or_null("MovementComponent") as MovementComponent
		if movement:
			var knockback_dir = (target.global_position - caster.global_position).normalized()
			movement.apply_impulse(knockback_dir * knockback_force)
	
	print("[%s] Hit %s for %.1f damage" % [attack_name, target.name, damage])


func _on_attack_finished() -> void:
	is_active = false
	attack_finished.emit()


func cancel() -> void:
	if not is_active:
		return
	
	is_active = false
	attack_finished.emit()


func set_caster(p_caster: Node2D) -> void:
	caster = p_caster