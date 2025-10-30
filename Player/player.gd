# Player Controller (Godot 4.x)
class_name Player
extends CharacterBody3D

@export var player_id: int = 1
@onready var camera: Camera3D = $Camera3D

const SPEED: float = 10.0
const JUMP_VELOCITY: float = 4.5
const ROTATION_SPEED: float = 3.0

# Ability config
@export var max_ability_count: int = 5
var ability_left: int
@export var ability_mesh: PackedScene   # assign a small Node3D scene with a MeshInstance3D (no physics)

func _ready() -> void:
	# camera culling (shared + player-specific)
	camera.cull_mask = 0
	camera.set_cull_mask_value(1, true)              # shared visual layer
	if player_id == 1:
		camera.set_cull_mask_value(2, true)          # P1-only layer
	elif player_id == 2:
		camera.set_cull_mask_value(3, true)          # P2-only layer

	ability_left = max_ability_count

func _physics_process(delta: float) -> void:
	# gravity
	if !is_on_floor():
		velocity += get_gravity() * delta

	# per-player jump
	if player_id == 1 and Input.is_action_just_pressed("p1_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	elif player_id == 2 and Input.is_action_just_pressed("p2_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# rotation + movement (your original logic)
	var input_dir: Vector2 = Vector2.ZERO
	if player_id == 1:
		input_dir = Input.get_vector("p1_move_left", "p1_move_right", "p1_move_up", "p1_move_down")
		if Input.is_action_pressed("p1_rotate_right"):
			rotation.y -= ROTATION_SPEED * delta
		elif Input.is_action_pressed("p1_rotate_left"):
			rotation.y += ROTATION_SPEED * delta
	elif player_id == 2:
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

# ---------- ability helpers ----------

func _try_spawn_ability() -> void:
	if ability_left <= 0:
		print("Player %d: no charges left." % player_id)
		return
	if ability_mesh == null:
		push_error("Assign 'ability_mesh' (PackedScene) on Player %d." % player_id)
		return

	var instance: Node3D = ability_mesh.instantiate()
	instance.global_position = _ground_position_under_player()
	_disable_any_colliders(instance)   # ensure no collisions
	get_tree().current_scene.add_child(instance)     # add to world

	ability_left -= 1
	print("Player %d ability used. Remaining: %d" % [player_id, ability_left])

# Find a nice placement on the floor below the player (so it’s not inside the capsule)
func _ground_position_under_player() -> Vector3:
	var from: Vector3 = global_transform.origin + Vector3(0, 1.5, 0)
	var to: Vector3 = from + Vector3(0, 20, 0)
	var params := PhysicsRayQueryParameters3D.create(from, to)
	params.exclude = [self]
	var hit := get_world_3d().direct_space_state.intersect_ray(params)

	if hit.has("position"):
		return (hit.position + Vector3(0, 0.02, 0))  # small lift to avoid z-fighting
	return global_transform.origin

# If the packed scene accidentally has physics nodes, disable them so there’s no capsule/blocking
func _disable_any_colliders(root: Node) -> void:
	if root is CollisionObject3D:
		# Remove from all layers/masks so it can't collide with anything
		var co := root as CollisionObject3D
		co.collision_layer = 0
		co.collision_mask = 0
	for child in root.get_children():
		_disable_any_colliders(child)
