# systems/state_machine/states/action/casting_state.gd
class_name ActionCastingState
extends State


var current_spell: SpellBase = null
var elapsed_time: float = 0.0
var cooldown_timer: float = 0.0
var mob: MobBase


func _init(p_state_machine, p_mob: MobBase) -> void:
	super(p_state_machine)
	mob = p_mob


func enter() -> void:
	if current_spell == null:
		push_error("CastingState entered with no spell set!")
		return
	
	elapsed_time = 0.0
	cooldown_timer = 0.0
	
	var spell_manager = mob.get_spell_manager()
	spell_manager.consume_resources(current_spell)
	
	var movement = mob.get_movement_component()
	movement.set_movement_modifier(current_spell.movement_modifier)
	
	print("Casting: %s" % current_spell.spell_name)


func update(delta: float, _context: Dictionary) -> void:
	if current_spell == null:
		return
	
	# Casting phase
	if elapsed_time < current_spell.cast_time:
		elapsed_time += delta
		
		if elapsed_time >= current_spell.cast_time:
			current_spell.execute()
			cooldown_timer = current_spell.cooldown
			print("Cast complete, cooldown: %s" % cooldown_timer)
	
	# Cooldown phase
	elif cooldown_timer > 0.0:
		cooldown_timer -= delta


func exit() -> void:
	var movement = mob.get_movement_component()
	movement.reset_movement_modifier()
	
	current_spell = null


func get_transition(context: Dictionary) -> String:
	if current_spell == null:
		return "ActionIdle"
	
	# Can cancel during cast or cooldown with dodge
	if context.get("dodge_pressed", false):
		if current_spell.can_dodge_cancel:
			print("Cast cancelled by dodge!")
			return "ActionIdle"
	
	# Finished casting and cooldown
	if elapsed_time >= current_spell.cast_time and cooldown_timer <= 0.0:
		# Check if button still held and we have resources
		if context.get("cast_primary", false):
			var spell_manager = mob.get_spell_manager()
			
			if spell_manager.can_cast(current_spell):
				# Restart cast
				elapsed_time = 0.0
				cooldown_timer = 0.0
				spell_manager.consume_resources(current_spell)
				print("Auto-repeat cast: %s" % current_spell.spell_name)
				return ""  # Stay in casting
		
		# Button released or no resources, return to idle
		return "ActionIdle"
	
	return ""


func set_spell(spell: SpellBase) -> void:
	current_spell = spell