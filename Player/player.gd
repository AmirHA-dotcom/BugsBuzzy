# Player Controller (Godot 4.x)
class_name Player

extends CharacterBody3D

# TOP of the file (under class_name)
signal ability_changed(player_id: int, left: int, max: int)


@export var player_id: int = 1
@onready var camera: Camera3D = $Camera3D   # if using SpringArm, change to $"SpringArm3D/Camera3D"
@onready var meshInstance: MeshInstance3D = $MeshInstance3D
@onready var omniLight: OmniLight3D = $OmniLight3D


const SPEED: float = 10.0
const JUMP_VELOCITY: float = 4.5
const ROTATION_SPEED: float = 3.0

# Ability config
@export var max_ability_count: int = 5
var ability_left: int
@export var ability_mesh: PackedScene   # assign a Node3D scene (no physics)

# Respawn config
@export var respawn_point_path: NodePath
var respawn_point: Node3D

func _emit_ability():
	ability_changed.emit(player_id, ability_left, max_ability_count)

func reset_ability():
	ability_left = max_ability_count
	_emit_ability()


func _ready() -> void:
	# Camera layer setup
	camera.cull_mask = 0
	camera.set_cull_mask_value(1, true)
	if player_id == 1:
		camera.set_cull_mask_value(2, true)
	elif player_id == 2:
		camera.set_cull_mask_value(3, true)
		var mat = meshInstance.get_surface_override_material(0)
		mat = mat.duplicate()
		if mat is StandardMaterial3D:
			mat.albedo_color = Color8(0, 191, 255)
			mat.emission = Color8(0, 191, 255)
		meshInstance.set_surface_override_material(0, mat)
		omniLight.light_color = Color8(0, 191, 255)
	
		

	ability_left = max_ability_count

	ability_left = max_ability_count
	_emit_ability()   # <-- tell UI initial value

	# get respawn point node
	respawn_point = get_node_or_null(respawn_point_path)
	if respawn_point == null:
		push_error("Player %d: respawn point not assigned!" % player_id)

func _physics_process(delta: float) -> void:
	# gravity
	if !is_on_floor():
		velocity += get_gravity() * delta

	# per-player jump
	if player_id == 1 and Input.is_action_just_pressed("p1_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	elif player_id == 2 and Input.is_action_just_pressed("p2_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# rotation + movement
	var input_dir: Vector2 = Vector2.ZERO

	if player_id == 1:
		input_dir = Input.get_vector("p1_move_left", "p1_move_right", "p1_move_up", "p1_move_down")
		if Input.is_action_pressed("p1_rotate_right"):
			rotation.y -= ROTATION_SPEED * delta
		elif Input.is_action_pressed("p1_rotate_left"):
			rotation.y += ROTATION_SPEED * delta
	else:
		input_dir = Input.get_vector("p2_move_left", "p2_move_right", "p2_move_up", "p2_move_down")
		if Input.is_action_pressed("p2_rotate_right"):
			rotation.y -= ROTATION_SPEED * delta
		elif Input.is_action_pressed("p2_rotate_left"):
			rotation.y += ROTATION_SPEED * delta

	var dir3: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if dir3 != Vector3.ZERO:
		velocity.x = dir3.x * SPEED
		velocity.z = dir3.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# ability trigger
	if player_id == 1 and Input.is_action_just_pressed("p1_ability"):
		_try_spawn_ability()
	elif player_id == 2 and Input.is_action_just_pressed("p2_ability"):
		_try_spawn_ability()

	move_and_slide()

# ---------- ability logic ----------

func _try_spawn_ability() -> void:
	if ability_left <= 0:
		print("Player %d: no charges left." % player_id)
		return
	if ability_mesh == null:
		push_error("Assign 'ability_mesh' for Player %d" % player_id)
		return

	var instance: Node3D = ability_mesh.instantiate()
	instance.global_position = _ground_position_under_player()
	_disable_any_colliders(instance)
	get_tree().current_scene.add_child(instance)

	ability_left -= 1

	_emit_ability()   # <-- update UI

	print("Player %d ability used. Remaining: %d" % [player_id, ability_left])

# Cast DOWN to find the ground
func _ground_position_under_player() -> Vector3:
	var from: Vector3 = global_transform.origin + Vector3(0, 1, 0)
	var to: Vector3 = from + Vector3(0, -5, 0) # cast downward
	var params := PhysicsRayQueryParameters3D.create(from, to)
	params.exclude = [self]
	var hit := get_world_3d().direct_space_state.intersect_ray(params)
	if hit.has("position"):
		return hit.position + Vector3(0, 0.05, 0)
	return global_transform.origin

func _disable_any_colliders(root: Node) -> void:
	if root is CollisionObject3D:
		var co := root as CollisionObject3D
		co.collision_layer = 0
		co.collision_mask = 0
	for child in root.get_children():
		_disable_any_colliders(child)

# ---------- respawn system ----------

func respawn_to_checkpoint() -> void:
	if respawn_point == null:
		return
		# teleport safely after physics step
	call_deferred("_do_respawn")

func _do_respawn() -> void:
	global_transform.origin = respawn_point.global_transform.origin + Vector3(0, 0.5, 0)
	velocity = Vector3.ZERO
