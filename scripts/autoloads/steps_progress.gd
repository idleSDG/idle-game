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

func _on_error(_err):
	dailySteps = 6000

func _on_permission(result : bool):
	if result:
		var end = Time.get_unix_time_from_system()*1000
		var time = Time.get_datetime_dict_from_system()
		var start = Time.get_unix_time_from_system()*1000 - time["hour"]*3600000 - time["minute"]*60000 - time["second"]*10000
		_steps_plugin.read_steps(start,end)
		var timer = Timer.new()
		timer.wait_time = 20
		timer.autostart = true
		timer.one_shot = false
		timer.timeout.connect(_on_timer_timeout)
		add_child(timer)
	
func _on_timer_timeout():
	var end = Time.get_unix_time_from_system() * 1000
	var dt = Time.get_datetime_dict_from_system()
	dt["hour"] = 0
	dt["minute"] = 0
	dt["second"] = 0
	var start = Time.get_unix_time_from_datetime_dict(dt) * 1000
	
	_steps_plugin.read_steps(start,end)
