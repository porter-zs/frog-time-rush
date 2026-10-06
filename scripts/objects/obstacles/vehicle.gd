class_name Vehicle extends Obstacle

var tween: Tween = null

func _ready() -> void:
	super()
	self.area_entered.connect(_on_hitbox_area_entered)
	
	self._squash_and_stretch()
	
	var max_frame: int = (sprite.hframes * sprite.vframes) - 1
	sprite.frame = randi_range(0, max_frame)
	
	var states: Array[State] = [
		ObstacleDriveState.new(self)
	]
	
	state_machine.state_machine(states)

func _squash_and_stretch() -> void:
	if tween and tween.is_valid():
		tween.kill()
	
	tween = create_tween()
	tween.set_loops()
	
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.5)
	tween.tween_property(sprite, "scale", Vector2(1.05, 0.8), 0.1)
	tween.tween_property(sprite, "scale", Vector2(0.95, 1.05), 0.1)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.15).set_ease(Tween.EASE_IN)

func _on_hitbox_area_entered(body: Node2D) -> void:
	if body is Player:
		body.state_machine.transition_state(PlayerDeathState.state_name)
