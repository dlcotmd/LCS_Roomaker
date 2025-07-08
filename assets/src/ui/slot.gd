extends Panel
#슬롯 위에 마우스가 있는지 없는지 확인
#x 누르면 플레이어 위치에 아이템 반환

@onready var item_visual: Sprite2D = $CenterContainer/Panel/itemDisplay

var inv_slot: InvSlot
var is_hovered := false

func _ready():
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("mouse_exited", Callable(self, "_on_mouse_exited"))

func _on_mouse_entered():
	is_hovered = true

func _on_mouse_exited():
	is_hovered = false

func _process(delta):
	if is_hovered and Input.is_action_just_pressed("drop"):
		if inv_slot and inv_slot.item:
			drop_item(inv_slot.item)
			inv_slot.item = null  # 인벤토리에서 제거
			update(inv_slot)  # 슬롯 갱신

func drop_item(item: InvItem):
	var drop_scene = preload("res://assets/objects/entities/drop_item.tscn")
	var drop = drop_scene.instantiate()
	drop.global_position = Info.player_pos
	
	# item의 정보 반영
	drop.itemId = item.name
	drop.itemName = item.name
	drop.itemDes = item.description
	drop.itemType = item.item_type
	drop.find_child("sp").texture = item.texture

	get_tree().current_scene.find_child("all_entities").add_child(drop)


func update(slot: InvSlot):
	if !slot.item:
		item_visual.visible = false
	else:
		item_visual.visible = true
		item_visual.texture = slot.item.texture
