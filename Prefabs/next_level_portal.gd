extends Sprite2D


@export var next_level: String = "";


func _on_area_2d_body_entered(body: Node2D) -> void:
	print("entrou")
	if body.is_in_group("player"):
		get_tree().change_scene_to_file(next_level)
