extends Control
#인벤토리 on, off 기능
#아이템 먹는기

@onready var inv: Inv = preload("res://assets/objects/ui/playerinv.tres")
@onready var slots: Array = $back_panel/slot_grid.get_children()
@export var detect_item_range : float = 40

var is_open : bool = false

func _ready():
	update_slot()
	close()
	#Info.inventory = self
	
func update_slot():
	for i in range(min(inv.slots.size(), slots.size())):
		#slots[i].update(inv.slots[i])
		var ui_slot = slots[i]
		var data_slot = inv.slots[i]
		
		ui_slot.inv_slot = data_slot  # 핵심: UI에 데이터 연결
		ui_slot.update(data_slot)  # 슬롯 UI 내용 갱신 함수 호출
	
func _process(delta):
	#print(Info.inventory.find_child("back_panel").find)
	if Input.is_action_just_pressed("inventory"):
		if is_open:
			close()
		else:
			open()
	if Input.is_action_just_pressed("pick up"):
		collect()
		
func open():
	visible = true
	is_open = true
	
func close():
	visible = false
	is_open = false
	
#아이템 인벤토리에 추가
func collect():
	var near_dropItem = null

	for entity in Info.all_entities:
		if entity is DropItem and entity.global_position:
			if near_dropItem == null or entity.global_position.distance_to(Info.player_pos) < near_dropItem.global_position.distance_to(Info.player_pos):
				near_dropItem = entity

	if near_dropItem != null and near_dropItem.global_position.distance_to(Info.player_pos) <= detect_item_range:
		var item_id = near_dropItem.itemId
		var item = create_item_from_name(item_id)
		inv.insert(item)
		update_slot()
		print(item_id)
		near_dropItem.queue_free()

#인벤토리에 이미지 띄우기, 그 이미지에 맞는 이름 가져오기
func create_item_from_name(item_name: String) -> InvItem:
	var item = InvItem.new()
	item.name = item_name  # 실제 표시될 이름을 item_name으로 고정

	var item_data = Cfile.get_jsonData("res://assets/data/items/" + item_name + ".json")
	if item_data == null:
		push_error("아이템 데이터 없음: " + item_name)
		return item

	item.description = item_data.get("des", "")
	var tex_path = "res://assets/sprites/items/" + item_name + ".png"
	if ResourceLoader.exists(tex_path):
		item.texture = load(tex_path)
	else:
		push_error("아이템 이미지 없음: " + tex_path)

	return item



#extends Control
#
#@export var slot_active : Texture2D
#@export var slot_default : Texture2D
#
#var is_open = false
#var holding_item = null
#
#var slots : Array # 슬롯 자식 객체 저장 리스트
#
## Pointer----------------------
#var slot_grid : GridContainer
#var back_panel : NinePatchRect
#
#func _ready():
	#slot_grid = $slot_grid
	#back_panel = $back_panel
	#load_slots()
#
#func read_slots():
	## slots 리스트에 객체 불러와주는 함수
	#slots = []
	#slots = slot_grid.get_children()
	#
#func control_slots():
	## slot 관리
	#for slot in slots:
		#var slot_panel = slot.find_child("panel")
		#var slot_center_pos = slot.global_position + Vector2(slot_panel.size.x/2, slot_panel.size.y/2)
		#$marker.global_position = slot_center_pos
		#if slot_center_pos.distance_to(get_global_mouse_position()) < slot_panel.size.x / 2:
			##slot_panel.modulate = Color(5, 5, 5, 1)
			#slot_panel.texture = slot_active
		#else:
			#slot_panel.texture = slot_default
			##slot_panel.modulate = Color(1, 1, 1, 1)
#
#func draw_back_panel(row : int):
	#back_panel.size.y = row * 28
#
#func load_slots():
	#var slot_path = load("res://assets/objects/gui/inventory_slot.tscn")
	#for i in range(Info.inventory_max_slot):
		#var slot = slot_path.instantiate()
		#slots.append(slot)
		#slot_grid.add_child(slot)
#
#func _process(delta):
	#read_slots()
	#control_slots()
	#
	#if Input.is_action_just_pressed("inventory"):
		#if is_open == true:
			#visible = false
		#elif is_open == false:
			#visible = true
		#is_open = !is_open
	#
