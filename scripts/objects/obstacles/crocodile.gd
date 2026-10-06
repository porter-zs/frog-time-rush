class_name Crocodile extends MountableObstacle

var player: Player = null

func _ready() -> void:
	super()
	
	var states: Array[State] = [
		ObstacleDriveState.new(self),
		CrocodileBiteState.new(self)
	]
	
	state_machine.state_machine(states)
	sprite.play("default")

func _process(_delta: float) -> void:
	if in_crocodile_bite_area():
		state_machine.transition_state(CrocodileBiteState.state_name)

func in_crocodile_bite_area() -> bool:
	if actors_attached.is_empty():
		return false
	
	for actor in actors_attached:
		if actor is Player:
			player = actor
			break
	
	if player == null or not is_instance_valid(player):
		return false
	
	var relative_x: float = player.global_position.x\
	 - self.global_position.x
	var snapped_slot_x: float = round(relative_x /\
	 GameManager.GRID_SIZE) * GameManager.GRID_SIZE
	var bite_slot_area: float = -GameManager.GRID_SIZE\
	if direction == Vector2.LEFT else GameManager.GRID_SIZE
	
	return snapped_slot_x == bite_slot_area
