class_name HUD extends Control

@onready var time_label: Label = $TimeLabel
@onready var score_label: Label = $ScoreLabel
@onready var stage_timer: Timer = $"../StageTimer"
@onready var lives_container: HBoxContainer = $LivesContainer

@onready var lives_icon: PackedScene = preload("res://objects/game/player_lives_icon.tscn")

func _ready() -> void:
	GameManager.score_changed.connect(_update_score_label)
	GameManager.lives_changed.connect(_update_lives_count_display)
	
	_update_score_label(GameManager.score)
	_update_time_label()
	_update_lives_count_display(GameManager.lives)

func _process(_delta: float) -> void:
	_update_time_label()

func _update_score_label(new_score: int) -> void:
	score_label.text = str(new_score).lpad(9, "0")

func _update_time_label() -> void:
	time_label.text = "time left\n%05.2f" % stage_timer.time_left

func _update_lives_count_display(lives: int) -> void:
	for child in lives_container.get_children():
		lives_container.remove_child(child)
		child.queue_free()
	
	for live in range(lives - 1):
		var new_icon: TextureRect = lives_icon.instantiate()
		lives_container.add_child(new_icon)
