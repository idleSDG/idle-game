extends Node2D

@onready var content = $CanvasLayer

var battle_area_scene := preload("res://scenes/battle_area.tscn")
var level_select_scene := preload("res://scenes/battle.tscn")

var current_view: Node = null

func _ready() -> void:
	if (GlobalVariables.battleState == GlobalVariables.BattleStates.IN_BATTLE 
	or GlobalVariables.battleState == GlobalVariables.BattleStates.AWAITING_EXIT):
		enter_battle()

func show_level_select() -> void:
	_swap_to(level_select_scene)

func enter_battle() -> void:
	_swap_to(battle_area_scene)

func exit_battle() -> void:
	_swap_to(level_select_scene)

func _swap_to(scene_res: PackedScene) -> void:
	if current_view and current_view.get_parent():
		current_view.queue_free()
	current_view = scene_res.instantiate()
	content.add_child(current_view)
	if current_view.has_signal("request_start_signal"):
		current_view.request_start_signal.connect(_on_start_battle_request)
	if current_view.has_signal("request_exit_signal"):
		current_view.request_exit_signal.connect(_on_exit_battle_request)


func _on_start_battle_request() -> void:
	enter_battle()

func _on_exit_battle_request() -> void:
	exit_battle()
