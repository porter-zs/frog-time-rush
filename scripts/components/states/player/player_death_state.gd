class_name PlayerDeathState extends CharacterState

const DEATH_SFX: AudioStreamWAV = preload("res://sound/player_death.wav")

static var state_name: String = "PlayerDeathState"

func get_state_name() -> String:
	return state_name

func _enter() -> void:
	AudioManager.play_sfx(DEATH_SFX)
	
	actor.sprite.play("death")
	
	if GameManager.lives >= 1:
		GameManager.lives -= 1
		await actor.sprite.animation_finished
		actor.reset_player()
		state_machine.transition_state(PlayerIdleState.state_name)
