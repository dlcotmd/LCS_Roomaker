extends Node2D

# 체력 바 객체 코드

var bar : TextureProgressBar
var parent_texture_rect : Rect2

func _ready():
	bar = $bar
	# 체력 바 대상의 ㄹㅇ 안에 있는 그림 Rect 가져오기
	parent_texture_rect = get_parent().find_child("anim_sp").sprite_frames.get_frame_texture("idle", 0).get_image().get_used_rect()
	print(parent_texture_rect)
func _process(delta):
	# 체력 표시할 대상의 최대 체력에 따라 체력 바 크기 변경
	# 최소 크기 존재해서 일정 이하로 안 작아짐
	bar.size.x = get_parent().max_hp * 0.12
	bar.size.y = get_parent().max_hp * 0.02

	# 체력 바 크기에 따라서 위치 중앙으로 조절
	# 대상 그림 사이즈 세로 길이에 따라 높이 변경
	bar.position.x = -bar.size.x / 2
	bar.position.y = -bar.size.y / 2 - parent_texture_rect.size.y * 0.85
	

	# 체력 바의 최대 수치, 현재 값 적용
	bar.max_value = get_parent().max_hp
	bar.value = get_parent().hp
	
