# spells/spell_base.gd
extends Node
class_name SpellBase

## Base class for all spell nodes


@export_group("Spell Properties")
@export var spell_name: String = "Unnamed Spell"
@export var mana_cost: float = 0.0
@export var cast_time: float = 0.0
@export var cooldown: float = 0.5
@export var movement_modifier: float = 1.0  # 1.0 = normal, 0.5 = slowed, 0.0 = locked
@export var can_dodge_cancel: bool = true

var caster: Node2D  # Reference to whoever cast this spell


## Called when spell execution begins (after cast time)
func execute() -> void:
	push_warning("SpellBase.execute() not implemented for %s" % spell_name)


## Set the caster reference
func set_caster(p_caster: Node2D) -> void:
	caster = p_caster