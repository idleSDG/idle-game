extends Node

signal appearance_changed

var appearance : WizardAppearance = WizardAppearance.new()

func apply_skin_color(color: Color) -> void:
	appearance.skin_color = color
	appearance_changed.emit()

func get_save_data() -> Dictionary:
	return appearance.get_save_data()

func load_save_data(data: Dictionary) -> void:
	appearance.load_save_data(data)
	appearance_changed.emit()

func init_new_save() -> void:
	appearance = WizardAppearance.new()
	appearance_changed.emit()
