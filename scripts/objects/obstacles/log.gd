class_name Log extends MountableObstacle

func _ready() -> void:
	super()
	speed = speed * GameManager.game_speed
	
	var states: Array[State] = [
		ObstacleDriveState.new(self)
	]
	
	state_machine.state_machine(states)
