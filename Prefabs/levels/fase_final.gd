extends Node2D


func _on_enemy_boss_on_death() -> void:
	print(get_tree().change_scene_to_file("res://Prefabs/menu_initial.tscn"))
