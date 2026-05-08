class_name steps_sleep_plugin_manager
extends Node

var sleep: sleep_progress
var steps: steps_progress

var _plugin_name = "GodotStepAndSleepPlugin"
var _plugin


func _init() -> void:
	sleep = sleep_progress.new()
	steps = steps_progress.new()
	if Engine.has_singleton(_plugin_name):
		_plugin = Engine.get_singleton(_plugin_name)
		_plugin.on_error.connect(_on_error)
		_plugin.on_history_permission_result.connect(_on_history_permission)
		_plugin.request_history_permissions()
	else:
		_set_fallback_data(true, true)


func _on_error(err):
	print("Sleep error:", err)
	sleep.set_fallback_data()
	steps.set_fallback_data()


func get_classes():
	return [steps, sleep]


func _on_history_permission(steps_granted: bool, sleep_granted: bool):
	if !sleep.has_sleep_data():
		if sleep_granted:
			sleep.has_history_permissions = true
			sleep.sleep_permissions.emit()
			sleep.fetch_sleep()

	if !steps.has_steps_data():
		if steps_granted:
			steps.has_history_permissions = true
			steps.steps_permissions.emit()
			steps.fetch_steps()
			var timer = Timer.new()
			timer.wait_time = 10
			timer.autostart = true
			timer.one_shot = false
			timer.timeout.connect(steps.fetch_steps)
			add_child(timer)


func _set_fallback_data(set_sleep: bool, set_steps: bool):
	if set_sleep:
		sleep.set_fallback_data()
	if set_steps:
		steps.set_fallback_data()
		
func request_history_permissions():
	if Engine.has_singleton(_plugin_name):
		_plugin.request_history_permissions()
