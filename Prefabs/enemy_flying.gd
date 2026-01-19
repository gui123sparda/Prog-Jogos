#extends "res://Scripts/enemy.gd"



extends CharacterBody2D

enum StateMachine {IDLE, WALK, ATTACK, DEATH}


const BULLET_SCENE: PackedScene = preload("res://Prefabs/objects/laser.tscn")

@export var SPEED := 90.0
@export var DIST_FOLLOW := 300.0
@export var DIST_ATTACK := 500.0
@export var cooldown_attack_init := 2.0
@export var damage_power := 1
@export var player : CharacterBody2D = null
#@onready var object_detecter := $RayCast2D as RayCast2D
@onready var animation_tree: AnimationTree = $AnimationTree
#@onready var attack_raycast: RayCast2D = $attack_raycast


var att_power := 10
var health := 3
var death := false
var state := StateMachine.IDLE
var machine_state
var is_attacking := false
var is_taking_damage := false
var can_attack := true
var attack_cooldown_time := 1.0

# Separar fisica do update

signal damege

func get_distance_to_player() -> float:
	if not player or not is_instance_valid(player):
		return 0.0
	return global_position.distance_to(player.global_position)

func get_direction_to_player() -> Vector2:
	if not player or not is_instance_valid(player):
		return Vector2.ZERO
	var diff = player.global_position - global_position
	if diff.length() > 0:
		return diff.normalized()
	return Vector2.ZERO

func _ready() -> void:
	machine_state = animation_tree.get("parameters/playback")
	
	#add_user_signal("damege")

func _run_physics(delta:float) -> void:
	if not is_attacking and not is_taking_damage and can_attack:
		if state != StateMachine.DEATH:
			if health <= 0 :
				state = StateMachine.DEATH

func _follow_player():
	$sprite.flip_h = get_direction_to_player().x > 0


func check_attack():
	if get_distance_to_player() < DIST_ATTACK and can_attack:
		state = StateMachine.ATTACK


func shoot() -> void:
	var bullet := BULLET_SCENE.instantiate()
	bullet.global_position = self.global_position
	bullet.direction = get_direction_to_player()
	get_tree().current_scene.add_child(bullet)


func _process(delta: float) -> void:
	check_attack()
	_follow_player()
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
				machine_state.travel("idle")
				is_attacking = false
				#_run_physics(delta)


			StateMachine.ATTACK:
				if not is_attacking and not death and can_attack:
					is_attacking = true
					can_attack = false
					shoot()
					await_damage(0.5)
					start_attack_cooldown()
					state = StateMachine.IDLE
			
			StateMachine.DEATH:
				if not death:
					death = true
					machine_state.travel("death")
					await animation_tree.animation_finished
					queue_free()

func await_damage(time:float):
	emit_signal("damege",time)

func ApplyDamage(damage_amount: int = 0) -> void:
	if state == StateMachine.DEATH  and is_taking_damage:
		return
	
	health -= damage_amount
	if health <= 0:
		state = StateMachine.DEATH

	is_taking_damage = true
	is_attacking = false
	
	
	machine_state.travel("takeDamege")
	print(self.name + " tomou dano, vida restante: ", health)
	await_damage(2)


func start_attack_cooldown() -> void:
	await get_tree().create_timer(cooldown_attack_init).timeout
	can_attack = true
	is_attacking = false

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name == "takeDamege":
		is_taking_damage = false
		if health <= 0:
			state = StateMachine.DEATH
			# Chama _physics_process para executar o estado DEATH
			await get_tree().process_frame
			_process(get_process_delta_time())
		else:
			state = StateMachine.IDLE


func _on_area_2d_body_entered(body: Node2D) -> void:
	print(body.get_groups())
	if body.is_in_group("player"):
		var _player = body.ApplyDamage(damage_power)
