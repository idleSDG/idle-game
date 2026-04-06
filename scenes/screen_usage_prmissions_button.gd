extends Button

func _ready() -> void:
	if ScreenTimeProgress.has_history_permissions:
		text = "Screen time permissions already granted"

func _on_pressed() -> void:
	if not ScreenTimeProgress.has_history_permissions:
		ScreenTimeProgress.request_permissions()
