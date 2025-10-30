extends Area3D

# When the player enters the trigger zone
func _on_Area3D_body_entered(body):
	print("meow")
	if body.name == "Player":  # Check if the body entering is the player
		print("Won!")
