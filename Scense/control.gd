extends Control

@export var start_seconds: int = 60
var time_left: int

@onready var timer: Timer = $GameTimer
@onready var label: Label = $Label

@export var lose_ui_path: NodePath
@onready var lose_ui = get_node_or_null(lose_ui_path)

func _ready() -> void:
	time_left = start_seconds
	label.text = "%02d : %02d" % [time_left / 60, time_left % 60]

	timer.wait_time = 1.0
	timer.one_shot = false
	timer.timeout.connect(_on_tick)
	timer.start()

func _on_tick() -> void:
	time_left -= 1
	time_left = max(time_left, 0)
	label.text = "%02d : %02d" % [time_left / 60, time_left % 60]
	if time_left <= 0:
		timer.stop()
		lose_ui.show_lose_screen()
		print("Game Over")
