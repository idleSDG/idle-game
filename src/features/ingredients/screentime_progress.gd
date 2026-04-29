class_name screentime_progress
extends Node

signal screen_time_data_ready
signal screen_time_permissions

var _plugin_name = "GodotScreenTimePlugin"
var _screen_time_plugin
var _has_screen_time_data: bool = false
var lookback_days: int = 7

var screen_time_data_by_hour: Dictionary = { }
var has_history_permissions: bool
const GRAPH_MAX_SCREEN_TIME: int = 0


func _init() -> void:
	has_history_permissions = false
	if Engine.has_singleton(_plugin_name):
		_screen_time_plugin = Engine.get_singleton(_plugin_name)
		_screen_time_plugin.on_screen_usage_results.connect(_on_screen_usage)
		_screen_time_plugin.on_screen_time_error.connect(_on_error)
		_screen_time_plugin.on_usage_permission_result.connect(_on_permissions)
		request_permissions()
	else:
		#fallback for testing
		_set_fallback_data()
		_mark_screen_time_ready()


func _on_screen_usage(hourly_array: Array):
	screen_time_data_by_hour.clear()
	for i in range(hourly_array.size()):
		var hours_ago = hourly_array.size() - 1 - i
		var minutes = hourly_array[i] / 1000 / 60
		#using negative minutes so the calculations are easier (higer == worse)
		screen_time_data_by_hour[hours_ago] = -minutes
		_mark_screen_time_ready()


func _on_error(err):
	print("Steps error:", err)
	_set_fallback_data()
	_mark_screen_time_ready()


func _mark_screen_time_ready():
	if _has_screen_time_data:
		return
	_has_screen_time_data = true
	screen_time_data_ready.emit()


func request_permissions():
	#var timer = Timer.new()
	#timer.wait_time = 10
	#timer.autostart = true
	#timer.one_shot = false
	#timer.timeout.connect(_on_permissions.bind(false))
	#add_child(timer)
	if Engine.has_singleton(_plugin_name):
		_screen_time_plugin.requestUsagePermissions()


func _notification(what: int) -> void:
	if Engine.has_singleton(_plugin_name) && not has_history_permissions:
		if (what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN):
			_screen_time_plugin.hasUsageStatsPermission()


func _on_permissions(permissions: bool):
	if permissions:
		has_history_permissions = true
		emit_signal("screen_time_permissions")
		_fetch_screen_time()
		var timer = Timer.new()
		timer.wait_time = 60
		timer.autostart = true
		timer.one_shot = false
		timer.timeout.connect(_fetch_screen_time)
		add_child(timer)
	else:
		# For now set the screen time to the fallback if permissions are denied
		_set_fallback_data()
		_mark_screen_time_ready()


func _fetch_screen_time():
	_screen_time_plugin.readScreenTimeDays(lookback_days)


func get_latest_value_for_profile() -> Dictionary:
	return {
		"time": Time.get_unix_time_from_system(),
		"val": screen_time_data_by_hour.get(0, 0),
	}


func get_profile_momentum_history_between(start_t: float, end_t: float) -> Array:
	var history: Array = []
	if end_t <= start_t:
		history.append(
			{
				"time": end_t,
				"val": get_latest_value_for_profile()["val"],
			},
		)
		return history

	var max_window_seconds := float(168) * 3600.0
	var clamped_start_t = max(start_t, end_t - max_window_seconds)

	var cursor = clamped_start_t
	while cursor < end_t:
		var hour_start := float(_start_of_hour_unix(cursor))
		var hour_offset = _hour_offset_for_unix(cursor)
		var hour_val = float(screen_time_data_by_hour.get(hour_offset, 0))
		history.append({ "time": cursor, "val": hour_val })
		cursor = hour_start + 3600.0

	return history


func _timezone_offset_seconds() -> int:
	return -int(Time.get_time_zone_from_system()["bias"]) * 60


func _start_of_hour_unix(unix_time: float) -> int:
	var offset := _timezone_offset_seconds()
	var local_unix := int(unix_time) - offset
	var local_hour_start := local_unix - posmod(local_unix, 3600)
	return local_hour_start + offset


func _hour_offset_for_unix(unix_time: float) -> int:
	var current_hour_start := _start_of_hour_unix(Time.get_unix_time_from_system())
	var target_hour_start := _start_of_hour_unix(unix_time)
	var delta_seconds := current_hour_start - target_hour_start
	var delta_hours := int(floor(float(delta_seconds) / 3600.0))
	return maxi(clampi(delta_hours, 0, 167), 0)


func get_last_days_screen_time_history(days: int = lookback_days) -> Array:
	var hours = days * 24
	hours = clamp(hours, 1, 167)
	var history: Array = []
	var counter = 0
	for offset in range(hours, -1, -1):
		var clamped_time := clampi(screen_time_data_by_hour.get(offset, -30), -60, GRAPH_MAX_SCREEN_TIME)
		history.append(
			{
				"time": counter,
				"val": float(clamped_time),
			},
		)
		counter += 1

	return history


func has_screen_time_data() -> bool:
	return _has_screen_time_data


func _set_fallback_data():
	var hour_counter = 0
	for i in range(1, 8):
		for j in range(0, 24):
			if ((0 <= j) and (j <= 1)) or ((22 <= j) and (j <= 23)):
				screen_time_data_by_hour[hour_counter] = 0
			elif (j < 12):
				screen_time_data_by_hour[hour_counter] = (j - 1) * (-6)
			else:
				screen_time_data_by_hour[hour_counter] = -(60 + ((j - 12) * (-6)))
			hour_counter += 1
	screen_time_data_by_hour[0] = -10
