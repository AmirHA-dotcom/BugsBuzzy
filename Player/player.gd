extends CharacterBody3D

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
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# Handle rotation with Q and E
	if Input.is_action_pressed("rotate_right"):  
		rotation.y -= ROTATION_SPEED * delta
	elif Input.is_action_pressed("rotate_left"): 
		rotation.y += ROTATION_SPEED * delta

	move_and_slide()
