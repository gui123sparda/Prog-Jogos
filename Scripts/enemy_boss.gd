extends CharacterBody2D

enum StateMachine {INIT, ATTACK, ATTACK2, IDLE, GET_READY, DEATH}
"""
INIT -> Animaçao inicial
ATTACK -> Ataque de projeteis
ATTACK2 -> Dar um soco Grandao
DAMAGE -> Levar dano
DEATH -> Animaçao de morte
"""
@export var SPEED := 90.0
@export var DIST_FOLLOW := 300.0
@export var DIST_ATTACK := 80.0
@export var cooldown_attacks := 3.0 #Espera entre ataques
@export var cooldown_attack2_init := 0.75


@export var damage_power := 1

@export var player_ref : CharacterBody2D = null 
@export var bullet_point : Node2D = null 


@onready var animation_tree: AnimationTree = $AnimationTree

const BULLET_SCENE: PackedScene = preload("res://Prefabs/objects/laser.tscn")


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


#ATACKING
var _max_times_shouting = 1
var _times_shouting = 0
var current_attack := StateMachine.ATTACK
var debug = true
var _attack_counting = 0.0

func _ready() -> void:
	machine_state = animation_tree.get("parameters/playback")

func get_direction_to_player(ref:Vector2 = global_position) -> Vector2:
	if not player_ref or not is_instance_valid(player_ref):
		return Vector2.ZERO
	var diff = player_ref.global_position - ref
	if diff.length() > 0:
		return diff.normalized()
	return Vector2.ZERO

func shoot(angle := 0) -> void:
	var bullet := BULLET_SCENE.instantiate()
	bullet.global_position = bullet_point.global_position
	var direction := get_direction_to_player(bullet.global_position)
	bullet.direction = direction.rotated(deg_to_rad(angle))
	
	get_tree().current_scene.add_child(bullet)


func _die():
	is_attacking = false
	death = true
	state = StateMachine.DEATH
	
	$area_dano/CollisionShape2D.disabled = true
	$area_dano.monitorable = false
	$area_dano.monitoring = false


func do_attack(atk_count):
	if not (atk_count / cooldown_attacks <= 1):
		print(atk_count / cooldown_attacks)
		return true
	

func _process(delta: float) -> void:
	
	if do_attack(_attack_counting):
		state = StateMachine.GET_READY
		#Escolher qual aleatoriamente
		_attack_counting = 0
	#print(_attack_counting)
	if health < 0 :
		_die()
		# INIT, ATTACK, ATTACK2, DAMAGE, DEATH
	
	if Input.is_action_just_pressed("ui_down"):
		ApplyDamage(1)
	
	match state:
		StateMachine.INIT:
			velocity.x = 0
			machine_state.travel("Idle")
			is_attacking = false
			#_run_physics(delta)

		# Entre as pausas de ataques
		StateMachine.IDLE:
			_attack_counting += delta
			machine_state.travel("Idle")
			is_attacking = false
			#_run_physics(delta)
				
		
		StateMachine.GET_READY:
			machine_state.travel("awaiting")
			#await get_tree().create_timer(1).timeout
			await get_tree().create_timer(cooldown_attack2_init).timeout
			var random_attack = [StateMachine.ATTACK, StateMachine.ATTACK2].pick_random()
			state = random_attack
		
		
		StateMachine.ATTACK:
			if not is_attacking and not death:
				is_attacking = true
				can_attack = false
				machine_state.travel("attack")
				await animation_tree.animation_finished
				#await get_tree().create_timer(cooldown_attack_init).timeout
				start_attack_cooldown(3)
				state = StateMachine.IDLE

		StateMachine.ATTACK2:
			if _times_shouting <= _max_times_shouting:
				if not is_attacking and not death:
					
					is_attacking = true
					can_attack = false
					shoot(30)
					shoot()
					shoot(-30)
					_times_shouting += 1
					start_attack_cooldown(3)

			else:
				_times_shouting = 0
				state = StateMachine.IDLE


		StateMachine.DEATH:
			if not death:
				death = true
				machine_state.travel("death")
				await animation_tree.animation_finished
				queue_free()


func ApplyDamage(damage_amount: int = 0) -> void:
	if state == StateMachine.DEATH  and is_taking_damage:
		return
	
	health -= damage_amount
	is_taking_damage = true
	is_attacking = false
	
	machine_state.travel("takeDamege")
	print(self.name + " tomou dano, vida restante: ", health)


func stop(time):
	await get_tree().create_timer(time).timeout


func start_attack_cooldown(timeout:float = attack_cooldown_time) -> void:
	print("parou de atacar")
	await get_tree().create_timer(timeout).timeout
	can_attack = true
	is_attacking = false

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	print(anim_name)
	if anim_name == "takeDamege":
		is_taking_damage = false
		if health <= 0:
			state = StateMachine.DEATH
			# Chama _physics_process para executar o estado DEATH
			await get_tree().process_frame
			_process(get_process_delta_time())
		else:
			state = StateMachine.INIT


func _on_area_2d_body_entered(body: Node2D) -> void:
	print(body.get_groups())
	if body.is_in_group("player"):
		print("entoru")
		var _player = body.ApplyDamage(damage_power)
