extends CharacterBody2D


@export var SPEED := 300.0
const JUMP_VELOCITY = -400.0

@onready var object_detecter := $RayCast2D as RayCast2D

var direction := 1.0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if object_detecter.is_colliding():
		direction = direction * -1
		if $sprite.flip_h:
			$sprite.flip_h = false
		else:
			$sprite.flip_h = true 
		
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
