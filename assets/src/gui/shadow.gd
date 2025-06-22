extends Node2D

func _ready():
	if get_parent().has_node("coll") == true:
		$shadow.size.x = get_parent().find_child("coll").shape.size.x
		$shadow.size.y = get_parent().find_child("coll").shape.size.y / 4
		
		$shadow.position.x = -$shadow.size.x / 2
		$shadow.position.y = get_parent().find_child("coll").shape.size.y - 2.5
	elif get_parent().has_node("sp") == true:
		pass # 나중에 만듦. 아직 애니메이션 적용 노드 밖에 없음
