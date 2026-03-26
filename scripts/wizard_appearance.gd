class_name WizardAppearance
extends Resource

var skin_color : Color = Color(0.92, 0.78, 0.62)  # default skin color

func get_skin_color() -> Color:
	return skin_color

func get_save_data() -> Dictionary:
	return {
		"skin_color_r": skin_color.r,
		"skin_color_g": skin_color.g,
		"skin_color_b": skin_color.b,
	}

func load_save_data(data: Dictionary) -> void:
	skin_color  = Color(
		data.get("skin_color_r", 0.92),
		data.get("skin_color_g", 0.78),
		data.get("skin_color_b", 0.62)
	)
