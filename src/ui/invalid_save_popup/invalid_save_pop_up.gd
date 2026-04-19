extends Control

@onready var error_label: Label = $SaveErrorBackgroundBlur/SaveErrorPanelContainer/SaveErrorVBoxContainer/SaveErrorMarginContainer/SaveErrorSaveLabel

func _ready() -> void:
	hide()
	SaveManager.save_load_failed.connect(_on_save_load_failed)

func _on_save_load_failed(error: SaveManager.SaveReadError):
	match error:
		SaveManager.SaveReadError.INVALID_SAVE:
			_display_error("Your save file is invalid. Press the button below to clear it. (This will reset all progress!)")

func _display_error(message: String) -> void:
	if error_label:
		error_label.text = message
	show()
	get_tree().paused = true
	
func _on_clear_invalid_save_button_pressed() -> void:
	get_tree().paused = false
	SaveManager.clear_save()
	self.visible = false
