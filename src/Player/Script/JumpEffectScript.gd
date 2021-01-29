extends AnimatedSprite

func _on_JumpEffect_animation_finished() -> void:
	queue_free()
