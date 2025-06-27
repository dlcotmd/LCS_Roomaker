extends CharacterBody2D

# 몬스터 객체의 코드

# 작동 이해 / 몬스터라는 플레이어를 따라가며, 체력이 없으면 죽는 객체의 거푸집을
# 만든다고 생각하면 편함, 이미지도 없는 거푸집에 Command.gd의 summon_monster 함수로
# 몬스터의 이름을 받아 그 이름에 맞는 animation과 .json에 있는 체력, 스피드 등등 데이터를
# 거푸집에 씌운다고 생각하면 됨.

# 1은 가소 값임 추후에 .json 에 있는 데이터로 바뀜.
@export var SPEED : float = 45
@export var ACCEL : float = 4 # 가속력 속도에 비해 작을 수록 미끄러 지듯이 움직임

@export var hp : float = 1
@export var max_hp : float = 1

var allow_move : bool = true
var direction : Vector2
var target_pos : Vector2

var detect_range : float

var is_attacking : bool = false
var is_shooting : bool = false
var is_dead : bool = false

var attack_damage : float
var attack_delay : float
var knockback_force : float

# Pointer--------------
var anim_sp : AnimatedSprite2D
var navi_agent : NavigationAgent2D

func _ready():
	anim_sp = $anim_sp
	navi_agent = $navi_agent
	
	anim_sp.play("idle")

func _physics_process(delta):
	if allow_move and not is_attacking and is_dead == false:
		direction = (navi_agent.get_next_path_position() - global_position).normalized()
	else:
		direction = Vector2.ZERO

	var new_velocity = direction * SPEED * delta * 60
	navi_agent.set_velocity(new_velocity)
	
	control_of_dir()

	move_and_slide()

func control_of_dir():
	# 방향에 따른 애니메이션, 공격 범위 위치, 이미지 반전 조정
	if is_attacking or is_dead or is_shooting:
		return  # 공격 중이거나 죽은 상태면 걷기 애니메이션 중단
	if direction.x > 0:
		anim_sp.play("walk")
		anim_sp.flip_h = false
	elif direction.x < 0:
		anim_sp.play("walk")
		anim_sp.flip_h = true
	else:
		anim_sp.play("idle")

# 네비게이션 길 설정 signal
func _on_navi_timer_timeout():
	navi_agent.target_position = Info.player_pos
func _on_navi_agent_velocity_computed(safe_velocity):
	velocity = velocity.move_toward(safe_velocity, ACCEL)
