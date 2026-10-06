class_name HighScoreScreen extends CanvasLayer

const MAX_INITIALS: int = 3
const ALPHABET: String = "abcdefghijklmnopqrstuvwxyz<."
const KEY_PRESS_SFX: AudioStreamWAV = preload("res://sound/select.wav")
const KEY_SWITCH: AudioStreamWAV = preload("res://sound/navigation.wav")

var selected_index: int = 0
var current_initials: String = ""

@onready var title_label = $Title
@onready var button_grid: Array[Button] = []
@onready var button_scene: PackedScene = preload("res://objects/game/button.tscn")
@onready var player_score_label: Label = $Control/PlayeScoreValue
@onready var entered_name_label: Label = $Control/PlayerInitials
@onready var alphabet_container: GridContainer = $Control/MarginContainer/VBoxContainer/GridContainer

func _ready() -> void:
	entered_name_label.text = "".rpad(3, "_")
	player_score_label.text = "score\n%09d" % GameManager.score
	_generate_alpha_key()
	_title_label_animation()

func _title_label_animation() -> void:
	var tween: Tween = create_tween()
	tween.set_loops()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(title_label, "rotation_degrees", -2.0, 2.5)
	tween.tween_property(title_label, "rotation_degrees", 2.0, 2.5)

func _generate_alpha_key() -> void:
	for letter in ALPHABET:
		var button: Button = button_scene.instantiate()
		
		button.text = letter
		button.focus_mode = Control.FOCUS_ALL
		button.focus_entered.connect(func():\
		AudioManager.play_sfx(KEY_SWITCH, Vector2(1.0, 1.0)))
		alphabet_container.add_child(button)
		button_grid.append(button)
	
	if not button_grid.is_empty():
		button_grid[0].grab_focus()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		var focused_node = get_viewport().gui_get_focus_owner()
		AudioManager.play_sfx(KEY_PRESS_SFX)
		
		if focused_node is Button and focused_node in button_grid:
			_handle_key_select(focused_node.text)
	elif event.is_action_pressed("select"):
		ScreenTransition.transition_to_room(GameManager.MAIN_MENU_SCENE)

func _handle_key_select(given_char: String) -> void:
	if given_char == "<":
		if current_initials.length() > 0:
			current_initials = current_initials.substr(0, current_initials.length() - 1)
	elif given_char == ".":
		if current_initials.length() > 0:
			_handle_submit()
	else:
		if current_initials.length() < MAX_INITIALS:
			current_initials += given_char
	
	_update_display_label()

func _update_display_label() -> void:
	entered_name_label.text = current_initials.rpad(3, "_")
	
	if current_initials.length() == MAX_INITIALS:
		_handle_submit()

func _handle_submit() -> void:
	GameManager._high_score_list_updated(current_initials)
