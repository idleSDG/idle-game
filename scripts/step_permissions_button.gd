extends Button

func _ready() -> void:
	if StepsProgress.has_history_permissions:
		text = "Step permissions already granted"

func _on_pressed() -> void:
	if not StepsProgress.has_history_permissions:
		StepsProgress.request_history_permissions()
