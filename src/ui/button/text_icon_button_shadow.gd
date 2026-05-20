@tool
extends NinePatchRect

@onready var _button: TextIconButton = $".."


func _ready() -> void:
	if _button:
		self.texture = _button.normal_texture


func _on_button_down() -> void:
	if _button and _button.pressed_texture:
		self.texture = _button.pressed_texture


func _on_button_up() -> void:
	if _button and _button.normal_texture:
		self.texture = _button.normal_texture
