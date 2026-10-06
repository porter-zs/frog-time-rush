class_name Spawner extends Node2D


@export var spawn_interval_min: float = 1
@export var spawn_interval_max: float = 3
@export var obstacle_scenes: Array[PackedScene] = []
@export_enum("LEFT", "RIGHT") var drive_direction: String = "LEFT"

@onready var spawn_timer: Timer = $SpawnTimer

@export var obstacle_container: Node2D

func _ready() -> void:
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	_spawn_obstacle()
	spawn_timer.start(randf_range(spawn_interval_min, spawn_interval_max))

func _spawn_obstacle() -> void:
	if obstacle_scenes.is_empty() or not obstacle_container:
		return
	
	if randf() < 0.05:
		return
	
	var random_obstacle_scene: PackedScene = obstacle_scenes.pick_random()
	var new_obstacle: Obstacle = random_obstacle_scene.instantiate()
	var obstacle_direction: Vector2 = Vector2.LEFT if\
	drive_direction == "LEFT" else Vector2.RIGHT
	
	new_obstacle.direction = obstacle_direction
	new_obstacle.global_position = self.global_position
	obstacle_container.add_child(new_obstacle)

func _on_spawn_timer_timeout() -> void:
	_spawn_obstacle()
	spawn_timer.start(randf_range(spawn_interval_min, spawn_interval_max))
