extends Node2D

@export var velocity := 1
var direction := Vector2(0, 0)
var laser_owner := "Enemy"
var damage := 1


func _process(delta: float) -> void:
	position += direction * velocity


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# som
		body.ApplyDamage(damage)
		queue_free()




func _on_area_2d_area_entered(area: Area2D) -> void:
	var body = area.get_parent()
	if body.is_in_group("player"):
		direction = direction * -1
		laser_owner = "player"
		$Icon.modulate = Color(0.133, 0.288, 0.841, 1.0)
	if body.is_in_group("Enemies") and laser_owner == "player":
		body.ApplyDamage(damage)
		queue_free()
