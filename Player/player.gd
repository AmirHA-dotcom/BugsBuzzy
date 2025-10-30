#Player Controller
extends CharacterBody3D

@export var	 player_id = 1

const SPEED = 7.0
const JUMP_VELOCITY = 4.5
const ROTATION_SPEED = 3.0 # Speed at which the player rotates when pressing Q/E

func _physics_process(delta: float) -> void:
	# Add gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle movement/deceleration.
	var input_dir := Vector2.ZERO
	
	if player_id == 1:
		input_dir = Input.get_vector("p1_move_left", "p1_move_right", "p1_move_up", "p1_move_down");
		if Input.is_action_pressed("p1_rotate_right"):  
			rotation.y -= ROTATION_SPEED * delta
		elif Input.is_action_pressed("p1_rotate_left"): 
			rotation.y += ROTATION_SPEED * delta
	elif player_id == 2:
		input_dir = Input.get_vector("p2_move_left", "p2_move_right", "p2_move_up", "p2_move_down");
		if Input.is_action_pressed("p2_rotate_right"):  
			rotation.y -= ROTATION_SPEED * delta
		elif Input.is_action_pressed("p2_rotate_left"): 
			rotation.y += ROTATION_SPEED * delta
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	

	move_and_slide()
