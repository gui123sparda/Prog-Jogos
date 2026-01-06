# Exemplo de script em GDScript
extends CharacterBody2D
### TODO Terminar de fazer o sistema de invencibilidade
@export var velocidade := 200.0
@export var jump_velocidade := -400.0 
@export var run_acl := 1.5
@export var damage_power := 1
@export var health := 3
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var attack_area: Area2D = $attack_area
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
var machine_state

var gravity = 750.0

var is_moving:= false
var is_attacking := false
var is_taking_damage := false
var is_invisible := false
var animate_finished = true
var is_death := false


func _attack() -> void:
	pass


func _ready() -> void:
	machine_state = animation_tree.get("parameters/playback")


func _flip(direcao) -> void:
	attack_area.scale.x = direcao * -1
	collision_shape_2d.scale.x = direcao * -1

func _physics_process(delta):
	if is_death:
		machine_state.travel("death")
		
		
	
	
	
	var direcao = Vector2.ZERO # Vetor de direção inicial
	
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if not is_attacking and not is_taking_damage  and animate_finished:
		if Input.is_action_pressed("ui_right"):
			machine_state.travel("walk")
			direcao.x += velocidade

		elif Input.is_action_pressed("ui_left"):
			machine_state.travel("walk")
			direcao.x -= velocidade
		
		if Input.is_action_pressed("ui_down") and is_on_floor():
			velocity.y = jump_velocidade

	if Input.is_action_pressed("ui_up") and is_on_floor() and not is_taking_damage:
		is_attacking = true
		machine_state.travel("attack")
		
		await animation_tree.animation_finished
		



		# Normaliza o vetor de direção para que não se mova mais rápido diagonalmente
	if direcao.x != 0 or is_taking_damage:
		direcao.x = direcao.normalized().x
	else:
		machine_state.travel("idle")
	is_moving = direcao.x != 0
	
	if is_moving and not is_taking_damage:
		#$sprite.flip_h = (direcao.x > 0)
		_flip(direcao.x)
		
		#if  Input.is_action_pressed("ui_run"):
			#machine_state.travel("running")
			#velocity.x = direcao.x * velocidade * run_acl

	velocity.x = direcao.x * velocidade

	if not is_on_floor() and not is_taking_damage:
		if velocity.y < 0.0:
			machine_state.travel("jump")
		else:
			machine_state.travel("fall")

	
	
	# Move o personagem e trata colisões
	move_and_slide()
	#velocity.x = Vector2.ZERO.x


func aplly_damege(damage_amount: int = 0) -> void:
	if is_death or is_taking_damage or is_invisible:
		return
	
	health -= damage_amount
	is_taking_damage = true
	is_attacking = false
	velocity = Vector2(500 * scale.x ,-150)
	move_and_slide()
	animate_finished = false
	machine_state.travel("hit")
	#print("tomou dano, vida restante: ", health)
	
	if health <= 0:
		is_death = true


func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name == "death":
		queue_free()
	if anim_name == "attack":
		is_attacking = false
		#animate_finished = true
	
	
	if anim_name == "hit":
		is_taking_damage = false
		animate_finished = true

		if health <= 0:
			is_death = true
			


func _on_attack_area_body_entered(body: Node2D) -> void:
	print(body.get_groups())
	if body.is_in_group("Enemies"):
		if body.death != true:
			var _goblin = body.aplly_damege(damage_power)
