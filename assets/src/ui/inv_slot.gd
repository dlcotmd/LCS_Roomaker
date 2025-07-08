extends Resource

class_name InvSlot

@export var item:InvItem = null

#func get_item(item_name : String):
	#var item = Cfile.get_jsonData("res://assets/data/items/" + item_name + ".json")
	#
