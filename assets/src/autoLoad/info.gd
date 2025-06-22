extends Node

var player_pos : Vector2
var player_hp : float = 150
var player_max_hp : float = 150
var player_attack_damage : float = 5.5
var player_dash_amount : int = 3
var player_knockback_force : float = 1.8
var player_movement_speed : float = 55.0

var full_screen : bool = false
func _process(_delta):
	if Input.is_action_just_pressed("full_screen"):
		if full_screen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		full_screen = !full_screen
