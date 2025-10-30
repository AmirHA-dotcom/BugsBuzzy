# Trap.gd
extends Area3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body is Player:                      # catches BOTH players
		print("Player %d died!" % body.player_id)
		# If you have respawn:
		# body.respawn_to_checkpoint()
