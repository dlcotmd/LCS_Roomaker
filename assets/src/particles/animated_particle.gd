extends Node2D

func _on_animation_finished():
	if $anim_sp.animation == 'play':
		queue_free()
