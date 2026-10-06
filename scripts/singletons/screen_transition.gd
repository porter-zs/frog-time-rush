extends CanvasLayer

@onready var colour_rect: ColorRect = $ColorRect
@onready var animator: AnimationPlayer = $AnimationPlayer

func transition_to_room(target_scene_path: String) -> void:
	animator.play("transition")
	await animator.animation_finished
	
	get_tree().change_scene_to_file(target_scene_path)
	await get_tree().process_frame
	animator.play_backwards("transition")
	await animator.animation_finished
