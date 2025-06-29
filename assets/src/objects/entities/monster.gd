extends CharacterBody2D

class_name Monster # 클래스 설정으로 충돌 인식 간편하게 함

# 몬스터 객체의 코드

# 작동 이해 / 몬스터라는 플레이어를 따라가며, 체력이 없으면 죽는 객체의 거푸집을
# 만든다고 생각하면 편함, 이미지도 없는 거푸집에 Command.gd의 summon_monster 함수로
# 몬스터의 이름을 받아 그 이름에 맞는 animation과 .json에 있는 체력, 스피드 등등 데이터를
# 거푸집에 씌운다고 생각하면 됨.

# 1은 가소 값임 추후에 .json 에 있는 데이터로 바뀜.
var speed : float = 1
var accel : float = 1 # 가속력 속도에 비해 작을 수록 미끄러 지듯이 움직임

var hp : float = 1
var max_hp : float = 1

var collision_rect : Rect2 
var direction : Vector2
var target_pos : Vector2

var detect_range : float

var is_dead : bool = false
var is_attacking : bool = false

var allow_meleeAttack : bool = true
var allow_move : bool = true
var allow_shoot : bool = true

var meleeAttack_damage : float
var meleeAttack_delay : float
var meleeAttack_delay_timer : float = 0
var meleeAttack_rect : Rect2
var meleeAttack_frames : Array # 공격을 넣는 타이밍이 두번도 가능하기 때문

var attack_method : String

var projectile_delay_timer : float = 0
var projectile_delay : float
var projectile_pos : Vector2 # 발사체 소환 위치
var projectile_name : String
var projectile_delay_range : Array # 랜덤한 딜레이 범위를 위한 변수

var last_projectile_frame : int # 총알 한 번에 여러개 소환 막기

var shoot_func : String # 어떻게 날릴지 형식
var shoot_frames : Array # 딱 날리는 프레임들

var knockback_force : float

var texture_pivot : Vector2
var load_animation : SpriteFrames

# Pointer--------------
var anim_sp : AnimatedSprite2D
var meleeAttack_area : Area2D
var collision : CollisionShape2D
var area_collision : CollisionShape2D
var sight : RayCast2D

func _ready():
	anim_sp = $anim_sp
	meleeAttack_area = $attack
	collision = $coll
	area_collision = $monster/coll
	sight = $sight

	anim_sp.sprite_frames = load_animation
	anim_sp.offset = texture_pivot
	
	area_collision.shape = RectangleShape2D.new()
	collision.shape = RectangleShape2D.new()
	
	#공격, 공격 감지 범위 collision 크기 위치 조정
	$attack/coll.shape = RectangleShape2D.new()
	$attack/coll.shape.size = meleeAttack_rect.size
	$attack/coll.position = meleeAttack_rect.position

	collision.shape.size = collision_rect.size
	collision.position = collision_rect.position
	area_collision.position = collision_rect.position
	area_collision.shape.size = collision_rect.size + Vector2(0.5, 0.5)
	
	$hp_bar.position.y = -collision_rect.size.y * 2.4
	
	anim_sp.play("idle")
	if attack_method == "projectile":
		projectile_delay = randf_range(projectile_delay_range[0], projectile_delay_range[1])

func _physics_process(delta):
	#print("움직임 :", allow_move, "근접 허용", allow_meleeAttack, "원거리 허용", allow_shoot)
	if allow_move:
		direction = (Info.player_pos - global_position).normalized()
	else:
		direction = Vector2.ZERO
	
	control_allowMovement()
	control_meleeAttack_timer(delta)
	control_of_dir()
	control_meleeAttack()
	if attack_method == "projectile":
		control_shoot_timer(delta)
		control_projectile()
		
	velocity = velocity.move_toward(direction * speed, accel)
	move_and_slide()

func melee_attack():
	allow_meleeAttack = false
	is_attacking = true
	print('근접')
	anim_sp.play("attack")
