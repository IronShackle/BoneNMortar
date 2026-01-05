# Systems/Combat/Abilities/ability_manager.gd
class_name AbilityManager
extends RefCounted

## Manages equipped abilities and ability slots


var caster: Node2D

# Ability slots
var primary_ability: AbilityBase = null
var secondary_ability: AbilityBase = null

# All available abilities (for swapping)
var available_abilities: Array[AbilityBase] = []


func _init(p_caster: Node2D) -> void:
	caster = p_caster
	_discover_abilities()
	_auto_equip_first_ability()


## Discover all ability nodes attached to the caster
func _discover_abilities() -> void:
	available_abilities.clear()
	
	# Check for Abilities container first (backward compat with "Spells")
	var container_names = ["Abilities", "Spells"]
	
	for container_name in container_names:
		if caster.has_node(container_name):
			for child in caster.get_node(container_name).get_children():
				if child is AbilityBase:
					child.set_caster(caster)
					available_abilities.append(child)
			return  # Found container, stop searching
	
	# Fallback: search all children
	for child in caster.get_children():
		if child is AbilityBase:
			child.set_caster(caster)
			available_abilities.append(child)


## Auto-equip first ability if none equipped (convenience for prototype)
func _auto_equip_first_ability() -> void:
	if available_abilities.size() > 0 and primary_ability == null:
		primary_ability = available_abilities[0]
		print("Auto-equipped %s to primary slot" % primary_ability.ability_name)


## Get the equipped primary ability
func get_primary_ability() -> AbilityBase:
	return primary_ability


## Get the equipped secondary ability
func get_secondary_ability() -> AbilityBase:
	return secondary_ability


## Equip an ability to primary slot
func equip_primary(ability: AbilityBase) -> void:
	if ability in available_abilities:
		primary_ability = ability
		print("Equipped %s to primary slot" % ability.ability_name)
	else:
		push_error("Ability not in available abilities list")


## Equip an ability to secondary slot
func equip_secondary(ability: AbilityBase) -> void:
	if ability in available_abilities:
		secondary_ability = ability
		print("Equipped %s to secondary slot" % ability.ability_name)
	else:
		push_error("Ability not in available abilities list")


## Equip an ability by name
func equip_primary_by_name(ability_name: String) -> void:
	for ability in available_abilities:
		if ability.ability_name == ability_name:
			equip_primary(ability)
			return
	push_error("Ability '%s' not found" % ability_name)


## Get all available abilities
func get_available_abilities() -> Array[AbilityBase]:
	return available_abilities


## Check if can cast an ability (mana check, cooldown, etc.)
func can_cast(ability: AbilityBase) -> bool:
	if ability == null:
		return false
	
	# For now, just check mana (placeholder)
	# TODO: Add cooldown tracking here later
	return caster.has_mana(ability.mana_cost)


## Consume resources when casting an ability
func consume_resources(ability: AbilityBase) -> void:
	caster.consume_mana(ability.mana_cost)
	# TODO: Start cooldown tracking here later