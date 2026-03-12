extends Node

var _plugin_name = "GodotStepPlugin"
var _steps_plugin
var dailySteps := 0

func _ready():
	if Engine.has_singleton(_plugin_name):
		_steps_plugin = Engine.get_singleton(_plugin_name)
		_steps_plugin.on_steps_read.connect(_on_steps)
		_steps_plugin.on_steps_error.connect(_on_error)
		_steps_plugin.on_permission_result.connect(_on_permission)
		_steps_plugin.request_permissions()
	else:
		#fallback for testing
		dailySteps = 6001

func _on_steps(steps):
	dailySteps = steps

func _on_error(err):
	print("Steps error:",err)
	dailySteps = 6000

func _on_permission(result : bool):
	if result:
		_on_timer_timeout()
		var timer = Timer.new()
		timer.wait_time = 10
		timer.autostart = true
		timer.one_shot = false
		timer.timeout.connect(_on_timer_timeout)
		add_child(timer)
	
func _on_timer_timeout():
	_steps_plugin.readTodaySteps()
