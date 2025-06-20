extends CharacterBody2D

class_name Player

var SPEED : float = 60.0
var ACCEL : float = 15.0

var hp : float = 500
var max_hp : float = 500

var direction : Vector2
var last_dir = 'front' # or "side", "back"
var is_attacking : bool = false

# Pointer--------------
var anim_sp : AnimatedSprite2D
var attack_collision : CollisionShape2D

func _ready():
	anim_sp = $anim_sp
	attack_collision = $attack/coll

func _physics_process(_delta):
	Info.player_pos = global_position

	if is_attacking == false:
		direction = Input.get_vector("A","D","W","S")
	
	control_attackAnim()
	control_of_dir()
	
	velocity.x = move_toward(velocity.x, SPEED * direction.x, ACCEL)
	velocity.y = move_toward(velocity.y, SPEED * direction.y, ACCEL)

	move_and_slide()

func control_of_dir():
	# 방향에 따른 애니메이션, 공격 범위 위치, 이미지 반전 조정
	if direction.x > 0:
		anim_sp.play("move_side")
		last_dir = 'side'
		attack_collision.position = Vector2(18, 0)
		$anim_sp.flip_h = true
	elif direction.x < 0:
		anim_sp.play("move_side")
		last_dir = 'side'
		attack_collision.position = Vector2(-18, 0)
		$anim_sp.flip_h = false
	elif direction.y > 0:
		anim_sp.play("move_front")
		last_dir = 'front'
		attack_collision.position = Vector2(0, 18)
	elif direction.y < 0:
		anim_sp.play("move_back")
		last_dir = 'back'
		attack_collision.position = Vector2(0, -18)
	elif is_attacking == false:
		anim_sp.play("idle_" + last_dir)
func control_attackAnim():
	# 공격 애니메이션 조정
	if "attack" in anim_sp.animation: # 현재 실행 중인 애니메이션 이름에 attack이 들어가는가
		if anim_sp.frame == 1: # 딱 검기가 뻗어나가는 프레임이 1이라서 1일때만
			attack_collision.disabled = false # 공격 범위 활성화
		elif anim_sp.frame != 1:
			attack_collision.disabled = true

	if Input.is_action_just_pressed("L_click"):
		is_attacking = true
		direction = Vector2(0, 0)
		anim_sp.play("attack_" + last_dir)

func _on_animation_finished():
	# 원래는 애니메이션이 끝나면 발동되는 함수이지만,
	# move, idle은 반복 애니메이션 이므로 끝나지 않아, 끝나는 애니매이션은 attack 졸류뿐
	is_attacking = false
