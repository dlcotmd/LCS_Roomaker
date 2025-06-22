extends CanvasLayer

func _process(_delta):
	$health_ui/lv/hp.value = Info.player_hp
	$health_ui/lv/hp.max_value = Info.player_max_hp
	$health_ui/lv/energy.value = Info.player_dash_amount
	#$health_ui/lv/energy.max_value = Info.player_dash_amount