func shoot_projectile():
	allow_shoot = false
	is_attacking = true
	print('원거리')
	anim_sp.play("shoot")
func control_allowMovement():
	#-----------Raycast 코드-------------
	var player_distance = global_position.distance_to(Info.player_pos)
	if player_distance <= detect_range:
		sight.target_position = to_local(Info.player_pos + Vector2(0, 5))
	
	var can_see_player : bool = false
	if sight.is_colliding():
		if sight.get_collider() is Player:
			can_see_player = true
		elif not sight.get_collider() is Monster:
			can_see_player = false
	#------------------------------------
	
	if is_attacking == false and is_dead == false and can_see_player == true:
		allow_move = true
	else:
		allow_move = false
		

func control_meleeAttack_timer(delta):
	# 타이머가 지나야 allow_attack을 true 해줌
	if allow_move == false:
		return
	meleeAttack_delay_timer += delta
	if meleeAttack_delay_timer >= meleeAttack_delay:
		allow_meleeAttack = true
		meleeAttack_delay_timer = 0
func control_shoot_timer(delta):
	# 타이머가 지나야 allow_shoot을 true 해줌
	if allow_move == false:
		return
	projectile_delay_timer += delta
	if projectile_delay_timer >= projectile_delay:
		allow_shoot = true
		projectile_delay_timer = 0
		projectile_delay = randf_range(projectile_delay_range[0], projectile_delay_range[1])

func control_of_dir():
	# 방향에 따른 애니메이션, 공격 범위 위치, 이미지 반전 조정
	if allow_move == false:
		return  # 움직일 수 없는 상태라면 그냥 작동 안함
	if direction.x > 0.01:
		anim_sp.play("walk")
		anim_sp.offset.x = -texture_pivot.x
		if attack_method == "projectile":
			projectile_pos.x = abs(projectile_pos.x)
		$attack/coll.position.x = meleeAttack_rect.position.x
		anim_sp.flip_h = true
	elif direction.x < 0.01:
		anim_sp.play("walk")
		anim_sp.offset.x = texture_pivot.x
		if attack_method == "projectile":
			projectile_pos.x = abs(projectile_pos.x) * -1
		$attack/coll.position.x = -meleeAttack_rect.position.x
		anim_sp.flip_h = false
	else:
		anim_sp.play("idle")

func control_meleeAttack():
	if allow_meleeAttack:
		for area in meleeAttack_area.get_overlapping_areas():
			if area.name == "player" and area.get_parent() is Player:
				melee_attack()
				break
	# 공격 중일 때만 프레임 체크
	if anim_sp.animation == "attack" and (float(anim_sp.frame) in meleeAttack_frames) == true:
		# json에서 frames에 있는 값들이 float임 json엔 Float만 가능하나봄 ㅅㅂ
		meleeAttack_area.monitorable = true
	else:
		meleeAttack_area.monitorable = false
func control_projectile():
	if allow_shoot == true:
		shoot_projectile()
	if anim_sp.animation == 'shoot' and float(anim_sp.frame) in shoot_frames and last_projectile_frame != int(anim_sp.frame):
		Shoot.call(shoot_func, projectile_name, global_position + projectile_pos)
		last_projectile_frame = int(anim_sp.frame)

func _on_animation_finished():
	if anim_sp.animation == 'death':
		Command.particle("blood_explosion", global_position)
		queue_free()
	if anim_sp.animation == 'shoot':
			last_projectile_frame = -1
			is_attacking = false
	if anim_sp.animation == 'attack':
			is_attacking = false
func _on_body_area_entered(area):
	print(area.name, "아레나에 들어왔다")
	if area.name == "attack" and area.get_parent() is Player and is_dead == false:
		Command.hurt(self, Info.player_attack_damage)
		Command.apply_knockback(area.global_position, self, Info.player_knockback_force)
		if hp <= 0:
			Command.kill(self)
