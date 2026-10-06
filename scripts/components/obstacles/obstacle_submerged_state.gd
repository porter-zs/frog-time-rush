class_name ObstacleSubmergedState extends CharacterState

static var state_name: String  = "ObstacleSubmergedState"

func get_state_name() -> String:
	return state_name

func _enter() -> void:
	if is_instance_valid(actor.actors_attached):
		actor.actors_attached.clear()
		for rider in actor.actors_attached:
			rider.mountable_platform = null
	
	var wait_time: float = randf_range(0.5, 1)
	await actor.get_tree().create_timer(wait_time).timeout
	
	if is_instance_valid(actor):
		actor._surface()
		actor.state_machine.transition_state(ObstacleDriveState.state_name)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(actor):
		return
	
	actor._detect_obstacle()
	var movement: Vector2 = actor.direction * actor.speed * delta
	
	actor.global_position += movement
