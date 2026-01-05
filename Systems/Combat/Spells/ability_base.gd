# Systems/Combat/Abilities/ability_base.gd
extends Node
class_name AbilityBase

## Base class for all ability nodes (spells, attacks, special moves)


signal ability_completed()


@export_group("Ability Properties")
@export var ability_name: String = "Unnamed Ability"
@export var mana_cost: float = 0.0
@export var cast_time: float = 0.0
@export var cooldown: float = 0.5
@export var movement_modifier: float = 1.0  # 1.0 = normal, 0.5 = slowed, 0.0 = locked
@export var can_dodge_cancel: bool = true

var caster: Node2D  # Reference to whoever cast this ability
var is_executing: bool = false


## Called when ability execution begins (after cast time)
func execute() -> void:
	push_warning("AbilityBase.execute() not implemented for %s" % ability_name)


## Set the caster reference
func set_caster(p_caster: Node2D) -> void:
	caster = p_caster