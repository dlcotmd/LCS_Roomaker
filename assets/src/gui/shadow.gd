extends Node2D

# 그림자 객체의 본인의 부모노드 크기에 따른 그림자 크기 변경

func _ready():
	if get_parent().has_node("coll") == true: # 부모 노드가 콜리션을 가지고 있다면
		
		# 부모 노드의 콜리션 크기에 맞춰 그림자의 크기 조정 x에 비해 y크기는 적게 변함
		$shadow.size.x = get_parent().find_child("coll").shape.size.x
		$shadow.size.y = get_parent().find_child("coll").shape.size.y / 4
		
		# 위치 센터 조정
		$shadow.position.x = -$shadow.size.x / 2
		$shadow.position.y = get_parent().find_child("coll").shape.size.y - 2.5
