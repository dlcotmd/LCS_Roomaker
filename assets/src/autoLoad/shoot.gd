extends Node

func target_player(projectile_name : String, shoot_marker_pos : Vector2):
	Command.summon_projectile(projectile_name, shoot_marker_pos, shoot_marker_pos.direction_to(Info.player_pos))
func spread_circle_border(projectile_name : String, shoot_marker_pos : Vector2, amount : int = 1):
	amount = clamp(amount, 1, 400)
	for i in amount:
		var angle_deg = i * (360.0 / amount)
		var angle_rad = deg_to_rad(angle_deg)

		var dir = Vector2(cos(angle_rad), sin(angle_rad))
		Command.summon_projectile(projectile_name, shoot_marker_pos, dir)
