class_name ObstacleDriveState extends CharacterState

static var state_name: String  = "ObstacleDriveState"

func get_state_name() -> String:
	return state_name

func _physics_process(delta: float) -> void:
	if not is_instance_valid(actor):
		return
	
	actor._detect_obstacle()
	actor.global_position += actor.direction * actor.speed * delta
