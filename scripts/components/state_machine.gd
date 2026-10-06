class_name StateMachine extends Node2D

@export var is_debugging: bool = false

var current_state: State
var states: Dictionary = {}
var parent_node_name: String

func state_machine(init_state: Array[State]) -> void:
	for state: State in init_state:
		states[state.get_state_name()] = state
	current_state = init_state[0]
	current_state._enter()
	
	log_state()

func log_state() -> void:
	if is_debugging:
		print("[%s]: Entering State, \"%s\"" % [parent_node_name, current_state.get_state_name()])

func _process(delta: float) -> void:
	current_state._process(delta)

func _physics_process(delta: float) -> void:
	current_state._physics_process(delta)

func transition_state(new_state_name: String) -> void:
	var new_state: State = states.get(new_state_name)
	
	if new_state == null:
		push_error("Transitioning to state (%s) failed as it does not exist.", % new_state_name)
	elif new_state != current_state:
		current_state._exit()
		log_state()
		current_state = states[new_state.get_state_name()]
		current_state._enter()
		log_state()
	else:
		return
