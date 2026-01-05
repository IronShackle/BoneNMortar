# Systems/Combat/Abilities/Flail Charge/flail_charge.gd
extends AbilityBase
class_name FlailChargeAbility

enum Phase { WINDUP, CHARGING, RECOVERY }

@export_group("Timing")
@export var windup_duration: float = 1.0
@export var charge_duration: float = 1.2
@export var recovery_duration: float = 0.5

@export_group("Movement")
@export var charge_speed: float = 200.0

@export_group("Hitbox Spawning")
@export var hitbox_count: int = 8
@export var cone_angle: float = 60.0
@export var cone_range: float = 40.0
@export var hitbox_lifetime: float = 0.2
@export var triangle_length: float = 30.0
@export var triangle_width: float = 20.0

var current_phase: Phase = Phase.WINDUP
var phase_timer: float = 0.0
var charge_direction: Vector2 = Vector2.ZERO
var hitboxes_spawned: int = 0
var spawn_interval: float = 0.0
var spawn_timer: float = 0.0


func execute() -> void:
	if is_executing:
		return
	
	is_executing = true
	current_phase = Phase.WINDUP
	phase_timer = windup_duration
	hitboxes_spawned = 0
	
	var player = caster.get_tree().get_first_node_in_group("player")
	if player:
		charge_direction = (player.global_position - caster.global_position).normalized()
	else:
		charge_direction = Vector2.DOWN
	
	print("[FlailCharge] Starting charge - Windup phase")


func update(_delta: float) -> void:
	if not is_executing:
		return
	
	phase_timer -= _delta
	
	match current_phase:
		Phase.WINDUP:
			_process_windup(_delta)
		Phase.CHARGING:
			_process_charging(_delta)
		Phase.RECOVERY:
			_process_recovery(_delta)


func _process_windup(_delta: float) -> void:
	var movement = caster.get_movement_component()
	if movement:
		movement.set_movement_modifier(0.0)
	
	if phase_timer <= 0:
		_enter_phase(Phase.CHARGING)


func _process_charging(_delta: float) -> void:
	# Apply continuous impulse to maintain speed
	var movement = caster.get_movement_component()
	if movement:
		var impulse = charge_direction * charge_speed * _delta * 60.0
		movement.apply_impulse(impulse)
	
	# Spawn hitboxes at intervals
	spawn_timer -= _delta
	if spawn_timer <= 0 and hitboxes_spawned < hitbox_count:
		_spawn_hitbox()
		hitboxes_spawned += 1
		spawn_timer = spawn_interval
	
	if phase_timer <= 0:
		_enter_phase(Phase.RECOVERY)


func _process_recovery(_delta: float) -> void:
	if phase_timer <= 0:
		_complete_ability()


func _enter_phase(new_phase: Phase) -> void:
	current_phase = new_phase
	
	match new_phase:
		Phase.WINDUP:
			phase_timer = windup_duration
		Phase.CHARGING:
			phase_timer = charge_duration
			spawn_interval = charge_duration / hitbox_count
			spawn_timer = spawn_interval
			
			var movement = caster.get_movement_component()
			if movement:
				movement.reset_movement_modifier()
			
			print("[FlailCharge] Charging!")
		Phase.RECOVERY:
			phase_timer = recovery_duration


func _spawn_hitbox() -> void:
	var hitbox = HitboxInstance.new()
	caster.get_tree().current_scene.add_child(hitbox)
	
	# Random position within cone
	var angle_offset = randf_range(-cone_angle / 2, cone_angle / 2)
	var distance_offset = randf_range(0, cone_range)
	var base_angle = charge_direction.angle()
	var spawn_angle = base_angle + deg_to_rad(angle_offset)
	var spawn_offset = Vector2(cos(spawn_angle), sin(spawn_angle)) * distance_offset
	
	hitbox.global_position = caster.global_position + spawn_offset
	hitbox.rotation = charge_direction.angle()
	
	# Get team from caster's hurtbox
	var team = "neutral"
	var caster_hurtbox = caster.get_node_or_null("Hurtbox") as Hurtbox
	if caster_hurtbox:
		team = caster_hurtbox.team
	
	hitbox.initialize(
		team,
		hitbox_lifetime,
		ShapePreset.ShapeType.TRIANGLE,
		0.0,
		0.0,
		Vector2(triangle_length, triangle_width)
	)


func _complete_ability() -> void:
	var movement = caster.get_movement_component()
	if movement:
		movement.reset_movement_modifier()
	
	is_executing = false
	ability_completed.emit()
	print("[FlailCharge] Charge complete")


func cancel() -> void:
	if not is_executing:
		return
	
	var movement = caster.get_movement_component()
	if movement:
		movement.reset_movement_modifier()
	
	is_executing = false
	print("[FlailCharge] Cancelled")
