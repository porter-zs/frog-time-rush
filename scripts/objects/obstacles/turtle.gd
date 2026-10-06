class_name Turtle extends MountableObstacle

var is_submerged: bool = false
var submerge_timer: Timer

@onready var submerged_timer_min: float = 4.0
@onready var submerged_timer_max: float = 6.0

func _ready() -> void:
	super()
	
	var states: Array[State] = [
		ObstacleDriveState.new(self),
		ObstacleSubmergedState.new(self)
	]
	
	state_machine.state_machine(states)
	sprite.play("default")
	submerge_timer = $SubmergeTimer
	submerge_timer.timeout.connect(_on_submerge_timeout)
	_reset_submerge_timer()

func _submerge() -> void:
	is_submerged = true
	sprite.play("submerge")
	
	await sprite.animation_finished
	
	if is_submerged:
		_set_sprite_and_monitoring(false)
		state_machine.transition_state(ObstacleSubmergedState.state_name)

func _surface() -> void:
	is_submerged = false
	_set_sprite_and_monitoring(true)
	
	if not is_submerged:
		sprite.play_backwards("submerge")
		await sprite.animation_finished
		sprite.play("default", -1, 1.0)
		_reset_submerge_timer()

func _set_sprite_and_monitoring(new_value: bool) -> void:
	sprite.visible = new_value
	self.monitoring = new_value

func _reset_submerge_timer() -> void:
	submerge_timer.start(randf_range(submerged_timer_min, submerged_timer_max))

func _on_submerge_timeout() -> void:
	_submerge()
