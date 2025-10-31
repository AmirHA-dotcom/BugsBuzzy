extends Control

@onready var start_button = $StartButton
@onready var name_box = $LineEdit

func _ready():
	start_button.pressed.connect(_on_start_pressed)

func _on_start_pressed():
	var text = name_box.text
	GameManager.groupID = text
	print("Typed text: ", text)  # just printing for now
	get_tree().change_scene_to_file("res://Scense/game_on.tscn")
