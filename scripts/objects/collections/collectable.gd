class_name Collectable extends Area2D

const COLLECT_SFX: AudioStreamWAV = preload("res://sound/get_item.wav")

@onready var attached: bool = false
@onready var sprite: CanvasItem = $CharacterSprite
@onready var collect_scene: PackedScene = preload("res://objects/collections/collection_effect.tscn")

var points_awarded: int = 0

func _ready() -> void:
	_destroy_timeout()

func _destroy_timeout() -> void:
	await get_tree().create_timer(10).timeout
	
	if attached:
		return
	
	if self is FemaleFrog:
		GameManager.female_frog_exists = false
	
	_destroy_self()

func _destroy_self() -> void:
	_create_collect_effect()
	self.queue_free()

func _create_collect_effect() -> void:
	var collect_effect: CollectionEffect = collect_scene.instantiate()
	collect_effect.global_position = self.global_position
	GameManager.item_container.add_child(collect_effect)
	
func _add_bonus() -> void:
	_create_collect_effect()
	GameManager.add_points(points_awarded, COLLECT_SFX)
