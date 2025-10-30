extends CharacterBody3D

@export var speed := 3.0
@export var wander_radius := 10.0  # How far to pick random destinations
@export var pause_time := 1.5      # Pause before picking a new destination

var agent: NavigationAgent3D
var gravity := 20
var timer := 0.0

func _ready():
	agent = $NavigationAgent3D
	agent.path_desired_distance = 0.3
	agent.target_desired_distance = 0.5
	_pick_new_target()

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# If we’ve reached the current target, wait and pick a new one
	if agent.is_navigation_finished():
		timer += delta
		if timer > pause_time:
			_pick_new_target()
			timer = 0.0
		velocity.x = move_toward(velocity.x, 0, 2 * delta)
		velocity.z = move_toward(velocity.z, 0, 2 * delta)
	else:
		# Move toward the next path point
		var next_pos = agent.get_next_path_position()
		var direction = (next_pos - global_position).normalized()
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		move_and_slide()
		
		# Rotate toward movement direction
		if direction.length() > 0.01:
			look_at(global_position + direction, Vector3.UP)

func _pick_new_target():
	# Pick a random point near the imposter
	var random_offset = Vector3(
		randf_range(-wander_radius, wander_radius),
		0,
		randf_range(-wander_radius, wander_radius)
	)
	var new_target = global_position + random_offset

	# Ask the navigation system to find the nearest valid point
	var nav = get_world_3d().navigation_map
	var valid_point = NavigationServer3D.map_get_closest_point(nav, new_target)

	agent.target_position = valid_point
