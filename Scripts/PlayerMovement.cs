using Godot;
using System;

using System.Reflection.Metadata.Ecma335;



public partial class PlayerMovement : CharacterBody2D
{

	[Export]
	public float moveSpeed = 400f;
	[Export]
	public float jumpSpeed = -1000f;
	public float gravity = (float)ProjectSettings.GetSetting("physics/2d/default_gravity");
	[Export]
	public Node2D playerTransform;

	[Export]
	public AudioStreamPlayer attack_sound;

	[Export] public int damage_power = 1;
	[Export] public int health = 3;

	[Export] public Area2D attack_area;
	[Export] public CollisionShape2D collision_shape_2d;
	public Vector2 velocity;

	public bool is_Running = false;
	public bool is_Jumping = false;

	private bool is_attacking = false;
	private bool is_taking_damage = false;
	private bool is_invisible = false; // TODO: sistema de invencibilidade
	private bool animate_finished = true;
	private bool is_death = false;
	public float inputDirection;


	[Export]
	public AnimationTree playerAnimator;
	private AnimationNodeStateMachinePlayback _animStateMachine;
	
	
	
	
	
	
	
	
	
	
	[Signal]
	public delegate void DamageEventHandler();
	
	[Signal]
	public delegate void IsDeathEventHandler();
	
	
	
	public override void _Ready()
	{
		
		playerTransform = GetNode<Node2D>("Sprite2DPlayer");
		playerAnimator = GetNode<AnimationTree>("AnimationTree");
		_animStateMachine = (AnimationNodeStateMachinePlayback)playerAnimator.Get("parameters/playback");


		GD.Print("Player pronto");
	}



	public void GetInput()
	{

		if (inputDirection > 0 && is_Running == false )
		{
			//_animStateMachine.Travel("Walk");

			playerTransform.Scale = new Vector2(-1, 1);
			attack_area.Scale =  new Vector2(-1, 1);
			playerAnimator.Set("parameters/conditions/is_run", false);
			playerAnimator.Set("parameters/conditions/is_walk", true);
			playerAnimator.Set("parameters/conditions/idle", false);
			velocity.X = inputDirection * moveSpeed;
		}
		else if (inputDirection > 0 && is_Running == true )
		{
			playerTransform.Scale = new Vector2(-1, 1);
			attack_area.Scale =  new Vector2(-1, 1);

			playerAnimator.Set("parameters/conditions/is_run", true);
			playerAnimator.Set("parameters/conditions/is_walk", false);
			playerAnimator.Set("parameters/conditions/idle", false);
			velocity.X = inputDirection * moveSpeed * 2;
		}
		else if (inputDirection < 0 && is_Running == false )
		{
			//_animStateMachine.Travel("Walk");

			playerTransform.Scale = new Vector2(1, 1);
			attack_area.Scale =  new Vector2(1, 1);


			playerAnimator.Set("parameters/conditions/is_run", false);
			playerAnimator.Set("parameters/conditions/is_walk", true);
			playerAnimator.Set("parameters/conditions/idle", false);
			velocity.X = inputDirection * moveSpeed;
		}
		else if (inputDirection < 0 && is_Running == true )
		{
			playerTransform.Scale = new Vector2(1, 1);
			attack_area.Scale =  new Vector2(1, 1);


			playerAnimator.Set("parameters/conditions/is_run", true);
			playerAnimator.Set("parameters/conditions/is_walk", false);
			playerAnimator.Set("parameters/conditions/idle", false);
			velocity.X = inputDirection * moveSpeed * 2;
		}
		else if (IsOnFloor())
		{

			playerAnimator.Set("parameters/conditions/is_run", false);
			playerAnimator.Set("parameters/conditions/idle", true);
			playerAnimator.Set("parameters/conditions/is_walk", false);
			velocity.X = inputDirection;
		}

	}


	public override void _PhysicsProcess(double delta)
	{
		
		
		if (is_death) {
			_animStateMachine.Travel("death");
		}
		
		
		velocity = Velocity;
		inputDirection = Input.GetAxis("Left", "Right");
		//GD.Print(inputDirection);
		//GD.Print(velocity);
		if (!is_death) {
			
		GetInput();
		}
		if (IsOnFloor())
		{
			is_Jumping = false;
			velocity.Y = 0;
		}
		else
		{
			velocity.Y += gravity * (float)delta;
		}

		

if (!is_death) {
		if (Input.IsActionPressed("Run"))
		{
			is_Running = true;
		}
		else
		{
			is_Running = false;
		}
		if (Input.IsActionJustPressed("Attack") && !is_attacking)
		{
			Attack();
			_animStateMachine.Travel("Attack");
		}
		if (Input.IsActionPressed("Jump") && IsOnFloor())
		{
			_animStateMachine.Travel("Jump");
			is_Jumping = true;
			GD.Print("Pulou");
			velocity.Y = jumpSpeed;
		}

} else {
	velocity.X = inputDirection;
}



		MoveAndSlide();
		Velocity = velocity;

	}

	public void Attack()
	{
		attack_sound.Play();
		 GD.Print("ATAQUE!");
		//// Desativa após 0.25s
		//GetTree().CreateTimer(0.25f).Timeout += () =>
		//{
			//attack_area.Monitoring = false;
			//is_attacking = false;
		//};
	}

	public void ApplyDamage(int damage)
	{
		if (is_death || is_taking_damage)
			return;

		health -= damage;
		is_taking_damage = true;

		GD.Print("Player tomou dano. Vida: ", health);

		EmitSignal(SignalName.Damage);

		// Pequeno knockback
		if (IsOnFloor()) {
		Velocity = new Vector2(-3000 * Scale.X, -1500);
			
		} else {
		Velocity = new Vector2(-300 * Scale.X, -150);
			
		}

		GetTree().CreateTimer(0.3f).Timeout += () =>
		{
			is_taking_damage = false;
			if (health <= 0)
				is_death = true;
		};
	}

	// ===============================
	// HITBOX DO ATAQUE
	// ===============================
	public void OnAttackAreaBodyEntered(Node2D body)
	{

		if (body.IsInGroup("Enemies"))
		{
			//GD.Print("COLIDIU COM: ", body.Name);
			body.Call("ApplyDamage", damage_power);
		}
	}
	
	public void OnAnimationPlayerAnimationFinished(String anim_name){
		if (anim_name == "Attack") {
			is_attacking = false;
		} else if (anim_name == "death") {
			EmitSignal(SignalName.IsDeath);
			QueueFree();
		}
	}
	
	public void OnAttackColision(Area2D area) {
		Node boss = area.GetParent();
		GD.Print("COLIDIU COM: ", boss);
		if (boss.IsInGroup("boss")) {
			boss.Call("ApplyDamage", damage_power);
		}
		
	}

}
