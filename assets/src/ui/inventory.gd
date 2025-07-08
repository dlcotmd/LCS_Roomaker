extends Control

@export var slot_active : Texture2D
@export var slot_default : Texture2D

var is_open = false
var holding_item = null

var slots : Array # 슬롯 자식 객체 저장 리스트

# Pointer----------------------
var slot_grid : GridContainer
var back_panel : NinePatchRect

func _ready():
	slot_grid = $slot_grid
	back_panel = $back_panel
	load_slots()

func read_slots():
	# slots 리스트에 객체 불러와주는 함수
	slots = []
	slots = slot_grid.get_children()
	
func control_slots():
	# slot 관리
	for slot in slots:
		var slot_panel = slot.find_child("panel")
		var slot_center_pos = slot.global_position + Vector2(slot_panel.size.x/2, slot_panel.size.x/2)
		$marker.global_position = slot_center_pos
		if slot_center_pos.distance_to(get_global_mouse_position()) < slot_panel.size.x / 2:
			slot_panel.texture = slot_active
		else:
			slot_panel.texture = slot_default

func draw_back_panel(row : int):
	back_panel.size.y = row * 28

func load_slots():
	var slot_path = load("res://assets/objects/gui/inventory_slot.tscn")
	for i in range(8):
		var slot = slot_path.instantiate()
		slots.append(slot)
		slot_grid.add_child(slot)
	for i in range(3):
		var slot = slot_path.instantiate()
		#$slot_grid2.append(slot)
		$slot_grid2.add_child(slot)

func _process(delta):
	read_slots()
	control_slots()
	
	if Input.is_action_just_pressed("inventory"):
		if is_open == true:
			visible = false
		elif is_open == false:
			visible = true
		is_open = !is_open
	
