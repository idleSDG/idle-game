extends Node2D

func _ready() -> void:
	PlayerInventory.steps.steps_permissions.connect(_ready)
	PlayerInventory.screentime.screen_time_permissions.connect(_ready)
	if PlayerInventory.steps.has_history_permissions:
		$CanvasLayer/StepPermissionsButton.text = "Step permissions already granted"
	if PlayerInventory.screentime.has_history_permissions:
		$CanvasLayer/ScreenUsagePermissionsButton.text = "Screen time permissions already granted"

func _on_clear_save_pressed() -> void:
	SaveManager.clear_save()

func _on_request_step_permissions_pressed() -> void:
	if not PlayerInventory.steps.has_history_permissions:
		PlayerInventory.steps.request_history_permissions()

func _on_request_screen_time_permissions_pressed() -> void:
	if not PlayerInventory.screentime.has_history_permissions:
		PlayerInventory.screentime.request_permissions()
