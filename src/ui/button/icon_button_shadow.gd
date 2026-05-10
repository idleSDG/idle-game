@tool

extends TextureRect

@onready var button: TextureButton = $".."

func _ready():
	self.texture = button.texture_normal

func _on_button_down():
	self.texture = button.texture_pressed
	
func _on_button_up():
	self.texture = button.texture_normal
