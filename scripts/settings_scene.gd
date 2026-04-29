extends Node2D

func _ready() -> void:
	if not PlayerInventory.steps.steps_permissions.is_connected(_ready):
		PlayerInventory.steps.steps_permissions.connect(_ready)
	if not PlayerInventory.sleep.sleep_permissions.is_connected(_ready):
		PlayerInventory.sleep.sleep_permissions.connect(_ready)
	if not PlayerInventory.screentime.screen_time_permissions.is_connected(_ready):
		PlayerInventory.screentime.screen_time_permissions.connect(_ready)
	if PlayerInventory.steps.has_history_permissions && PlayerInventory.sleep.has_history_permissions:
		$CanvasLayer/StepPermissionsButton.text = "Step and sleep permissions already granted"
	if PlayerInventory.screentime.has_history_permissions:
		$CanvasLayer/ScreenUsagePermissionsButton.text = "Screen time permissions already granted"

func _on_clear_save_pressed() -> void:
	SaveManager.clear_save()

func _on_request_step_permissions_pressed() -> void:
	if not PlayerInventory.steps.has_history_permissions:
		PlayerInventory.steps.request_history_permissions()
	if not PlayerInventory.sleep.has_history_permissions:
		PlayerInventory.sleep.request_history_permissions()

func _on_request_screen_time_permissions_pressed() -> void:
	if not PlayerInventory.screentime.has_history_permissions:
		PlayerInventory.screentime.request_permissions()
