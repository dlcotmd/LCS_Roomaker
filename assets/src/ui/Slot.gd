extends Panel


var ItemClass = preload("res://assets/objects/ui/item.tscn")
var item = null
# Called when the node enters the scene tree for the first time.
func _ready():
	if randi() % 2 == 0:
		item = ItemClass.instantiate()
		add_child(item)

func pickFromSlot():
	remove_child(item)
	var inventoryNode = find_parent("inventory")
	inventoryNode.add_child(item)
	item = null
	
func putIntoSlot(new_item):
	item = new_item
	item.position = Vector2(0, 0)
	var inventoryNode = find_parent("inventory")
	inventoryNode.remove_child(item)
	add_child(item)
	
