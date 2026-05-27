extends Node2D

@onready var enabled_texture = load("res://assets/hud/buttons/sound_icon.tres")
@onready var disabled_texture = load("res://assets/hud/buttons/sound_disabled_icon.tres")


func _ready() -> void:
	if not PlayerInventory.steps.steps_permissions.is_connected(_ready):
		PlayerInventory.steps.steps_permissions.connect(_ready)
	if not PlayerInventory.sleep.sleep_permissions.is_connected(_ready):
		PlayerInventory.sleep.sleep_permissions.connect(_ready)
	if not PlayerInventory.screentime.screen_time_permissions.is_connected(_ready):
		PlayerInventory.screentime.screen_time_permissions.connect(_ready)
	if PlayerInventory.steps.has_history_permissions && PlayerInventory.sleep.has_history_permissions:
		$CanvasLayer/ScrollContainer/SizingControl/Permissions/PermissionVBoxContainer/StepAndSleepButton.button_text = "Step and sleep permissions granted"
		$CanvasLayer/ScrollContainer/SizingControl/Permissions/PermissionVBoxContainer/StepAndSleepButton.is_disabled = true
	if PlayerInventory.screentime.has_history_permissions:
		$CanvasLayer/ScrollContainer/SizingControl/Permissions/PermissionVBoxContainer/ScreenTimeButton.button_text = "Screen time permissions granted"
		$CanvasLayer/ScrollContainer/SizingControl/Permissions/PermissionVBoxContainer/ScreenTimeButton.is_disabled = true
	_set_sound_button_icons()
	$CanvasLayer/ScrollContainer.get_v_scroll_bar().custom_minimum_size.x = 20

func _set_sound_button_icons():
	var audio_bus = $CanvasLayer/ScrollContainer/SizingControl/Sound/VolumeVBoxContainer/VolumeVBoxContainer/SliderHBoxContainer/VolumeSlider.bus_index
	var disabled = AudioServer.is_bus_mute(audio_bus)
	if disabled:
		$CanvasLayer/ScrollContainer/SizingControl/Sound/VolumeVBoxContainer/VolumeVBoxContainer/SliderHBoxContainer/VolumeButton.icon = disabled_texture
	else:
		$CanvasLayer/ScrollContainer/SizingControl/Sound/VolumeVBoxContainer/VolumeVBoxContainer/SliderHBoxContainer/VolumeButton.icon = enabled_texture

	audio_bus = $CanvasLayer/ScrollContainer/SizingControl/Sound/VolumeVBoxContainer/VolumeVBoxContainer2/SliderHBoxContainer/VolumeSlider.bus_index
	disabled = AudioServer.is_bus_mute(audio_bus)
	if disabled:
		$CanvasLayer/ScrollContainer/SizingControl/Sound/VolumeVBoxContainer/VolumeVBoxContainer2/SliderHBoxContainer/VolumeButton.icon = disabled_texture
	else:
		$CanvasLayer/ScrollContainer/SizingControl/Sound/VolumeVBoxContainer/VolumeVBoxContainer2/SliderHBoxContainer/VolumeButton.icon = enabled_texture

	audio_bus = $CanvasLayer/ScrollContainer/SizingControl/Sound/VolumeVBoxContainer/VolumeVBoxContainer3/SliderHBoxContainer/VolumeSlider.bus_index
	disabled = AudioServer.is_bus_mute(audio_bus)
	if disabled:
		$CanvasLayer/ScrollContainer/SizingControl/Sound/VolumeVBoxContainer/VolumeVBoxContainer3/SliderHBoxContainer/VolumeButton.icon = disabled_texture
	else:
		$CanvasLayer/ScrollContainer/SizingControl/Sound/VolumeVBoxContainer/VolumeVBoxContainer3/SliderHBoxContainer/VolumeButton.icon = enabled_texture


func _on_clear_save_pressed() -> void:
	SaveManager.clear_save()


