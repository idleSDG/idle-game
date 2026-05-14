extends Node

@onready var button: TextureButton = $".."

func _ready():
	button.pressed.connect(_on_button_pressed)

func _on_button_pressed():
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2(1.2, 1.2), 0.05)
