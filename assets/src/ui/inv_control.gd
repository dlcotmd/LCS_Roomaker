extends Node2D

var is_open = false
const SlotClass = preload("res://assets/src/ui/Slot.gd")
@onready var inventory_slots = $GridContainer
var holding_item = null

func _ready():
	close()
	for inv_slot in inventory_slots.get_children():
		inv_slot.connect("gui_input", Callable(self, "slot_gui_input").bind(inv_slot))
		
# 두 번째 인자 타입 제거
func slot_gui_input(event: InputEvent, slot):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if holding_item != null:
				if !slot.item:
					slot.putIntoSlot(holding_item)
					holding_item = null
				else:
					var temp_item = slot.item
					slot.pickFromSlot()
					temp_item.global_position = event.global_position
					slot.putIntoSlot(holding_item)
					holding_item = temp_item
			elif slot.item:
				holding_item = slot.item
				slot.pickFromSlot()
				holding_item.global_position = get_viewport().get_mouse_position()

func _input(event):
	if holding_item:
		var mouse_pos = get_global_mouse_position()
		var texture_rect = holding_item.get_node_or_null("TextureRect")
		
		if texture_rect and texture_rect.texture:
			var tex_size = texture_rect.texture.get_size()
			var offset = Vector2(1, 10)  # 가로 세로 8만큼 이동
			holding_item.global_position = mouse_pos - tex_size * 0.5 + offset
		else:
			# fallback: 이미지 없을 경우 그냥 마우스 위치
			holding_item.global_position = mouse_pos


func _process(delta):
	if Input.is_action_just_pressed("I"):
		if is_open:
			close()
		else:
			open()

func open():
	visible = true
	is_open = true
	
func close():
	visible = false
	is_open = false
