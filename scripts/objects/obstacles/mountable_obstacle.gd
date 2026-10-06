class_name MountableObstacle extends Obstacle

const GAME_MUSIC: AudioStreamMP3 = preload("res://sound/JDSherbert_AMP_junction_jazz.mp3")
var actors_attached: Array[Object] = []

var item_container: Node2D
@export var female_frog_scene: PackedScene

func _ready() -> void:
	super()
	AudioManager.play_music(GAME_MUSIC)
	self.area_entered.connect(_on_detect_area_entered)
	self.area_exited.connect(_on_detect_area_exited)
	item_container = get_tree().get_first_node_in_group("Collections")
	var states: Array[State] = [
		ObstacleDriveState.new(self)
	]
	
	state_machine.state_machine(states)
	_spawn_female_chance()

func _process(_delta: float) -> void:
	if state_machine.current_state != ObstacleDriveState:
		state_machine.transition_state(ObstacleDriveState.state_name)

func _snap_character_to_slot(actor: Object) -> void:
	var relative_position: Vector2 = actor.global_position - self.global_position
	var snap_y: float = 0.0
	var snap_x: float = round(relative_position.x /\
	 GameManager.GRID_SIZE) * GameManager.GRID_SIZE
	
	snap_x = clamp(snap_x, -GameManager.GRID_SIZE, GameManager.GRID_SIZE)
	actor.global_position = self.global_position + Vector2(snap_x, snap_y)

func _switch_obstacle_buffer(actor: Object) -> void:
	await get_tree().create_timer(0.02).timeout
	
	if actor.mounted_platform == self:
		actor.mounted_platform = null

func _spawn_female_chance() -> void:
	if randf() < 0.99 or GameManager.female_frog_exists:
		return
	
	GameManager.female_frog_exists = true
	var female: FemaleFrog = female_frog_scene.instantiate()
	item_container.add_child(female)
	
	var grid_slots: Array[float] = [
		-GameManager.GRID_SIZE, 
		0.0,
		GameManager.GRID_SIZE
		]
	var random_slot_x: float = grid_slots.pick_random()
	female.global_position = self.global_position + Vector2(random_slot_x, 0.0)
	female.mounted_platform = self

func _on_detect_area_entered(body: Node2D) -> void:
	if body is not Player:
		return
	
	if body.mounted_platform and body.mounted_platform != self:
		body.mounted_platform.actors_attached.erase(body)
	
	if not body in actors_attached:
		actors_attached.append(body)
	
	body.mounted_platform = self

func _on_detect_area_exited(body: Node2D) -> void:
	if body not in actors_attached:
		return
	
	actors_attached.erase(body)
	_switch_obstacle_buffer(body)
