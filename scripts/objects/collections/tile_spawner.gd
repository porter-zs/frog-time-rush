class_name TileBasedSpawner extends Node2D

var timer_min: float = 5.0
var timer_max: float = 10.0

@export var fly_scene: PackedScene
@export var item_container: Node2D
@export var tilemap: TileMapLayer = null
@export var top_left_tile: Vector2i = Vector2i.ZERO
@export var bottom_right_tile: Vector2i = Vector2i.ZERO

@onready var spawn_timer: Timer = $SpawnTimer

func _ready() -> void:
	spawn_timer.timeout.connect(_spawn_on_random_tile)
	spawn_timer.start(randf_range(timer_min, timer_max))

func _delay_spawn() -> void:
	if not is_instance_valid(GameManager.item_container):
		await GameManager.game_state_ready
	
	await get_tree().physics_frame
	spawn_timer.start(randf_range(timer_min, timer_max))
	_spawn_on_random_tile()

func _spawn_on_random_tile() -> void:
	if not is_instance_valid(tilemap) or not is_instance_valid(GameManager.item_container):
		spawn_timer.start(randf_range(timer_min, timer_max))
		return
	
	if randf() < 0.5:
		spawn_timer.start(randf_range(timer_min, timer_max))
		return
	
	var drawn_cells: Array[Vector2i] = tilemap.get_used_cells()
	var valid_tiles: Array[Vector2i] = drawn_cells.filter(
		func(tile_coord: Vector2i) -> bool:
			var tile_data: TileData = tilemap.get_cell_tile_data(tile_coord)
			if tile_data == null:
				return false
			var has_item_data = tile_data.get_custom_data("item")
			return typeof(has_item_data) == TYPE_BOOL and has_item_data
			)

	if not valid_tiles.is_empty():
		var random_tile_coord: Vector2i = valid_tiles.pick_random()
		var tile_local_position = tilemap.map_to_local(random_tile_coord)
		var tile_global_position = tilemap.to_global(tile_local_position)
		
		var new_fly: Fly = fly_scene.instantiate()
		new_fly.global_position = tile_global_position
		new_fly.type = randi_range(0, new_fly.FLY_TYPE.size() - 1)
		item_container.add_child(new_fly)
	
	spawn_timer.start(randf_range(timer_min, timer_max))
