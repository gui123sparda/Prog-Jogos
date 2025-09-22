using Godot;
using System;


public partial class PlayerMovement : CharacterBody2D
{

	[Export]
	public float moveSpeed = 400f;
	[Export]
	public float jumpSpeed = -400f;
	public float gravity = (float)ProjectSettings.GetSetting("physics/2d/default_gravity");
	public Sprite2D sprite;

	public Vector2 velocity;
	public float inputDirection;

	public AnimationTree playerAnimator;
	public override void _Ready()
	{
		sprite = GetNode<Sprite2D>("Sprite2D");
		playerAnimator = GetNode<AnimationTree>("AnimationController");
	}

	public void GetInput()
	{
		if (inputDirection > 0)
		{
			playerAnimator.Set("parameters/conditions/isRunning", true);
			playerAnimator.Set("parameters/conditions/idle", false);           
			sprite.FlipH = true;
			velocity.X = inputDirection * moveSpeed;
		}
		else if (inputDirection < 0)
		{
			playerAnimator.Set("parameters/conditions/isRunning", true);
			playerAnimator.Set("parameters/conditions/idle", false);
			sprite.FlipH = false;
			velocity.X = inputDirection * moveSpeed;
		}
		if (inputDirection != 0)
		{
			velocity.X = inputDirection * moveSpeed;
		}
		else
		{
			playerAnimator.Set("parameters/conditions/idle", true);
			playerAnimator.Set("parameters/conditions/isRunning", false);
			velocity.X = inputDirection;
		}
		
	}

	public override void _PhysicsProcess(double delta)
	{
		velocity = Velocity;
		inputDirection = Input.GetAxis("Left", "Right");
		GD.Print(inputDirection);
		GD.Print(velocity);
		

		velocity.Y += gravity * (float)delta;

		if (Input.IsActionPressed("Jump"))
		{
			GD.Print("Pulou");
			velocity.Y = jumpSpeed;
		}

		GetInput();
		Velocity = velocity;
		MoveAndSlide();
		
	}
}
