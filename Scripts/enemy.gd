extends CharacterBody2D

enum StateMachine {IDLE, WALK, ATTACK, PARRY, DEATH}

@export var SPEED := 90.0
@export var DIST_FOLLOW := 300.0
@export var DIST_ATTACK := 80.0

@onready var object_detecter := $RayCast2D as RayCast2D

var direction := 1.0
var att_power := 10	
var health := 3
var animation := ''
var death := false
var state := StateMachine.WALK

func _physics_process(delta: float) -> void:
	
	match state:
		StateMachine.IDLE:
			pass
		StateMachine.WALK:
			# Add the gravity.
			if not is_on_floor():
				velocity += get_gravity() * delta
				
			if object_detecter.is_colliding():
				direction = direction * -1
				scale.x *= -1 
			if direction:
				velocity.x = direction * SPEED
			
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
			move_and_slide()
			

		StateMachine.ATTACK:
			pass
		StateMachine.DEATH:
			pass
	
	
	
	
	
	
	
