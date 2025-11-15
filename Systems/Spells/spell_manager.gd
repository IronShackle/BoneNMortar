# systems/spells/spell_manager.gd
class_name SpellManager
extends RefCounted

## Manages equipped spells and spell slots


var caster: Node2D

# Spell slots
var primary_spell: SpellBase = null
var secondary_spell: SpellBase = null

# All available spells (for swapping)
var available_spells: Array[SpellBase] = []


func _init(p_caster: Node2D) -> void:
	caster = p_caster
	_discover_spells()
	_auto_equip_first_spell()


## Discover all spell nodes attached to the caster
func _discover_spells() -> void:
	available_spells.clear()
	
	# Check for Spells container first
	if caster.has_node("Spells"):
		for child in caster.get_node("Spells").get_children():
			if child is SpellBase:
				child.set_caster(caster)
				available_spells.append(child)
	else:
		# Fallback: search all children
		for child in caster.get_children():
			if child is SpellBase:
				child.set_caster(caster)
				available_spells.append(child)


## Auto-equip first spell if none equipped (convenience for prototype)
func _auto_equip_first_spell() -> void:
	if available_spells.size() > 0 and primary_spell == null:
		primary_spell = available_spells[0]
		print("Auto-equipped %s to primary slot" % primary_spell.spell_name)


## Get the equipped primary spell
func get_primary_spell() -> SpellBase:
	return primary_spell


## Get the equipped secondary spell
func get_secondary_spell() -> SpellBase:
	return secondary_spell


## Equip a spell to primary slot
func equip_primary(spell: SpellBase) -> void:
	if spell in available_spells:
		primary_spell = spell
		print("Equipped %s to primary slot" % spell.spell_name)
	else:
		push_error("Spell not in available spells list")


## Equip a spell to secondary slot
func equip_secondary(spell: SpellBase) -> void:
	if spell in available_spells:
		secondary_spell = spell
		print("Equipped %s to secondary slot" % spell.spell_name)
	else:
		push_error("Spell not in available spells list")


## Equip a spell by name
func equip_primary_by_name(spell_name: String) -> void:
	for spell in available_spells:
		if spell.spell_name == spell_name:
			equip_primary(spell)
			return
	push_error("Spell '%s' not found" % spell_name)


## Get all available spells
func get_available_spells() -> Array[SpellBase]:
	return available_spells


## Check if can cast a spell (mana check, cooldown, etc.)
func can_cast(spell: SpellBase) -> bool:
	if spell == null:
		return false
	
	# For now, just check mana (placeholder)
	# TODO: Add cooldown tracking here later
	return caster.has_mana(spell.mana_cost)


## Consume resources when casting a spell
func consume_resources(spell: SpellBase) -> void:
	caster.consume_mana(spell.mana_cost)
	# TODO: Start cooldown tracking here later
