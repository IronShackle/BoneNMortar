# mob_base.gd
extends CharacterBody2D
class_name MobBase


@onready var movement_component: MovementComponent = $MovementComponent
@onready var movement_machine: StateMachine = $MovementMachine
@onready var action_machine: StateMachine = $ActionMachine


func _ready() -> void:
	_setup_movement_machine()
	_setup_action_machine()
	_setup_mob_specific()


# Subclasses override to provide their own context
func get_movement_context(_delta: float) -> Dictionary:
	return {}


func get_action_context(_delta: float) -> Dictionary:
	return {}


func _physics_process(delta: float) -> void:
	var movement_context = get_movement_context(delta)
	var action_context = get_action_context(delta)
	
	movement_machine.update(delta, movement_context)
	action_machine.update(delta, action_context)


# Virtual methods
func _setup_movement_machine() -> void:
	push_warning("MobBase._setup_movement_machine() not overridden")


func _setup_action_machine() -> void:
	push_warning("MobBase._setup_action_machine() not overridden")


func _setup_mob_specific() -> void:
	pass


# Public API
func get_movement_component() -> MovementComponent:
	return movement_component


func get_movement_machine() -> StateMachine:
	return movement_machine


func get_action_machine() -> StateMachine:
	return action_machine