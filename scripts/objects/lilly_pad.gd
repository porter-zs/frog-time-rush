class_name LillyPad extends Area2D

const LILLY_CAPTURED_SFX: AudioStreamWAV = preload("res://sound/get_lilly.wav")

@onready var sprite: Sprite2D = $LillySprite
@onready var gator_timer: Timer = $GatorTimer
@onready var animator: AnimationPlayer = $AnimationPlayer

@onready var gator_present_time: float = 5
@onready var is_gator_present: bool = false
@onready var is_frog_occupied: bool = false

func _ready() -> void:
	GameManager.lillies_changed.connect(_on_lilly_changed)
	gator_timer.timeout.connect(_on_gator_timeout)
	self.area_entered.connect(_on_area_entered)
	sprite.visible = false
	
	gator_timer.start(gator_present_time)

func _update_frog_occupied(new_value: bool = false) -> void:
	is_frog_occupied = new_value
	sprite.visible = new_value
	is_gator_present = false
	animator.play("RESET")
	
	var bonus_points: int = (700) if GameManager.female_attached else 200
	
	if new_value:
		GameManager.lillies += 1
		GameManager.add_points(bonus_points, LILLY_CAPTURED_SFX)
		GameManager.female_attached = false

func _on_lilly_changed(new_value: int) -> void:
	if new_value == 5:
		_update_frog_occupied(false)

func _on_area_entered(body: Node2D) -> void:
	if body is Player and not is_frog_occupied and not is_gator_present:
		_update_frog_occupied(true)
		body.reset_player()
	elif body is Player and (is_frog_occupied or is_gator_present):
		body.state_machine.transition_state(PlayerDeathState.state_name)

func _on_gator_timeout() -> void:
	if is_frog_occupied:
		return
	
	if is_gator_present:
		animator.play_backwards("gator_spawn")
		is_gator_present = false
	
	if randf() < 0.9:
		gator_timer.start(gator_present_time)
		return
	
	is_gator_present = true
	sprite.visible = true
	animator.play("gator_spawn")
	
	gator_timer.start(gator_present_time)
