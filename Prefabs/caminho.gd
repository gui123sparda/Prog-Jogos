extends Path2D

@export var speed: float

var running := true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if running:
		$PathFollow2D.progress += delta * speed


func _on_fly_enemy_damege(time) -> void:
	running = false
	await get_tree().create_timer(time).timeout
	running= true
	
