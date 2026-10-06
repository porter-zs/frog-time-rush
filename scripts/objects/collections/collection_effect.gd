class_name CollectionEffect extends AnimatedSprite2D

func _ready() -> void:
	_start_timer()

func _start_timer() -> void:
	await self.animation_finished
	self.queue_free()
