extends Node


# https://pin.it/2FTcVU4pL 체력 UI 핀터레스트
func summon_monster(monster_name : String, pos : Vector2):
	if get_tree().current_scene.name != 'play_scene':
		print('현재 게임 진행 중이 아니라 소환 할 수 없습니다.')
		return
	
	var monster_data = Cfile.get_jsonData("res://assets/data/monsters/" + monster_name + ".json")
	#print(monster_data)
	#print(Cfile.get_filesPath("res://assets/data/monsters/", ".json"))
	if monster_data == null:
		print('데이터에 없는 존재')
		return
	
	var monster_path = preload("res://assets/objects/entities/monster.tscn")
	var monster : Monster = monster_path.instantiate()
	monster.max_hp = monster_data["hp"]
	monster.hp = monster_data["hp"]
	
	monster.SPEED = monster_data["speed"]
	monster.ACCEL = monster_data["accel"]
	monster.collision_size = Vector2(monster_data["collision_size"][0], monster_data["collision_size"][1])
	
	monster.detect_range = monster_data["detect_range"]
	
	monster.attack_damage = monster_data["attack"]["damage"]
	monster.knockback_force = monster_data["attack"]["knockback"]
	monster.attack_rect = monster_data["attack"]["collision_rect"]
	monster.attack_frames = monster_data["animation"]["attack_frames"]
	monster.attack_delay = monster_data["attack"]["delay"]
	
	monster.animation = load("res://assets/animations/" + monster_name + ".tres")
	monster.texture_pivot = Vector2(monster_data["animation"]["texture_pivot"][0], monster_data["animation"]["texture_pivot"][1])
	
	monster.global_position = pos
	
	get_tree().current_scene.find_child("all_entities").add_child(monster)

func apply_knockback(target_pos: Vector2, body: Node2D, force: float) -> void:
	var direction = (body.global_position - target_pos).normalized()
	var distance = body.global_position.distance_to(target_pos)
	
	# 거리가 가까울수록 힘이 세고, 멀수록 약하게
	var knockback_strength = force * 500 / max(distance, 1.0)
	
	knockback_strength = clamp(knockback_strength, 0, 600)
	
	var knockback_vector = direction * knockback_strength
	
	# CharacterBody2D일 경우
	if body is CharacterBody2D:
		body.velocity.x += knockback_vector.x
		body.velocity.y += knockback_vector.y / 1.8

func shake_camera(camera: Camera2D, duration: float, intensity: float) -> void:
	var time_elapsed = 0.0
	var original_offset = camera.offset
	
	intensity = clamp(intensity, 0, 40)

	while time_elapsed < duration:
		var shake_offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		camera.offset = original_offset + shake_offset

		await get_tree().process_frame
		time_elapsed += get_process_delta_time()

	camera.offset = original_offset

func particle(par_name : String, pos : Vector2, dir : Vector2, color : Color):
	var par_path = preload("res://assets/objects/particles/animated_particle.tscn")
	var par = par_path.instantiate()
	
	par.modulate = color
	par.find_child("anim_sp").sprite_frames = load("res://assets/animations/particles/" + par_name + ".tres")
	par.find_child("anim_sp").play("play")
	par.global_position = pos
	par.rotation = dir.angle()
	get_tree().current_scene.find_child("all_particles").add_child(par)

func hurt(node, damage : float):
	if (node.has_node("anim_sp") or node.has_node("sp")) == false:
		# 스프라이트를 안 가지고 있다면 그냥 반환
		return
	
	if node is Player:
		Info.player_hp -= damage
		Command.shake_camera(node.find_child("cam"), 0.15, damage * 0.1)
		node.find_child("animation").play("hurt")
		node.find_child("anim_sp").modulate = Color(100, 100, 100, 1)
		await get_tree().create_timer(0.2).timeout
		node.find_child("anim_sp").modulate = Color(1, 1, 1, 1)
	else:
		node.hp -= damage
		get_tree().current_scene.find_child("all_entities").find_child("player").find_child("animation").play("impact_zoom")
		Command.shake_camera(get_tree().current_scene.find_child("all_entities").find_child("player").find_child("cam"), 0.15, damage * 0.1)
		Command.particle("attack_hit", node.global_position + Info.player_pos.direction_to(node.global_position).normalized() * 13, Info.player_pos.direction_to(node.global_position).normalized(), Color("#b81a33"))
		node.find_child("anim_sp").modulate = Color(100, 100, 100, 1)
		Engine.time_scale = 0.45
		await get_tree().create_timer(0.1).timeout
		Engine.time_scale = 1.0
		node.find_child("anim_sp").modulate = Color(1, 1, 1, 1)
