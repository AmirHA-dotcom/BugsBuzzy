extends CharacterBody3D

@export var speed: float = 15.0
@export var stuck_time: float = 0.2  # seconds before rotating
@export var move_threshold: float = 0.05  # min movement distance to count as moving

var direction := Vector3.FORWARD
var last_position := Vector3.ZERO
var time_since_moved := 0.0
var gravity :=20

func _ready():
	last_position = global_position
	randomize() # for optional randomness later
	direction = -direction.normalized()

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	# Move forward
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	move_and_slide()

	# Check how far we’ve moved since last frame
	var moved_distance = (global_position - last_position).length()

	if moved_distance < move_threshold:
		time_since_moved += delta
	else:
		time_since_moved = 0.0

	# Rotate if stuck for too long
	if time_since_moved > stuck_time:
		_rotate_90_degrees()
		time_since_moved = 0.0

	last_position = global_position


func _rotate_90_degrees():
	# Choose a random multiple of 90°: 1, 2, or 3
	var multiples = [1, 2, 3]
	var choice = multiples[randi() % multiples.size()]
	var angle = deg_to_rad(90 * choice)  # 90°, 180°, or 270°

	# Rotate the direction vector
	
	direction = direction.rotated(Vector3.UP, angle).normalized()
	
	# Visually face the new direction
	look_at(global_position - direction, Vector3.UP)
	print("🔁 Rotated by ", 90 * choice, "° because stuck")
