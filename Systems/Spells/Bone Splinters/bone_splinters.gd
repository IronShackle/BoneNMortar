# spells/bone_splinters.gd
extends SpellBase

## Close-range cone AoE spell that shotguns shrapnel


@export_group("Bone Splinters Properties")
@export var cone_angle: float = 60.0  # Degrees
@export var cone_range: float = 80.0  # Pixels
@export var damage: float = 15.0


func _ready() -> void:
	# Set spell properties
	spell_name = "Bone Splinters"
	mana_cost = 10.0
	cast_time = 0.2
	movement_modifier = 0.7
	can_dodge_cancel = true


func execute() -> void:
	if caster == null:
		push_error("Bone Splinters executed without caster!")
		return
	
	print("Bone Splinters executed!")
	
	# Get mouse position for aiming
	var mouse_pos = caster.get_global_mouse_position()
	var caster_pos = caster.global_position
	var aim_direction = (mouse_pos - caster_pos).normalized()
	
	print("Aim direction: %s" % aim_direction)
	print("Cone: %s degrees, %s range, %s damage" % [cone_angle, cone_range, damage])
	
	# TODO: Spawn cone AoE visual effect
	# TODO: Detect and damage enemies in cone