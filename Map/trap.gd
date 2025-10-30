extends Area3D

func _ready() -> void:
	# Safer than relying on editor wiring:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	# Adjust the name/class check to your player
	if body is CharacterBody3D and body.name == "Player":
		print("You Are Dead!")
