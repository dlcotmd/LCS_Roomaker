extends Node

func force_play(sound_name : String, volume : float = 0):
	var audio = AudioStreamPlayer2D.new()
	audio.stream = load("res://assets/sounds/sfx/"+ sound_name +".mp3")
	audio.volume_db = volume
	add_child(audio)
	audio.play()
	
func _process(delta):
	for sound_child in get_children():
		if sound_child.playing == false:
			sound_child.queue_free()
