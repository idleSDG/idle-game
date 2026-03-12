extends Node

var _plugin_name = "GodotStepPlugin"
var _steps_plugin
var dailySteps := 0
var sensorSteps := 0

func _ready():
	if Engine.has_singleton(_plugin_name):
		_steps_plugin = Engine.get_singleton(_plugin_name)
		_steps_plugin.on_steps_read.connect(_on_steps)
		_steps_plugin.on_steps_error.connect(_on_error)
		_steps_plugin.on_history_permission_result.connect(_on_history_permission)
		_steps_plugin.on_sensor_permission_result.connect(_on_sensor_permission)
		_steps_plugin.on_realtime_steps.connect(_on_realtime_step)
		_steps_plugin.request_history_permissions()
	else:
		#fallback for testing
		dailySteps = 6001

func _on_steps(steps):
	dailySteps = steps

func _on_realtime_step(steps):
	sensorSteps = steps


func _on_error(err):
	print("Steps error:",err)
	dailySteps = 6000

func _on_history_permission(result : bool):
	if result:
		_steps_plugin.readTodaySteps()
		_steps_plugin.request_sensor_permissions()

func _on_sensor_permission(result : bool):
	if result:
		_steps_plugin.start_step_sensor()
