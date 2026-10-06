class_name Fly extends Collectable

enum FLY_TYPE {
	RED,
	BLUE,
	GREEN,
	PURPLE,
	PINK,
	FIRE
}

var type: int = FLY_TYPE.RED

func _ready() -> void:
	super()
	self.area_entered.connect(_on_area_entered)

	if type == FLY_TYPE.RED:
		points_awarded = 25
		sprite.animation = "red"
	elif type == FLY_TYPE.BLUE:
		points_awarded = 50
		sprite.animation = "blue"
	elif type == FLY_TYPE.GREEN:
		points_awarded = 75
		sprite.animation = "green"
	elif type == FLY_TYPE.PURPLE:
		points_awarded = 100
		sprite.animation = "purple"
	elif type == FLY_TYPE.PINK:
		points_awarded = 150
		sprite.animation = "pink"
	elif type == FLY_TYPE.FIRE:
		points_awarded = 175
		sprite.animation = "fire"
	
	sprite.play()

func _on_area_entered(area: Node2D) -> void:
	if area is Player:
		_add_bonus()
		self.queue_free()
	return
