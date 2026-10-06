class_name State extends Node2D

func _ready() -> void:
	pass

func _enter() -> void:
	pass

func _exit() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func _physics_process(_delta: float) -> void:
	pass

func get_state_name() -> String:
	push_error("Method get_state_name() must be defined.")
	return ""
