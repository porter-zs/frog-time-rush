extends Node

var previous_direction: Vector2 = Vector2.UP

func get_move_key_press() -> bool:
	if get_key_press_down() or get_key_press_up()\
	or get_key_press_left() or get_key_press_right():
		return true
	return false

func get_key_press_up() -> bool:
	if Input.is_action_just_pressed("up"):
		return true
	else:
		return false

func get_key_press_down() -> bool:
	if Input.is_action_just_pressed("down"):
		return true
	else:
		return false

func get_key_press_left() -> bool:
	if Input.is_action_just_pressed("left"):
		return true
	else:
		return false

func get_key_press_right() -> bool:
	if Input.is_action_just_pressed("right"):
		return true
	else:
		return false

func get_key_press_select() -> bool:
	if Input.is_action_just_pressed("select"):
		return true
	else:
		return false

func get_key_press_start() -> bool:
	if Input.is_action_just_pressed("start"):
		return true
	else:
		return false

func get_key_press_interact() -> bool:
	if Input.is_action_just_pressed("interact"):
		return true
	else:
		return false