func _on_request_step_permissions_pressed() -> void:
	if not PlayerInventory.steps.has_history_permissions:
		PlayerInventory.step_sleep_manager.request_history_permissions()


func _on_request_screen_time_permissions_pressed() -> void:
	if not PlayerInventory.screentime.has_history_permissions:
		PlayerInventory.screentime.request_permissions()


func _on_volume_slider_1_value_changed(value: float) -> void:
	$CanvasLayer/ScrollContainer/SizingControl/Sound/VolumeVBoxContainer/VolumeVBoxContainer/SliderHBoxContainer/VolumeLabel.text = str(int(value * 100)) + "%"


func _on_volume_slider_2_value_changed(value: float) -> void:
	$CanvasLayer/ScrollContainer/SizingControl/Sound/VolumeVBoxContainer/VolumeVBoxContainer2/SliderHBoxContainer/VolumeLabel.text = str(int(value * 100)) + "%"


func _on_volume_slider_3_value_changed(value: float) -> void:
	$CanvasLayer/ScrollContainer/SizingControl/Sound/VolumeVBoxContainer/VolumeVBoxContainer3/SliderHBoxContainer/VolumeLabel.text = str(int(value * 100)) + "%"


func _on_volume_button_1_pressed() -> void:
	var audio_bus = $CanvasLayer/ScrollContainer/SizingControl/Sound/VolumeVBoxContainer/VolumeVBoxContainer/SliderHBoxContainer/VolumeSlider.bus_index
	var disabled = AudioServer.is_bus_mute(audio_bus)
	print(disabled)
	if disabled:
		$CanvasLayer/ScrollContainer/SizingControl/Sound/VolumeVBoxContainer/VolumeVBoxContainer/SliderHBoxContainer/VolumeButton.icon = enabled_texture
		AudioServer.set_bus_mute(audio_bus, false)
	else:
		$CanvasLayer/ScrollContainer/SizingControl/Sound/VolumeVBoxContainer/VolumeVBoxContainer/SliderHBoxContainer/VolumeButton.icon = disabled_texture
		AudioServer.set_bus_mute(audio_bus, true)


func _on_volume_button_2_pressed() -> void:
	var audio_bus = $CanvasLayer/ScrollContainer/SizingControl/Sound/VolumeVBoxContainer/VolumeVBoxContainer2/SliderHBoxContainer/VolumeSlider.bus_index
	var disabled = AudioServer.is_bus_mute(audio_bus)
	print(disabled)
	if disabled:
		$CanvasLayer/ScrollContainer/SizingControl/Sound/VolumeVBoxContainer/VolumeVBoxContainer2/SliderHBoxContainer/VolumeButton.icon = enabled_texture
		AudioServer.set_bus_mute(audio_bus, false)
	else:
		$CanvasLayer/ScrollContainer/SizingControl/Sound/VolumeVBoxContainer/VolumeVBoxContainer2/SliderHBoxContainer/VolumeButton.icon = disabled_texture
		AudioServer.set_bus_mute(audio_bus, true)


func _on_volume_button_3_pressed() -> void:
	var audio_bus = $CanvasLayer/ScrollContainer/SizingControl/Sound/VolumeVBoxContainer/VolumeVBoxContainer3/SliderHBoxContainer/VolumeSlider.bus_index
	var disabled = AudioServer.is_bus_mute(audio_bus)
	print(disabled)
	if disabled:
		$CanvasLayer/ScrollContainer/SizingControl/Sound/VolumeVBoxContainer/VolumeVBoxContainer3/SliderHBoxContainer/VolumeButton.icon = enabled_texture
		AudioServer.set_bus_mute(audio_bus, false)
	else:
		$CanvasLayer/ScrollContainer/SizingControl/Sound/VolumeVBoxContainer/VolumeVBoxContainer3/SliderHBoxContainer/VolumeButton.icon = disabled_texture
		AudioServer.set_bus_mute(audio_bus, true)
