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
	public override void _Ready()
	{
		
		playerTransform = GetNode<Node2D>("Sprite2DPlayer");
		playerAnimator = GetNode<AnimationTree>("AnimationTree");
		_animStateMachine = (AnimationNodeStateMachinePlayback)playerAnimator.Get("parameters/playback");

		attack_area.Monitoring = false;
		attack_area.Monitorable = true;
		attack_area.BodyEntered += OnAttackAreaBodyEntered;

		GD.Print("Player pronto");
	}

	public void GetInput()
	{

		if (inputDirection > 0 && is_Running == false )
		{
			//_animStateMachine.Travel("Walk");

			playerTransform.Scale = new Vector2(-1, 1);

			playerAnimator.Set("parameters/conditions/is_run", false);
			playerAnimator.Set("parameters/conditions/is_walk", true);
			playerAnimator.Set("parameters/conditions/idle", false);
			velocity.X = inputDirection * moveSpeed;
		}
		else if (inputDirection > 0 && is_Running == true )
		{
			playerTransform.Scale = new Vector2(-1, 1);

			playerAnimator.Set("parameters/conditions/is_run", true);
			playerAnimator.Set("parameters/conditions/is_walk", false);
			playerAnimator.Set("parameters/conditions/idle", false);
			velocity.X = inputDirection * moveSpeed * 2;
		}
		else if (inputDirection < 0 && is_Running == false )
		{
			//_animStateMachine.Travel("Walk");

			playerTransform.Scale = new Vector2(1, 1);

			playerAnimator.Set("parameters/conditions/is_run", false);
			playerAnimator.Set("parameters/conditions/is_walk", true);
			playerAnimator.Set("parameters/conditions/idle", false);
			velocity.X = inputDirection * moveSpeed;
		}
		else if (inputDirection < 0 && is_Running == true )
		{
			playerTransform.Scale = new Vector2(1, 1);

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
		velocity = Velocity;
		inputDirection = Input.GetAxis("Left", "Right");
		//GD.Print(inputDirection);
		//GD.Print(velocity);
		GetInput();
		if (IsOnFloor())
		{
			is_Jumping = false;
			velocity.Y = 0;
		}
		else
		{

			
			velocity.Y += gravity * (float)delta;
		}




		if (Input.IsActionPressed("Run"))
		{
			is_Running = true;
		}
		else
		{
			is_Running = false;
		}
		if (Input.IsActionJustPressed("Attack"))
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





		MoveAndSlide();
		Velocity = velocity;

	}

	public void Attack()
	{
		attack_sound.Play();
		 GD.Print("ATAQUE!");
		is_attacking = true;
		attack_area.Monitoring = true;

		// Desativa após 0.25s
		GetTree().CreateTimer(1f).Timeout += () =>
		{
			GD.Print("atacou");
			attack_area.Monitoring = false;
			is_attacking = false;
		};
	}

	public void ApplyDamage(int damage)
	{
		if (is_death || is_taking_damage)
			return;

		health -= damage;
		is_taking_damage = true;

		GD.Print("Player tomou dano. Vida: ", health);

		

		// Pequeno knockback
		Velocity = new Vector2(-300 * Scale.X, -150);

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
	private void OnAttackAreaBodyEntered(Node2D body)
	{
		GD.Print("COLIDIU COM: ", body.Name);

		if (body.IsInGroup("Enemies"))
		{
			GD.Print("DANO APLICADO");
			body.Call("ApplyDamage", damage_power);
		}
	}

}
