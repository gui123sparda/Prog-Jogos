extends Sprite2D

var pegada = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	# Ainda n
	if not pegada:
		$AudioStreamPlayer.play()
	pegada = true
	visible = false
	await $AudioStreamPlayer.finished
	queue_free()
