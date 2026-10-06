class_name MainGameLoop extends Node2D

const START_TIME: float = 1.5
const WHISTLE_BLOW_COUNT_SFX: AudioStreamWAV = preload("res://sound/count_down_whistle_blow.wav")
const WHISTLE_BLOW_START_SFX: AudioStreamWAV = preload("res://sound/start_whistle_blow.wav")
const GET_ITEM: AudioStreamWAV = preload("res://sound/get_item.wav")

var total_clears: int = 0

@onready var base_tiles: Array[TileMapLayer] = [$BaseLevel, $BaseDoodad]
@onready var winter_tiles: Array[TileMapLayer] = [$WinterLevel, $WinterDoodad]
@onready var cave_tiles: Array[TileMapLayer] = [$CaveLevel, $CaveDoodad]
@onready var tilesets: Array = []

@onready var stage_timer: Timer = $StageTimer
@onready var ready_text: TextureRect = $StageText/Control/ReadyText
@onready var start_text: TextureRect = $StageText/Control/StartText
@onready var game_over_text: TextureRect = $StageText/Control/GameOverText

var player: Player = null
var is_game_over: bool = false

func _ready() -> void:
	total_clears = 0
	is_game_over = false
	tilesets = [base_tiles, winter_tiles, cave_tiles]
	GameManager.init_game_state()
	var container = get_tree().get_first_node_in_group("Collections")
	
	if container:
		GameManager.item_container = container
	
	var obstacles = get_tree().get_nodes_in_group("Obstacles") # Ensure your obstacles are in this group!
	for obstacle in obstacles:
		if obstacle.has_method("_spawn_female_chance"):
			obstacle._spawn_female_chance()
	GameManager.lillies_changed.connect(_on_lillies_changed)
	GameManager.lives_changed.connect(_on_lives_changed)
	GameManager.score_changed.connect(_on_score_changed_oneup)
	
	stage_timer.timeout.connect(_on_stage_timeout)
	player = get_tree().get_first_node_in_group("Player")
	
	if player:
		player.can_move = false
	
	start_text.visible = false
	game_over_text.visible = false
	_scale_up_text_image(ready_text, 0.8)
	AudioManager.play_sfx(WHISTLE_BLOW_COUNT_SFX, Vector2(1,1))
	await get_tree().create_timer(START_TIME).timeout
	_start_game()

func _swap_tileset(target_index: int) -> void:
	for index in range(tilesets.size()):
		var current_tileset: Array[TileMapLayer] = tilesets[index]
		var visible_toggle: bool = index == target_index
		
		for layer in current_tileset:
			layer.visible = visible_toggle

func _game_victory() -> void:
	if total_clears % 5 == 0:
		GameManager.game_speed += GameManager.GAME_SPEED_INCREMENT
	total_clears += 1
	
	if total_clears % 5 == 0:
		var random_theme: int = randi() % tilesets.size()
		_swap_tileset(random_theme)

func _game_over() -> void:
	is_game_over = true
	stage_timer.stop()
	
	if player:
		player.can_move = false
	
	_scale_up_text_image(game_over_text, 0.8)
	await get_tree().create_timer(1.5).timeout
	
	if GameManager._is_high_score():
		ScreenTransition.transition_to_room(GameManager.HIGH_SCORE_SCENE)
		return
	else:
		ScreenTransition.transition_to_room(GameManager.MAIN_MENU_SCENE)
		return

func _start_game() -> void:
	ready_text.visible = false
	
	AudioManager.play_sfx(WHISTLE_BLOW_START_SFX, Vector2(1,1))
	stage_timer.start(GameManager.STAGE_TIME_LIMIT)
	_scale_up_text_image(start_text, 0.8)
	await get_tree().create_timer(0.5).timeout
	
	if player:
		player.can_move = true
	start_text.visible = false

func _scale_up_text_image(label: TextureRect, duration: float) -> void:
	label.pivot_offset = label.size / 2.0
	label.scale = Vector2.ZERO
	label.visible = true
	
	var tween = create_tween()
	tween.tween_property(label, "scale", Vector2.ONE, duration)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)

func _on_stage_timeout() -> void:
	if player:
		player.state_machine.transition_state(PlayerDeathState.state_name)
		await player.sprite.animation_finished
	
	if not is_game_over:
		stage_timer.start(GameManager.STAGE_TIME_LIMIT)

func _on_score_changed_oneup(new_value) -> void:
	if new_value % 20_000 == 0:
		GameManager.lives += 1
		AudioManager.play_sfx(GET_ITEM)
	else:
		return

func _on_lillies_changed(new_value: int) -> void:
	if new_value < 5:
		stage_timer.start(GameManager.STAGE_TIME_LIMIT)
	elif new_value == 5:
		GameManager.add_points(2000)
		GameManager.lillies = 0
		_game_victory()

func _on_lives_changed(new_value: int) -> void:
	stage_timer.start(GameManager.STAGE_TIME_LIMIT)
	
	if new_value <= 0:
		_game_over()
