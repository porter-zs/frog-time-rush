extends Node

const GRID_SIZE: int = 16
const MAX_LIVES: int = 6
const GAME_SPEED_INCREMENT: float = 0.0025
const STAGE_TIME_LIMIT: int = 35
const MAX_LEADER_BOARD_SIZE: int  = 5
const START_POSITION: Vector2 = Vector2(200, 232)

const MAIN_MENU_SCENE: String = "res://scenes/main_menu.tscn"
const GAME_SCENE: String = "res://scenes/stage.tscn"
const HIGH_SCORE_SCENE: String = "res://scenes/high_score_screen.tscn"
const SAVE_PATH: String = "user://save_data.json"


var item_container: Node2D = null
var female_attached: bool = false
var female_frog_exists: bool = false

@export var game_speed: float = 1.0:
	set(value):
		game_speed = value
		game_speed_changed.emit(game_speed)

@export var score: int = 0:
	set(value):
		var base_score: int = value - score
		
		if base_score > 0:
			score = min(score + roundi(base_score * game_speed), 999_999_999)
		else:
			score = value
		
		score_changed.emit(score)

@export var lives: int = 3:
	set(value):
		lives = clamp(value, 0, MAX_LIVES)
		lives_changed.emit(lives)

@export var lillies: int = 0:
	set(value):
		lillies = clamp(value, 0, 5)
		lillies_changed.emit(lillies)

@export var high_scores: Array[Dictionary] = []

signal lives_changed(new_lives)
signal score_changed(new_score)
signal lillies_changed(new_lillies)
signal game_speed_changed(new_game_speed)
signal game_state_ready()
signal high_scores_changed()

func _ready() -> void:
	_load_scores()
	init_game_state()

func init_game_state() -> void:
	GameManager.lives = 3
	GameManager.score = 0
	GameManager.lillies = 0
	GameManager.game_speed = 1
	female_attached = false
	female_frog_exists = false
	var existing_container: Node2D = get_tree().get_first_node_in_group("Collections")
	
	if existing_container:
		item_container = existing_container
	else:
		item_container = Node2D.new()
		item_container.name = "ItemContainer"
		item_container.add_to_group("Collections")
		add_child(item_container)
	
	game_state_ready.emit()

func add_points(point_amt: int, sfx: AudioStream = null) -> void:
	if sfx:
		AudioManager.play_sfx(sfx)
	score += point_amt

func _is_high_score() -> bool:
	if score <= 0:
		return false
	if high_scores.size() < MAX_LEADER_BOARD_SIZE:
		return true
	return score > high_scores[-1]["score"]

func _high_score_list_updated(player_name: String) -> void:
	var new_score_entry = {
		"name": player_name,
		"score": self.score
	}
	
	high_scores.append(new_score_entry)
	high_scores.sort_custom(func(a, b): 
		var score_a = a.get("score", 0)
		var score_b = b.get("score", 0)
		return score_a > score_b
	)
	
	if high_scores.size() > MAX_LEADER_BOARD_SIZE:
		high_scores.resize(MAX_LEADER_BOARD_SIZE)
	
	high_scores_changed.emit()
	_save_scores()
	
	ScreenTransition.transition_to_room(GameManager.MAIN_MENU_SCENE)

func _save_scores() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	
	if file:
		var json_string: String = JSON.stringify(high_scores)
		file.store_string(json_string)

func _load_scores() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		if file.get_length() == 0:
			return
		
		var json_string: String = file.get_as_text()
		var json: JSON = JSON.new()
		var error: Error = json.parse(json_string)
		
		if error == OK:
			if json.data is Array:
				high_scores.assign(json.data)
