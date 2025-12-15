# healing_effect.gd (example)
class_name HealingEffect
extends AltarEffect

## Heals the player when used


@export var heal_amount: float = 50.0


func execute(player: Node2D) -> void:
	var health = player.get_node_or_null("HealthComponent")
	
	if health and health is HealthComponent:
		health.gain_life(heal_amount)
		print("Healed player for %d HP" % heal_amount)