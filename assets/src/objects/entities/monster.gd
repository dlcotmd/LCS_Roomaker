extends CharacterBody2D

class_name Monster

var SPEED : float = 1
var ACCEL : float = 1

var hp : float = 1
var max_hp : float = 1

var collision_size : Vector2
var allow_move : bool = false
var direction : Vector2
var target_pos : Vector2

var detect_range : float

var is_attacking : bool = false
var is_dead : bool = false

var attack_damage : float
var attack_delay : float
var allow_attack : bool = true
var attack_delay_timer : float = 0
var attack_rect : Array # x, y, width, height
var attack_frames : Array # 공격을 넣는 타이밍이 두번도 가능하기 때문

var knockback_force : float

var texture_pivot : Vector2
var animation : SpriteFrames

# Pointer--------------
var anim_sp : AnimatedSprite2D
var attack_collision : CollisionShape2D
var attack_detect_collision : CollisionShape2D
var collision : CollisionShape2D
var area_collision : CollisionShape2D
var navi_agent : NavigationAgent2D

func _ready():
	anim_sp = $anim_sp
	attack_collision = $attack/coll
	collision = $coll
	area_collision = $monster/coll
	attack_detect_collision = $attack_detect/coll
	navi_agent = $navi_agent
	
	anim_sp.sprite_frames = animation
	anim_sp.offset = texture_pivot
	
	area_collision.shape = RectangleShape2D.new()
	attack_detect_collision.shape = RectangleShape2D.new()
	attack_collision.shape = RectangleShape2D.new()
	collision.shape = RectangleShape2D.new()
	
	collision.shape.size = collision_size
	area_collision.shape.size = collision_size + Vector2(0.5, 0.5)
	
	$hp_bar.position.y = -collision_size.y * 1.2 - 3
	#$shadow.position.y = collision_size.y / 2 + 1
	
	#공격, 공격 감지 범위 collision 크기 위치 조정
	attack_collision.shape.size = Vector2(attack_rect[2], attack_rect[3])
	attack_collision.position = Vector2(attack_rect[0], attack_rect[1])
	attack_detect_collision.shape.size = Vector2(attack_rect[2], attack_rect[3])
	attack_detect_collision.position = Vector2(attack_rect[0], attack_rect[1])

func _physics_process(delta):
	var player_distance = global_position.distance_to(Info.player_pos)
	allow_move = player_distance <= detect_range
	

	if allow_move and not is_attacking and is_dead == false:
		direction = (navi_agent.get_next_path_position() - global_position).normalized()
	else:
		direction = Vector2.ZERO
	
	control_attack_timer(delta)
	control_attackAnim()
	control_of_dir()
	
	var new_velocity = direction * SPEED * delta * 60
	navi_agent.set_velocity(new_velocity)

	move_and_slide()

func melee_attack():
	if not allow_attack:
		return
	is_attacking = true
	allow_move = false
	anim_sp.play("attack")
func hurt(damage):
	hp -= damage
	anim_sp.modulate = Color(100, 100, 100, 1)
	await get_tree().create_timer(0.2).timeout
	anim_sp.modulate = Color(1, 1, 1, 1)
func dead():
	if is_dead:
		return
	is_dead = true
	direction = Vector2.ZERO
	anim_sp.play("death")

func control_attack_timer(delta):
	if allow_attack:
		return
	attack_delay_timer += delta
	if attack_delay_timer >= attack_delay:
		allow_attack = true
		attack_delay_timer = 0
func control_of_dir():
	# 방향에 따른 애니메이션, 공격 범위 위치, 이미지 반전 조정
	if is_attacking or is_dead:
		return  # 공격 중이거나 죽은 상태면 걷기 애니메이션 중단
	if direction.x > 0:
		anim_sp.play("walk")
		anim_sp.offset.x = -texture_pivot.x
		attack_collision.position = Vector2(attack_rect[0], attack_rect[1])
		attack_detect_collision.position = Vector2(attack_rect[0], attack_rect[1])
		anim_sp.flip_h = true
	elif direction.x < 0:
		anim_sp.play("walk")
		anim_sp.offset.x = texture_pivot.x
		attack_collision.position = Vector2(-attack_rect[0], attack_rect[1])
		attack_detect_collision.position = Vector2(-attack_rect[0], attack_rect[1])
		anim_sp.flip_h = false
	else:
		anim_sp.play("idle")
func control_attackAnim():
	if is_attacking == false and is_dead == false:
		for area in $attack_detect.get_overlapping_areas():
			if area.name == "player" and area.get_parent() is Player:
				melee_attack()
				break

	# 공격 중일 때만 프레임 체크
	if anim_sp.animation == "attack":
		# json에서 frames에 있는 값들이 float임 json엔 Float만 가능하나봄 ㅅㅂ
		attack_collision.disabled = !(float(anim_sp.frame) in attack_frames)
	else:
		attack_collision.disabled = true

func _on_animation_finished():
	match anim_sp.animation:
		"attack":
			is_attacking = false
			allow_move = true
			allow_attack = false
		"death":
			Command.particle("blood_explosion", global_position, Vector2(0, 0), Color(1, 1, 1, 1))
			queue_free()
func _on_body_area_entered(area):
	if area.name == "attack" and area.get_parent() is Player and is_dead == false:
		Command.hurt(self, Info.player_attack_damage)
		Command.apply_knockback(area.global_position, self, Info.player_knockback_force)
		if hp <= 0:
			dead()

# 네비게이션 길 설정 signal
func _on_navi_timer_timeout():
	navi_agent.target_position = Info.player_pos
func _on_navi_agent_velocity_computed(safe_velocity):
	velocity = velocity.move_toward(safe_velocity, ACCEL)
