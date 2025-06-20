extends Node

var player_pos : Vector2

var full_screen : bool = false
func _process(_delta):
	if Input.is_action_just_pressed("full_screen"):
		if full_screen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		full_screen = !full_screen
