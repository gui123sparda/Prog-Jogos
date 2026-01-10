#extends "res://Scripts/enemy.gd"



extends CharacterBody2D

enum StateMachine {IDLE, WALK, ATTACK, DEATH}

@export var SPEED := 90.0
@export var DIST_FOLLOW := 300.0
@export var DIST_ATTACK := 80.0
@export var cooldown_attack_init := 2.0
@export var damage_power := 1

#@onready var object_detecter := $RayCast2D as RayCast2D
@onready var animation_tree: AnimationTree = $AnimationTree
#@onready var attack_raycast: RayCast2D = $attack_raycast

#var direction := 1.0
var att_power := 10
var health := 3
var animation := ''
var death := false
var state := StateMachine.IDLE
var machine_state
var is_attacking := false
var is_taking_damage := false
var can_attack := true
var attack_cooldown_time := 1.0

# Separar fisica do update

signal damege

func _ready() -> void:
	machine_state = animation_tree.get("parameters/playback")
	#add_user_signal("damege")

func _run_physics(delta:float) -> void:
	if not is_attacking and not is_taking_damage and can_attack:
		#if object_detecter.is_colliding() :
			#direction = direction * -1
			#scale.x *= -1
		#if direction:
			#velocity.x = direction * SPEED
		#else:
			#velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
		if state != StateMachine.DEATH:
			if health <= 0 :
				state = StateMachine.DEATH
			elif velocity.x == 0:
				state = StateMachine.IDLE
			elif velocity.x != 0 :
				state = StateMachine.WALK
			move_and_slide()
			#if attack_raycast.is_colliding() and health > 0:
			#if health > 0:
				#state = StateMachine.ATTACK


func _physics_process(delta: float) -> void:
	if health < 0 :
		is_attacking = false
		death = true
		state = StateMachine.DEATH
		$CollisionShape2D.disabled = true
		$area_dano/CollisionShape2D.disabled = true
		$area_dano.monitorable = false
		$area_dano.monitoring = false

		
	if not is_taking_damage:
		match state:
			StateMachine.IDLE:
				velocity.x = 0
				machine_state.travel("idle")
				is_attacking = false
				_run_physics(delta)

				
				
			StateMachine.WALK:
				if not death:
					#velocity.x = direction * SPEED
					machine_state.travel("walk")
					_run_physics(delta)
					
					
				
			StateMachine.ATTACK:
				if not is_attacking and not death and can_attack:
					is_attacking = true
					can_attack = false
					machine_state.travel("attack")
					await animation_tree.animation_finished
					#await get_tree().create_timer(cooldown_attack_init).timeout
					state = StateMachine.IDLE
					start_attack_cooldown()
					state = StateMachine.IDLE
			
			StateMachine.DEATH:
				if not death:
					death = true
					machine_state.travel("death")
					await animation_tree.animation_finished
					queue_free()

func await_damage(time:float):
	emit_signal("damege")

func aplly_damege(damage_amount: int = 0) -> void:
	if state == StateMachine.DEATH  and is_taking_damage:
		return
	
	health -= damage_amount
	is_taking_damage = true
	is_attacking = false
	
	
	machine_state.travel("takeDamege")
	print(self.name + " tomou dano, vida restante: ", health)
	await_damage(2)

		
func start_attack_cooldown() -> void:
	await get_tree().create_timer(attack_cooldown_time).timeout
	can_attack = true
	is_attacking = false

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name == "takeDamege":
		is_taking_damage = false
		if health <= 0:
			state = StateMachine.DEATH
			# Chama _physics_process para executar o estado DEATH
			await get_tree().process_frame
			_physics_process(get_process_delta_time())
		else:
			state = StateMachine.IDLE


func _on_area_2d_body_entered(body: Node2D) -> void:
	print(body.get_groups())
	if body.is_in_group("player"):
		var _player = body.aplly_damege(damage_power)
