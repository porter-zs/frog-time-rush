class_name Snake extends Obstacle

func _ready() -> void:
	super()
	detect_obstacles.enabled = false
	self.area_entered.connect(_on_hitbox_area_entered)

	var states: Array[State] = [
		ObstacleDriveState.new(self)
	]
	
	state_machine.state_machine(states)

func _on_hitbox_area_entered(body: Node2D) -> void:
	if body is Player:
		body.state_machine.transition_state(PlayerDeathState.state_name)
