extends Node2D

var bar : TextureProgressBar

func _ready():
	bar = $bar

func _process(delta):
	bar.size.x = get_parent().max_hp * 0.12
	bar.size.y = get_parent().max_hp * 0.02
	bar.position.x = -bar.size.x / 2
	bar.position.y = -bar.size.y / 2
	bar.max_value = get_parent().max_hp
	bar.value = get_parent().hp
	
