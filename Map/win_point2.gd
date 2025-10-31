# WinPoint.gd
extends Area3D

@export var target_player_id: int = 2
signal player_reached(player_id: int)

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body is Player and body.player_id == target_player_id:
		print("Player %d reached WinPoint_%d" % [body.player_id, target_player_id])
		player_reached.emit(body.player_id)
