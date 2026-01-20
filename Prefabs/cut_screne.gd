extends Node2D


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("enter"):
		get_tree().change_scene_to_file("res://Prefabs/levels/fase_2.tscn")
