extends CharacterBody2D

class_name Monster # 클래스 설정으로 충돌 인식 간편하게 함

# 몬스터 객체의 코드

# 작동 이해 / 몬스터라는 플레이어를 따라가며, 체력이 없으면 죽는 객체의 거푸집을
# 만든다고 생각하면 편함, 이미지도 없는 거푸집에 Command.gd의 summon_monster 함수로
# 몬스터의 이름을 받아 그 이름에 맞는 animation과 .json에 있는 체력, 스피드 등등 데이터를
# 거푸집에 씌운다고 생각하면 됨.

# 1은 가소 값임 추후에 .json 에 있는 데이터로 바뀜.
var SPEED : float = 1
var ACCEL : float = 1 # 가속력 속도에 비해 작을 수록 미끄러 지듯이 움직임

var hp : float = 1
var max_hp : float = 1

var collision_data : Array
var allow_move : bool = false
var direction : Vector2
var target_pos : Vector2

var detect_range : float

var is_attacking : bool = false
var is_shooting : bool = false
var is_dead : bool = false

var attack_damage : float
var attack_delay : float
var allow_attack : bool = true
var attack_delay_timer : float = 0
var attack_rect : Array # x, y, width, height
var attack_frames : Array # 공격을 넣는 타이밍이 두번도 가능하기 때문

var attack_method : String

var projectile_delay_timer : float = 0
var projectile_delay : float
var projectile_type : String
var projectile_name : String
var projectile_delay_range : Array
var projectile_speed : float
var projectile_damage : float
var projectile_kncokback : float

var last_projectile_frame : int # 총알 한 번에 여러개 소환 막기

var shoot_pos : Vector2
var shoot_frames : Array

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
var sight : RayCast2D
var shoot_marker : Marker2D

func _ready():
	anim_sp = $anim_sp
	attack_collision = $attack/coll
	collision = $coll
	area_collision = $monster/coll
	attack_detect_collision = $attack_detect/coll
	navi_agent = $navi_agent
	sight = $sight
	shoot_marker = $shoot_marker
	
	anim_sp.sprite_frames = animation
	anim_sp.offset = texture_pivot
	
	area_collision.shape = RectangleShape2D.new()
	attack_detect_collision.shape = RectangleShape2D.new()
	attack_collision.shape = RectangleShape2D.new()
	collision.shape = RectangleShape2D.new()

	collision.shape.size = Vector2(collision_data[2], collision_data[3])
	collision.position = Vector2(collision_data[0], collision_data[1])
	area_collision.position = Vector2(collision_data[0], collision_data[1])
	area_collision.shape.size = Vector2(collision_data[2], collision_data[3]) + Vector2(0.5, 0.5)
	
	$hp_bar.position.y = -collision_data[3] * 2.4

	navi_agent.radius = (collision_data[2] + collision_data[3]) / 3
	
	if attack_method == "projectile":
		projectile_delay = randf_range(projectile_delay_range[0], projectile_delay_range[1])
		shoot_marker.position = shoot_pos
	
	#공격, 공격 감지 범위 collision 크기 위치 조정
	attack_collision.shape.size = Vector2(attack_rect[2], attack_rect[3])
	attack_collision.position = Vector2(attack_rect[0], attack_rect[1])
	attack_detect_collision.shape.size = Vector2(attack_rect[2], attack_rect[3])
	attack_detect_collision.position = Vector2(attack_rect[0], attack_rect[1])

func _physics_process(delta):
	if allow_move and not is_attacking and is_dead == false:
		direction = (navi_agent.get_next_path_position() - global_position).normalized()
	else:
		direction = Vector2.ZERO
	
	control_attack_timer(delta)
	control_attackAnim()
	control_of_dir()
	control_sight()
	if attack_method == "projectile":
		control_projectile(delta)
	
	var new_velocity = direction * SPEED * delta * 60
	navi_agent.set_velocity(new_velocity)

	move_and_slide()

func melee_attack():
	if not allow_attack:
		return
	is_attacking = true
	allow_move = false
	anim_sp.play("attack")
func shoot_projectile():
	if projectile_type == "player_dir":
		Command.summon_projectile(projectile_name, shoot_marker.global_position, shoot_marker.global_position.direction_to(Info.player_pos))
	elif projectile_type == "circle_expand":
		for i in 36:
			var angle_deg = i * (360.0 / 36)
			var angle_rad = deg_to_rad(angle_deg)

			var dir = Vector2(cos(angle_rad), sin(angle_rad))
			Command.summon_projectile(projectile_name, shoot_marker.global_position, dir)
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

func control_projectile(delta):
	projectile_delay_timer += delta
	
	if anim_sp.animation == 'shoot' and float(anim_sp.frame) in shoot_frames and last_projectile_frame != int(anim_sp.frame):
		shoot_projectile()
		last_projectile_frame = int(anim_sp.frame)
	
	if projectile_delay_timer >= projectile_delay and allow_move == true and is_attacking == false and is_dead == false:
		allow_move = false
		is_shooting = true
		anim_sp.play("shoot")
		projectile_delay_timer = 0
		projectile_delay = randf_range(projectile_delay_range[0], projectile_delay_range[1])
func control_sight():
	var player_distance = global_position.distance_to(Info.player_pos)
	if player_distance <= detect_range:
		sight.target_position = to_local(Info.player_pos + Vector2(0, 5))
	if sight.is_colliding():
		if sight.get_collider() is Player:
			allow_move = true
		else:
			allow_move = false
func control_attack_timer(delta):
	if allow_attack:
		return
	attack_delay_timer += delta
	if attack_delay_timer >= attack_delay:
		allow_attack = true
		attack_delay_timer = 0
func control_of_dir():
	# 방향에 따른 애니메이션, 공격 범위 위치, 이미지 반전 조정
	if is_attacking or is_dead or is_shooting:
		return  # 공격 중이거나 죽은 상태면 걷기 애니메이션 중단
	if direction.x > 0:
		anim_sp.play("walk")
		anim_sp.offset.x = -texture_pivot.x
		if attack_method == "projectile":
			shoot_marker.position.x = shoot_pos.x
		attack_collision.position = Vector2(attack_rect[0], attack_rect[1])
		attack_detect_collision.position = Vector2(attack_rect[0], attack_rect[1])
		anim_sp.flip_h = true
	elif direction.x < 0:
		anim_sp.play("walk")
		anim_sp.offset.x = texture_pivot.x
		if attack_method == "projectile":
			shoot_marker.position.x = -shoot_pos.x
		attack_collision.position = Vector2(-attack_rect[0], attack_rect[1])
		attack_detect_collision.position = Vector2(-attack_rect[0], attack_rect[1])
		anim_sp.flip_h = false
	else:
		anim_sp.play("idle")
func control_attackAnim():
	if is_attacking == false and is_dead == false and is_shooting == false:
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
		"shoot":
			last_projectile_frame = -1
			is_shooting = false
			allow_move = true
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
