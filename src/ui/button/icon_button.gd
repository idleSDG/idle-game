@tool
extends TextureButton
class_name IconButton

@export var button_is_disabled: bool = false:
	set(value):
		button_is_disabled = value
		disabled = value
		_update_visuals()

@export var icon: Texture2D:
	set(value):
		icon = value
		if is_node_ready():
			_update_icon()

@export var show_highlight: bool = false:
	set(value):
		show_highlight = value
		if is_node_ready():
			_update_highlight()

func _ready():
	_update_icon()
	_update_highlight()

func _update_icon():
	var icon_node = get_node_or_null("Icon")
	if icon_node:
		icon_node.texture = icon
		
func _update_visuals():
	if disabled:
		self.modulate.a = 0.33
	else:
		self.modulate.a = 1.0

func _on_button_down():
	if Engine.is_editor_hint(): 
		return
	
	var icon_node = get_node_or_null("Icon")
	if icon_node:
		var offset_amount = size.y / 16.0
		icon_node.position.y += offset_amount

func _on_button_up():
	if Engine.is_editor_hint(): 
		return
	
	var icon_node = get_node_or_null("Icon")
	if icon_node:
		icon_node.position.y = 0

func _update_highlight():
	var border = get_node_or_null("HighlightBorder")
	if border:
		border.visible = show_highlight
