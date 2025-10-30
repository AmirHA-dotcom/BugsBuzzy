extends CharacterBody3D

@export var speed := 4.0
@export var target: NodePath  # Drag your player node here

var agent: NavigationAgent3D
var gravity := 20

func _ready():
	agent = $NavigationAgent3D
	agent.path_desired_distance = 0.3
	agent.target_desired_distance = 0.5

func _physics_process(delta):
	if not target:
		return

	var player = get_node_or_null(target)
	if player == null:
		return

	# Update agent’s destination
	agent.target_position = player.global_position

	if agent.is_navigation_finished():
		return

	# Get the next path point and move toward it
	var next_pos = agent.get_next_path_position()
	var direction = (next_pos - global_position).normalized()

	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	move_and_slide()

	# Optional: Face toward the movement direction
	if direction.length() > 0.01:
		look_at(global_position + direction, Vector3.UP)
