class_name StateMachine
extends Node

@export var initial_state: State
var states: Dictionary = {}
var current_state: State


func _ready() -> void:
	# assign states to children of StateMachine
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transition.connect(transition_to)
	
	# assign and enter initial state
	if initial_state:
		initial_state.enter()
		current_state = initial_state


# call processes of current state
func _process(delta: float) -> void:
	if current_state:
		current_state.on_process(delta)


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.on_physics_process(delta)


# transition to a new state by node name
func transition_to(new_state_name: String) -> void:
	var new_state: State = states.get(new_state_name.to_lower())
	
	# case checks
	if !new_state:
		print(name + ": " + new_state_name + " does not exist in the dictionary of states")
		return
	
	if new_state == current_state:
		print(name + ": " + new_state_name + " is already the current state")
		return
	
	# update current state, call enter and exit functions
	if current_state:
		current_state.exit()
	
	new_state.enter()
	current_state = new_state
	
	print("State: " + new_state_name)
