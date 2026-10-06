class_name FemaleFrog extends Collectable

var player: Player = null
var mounted_platform = null

@onready var current_lillies: int = GameManager.lillies
@onready var current_lives: int = GameManager.lives

func _ready() -> void:
	super()
	GameManager.lillies_changed.connect(func(value): _destroy_on_value_change("current_lillies", value))
	GameManager.lives_changed.connect(func(value): _destroy_on_value_change("current_lives", value))
	self.area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	if not is_instance_valid(mounted_platform):
		mounted_platform = null
	
	if is_instance_valid(mounted_platform):
		_apply_platform_movement(delta)
		mounted_platform._snap_character_to_slot(self)
	
	if attached and is_instance_valid(player):
		var offset: Vector2 = Vector2(0, -4)
		self.global_position = player.global_position + offset

func _destroy_on_value_change(var_name: String, new_value: int) -> void:
	var old_value: int = get(var_name)
	
	if not attached:
		set(var_name, new_value)
		return
	
	var destroy_con: bool = false
	if var_name == "current_lives":
		destroy_con = old_value > new_value
	elif var_name == "current_lillies":
		destroy_con = old_value < new_value
	
	if destroy_con:
		GameManager.female_frog_exists = false
		GameManager.female_attached = false
		_destroy_self()
	else:
		set(var_name, new_value)

func _apply_platform_movement(delta: float, target_position: Vector2 = Vector2.ZERO) -> Vector2:
	if mounted_platform:
		var mounted_platform_direction: Vector2 = mounted_platform.direction\
		 * mounted_platform.speed * delta
		
		self.global_position += mounted_platform_direction
		
		return target_position + mounted_platform_direction
	return target_position

func _on_area_entered(area: Node2D) -> void:
	if GameManager.female_attached:
		self.queue_free()
		return
	
	if area is Player and not attached:
		attached = true
		GameManager.female_attached = true
		player = area
		mounted_platform = null
		set_deferred("monitoring", false)
		set_deferred("monitorable", false)
