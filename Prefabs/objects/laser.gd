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
