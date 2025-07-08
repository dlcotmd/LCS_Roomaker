extends Resource
#인벤토리 슬롯 늘리는 법
#1. assets -> objects -> ui -> playerinv -> inspector에 size 늘리고 empty에서 NewInvSlot 하면됨
#2. assets -> objects -> ui -> inventory -> 왼쪽에 Panel 누르고 ctrl + D 해서 원하는 만큼 복사하면 됨
#slot_grid 눌러서 inspector에 Columns 수 늘리면 한 줄에 들어가는 노드 최대 수 조절할 수 있

class_name Inv

@export var slots: Array[InvSlot]
	
func insert(item: InvItem):
	for slot in slots:
		if slot.item == null:
			slot.item = item
			return
	print("빈 슬롯 없음")
