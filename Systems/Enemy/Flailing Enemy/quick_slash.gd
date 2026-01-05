# Systems/Combat/Abilities/Quick Slash/quick_slash.gd
extends AbilityBase
class_name QuickSlashAbility

enum Phase { WINDUP, ATTACKING, RECOVERY }

@export_group("Timing")
@export var windup_duration: float = 0.3
@export var attack_duration: float = 0.2
@export var recovery_duration: float = 0.3

@export_group("Movement")
@export var step_distance: float = 40.0

@export_group("Hitbox")
@export var hitbox_lifetime: float = 0.15
@export var arc_radius: float = 50.0
@export var arc_angle: float = 90.0

var current_phase: Phase = Phase.WINDUP
var phase_timer: float = 0.0
var attack_direction: Vector2 = Vector2.ZERO
var has_spawned_hitbox: bool = false


func execute() -> void:
	if is_executing:
		return
	
	is_executing = true
	current_phase = Phase.WINDUP
	phase_timer = windup_duration
	has_spawned_hitbox = false
	
	var player = caster.get_tree().get_first_node_in_group("player")
	if player:
		attack_direction = (player.global_position - caster.global_position).normalized()
	else:
		attack_direction = Vector2.DOWN
	
	print("[QuickSlash] Starting attack - Windup phase")


func update(_delta: float) -> void:
	if not is_executing:
		return
	
	phase_timer -= _delta
	
	match current_phase:
		Phase.WINDUP:
			_process_windup(_delta)
		Phase.ATTACKING:
			_process_attacking(_delta)
		Phase.RECOVERY:
			_process_recovery(_delta)


func _process_windup(_delta: float) -> void:
	var movement = caster.get_movement_component()
	if movement:
		movement.set_movement_modifier(0.0)
	
	if phase_timer <= 0:
		_enter_phase(Phase.ATTACKING)


func _process_attacking(_delta: float) -> void:
	if not has_spawned_hitbox:
		var movement = caster.get_movement_component()
		if movement:
			movement.reset_movement_modifier()
			var step_impulse = attack_direction * step_distance * 20.0
			movement.apply_impulse(step_impulse)
		
		_spawn_hitbox()
		has_spawned_hitbox = true
	
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
		Phase.ATTACKING:
			phase_timer = attack_duration
			print("[QuickSlash] Attacking!")
		Phase.RECOVERY:
			phase_timer = recovery_duration


func _spawn_hitbox() -> void:
	var hitbox = HitboxInstance.new()
	caster.get_tree().current_scene.add_child(hitbox)
	
	hitbox.global_position = caster.global_position
	hitbox.rotation = attack_direction.angle()
	
	# Get team from caster's hurtbox
	var team = "neutral"
	var caster_hurtbox = caster.get_node_or_null("Hurtbox") as Hurtbox
	if caster_hurtbox:
		team = caster_hurtbox.team
	
	hitbox.initialize(
		team,
		hitbox_lifetime,
		ShapePreset.ShapeType.ARC,
		arc_radius,
		arc_angle,
		Vector2.ZERO
	)
	
	print("[QuickSlash] Spawned arc hitbox at angle: %f" % attack_direction.angle())


func _complete_ability() -> void:
	var movement = caster.get_movement_component()
	if movement:
		movement.reset_movement_modifier()
	
	is_executing = false
	ability_completed.emit()
	print("[QuickSlash] Attack complete")


func cancel() -> void:
	if not is_executing:
		return
	
	var movement = caster.get_movement_component()
	if movement:
		movement.reset_movement_modifier()
	
	is_executing = false
	print("[QuickSlash] Cancelled")
