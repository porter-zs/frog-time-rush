class_name CrocodileBiteState extends CharacterState

static var state_name: String = "CrocodileBiteState"

func get_state_name() -> String:
	return state_name

func _enter() -> void:
	actor.sprite.play("bite")
	
	await actor.sprite.animation_finished
	
	if actor.in_crocodile_bite_area():
		actor.player.state_machine.transition_state(PlayerDeathState.state_name)
	
	if is_instance_valid(actor):
		actor.state_machine.transition_state(ObstacleDriveState.state_name)

func _process(delta: float) -> void:
	if not is_instance_valid(actor):
		return
	
	actor._detect_obstacle()
	var movement: Vector2 = actor.direction * actor.speed * delta
	
	actor.global_position += movement

func _exit() -> void:
	actor.player = null
	actor.sprite.animation = "default"
