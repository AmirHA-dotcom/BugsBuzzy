extends Area3D

# When the player enters the trap area
func _ready():
	body_entered.connect(_on_body_entered)

# This function is called when the player collides with the trap
func _on_body_entered(body: Node) -> void:
	if body is Player:
		# For example, the player falls down when entering the trap
		print("Player fell into the hole!")
		# You can apply a force or simply move the player to simulate falling
		body.global_position.y -= 5  # Makes the player fall down (adjust the value)
		await get_tree().create_timer(0.8).timeout
		
		body.respawn_to_checkpoint()
