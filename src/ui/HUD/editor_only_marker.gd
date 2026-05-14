@tool
## Use this to mark areas on the screen in the editor, they won't be visible in-game unless flag 'Visible in Game' is checked..
class_name EditorOnlyMarkerArea extends ColorRect

@export var visible_in_game = false

func _ready():
	if not Engine.is_editor_hint() && !visible_in_game:
		hide()
