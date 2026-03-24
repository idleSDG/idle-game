extends Node2D

signal request_start_signal

@onready var test_battle_button: Button = $CanvasLayer/testBattleButton

func _ready() -> void:
	test_battle_button.pressed.connect(_on_test_battle_button_pressed)

func _on_test_battle_button_pressed() -> void:
	request_start_signal.emit()
