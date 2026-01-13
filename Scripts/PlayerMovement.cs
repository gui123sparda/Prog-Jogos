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

	public Vector2 velocity;

	public bool is_Running = false;
	public bool is_Jumping = false;
	public float inputDirection;


	[Export]
	public AnimationTree playerAnimator;
	private AnimationNodeStateMachinePlayback _animStateMachine;
	public override void _Ready()
	{
		playerTransform = GetNode<Node2D>("Sprite2DPlayer");
		playerAnimator = GetNode<AnimationTree>("AnimationTree");
		_animStateMachine = (AnimationNodeStateMachinePlayback)playerAnimator.Get("parameters/playback");
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
		GD.Print(inputDirection);
		GD.Print(velocity);
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
		if (Input.IsActionPressed("Attack"))
		{
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


}
