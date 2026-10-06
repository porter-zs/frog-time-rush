extends Node

var music_player: AudioStreamPlayer = null

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	self.add_child(music_player)

func play_music(stream: AudioStream) -> void:
	if not stream and not music_player:
		return
	
	if music_player.stream == stream and music_player.playing:
		return
	
	music_player.stream = stream
	music_player.play()

func play_sfx(stream: AudioStream, pitch_range: Vector2 = Vector2(0.95, 1.15)) -> void:
	if not stream: return
	
	var player = AudioStreamPlayer.new()
	add_child(player)
	
	player.stream = stream
	player.pitch_scale = randf_range(pitch_range.x, pitch_range.y)
	player.bus = "SFX"
	
	player.finished.connect(func(): player.queue_free())
	player.play()

func set_bus_volume(bus_name: String, value_normalized: float) -> void:
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		push_warning("Audio bus \"%s\" does not exist." % bus_name)
		return
	
	if value_normalized <= 0.05:
		AudioServer.set_bus_mute(bus_index, true)
	else:
		AudioServer.set_bus_mute(bus_index, false)
		
		var db_value = linear_to_db(value_normalized)
		AudioServer.set_bus_volume_db(bus_index, db_value)
