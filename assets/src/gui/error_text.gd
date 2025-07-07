extends Control

var error : String

func _ready():
	set_text(error)
	$animation.play("trans")
	
func set_text(text : String):
	$text.text = text

func _on_animation_finished(anim_name):
	if anim_name == 'trans':
		queue_free()
