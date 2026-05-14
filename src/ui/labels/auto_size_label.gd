class_name AutoSizeLabel extends Label

@export var max_font_size: int = 32
@export var min_font_size: int = 12

func _ready():
	resized.connect(update_font_size)
	item_rect_changed.connect(update_font_size)
	update_font_size()

func update_font_size():
	if not label_settings:
		label_settings = LabelSettings.new()
		label_settings.font_size = max_font_size

	var current_size = max_font_size
	label_settings.font_size = current_size
	
	var font = label_settings.font
	if not font:
		font = get_theme_font("font")

	while current_size > min_font_size:
		var text_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, current_size)
		if text_size.x <= size.x:
			break
		current_size -= 1
	
	label_settings.font_size = current_size
