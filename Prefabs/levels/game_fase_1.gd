extends Node2D

var Player_life = null 

func _process(delta: float) -> void:
	Player_life = $"Player Final".health
	$CanvasLayer/vidas_txt.text = "VIDA " + str(Player_life)
	

func _on_player_final_damage() -> void:
	print("ELE LEVOU DANOOOO")
	$"Player Final/Camera2D".flash_damage()


func _on_player_final_is_death() -> void:
	print(get_tree().change_scene_to_file("res://Prefabs/menu_initial.tscn"))
