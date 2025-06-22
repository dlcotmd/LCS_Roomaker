extends Node2D

func _process(_delta):
	
	for node in get_children():
		#print(-node.global_position.y)
		#node.z_index = -node.global_position.y
		if node.has_node("shadow") == true:
			continue
		var shadow_path = preload("res://assets/objects/gui/shadow.tscn")
		var shadow = shadow_path.instantiate()
		node.add_child(shadow)
