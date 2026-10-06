class_name Player extends Area2D

const JUMP_SFX: AudioStreamWAV = preload("res://sound/player_leap.wav")

var can_move: bool = true
var is_moving: bool = false
var state_machine: StateMachine 
var mounted_platform: MountableObstacle = null

@export var tilemap: TileMapLayer = null
@export var start_position: Vector2 = GameManager.START_POSITION

@onready var sprite: AnimatedSprite2D = $CharacterSprite

func _ready() -> void:
	state_machine = StateMachine.new()
	self.add_child(state_machine)
	
	var states: Array[State] = [
		PlayerIdleState.new(self),
		PlayerJumpState.new(self),
		PlayerDeathState.new(self)
	]
	
	state_machine.state_machine(states)

func _process(_delta: float) -> void:
	var current_state_name = state_machine.current_state.get_state_name()
	if current_state_name == "PlayerDeathState" or not can_move:
		return
	
	if not is_instance_valid(mounted_platform):
		mounted_platform = null
	
	if _is_lethal_zone_tile(self.global_position) and mounted_platform == null:
		state_machine.transition_state(PlayerDeathState.state_name)
	elif InputController.get_move_key_press():
		state_machine.transition_state(PlayerJumpState.state_name)
	
	_off_screen_death()

func _is_lethal_zone_tile(given_coord: Vector2) -> bool:
	if not tilemap:
		return false
	
	var tile_coord: Vector2i = tilemap.local_to_map(tilemap.to_local(given_coord))
	var tile_data: TileData = tilemap.get_cell_tile_data(tile_coord)
	
	if not tile_data or mounted_platform:
		return false
	
	return tile_data.get_custom_data("lethal")

func _apply_platform_movement(delta: float, target_position: Vector2 = Vector2.ZERO) -> Vector2:
	if mounted_platform:
		var mounted_platform_direction: Vector2 = mounted_platform.direction\
		 * mounted_platform.speed * delta
		
		self.global_position += mounted_platform_direction
		
		return target_position + mounted_platform_direction
	return target_position

func reset_player() -> void:
	self.global_position = start_position
	mounted_platform = null
	InputController.previous_direction = Vector2.UP
	state_machine.transition_state(PlayerIdleState.state_name)

func _off_screen_death() -> void:
	var viewport_width: float = get_viewport_rect().size.x
	var viewport_height: float = get_viewport_rect().size.y

	if self.global_position.x < 0 or\
	 self.global_position.x > viewport_width or\
	self.global_position.y < 0 or\
	 self.global_position.y > viewport_height - 32:
		state_machine.transition_state(PlayerDeathState.state_name)
