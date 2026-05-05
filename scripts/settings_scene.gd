extends Node2D

func _ready() -> void:
	StepsProgress.steps_permissions.connect(_ready)
	ScreenTimeProgress.screen_time_permissions.connect(_ready)
	if StepsProgress.has_history_permissions:
		$CanvasLayer/StepPermissionsButton.text = "Step permissions already granted"
	if ScreenTimeProgress.has_history_permissions:
		$CanvasLayer/ScreenUsagePermissionsButton.text = "Screen time permissions already granted"

func _on_clear_save_pressed() -> void:
	SaveManager.clear_save()

func _on_request_step_permissions_pressed() -> void:
	if not StepsProgress.has_history_permissions:
		StepsProgress.request_history_permissions()

func _on_request_screen_time_permissions_pressed() -> void:
	if not ScreenTimeProgress.has_history_permissions:
		ScreenTimeProgress.request_permissions()
