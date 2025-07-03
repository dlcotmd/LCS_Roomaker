extends CanvasLayer

@export var heart : PackedScene
@export var heart_full : Texture2D
@export var heart_half : Texture2D

# Pointer----------------
var dash_bar : TextureProgressBar
var heart_container : HBoxContainer

func _ready():
	dash_bar = $player_ui/V/dash
	heart_container = $player_ui/V/H

func _process(_delta):
	control_dash_bar()
	control_player_heart()
	#$player_ui/lv/hp.value = Info.player_hp
	#$player_ui/lv/hp.max_value = Info.player_max_hp
	#$player_ui/lv/energy.value = 100

func spawn_heart(spawn_count : int):
	for i in range(spawn_count):
		var heart = heart.instantiate()
		heart_container.add_child(heart)
			
func control_dash_bar():
	if dash_bar.value == 0:
		dash_bar.visible = false
	elif dash_bar.value != 0:
		dash_bar.visible = true
	dash_bar.value = round((Info.player.dash_timer / Info.player_dash_delay) * 100)

func control_player_heart():
	var spawn_count = int(Info.player_max_hp / 2)
	if Info.player_max_hp % 2 != 0:
		spawn_count += 1

	# 기존 하트 개수와 다르면 전부 삭제 후 다시 생성
	var heart_container_children = heart_container.get_children()
	if spawn_count != heart_container_children.size():
		for heart in heart_container_children:
			heart.queue_free()
		spawn_heart(spawn_count)

	# 다시 불러옴 (기존 배열은 queue_free 무효)
	heart_container_children = heart_container.get_children()

	# 체력 표시
	for i in range(spawn_count):
		var texture_rect = heart_container_children[i].find_child("progress")
		var hp_index = i * 2

		if Info.player_hp >= hp_index + 2:
			texture_rect.texture = heart_full
		elif Info.player_hp == hp_index + 1:
			texture_rect.texture = heart_half
		else:
			texture_rect.texture = null  # 비어 있는 하트
