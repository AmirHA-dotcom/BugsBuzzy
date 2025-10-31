extends CharacterBody3D

@export var speed: float = 6.0
@export var chase_speed: float = 9.9
@export var field_of_view_degrees: float = 90.0
@export var patrol_radius: float = 20.0
@export var min_move_distance: float = 0.1  # minimum horizontal distance to attempt movement
@export var patrol_interval: float = 5.0

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var player_detector: Area3D = $PlayerDetector
@onready var vision_ray: RayCast3D = $VisionRay

enum State { PATROL, CHASE }
var state: State = State.PATROL
var player_target: Node3D = null
var patrol_timer: Timer
var view_cone_dot_product: float

func _ready() -> void:
	# connect detector signals
	player_detector.body_entered.connect(_on_player_detector_body_entered)
	player_detector.body_exited.connect(_on_player_detector_body_exited)

	# patrol timer
	patrol_timer = Timer.new()
	patrol_timer.wait_time = patrol_interval
	patrol_timer.autostart = true
	patrol_timer.one_shot = false
	patrol_timer.timeout.connect(get_new_patrol_point)
	add_child(patrol_timer)

	view_cone_dot_product = cos(deg_to_rad(field_of_view_degrees / 2.0))

	# If nav map already exists, pick first patrol point, otherwise wait for map change
	if nav_agent.get_navigation_map() != RID():
		get_new_patrol_point()
	else:
		NavigationServer3D.map_changed.connect(_on_nav_map_ready)

	# Safety: ensure raycast is enabled
	vision_ray.enabled = true

func _on_nav_map_ready(map_rid):
	if nav_agent.get_navigation_map() == map_rid:
		get_new_patrol_point()

func _physics_process(delta: float) -> void:
	# update chase/patrol target selection
	if player_target:
		if can_see_player(player_target):
			state = State.CHASE
		else:
			# if player is detected but not visible, keep chasing last known (optional)
			# here we'll return to patrol if not visible:
			state = State.PATROL

	match state:
		State.PATROL:
			_patrol_process(delta)
		State.CHASE:
			_chase_process(delta)

	# gravity
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		velocity.y = 0.0

	# perform movement
	move_and_slide()

func _patrol_process(delta: float) -> void:
	# pick new patrol target if we reached current one
	if nav_agent.is_target_reached():
		get_new_patrol_point()

	_move_along_agent_path(delta, speed)

func _chase_process(delta: float) -> void:
	if player_target:
		# flatten target Y to agent's plane so path stays on navmesh level
		var target_pos: Vector3 = player_target.global_position
		target_pos.y = global_position.y
		# if target is not reachable directly, find closest reachable point on navmesh
		if nav_agent.get_navigation_map() != RID():
			nav_agent.set_target_position(target_pos)
			if not nav_agent.is_target_reachable():
				var safe = NavigationServer3D.map_get_closest_point(nav_agent.get_navigation_map(), target_pos)
				nav_agent.set_target_position(safe)
	else:
		# lost player -> resume patrol
		state = State.PATROL
		get_new_patrol_point()

	_move_along_agent_path(delta, chase_speed)

func _move_along_agent_path(delta: float, current_speed: float) -> void:
	if nav_agent.get_navigation_map() == RID():
		return # no navigation map yet

	# get next path position from nav agent
	var next_path_pos: Vector3 = nav_agent.get_next_path_position()
	# compute horizontal direction only
	var to_next: Vector3 = next_path_pos - global_position
	to_next.y = 0
	var horiz_dist = to_next.length()

	# debug prints (comment out for clean log)
	# print("Next path pos:", next_path_pos, "Agent pos:", global_position, "dist:", horiz_dist)

	if horiz_dist > min_move_distance:
		var direction = to_next.normalized()
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		look_at(global_position + Vector3(direction.x, 0, direction.z), Vector3.UP)
	else:
		# very close to next path point - stop horizontal movement
		velocity.x = 0
		velocity.z = 0

	# If agent is stalled (next_path_pos equals current pos repeatedly), try small recovery:
	if nav_agent.is_navigation_finished() and not nav_agent.is_target_reached():
		# Re-request path to force recompute
		var t = nav_agent.get_target_position()
		nav_agent.set_target_position(t)

func get_new_patrol_point() -> void:
	if nav_agent.get_navigation_map() == RID():
		return

	# sample random point in XZ around us, then clamp Y to current plane
	var rand_pos = (Vector3(randf(), 0.0, randf()) - Vector3(0.5, 0.0, 0.5)) * patrol_radius
	var target = global_position + rand_pos
	target.y = global_position.y

	# get closest reachable point on navmesh
	var map = nav_agent.get_navigation_map()
	if map != RID():
		var safe_point = NavigationServer3D.map_get_closest_point(map, target)
		# guard: if safe_point is valid (non-zero), set it
		if safe_point != Vector3.ZERO:
			nav_agent.set_target_position(safe_point)
		else:
			# fallback: set to agent current position (no-op) and try again next timer tick
			nav_agent.set_target_position(global_position)
	else:
		# no map - do nothing
		pass

# --------------------
# Senses & signals
# --------------------
func can_see_player(player: Node3D) -> bool:
	# forward is -Z in Godot transform
	var robot_forward = -global_transform.basis.z.normalized()
	var to_player = (player.global_position - global_position).normalized()
	# check cone
	if robot_forward.dot(to_player) < view_cone_dot_product:
		return false

	# raycast - set target relative to raycast node (RayCast3D expects local target)
	vision_ray.target_position = to_local(player.global_position)
	vision_ray.force_raycast_update()

	if vision_ray.is_colliding():
		if vision_ray.get_collider() == player:
			return true

	return false

func _on_player_detector_body_entered(body: Node3D) -> void:
	# adjust type check to match your Player class name
	if body is Node3D and body.name.to_lower().find("player") != -1:
		player_target = body
		state = State.CHASE

func _on_player_detector_body_exited(body: Node3D) -> void:
	if body == player_target:
		player_target = null
		state = State.PATROL
		get_new_patrol_point()
