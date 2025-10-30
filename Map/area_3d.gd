extends Area3D

# Signal for when a player wins
signal player_won

# This function is triggered when an object enters the area
func _on_Win_Point_body_entered(body: Node):
	# Check if the object that collided is the player
	if body.name == "Player":  # Ensure the player's node is named "Player"
		print("You Won!")
		emit_signal("player_won")  # Emit the win signal if needed for further use
		# You can add more logic here, like triggering a victory screen or stopping the game.
