class_name SkinColorPanel extends PanelContainer

signal changed(color: Color)

@onready var color_picker : ColorPicker = $VBoxContainer/ColorPicker

func _ready() -> void:
	color_picker.color = PlayerAppearance.appearance.skin_color
	color_picker.color_changed.connect(_on_color_changed)
	
func _on_color_changed(color: Color) -> void:
	changed.emit(color)
