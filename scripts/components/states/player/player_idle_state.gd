class_name PlayerIdleState extends CharacterState

static var state_name: String = "PlayerIdleState"

func get_state_name() -> String:
	return state_name

func _enter() -> void:
	actor.is_moving = false
	_animate_sprite()
	if actor.mounted_platform:
		actor.mounted_platform._snap_character_to_slot(actor)

func _process(delta: float) -> void:
	actor._apply_platform_movement(delta)

func _animate_sprite() -> void:
	if InputController.previous_direction == Vector2.UP:
		actor.sprite.play("forward_idle")
	elif InputController.previous_direction == Vector2.DOWN:
		actor.sprite.play("backward_idle")
	elif InputController.previous_direction == Vector2.LEFT:
		actor.sprite.flip_h = true
		actor.sprite.play("sideway_idle")
	elif InputController.previous_direction == Vector2.RIGHT:
		actor.sprite.flip_h = false
		actor.sprite.play("sideway_idle")
