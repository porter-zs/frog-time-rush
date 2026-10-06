class_name Obstacle extends Area2D

const DELETE_BUFFER_SPACE: int = 32

var direction: Vector2 = Vector2.LEFT

@export var speed: float = 100.0

@onready var state_machine: StateMachine
@onready var sprite: CanvasItem = $CharacterSprite
@onready var detect_obstacles: RayCast2D = $DetectObstacles

func _ready() -> void:
	state_machine = StateMachine.new()
	self.add_child(state_machine)
	speed = speed * GameManager.game_speed

	sprite.flip_h = false if direction == Vector2.LEFT else true
	
	if is_instance_valid(detect_obstacles):
		var cast_distance = abs(detect_obstacles.target_position.x)
		detect_obstacles.target_position.x = -cast_distance\
		 if direction == Vector2.LEFT else cast_distance

func _process(_delta: float) -> void:
	var viewport_width: float = get_viewport_rect().size.x
	
	if self.global_position.x < -DELETE_BUFFER_SPACE or\
	 self.global_position.x > viewport_width + DELETE_BUFFER_SPACE:
		self.queue_free()

func _detect_obstacle() -> void:
	if not detect_obstacles or not detect_obstacles.enabled:
		return
	
	if detect_obstacles.is_colliding() and\
	 detect_obstacles.get_collider() is Obstacle:
		var tailing: Obstacle = detect_obstacles.get_collider()
		
		speed = tailing.speed
