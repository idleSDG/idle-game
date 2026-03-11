extends Node

# THIS SCRIPT IS ON MAIN's ROOT NODE

# Loads save data upon turning the game on and, if the player was in battle, resumes it
func _ready() -> void:
	GlobalVariables.load_game()
	if GlobalVariables.inBattle:
		get_tree().change_scene_to_file("res://scenes/battle.tscn")
