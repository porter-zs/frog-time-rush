class_name MainMenu extends CanvasLayer

const SELECT_SFX: AudioStreamWAV = preload("res://sound/select.wav")
const KEY_SWITCH: AudioStreamWAV = preload("res://sound/navigation.wav")

@onready var credits_button: Button = $CreditsButton
@onready var game_title: TextureRect = $Title
@onready var player_score_label: Label = $PlayerScore
@onready var credits_popup: PanelContainer = $CreditsPopup
@onready var high_score_container: VBoxContainer = $HighScoreContainer/MarginContainer/HighScores
@onready var high_score_label_scene: PackedScene = preload("res://objects/game/high_score_box.tscn")

var credits_toggled: bool = false

func _ready() -> void:
	credits_button.grab_focus()
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	GameManager.score_changed.connect(_update_player_score_label)
	credits_button.focus_entered.connect(func():\
		AudioManager.play_sfx(KEY_SWITCH, Vector2(1.0, 1.0)))
	credits_popup.visible = false
	player_score_label.visible = false if GameManager.score == 0 else true
	
	_display_high_score()
	_start_label_animation()
	_update_player_score_label(GameManager.score)

func _unhandled_input(_event: InputEvent) -> void:
	if InputController.get_key_press_start():
		ScreenTransition.transition_to_room(GameManager.GAME_SCENE)
	
	if InputController.get_key_press_interact():
		if credits_button.has_focus():
			if not credits_popup.visible:
				AudioManager.play_sfx(SELECT_SFX, Vector2(1.0,1.0))
			credits_popup.visible = not credits_popup.visible

func _display_high_score() -> void:
	GameManager._load_scores()
	
	for record in GameManager.high_scores:
		var high_score: HighScoreBox = high_score_label_scene.instantiate()
		high_score_container.add_child(high_score)
		high_score.name_label.text = record.name
		high_score.value_label.text = str(record.score).lpad(9, "0")

func _update_player_score_label(new_value: int) -> void:
	if new_value > 0:
		player_score_label.text = "your score: " + str(GameManager.score).lpad(9, "0")

func _start_label_animation() -> void:
	var tween: Tween = create_tween()
	tween.set_loops()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(game_title, "rotation_degrees", -1.0, 2.5)
	tween.tween_property(game_title, "rotation_degrees", 1.0, 2.5)
