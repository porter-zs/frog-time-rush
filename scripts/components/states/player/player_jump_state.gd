class_name PlayerJumpState extends CharacterState

static var state_name: String = "PlayerJumpState"

var next_position: Vector2 = Vector2.ZERO
var grid_time: float = 16.0 * GameManager.game_speed

func get_state_name() -> String:
	return state_name

func _enter() -> void:
	actor.is_moving = false
	next_position = actor.global_position
	_snap_to_tilemap_grid()
	
	if InputController.get_key_press_up():
		_handle_movement("forward_leap", Vector2.UP)
	elif InputController.get_key_press_down():
		_handle_movement("backward_leap", Vector2.DOWN)
	elif InputController.get_key_press_left():
		actor.sprite.flip_h = true
		_handle_movement("sideway_leap", Vector2.LEFT)
	elif InputController.get_key_press_right():
		actor.sprite.flip_h = false
		_handle_movement("sideway_leap", Vector2.RIGHT)
	
	if _is_jumpable_tile(next_position):
		actor.is_moving = true
	else:
		state_machine.transition_state(PlayerIdleState.state_name)

func _process(delta: float) -> void:
	next_position = actor._apply_platform_movement(delta, next_position)
	
	if actor.is_moving:
		actor.global_position = actor.global_position.lerp(next_position, grid_time * delta)
		if actor.global_position.distance_to(next_position) < 1.0:
			actor.global_position = next_position
			state_machine.transition_state(PlayerIdleState.state_name)
	else:
		state_machine.transition_state(PlayerIdleState.state_name)

func _handle_movement(anime_name: String, target_direction: Vector2) -> void:
	actor.sprite.play(anime_name)
	GameManager.add_points(10, actor.JUMP_SFX)
	InputController.previous_direction = target_direction
	next_position = actor.global_position + (target_direction * GameManager.GRID_SIZE)

func _snap_to_tilemap_grid() -> void:
	if actor.mounted_platform == null:
		var half_cell: Vector2 = Vector2(GameManager.GRID_SIZE\
		 / 2.0, GameManager.GRID_SIZE / 2.0)
		actor.global_position = (actor.global_position - half_cell)\
		.snapped(Vector2(GameManager.GRID_SIZE, GameManager.GRID_SIZE)) + half_cell

func _is_jumpable_tile(target_position: Vector2) -> bool:
	if not actor.tilemap:
		return true
	
	var tile_coord: Vector2i = actor.tilemap.\
	local_to_map(actor.tilemap.to_local(target_position))
	var tile_data: TileData = actor.tilemap.get_cell_tile_data(tile_coord)
	
	if not tile_data:
		return true
	
	return not tile_data.get_custom_data("solid")
