# WinPoint.gd
extends Area3D

var target_player_id: int = 1
signal player_won(player_id: int)

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body is Player and body.player_id == target_player_id:
		print("Player %d Won!" % target_player_id)
		player_won.emit(target_player_id)
