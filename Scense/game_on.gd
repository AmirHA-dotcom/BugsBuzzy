# GameManager.gd (attach to a Node that exists in the running scene, e.g., the root)
extends Node

@export var win_p1_path: NodePath
@export var win_p2_path: NodePath

@export var player1_path: NodePath
@export var player2_path: NodePath
@export var label_p1_path: NodePath
@export var label_p2_path: NodePath

@onready var win_p1: Node = get_node_or_null(win_p1_path)
@onready var win_p2: Node = get_node_or_null(win_p2_path)

@export var win_ui_path: NodePath
@onready var win_ui = get_node_or_null(win_ui_path)


var p1_done := false
var p2_done := false

func _ready() -> void:
	if win_p1 == null or win_p2 == null:
		push_error("GameManager: WinPoint paths not set or not found.")
		# Optional: print the tree to verify paths
		# get_tree().current_scene.print_tree_pretty()
		return

	# Connect once
	win_p1.player_reached.connect(_on_player_reached)
	win_p2.player_reached.connect(_on_player_reached)
	
	# Connect once
	p1.ability_changed.connect(_on_ability_changed)
	p2.ability_changed.connect(_on_ability_changed)

	# Force initial HUD refresh (in case players emitted before GM ready)
	_on_ability_changed(1, p1.ability_left, p1.max_ability_count)
	_on_ability_changed(2, p2.ability_left, p2.max_ability_count)

func _on_player_reached(player_id: int) -> void:
	if player_id == 1:
		p1_done = true
	elif player_id == 2:
		p2_done = true

	print("Reached status -> P1:%s  P2:%s" % [str(p1_done), str(p2_done)])

	if p1_done and p2_done:
		print("🎉 BOTH PLAYERS WIN! Show UI here.")
		win_ui.show_win_screen()
		# Optional: prevent re-trigger
		p1_done = false
		p2_done = false


@onready var p1: Player = get_node(player1_path)
@onready var p2: Player = get_node(player2_path)
@onready var label_p1: Label = get_node(label_p1_path)
@onready var label_p2: Label = get_node(label_p2_path)


func _on_ability_changed(pid: int, left: int, maxc: int) -> void:
	var txt := "Ability %d/%d" % [left, maxc]
	if pid == 1 and label_p1:
		label_p1.text = txt
	elif pid == 2 and label_p2:
		label_p2.text = txt
