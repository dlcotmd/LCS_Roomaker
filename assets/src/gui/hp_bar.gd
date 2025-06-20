extends Node2D

var bar : TextureProgressBar

func _ready():
	bar = $bar

func _process(delta):
	bar.max_value = get_parent().max_hp
	bar.value = get_parent().hp
	
