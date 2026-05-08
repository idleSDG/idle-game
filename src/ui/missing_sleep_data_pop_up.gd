extends Control

var sleep: sleep_progress


func _ready() -> void:
	sleep = PlayerInventory.sleep
	sleep.sleep_data_popup.connect(_on_sleep_popup)


func _on_sleep_popup() -> void:
	%MissingSleepDataPopUp.visible = true


func _on_sleep_data_fallback_button_pressed() -> void:
	sleep.set_fallback_data()
	%MissingSleepDataPopUp.visible = false


func _on_sleep_data_device_data_button_pressed() -> void:
	sleep.mark_sleep_ready()
	%MissingSleepDataPopUp.visible = false
