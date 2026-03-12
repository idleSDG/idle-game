extends Node


func _on_test_battle_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/battle_area.tscn")
