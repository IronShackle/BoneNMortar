extends Node
## Simple test script demonstrating HealthComponent usage
## Attach this to any Node in a test scene with a MobBase child to test

@export var mob_to_test: MobBase

func _ready() -> void:
	if not mob_to_test:
		print("No mob assigned to test!")
		return

	var health = mob_to_test.get_health_component()
	if not health:
		print("Mob has no HealthComponent!")
		return

	# Connect to signals to observe behavior
	health.health_changed.connect(_on_health_changed)
	health.life_lost.connect(_on_life_lost)
	health.life_gained.connect(_on_life_gained)
	health.died.connect(_on_died)

	print("\n=== HealthComponent Test Starting ===")
	print("Initial health: ", health.current_health, "/", health.max_health)
	print("Health percent: ", health.get_health_percent() * 100, "%")
	print("Is alive: ", health.is_alive())

	# Test 1: Basic damage
	print("\n--- Test 1: Basic Damage ---")
	health.lose_life(25.0)

	# Test 2: Healing
	print("\n--- Test 2: Healing ---")
	health.gain_life(10.0)

	# Test 3: Apply DoT
	print("\n--- Test 3: Damage Over Time ---")
	print("Applying DoT: 5 damage per tick for 6 seconds")
	health.apply_dot(5.0, 6.0, self)

	# Test 4: Multiple DoTs stack
	await get_tree().create_timer(2.0).timeout
	print("\n--- Test 4: Stacking DoT ---")
	print("Adding second DoT: 3 damage per tick for 4 seconds")
	health.apply_dot(3.0, 4.0, null)

	# Test 5: Clear DoTs from source
	await get_tree().create_timer(3.0).timeout
	print("\n--- Test 5: Clear DoT from specific source ---")
	health.clear_dots_from_source(self)

	# Test 6: Fatal damage
	await get_tree().create_timer(2.0).timeout
	print("\n--- Test 6: Fatal Damage ---")
	health.lose_life(1000.0)  # Overkill

	print("\n=== Test Complete ===")


func _on_health_changed(old_value: float, new_value: float) -> void:
	print("  [SIGNAL] health_changed: ", old_value, " -> ", new_value)


func _on_life_lost(amount: float, source: Node) -> void:
	var source_name = source.name if source else "unknown"
	print("  [SIGNAL] life_lost: ", amount, " from ", source_name)


func _on_life_gained(amount: float) -> void:
	print("  [SIGNAL] life_gained: ", amount)


func _on_died() -> void:
	print("  [SIGNAL] died! Entity is no more.")
