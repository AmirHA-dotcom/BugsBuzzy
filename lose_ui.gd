extends CanvasLayer

# Optional, only if you use a GameManager soft-restart
@export var manager_path: NodePath
@onready var manager = get_node_or_null(manager_path)

@onready var ctrl: Control = $Control
@onready var restart_btn: Button = $Control/Restart_Button
@onready var main_menu_btn: Button = $Control/MainMenu_Button


func _ready() -> void:
	# Make the whole UI respond while the tree is paused
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	ctrl.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	restart_btn.process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	# Ensure the button is clickable and connected
	restart_btn.disabled = false
	restart_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	if not restart_btn.pressed.is_connected(_on_restart_button_pressed):
		restart_btn.pressed.connect(_on_restart_button_pressed)
		
		# Ensure main menu button works while paused
	main_menu_btn.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	main_menu_btn.disabled = false
	main_menu_btn.mouse_filter = Control.MOUSE_FILTER_STOP

	if not main_menu_btn.pressed.is_connected(_on_main_menu_button_pressed):
		main_menu_btn.pressed.connect(_on_main_menu_button_pressed)


	# Put UI on top of subviewports if needed
	layer = 10

func show_lose_screen() -> void:
	visible = true
	get_tree().paused = true

func _on_restart_button_pressed() -> void:
	print("Restart pressed")
	get_tree().paused = false
	# Soft restart through manager if you have one; otherwise hard reload.
	if manager and manager.has_method("start_match"):
		visible = false
		manager.start_match()
	else:
		get_tree().reload_current_scene()


func _on_main_menu_button_pressed() -> void:
	print("Main Menu pressed")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scense/main_menu.tscn")
