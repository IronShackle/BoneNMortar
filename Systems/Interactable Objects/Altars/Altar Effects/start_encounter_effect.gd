# start_encounter_effect.gd
class_name StartEncounterEffect
extends AltarEffect

## Starts the wave encounter when altar is used


@export var wave_manager_path: NodePath


func execute(_player: Node2D) -> void:
	var wave_manager = get_node_or_null(wave_manager_path)
	
	if wave_manager and wave_manager.has_method("start_encounter"):
		wave_manager.start_encounter()
		print("Encounter started!")
	else:
		push_error("StartEncounterEffect: WaveManager not found at path!")