extends Node2D
# play_scene에 있는 all_entities 코드

func _process(_delta):
	
	for node in get_children():
		if node.has_node("shadow") == true: # 자식 노드 중 그림자 객체를 가지고 있다면
			continue # 다음 노드로 넘어감 (밑에 코드 실행 X)

		# 그림자 객체 없으면 실행
		var shadow_path = preload("res://assets/objects/gui/shadow.tscn")
		var shadow = shadow_path.instantiate()
		node.add_child(shadow) # 해당 노드에 그림자 객체 추가
